from __future__ import annotations

import json
import os
import shutil
import subprocess
import time
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
LOCAL = ROOT / ".local"
SECRETS = LOCAL / "secrets"
TRUST = LOCAL / "trust"
REPORTS = LOCAL / "reports"
WALLET = TRUST / "tls_wallet"
ADB_ENV = SECRETS / "adb.env"


class RuntimeFailure(RuntimeError):
    pass


def ensure_local_dirs() -> None:
    for path in (LOCAL, SECRETS, TRUST, REPORTS):
        path.mkdir(parents=True, exist_ok=True, mode=0o700)
        path.chmod(0o700)


def load_env(path: Path = ADB_ENV) -> dict[str, str]:
    values: dict[str, str] = {}
    if not path.exists():
        return values
    for raw_line in path.read_text(encoding="utf-8").splitlines():
        line = raw_line.strip()
        if not line or line.startswith("#"):
            continue
        key, separator, value = line.partition("=")
        if not separator or not key:
            raise RuntimeFailure(f"Invalid environment entry in {path.name}")
        values[key] = value
    return values


def command(
    args: list[str],
    *,
    check: bool = True,
    capture: bool = True,
    env: dict[str, str] | None = None,
    timeout: int | None = None,
) -> subprocess.CompletedProcess[str]:
    merged_env = os.environ.copy()
    if env:
        merged_env.update(env)
    result = subprocess.run(  # noqa: S603 - callers pass repository-controlled commands.
        args,
        cwd=ROOT,
        env=merged_env,
        check=False,
        text=True,
        capture_output=capture,
        timeout=timeout,
    )
    if check and result.returncode != 0:
        message = result.stderr.strip() or result.stdout.strip() or "command failed"
        raise RuntimeFailure(f"{args[0]} failed: {message}")
    return result


def write_json(path: Path, value: Any) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n", encoding="utf-8")


def require_local_profile() -> None:
    profile = os.environ.get("ERP_ENVIRONMENT", "local-dev")
    if profile not in {"local-dev", "local-test"}:
        raise RuntimeFailure("Destructive/mutating commands require local-dev or local-test")
    if os.environ.get("DATABASE_NAME", "ERPATP") != "ERPATP":
        raise RuntimeFailure("Target database fingerprint is not ERPATP")


def redact(value: str, secrets: dict[str, str] | None = None) -> str:
    result = value
    for secret in (secrets or load_env()).values():
        if secret:
            result = result.replace(secret, "[REDACTED]")
    return result


def sqlplus(
    user: str,
    password: str,
    source: str,
    *,
    service: str = "erpatp_tp",
    timeout: int = 300,
) -> str:
    safe_password = password.replace('"', '""')
    script = (
        "whenever oserror exit failure rollback\n"
        "whenever sqlerror exit sql.sqlcode rollback\n"
        "set echo off feedback on heading on pagesize 500 linesize 240 serveroutput on\n"
        f'connect {user}/"{safe_password}"@{service}\n'
        f"{source.rstrip()}\n"
        "exit success commit\n"
    )
    docker = shutil.which("docker")
    if not docker:
        raise RuntimeFailure("Docker executable not found")
    result = subprocess.run(  # noqa: S603 - fixed local Docker/SQL*Plus invocation.
        [
            docker,
            "exec",
            "-e",
            "TNS_ADMIN=/u01/app/oracle/wallets/tls_wallet",
            "-i",
            "erp-oracle-adb",
            "sqlplus",
            "-L",
            "-s",
            "/nolog",
        ],
        cwd=ROOT,
        input=script,
        text=True,
        capture_output=True,
        timeout=timeout,
        check=False,
    )
    output = redact((result.stdout or "") + (result.stderr or ""), {"password": password})
    if result.returncode != 0:
        raise RuntimeFailure(f"SQL execution failed for {user}: {output.strip()[-2000:]}")
    return output


def wait_for_container_healthy(timeout: int = 1200) -> None:
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        status = command(
            [
                "docker",
                "inspect",
                "--format",
                "{{if .State.Health}}{{.State.Health.Status}}{{else}}{{.State.Status}}{{end}}",
                "erp-oracle-adb",
            ],
            check=False,
        ).stdout.strip()
        if status == "healthy":
            readiness = command(
                [
                    "docker",
                    "exec",
                    "erp-oracle-adb",
                    "bash",
                    "-lc",
                    "test -d /u01/app/oracle/wallets/tls_wallet && "
                    "printf '' | timeout 3 openssl s_client -connect 127.0.0.1:8443 "
                    "-servername localhost 2>/dev/null | grep -q 'BEGIN CERTIFICATE'",
                ],
                check=False,
            )
            if readiness.returncode == 0:
                return
        if status in {"exited", "dead"}:
            logs = command(
                ["docker", "logs", "--tail", "100", "erp-oracle-adb"], check=False
            ).stdout
            raise RuntimeFailure(f"Oracle container stopped during startup: {redact(logs)[-2000:]}")
        time.sleep(10)
    raise RuntimeFailure(
        "Oracle container did not become healthy within the bounded startup window"
    )
