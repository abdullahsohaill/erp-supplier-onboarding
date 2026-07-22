# Migration Summary

## Final Result

The final verification used a newly created Oracle volume, not the previous populated database. ERPATP was recreated from the checksum-verified local ATP PDB cache, and the external migration runner applied all 47 ordered assets successfully. Runtime verification then confirmed exactly 18 tables, 189 columns, 17 foreign keys, four valid views, 15 valid package specifications, 15 valid package bodies, and zero invalid objects.

The bootstrap also creates the least-privilege `ERP_APP` and `ERP_VERIFY` users and REST-enables `ERP_VERIFY` under alias `erp-inspector`. Bootstrap is intentionally outside the 47 application-install assets because it must run as local ADMIN before the application schema exists.

## Ordered DDL Migrations

| Order | File | Purpose | Final result |
|---:|---|---|---|
| 1 | `001_create_reference_tables.sql` | Creates BU, supplier type, high-risk country, validation rule, and shared scoring-rule catalogs | PASS |
| 2 | `002_create_request_workflow_tables.sql` | Creates request, site, contact, bank metadata, document metadata, and status history | PASS |
| 3 | `003_create_analysis_tables.sql` | Creates validation result, duplicate match, risk assessment, and AI summary evidence | PASS |
| 4 | `004_create_integration_reference_tables.sql` | Creates integration log and existing supplier/site references | PASS |
| 5 | `005_add_constraints.sql` | Adds 17 FKs plus check/unique/business constraints | PASS |
| 6 | `006_add_indexes.sql` | Adds 48 declared indexes for owner, workflow, evidence, reference, and support access | PASS |
| 7 | `007_create_views.sql` | Creates four current-state/role-safe helper views | PASS |

These seven files are the physical schema migrations. They remain consistent with the authoritative `database-schema-design.md` and `db-schema.dbml` artifacts.

## Remaining Ordered Assets

| Order range | Asset group | Count | Purpose | Final result |
|---|---|---:|---|---|
| 8 | `grant_verify_read.sql` | 1 | Grants `ERP_VERIFY` SELECT on all 18 tables and four views, with no DML/DDL | PASS |
| 9 | `assert_schema.sql` | 1 | Fails unless the runtime has exact 18/189/17 parity | PASS |
| 10-24 | Package specifications | 15 | Defines common, intake, analysis, review, integration, and admin contracts | PASS |
| 25-39 | Package bodies | 15 | Implements the 42-operation business/service behavior | PASS |
| 40 | `assert_valid_objects.sql` | 1 | Fails on invalid packages/views | PASS |
| 41-45 | ORDS modules | 5 | Installs the 42 Requester/analysis/review/integration/admin handlers | PASS |
| 46 | `roles_privileges.sql` | 1 | Defines OAuth2 roles and exact ORDS privileges | PASS |
| 47 | `register_local_clients.sql` | 1 | Registers generated local OAuth clients without committing secrets | PASS |

## PL/SQL Packages

Each package has one specification and one body, for 30 assets total:

| Package | Responsibility |
|---|---|
| `ERP_API_UTIL_PKG` | Response envelopes, errors, authorization helpers |
| `ERP_PRINCIPAL_PKG` | OAuth principal and role context |
| `ERP_AUTH_PKG` | Role and ownership authorization |
| `ERP_INPUT_PKG` | JSON input allowlist, bounds, and sanitization |
| `ERP_HEALTH_PKG` | Runtime health response |
| `ERP_API_DISPATCH_PKG` | Routes ORDS handlers to unit packages |
| `ERP_REQUEST_REPO_PKG` | Request aggregate persistence |
| `ERP_REQUEST_PROJECTION_PKG` | Role-safe response projections |
| `ERP_GOV_CHECK_PORT_PKG` | Validation/duplicate/risk orchestration port |
| `ERP_REQUEST_WORKFLOW_PKG` | Draft, submit, correction, and lifecycle rules |
| `ERP_REQUEST_QUERY_PKG` | Lists, detail, timeline, dashboard queries |
| `ERP_ANALYSIS_PKG` | Validation, duplicate, risk, advisory AI |
| `ERP_REVIEW_PKG` | Reviewer decisions and selected evidence |
| `ERP_INTEGRATION_PKG` | Fusion/OIC mock, logs, retry, reference upsert |
| `ERP_ADMIN_PKG` | Admin Settings, reference maintenance, dashboards |

## Seed Execution

| Seed file | Purpose | Final result |
|---|---|---|
| `001_reference_data.sql` | Active/inactive validation, duplicate/risk, country, BU, and supplier-type settings | PASS |
| `002_supplier_reference_data.sql` | Existing supplier/site master data for duplicate checks | PASS |
| `003_request_scenarios.sql` | Seven lifecycle requests plus validation, duplicate, risk, AI, and integration evidence | PASS |

After seeding, `sync_identity_sequences.sql` advances identities beyond explicit demo IDs, and `seed_completeness.sql` verifies every table has data and retry count equals JSON history length. Final clean row counts are documented in `team-lead-construction-report.md`.

## Rerun and Recovery Behavior

- The manifest order is deterministic.
- Source SHA-256 checksums and results are stored only in ignored runtime evidence.
- No unsupported migration-history application table is added.
- Unchanged assets may be `SKIPPED_VERIFIED` only when the live schema has the exact fingerprint.
- The verifier grant and schema/object validators always rerun.
- A changed package specification forces package recompilation.
- Seed scripts are idempotent for their defined presentation rows.
- `stop.sh` preserves the named volume; guarded reset requires an explicit local ERPATP confirmation.

## Evidence Locations

- Manifest: `database/migrations/manifest.json`
- Sanitized runtime result: `.local/reports/migration-run.json`
- Authoritative schema: `aidlc-docs/inception/application-design/database-schema-design.md`
- Machine-readable schema: `aidlc-docs/inception/application-design/db-schema.dbml`
- Team-lead report: `aidlc-docs/construction/reports/team-lead-construction-report.md`
