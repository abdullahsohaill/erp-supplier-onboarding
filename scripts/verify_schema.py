#!/usr/bin/env python3
from __future__ import annotations

import json
from datetime import UTC, datetime

from run_migrations import ROOT, connect, load_env

EXPECTED_TABLES = {
    "SUPPLIER_REQUEST", "SUPPLIER_REQUEST_SITE", "SUPPLIER_REQUEST_CONTACT",
    "SUPPLIER_REQUEST_BANK", "SUPPLIER_REQUEST_DOCUMENT", "STATUS_HISTORY",
    "VALIDATION_RESULT", "DUPLICATE_MATCH", "RISK_ASSESSMENT", "AI_SUMMARY",
    "EXISTING_SUPPLIER_REF", "EXISTING_SUPPLIER_SITE_REF", "INTEGRATION_LOG",
    "VALIDATION_RULES", "REF_BUSINESS_UNIT", "REF_SUPPLIER_TYPE",
    "REF_HIGH_RISK_COUNTRY", "REF_SCORING_RULE",
}


def main() -> int:
    load_env()
    with connect("app") as connection, connection.cursor() as cursor:
        cursor.execute("select table_name from user_tables order by table_name")
        tables = {row[0] for row in cursor.fetchall()}
        names = ",".join(f"'{name}'" for name in EXPECTED_TABLES)
        cursor.execute(f"select count(*) from user_tab_columns where table_name in ({names})")
        column_count = cursor.fetchone()[0]
        cursor.execute(f"select count(*) from user_constraints where constraint_type='R' and table_name in ({names})")
        foreign_key_count = cursor.fetchone()[0]
        cursor.execute("select object_name, object_type, status from user_objects where status <> 'VALID' order by object_type, object_name")
        invalid = [{"name": row[0], "type": row[1], "status": row[2]} for row in cursor.fetchall()]
        seed_counts = {}
        for table in sorted(EXPECTED_TABLES):
            cursor.execute(f"select count(*) from {table}")
            seed_counts[table] = cursor.fetchone()[0]

    result = {
        "generatedAt": datetime.now(UTC).isoformat(),
        "expectedTables": 18,
        "actualTables": len(tables & EXPECTED_TABLES),
        "extraTables": sorted(tables - EXPECTED_TABLES),
        "missingTables": sorted(EXPECTED_TABLES - tables),
        "expectedColumns": 189,
        "actualColumns": column_count,
        "expectedForeignKeys": 17,
        "actualForeignKeys": foreign_key_count,
        "invalidObjects": invalid,
        "seedCounts": seed_counts,
    }
    report = ROOT / "reports" / "schema-verification.json"
    report.write_text(json.dumps(result, indent=2) + "\n", encoding="utf-8")
    ok = not result["extraTables"] and not result["missingTables"] and column_count == 189 and foreign_key_count == 17 and not invalid and all(seed_counts.values())
    print(json.dumps(result, indent=2))
    return 0 if ok else 1


if __name__ == "__main__":
    raise SystemExit(main())
