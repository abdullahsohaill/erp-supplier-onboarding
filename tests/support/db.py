from __future__ import annotations

import re

from scripts.runtime import load_env, sqlplus


def query_scalar(sql: str, principal: str = "support_admin_test") -> str:
    env = load_env()
    output = sqlplus(
        "ERP_APP",
        env["ERP_APP_PASSWORD"],
        "set heading off feedback off pagesize 0 verify off\n"
        f"begin dbms_session.set_identifier('{principal}'); end;\n/\n"
        f"select 'ERP_RESULT=' || ({sql}) from dual;",
    )
    match = re.search(r"ERP_RESULT=(.*)", output)
    if not match:
        raise AssertionError(f"No scalar result in SQL output: {output[-1000:]}")
    return match.group(1).strip()


def execute(source: str, principal: str) -> str:
    env = load_env()
    return sqlplus(
        "ERP_APP",
        env["ERP_APP_PASSWORD"],
        f"begin dbms_session.set_identifier('{principal}'); end;\n/\n{source}",
    )
