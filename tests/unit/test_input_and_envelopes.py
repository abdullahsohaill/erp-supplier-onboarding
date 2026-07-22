from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_input_package_rejects_unknown_fields_raw_bank_and_oversize() -> None:
    source = (ROOT / "database/packages/common/erp_input_pkg.pkb").read_text(encoding="utf-8")
    assert "UNKNOWN_FIELD" in source
    assert "RAW_BANK_DATA_PROHIBITED" in source
    assert "BODY_TOO_LARGE" in source
    assert "1048576" in source


def test_envelope_has_trace_success_and_safe_error() -> None:
    source = (ROOT / "database/packages/common/erp_api_util_pkg.pkb").read_text(encoding="utf-8")
    for token in ("traceId", "success", "error", "INTERNAL_ERROR"):
        assert token in source
    assert "sqlerrm" not in source.lower()


def test_no_full_bank_account_column_or_request_key() -> None:
    dbml = (ROOT / "aidlc-docs/inception/application-design/db-schema.dbml").read_text(
        encoding="utf-8"
    )
    repo = (ROOT / "database/packages/uow001/erp_request_repo_pkg.pkb").read_text(encoding="utf-8")
    assert "account_number" not in dbml.lower()
    assert "accountNumber" not in repo
    assert "masked_account_display" in dbml
    assert "account_hash" in dbml
