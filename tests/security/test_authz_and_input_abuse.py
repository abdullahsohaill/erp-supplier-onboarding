from __future__ import annotations

import pytest
import requests

from tests.e2e.helpers import complete_payload, create_request


@pytest.mark.runtime
def test_unauthenticated_request_is_denied(runtime_config) -> None:
    response = requests.get(
        runtime_config.base_url + "/requests",
        verify=runtime_config.ca_file,
        timeout=30,
    )
    assert response.status_code in {401, 403}


@pytest.mark.runtime
def test_cross_owner_request_is_not_disclosed(requester_a, requester_b) -> None:
    created = create_request(requester_a)
    response = requester_b.request("GET", f"/requests/{created['requestId']}")
    assert response.status_code in {200, 404}
    if response.status_code == 200:
        assert response.json()["success"] is False
        assert response.json()["error"]["code"] == "REQUEST_NOT_FOUND"


@pytest.mark.runtime
def test_raw_bank_and_mass_assignment_are_rejected(requester_a) -> None:
    raw_bank = complete_payload(bank={"accountNumber": "1234567890123456"})
    response = requester_a.request("POST", "/requests", json=raw_bank)
    assert response.status_code == 400
    mass_assignment = complete_payload(status="Approved")
    response = requester_a.request("POST", "/requests", json=mass_assignment)
    assert response.status_code == 400


@pytest.mark.runtime
def test_sql_injection_is_data_not_code(requester_a) -> None:
    payload = complete_payload(supplierName="Supplier ' OR 1=1 --")
    created = create_request(requester_a, payload)
    assert created["supplierName"] == "Supplier ' OR 1=1 --"
