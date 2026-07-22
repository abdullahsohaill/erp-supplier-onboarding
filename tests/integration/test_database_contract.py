from __future__ import annotations

import json

import pytest


@pytest.mark.oracle
def test_live_schema_and_seed_inventory(oracle_connection) -> None:
    cursor = oracle_connection.cursor()
    cursor.execute("select count(*) from user_tables")
    assert cursor.fetchone()[0] == 18
    cursor.execute("select count(*) from user_tab_columns")
    assert cursor.fetchone()[0] == 189
    cursor.execute("select count(*) from user_constraints where constraint_type='R'")
    assert cursor.fetchone()[0] == 17
    cursor.execute("select count(*) from user_objects where status <> 'VALID'")
    assert cursor.fetchone()[0] == 0


@pytest.mark.oracle
def test_every_live_table_is_seeded(oracle_connection) -> None:
    cursor = oracle_connection.cursor()
    cursor.execute("select table_name from user_tables")
    for (table,) in cursor.fetchall():
        cursor.execute(f"select count(*) from {table}")
        assert cursor.fetchone()[0] > 0, table


@pytest.mark.oracle
def test_retry_history_matches_summary_count(oracle_connection) -> None:
    cursor = oracle_connection.cursor()
    cursor.execute("select retry_count, json_serialize(retry_history_json returning clob) from integration_log")
    for retry_count, history in cursor.fetchall():
        assert retry_count == len(json.loads(history.read() if hasattr(history, "read") else history))


@pytest.mark.oracle
def test_validation_results_reference_exact_rules(oracle_connection) -> None:
    cursor = oracle_connection.cursor()
    cursor.execute("select count(*) from validation_result v left join validation_rules r on r.validation_rule_id=v.validation_rule_id where r.validation_rule_id is null")
    assert cursor.fetchone()[0] == 0
