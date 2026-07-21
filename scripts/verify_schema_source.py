from __future__ import annotations

import re
from pathlib import Path

from runtime import ROOT, RuntimeFailure

EXPECTED_TABLES = 18
EXPECTED_COLUMNS = 189
EXPECTED_FOREIGN_KEYS = 17


def dbml_contract(path: Path) -> tuple[dict[str, list[str]], int]:
    text = path.read_text(encoding="utf-8")
    tables: dict[str, list[str]] = {}
    for table, body in re.findall(r"Table\s+([a-z0-9_]+)\s*\{(.*?)\n\}", text, re.DOTALL):
        columns = re.findall(
            r"^\s{2}([a-z0-9_]+)\s+(?:int|varchar|text|decimal|timestamp|boolean|json|date)(?:\s|$)",
            body,
            re.MULTILINE,
        )
        tables[table.upper()] = [column.upper() for column in columns]
    return tables, len(re.findall(r"^Ref:", text, re.MULTILINE))


def ddl_contract(directory: Path) -> tuple[dict[str, list[str]], int]:
    text = "\n".join(path.read_text(encoding="utf-8") for path in sorted(directory.glob("*.sql")))
    tables: dict[str, list[str]] = {}
    for table, body in re.findall(
        r"create table\s+([a-z0-9_]+)\s*\((.*?)\n\);", text, re.IGNORECASE | re.DOTALL
    ):
        columns = []
        for line in body.splitlines():
            candidate = line.strip().rstrip(",")
            if not candidate or candidate.lower().startswith("constraint "):
                continue
            match = re.match(
                r"([a-z0-9_]+)\s+(?:number|varchar2|clob|date|timestamp)\b",
                candidate,
                re.IGNORECASE,
            )
            if match:
                columns.append(match.group(1).upper())
        tables[table.upper()] = columns
    return tables, len(re.findall(r"\bforeign key\s*\(", text, re.IGNORECASE))


def main() -> int:
    dbml, dbml_fks = dbml_contract(ROOT / "aidlc-docs/inception/application-design/db-schema.dbml")
    ddl, ddl_fks = ddl_contract(ROOT / "database/migrations")
    dbml_columns = sum(map(len, dbml.values()))
    ddl_columns = sum(map(len, ddl.values()))
    expected = (EXPECTED_TABLES, EXPECTED_COLUMNS, EXPECTED_FOREIGN_KEYS)
    actuals = {
        "DBML": (len(dbml), dbml_columns, dbml_fks),
        "DDL": (len(ddl), ddl_columns, ddl_fks),
    }
    for source, actual in actuals.items():
        if actual != expected:
            raise RuntimeFailure(f"{source} parity is {actual}, expected {expected}")
    if dbml != ddl:
        mismatches = {
            table: {"dbml": dbml.get(table), "ddl": ddl.get(table)}
            for table in sorted(set(dbml) | set(ddl))
            if dbml.get(table) != ddl.get(table)
        }
        raise RuntimeFailure(f"DBML/DDL table-column mismatch: {mismatches}")
    print("Schema source parity passed: 18 tables, 189 columns, 17 foreign keys")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except RuntimeFailure as exc:
        print(f"Schema source verification failed: {exc}")
        raise SystemExit(1) from exc
