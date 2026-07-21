from __future__ import annotations

from runtime import ROOT, RuntimeFailure, load_env, require_local_profile, sqlplus

SEEDS = [
    "database/seed/001_reference_data.sql",
    "database/seed/002_supplier_reference_data.sql",
    "database/seed/003_request_scenarios.sql",
]


def main() -> int:
    require_local_profile()
    env = load_env()
    for relative in SEEDS:
        path = ROOT / relative
        sqlplus("ERP_APP", env["ERP_APP_PASSWORD"], path.read_text(encoding="utf-8"))
    check = ROOT / "database/scripts/seed_completeness.sql"
    print(sqlplus("ERP_APP", env["ERP_APP_PASSWORD"], check.read_text(encoding="utf-8")))
    print("Deterministic representative data seeded")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (RuntimeFailure, KeyError) as exc:
        print(f"Seed failed: {exc}")
        raise SystemExit(1) from exc
