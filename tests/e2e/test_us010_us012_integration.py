from __future__ import annotations

import pytest


@pytest.mark.runtime
def test_us011_approved_request_is_created_in_mock_fusion(support_admin) -> None:
    response = support_admin.request("POST", "/requests/105/submit-to-fusion")
    assert response.status_code == 200, response.text
    assert response.json()["data"]["status"] == "SUCCESS"


@pytest.mark.runtime
def test_us010_support_can_retry_eligible_failure(support_admin) -> None:
    response = support_admin.request("POST", "/integration-logs/10002/retry")
    assert response.status_code == 200, response.text
    data = response.json()["data"]
    assert data["status"] == "SUCCESS"
    assert data["retryCount"] == len(data["retryHistory"])


@pytest.mark.runtime
def test_us012_support_triggers_reference_sync_and_system_upserts(
    system_oic, support_admin
) -> None:
    sync = support_admin.request("POST", "/admin-settings/supplier-reference-sync")
    assert sync.status_code == 202
    upsert = system_oic.request(
        "PUT",
        "/internal/supplier-references/FUS-E2E-9001",
        json={
            "supplierNumber": "SUP-E2E-9001",
            "supplierName": "E2E Reference Supplier",
            "countryCode": "PK",
            "taxRegistrationNumber": "PK-E2E-REF-9001",
            "emailDomain": "reference.example",
            "phoneNormalized": "+923009009001",
            "addressNormalized": "20 REFERENCE ROAD LAHORE PUNJAB PK",
            "bankAccountHash": "sha256:e2e-ref-9001",
        },
    )
    assert upsert.status_code == 200, upsert.text
