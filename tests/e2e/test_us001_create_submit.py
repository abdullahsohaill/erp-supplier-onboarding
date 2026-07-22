from __future__ import annotations

import pytest

from tests.e2e.helpers import create_request


@pytest.mark.runtime
def test_us001_create_complete_draft_and_submit(requester_a) -> None:
    request = create_request(requester_a)
    assert request["status"] == "Draft"
    response = requester_a.request("POST", f"/requests/{request['requestId']}/submit")
    assert response.status_code == 200, response.text
    assert response.json()["data"]["status"] == "Under Review"
