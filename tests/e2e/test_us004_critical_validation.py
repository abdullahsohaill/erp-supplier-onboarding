from __future__ import annotations

import pytest

from tests.e2e.helpers import complete_payload, create_request


@pytest.mark.runtime
def test_us004_exact_tax_blocks_before_submission(requester_b) -> None:
    payload = complete_payload(taxRegistrationNumber="PK-NTN-100884")
    request = create_request(requester_b, payload)
    response = requester_b.request("POST", f"/requests/{request['requestId']}/submit")
    assert response.status_code == 422, response.text
    details = response.json()["error"]["details"]
    assert details["status"] == "Draft"
    assert any(item["ruleCode"] == "VAL-008" for item in details["validationResults"])


@pytest.mark.runtime
def test_us004_high_risk_country_warns_but_does_not_block(requester_b) -> None:
    request = create_request(requester_b, complete_payload(countryCode="AF"))
    response = requester_b.request("POST", f"/requests/{request['requestId']}/submit")
    assert response.status_code == 200, response.text
