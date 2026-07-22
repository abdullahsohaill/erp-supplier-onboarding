from __future__ import annotations

import argparse
from pathlib import Path

from query_guard import validate_read_only
from runtime import ROOT, RuntimeFailure, load_env, sqlplus

QUERY_DIR = ROOT / "database/qa"
CATALOG = {
    "01_schema_inventory.sql": "Tables, columns, keys, indexes, and views",
    "02_requests_and_status.sql": "Request status, owners, and history",
    "03_validation_duplicate_risk_ai.sql": "Analysis evidence without sensitive values",
    "04_integration_and_retry.sql": "Integration attempts and retry state",
    "05_admin_settings.sql": "Validation, scoring, country, BU, and supplier-type settings",
    "06_security_and_privileges.sql": "ERP_VERIFY read-only grants",
}
def catalog() -> None:
    for name, description in CATALOG.items():
        print(f"{name}: {description}")


def selected_source(args: argparse.Namespace) -> str:
    if args.sql:
        return args.sql
    requested = Path(args.file).name
    if requested != args.file or requested not in CATALOG:
        raise RuntimeFailure("--file must name one query from --catalog")
    return (QUERY_DIR / requested).read_text(encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(description="Read-only ERP schema inspection as ERP_VERIFY")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--catalog", action="store_true", help="list curated inspection queries")
    group.add_argument("--file", help="run one curated catalog filename")
    group.add_argument("--sql", help="run one or more read-only SELECT/WITH/DESCRIBE statements")
    args = parser.parse_args()
    if args.catalog:
        catalog()
        return 0
    env = load_env()
    password = env.get("ERP_VERIFY_PASSWORD")
    if not password:
        raise RuntimeFailure("ERP_VERIFY password is missing; start and migrate the local stack")
    try:
        source = validate_read_only(selected_source(args))
    except ValueError as exc:
        raise RuntimeFailure(str(exc)) from exc
    output = sqlplus("ERP_VERIFY", password, source)
    print(output.strip())
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, OSError) as exc:
        print(f"Query failed: {exc}")
        raise SystemExit(1) from exc
