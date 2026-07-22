from __future__ import annotations

import os
import subprocess
from pathlib import Path

from runtime import REPORTS, RuntimeFailure, command, load_env, redact, write_json


def main() -> int:
    secrets = load_env()
    password = secrets.get("ERP_VERIFY_PASSWORD")
    if not password:
        raise RuntimeFailure("ERP_VERIFY password is missing")
    openjdk = command(["brew", "--prefix", "openjdk"], timeout=30).stdout.strip()
    caskroom = Path(command(["brew", "--caskroom", "sqlcl"], timeout=30).stdout.strip())
    candidates = sorted(caskroom.glob("*/sqlcl/bin/sql"))
    if not candidates:
        raise RuntimeFailure("Oracle SQLcl executable is missing")
    executable = candidates[-1]

    process_env = os.environ.copy()
    process_env.update(
        {
            "JAVA_HOME": str(Path(openjdk) / "libexec/openjdk.jdk/Contents/Home"),
            "TNS_ADMIN": str(Path.cwd() / ".local/trust/tls_wallet"),
        }
    )
    source = (
        f'connect ERP_VERIFY/"{password}"@erpatp_tp\n'
        "set heading off feedback off pagesize 0 verify off echo off\n"
        "select 'SQLCL_WALLET_OK:' || count(*) from ERP_APP.SUPPLIER_REQUEST;\n"
        "exit success\n"
    )
    result = subprocess.run(  # noqa: S603 - fixed local SQLcl executable.
        [str(executable), "-S", "-NOLOG"],
        cwd=Path.cwd(),
        env=process_env,
        input=source,
        text=True,
        capture_output=True,
        timeout=60,
        check=False,
    )
    safe_output = redact((result.stdout or "") + (result.stderr or ""), secrets)
    if result.returncode != 0 or "SQLCL_WALLET_OK:" not in safe_output:
        raise RuntimeFailure(f"SQLcl wallet smoke failed: {safe_output[-800:]}")
    row_count = safe_output.split("SQLCL_WALLET_OK:", 1)[1].splitlines()[0].strip()
    write_json(
        REPORTS / "sqlcl-smoke.json",
        {
            "status": "PASS",
            "client": "Oracle SQLcl",
            "service": "erpatp_tp",
            "user": "ERP_VERIFY",
            "supplier_request_rows": int(row_count),
            "wallet": ".local/trust/tls_wallet",
        },
    )
    print("Oracle SQLcl wallet connection passed as read-only ERP_VERIFY")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, OSError, ValueError) as exc:
        print(f"SQLcl smoke failed: {exc}")
        raise SystemExit(1) from exc
