from decimal import Decimal

import pytest

from tests.support.reference_model import (
    append_retry,
    duplicate_score,
    money,
    normalize_name,
    normalize_token,
    requester_projection,
    risk_score,
    submit,
)


def test_normalization_examples() -> None:
    assert normalize_name(" Northstar Facilities, Ltd. ") == "NORTHSTAR FACILITIES"
    assert normalize_token("GB 111-222.333") == "GB111222333"


def test_duplicate_critical_trigger_caps_at_100() -> None:
    assert duplicate_score({"DUP_EXACT_TAX", "DUP_SAME_COUNTRY"}, {"DUP_SAME_COUNTRY": 10}) == (100, "Critical")


def test_risk_scoring_thresholds() -> None:
    weights = {"MISSING_TAX": 25, "HIGH_RISK_COUNTRY": 25, "BANK_COUNTRY_MISMATCH": 20}
    assert risk_score(set(), weights) == (0, "Low")
    assert risk_score({"MISSING_TAX", "HIGH_RISK_COUNTRY"}, weights) == (50, "Medium")
    assert risk_score(set(weights), weights) == (70, "High")


def test_submission_keeps_editable_status_when_blocked() -> None:
    assert submit("Draft", True).status == "Draft"
    assert submit("Correction Requested", True).status == "Correction Requested"


def test_submission_records_ordered_review_transition() -> None:
    result = submit("Draft", False)
    assert result.accepted
    assert result.status == "Under Review"
    assert result.history == ("Submitted", "Under Review")


def test_invalid_submission_state_rejected() -> None:
    with pytest.raises(ValueError):
        submit("Approved", False)


def test_requester_projection_removes_internal_evidence_recursively() -> None:
    source = {
        "requestId": 3,
        "riskScore": 80,
        "nested": {"technicalMessage": "timeout", "safe": "Try later"},
        "timeline": [{"selectedRiskFactorCodes": ["MISSING_TAX"], "comment": "Provide tax data"}],
    }
    assert requester_projection(source) == {
        "requestId": 3,
        "nested": {"safe": "Try later"},
        "timeline": [{"comment": "Provide tax data"}],
    }


def test_retry_count_equals_history_length() -> None:
    original = {"retryCount": 0, "retryHistory": []}
    updated = append_retry(original, {"result": "FAILED", "message": "Synthetic timeout"})
    assert original == {"retryCount": 0, "retryHistory": []}
    assert updated["retryCount"] == len(updated["retryHistory"]) == 1


def test_money_rejects_negative_value() -> None:
    assert money("10") == Decimal("10.00")
    with pytest.raises(ValueError):
        money("-0.01")
