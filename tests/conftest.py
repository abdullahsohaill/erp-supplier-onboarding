from __future__ import annotations

import pytest

from tests.support.api import ApiClient
from tests.support.config import load_runtime_config, runtime_enabled
from tests.support.db import execute


def pytest_collection_modifyitems(config: pytest.Config, items: list[pytest.Item]) -> None:
    if runtime_enabled():
        return
    marker = pytest.mark.skip(reason="Set ERP_RUNTIME_TESTS=1 after starting the local stack")
    for item in items:
        if "runtime" in item.keywords:
            item.add_marker(marker)


@pytest.fixture(scope="session", autouse=True)
def restore_mutable_demo_scenarios():
    if not runtime_enabled():
        yield
        return
    execute(
        """
        delete from integration_log where request_id = 105;
        delete from status_history where request_id = 105 and history_id <> 5006;
        update supplier_request
           set status = 'Approved', fusion_supplier_id = null,
               fusion_supplier_number = null, fusion_created_at = null,
               fusion_response_ref = null, last_updated_at = systimestamp
         where request_id = 105;

        delete from status_history where request_id = 107 and history_id <> 5008;
        update supplier_request
           set status = 'Integration Failed', fusion_supplier_id = null,
               fusion_supplier_number = null, fusion_created_at = null,
               fusion_response_ref = null, last_updated_at = systimestamp
         where request_id = 107;
        update integration_log
           set oic_instance_id = 'OIC-MOCK-107-2', status = 'FAILED',
               error_category = 'TEMPORARY_TIMEOUT',
               response_ref = 'mock://responses/REQ-2026-0161/attempt-2',
               user_message = 'Supplier creation is delayed. Support can retry.',
               technical_message = 'Deterministic mock timeout on attempt 2.',
               retry_count = 1, retry_eligible_flag = 1,
               last_retry_at = systimestamp - interval '1' hour,
               last_retry_by = 'support_admin_test',
               retry_history_json = '[{"attempt":1,"actor":"support_admin_test",'
                   || '"timestamp":"2026-07-21T15:00:00Z","result":"FAILED",'
                   || '"message":"Temporary timeout",'
                   || '"oicInstanceId":"OIC-MOCK-107-2"}]'
         where log_id = 10002;

        delete from duplicate_match
         where candidate_supplier_ref_id in (
             select supplier_ref_id from existing_supplier_ref
              where fusion_supplier_id = 'FUS-E2E-9001'
         );
        delete from existing_supplier_site_ref
         where supplier_ref_id in (
             select supplier_ref_id from existing_supplier_ref
              where fusion_supplier_id = 'FUS-E2E-9001'
         );
        delete from existing_supplier_ref where fusion_supplier_id = 'FUS-E2E-9001';
        commit;
        """,
        "support_admin_test",
    )
    yield


@pytest.fixture(scope="session")
def runtime_config():
    return load_runtime_config()


@pytest.fixture(scope="session")
def requester_a(runtime_config):
    return ApiClient(runtime_config, "requester_a")


@pytest.fixture(scope="session")
def requester_b(runtime_config):
    return ApiClient(runtime_config, "requester_b")


@pytest.fixture(scope="session")
def reviewer(runtime_config):
    return ApiClient(runtime_config, "reviewer_test")


@pytest.fixture(scope="session")
def support_admin(runtime_config):
    return ApiClient(runtime_config, "support_admin_test")


@pytest.fixture(scope="session")
def system_oic(runtime_config):
    return ApiClient(runtime_config, "system_oic_test")
