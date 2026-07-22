from __future__ import annotations

import json
import re
from pathlib import Path

import yaml


def test_runtime_ports_are_loopback_only(project_root: Path) -> None:
    compose = yaml.safe_load((project_root / "docker-compose.yml").read_text(encoding="utf-8"))
    assert compose["services"]["adb"]["ports"] == [
        "127.0.0.1:1521:1521",
        "127.0.0.1:1522:1522",
        "127.0.0.1:8443:8443",
    ]
    assert "SYS_ADMIN" in compose["services"]["adb"]["cap_add"]
    assert compose["services"]["adb"]["devices"] == ["/dev/fuse:/dev/fuse"]


def test_secret_files_and_reports_are_ignored(project_root: Path) -> None:
    ignored = (project_root / ".gitignore").read_text(encoding="utf-8")
    for required in (".env", "wallet/", "certs/", "reports/*"):
        assert required in ignored


def test_no_hardcoded_real_secrets(project_root: Path) -> None:
    files = [path for path in project_root.rglob("*") if path.is_file() and ".git" not in path.parts and ".venv" not in path.parts]
    suspicious = re.compile(r"(?i)(password|client_secret)\s*[=:]\s*['\"](?!\$\{|\$\(|replace|generated|<|\*{3})[^'\"]{8,}['\"]")
    findings = []
    for path in files:
        if path.suffix.lower() in {".png", ".pdf", ".lock"}:
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except UnicodeDecodeError:
            continue
        if any("$(" not in match.group(0) for match in suspicious.finditer(text)):
            findings.append(str(path.relative_to(project_root)))
    assert not findings


def test_bank_schema_contains_only_masked_hash_and_last_four(project_root: Path) -> None:
    ddl = (project_root / "database/migrations/001_create_tables.sql").read_text(encoding="utf-8").lower()
    bank = ddl.split("create table supplier_request_bank", 1)[1].split("create table", 1)[0]
    assert "masked_account_display" in bank and "account_last4" in bank and "account_hash" in bank
    assert re.search(r"\baccount_number\b", bank) is None


def test_requester_projection_does_not_select_internal_evidence(project_root: Path) -> None:
    package = (project_root / "database/packages/050_erp_request_pkg.sql").read_text(encoding="utf-8").lower()
    function = package.split("function request_json", 2)[2].split("function requests_json", 1)[0]
    for forbidden in ("risk_score", "risk_level", "risk_reasons_json", "summary_json", "matched_fields_json", "technical_message"):
        assert forbidden not in function
    assert "selectedriskfactorcodes" not in function


def test_all_openapi_operations_require_oauth(project_root: Path) -> None:
    spec = yaml.safe_load((project_root / "ords/openapi/openapi.yaml").read_text(encoding="utf-8"))
    operations = [op for item in spec["paths"].values() for method, op in item.items() if method in {"get", "post", "put", "patch", "delete"}]
    assert all(op.get("security") for op in operations)
    assert set(spec["components"]["securitySchemes"]) == {"RequesterOAuth", "ReviewerOAuth", "AdminOAuth", "SystemOAuth"}


def test_rate_limit_policy_is_bounded(project_root: Path) -> None:
    policy = json.loads((project_root / "ords/security/rate-limit-policy.json").read_text(encoding="utf-8"))
    assert 0 < policy["default"]["requestsPerMinute"] <= 1000
    assert policy["response"]["status"] == 429


def test_http_clients_never_disable_certificate_verification(project_root: Path) -> None:
    code = "\n".join(path.read_text(encoding="utf-8") for path in (project_root / "scripts").glob("*.py"))
    assert "verify=False" not in code and "ssl_server_dn_match=False" not in code
