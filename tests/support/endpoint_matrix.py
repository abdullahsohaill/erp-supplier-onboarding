from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Any

import yaml

ROOT = Path(__file__).resolve().parents[2]
OPENAPI = ROOT / "ords/openapi/supplier-onboarding-v1.yaml"
HTTP_METHODS = {"get", "post", "put", "patch", "delete"}

ROLE_FIXTURES = {
    "Requester": "requester_a",
    "Reviewer": "reviewer",
    "SupportAdmin": "support_admin",
    "SystemOIC": "system_oic",
}
ROLE_TOKEN_VARIABLES = {
    "Requester": "requesterToken",
    "Reviewer": "reviewerToken",
    "SupportAdmin": "supportToken",
    "SystemOIC": "systemToken",
}
AUTHENTICATED_ROLES = tuple(ROLE_FIXTURES)

DEFAULT_PATH_VALUES = {
    "requestId": "103",
    "logId": "10002",
    "countryCode": "AF",
    "effectiveFrom": "2026-01-01",
    "ruleCode": "VAL-009",
    "ruleType": "RISK",
    "version": "1.0",
    "businessUnitCode": "PK-OPS",
    "supplierTypeCode": "CORPORATE",
    "fusionSupplierId": "FUS-100884",
    "fusionSiteId": "SITE-100884-1",
}

PATH_OVERRIDES = {
    "updateRequest": {"requestId": "101"},
    "submitRequest": {"requestId": "999999999"},
    "getDuplicateMatches": {"requestId": "104"},
    "getAttachments": {"requestId": "101"},
    "maintainAttachmentMetadata": {"requestId": "999999999"},
    "approveRequest": {"requestId": "999999999"},
    "rejectRequest": {"requestId": "999999999"},
    "requestCorrection": {"requestId": "999999999"},
    "markDuplicate": {"requestId": "999999999"},
    "submitToFusion": {"requestId": "999999999"},
    "retryIntegration": {"logId": "999999999"},
    "recordIntegrationResult": {"requestId": "999999999"},
}

CREATE_REQUEST_BODY: dict[str, Any] = {
    "supplierName": "Matrix Verification Supplier",
    "supplierTypeCode": "CORPORATE",
    "countryCode": "PK",
    "businessUnitCode": "PK-OPS",
    "businessJustification": "Complete matrix verification business requirement.",
    "productServiceCategory": "Professional Services",
    "expectedAnnualSpend": 225000,
    "taxRegistrationNumber": "PK-MATRIX-VERIFY",
    "sites": [
        {
            "siteName": "Primary",
            "countryCode": "PK",
            "addressLine1": "10 Matrix Road",
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
            "contactName": "Matrix Contact",
            "contactEmail": "matrix@example.invalid",
            "phoneNumber": "+923001234567",
        }
    ],
    "bank": {
        "bankCountryCode": "PK",
        "maskedAccountDisplay": "****9001",
        "accountLast4": "9001",
        "accountHash": "sha256:matrix-verification-9001",
        "bankProvided": True,
    },
    "documents": [
        {
            "documentType": "REGISTRATION",
            "documentStatus": "CAPTURED",
            "isRequired": True,
            "metadata": {"fileName": "matrix-registration.pdf", "size": 1200},
            "missing": False,
        }
    ],
}

REQUEST_BODIES: dict[str, dict[str, Any]] = {
    "createRequest": CREATE_REQUEST_BODY,
    "updateRequest": {
        "businessJustification": "Updated matrix verification business requirement."
    },
    "maintainAttachmentMetadata": {
        "documentType": "REGISTRATION",
        "documentStatus": "CAPTURED",
        "isRequired": True,
        "metadata": {"fileName": "matrix.pdf", "size": 1200},
        "missing": False,
    },
    "approveRequest": {
        "comment": "Matrix authorization reachability.",
        "selectedRiskFactorCodes": [],
        "correctionItems": [],
    },
    "rejectRequest": {
        "comment": "Matrix authorization reachability.",
        "selectedRiskFactorCodes": [],
        "correctionItems": [],
    },
    "requestCorrection": {
        "comment": "Matrix authorization reachability.",
        "selectedRiskFactorCodes": [],
        "correctionItems": [
            {
                "fieldName": "businessJustification",
                "reasonCode": "WEAK_JUSTIFICATION",
                "message": "Provide more detail.",
            }
        ],
    },
    "markDuplicate": {
        "comment": "Matrix authorization reachability.",
        "selectedRiskFactorCodes": [],
        "correctionItems": [],
        "existingSupplierNumber": "SUP-100884",
    },
    "putHighRiskCountry": {
        "countryName": "Afghanistan",
        "riskLevel": "HIGH",
        "active": True,
    },
    "putValidationRule": {"active": True},
    "putScoringRule": {
        "active": True,
        "weight": 15,
        "severity": "MEDIUM",
        "criticalTrigger": False,
    },
    "putBusinessUnit": {
        "name": "Pakistan Operations",
        "fusionMappingCode": "PK_OPERATIONS",
        "active": True,
    },
    "putSupplierType": {
        "name": "Corporate Supplier",
        "taxRequired": True,
        "active": True,
    },
    "upsertSupplierReference": {
        "supplierNumber": "SUP-100884",
        "supplierName": "Al Noor Packaging",
        "countryCode": "PK",
        "taxRegistrationNumber": "PK-NTN-100884",
        "emailDomain": "alnoor.example",
        "phoneNormalized": "+9221000100884",
        "addressNormalized": "12 INDUSTRIAL AREA KARACHI SINDH PK",
        "bankAccountHash": "sha256:demo-bank-token-100884",
    },
    "upsertSupplierSiteReference": {
        "siteName": "Karachi Primary",
        "countryCode": "PK",
        "addressNormalized": "12 INDUSTRIAL AREA KARACHI SINDH PK",
        "businessUnitCode": "PK-OPS",
    },
    "recordIntegrationResult": {
        "oicInstanceId": "OIC-MATRIX-INVALID-REQUEST",
        "status": "FAILED",
        "errorCategory": "TEST_ONLY",
        "payloadRef": "mock://matrix/payload",
        "responseRef": "mock://matrix/response",
        "userMessage": "Matrix reachability result.",
        "technicalMessage": "Expected foreign-key rejection for unknown request.",
        "retryEligible": False,
    },
}


@dataclass(frozen=True)
class OperationCase:
    operation_id: str
    method: str
    path_template: str
    path: str
    allowed_roles: tuple[str, ...]
    primary_role: str
    wrong_role: str | None
    declared_statuses: frozenset[int]
    request_body_required: bool
    body: dict[str, Any] | None

    @property
    def is_mutation(self) -> bool:
        return self.method != "GET"


def _render_path(path: str, operation_id: str) -> str:
    values = DEFAULT_PATH_VALUES | PATH_OVERRIDES.get(operation_id, {})
    result = path
    for name, value in values.items():
        result = result.replace("{" + name + "}", value)
    return result


def operation_cases() -> list[OperationCase]:
    spec = yaml.safe_load(OPENAPI.read_text(encoding="utf-8"))
    cases: list[OperationCase] = []
    for path, path_item in spec["paths"].items():
        for method, operation in path_item.items():
            if method not in HTTP_METHODS:
                continue
            operation_id = operation["operationId"]
            declared_roles = tuple(operation.get("x-roles", ()))
            allowed_roles = (
                AUTHENTICATED_ROLES if declared_roles == ("Authenticated",) else declared_roles
            )
            primary_role = allowed_roles[0]
            wrong_role = next(
                (role for role in AUTHENTICATED_ROLES if role not in allowed_roles),
                None,
            )
            cases.append(
                OperationCase(
                    operation_id=operation_id,
                    method=method.upper(),
                    path_template=path,
                    path=_render_path(path, operation_id),
                    allowed_roles=tuple(allowed_roles),
                    primary_role=primary_role,
                    wrong_role=wrong_role,
                    declared_statuses=frozenset(int(code) for code in operation["responses"]),
                    request_body_required=bool(
                        operation.get("requestBody", {}).get("required", False)
                    ),
                    body=REQUEST_BODIES.get(operation_id),
                )
            )
    if len(cases) != 42:
        raise AssertionError(f"Expected 42 operations, found {len(cases)}")
    return cases
