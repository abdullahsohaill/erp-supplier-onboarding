from __future__ import annotations

import json

import pytest


def scalar(connection, sql: str, **binds):
    with connection.cursor() as cursor:
        cursor.execute(sql, binds)
        return cursor.fetchone()[0]


@pytest.mark.oracle
def test_us_001_create_and_submit_request_baseline(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from supplier_request where status='Draft'") >= 1
    assert scalar(oracle_connection, "select count(*) from supplier_request_site") >= 1
    assert scalar(oracle_connection, "select count(*) from supplier_request_contact") >= 1


@pytest.mark.oracle
def test_us_002_correct_returned_request(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from supplier_request where status='Correction Requested'") >= 1
    assert scalar(oracle_connection, "select count(*) from status_history where to_status='Correction Requested' and action_comment is json") >= 1


@pytest.mark.oracle
def test_us_003_track_request_status_and_outcome(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(distinct status) from supplier_request") >= 8
    assert scalar(oracle_connection, "select count(*) from supplier_request where status='Created in Fusion' and fusion_supplier_number is not null") >= 1


@pytest.mark.oracle
def test_us_004_validation_and_duplicate_evidence(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from validation_result where is_current=1 and is_blocking=1") >= 2
    assert scalar(oracle_connection, "select count(*) from duplicate_match where match_level='Critical'") >= 2


@pytest.mark.oracle
def test_us_005_risk_score_and_reasons(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from risk_assessment where is_current=1 and risk_score between 0 and 100") >= 1
    assert scalar(oracle_connection, "select count(*) from risk_assessment where json_exists(risk_reasons_json, '$[*].code')") >= 1


@pytest.mark.oracle
def test_us_006_ai_explanation_is_advisory(oracle_connection) -> None:
    with oracle_connection.cursor() as cursor:
        cursor.execute("select json_serialize(summary_json returning clob) from ai_summary")
        summary = cursor.fetchone()[0]
    summary = summary.read() if hasattr(summary, "read") else summary
    data = json.loads(summary)
    assert "decisionGuardrail" in data
    assert not ({"approve", "reject", "markDuplicate", "createSupplier"} & set(data))


@pytest.mark.oracle
def test_us_007_reviewer_decisions_are_audited(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from status_history where action_code in ('APPROVE','REJECT','REQUEST_CORRECTION','MARK_DUPLICATE') and action_comment is json") >= 4


@pytest.mark.oracle
def test_us_008_requester_guidance_exists(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from status_history where to_status in ('Correction Requested','Rejected','Marked Duplicate') and json_value(action_comment,'$.comment') is not null") >= 3


@pytest.mark.oracle
def test_us_009_business_dashboard_source_data(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from supplier_request where requester_user='local-requester'") >= 10
    assert scalar(oracle_connection, "select count(*) from supplier_request where status='Under Review'") >= 1


@pytest.mark.oracle
def test_us_010_integration_troubleshooting_and_retry(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from integration_log where status='FAILED' and retry_eligible_flag=1 and retry_count>0") >= 1


@pytest.mark.oracle
def test_us_011_submit_approved_supplier_to_mock_fusion(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from supplier_request where status='Created in Fusion' and fusion_supplier_id is not null and fusion_supplier_number is not null") >= 1


@pytest.mark.oracle
def test_us_012_load_supplier_reference_data(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from existing_supplier_ref where last_sync_at is not null") >= 3
    assert scalar(oracle_connection, "select count(*) from existing_supplier_site_ref") >= 3


@pytest.mark.oracle
def test_us_013_governed_admin_settings_and_sensitive_data(oracle_connection) -> None:
    assert scalar(oracle_connection, "select count(*) from validation_rules") == 9
    assert scalar(oracle_connection, "select count(*) from ref_scoring_rule where rule_type='RISK'") == 12
    assert scalar(oracle_connection, "select count(*) from supplier_request_bank where masked_account_display like '****%' and length(account_last4)=4") >= 1


@pytest.mark.oracle
def test_us_014_representative_demo_scenarios(oracle_connection) -> None:
    expected = {'Draft', 'Correction Requested', 'Under Review', 'Approved', 'Rejected', 'Marked Duplicate', 'Created in Fusion', 'Integration Failed'}
    with oracle_connection.cursor() as cursor:
        cursor.execute("select distinct status from supplier_request")
        actual = {row[0] for row in cursor.fetchall()}
    assert expected <= actual
