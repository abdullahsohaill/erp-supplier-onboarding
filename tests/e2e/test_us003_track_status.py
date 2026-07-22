from __future__ import annotations

import pytest

from tests.e2e.helpers import create_request


@pytest.mark.runtime
def test_us003_owner_can_track_list_detail_and_timeline(requester_a) -> None:
    created = create_request(requester_a)
    listing = requester_a.request("GET", "/requests")
    assert listing.status_code == 200
    ids = {item["requestId"] for item in listing.json()["data"]}
    assert created["requestId"] in ids
    detail = requester_a.request("GET", f"/requests/{created['requestId']}")
    assert detail.status_code == 200
    assert detail.json()["data"]["timeline"][0]["actionCode"] == "CREATE_DRAFT"
    assert "riskAssessment" not in detail.json()["data"]
