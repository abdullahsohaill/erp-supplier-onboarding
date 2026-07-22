from __future__ import annotations

import re
import subprocess
from pathlib import Path

import pytest
import requests

from tests.e2e.helpers import complete_payload

ROOT = Path(__file__).resolve().parents[2]


def test_tracked_source_contains_no_generated_secret_material() -> None:
    source_paths = [
        path
        for path in ROOT.rglob("*")
        if path.suffix in {".yml", ".yaml", ".py", ".sql", ".md"}
        and ".venv" not in path.parts
        and ".local" not in path.parts
    ]
    source = "\n".join(path.read_text(encoding="utf-8") for path in source_paths if path.is_file())
    assert "__REQUESTER_A_SECRET__" in source
    secret_assignment = "ADMIN_" + r"PASSWORD=[^<\n]"
    assert not re.search(secret_assignment, source)
    assert ".local/" in (ROOT / ".gitignore").read_text(encoding="utf-8")


def test_nginx_logs_are_redacted_and_cors_is_explicit() -> None:
    nginx = (ROOT / "config/nginx/nginx.conf").read_text(encoding="utf-8")
    clients = (ROOT / "ords/security/register_local_clients.sql").read_text(encoding="utf-8")
    assert "$http_authorization" not in nginx.split("log_format safe_access", 1)[1].split(";", 1)[0]
    assert "http://127.0.0.1:5500" in clients
    assert "p_origins_allowed => '*'" not in clients


def test_database_actions_is_loopback_only_and_mongo_remains_disabled() -> None:
    hardening = (ROOT / "scripts/harden_ords.py").read_text(encoding="utf-8")
    compose = (ROOT / "docker-compose.yml").read_text(encoding="utf-8")
    nginx = (ROOT / "config/nginx/nginx.conf").read_text(encoding="utf-8")
    bootstrap = (ROOT / "database/bootstrap/000_create_principals.sql").read_text(
        encoding="utf-8"
    )
    assert '"database.api.enabled": "true"' in hardening
    assert '"feature.sdw": "true"' in hardening
    assert '"restEnabledSql.active": "true"' in hardening
    assert '"mongo.enabled": "false"' in hardening
    assert '"127.0.0.1:8444:8444"' in compose
    assert "listen 8444 ssl" in nginx
    assert "p_schema              => 'ERP_VERIFY'" in bootstrap
    assert "p_url_mapping_pattern => 'erp-inspector'" in bootstrap
    assert "p_auto_rest_auth      => true" in bootstrap


@pytest.mark.runtime
def test_ords_hardening_is_persisted() -> None:
    result = subprocess.run(  # noqa: S603 - executable and arguments are fixed repo paths.
        [str(ROOT / ".venv/bin/python"), "scripts/harden_ords.py"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
        timeout=60,
    )
    assert result.returncode == 0, result.stderr or result.stdout


@pytest.mark.runtime
def test_database_actions_login_is_available_only_on_local_tls(runtime_config) -> None:
    response = requests.get(
        "https://127.0.0.1:8444/ords/sql-developer",
        verify=runtime_config.ca_file,
        timeout=30,
    )
    assert response.status_code == 200
    assert "sql" in response.text.lower() or "sign" in response.text.lower()


@pytest.mark.runtime
def test_mutation_rate_limit_returns_429(requester_b) -> None:
    statuses = [
        requester_b.request("POST", "/requests", json=complete_payload()).status_code
        for _ in range(36)
    ]
    assert 429 in statuses
