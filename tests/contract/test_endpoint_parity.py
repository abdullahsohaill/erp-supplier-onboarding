from __future__ import annotations

import re
from pathlib import Path

import yaml


def technical_endpoints(path: Path) -> set[tuple[str, str]]:
    text = path.read_text(encoding="utf-8")
    section = text.split("### 8.4 Endpoint Catalog", 1)[1].split("#### Requester Response Projection", 1)[0]
    return {(m.group(1), m.group(2)) for m in re.finditer(r"\| (GET|POST|PUT|PATCH|DELETE) \| `([^`]+)` \|", section)}


def ords_endpoints(path: Path) -> set[tuple[str, str]]:
    return {(m.group(1), m.group(2)) for m in re.finditer(r"-- ENDPOINT (GET|POST|PUT|PATCH|DELETE) (\S+)", path.read_text(encoding="utf-8"))}


def openapi_endpoints(path: Path) -> set[tuple[str, str]]:
    spec = yaml.safe_load(path.read_text(encoding="utf-8"))
    methods = {"get", "post", "put", "patch", "delete"}
    return {(method.upper(), route) for route, item in spec["paths"].items() for method in item if method in methods}


def test_all_42_endpoint_contracts_match(project_root: Path) -> None:
    expected = technical_endpoints(project_root / "aidlc-docs/inception/application-design/technical-design.md")
    ords = ords_endpoints(project_root / "ords/modules/001_erp_v1_module.sql")
    openapi = openapi_endpoints(project_root / "ords/openapi/openapi.yaml")
    assert len(expected) == len(ords) == len(openapi) == 42
    assert ords == expected
    assert openapi == expected


def test_every_openapi_operation_has_unique_id_security_and_response(project_root: Path) -> None:
    spec = yaml.safe_load((project_root / "ords/openapi/openapi.yaml").read_text(encoding="utf-8"))
    operations = [op for item in spec["paths"].values() for method, op in item.items() if method in {"get", "post", "put", "patch", "delete"}]
    operation_ids = [op["operationId"] for op in operations]
    assert len(operation_ids) == len(set(operation_ids)) == 42
    assert all(op.get("security") for op in operations)
    assert all("responses" in op and any(code.startswith("2") for code in op["responses"]) for op in operations)
