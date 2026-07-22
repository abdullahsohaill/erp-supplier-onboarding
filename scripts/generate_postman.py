from __future__ import annotations

import copy
import json
import sys
from pathlib import Path
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
OUTPUT = ROOT / "postman/erp-supplier-onboarding.postman_collection.json"
sys.path.insert(0, str(ROOT))

CLIENTS = {
    "requester_a": ("requesterClientId", "requesterClientSecret", "requesterToken"),
    "requester_b": ("requesterBClientId", "requesterBClientSecret", "requesterBToken"),
    "reviewer_test": ("reviewerClientId", "reviewerClientSecret", "reviewerToken"),
    "support_admin_test": ("supportClientId", "supportClientSecret", "supportToken"),
    "system_oic_test": ("systemClientId", "systemClientSecret", "systemToken"),
}


def _operation_cases() -> list[Any]:
    from tests.support.endpoint_matrix import operation_cases

    return operation_cases()


def _test_event(statuses: list[int], extra: list[str] | None = None) -> list[dict[str, Any]]:
    script = [
        f"const allowed = {json.dumps(statuses)};",
        'pm.test("Declared response status", () => '
        "pm.expect(allowed).to.include(pm.response.code));",
        'pm.test("Response time under 10 seconds", () => '
        "pm.expect(pm.response.responseTime).to.be.below(10000));",
    ]
    script.extend(extra or [])
    return [{"listen": "test", "script": {"type": "text/javascript", "exec": script}}]


def _request_item(case: Any) -> dict[str, Any]:
    request: dict[str, Any] = {
        "method": case.method,
        "header": [{"key": "Accept", "value": "application/json"}],
        "auth": {
            "type": "bearer",
            "bearer": [
                {
                    "key": "token",
                    "value": "{{" + case.primary_role.lower().replace("admin", "") + "Token}}",
                    "type": "string",
                }
            ],
        },
        "url": "{{baseUrl}}" + case.path,
        "description": (
            f"Canonical operationId: {case.operation_id}. Allowed roles: "
            + ", ".join(case.allowed_roles)
            + "."
        ),
    }
    token_names = {
        "Requester": "requesterToken",
        "Reviewer": "reviewerToken",
        "SupportAdmin": "supportToken",
        "SystemOIC": "systemToken",
    }
    request["auth"]["bearer"][0]["value"] = "{{" + token_names[case.primary_role] + "}}"
    if case.body is not None:
        request["header"].append({"key": "Content-Type", "value": "application/json"})
        request["body"] = {
            "mode": "raw",
            "raw": json.dumps(case.body, indent=2),
            "options": {"raw": {"language": "json"}},
        }
    return {
        "name": f"{case.method} {case.operation_id}",
        "request": request,
        "event": _test_event(sorted(case.declared_statuses)),
    }


def _token_item(client_name: str, variables: tuple[str, str, str]) -> dict[str, Any]:
    client_id, client_secret, token = variables
    return {
        "name": f"Token - {client_name}",
        "request": {
            "method": "POST",
            "header": [{"key": "Content-Type", "value": "application/x-www-form-urlencoded"}],
            "auth": {
                "type": "basic",
                "basic": [
                    {"key": "username", "value": "{{" + client_id + "}}", "type": "string"},
                    {
                        "key": "password",
                        "value": "{{" + client_secret + "}}",
                        "type": "string",
                    },
                ],
            },
            "body": {
                "mode": "urlencoded",
                "urlencoded": [{"key": "grant_type", "value": "client_credentials"}],
            },
            "url": "{{tokenUrl}}",
        },
        "event": _test_event(
            [200],
            [
                "const body = pm.response.json();",
                'pm.test("Access token returned", () => '
                'pm.expect(body.access_token).to.be.a("string"));',
                f'pm.environment.set("{token}", body.access_token);',
            ],
        ),
    }


def _flow_item(
    name: str,
    method: str,
    path: str,
    token: str,
    statuses: list[int],
    body: dict[str, Any] | None = None,
    extra_tests: list[str] | None = None,
) -> dict[str, Any]:
    request: dict[str, Any] = {
        "method": method,
        "header": [{"key": "Accept", "value": "application/json"}],
        "auth": {
            "type": "bearer",
            "bearer": [{"key": "token", "value": "{{" + token + "}}", "type": "string"}],
        },
        "url": "{{baseUrl}}" + path,
        "description": "Guided flow step using the same verified API contract.",
    }
    if body is not None:
        request["header"].append({"key": "Content-Type", "value": "application/json"})
        request["body"] = {
            "mode": "raw",
            "raw": json.dumps(body, indent=2),
            "options": {"raw": {"language": "json"}},
        }
    return {"name": name, "request": request, "event": _test_event(statuses, extra_tests)}


def _guided_flows(cases: list[Any]) -> list[dict[str, Any]]:
    create_body = copy.deepcopy(
        next(case.body for case in cases if case.operation_id == "createRequest")
    )
    create_body["supplierName"] = "Postman Guided Flow {{$timestamp}}"
    create_body["taxRegistrationNumber"] = "PK-PM-{{$timestamp}}"
    return [
        {
            "name": "Requester Create and Submit",
            "item": [
                _flow_item(
                    "1. Create draft",
                    "POST",
                    "/requests",
                    "requesterToken",
                    [201],
                    create_body,
                    [
                        "const body = pm.response.json();",
                        'pm.environment.set("flowRequestId", body.data.requestId);',
                    ],
                ),
                _flow_item(
                    "2. Read draft",
                    "GET",
                    "/requests/{{flowRequestId}}",
                    "requesterToken",
                    [200],
                ),
                _flow_item(
                    "3. Submit draft with automatic checks",
                    "POST",
                    "/requests/{{flowRequestId}}/submit",
                    "requesterToken",
                    [200, 422],
                ),
                _flow_item(
                    "4. Read validation results",
                    "GET",
                    "/requests/{{flowRequestId}}/validation-results",
                    "requesterToken",
                    [200],
                ),
            ],
        },
        {
            "name": "Reviewer Analysis",
            "item": [
                _flow_item(
                    "1. Reviewer dashboard",
                    "GET",
                    "/dashboard/reviewer-summary",
                    "reviewerToken",
                    [200],
                ),
                _flow_item(
                    "2. Validation evidence",
                    "GET",
                    "/requests/{{reviewRequestId}}/validation-results",
                    "reviewerToken",
                    [200],
                ),
                _flow_item(
                    "3. Duplicate evidence",
                    "GET",
                    "/requests/{{duplicateRequestId}}/duplicate-matches",
                    "reviewerToken",
                    [200],
                ),
                _flow_item(
                    "4. Risk evidence",
                    "GET",
                    "/requests/{{reviewRequestId}}/risk-assessment",
                    "reviewerToken",
                    [200],
                ),
                _flow_item(
                    "5. AI summaries",
                    "GET",
                    "/requests/{{reviewRequestId}}/ai-summaries",
                    "reviewerToken",
                    [200],
                ),
            ],
        },
        {
            "name": "Support and Admin Inspection",
            "item": [
                _flow_item(
                    "1. Support dashboard",
                    "GET",
                    "/dashboard/support-summary",
                    "supportToken",
                    [200],
                ),
                _flow_item(
                    "2. Integration logs",
                    "GET",
                    "/integration-logs",
                    "supportToken",
                    [200],
                ),
                _flow_item(
                    "3. Validation rules",
                    "GET",
                    "/admin-settings/validation-rules",
                    "supportToken",
                    [200],
                ),
                _flow_item(
                    "4. Scoring rules",
                    "GET",
                    "/admin-settings/scoring-rules",
                    "supportToken",
                    [200],
                ),
            ],
        },
    ]


def main() -> int:
    cases = _operation_cases()
    role_order = ["Requester", "Reviewer", "SupportAdmin", "SystemOIC"]
    folders: list[dict[str, Any]] = [
        {
            "name": "00 Authentication",
            "item": [_token_item(name, variables) for name, variables in CLIENTS.items()],
        }
    ]
    for index, role in enumerate(role_order, start=1):
        folders.append(
            {
                "name": f"{index:02d} {role} Operations",
                "item": [_request_item(case) for case in cases if case.primary_role == role],
            }
        )
    folders.append({"name": "10 Guided Flows", "item": _guided_flows(cases)})
    collection = {
        "info": {
            "name": "ERP Supplier Onboarding - Complete Local QA",
            "description": (
                "Generated from the approved 42-operation OpenAPI contract. Run the token folder "
                "before role folders. Secrets belong only in the ignored local environment."
            ),
            "schema": "https://schema.getpostman.com/json/collection/v2.1.0/collection.json",
        },
        "item": folders,
    }
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(json.dumps(collection, indent=2) + "\n", encoding="utf-8")
    print(f"Generated {OUTPUT.relative_to(ROOT)} with {len(cases)} canonical operations")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
