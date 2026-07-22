from __future__ import annotations

from pathlib import Path

import oracledb
import requests
from runtime import ROOT, RuntimeFailure, load_env

PROFILE = ROOT / ".local/secrets/atp-cloud.env"
REQUIRED = {
    "ATP_CLOUD_USER",
    "ATP_CLOUD_PASSWORD",
    "ATP_CLOUD_DSN",
    "ATP_CLOUD_WALLET_DIR",
    "ATP_CLOUD_WALLET_PASSWORD",
}


def main() -> int:
    env = load_env(PROFILE)
    missing = sorted(name for name in REQUIRED if not env.get(name))
    if missing:
        raise RuntimeFailure(
            "Managed ATP profile is incomplete. Create the database and wallet, then set: "
            + ", ".join(missing)
        )
    wallet = Path(env["ATP_CLOUD_WALLET_DIR"]).expanduser().resolve()
    for name in ("tnsnames.ora", "sqlnet.ora"):
        if not (wallet / name).is_file():
            raise RuntimeFailure(f"Wallet directory is missing {name}")
    connection = oracledb.connect(
        user=env["ATP_CLOUD_USER"],
        password=env["ATP_CLOUD_PASSWORD"],
        dsn=env["ATP_CLOUD_DSN"],
        config_dir=str(wallet),
        wallet_location=str(wallet),
        wallet_password=env["ATP_CLOUD_WALLET_PASSWORD"],
    )
    try:
        with connection.cursor() as cursor:
            cursor.execute(
                "select sys_context('USERENV','DB_NAME'), sys_context('USERENV','CLOUD_SERVICE') "
                "from dual"
            )
            database_name, cloud_service = cursor.fetchone()
            cursor.execute("select count(*) from user_tables")
            table_count = cursor.fetchone()[0]
    finally:
        connection.close()
    print(f"Managed ATP connection passed: database={database_name}, service={cloud_service}")
    print(f"Connected schema currently contains {table_count} tables")
    ords_url = env.get("ATP_CLOUD_ORDS_URL", "").rstrip("/")
    if ords_url:
        response = requests.get(f"{ords_url}/requests", timeout=30)
        if response.status_code not in {401, 403}:
            raise RuntimeFailure(
                "Unauthenticated cloud ORDS boundary returned "
                f"{response.status_code}, expected 401/403"
            )
        print("Managed ORDS unauthenticated boundary passed")
    else:
        print("Managed ORDS check skipped: ATP_CLOUD_ORDS_URL is not configured")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, OSError, oracledb.Error, requests.RequestException) as exc:
        print(f"Managed ATP preflight failed: {exc}")
        raise SystemExit(1) from exc
