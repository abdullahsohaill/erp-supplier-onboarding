from __future__ import annotations

import json
import re
from pathlib import Path

from tests.support.endpoint_matrix import operation_cases

ROOT = Path(__file__).resolve().parents[2]
COLLECTION = ROOT / "postman/erp-supplier-onboarding.postman_collection.json"
TEMPLATE = ROOT / "postman/erp-local.postman_environment.template.json"


def _walk(items: list[dict[str, object]]):
    for item in items:
        yield item
        children = item.get("item")
        if isinstance(children, list):
            yield from _walk(children)


def test_collection_is_valid_postman_21_json() -> None:
    document = json.loads(COLLECTION.read_text(encoding="utf-8"))
    assert document["info"]["schema"].endswith("/v2.1.0/collection.json")
    assert isinstance(document["item"], list)


def test_collection_contains_every_canonical_operation_once() -> None:
    document = json.loads(COLLECTION.read_text(encoding="utf-8"))
    operation_ids = []
    for item in _walk(document["item"]):
        request = item.get("request")
        if not isinstance(request, dict):
            continue
        description = str(request.get("description", ""))
        match = re.search(r"Canonical operationId: ([A-Za-z0-9]+)\.", description)
        if match:
            operation_ids.append(match.group(1))
    expected = [case.operation_id for case in operation_cases()]
    assert sorted(operation_ids) == sorted(expected)
    assert len(operation_ids) == 42


def test_committed_postman_assets_are_secret_free() -> None:
    source = COLLECTION.read_text(encoding="utf-8") + TEMPLATE.read_text(encoding="utf-8")
    assert "GENERATE_LOCALLY" in source
    assert "client_secret\"" not in source.lower()
    assert not re.search(r'"access_token"\s*:\s*"[^\"]+"', source, re.IGNORECASE)


def test_environment_template_marks_secret_values() -> None:
    document = json.loads(TEMPLATE.read_text(encoding="utf-8"))
    secret_values = [item for item in document["values"] if item.get("type") == "secret"]
    assert len(secret_values) >= 8
    assert all(item["value"] in {"", "GENERATE_LOCALLY"} for item in secret_values)
