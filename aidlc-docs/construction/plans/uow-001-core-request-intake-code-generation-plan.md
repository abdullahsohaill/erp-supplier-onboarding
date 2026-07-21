# UOW-001 Core Request Intake Code Generation Plan

## Status

Part 1 planning complete; awaiting explicit approval. Part 2 generation has not started.

This document is the single source of truth for UOW-001 Code Generation. Part 2 must execute the numbered steps in order and mark each checkbox in the same interaction that completes the step.

## Unit Context

| Item | UOW-001 Scope |
|---|---|
| Stories | US-001 Create and submit; US-002 Correct returned request; US-003 Track status/outcome. |
| Functional requirements | FR-001 through FR-004 directly, with the UOW-001 orchestration boundary of FR-005. |
| Business rules | CRI-BR-001 through CRI-BR-028. |
| API contract | 11 Requester ORDS method/path contracts under `/ords/erp/supplier-onboarding/v1`. |
| Schema | Create the complete finalized shared baseline: 18 tables, 189 columns, 17 physical foreign keys. |
| Dependencies | No upstream UOW. UOW-001 defines the governed-check port later extended by UOW-002. |
| Runtime | Local Docker Compose, Oracle Autonomous AI Database Free 26ai in ATP mode, bundled ORDS, Python 3.13 tooling. |
| Frontend | No Visual Builder source project exists. Do not generate or modify frontend code or the approved static wireframe in this unit. |

## Readiness and Constraints

- Functional Design, NFR Requirements, NFR Design, and Infrastructure Design are approved.
- The repository is greenfield for executable code; only AI-DLC documents and the static mockup exist.
- Application/config/test code must be created at the workspace root, never under `aidlc-docs/`.
- Markdown implementation summaries belong under `aidlc-docs/construction/uow-001-core-request-intake/code/`.
- Docker exposes 10 CPUs but approximately 7.65 GiB. Runtime startup is blocked until the user raises Docker memory to at least 8 GiB.
- The Oracle image is not pulled. Part 2 must resolve and record the exact digest before starting it.
- The 18-table schema is immutable. No migration-history, authentication, rate-limit, correction-item, Reviewer-selection, or retry-history application table may be introduced.
- Full bank account numbers, real credentials, real customer data, and production endpoints are prohibited.

## Implementation-Readiness Amendments

### Edge Rate Limiting

ORDS 26.2 primary documentation describes OAuth2 clients, roles, privileges, and token controls but does not document native per-client request throttling. U1-NFR-SEC-013 must not be falsely marked complete and cannot be implemented through a new application table.

Part 2 will therefore add a small loopback-only Nginx edge service using an exact release tag and resolved digest. It will:

- Terminate local development HTTPS and proxy only approved paths to bundled ORDS over verified HTTPS.
- Apply separate read and mutation zones keyed by the bearer token used by each deterministic local client.
- Enforce 120 reads/minute/token and 30 mutations/minute/token with HTTP 429.
- Never log or return the Authorization header.
- Keep the ORDS listener private to the Compose network; Database Actions/APEX are not exposed through the application gateway.
- Remain a local prototype control. Production requires customer-approved gateway/WAF identity-aware throttling.

Approval of this code-generation plan also approves updating the two UOW-001 infrastructure artifacts from 12 to 13 resources before creating `docker-compose.yml`. If proxy-to-ORDS certificate verification cannot be established, generation must stop and return to Infrastructure Design; it must not disable verification.

### Governed-Check Compatibility Body

UOW-001 owns submit/resubmit orchestration while UOW-002 owns the full validation, duplicate, risk, and AI engines. To keep UOW-001 executable without duplicating the later service boundary:

- Create `ERP_GOV_CHECK_PORT_PKG` as the stable package interface used by `ERP_REQUEST_WORKFLOW_PKG`.
- Its UOW-001 compatibility body is configuration/data driven and implements only submission completeness (`VAL-001` through `VAL-007`) and active exact-tax/same-bank critical blockers (`VAL-008` and `VAL-009`).
- It persists current safe validation/critical-match evidence in the approved tables and never exposes internal candidate fields to Requesters.
- It creates no fuzzy duplicate score, automatic risk assessment, or AI summary. Those are UOW-002 responsibilities.
- UOW-002 extends the same package body and contract; no ORDS route or UOW-001 workflow package is replaced.

## Planned Root Structure

| Path | Purpose |
|---|---|
| `.gitignore`, `.env.example`, `docker-compose.yml` | Safe local configuration and orchestration. |
| `requirements.in`, `requirements.txt`, `pyproject.toml` | Exact Python dependency inputs, generated hash lock, pytest/Hypothesis/Ruff configuration. |
| `config/nginx/` | Loopback HTTPS proxy, allowlisted routes, redacted logs, read/mutation rate zones. |
| `database/bootstrap/` | ADMIN-only creation/grants for `ERP_APP` and optional `ERP_VERIFY`. |
| `database/migrations/` | Ordered table, constraint, index, view, package-install, and verification manifest entries. |
| `database/packages/common/` | API envelope, error, principal/auth, validation, health, and shared utility packages. |
| `database/packages/uow001/` | Request command, query, projection, workflow, and governed-check port packages. |
| `database/seed/` | Deterministic reference and representative scenario data for all 18 tables. |
| `database/scripts/` | SQL health, schema inventory/parity, invalid object, seed completeness, and cleanup checks. |
| `ords/modules/` | UOW-001 Requester module/templates/handlers. |
| `ords/security/` | REST enablement, roles, privileges, clients, CORS inputs, and secret-safe registration. |
| `ords/openapi/` | OpenAPI 3.0.3 contract for the 11 UOW-001 routes. |
| `scripts/` | Preflight, secrets, image digest, start/stop, health, migrate, seed, verify, test, report, and guarded reset orchestration. |
| `tests/support/` | Configuration, database/API clients, fixtures, assertions, and reusable Hypothesis strategies. |
| `tests/unit/`, `tests/property/` | Package/domain examples and required property tests. |
| `tests/integration/`, `tests/contract/` | Oracle/ORDS behavior and OpenAPI parity tests. |
| `tests/security/`, `tests/e2e/`, `tests/performance/` | Authorization, abuse, story flows, recovery, and local p95/concurrency checks. |
| `.local/` | Ignored generated secrets, wallets/trust, image/tool metadata, logs, and reports. |

## Fixed Package Boundaries

| Package | Responsibility |
|---|---|
| `ERP_API_UTIL_PKG` | Trace IDs, success/error envelopes, safe exception mapping, JSON helpers. |
| `ERP_PRINCIPAL_PKG` | Derive and normalize trusted ORDS subject/role context. |
| `ERP_AUTH_PKG` | Function- and object-level authorization and editable-state checks. |
| `ERP_INPUT_PKG` | Allowlisted JSON extraction, type/length/format bounds, unknown/server-field rejection. |
| `ERP_REQUEST_REPO_PKG` | Aggregate persistence and index-aligned reads against approved tables. |
| `ERP_REQUEST_PROJECTION_PKG` | Requester-safe list/detail/timeline/finding/document JSON. |
| `ERP_GOV_CHECK_PORT_PKG` | Stable UOW-002 port plus UOW-001 compatibility body described above. |
| `ERP_REQUEST_WORKFLOW_PKG` | Create, update, submit/resubmit transactions and history transitions. |
| `ERP_REQUEST_QUERY_PKG` | Owner-scoped list/detail/dashboard/reference queries and pagination. |
| `ERP_HEALTH_PKG` | Database identity, schema version/inventory, object validity, and safe health values. |

All public procedures/functions use typed parameters or validated JSON CLOBs, static SQL/binds, explicit transaction ownership, and safe errors. ORDS handlers remain thin.

## Exact File Manifest

### Runtime and Automation

| Exact Path | Planned Content |
|---|---|
| `.gitignore` | Generated-secret, wallet, trust, virtual-environment, report, scanner, and local-runtime exclusions. |
| `.env.example` | Non-secret environment variable names and safe examples. |
| `docker-compose.yml` | Oracle, edge gateway, private network, named volume, ports, health, and resource configuration. |
| `requirements.in` | Exact direct Python pins. |
| `requirements.txt` | Generated transitive hash lock. |
| `pyproject.toml` | pytest, Hypothesis, Ruff, coverage, marker, and timeout configuration. |
| `config/nginx/nginx.conf` | HTTPS proxy, trusted ORDS upstream, allowlisted paths, body limits, redacted logs, and rate zones. |
| `scripts/preflight.py` | Host/resource/port/FileVault/path/target checks. |
| `scripts/generate_secrets.py` | Strong ignored local database, wallet, gateway, and OAuth material. |
| `scripts/capture_image_metadata.py` | Image tag, digest, architecture, and scanner metadata. |
| `scripts/migrate.py` | Ordered fail-fast migration/package/ORDS runner and external manifest writer. |
| `scripts/seed.py` | Deterministic seed orchestration and completeness checks. |
| `scripts/health.py` | Bounded host/container/database/schema/ORDS/OAuth health gates. |
| `scripts/verify.py` | Aggregate schema/API/secret/config verification. |
| `scripts/report.py` | Redacted evidence and Markdown summary generation. |
| `scripts/start.sh`, `scripts/stop.sh`, `scripts/test.sh`, `scripts/reset-local.sh` | Thin lifecycle entry points with safe error propagation. |
| `scripts/tools/install-gitleaks.sh`, `scripts/tools/install-trivy.sh` | Pinned official release download and checksum verification. |

### Database Baseline

| Exact Path | Planned Objects |
|---|---|
| `database/bootstrap/000_create_principals.sql` | `ERP_APP`, optional `ERP_VERIFY`, quotas, and least-privilege grants. |
| `database/migrations/001_create_reference_tables.sql` | `REF_BUSINESS_UNIT`, `REF_SUPPLIER_TYPE`, `REF_HIGH_RISK_COUNTRY`, `VALIDATION_RULES`, `REF_SCORING_RULE`. |
| `database/migrations/002_create_request_workflow_tables.sql` | `SUPPLIER_REQUEST`, `SUPPLIER_REQUEST_SITE`, `SUPPLIER_REQUEST_CONTACT`, `SUPPLIER_REQUEST_BANK`, `SUPPLIER_REQUEST_DOCUMENT`, `STATUS_HISTORY`. |
| `database/migrations/003_create_analysis_tables.sql` | `VALIDATION_RESULT`, `DUPLICATE_MATCH`, `RISK_ASSESSMENT`, `AI_SUMMARY`. |
| `database/migrations/004_create_integration_reference_tables.sql` | `EXISTING_SUPPLIER_REF`, `EXISTING_SUPPLIER_SITE_REF`, `INTEGRATION_LOG`. |
| `database/migrations/005_add_constraints.sql` | Unique/check/JSON constraints and exactly 17 foreign keys. |
| `database/migrations/006_add_indexes.sql` | Approved non-duplicate indexes. |
| `database/migrations/007_create_views.sql` | Justified UOW-001 helper/read views only. |
| `database/migrations/manifest.json` | Ordered files/packages/ORDS definitions and expected checksums. |
| `database/seed/001_reference_data.sql` | Governed reference/rule configuration. |
| `database/seed/002_supplier_reference_data.sql` | Existing supplier/site dummy reference data. |
| `database/seed/003_request_scenarios.sql` | Request aggregates, history, evidence, AI, and integration dummy scenarios across every remaining table. |
| `database/scripts/schema_inventory.sql` | Table/column/constraint/relationship inventory. |
| `database/scripts/invalid_objects.sql` | Invalid `ERP_APP` object gate. |
| `database/scripts/seed_completeness.sql` | Every-table and referential/JSON invariant checks. |

### PL/SQL and ORDS

| Exact Path Pattern | Planned Content |
|---|---|
| `database/packages/common/erp_api_util_pkg.pks`, `.pkb` | `ERP_API_UTIL_PKG`. |
| `database/packages/common/erp_principal_pkg.pks`, `.pkb` | `ERP_PRINCIPAL_PKG`. |
| `database/packages/common/erp_auth_pkg.pks`, `.pkb` | `ERP_AUTH_PKG`. |
| `database/packages/common/erp_input_pkg.pks`, `.pkb` | `ERP_INPUT_PKG`. |
| `database/packages/common/erp_health_pkg.pks`, `.pkb` | `ERP_HEALTH_PKG`. |
| `database/packages/uow001/erp_request_repo_pkg.pks`, `.pkb` | `ERP_REQUEST_REPO_PKG`. |
| `database/packages/uow001/erp_request_projection_pkg.pks`, `.pkb` | `ERP_REQUEST_PROJECTION_PKG`. |
| `database/packages/uow001/erp_gov_check_port_pkg.pks`, `.pkb` | `ERP_GOV_CHECK_PORT_PKG`. |
| `database/packages/uow001/erp_request_workflow_pkg.pks`, `.pkb` | `ERP_REQUEST_WORKFLOW_PKG`. |
| `database/packages/uow001/erp_request_query_pkg.pks`, `.pkb` | `ERP_REQUEST_QUERY_PKG`. |
| `ords/modules/uow001_requester_module.sql` | REST enablement plus exact 11 handlers. |
| `ords/security/uow001_roles_privileges.sql` | Role/privilege/CORS definitions. |
| `ords/security/register_local_clients.sql` | Secret-bind-based ORDS 26.2 client registration. |
| `ords/openapi/uow001-openapi.yaml` | OpenAPI 3.0.3 contract. |

### Test and Documentation Files

| Exact Path | Planned Coverage |
|---|---|
| `tests/conftest.py` | Isolated run identity, clients, cleanup, and environment gates. |
| `tests/support/config.py`, `db.py`, `api.py`, `assertions.py`, `strategies.py` | Shared safe test infrastructure and reusable domain strategies. |
| `tests/unit/test_input_and_envelopes.py` | Input, error, trace, and sensitive-data rules. |
| `tests/unit/test_request_workflow.py` | CRI business rules and status/history transitions. |
| `tests/unit/test_request_projection.py` | Owner-safe projection and forbidden-field invariants. |
| `tests/property/test_request_properties.py` | Round-trip, ownership, status, bounds, and masking properties. |
| `tests/integration/test_migrations_and_schema.py` | Clean migration, 18/189/17, constraints, indexes, invalid objects. |
| `tests/integration/test_seed_and_persistence.py` | Every-table seed, FK/JSON invariants, restart/rebuild. |
| `tests/contract/test_openapi_and_ords.py` | OpenAPI validation and 11-route parity. |
| `tests/security/test_authz_and_input_abuse.py` | OAuth, roles, IDOR, injection, mass assignment, malformed/oversized input. |
| `tests/security/test_secrets_redaction_and_rate_limits.py` | Secret/log scans, bank leakage, CORS, and 429 behavior. |
| `tests/e2e/test_us001_create_submit.py` | US-001. |
| `tests/e2e/test_us002_correct_resubmit.py` | US-002. |
| `tests/e2e/test_us003_track_status.py` | US-003. |
| `tests/performance/test_uow001_performance.py` | Approved local p95 and ten-client smoke targets. |
| `aidlc-docs/construction/uow-001-core-request-intake/code/implementation-summary.md` | Sanitized implementation inventory/results. |
| `aidlc-docs/construction/uow-001-core-request-intake/code/database-summary.md` | Migrations, schema, seed, and parity summary. |
| `aidlc-docs/construction/uow-001-core-request-intake/code/api-summary.md` | ORDS/OpenAPI/security summary. |
| `aidlc-docs/construction/uow-001-core-request-intake/code/test-summary.md` | Test/scan/performance evidence summary. |

## UOW-001 ORDS Contract

| Method | Relative Path | Main Package Operation |
|---|---|---|
| POST | `/requests` | Create Draft. |
| GET | `/requests` | List own requests. |
| GET | `/requests/{requestId}` | Read own Requester-safe detail. |
| PATCH | `/requests/{requestId}` | Update owned editable aggregate. |
| POST | `/requests/{requestId}/submit` | Submit or resubmit through governed checks. |
| GET | `/requests/{requestId}/validation-results` | Read owner-safe current findings. |
| GET | `/requests/{requestId}/attachments` | Read document metadata. |
| POST | `/requests/{requestId}/attachment-metadata` | Maintain document metadata. |
| GET | `/dashboard/requester-summary` | Read owner-scoped counts. |
| GET | `/reference/business-units` | Read active business-unit lookup. |
| GET | `/reference/supplier-types` | Read active supplier-type lookup. |

## Dependency and Tool Pins

Versions were resolved from the official PyPI registry on 2026-07-21. `requirements.in` will use these exact direct pins and `requirements.txt` will be generated with transitive hashes.

| Dependency | Version | Purpose |
|---|---:|---|
| `oracledb` | 4.0.2 | Thin-mode Oracle TLS/mTLS automation. |
| `pytest` | 9.1.1 | Test runner. |
| `hypothesis` | 6.158.0 | Property-based generation, shrinking, and replay. |
| `requests` | 2.34.2 | HTTPS/OAuth/API client. |
| `jsonschema` | 4.26.0 | JSON instance validation. |
| `openapi-spec-validator` | 0.9.0 | OpenAPI document validation. |
| `PyYAML` | 6.0.3 | Safe OpenAPI/config parsing. |
| `pytest-cov` | 7.1.0 | Python tooling coverage. |
| `pytest-timeout` | 2.4.0 | Bounded tests and health waits. |
| `pip-audit` | 2.10.1 | Python vulnerability gate. |
| `cyclonedx-bom` | 7.3.0 | Python CycloneDX SBOM. |
| `pip-tools` | 7.6.0 | Hash-locked dependency resolution. |
| `ruff` | 0.15.22 | Python lint/format gate. |

External tools are pinned to Gitleaks 8.30.1 and Trivy 0.72.0. The Oracle image remains `ghcr.io/oracle/adb-free:26.2.4.2-26ai`; the Nginx image uses `nginx:1.28.0-alpine`. Both image digests and official release checksums must be captured before execution. High/Critical vulnerabilities block progress unless fixed or explicitly returned for review.

## Numbered Generation Steps

### Step 1: Revalidate Baseline and Record Infrastructure Amendment

- [ ] Re-read the approved plan/artifacts and verify Git status contains no unexpected user changes.
- [ ] Amend `infrastructure-design.md`, `deployment-architecture.md`, and AI-DLC state/audit to add the loopback edge-throttle resource and ORDS-private network path.
- [ ] Validate the amended infrastructure traceability and extension compliance before creating root code.

### Step 2: Create Safe Project Skeleton

- [ ] Create the planned root directories and UOW-001 code-summary directory.
- [ ] Extend `.gitignore` for `.env`, `.local/`, `.venv/`, wallets, certificates, reports, tokens, and generated secrets without removing existing rules.
- [ ] Create `.env.example` with names/placeholders only and update `README.md` to Construction status and safe prerequisites.
- [ ] Validate that no executable/config file is created under `aidlc-docs/`.

### Step 3: Pin Python and Security Tooling

- [ ] Create `requirements.in`, hash-locked `requirements.txt`, and `pyproject.toml` using the approved versions.
- [ ] Create pinned installer/checksum metadata for Gitleaks and Trivy under `scripts/tools/`.
- [ ] Generate the local virtual environment only under ignored `.venv/`; run dependency and import checks.

### Step 4: Generate Compose and Edge Gateway Configuration

- [ ] Create `docker-compose.yml` with pinned Oracle and Nginx tags, loopback-only gateway/database ports, private network, named Oracle volume, health dependencies, resource expectations, no Mongo port, and no plaintext secrets.
- [ ] Create Nginx HTTPS, upstream certificate verification, approved-route allowlist, body limits, redacted access logs, and token-scoped read/mutation rate zones.
- [ ] Validate resolved Compose config contains exactly the expected services/resources and no secret values.

### Step 5: Generate Preflight, Secret, and Trust Automation

- [ ] Implement host preflight for ARM64, Docker/Compose, at least 4 CPUs/8 GiB, FileVault, disk/ports, ignored paths, and local target fingerprint.
- [ ] Implement cryptographically strong local database/wallet/gateway/OAuth secret and certificate generation with owner-only permissions and no echoed values.
- [ ] Implement Oracle image digest capture, wallet/ORDS certificate extraction, trust-bundle construction, and certificate verification; never use an insecure client flag.

### Step 6: Generate Lifecycle Command Surface

- [ ] Create start, stop, bounded health, logs, migrate, seed, verify, test, report, and explicitly guarded reset commands.
- [ ] Ensure ordinary stop/down preserves the named volume.
- [ ] Ensure reset rejects non-loopback/non-`ERPATP`/wrong-Compose targets and requires a destructive confirmation flag.

### Step 7: Generate Bootstrap and External Migration Runner

- [ ] Create ADMIN-only bootstrap SQL for `ERP_APP`, optional `ERP_VERIFY`, quotas, and least-privilege grants.
- [ ] Create an ordered JSON migration manifest and Python runner that records SHA-256, UTC timing, database fingerprint, result, and safe errors outside the schema.
- [ ] Make SQL/PLSQL warnings/errors fail fast and prohibit a migration-history application table.

### Step 8: Generate the Finalized 18-Table DDL

- [ ] Translate all 189 authoritative columns to explicit Oracle types/lengths/defaults/identity behavior without inventing fields.
- [ ] Create all 18 approved tables in dependency-safe order, including valid JSON CLOB constraints and boolean-like check conventions.
- [ ] Validate table/column names against both `database-schema-design.md` and `db-schema.dbml`.

### Step 9: Generate Constraints, Relationships, Indexes, and Views

- [ ] Create all primary/unique/check constraints and exactly 17 approved physical foreign keys.
- [ ] Create approved access-path indexes without duplicating PK/UK backing indexes.
- [ ] Add only justified role-safe/helper views; views must not change the 18-table count.
- [ ] Create schema parity and zero-invalid-object verification scripts.

### Step 10: Generate Representative Seed Data for Every Table

- [ ] Seed `REF_BUSINESS_UNIT`, `REF_SUPPLIER_TYPE`, `REF_HIGH_RISK_COUNTRY`, `VALIDATION_RULES` (`VAL-001` through `VAL-009`), and typed/versioned `REF_SCORING_RULE` rows with active/inactive examples.
- [ ] Seed Requester-owned Draft, Correction Requested, Under Review, duplicate-blocked, warning-only, final outcome, and integration-failure scenarios across all 18 tables.
- [ ] Use only deterministic dummy masked/hash bank data, valid JSON, and referentially valid IDs discovered through business keys.
- [ ] Verify every application table contains representative data and `retry_count` equals retry history length.

### Step 11: Generate Common PL/SQL Packages

- [ ] Implement and compile `ERP_API_UTIL_PKG`, `ERP_PRINCIPAL_PKG`, `ERP_AUTH_PKG`, `ERP_INPUT_PKG`, and `ERP_HEALTH_PKG` specifications/bodies.
- [ ] Enforce safe envelopes, trace IDs, role/owner derivation, input bounds, unknown/server-field rejection, raw-bank rejection, static SQL, and redacted errors.
- [ ] Add focused direct-package test fixtures for boundary and authorization behavior.

### Step 12: Generate Repository and Projection Packages

- [ ] Implement and compile `ERP_REQUEST_REPO_PKG` with aggregate create/update/read, child ownership, one-bank/one-primary-site rules, conflict checks, and set-based bounded queries.
- [ ] Implement and compile `ERP_REQUEST_PROJECTION_PKG` with explicit Requester allowlists for list/detail/timeline/findings/documents.
- [ ] Add projection leakage and aggregate round-trip tests.

### Step 13: Generate Governed-Check Compatibility Package

- [ ] Implement and compile the stable `ERP_GOV_CHECK_PORT_PKG` interface and UOW-001 compatibility body exactly as defined above.
- [ ] Use active configuration and supplier/request reference data; do not hardcode request IDs, outcomes, scores, or fake risk/AI evidence.
- [ ] Persist run IDs/current flags and safe critical findings atomically while preserving historical rows.
- [ ] Add explicit tests proving critical blockers prevent submission and high-risk-country data alone does not block.

### Step 14: Generate Workflow and Query Packages

- [ ] Implement and compile `ERP_REQUEST_WORKFLOW_PKG` for create, editable update, blocked submit, and atomic successful submit/resubmit transitions.
- [ ] Implement and compile `ERP_REQUEST_QUERY_PKG` for owner-scoped list/detail/dashboard/reference lookups and deterministic pagination.
- [ ] Verify Draft incompleteness, Correction Requested editing, status/history atomicity, no history on ordinary edits/blocked submit, and safe final outcomes.

### Step 15: Generate the 11 UOW-001 ORDS Handlers

- [ ] REST-enable only the intended `ERP_APP` schema behavior and disable unrestricted REST-enabled SQL for application clients.
- [ ] Create one versioned UOW-001 module with the exact 11 method/path handlers and thin package calls.
- [ ] Apply media/body/pagination/error behavior and stable trace envelope contracts.

### Step 16: Generate OAuth2 Roles, Privileges, and Local Clients

- [ ] Use ORDS 26.2 `ORDS_SECURITY`/`ORDS_SECURITY_ADMIN` APIs, not deprecated `OAUTH`/`OAUTH_ADMIN` packages.
- [ ] Create Requester, Reviewer, Support/Admin, and System/OIC roles plus least-privilege UOW-001 Requester route privileges.
- [ ] Register two Requester clients and later-role clients with generated secrets written only to ignored files.
- [ ] Configure explicit CORS origins and verify unauthenticated, wrong-role, and cross-owner denial.

### Step 17: Generate and Validate OpenAPI 3.0.3

- [ ] Define all 11 UOW-001 operations, OAuth2 security, request/response schemas, pagination, trace envelopes, and 400/401/403/404/409/413/422/429/500 errors.
- [ ] Validate OpenAPI syntax and exact method/path parity with ORDS source.
- [ ] Include Requester-safe examples with no internal evidence or sensitive values.

### Step 18: Generate Business Logic and Repository Example Tests

- [ ] Create direct database/package tests covering every CRI-BR-001 through CRI-BR-028 rule and transaction failure point.
- [ ] Test all aggregate cardinalities, lengths, formats, status transitions, conflict handling, generated request numbers, timestamps, JSON, and foreign keys.
- [ ] Produce a machine-readable rule-to-test matrix with no uncovered blocking/security rule.

### Step 19: Generate Property-Based Tests

- [ ] Create reusable strategies for principals, partial/complete requests, structured addresses at 0/1/19/20/21 boundaries, contacts, masked bank metadata, documents, and lifecycle commands.
- [ ] Implement required round-trip and invariants for mapping, owner isolation, forbidden-field projection, status/history, address/spend bounds, and bank masking.
- [ ] Keep Hypothesis shrinking enabled and record replayable seed/profile and shrunk failures.
- [ ] Keep example tests for every critical path; PBT does not replace them.

### Step 20: Generate Database and Migration Integration Tests

- [ ] Test clean migration, checksum manifest, rerun behavior, invalid-object detection, exact 18/189/17 parity, indexes/constraints, and seed completeness.
- [ ] Test ordinary restart persistence and clean guarded rebuild equivalence.
- [ ] Test rollback at aggregate, child, findings, status, and history failure points.

### Step 21: Generate API, Contract, and End-to-End Tests

- [ ] Test every UOW-001 method/path positive and negative contract, OAuth token flow, body/media/page bounds, trace IDs, and safe errors.
- [ ] Test US-001 Draft/submit, US-002 correction/resubmit, and US-003 owner-scoped status/outcome workflows.
- [ ] Test automatic critical blockers, no duplicate-preview route, actionable 422 results, and successful Under Review handoff.
- [ ] Validate runtime responses against OpenAPI/JSON schemas.

### Step 22: Generate Security and Abuse Tests

- [ ] Test unauthenticated, wrong-role, IDOR/cross-owner, mass-assignment, SQL injection, malformed JSON, oversized input, CORS, raw-bank, error leakage, and reset-target attacks.
- [ ] Test Nginx read/mutation 429 behavior without Authorization-header logging.
- [ ] Scan repository/reports for secrets, tokens, wallets, full account-like values, and protected evidence leakage.

### Step 23: Generate Resilience and Performance Tests

- [ ] Test bounded startup/health failures, Docker restart persistence, package/transaction fault injection, certificate failure, and recovery reruns.
- [ ] Generate local dataset and harness for p50/p95/max list/detail/create/update/dashboard/submit targets and ten-client mixed-operation smoke tests.
- [ ] Record host allocation, image digests, dataset, warm-up, concurrency, errors, and measurements without making production claims.

### Step 24: Generate Supply-Chain and Quality Gates

- [ ] Run Ruff/compile checks, hash-lock verification, `pip-audit`, Gitleaks, Trivy filesystem/image scans, and CycloneDX SBOM generation.
- [ ] Fail on unresolved High/Critical findings or secret leakage and preserve sanitized evidence.
- [ ] Verify images/actions/tools use pinned versions/digests and only trusted registries/releases.

### Step 25: Execute Focused UOW-001 Verification

- [ ] After memory preflight passes, start the local stack, migrate, seed, compile, and execute the complete UOW-001 unit/integration/contract/property/security/e2e/recovery/performance suite.
- [ ] Correct failures and rerun affected plus regression suites until all UOW-001 gates pass or a genuine blocker is documented.
- [ ] Stop the stack without deleting the persistent volume and verify the working tree contains no generated secret/report material.

Full cross-unit Build and Test remains mandatory after UOW-005.

### Step 26: Generate Documentation and UOW-001 Code Summaries

- [ ] Update root README with exact safe setup/lifecycle commands and manual Docker memory prerequisite.
- [ ] Create `aidlc-docs/construction/uow-001-core-request-intake/code/implementation-summary.md`, `database-summary.md`, `api-summary.md`, and `test-summary.md` using only sanitized results.
- [ ] Record created files, migration purposes/checksums/results, schema parity, package/route inventory, tests, performance, scans, limitations, UOW-002 handoff, and production gates.

### Step 27: Commit and Push Green Checkpoints

- [ ] Commit/push scaffold/runtime/security configuration after static validation.
- [ ] Commit/push finalized schema/migration/seed assets after parity checks.
- [ ] Commit/push UOW-001 PL/SQL and ORDS/OpenAPI assets after compile/contract checks.
- [ ] Commit/push tests, reports, and documentation after all focused UOW-001 gates pass.
- [ ] Never commit `.local/`, `.venv/`, generated credentials, wallets, certificates, tokens, or unsanitized reports.

### Step 28: Close Code Generation Review Gate

- [ ] Mark every completed plan checkbox immediately and update story completion only after executable coverage passes.
- [ ] Validate Git diff, traceability, extension compliance, schema/API parity, and absence of duplicate/generated-secret files.
- [ ] Update AI-DLC state/audit and present the mandatory Code Generation completion review before UOW-002.

## Story and Requirement Traceability

| Scope | Generation Steps |
|---|---|
| US-001 / FR-001, FR-003, FR-004 | Steps 8 through 18, 20 through 23. |
| US-002 / FR-001, FR-002, FR-005 boundary | Steps 13, 14, 18 through 23. |
| US-003 / FR-002, FR-009 safe projection | Steps 12, 14, 17, 19, 21, 22. |
| CRI-BR-001 through CRI-BR-007 | Steps 11, 12, 14, 18, 22. |
| CRI-BR-008 through CRI-BR-020 | Steps 10, 13, 14, 18, 19, 21. |
| CRI-BR-021 through CRI-BR-024 | Steps 12, 14, 18 through 21, 23. |
| CRI-BR-025 through CRI-BR-028 | Steps 11, 12, 14, 17 through 22. |
| 53 UOW-001 NFRs | Steps 3 through 26; exact requirement-to-test evidence is emitted in Step 26. |

## Extension Enforcement in Part 2

| Extension | Enforced Code-Generation Controls |
|---|---|
| Security Baseline | SECURITY-01 through SECURITY-15 are blocking where applicable; explicit encryption, logging, validation, least privilege, network, auth, hardening, supply chain, abuse, secret, integrity, monitoring, and fail-safe steps are included. |
| Resiliency Baseline | RESILIENCY-01 through RESILIENCY-15 are enforced for local scope; production HA/DR/scaling items remain N/A with rationale. |
| Property-Based Testing, Partial | PBT-02, PBT-03, PBT-07, PBT-08, and PBT-09 are blocking. PBT-01, PBT-04 through PBT-06, and PBT-10 are advisory but included where valuable. |

### Security Planning Compliance

| Rule | Status | Planned Enforcement |
|---|---|---|
| SECURITY-01 | Compliant | Steps 4/5 enforce FileVault-backed persistence and verified HTTPS/TLS/mTLS. |
| SECURITY-02 | Compliant for local scope | Steps 4/22 configure and test redacted edge/ORDS access events. |
| SECURITY-03 | Compliant for local scope | Steps 11/23/26 generate structured trace/health/test evidence without protected data. |
| SECURITY-04 | N/A | UOW-001 serves JSON only; no HTML application is generated. |
| SECURITY-05 | Compliant | Steps 4/11/15/17/22 enforce body, type, length, format, allowlist, and injection controls. |
| SECURITY-06 | Compliant | Steps 7/11/16 implement least-privilege database principals, packages, roles, and route privileges. |
| SECURITY-07 | Compliant | Steps 4/5 enforce loopback bindings, a private ORDS network, and no unused port exposure. |
| SECURITY-08 | Compliant | Steps 11/16/22 layer OAuth privilege, role, object-owner, CORS, and IDOR controls. |
| SECURITY-09 | Compliant | Steps 2/4/5/11 reject defaults, omit unused services, and return safe errors. |
| SECURITY-10 | Compliant | Steps 3/24 pin, hash, scan, and produce SBOM evidence. |
| SECURITY-11 | Compliant | Steps 4/11/22 isolate security modules, layer controls, throttle requests, and test abuse. |
| SECURITY-12 | Compliant for local client-credentials scope | Steps 5/16 externalize and rotate generated secrets. Human login/session/MFA remain a production SSO gate. |
| SECURITY-13 | Compliant | Steps 3/7/17/24 validate deserialization, checksums/digests, contracts, and audit integrity. |
| SECURITY-14 | Compliant for local scope | Steps 22/23/26 test security events and produce review evidence; production retention/alerting remains gated. |
| SECURITY-15 | Compliant | Steps 6/7/11/20/23 enforce fail-fast handling, rollback, cleanup, bounded waits, and safe responses. |

### Resiliency Planning Compliance

| Rule | Status | Planned Enforcement |
|---|---|---|
| RESILIENCY-01 | Compliant | Unit remains classified as a medium-criticality local prototype. |
| RESILIENCY-02 | Compliant | Approved local targets are tested; no production SLA/RTO/RPO is claimed. |
| RESILIENCY-03 | Compliant | Steps 7/27/28 use checksummed change order, green commits, and approval gates. |
| RESILIENCY-04 | Compliant for local scope | Steps 6/20/25 automate deployment, verification, and clean-rebuild rollback. |
| RESILIENCY-05 | Compliant for local scope | Steps 22/23 make health/security failures blocking and observable. |
| RESILIENCY-06 | Compliant | Steps 5/6 implement bounded host, container, database, schema, ORDS, and OAuth probes. |
| RESILIENCY-07 | Compliant | Steps 23/26 record trace, health, error, recovery, and performance evidence. |
| RESILIENCY-08 | N/A | Multi-zone/region deployment is outside the approved local prototype. |
| RESILIENCY-09 | N/A | Local capacity is fixed; production auto-scaling remains a customer gate. |
| RESILIENCY-10 | Compliant | UOW-001 is database-local; edge/ORDS failure is isolated and no remote call holds a transaction. |
| RESILIENCY-11 | N/A | Production DR selection requires customer RTO/RPO and topology decisions. |
| RESILIENCY-12 | Compliant for local scope | Steps 4/20 test named-volume persistence; production backup/replication remains gated. |
| RESILIENCY-13 | Compliant for local scope | Steps 6/20/23 define and test restart and clean-rebuild recovery. |
| RESILIENCY-14 | Compliant for local scope | Steps 18/20/23 include transaction fault injection and restart/rebuild testing. |
| RESILIENCY-15 | Compliant for local scope | Steps 23/25/26 preserve diagnostics, correct failures, rerun, and report residual issues. |

### Partial Property-Based Testing Planning Compliance

| Rule | Status | Planned Enforcement |
|---|---|---|
| PBT-02 | Compliant | Steps 12/19 implement aggregate/API serialization and persistence round trips. |
| PBT-03 | Compliant | Step 19 covers ownership, projection, lifecycle, bounds, range, and masking invariants. |
| PBT-07 | Compliant | Step 19 creates centralized reusable domain-specific strategies with boundary cases. |
| PBT-08 | Compliant | Steps 19/26 retain shrinking and replayable seed/profile evidence. |
| PBT-09 | Compliant | Hypothesis 6.158.0 is pinned with pytest 9.1.1 in Steps 3/19. |

No applicable enabled-extension blocking finding exists in this generation plan. Any blocking finding discovered during Part 2 stops generation and is recorded before a continuation option is offered.

## Part 1 Planning Checklist

- [x] Loaded the approved Functional Design, NFR Requirements, NFR Design, Infrastructure Design, schema, unit/story maps, and construction baseline.
- [x] Confirmed greenfield workspace root and root-level application/config/test locations.
- [x] Defined exact paths, package boundaries, migration order, ORDS routes, tests, summaries, and commit checkpoints.
- [x] Mapped US-001 through US-003, FRs, CRI-BR-001 through CRI-BR-028, and all 53 UOW-001 NFRs to generation steps.
- [x] Resolved direct Python and external security-tool versions from primary registries.
- [x] Identified and resolved the governed-check cross-unit boundary without adding schema objects.
- [x] Identified the ORDS throttling gap and documented the loopback edge amendment without adding a rate-limit table.
- [x] Validated plan Markdown, tables, paths, sequence, extension coverage, and schema/API boundaries.
- [x] Updated AI-DLC state, master construction status, and audit for the Part 1 review gate.

## Approval Gate

Explicit approval of this complete plan is required before Step 1 of Part 2. Approval authorizes the generation sequence and the documented loopback edge-throttle infrastructure amendment. It does not waive the Docker memory preflight, security gates, schema contract, per-step checkbox updates, or later generated-code review.
