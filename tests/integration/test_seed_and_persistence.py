from __future__ import annotations

import pytest

from tests.support.db import query_scalar


@pytest.mark.runtime
def test_every_application_table_is_seeded() -> None:
    tables = [
        "AI_SUMMARY",
        "DUPLICATE_MATCH",
        "EXISTING_SUPPLIER_REF",
        "EXISTING_SUPPLIER_SITE_REF",
        "INTEGRATION_LOG",
        "REF_BUSINESS_UNIT",
        "REF_HIGH_RISK_COUNTRY",
        "REF_SCORING_RULE",
        "REF_SUPPLIER_TYPE",
        "RISK_ASSESSMENT",
        "STATUS_HISTORY",
        "SUPPLIER_REQUEST",
        "SUPPLIER_REQUEST_BANK",
        "SUPPLIER_REQUEST_CONTACT",
        "SUPPLIER_REQUEST_DOCUMENT",
        "SUPPLIER_REQUEST_SITE",
        "VALIDATION_RESULT",
        "VALIDATION_RULES",
    ]
    for table in tables:
        assert int(query_scalar(f"select count(*) from {table}")) > 0  # noqa: S608


@pytest.mark.runtime
def test_retry_count_matches_history_length() -> None:
    sql = (
        "select count(*) from integration_log l where nvl(l.retry_count,0) <> "
        "(select count(*) from json_table(l.retry_history_json, '$[*]' "
        "columns (attempt for ordinality)))"
    )
    assert query_scalar(sql) == "0"
