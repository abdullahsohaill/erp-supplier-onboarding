from __future__ import annotations

import json
import subprocess

import yaml
from openapi_spec_validator import validate_spec
from runtime import REPORTS, ROOT, RuntimeFailure, command, load_env, sqlplus, write_json
from verify_schema_source import main as verify_schema_source


def main() -> int:
    verify_schema_source()
    command([str(ROOT / ".venv/bin/ruff"), "check", "scripts", "tests"])
    command([str(ROOT / ".venv/bin/python"), "-m", "compileall", "-q", "scripts", "tests"])

    openapi_files = sorted((ROOT / "ords/openapi").glob("*.yaml"))
    for path in openapi_files:
        validate_spec(yaml.safe_load(path.read_text(encoding="utf-8")))

    runtime_checks: dict[str, object] = {"executed": False}
    running = command(["docker", "inspect", "erp-oracle-adb"], check=False).returncode == 0
    if running:
        env = load_env()
        inventory = sqlplus(
            "ERP_APP",
            env["ERP_APP_PASSWORD"],
            "select count(*) tables_count from user_tables;\n"
            "select count(*) columns_count from user_tab_columns "
            "where table_name in (select table_name from user_tables);\n"
            "select count(*) foreign_keys from user_constraints where constraint_type = 'R';\n"
            "select count(*) invalid_objects from user_objects where status <> 'VALID';",
        )
        runtime_checks = {"executed": True, "inventory": inventory.splitlines()}
    result = {
        "schema_source": "18/189/17 PASS",
        "openapi_documents": [str(path.relative_to(ROOT)) for path in openapi_files],
        "runtime": runtime_checks,
    }
    write_json(REPORTS / "verification.json", result)
    print("Static and available runtime verification passed")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (
        RuntimeFailure,
        KeyError,
        ValueError,
        json.JSONDecodeError,
        subprocess.SubprocessError,
    ) as exc:
        print(f"Verification failed: {exc}")
        raise SystemExit(1) from exc
