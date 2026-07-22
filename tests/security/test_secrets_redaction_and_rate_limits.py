from __future__ import annotations

import re
from pathlib import Path

import pytest

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


@pytest.mark.runtime
def test_mutation_rate_limit_returns_429(requester_b) -> None:
    statuses = [
        requester_b.request("POST", "/requests", json=complete_payload()).status_code
        for _ in range(36)
    ]
    assert 429 in statuses
