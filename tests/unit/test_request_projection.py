from __future__ import annotations

from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]


def test_requester_projection_hides_risk_and_duplicate_evidence() -> None:
    source = (ROOT / "database/packages/uow001/erp_request_projection_pkg.pkb").read_text(
        encoding="utf-8"
    )
    guard = source.index("if not p_requester_safe then")
    assert source.index("duplicateMatches") > guard
    assert source.index("riskAssessment") > guard


def test_dashboard_has_no_clickable_view_action_contract() -> None:
    view = (ROOT / "database/migrations/007_create_views.sql").read_text(encoding="utf-8")
    assert "else 'None'" in view
    assert "when 'Correction Requested' then 'Edit and Resubmit'" in view
