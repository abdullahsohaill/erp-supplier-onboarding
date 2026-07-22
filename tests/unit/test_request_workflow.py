from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_submit_preserves_editable_status_on_blockers() -> None:
    source = (ROOT / "database/packages/uow001/erp_request_workflow_pkg.pkb").read_text(
        encoding="utf-8"
    )
    blocked = source.index("if l_blockers > 0 then")
    submitted = source.index("'Submitted', l_action")
    assert blocked < submitted
    assert "o_status := 422" in source
    assert "AUTO_ROUTE_TO_REVIEW" in source


def test_exact_tax_and_bank_are_validation_blockers() -> None:
    source = (ROOT / "database/packages/uow001/erp_gov_check_port_pkg.pkb").read_text(
        encoding="utf-8"
    )
    assert "DUP_EXACT_TAX" in source and "VAL-008" in source
    assert "DUP_SAME_BANK" in source and "VAL-009" in source
    assert "STAGED_REQUEST" in source


def test_high_risk_country_is_risk_only() -> None:
    source = (ROOT / "database/packages/uow001/erp_gov_check_port_pkg.pkb").read_text(
        encoding="utf-8"
    )
    assert "add_risk('HIGH_RISK_COUNTRY'" in source
    assert "add_validation(p_request_id, o_run_id, 'HIGH_RISK_COUNTRY'" not in source
