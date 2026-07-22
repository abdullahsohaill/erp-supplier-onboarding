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
def test_schema_inventory_columns_and_primary_keys_match_contract() -> None:
    column_mismatches: dict[str, tuple[str, str]] = {}
    primary_key_mismatches: dict[str, str] = {}
    for table in TABLE_NAMES:
        expected = hashlib.sha256(",".join(TABLES[table]).encode()).hexdigest().upper()
        column_sql = (
            "select standard_hash(listagg(column_name, ',') "  # noqa: S608
            "within group (order by column_id), 'SHA256') "
            f"from user_tab_columns where table_name = '{table}'"
        )
        actual = query_scalar(column_sql)
        if actual != expected:
            column_mismatches[table] = (expected, actual)

        primary_key_sql = (
            "select count(*) from user_constraints "  # noqa: S608
            f"where table_name = '{table}' and constraint_type = 'P' "
            "and status = 'ENABLED'"
        )
        primary_key_count = query_scalar(primary_key_sql)
        if primary_key_count != "1":
            primary_key_mismatches[table] = primary_key_count

    assert len(TABLE_NAMES) == 18
    assert sum(len(columns) for columns in TABLES.values()) == 189
    assert not column_mismatches
    assert not primary_key_mismatches


@pytest.mark.runtime
def test_declared_foreign_keys_and_indexes_exist() -> None:
    missing_foreign_keys: list[str] = []
    missing_indexes: list[str] = []
    for foreign_key in sorted(FOREIGN_KEYS):
        sql = (
            "select count(*) from user_constraints "  # noqa: S608
            f"where constraint_name = upper('{foreign_key}') "
            "and constraint_type = 'R' and status = 'ENABLED'"
        )
        if query_scalar(sql) != "1":
            missing_foreign_keys.append(foreign_key)

    for index_name in sorted(INDEXES):
        count = query_scalar(
            f"select count(*) from user_indexes "  # noqa: S608
            f"where index_name = upper('{index_name}')"
        )
        if count != "1":
            missing_indexes.append(index_name)

    assert len(FOREIGN_KEYS) == 17
    assert len(INDEXES) == 48
    assert not missing_foreign_keys
    assert not missing_indexes


@pytest.mark.runtime
def test_json_documents_are_valid_and_every_table_has_demo_data() -> None:
    invalid_json_columns: dict[str, str] = {}
    empty_tables: list[str] = []
    for table, column in JSON_COLUMNS:
        invalid_count = query_scalar(
            f"select count(*) from {table} "  # noqa: S608
            f"where {column} is not null and {column} is not json"
        )
        if invalid_count != "0":
            invalid_json_columns[f"{table}.{column}"] = invalid_count

    for table in TABLE_NAMES:
        if int(query_scalar(f"select count(*) from {table}")) <= 0:  # noqa: S608
            empty_tables.append(table)

    assert not invalid_json_columns
    assert not empty_tables


@pytest.mark.runtime
def test_all_packages_and_views_are_valid() -> None:
    invalid_packages: dict[str, str] = {}
    invalid_views: dict[str, str] = {}
    for package_name in PACKAGE_NAMES:
        package_sql = (
            "select count(*) from user_objects "  # noqa: S608
            f"where object_name = '{package_name}' "
            "and object_type in ('PACKAGE','PACKAGE BODY') and status = 'VALID'"
        )
        package_count = query_scalar(package_sql)
        if package_count != "2":
            invalid_packages[package_name] = package_count

    for view_name in VIEW_NAMES:
        view_sql = (
            "select count(*) from user_objects "  # noqa: S608
            f"where object_name = '{view_name}' "
            "and object_type = 'VIEW' and status = 'VALID'"
        )
        view_count = query_scalar(view_sql)
        if view_count != "1":
            invalid_views[view_name] = view_count

    assert len(PACKAGE_NAMES) == 15
    assert len(VIEW_NAMES) == 4
    assert not invalid_packages
    assert not invalid_views


def test_matrix_inventory_matches_finalized_contract() -> None:
    assert len(TABLE_NAMES) == 18
    assert sum(len(columns) for columns in TABLES.values()) == 189
    assert len(FOREIGN_KEYS) == 17
    assert len(INDEXES) == 48
    assert len(PACKAGE_NAMES) == 15
    assert len(VIEW_NAMES) == 4
