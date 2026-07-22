from __future__ import annotations

import pytest

from scripts.query_guard import validate_read_only


def test_query_guard_accepts_read_only_statements() -> None:
    sources = [
        "select count(*) from ERP_APP.supplier_request",
        "with totals as (select count(*) total from ERP_APP.supplier_request) select * from totals",
        "describe ERP_APP.supplier_request",
        "select 1 from dual; select 2 from dual;",
    ]
    for source in sources:
        assert validate_read_only(source).endswith(";"), source


def test_query_guard_rejects_mutation_and_procedural_sql() -> None:
    sources = [
        "update ERP_APP.supplier_request set status = 'Draft'",
        "select * from dual; delete from ERP_APP.supplier_request",
        "begin null; end;",
        "execute immediate 'drop table x'",
        "",
    ]
    for source in sources:
        with pytest.raises(ValueError):
            validate_read_only(source)
