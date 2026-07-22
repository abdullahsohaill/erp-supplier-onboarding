from __future__ import annotations

import pytest


@pytest.mark.ords
def test_requester_can_read_own_seeded_request_without_risk_evidence(ords_client) -> None:
    session, base = ords_client("requester")
    response = session.get(f"{base}/requests/3", timeout=20)
    assert response.status_code == 200
    payload = response.json()
    serialized = str(payload).lower()
    assert "riskscore" not in serialized and "selectedriskfactorcodes" not in serialized and "technicalmessage" not in serialized


@pytest.mark.ords
def test_requester_is_denied_reviewer_risk_endpoint(ords_client) -> None:
    session, base = ords_client("requester")
    response = session.get(f"{base}/requests/3/risk-assessment", timeout=20)
    assert response.status_code == 403


@pytest.mark.ords
def test_reviewer_can_read_risk_and_duplicate_evidence(ords_client) -> None:
    session, base = ords_client("reviewer")
    assert session.get(f"{base}/requests/3/risk-assessment", timeout=20).status_code == 200
    assert session.get(f"{base}/requests/3/duplicate-matches", timeout=20).status_code == 200


@pytest.mark.ords
def test_admin_can_read_embedded_retry_history(ords_client) -> None:
    session, base = ords_client("admin")
    response = session.get(f"{base}/integration-logs/2", timeout=20)
    assert response.status_code == 200
    data = response.json()["data"]
    assert data["retryCount"] == len(data["retryHistory"])
