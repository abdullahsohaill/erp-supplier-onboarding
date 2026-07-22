from __future__ import annotations

import yaml
from openapi_spec_validator import validate_spec

from tests.support.contracts import ROOT, openapi_operations, ords_operations


def test_openapi_is_valid_and_has_all_42_operations() -> None:
    spec = yaml.safe_load(
        (ROOT / "ords/openapi/supplier-onboarding-v1.yaml").read_text(encoding="utf-8")
    )
    validate_spec(spec)
    assert len(openapi_operations()) == 42


def test_ords_and_openapi_method_path_parity() -> None:
    assert ords_operations() == openapi_operations()


def test_no_requester_duplicate_preview_route() -> None:
    operations = openapi_operations()
    assert all("preview" not in path for _, path in operations)
    assert ("POST", "/requests/{requestId}/duplicate-check") in operations
