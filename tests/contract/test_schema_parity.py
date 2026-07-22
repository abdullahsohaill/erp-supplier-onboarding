from __future__ import annotations

import re
from pathlib import Path


def parse_dbml(path: Path) -> tuple[dict[str, list[str]], int]:
    text = path.read_text(encoding="utf-8")
    tables: dict[str, list[str]] = {}
    for match in re.finditer(r"Table\s+(\w+)\s*\{(.*?)\n\}", text, re.S):
        columns = []
        in_indexes = False
        for raw in match.group(2).splitlines():
            line = raw.strip()
            if line.startswith("indexes {"):
                in_indexes = True
                continue
            if in_indexes:
                if line == "}":
                    in_indexes = False
                continue
            if not line or line.startswith("//") or line.startswith("Note:"):
                continue
            column = re.match(r"(\w+)\s+(?:int|varchar|text|decimal|timestamp|boolean|json|date)\b", line)
            if column:
                columns.append(column.group(1).lower())
        tables[match.group(1).lower()] = columns
    return tables, len(re.findall(r"^Ref:\s", text, re.M))


def parse_ddl(path: Path) -> dict[str, list[str]]:
    text = path.read_text(encoding="utf-8")
    tables: dict[str, list[str]] = {}
    for match in re.finditer(r"create table\s+(\w+)\s*\((.*?)\n\);", text, re.I | re.S):
        columns = []
        for raw in match.group(2).splitlines():
            line = raw.strip()
            if not line or line.lower().startswith("constraint"):
                continue
            column = re.match(r"(\w+)\s+(?:number|varchar2|clob|json|date|timestamp)\b", line, re.I)
            if column:
                columns.append(column.group(1).lower())
        tables[match.group(1).lower()] = columns
    return tables


def test_authoritative_schema_exactly_matches_executable_ddl(project_root: Path) -> None:
    dbml, dbml_fks = parse_dbml(project_root / "aidlc-docs/inception/application-design/db-schema.dbml")
    ddl = parse_ddl(project_root / "database/migrations/001_create_tables.sql")
    assert ddl == dbml
    assert len(ddl) == 18
    assert sum(map(len, ddl.values())) == 189
    constraints = (project_root / "database/migrations/002_constraints_and_indexes.sql").read_text(encoding="utf-8")
    assert len(re.findall(r"foreign key\s*\(", constraints, re.I)) == dbml_fks == 17


def test_removed_tables_are_not_reintroduced(project_root: Path) -> None:
    ddl = (project_root / "database/migrations/001_create_tables.sql").read_text(encoding="utf-8").upper()
    for removed in ("REF_RISK_RULE", "REF_DUPLICATE_RULE", "AI_SUMMARY_FEEDBACK", "INTEGRATION_RETRY_HISTORY"):
        assert f"CREATE TABLE {removed}" not in ddl
