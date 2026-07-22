from __future__ import annotations

import subprocess
import sys

import pytest

from tests.support.config import ROOT
from tests.support.db import query_scalar


def test_source_schema_parity() -> None:
    result = subprocess.run(
        [sys.executable, "scripts/verify_schema_source.py"],
        cwd=ROOT,
        check=False,
        capture_output=True,
        text=True,
    )
    assert result.returncode == 0, result.stderr or result.stdout


@pytest.mark.runtime
def test_runtime_schema_is_exact() -> None:
    assert query_scalar("select count(*) from user_tables") == "18"
    assert query_scalar(
        "select count(*) from user_tab_columns "
        "where table_name in (select table_name from user_tables)"
    ) == "189"
    assert query_scalar("select count(*) from user_constraints where constraint_type = 'R'") == "17"


@pytest.mark.runtime
def test_no_invalid_objects() -> None:
    assert query_scalar("select count(*) from user_objects where status <> 'VALID'") == "0"
