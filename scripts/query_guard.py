from __future__ import annotations

import re

READ_ONLY_START = re.compile(r"^\s*(select|with|desc(?:ribe)?)\b", re.IGNORECASE)
FORBIDDEN = re.compile(
    r"\b(insert|update|delete|merge|create|alter|drop|truncate|grant|revoke|execute|begin|declare|call)\b",
    re.IGNORECASE,
)


def validate_read_only(source: str) -> str:
    cleaned = re.sub(r"--[^\n]*", "", source).strip()
    statements = [item.strip() for item in cleaned.split(";") if item.strip()]
    if not statements:
        raise ValueError("No SQL statement was supplied")
    for statement in statements:
        if not READ_ONLY_START.match(statement) or FORBIDDEN.search(statement):
            raise ValueError("Only read-only SELECT, WITH, and DESCRIBE statements are allowed")
    return cleaned + ("" if cleaned.endswith(";") else ";")
