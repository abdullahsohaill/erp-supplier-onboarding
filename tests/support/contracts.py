from __future__ import annotations

import re
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[2]
METHODS = {"get", "post", "put", "patch", "delete"}


def normalize_path(path: str) -> str:
    return re.sub(r":([A-Za-z][A-Za-z0-9]*)", r"{\1}", "/" + path.strip("/"))


def openapi_operations() -> set[tuple[str, str]]:
    spec = yaml.safe_load(
        (ROOT / "ords/openapi/supplier-onboarding-v1.yaml").read_text(encoding="utf-8")
    )
    return {
        (method.upper(), path.rstrip("/") or "/")
        for path, item in spec["paths"].items()
        for method in item
        if method in METHODS
    }


def ords_operations() -> set[tuple[str, str]]:
    source = "\n".join(
        path.read_text(encoding="utf-8") for path in sorted((ROOT / "ords/modules").glob("*.sql"))
    )
    return {
        (method.upper(), normalize_path(path))
        for path, method in re.findall(
            r"ords\.define_handler\('supplier\.onboarding\.v1',\s*'([^']+)',\s*'(GET|POST|PUT|PATCH|DELETE)'",
            source,
            re.IGNORECASE,
        )
    }
