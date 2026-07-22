from __future__ import annotations

import hashlib
import re

import pytest

from tests.support.contracts import ROOT
from tests.support.db import query_scalar


def _dbml_tables() -> dict[str, list[str]]:
    source = (ROOT / "aidlc-docs/inception/application-design/db-schema.dbml").read_text(
        encoding="utf-8"
    )
    tables: dict[str, list[str]] = {}
    for table, body in re.findall(r"Table\s+([a-z0-9_]+)\s*\{(.*?)\n\}", source, re.DOTALL):
        columns = re.findall(
            r"^\s{2}([a-z0-9_]+)\s+"
            r"(?:int|varchar|text|decimal|timestamp|boolean|json|date)(?:\s|$)",
            body,
            re.MULTILINE,
        )
        tables[table.upper()] = [column.upper() for column in columns]
    return tables


TABLES = _dbml_tables()
TABLE_NAMES = sorted(TABLES)
FOREIGN_KEYS = re.findall(
    r"add constraint\s+(fk_[a-z0-9_]+)\s+foreign key",
    (ROOT / "database/migrations/005_add_constraints.sql").read_text(encoding="utf-8"),
    re.IGNORECASE,
)
INDEXES = re.findall(
    r"create\s+(?:unique\s+)?index\s+([a-z0-9_]+)",
    (ROOT / "database/migrations/006_add_indexes.sql").read_text(encoding="utf-8"),
    re.IGNORECASE,
)
PACKAGE_FILES = sorted((ROOT / "database/packages").rglob("*.pks"))
PACKAGE_NAMES = [path.stem.upper() for path in PACKAGE_FILES]
VIEW_NAMES = [
    "V_CURRENT_DUPLICATE_MATCH",
    "V_CURRENT_RISK_ASSESSMENT",
    "V_CURRENT_VALIDATION_RESULT",
    "V_REQUESTER_REQUEST_SUMMARY",
]
JSON_COLUMNS = [
    ("AI_SUMMARY", "SUMMARY_JSON"),
    ("DUPLICATE_MATCH", "MATCHED_FIELDS_JSON"),
    ("INTEGRATION_LOG", "RETRY_HISTORY_JSON"),
    ("RISK_ASSESSMENT", "RISK_REASONS_JSON"),
    ("SUPPLIER_REQUEST_DOCUMENT", "METADATA_JSON"),
]


@pytest.mark.runtime
@pytest.mark.parametrize("table", TABLE_NAMES)
def test_every_table_has_exact_source_columns(table: str) -> None:
    expected = hashlib.sha256(",".join(TABLES[table]).encode()).hexdigest().upper()
    sql = (
        "select standard_hash(listagg(column_name, ',') "  # noqa: S608
        "within group (order by column_id), 'SHA256') "
        f"from user_tab_columns where table_name = '{table}'"
    )
    actual = query_scalar(sql)
    assert actual == expected


@pytest.mark.runtime
@pytest.mark.parametrize("table", TABLE_NAMES)
def test_every_table_has_a_primary_key(table: str) -> None:
    sql = (
        "select count(*) from user_constraints "  # noqa: S608
        f"where table_name = '{table}' and constraint_type = 'P' "
        "and status = 'ENABLED'"
    )
    assert query_scalar(sql) == "1"


@pytest.mark.runtime
@pytest.mark.parametrize("foreign_key", sorted(FOREIGN_KEYS))
def test_every_foreign_key_is_enabled(foreign_key: str) -> None:
    sql = (
        "select count(*) from user_constraints "  # noqa: S608
        f"where constraint_name = upper('{foreign_key}') "
        "and constraint_type = 'R' and status = 'ENABLED'"
    )
    assert query_scalar(sql) == "1"


@pytest.mark.runtime
@pytest.mark.parametrize("index_name", sorted(INDEXES))
def test_every_declared_index_exists(index_name: str) -> None:
    assert (
        query_scalar(
            f"select count(*) from user_indexes "  # noqa: S608
            f"where index_name = upper('{index_name}')"
        )
        == "1"
    )


@pytest.mark.runtime
@pytest.mark.parametrize(("table", "column"), JSON_COLUMNS)
def test_every_json_column_contains_valid_json(table: str, column: str) -> None:
    assert (
        query_scalar(
            f"select count(*) from {table} "  # noqa: S608
            f"where {column} is not null and {column} is not json"
        )
        == "0"
    )


@pytest.mark.runtime
@pytest.mark.parametrize("table", TABLE_NAMES)
def test_every_finalized_table_contains_demo_data(table: str) -> None:
    assert int(query_scalar(f"select count(*) from {table}")) > 0  # noqa: S608


@pytest.mark.runtime
@pytest.mark.parametrize("package_name", PACKAGE_NAMES)
def test_every_package_spec_and_body_is_valid(package_name: str) -> None:
    sql = (
        "select count(*) from user_objects "  # noqa: S608
        f"where object_name = '{package_name}' "
        "and object_type in ('PACKAGE','PACKAGE BODY') and status = 'VALID'"
    )
    assert query_scalar(sql) == "2"


@pytest.mark.runtime
@pytest.mark.parametrize("view_name", VIEW_NAMES)
def test_every_declared_view_is_valid(view_name: str) -> None:
    sql = (
        "select count(*) from user_objects "  # noqa: S608
        f"where object_name = '{view_name}' "
        "and object_type = 'VIEW' and status = 'VALID'"
    )
    assert query_scalar(sql) == "1"


def test_matrix_inventory_matches_finalized_contract() -> None:
    assert len(TABLE_NAMES) == 18
    assert sum(len(columns) for columns in TABLES.values()) == 189
    assert len(FOREIGN_KEYS) == 17
    assert len(INDEXES) == 48
    assert len(PACKAGE_NAMES) == 15
    assert len(VIEW_NAMES) == 4
