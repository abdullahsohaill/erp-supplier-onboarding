from __future__ import annotations

import re

import yaml

from tests.support.contracts import ROOT, normalize_path
from tests.support.endpoint_matrix import (
    AUTHENTICATED_ROLES,
    OPENAPI,
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


def test_operation_identity_roles_and_paths_are_complete() -> None:
    operation_ids = [case.operation_id for case in CASES]
    assert len(operation_ids) == len(set(operation_ids)) == 42
    for case in CASES:
        assert re.fullmatch(r"[a-z][A-Za-z0-9]+", case.operation_id), case.operation_id
        assert case.allowed_roles, case.operation_id
        assert set(case.allowed_roles) <= set(AUTHENTICATED_ROLES), case.operation_id
        assert "{" not in case.path and "}" not in case.path, case.operation_id
        assert case.path.startswith("/"), case.operation_id


def test_every_operation_declares_auth_success_and_throttle_responses() -> None:
    for case in CASES:
        assert {401, 403, 429} <= case.declared_statuses, case.operation_id
        assert any(code < 400 for code in case.declared_statuses), case.operation_id


def test_required_request_bodies_have_safe_examples() -> None:
    for case in CASES:
        if case.request_body_required:
            assert isinstance(case.body, dict), case.operation_id
        if case.body is not None:
            serialized = str(case.body).lower()
            assert "accountnumber" not in serialized, case.operation_id
            assert "password" not in serialized, case.operation_id
            assert "client_secret" not in serialized, case.operation_id


def test_ords_transport_guards_match_every_openapi_role_declaration() -> None:
    for case in CASES:
        expected = tuple(OPENAPI_TO_LOCAL_ROLE[role] for role in case.allowed_roles)
        assert HANDLER_ROLES[(case.method, case.path_template)] == expected, case.operation_id


def test_openapi_operation_matrix_has_exact_method_path_role_mapping() -> None:
    spec = yaml.safe_load(OPENAPI.read_text(encoding="utf-8"))
    source_count = sum(
        method in {"get", "post", "put", "patch", "delete"}
        for item in spec["paths"].values()
        for method in item
    )
    assert source_count == len(CASES) == 42
