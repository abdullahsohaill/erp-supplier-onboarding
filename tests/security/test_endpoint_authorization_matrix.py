from __future__ import annotations

import time

import pytest
import requests

from tests.support.endpoint_matrix import ROLE_FIXTURES, OperationCase, operation_cases

CASES = operation_cases()
WRONG_ROLE_CASES = [case for case in CASES if case.wrong_role is not None]
_LAST_MUTATION: dict[str, float] = {}


def _pace_mutation(case: OperationCase, identity: str) -> None:
    if not case.is_mutation:
        return
    elapsed = time.monotonic() - _LAST_MUTATION.get(identity, 0)
    if elapsed < 2.05:
        time.sleep(2.05 - elapsed)
    _LAST_MUTATION[identity] = time.monotonic()


def _request_kwargs(case: OperationCase) -> dict[str, object]:
    if case.body is None:
        return {}
    return {"json": case.body}


@pytest.mark.runtime
@pytest.mark.security
@pytest.mark.timeout(180)
def test_every_operation_denies_unauthenticated_access(runtime_config) -> None:
    failures: list[tuple[str, int, str]] = []
    for case in CASES:
        _pace_mutation(case, "unauthenticated")
        response = requests.request(
            case.method,
            runtime_config.base_url.rstrip("/") + case.path,
            verify=runtime_config.ca_file,
            timeout=30,
            **_request_kwargs(case),
        )
        if response.status_code not in {401, 403}:
            failures.append((case.operation_id, response.status_code, response.text))
    assert not failures


@pytest.mark.runtime
@pytest.mark.security
@pytest.mark.timeout(180)
def test_every_restricted_operation_denies_a_wrong_role(
    request: pytest.FixtureRequest,
) -> None:
    failures: list[tuple[str, str, int, str]] = []
    for case in WRONG_ROLE_CASES:
        assert case.wrong_role is not None
        fixture = ROLE_FIXTURES[case.wrong_role]
        client = request.getfixturevalue(fixture)
        _pace_mutation(case, fixture)
        response = client.request(case.method, case.path, **_request_kwargs(case))
        if response.status_code != 403:
            failures.append(
                (case.operation_id, case.wrong_role, response.status_code, response.text)
            )
    assert not failures


@pytest.mark.runtime
@pytest.mark.security
@pytest.mark.timeout(180)
def test_every_operation_is_reachable_by_an_allowed_role(
    request: pytest.FixtureRequest,
) -> None:
    failures: list[tuple[str, int, list[int], str]] = []
    for case in CASES:
        fixture = ROLE_FIXTURES[case.primary_role]
        client = request.getfixturevalue(fixture)
        _pace_mutation(case, fixture)
        response = client.request(case.method, case.path, **_request_kwargs(case))
        if (
            response.status_code not in case.declared_statuses
            or response.status_code in {401, 403, 429}
        ):
            failures.append(
                (
                    case.operation_id,
                    response.status_code,
                    sorted(case.declared_statuses),
                    response.text,
                )
            )
    assert not failures
