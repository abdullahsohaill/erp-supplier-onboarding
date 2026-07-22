from __future__ import annotations

import re

import pytest
import yaml

from tests.support.contracts import ROOT, normalize_path
from tests.support.endpoint_matrix import (
    AUTHENTICATED_ROLES,
    OPENAPI,
    OperationCase,
    operation_cases,
)

CASES = operation_cases()
HANDLER_SOURCE = "\n".join(
    path.read_text(encoding="utf-8") for path in sorted((ROOT / "ords/modules").glob("*.sql"))
)
HANDLER_ROLES = {
    (method.upper(), normalize_path(path)): tuple(roles.split(","))
    for path, method, roles in re.findall(
        r"ords\.define_handler\('supplier\.onboarding\.v1',\s*'([^']+)',\s*"
        r"'(GET|POST|PUT|PATCH|DELETE)'.*?\n\s*q'~.*?authorize\('([^']+)'\)",
        HANDLER_SOURCE,
        re.IGNORECASE,
    )
}
OPENAPI_TO_LOCAL_ROLE = {
    "Requester": "REQUESTER",
    "Reviewer": "REVIEWER",
    "SupportAdmin": "SUPPORT_ADMIN",
    "SystemOIC": "SYSTEM_OIC",
}


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.operation_id)
def test_operation_id_is_stable_and_unique(case: OperationCase) -> None:
    assert re.fullmatch(r"[a-z][A-Za-z0-9]+", case.operation_id)
    assert sum(item.operation_id == case.operation_id for item in CASES) == 1


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.operation_id)
def test_operation_roles_are_explicit_and_known(case: OperationCase) -> None:
    assert case.allowed_roles
    assert set(case.allowed_roles) <= set(AUTHENTICATED_ROLES)


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.operation_id)
def test_operation_declares_auth_and_throttle_responses(case: OperationCase) -> None:
    assert {401, 403, 429} <= case.declared_statuses
    assert any(code < 400 for code in case.declared_statuses)


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.operation_id)
def test_operation_sample_resolves_every_path_parameter(case: OperationCase) -> None:
    assert "{" not in case.path
    assert "}" not in case.path
    assert case.path.startswith("/")


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.operation_id)
def test_required_request_body_has_safe_example(case: OperationCase) -> None:
    if case.request_body_required:
        assert isinstance(case.body, dict)
    if case.body is not None:
        serialized = str(case.body).lower()
        assert "accountnumber" not in serialized
        assert "password" not in serialized
        assert "client_secret" not in serialized


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.operation_id)
def test_ords_transport_guard_matches_openapi_roles(case: OperationCase) -> None:
    expected = tuple(OPENAPI_TO_LOCAL_ROLE[role] for role in case.allowed_roles)
    assert HANDLER_ROLES[(case.method, case.path_template)] == expected


def test_openapi_operation_matrix_has_exact_method_path_role_mapping() -> None:
    spec = yaml.safe_load(OPENAPI.read_text(encoding="utf-8"))
    source_count = sum(
        method in {"get", "post", "put", "patch", "delete"}
        for item in spec["paths"].values()
        for method in item
    )
    assert source_count == len(CASES) == 42
