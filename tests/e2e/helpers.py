from __future__ import annotations

import itertools
import time

_counter = itertools.count(100_000_000 + (time.time_ns() % 800_000_000))


def complete_payload(**overrides):
    suffix = next(_counter)
    payload = {
        "supplierName": f"E2E Supplier {suffix}",
        "supplierTypeCode": "CORPORATE",
        "countryCode": "PK",
        "businessUnitCode": "PK-OPS",
        "businessJustification": (
            "Approved sourcing need with clear scope, ownership, and annual demand."
        ),
        "productServiceCategory": "Professional Services",
        "expectedAnnualSpend": 225000,
        "taxRegistrationNumber": f"PK-E2E-{suffix}",
        "sites": [
            {
                "siteName": "Primary",
                "countryCode": "PK",
                "addressLine1": "10 Commerce Rd",
                "addressLine2": "Office 4",
                "city": "Lahore",
                "region": "Punjab",
                "postalCode": "54000",
                "intendedBusinessUnitId": 1,
                "isPrimary": True,
            }
        ],
        "contacts": [
            {
                "contactName": "E2E Contact",
                "contactEmail": f"contact{suffix}@e2e.example",
                "phoneNumber": f"+92300{suffix:07d}",
            }
        ],
        "bank": {
            "bankCountryCode": "PK",
            "maskedAccountDisplay": f"****{suffix % 10000:04d}",
            "accountLast4": f"{suffix % 10000:04d}",
            "accountHash": f"sha256:e2e-bank-{suffix}",
            "bankProvided": True,
        },
        "documents": [
            {
                "documentType": "REGISTRATION",
                "documentStatus": "CAPTURED",
                "isRequired": True,
                "metadata": {"fileName": f"registration-{suffix}.pdf", "size": 1200},
                "missing": False,
            }
        ],
    }
    payload.update(overrides)
    return payload


def create_request(client, payload=None):
    response = client.request("POST", "/requests", json=payload or complete_payload())
    assert response.status_code == 201, response.text
    return response.json()["data"]
