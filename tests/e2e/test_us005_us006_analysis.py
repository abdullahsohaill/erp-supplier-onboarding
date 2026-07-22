from __future__ import annotations

import pytest


@pytest.mark.runtime
def test_us005_reviewer_sees_duplicate_evidence(reviewer) -> None:
    response = reviewer.request("GET", "/requests/104/duplicate-matches")
    assert response.status_code == 200, response.text
    assert response.json()["data"][0]["matchLevel"] == "CRITICAL"


@pytest.mark.runtime
def test_us006_reviewer_can_recalculate_risk_and_ai(reviewer) -> None:
    risk = reviewer.request("POST", "/requests/103/risk-score")
    assert risk.status_code == 200, risk.text
    assert "riskAssessment" in risk.json()["data"]
    ai = reviewer.request("POST", "/requests/103/ai-summary")
    assert ai.status_code == 200, ai.text
    summaries = reviewer.request("GET", "/requests/103/ai-summaries")
    assert summaries.status_code == 200
    assert summaries.json()["data"][0]["summary"]["advisory"] is True
