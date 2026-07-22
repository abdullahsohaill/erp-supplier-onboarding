from __future__ import annotations

import pytest

from tests.e2e.helpers import create_request


@pytest.mark.runtime
def test_us007_reviewer_approves_with_selected_factors(requester_a, reviewer) -> None:
    request = create_request(requester_a)
    request_id = request["requestId"]
    assert requester_a.request("POST", f"/requests/{request_id}/submit").status_code == 200
    response = reviewer.request(
        "POST",
        f"/requests/{request_id}/approve",
        json={"comment": "Approved.", "selectedRiskFactorCodes": [], "correctionItems": []},
    )
    assert response.status_code == 200, response.text
    assert response.json()["data"]["status"] == "Approved"


@pytest.mark.runtime
def test_us008_correction_requires_targeted_items(reviewer) -> None:
    response = reviewer.request(
        "POST",
        "/requests/103/request-correction",
        json={"comment": "Please clarify.", "correctionItems": []},
    )
    assert response.status_code == 409


@pytest.mark.runtime
def test_us009_role_dashboards_are_available(requester_a, reviewer) -> None:
    requester = requester_a.request("GET", "/dashboard/requester-summary")
    reviewer_summary = reviewer.request("GET", "/dashboard/reviewer-summary")
    assert requester.status_code == 200
    assert reviewer_summary.status_code == 200
    assert "underReview" in reviewer_summary.json()["data"]
