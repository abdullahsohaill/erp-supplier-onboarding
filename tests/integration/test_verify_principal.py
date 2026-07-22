from __future__ import annotations

import pytest

from scripts.runtime import RuntimeFailure, load_env, sqlplus


@pytest.mark.runtime
def test_verify_principal_can_read_finalized_tables() -> None:
    env = load_env()
    output = sqlplus(
        "ERP_VERIFY",
        env["ERP_VERIFY_PASSWORD"],
        "select 'VERIFY_READ_COUNT=' || count(*) from ERP_APP.supplier_request;",
    )
    assert "VERIFY_READ_COUNT=" in output


@pytest.mark.runtime
def test_verify_principal_cannot_modify_application_data() -> None:
    env = load_env()
    with pytest.raises(RuntimeFailure):
        sqlplus(
            "ERP_VERIFY",
            env["ERP_VERIFY_PASSWORD"],
            "update ERP_APP.ref_business_unit set business_unit_name = business_unit_name;",
        )
