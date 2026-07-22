from __future__ import annotations

import os
from pathlib import Path

import pytest
from scripts.local_tls import local_https_session

ROOT = Path(__file__).resolve().parents[1]


def _load_env() -> None:
    env_file = ROOT / ".env"
    if not env_file.exists():
        return
    for raw in env_file.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line and not line.startswith("#") and "=" in line:
            key, value = line.split("=", 1)
            os.environ.setdefault(key, value)


@pytest.fixture(scope="session", autouse=True)
def load_local_environment() -> None:
    _load_env()


@pytest.fixture(scope="session")
def project_root() -> Path:
    return ROOT


@pytest.fixture(scope="session")
def oracle_connection():
    required = ["ADB_WALLET_PASSWORD", "ERP_APP_PASSWORD", "DB_DSN"]
    if any(not os.environ.get(name) for name in required):
        pytest.skip("Local Oracle wallet/database environment is not configured")
    wallet = ROOT / os.environ.get("DB_WALLET_DIR", "wallet/tls_wallet")
    if not wallet.exists():
        pytest.skip("Local Oracle wallet has not been copied")
    import oracledb
    from scripts.run_migrations import connect

    try:
        connection = connect("app")
    except oracledb.Error as exc:
        pytest.skip(f"Local Oracle is unavailable: {exc}")
    yield connection
    connection.close()


@pytest.fixture(scope="session")
def ords_client():
    base = os.environ.get("ORDS_BASE_URL", "https://localhost:8443/ords/erp/v1")
    cert = ROOT / os.environ.get("ORDS_CA_CERT", "certs/ords-self-signed.crt")
    if not cert.exists():
        pytest.skip("Local ORDS CA certificate is unavailable")

    token_url = base.split("/v1", 1)[0] + "/oauth/token"

    def client(role: str):
        prefix = {"requester": "REQUESTER", "reviewer": "REVIEWER", "admin": "ADMIN", "system": "SYSTEM"}[role]
        client_id = os.environ.get(f"{prefix}_CLIENT_ID")
        client_secret = os.environ.get(f"{prefix}_CLIENT_SECRET")
        if not client_id or not client_secret or client_secret == "generated-at-install":
            from scripts.run_migrations import connect

            with connect("app") as connection, connection.cursor() as cursor:
                cursor.execute(
                    "select client_id, client_secret from user_ords_clients where name = :name",
                    name=f"local-{role}",
                )
                credentials = cursor.fetchone()
            if credentials is None:
                pytest.skip(f"{role} OAuth client credentials are not configured")
            client_id, client_secret = credentials
        session = local_https_session(base, cert)
        response = session.post(token_url, auth=(client_id, client_secret), data={"grant_type": "client_credentials"}, timeout=20)
        response.raise_for_status()
        session.headers.update({"Authorization": f"Bearer {response.json()['access_token']}", "Accept": "application/json"})
        return session, base

    return client
