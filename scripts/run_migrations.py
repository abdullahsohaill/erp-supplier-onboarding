#!/usr/bin/env python3
from __future__ import annotations

import argparse
import hashlib
import json
import os
import re
import ssl
import sys
import time
from dataclasses import dataclass
from datetime import UTC, datetime
from pathlib import Path

import oracledb

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "database" / "migrations" / "manifest.json"
REPORT = ROOT / "reports" / "migration-execution.json"


@dataclass(frozen=True)
class Step:
    sequence: int
    phase: str
    path: Path
    connection: str
    sha256: str
    purpose: str


def load_env() -> None:
    path = ROOT / ".env"
    if not path.exists():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, value = line.split("=", 1)
        os.environ.setdefault(key.strip(), value.strip())


def file_hash(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_manifest() -> list[Step]:
    raw = json.loads(MANIFEST.read_text(encoding="utf-8"))
    steps: list[Step] = []
    for item in raw["steps"]:
        path = ROOT / item["file"]
        actual = file_hash(path)
        if actual != item["sha256"]:
            raise RuntimeError(f"Checksum mismatch for {item['file']}: expected {item['sha256']}, got {actual}")
        steps.append(Step(item["sequence"], item["phase"], path, item["connection"], actual, item["purpose"]))
    return sorted(steps, key=lambda step: step.sequence)


def sql_units(text: str) -> list[str]:
    units: list[str] = []
    buffer: list[str] = []
    plsql = False
    for raw in text.splitlines():
        stripped = raw.strip()
        lower = stripped.lower()
        if not buffer and (not stripped or stripped.startswith("--")):
            continue
        if not buffer and (lower.startswith("set ") or lower.startswith("whenever ") or lower.startswith("prompt ")):
            continue
        if not buffer:
            plsql = bool(re.match(r"^(declare|begin|create\s+or\s+replace\s+(package|procedure|function|trigger))\b", lower))
        if plsql and stripped == "/":
            statement = "\n".join(buffer).strip()
            if statement:
                units.append(statement)
            buffer = []
            plsql = False
            continue
        buffer.append(raw)
        if not plsql and stripped.endswith(";"):
            statement = "\n".join(buffer).strip()[:-1].rstrip()
            if statement:
                units.append(statement)
            buffer = []
    if any(line.strip() for line in buffer):
        raise ValueError("Unterminated SQL or PL/SQL unit")
    return units


def connect(kind: str) -> oracledb.Connection:
    wallet = ROOT / os.environ.get("DB_WALLET_DIR", "wallet/tls_wallet")
    dsn = os.environ.get("DB_DSN", "erpatp_low")
    common = {
        "dsn": dsn,
        "config_dir": str(wallet),
        "wallet_location": str(wallet),
        "wallet_password": os.environ["ADB_WALLET_PASSWORD"],
    }
    if os.environ.get("DB_ALLOW_INSECURE_LOCAL_TLS", "false").lower() == "true":
        tnsnames = (wallet / "tnsnames.ora").read_text(encoding="utf-8")
        alias = re.search(
            rf"(?ims)^\s*{re.escape(dsn)}\s*=\s*(.*?)(?=^\s*[a-z0-9_]+\s*=|\Z)",
            tnsnames,
        )
        if alias is None or re.search(r"\(host\s*=\s*(localhost|127\.0\.0\.1)\)", alias.group(1), re.I) is None:
            raise RuntimeError("DB_ALLOW_INSECURE_LOCAL_TLS is permitted only for a localhost TNS alias")
        context = ssl.create_default_context()
        context.check_hostname = False
        context.verify_mode = ssl.CERT_NONE
        common["ssl_context"] = context
    if kind == "admin":
        return oracledb.connect(user=os.environ.get("DB_ADMIN_USER", "ADMIN"), password=os.environ["ADB_ADMIN_PASSWORD"], **common)
    return oracledb.connect(user=os.environ.get("DB_APP_USER", "ERP_APP"), password=os.environ["ERP_APP_PASSWORD"], **common)


def wait_for_database(timeout_seconds: int) -> None:
    deadline = time.monotonic() + timeout_seconds
    last_error: Exception | None = None
    while time.monotonic() < deadline:
        try:
            with connect("admin") as connection:
                with connection.cursor() as cursor:
                    cursor.execute("select 1 from dual")
                    cursor.fetchone()
            return
        except Exception as exc:  # noqa: BLE001
            last_error = exc
            time.sleep(10)
    raise TimeoutError(f"Database did not become available within {timeout_seconds}s: {last_error}")


def render_sql(step: Step) -> str:
    text = step.path.read_text(encoding="utf-8")
    if "${ERP_APP_PASSWORD}" in text:
        password = os.environ["ERP_APP_PASSWORD"]
        if not re.fullmatch(r"[A-Za-z0-9_#-]{12,30}", password):
            raise ValueError("ERP_APP_PASSWORD must be 12-30 safe characters for bootstrap substitution")
        text = text.replace("${ERP_APP_PASSWORD}", password)
    return text


def run(args: argparse.Namespace) -> int:
    load_env()
    required = ["ADB_ADMIN_PASSWORD", "ADB_WALLET_PASSWORD", "ERP_APP_PASSWORD"]
    missing = [name for name in required if not os.environ.get(name)]
    if missing:
        raise RuntimeError(f"Missing required environment values: {', '.join(missing)}")
    if args.wait:
        wait_for_database(args.wait_timeout)

    records: list[dict[str, object]] = []
    connections: dict[str, oracledb.Connection] = {}
    try:
        for step in load_manifest():
            if args.phase and step.phase not in args.phase:
                continue
            record: dict[str, object] = {
                "sequence": step.sequence,
                "phase": step.phase,
                "file": str(step.path.relative_to(ROOT)),
                "purpose": step.purpose,
                "sha256": step.sha256,
                "startedAt": datetime.now(UTC).isoformat(),
            }
            try:
                connection = connections.get(step.connection)
                if connection is None:
                    connection = connect(step.connection)
                    connections[step.connection] = connection
                units = sql_units(render_sql(step))
                with connection.cursor() as cursor:
                    for statement in units:
                        cursor.execute(statement)
                connection.commit()
                record.update({"status": "SUCCEEDED", "unitCount": len(units)})
            except Exception as exc:
                if step.connection in connections:
                    connections[step.connection].rollback()
                record.update({"status": "FAILED", "error": str(exc)})
                records.append(record)
                raise
            finally:
                record["finishedAt"] = datetime.now(UTC).isoformat()
            records.append(record)
    finally:
        for connection in connections.values():
            connection.close()
        REPORT.parent.mkdir(parents=True, exist_ok=True)
        REPORT.write_text(json.dumps({"generatedAt": datetime.now(UTC).isoformat(), "steps": records}, indent=2) + "\n", encoding="utf-8")
    return 0


def main() -> int:
    parser = argparse.ArgumentParser(description="Apply checksummed Oracle ATP/ORDS construction steps.")
    parser.add_argument("--wait", action="store_true", help="Wait for the database before applying steps.")
    parser.add_argument("--wait-timeout", type=int, default=1800)
    parser.add_argument("--phase", action="append", choices=["bootstrap", "schema", "packages", "ords", "seed"])
    return run(parser.parse_args())


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as exc:  # noqa: BLE001
        print(f"migration failed: {exc}", file=sys.stderr)
        raise SystemExit(1)
