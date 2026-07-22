# Oracle ATP and ORDS Migration Summary

## Execution Model

`database/migrations/manifest.json` is the authoritative, machine-readable execution manifest. It records the exact SHA-256 checksum, sequence, connection scope, phase, and purpose for every executable installation file. `scripts/run_migrations.py` validates checksums before connecting and records each result outside the application schema in `reports/migration-execution.json`.

No migration-history table is created, preserving the fixed 18-table application contract.

## Migration Inventory

| Sequence | File | Connection | Objects or data created | Reset/rollback approach |
|---:|---|---|---|---|
| 1 | `database/migrations/000_bootstrap_schema.sql` | ADMIN | `ERP_APP`, least-privilege create grants, schema REST enablement | Drop `ERP_APP` only in a disposable local database |
| 2 | `database/migrations/001_create_tables.sql` | ERP_APP | All 18 tables and 189 columns | Clean-volume rebuild |
| 3 | `database/migrations/002_constraints_and_indexes.sql` | ERP_APP | 17 foreign keys, status/range/flag checks, unique keys, and operational indexes | Clean-volume rebuild |
| 10 | `database/packages/001_erp_api_pkg.sql` | ERP_APP | Safe JSON envelope and HTTP response helpers | `CREATE OR REPLACE` with prior version or clean rebuild |
| 11 | `database/packages/002_erp_security_pkg.sql` | ERP_APP | Principal, privilege, ownership, and editable-status guards | `CREATE OR REPLACE` or clean rebuild |
| 12 | `database/packages/010_erp_validation_pkg.sql` | ERP_APP | Governed validation execution and failed-result persistence | `CREATE OR REPLACE` or clean rebuild |
| 13 | `database/packages/020_erp_duplicate_pkg.sql` | ERP_APP | Normalization and duplicate matching/scoring | `CREATE OR REPLACE` or clean rebuild |
| 14 | `database/packages/030_erp_risk_pkg.sql` | ERP_APP | Configurable risk scoring and reason persistence | `CREATE OR REPLACE` or clean rebuild |
| 15 | `database/packages/040_erp_ai_pkg.sql` | ERP_APP | Deterministic advisory summary generation | `CREATE OR REPLACE` or clean rebuild |
| 16 | `database/packages/050_erp_request_pkg.sql` | ERP_APP | Request create, update, submit/resubmit, attachment, list, and role-safe detail services | `CREATE OR REPLACE` or clean rebuild |
| 17 | `database/packages/060_erp_review_pkg.sql` | ERP_APP | Approve, reject, correction, duplicate decisions and versioned decision envelopes | `CREATE OR REPLACE` or clean rebuild |
| 18 | `database/packages/070_erp_integration_pkg.sql` | ERP_APP | Mock Fusion submit/callback and atomic embedded retry history | `CREATE OR REPLACE` or clean rebuild |
| 19 | `database/packages/080_erp_dashboard_pkg.sql` | ERP_APP | Requester, Reviewer, and Support/Admin summary services | `CREATE OR REPLACE` or clean rebuild |
| 20 | `database/packages/090_erp_admin_pkg.sql` | ERP_APP | Governed settings and idempotent supplier-reference upserts | `CREATE OR REPLACE` or clean rebuild |
| 30 | `ords/security/001_roles_privileges.sql` | ERP_APP | Four ORDS roles and deny-by-default privilege patterns | Redefine privileges or clean rebuild |
| 31 | `ords/modules/001_erp_v1_module.sql` | ERP_APP | Published `erp.v1` module with all 42 handlers | Delete/redefine module or clean rebuild |
| 32 | `ords/security/002_oauth_clients.sql` | ERP_APP | Four local client-credentials clients with one role each | Revoke/delete local clients or clean rebuild |
| 40 | `database/seed/000_clear_seed.sql` | ERP_APP | Foreign-key-safe removal of prior synthetic rows | This is the seed reset itself |
| 41 | `database/seed/001_reference_data.sql` | ERP_APP | Validation/scoring catalogs, active/inactive settings, BUs, supplier types, country periods, and supplier references | Rerun sequences 40-42 |
| 42 | `database/seed/002_request_scenarios.sql` | ERP_APP | Request, site, contact, bank/document, history, validation, duplicate, risk, AI, integration, and retry examples | Rerun sequences 40-42 |

Exact checksums are intentionally not duplicated in prose; they are enforced directly from `database/migrations/manifest.json` and covered by `tests/contract/test_migration_manifest.py`.

## Schema Result

Live Oracle verification confirms:

| Contract | Expected | Live database |
|---|---:|---:|
| Tables | 18 | 18 |
| Columns | 189 | 189 |
| Foreign keys | 17 | 17 |
| ORDS operations | 42 | 42 |

All checksummed migration phases completed against Oracle Autonomous AI Database Free 26ai in ATP mode. Live verification found all 18 expected tables, 189 columns, 17 foreign keys, representative rows in every table, and no invalid Oracle objects. The runner also completed repeated package and ORDS installation successfully while runtime-only compatibility issues were corrected.
