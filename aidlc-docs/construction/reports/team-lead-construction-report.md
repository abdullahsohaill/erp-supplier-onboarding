# ERP Supplier Onboarding - Local Construction Report

## Executive Summary

The AI-DLC construction phase has produced a complete local demonstration backend for ERP supplier onboarding. It runs Oracle Autonomous AI Database Free 26ai in ATP mode, bundled ORDS, and a TLS-protected Nginx edge on Apple Silicon Docker Desktop. The implementation covers supplier request intake, correction and resubmission, status tracking, automatic validation and duplicate detection, explainable risk scoring, advisory AI, Reviewer decisions, dashboards, deterministic Fusion/OIC behavior, retry, reference synchronization, and Admin Settings.

The final clean build installed all 47 ordered assets from an empty Oracle volume, compiled 15 PL/SQL packages, exposed 42 protected ORDS operations, and seeded every one of the finalized 18 application tables. Schema verification reports exactly 18 tables, 189 columns, 17 foreign keys, four views, 18 primary keys, 72 check constraints, six unique constraints, and zero invalid objects.

The complete executable suite passed 67 of 67 broad tests in 202.00 seconds. Those tests retain the detailed 42-operation and database-object matrices internally. A separate five-minute run previously completed 574 requests across ten workers with no errors and met every local p95 target.

## Completion Status

| Area | Result | Evidence |
|---|---|---|
| Oracle ADB Free ATP mode | PASS | Healthy `erp-oracle-adb` container, persistent named volume |
| ORDS and local TLS edge | PASS | Healthy `erp-local-edge`; API and Database Actions listeners |
| Wallet connectivity | PASS | Oracle SQLcl connected as `ERP_VERIFY` through `erpatp_tp` |
| Database schema | PASS | 18 tables, 189 columns, 17 FKs, four views, zero invalid objects |
| Migrations | PASS | 47 of 47 ordered assets passed on a fresh database |
| Seed data | PASS | Every table populated; retry-history invariant has zero violations |
| API contract | PASS | 42 OpenAPI operations match 42 ORDS handlers and roles |
| Authentication/authorization | PASS | Missing-token, wrong-role, allowed-role, and ownership matrices |
| User stories | PASS | All 14 approved stories have executable E2E coverage |
| Account-free API client | PASS | Bruno installed; generated workspace has all 42 operations and needs no sign-in or credential entry |
| Postman compatibility | PASS | Desktop installed; collection has every operation exactly once |
| Database inspection | PASS | Database Actions on TLS loopback and six curated read-only query pages |
| Test suite | PASS | 67 passed, zero failed/skipped/errors |
| Production release | NOT CLAIMED | Local prototype only; vendor-image and production NFR gates remain |

## Installed Local Environment

| Component | Installed selection | Local access |
|---|---|---|
| Database | `ghcr.io/oracle/adb-free:26.2.4.2-26ai`, ATP workload | mTLS `127.0.0.1:1522`, service `erpatp_tp` |
| ORDS | Bundled ORDS 25.4 | Private container listener behind local edge |
| Application API | Nginx 1.30.4 Alpine 3.24 with verified upstream TLS | `https://localhost:8443/ords/erp/supplier-onboarding/v1` |
| Database Actions | ORDS Database Actions with REST-enabled SQL | `https://localhost:8444/ords/sql-developer` |
| Database inspection user | `ERP_VERIFY`, REST alias `erp-inspector` | SELECT-only on 18 tables and four views |
| Oracle CLI | Oracle SQLcl 26.2 with Homebrew OpenJDK 26 | `./scripts/sqlcl.sh` |
| API client | Bruno Desktop 3.5.3 and CLI 3.5.2 | Account-free generated collection; authenticated eight-request smoke PASS |
| Compatibility client | Postman Desktop 12.20.2 | Generated collection and ignored local environment |
| Python verification | Python 3.13 virtual environment with hash-locked requirements | `./scripts/qa.sh all` |

Database Actions is on a separate loopback-only port and does not broaden the application API gateway. It is authenticated and intended solely for local inspection. The generated access card and all passwords remain under ignored `.local/` paths with owner-only permissions.

## Database Model and Presentation Data

| Table | Purpose | Clean rows |
|---|---|---:|
| `REF_BUSINESS_UNIT` | Governed business-unit mappings | 3 |
| `REF_SUPPLIER_TYPE` | Supplier types and conditional tax policy | 3 |
| `REF_HIGH_RISK_COUNTRY` | Effective-dated country warnings | 3 |
| `VALIDATION_RULES` | Global validation controls | 9 |
| `REF_SCORING_RULE` | Duplicate/risk rules, weights, severities, active flags | 22 |
| `SUPPLIER_REQUEST` | Supplier request aggregate and lifecycle | 7 |
| `SUPPLIER_REQUEST_SITE` | Structured address and intended BU | 7 |
| `SUPPLIER_REQUEST_CONTACT` | Supplier contacts | 7 |
| `SUPPLIER_REQUEST_BANK` | Masked/tokenized bank metadata | 7 |
| `SUPPLIER_REQUEST_DOCUMENT` | Document metadata and missing flags | 7 |
| `STATUS_HISTORY` | Auditable lifecycle actions and decision envelopes | 8 |
| `VALIDATION_RESULT` | Versioned field-level validation evidence | 3 |
| `DUPLICATE_MATCH` | Duplicate candidates and matched-fields JSON | 2 |
| `RISK_ASSESSMENT` | Explainable scores and risk-reasons JSON | 2 |
| `AI_SUMMARY` | Versioned deterministic advisory summaries | 2 |
| `INTEGRATION_LOG` | Fusion/OIC outcome and retry history | 2 |
| `EXISTING_SUPPLIER_REF` | Mock Fusion supplier-master reference | 2 |
| `EXISTING_SUPPLIER_SITE_REF` | Mock Fusion supplier-site reference | 2 |

The seven requests deliberately demonstrate `Draft`, `Correction Requested`, `Under Review`, `Marked Duplicate`, `Approved`, `Created in Fusion`, and `Integration Failed` states.

## API and Security Design

The five ORDS modules contain 42 versioned operations:

| Module | Operations | Responsibility |
|---|---:|---|
| UOW-001 Requester | 11 | Request intake, update, submit, detail, status, attachments |
| UOW-002 Analysis | 7 | Validation, duplicate, risk, and advisory AI evidence |
| UOW-003 Review | 5 | Approve, reject, correction, duplicate decision, Reviewer behavior |
| UOW-004 Integration | 9 | Fusion/OIC mock, logs, retry, supplier reference upsert |
| UOW-005 Governance | 10 | Dashboards, Admin Settings, reference synchronization |

OAuth2 clients represent two Requesters, one Reviewer, Support/Admin, and System/OIC. Every ORDS handler performs an exact server-side role guard before business logic. Request ownership is checked separately, Requester projections hide internal risk/AI evidence, bank data is masked/tokenized, and generated credentials are absent from Git.

## Use-Case Test Evidence

| Story | Tested outcome | Executable evidence |
|---|---|---|
| US-001 | Create complete Draft and submit through automatic checks | `test_us001_create_complete_draft_and_submit` |
| US-002 | Targeted correction, edit, and resubmit | `test_us002_targeted_correction_edit_and_resubmit` |
| US-003 | Owner list/detail/timeline status tracking | `test_us003_owner_can_track_list_detail_and_timeline` |
| US-004 | Exact tax blocks submission; high-risk country warns only | Two `test_us004_*` cases |
| US-005 | Reviewer receives duplicate candidates and matched evidence | `test_us005_reviewer_sees_duplicate_evidence` |
| US-006 | Reviewer recalculates risk and deterministic AI summary | `test_us006_reviewer_can_recalculate_risk_and_ai` |
| US-007 | Reviewer approval records selected factors | `test_us007_reviewer_approves_with_selected_factors` |
| US-008 | Correction requires targeted field/evidence guidance | `test_us008_correction_requires_targeted_items` |
| US-009 | Role-specific Requester and Reviewer dashboards | `test_us009_role_dashboards_are_available` |
| US-010 | Support/Admin retries an eligible integration failure | `test_us010_support_can_retry_eligible_failure` |
| US-011 | Approved request creates a supplier through Fusion mock | `test_us011_approved_request_is_created_in_mock_fusion` |
| US-012 | Reference sync and protected System/OIC upserts | `test_us012_support_triggers_reference_sync_and_system_upserts` |
| US-013 | Admin toggles validation and scoring rules | `test_us013_admin_toggles_validation_and_scoring_rules` |
| US-014 | Tax policy and high-risk country demo configuration | `test_us014_admin_maintains_tax_policy_and_country_warning` |

## Test Distribution

| Suite | Tests | Main coverage |
|---|---:|---|
| Unit | 10 | Input allowlists, envelopes, projections, workflow, query guard |
| Property | 4 | Normalization, bank masking, address boundaries, owner identity |
| Integration/database | 12 | Schema, keys, indexes, JSON, seed, packages, views, verifier grants |
| Contract | 12 | OpenAPI, ORDS, all operations/roles, Bruno generator, and Postman compatibility assets |
| Security | 13 | OAuth, role matrices, IDOR, abuse, TLS, Database Actions, rate limits |
| E2E/story | 15 | All 14 stories and critical warning/blocking variants |
| Performance smoke | 1 | Local read p95 |
| Total | 67 | Zero failures, errors, or skips |

The detailed matrices include 42 unauthenticated denials, 40 wrong-role denials, 42 allowed-role reachability checks, all 18 table definitions, all 17 FKs, all 48 declared indexes, all JSON columns, all 15 package pairs, and all four views.

## Migration and Seed Result

The clean rebuild removed the previous named volume, recreated ERPATP from the checksum-verified local PDB cache, and applied all 47 manifest assets successfully. No application migration-history table was added; checksums and results are retained in ignored `.local/reports/migration-run.json`.

Three seed files then populated governed reference data, two existing suppliers/sites, and seven complete lifecycle scenarios. Identity sequences were synchronized after seeding. The final seed check found zero empty tables and zero retry-history invariant violations. See `migration-summary.md` for the complete ordered breakdown.

## Manual Demonstration Surfaces

1. Oracle Database Actions: browse tables and run read-only SQL as `ERP_VERIFY`.
2. Oracle SQLcl: connect through the generated mTLS wallet with `./scripts/sqlcl.sh`.
3. Bruno Desktop: account-free authentication, role folders, all 42 operations, and guided workflows.
4. Postman Desktop: optional compatibility client using the same API contract.
5. Curated CLI queries: run the six pages under `database/qa/` using `scripts/query.py`.
6. Static wireframes: open `mockups/supplier-onboarding-wireframes.html` for the user experience.

The exact presentation sequence and credential handling are documented in `local-demo-runbook.md`.

## Security and Limitations

Application-controlled dependency, secret, source, TLS, role, ownership, input, masking, throttling, and hardening checks pass. Database Actions is loopback-only and should be demonstrated with `ERP_VERIFY`, not ADMIN.

The current official Oracle ADB Free image contains documented vendor package findings. The local environment is accepted only for development and demonstration; it is not a production release baseline. Real OIC, Fusion, SSO, and AI calls remain deterministic mocks or documented contracts. Production topology, centralized monitoring, backup/restore objectives, HA, retention, and compliance controls remain future deployment decisions.

## Conclusion

The requested local construction scope is complete and demonstrable: database, wallet, migrations, seed data, ORDS endpoints, authentication/authorization, account-free Bruno, Postman compatibility assets, Database Actions, SQLcl, use-case tests, and reports are installed and verified. No OCI account or Oracle Playground is required.
