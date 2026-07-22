from __future__ import annotations

import re
from pathlib import Path

from tests.contract.test_schema_parity import parse_ddl


def seed_text(project_root: Path) -> str:
    return "\n".join(path.read_text(encoding="utf-8") for path in sorted((project_root / "database/seed").glob("*.sql")))


def test_every_application_table_has_seed_rows(project_root: Path) -> None:
    tables = parse_ddl(project_root / "database/migrations/001_create_tables.sql")
    seed = seed_text(project_root).lower()
    missing = [table for table in tables if not re.search(rf"insert\s+into\s+{re.escape(table)}\b", seed)]
    assert not missing


def test_all_nine_validation_rules_are_seeded(project_root: Path) -> None:
    seed = seed_text(project_root)
    assert {f"VAL-{number:03d}" for number in range(1, 10)} <= set(re.findall(r"VAL-\d{3}", seed))


def test_all_risk_and_duplicate_rules_are_seeded(project_root: Path) -> None:
    seed = seed_text(project_root)
    risk = {
        "MISSING_TAX", "HIGH_RISK_COUNTRY", "BANK_COUNTRY_MISMATCH", "INCOMPLETE_ADDRESS",
        "INCOMPLETE_BANK_DETAILS", "VAGUE_JUSTIFICATION", "HIGH_SPEND_WEAK_JUSTIFICATION",
        "MISSING_DOCUMENT_METADATA", "DUPLICATE_SCORE_HIGH", "DUPLICATE_SCORE_MEDIUM",
        "RISK_HIGH_THRESHOLD", "RISK_MEDIUM_THRESHOLD",
    }
    duplicate = {
        "DUP_EXACT_TAX", "DUP_SAME_BANK", "DUP_NAME_SIMILARITY", "DUP_SAME_COUNTRY",
        "DUP_EMAIL_DOMAIN", "DUP_PHONE", "DUP_ADDRESS", "DUP_BU_SITE",
        "DUP_HIGH_THRESHOLD", "DUP_MEDIUM_THRESHOLD",
    }
    codes = set(re.findall(r"insert into ref_scoring_rule values \('([^']+)'", seed, re.I))
    assert risk <= codes
    assert duplicate <= codes


def test_required_demo_scenarios_are_present(project_root: Path) -> None:
    seed = seed_text(project_root)
    for status in ("Draft", "Correction Requested", "Under Review", "Approved", "Rejected", "Marked Duplicate", "Created in Fusion", "Integration Failed"):
        assert f"'{status}'" in seed
    assert "DUP_EXACT_TAX" in seed and "DUP_SAME_BANK" in seed
    assert "retryHistory" not in seed or "attemptNumber" in seed
