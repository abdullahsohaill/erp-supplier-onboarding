from __future__ import annotations

import time

import pytest


@pytest.mark.oracle
@pytest.mark.performance
@pytest.mark.parametrize(
    "sql,limit_seconds",
    [
        ("select request_id,request_number,status from supplier_request order by last_updated_at desc fetch first 100 rows only", 2.0),
        ("select * from supplier_request where request_id=3", 1.0),
        ("select * from duplicate_match where request_id=3 and is_current=1 order by match_score desc", 2.0),
        ("select * from risk_assessment where request_id=3 and is_current=1", 1.0),
    ],
)
def test_local_query_smoke_latency(oracle_connection, sql: str, limit_seconds: float) -> None:
    started = time.perf_counter()
    with oracle_connection.cursor() as cursor:
        cursor.execute(sql)
        cursor.fetchall()
    assert time.perf_counter() - started < limit_seconds
