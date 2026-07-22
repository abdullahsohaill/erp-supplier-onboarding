from __future__ import annotations

import pytest


@pytest.mark.runtime
def test_us013_admin_toggles_validation_and_scoring_rules(support_admin) -> None:
    off = support_admin.request(
        "PUT", "/admin-settings/validation-rules/VAL-009", json={"active": False}
    )
    assert off.status_code == 200, off.text
    on = support_admin.request(
        "PUT", "/admin-settings/validation-rules/VAL-009", json={"active": True}
    )
    assert on.status_code == 200
    scoring = support_admin.request(
        "PUT",
        "/admin-settings/scoring-rules/RISK/VAGUE_JUSTIFICATION/versions/1.0",
        json={"active": True, "weight": 15, "severity": "MEDIUM", "criticalTrigger": False},
    )
    assert scoring.status_code == 200, scoring.text


@pytest.mark.runtime
def test_us014_admin_maintains_tax_policy_and_country_warning(support_admin) -> None:
    supplier_type = support_admin.request(
        "PUT",
        "/admin-settings/supplier-types/CORPORATE",
        json={"name": "Corporate Supplier", "taxRequired": True, "active": True},
    )
    assert supplier_type.status_code == 200
    country = support_admin.request(
        "PUT",
        "/admin-settings/high-risk-countries/AF/periods/2026-01-01",
        json={"countryName": "Afghanistan", "riskLevel": "HIGH", "active": True},
    )
    assert country.status_code == 200, country.text
