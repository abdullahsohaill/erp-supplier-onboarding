from __future__ import annotations

import re
from pathlib import Path

from scripts.run_migrations import sql_units


def test_all_sql_files_split_into_complete_units(project_root: Path) -> None:
    sql_files = list((project_root / "database").rglob("*.sql")) + list((project_root / "ords").rglob("*.sql"))
    assert sql_files
    for path in sql_files:
        assert sql_units(path.read_text(encoding="utf-8")), path


def test_every_package_has_spec_and_body(project_root: Path) -> None:
    for path in (project_root / "database/packages").glob("*.sql"):
        text = path.read_text(encoding="utf-8").lower()
        names = re.findall(r"create or replace package(?: body)?\s+(\w+)", text)
        assert len(names) == 2 and names[0] == names[1], path


def test_no_string_concatenated_user_values_in_dynamic_sql(project_root: Path) -> None:
    packages = "\n".join(path.read_text(encoding="utf-8").lower() for path in (project_root / "database/packages").glob("*.sql"))
    assert "execute immediate" not in packages
