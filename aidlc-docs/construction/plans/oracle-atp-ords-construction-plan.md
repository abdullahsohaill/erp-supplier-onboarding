# Oracle ATP and ORDS Construction Plan

## Status

**Approved. Construction design is in progress; implementation has not started.**

## Objective

Create a reproducible local Oracle Autonomous Transaction Processing environment, realize the finalized 18-table schema as executable Oracle migrations, configure the complete ORDS API baseline, load representative data into every application table, test the customer use cases and security boundaries, and produce consolidated implementation, migration, and test reports.

## Approved Baseline

- `aidlc-docs/inception/application-design/database-schema-design.md` is the authoritative database contract.
- `aidlc-docs/inception/application-design/db-schema.dbml` is its synchronized machine-readable equivalent.
- The application schema must contain exactly the approved 18 business tables, 189 columns, and 17 physical relationships.
- No migration-history, authentication, correction-item, Reviewer-selection, or retry-history application tables may be added.
- PL/SQL packages, ORDS metadata, indexes, constraints, views, identities, and test-only scripts may support the model without changing its approved table inventory.
- The 42 endpoints in Section 8.4 of `technical-design.md` form the ORDS contract baseline.
- Fusion and supplier-reference integration use deterministic local mocks until customer OIC/Fusion access is available.
- AI summaries use deterministic mock generation until the customer approves a live provider.
- Phase one does not create Fusion bank accounts or store full bank account numbers.

## Local Runtime Decision

| Area | Selected Approach | Rationale |
|---|---|---|
| Database | `ghcr.io/oracle/adb-free:26.2.4.2-26ai` | Official Oracle Autonomous AI Database Free image, native ARM64, pinned release, and supports ATP workload mode. |
| Workload | `WORKLOAD_TYPE=ATP` | Closest supported local equivalent to the target Oracle ATP service. |
| ORDS | ORDS bundled with the Autonomous Database Free image | Avoids a second ORDS installation and provides HTTPS on port 8443. |
| Orchestration | Docker Compose | Reproducible startup, persistence, health checks, resource settings, and teardown. |
| Database logic | Oracle SQL and PL/SQL packages behind ORDS | Matches the approved technical design and keeps validation, duplicate, risk, workflow, and integration behavior transactional. |
| API security | ORDS OAuth2 clients, privileges, and roles for Requester, Reviewer, Support/Admin, and System/OIC | Enforces deny-by-default role and function boundaries without trusting UI state. |
| Test runtime | Python 3.13 with pinned `pytest`, `python-oracledb`, `requests`, `jsonschema`, and `hypothesis` dependencies | Supports database, HTTPS API, contract, example-based, and property-based testing. |

Oracle documents the selected image as supporting ATP workload mode, ORDS, ARM64, and Docker-compatible OCI images. The local host has 16 GB RAM and ARM64 architecture; the image requires 4 CPUs and 8 GiB RAM.

Official references:

- [Oracle Autonomous AI Database Free container documentation](https://github.com/oracle/adb-free)
- [Oracle REST Data Services installation and configuration](https://docs.oracle.com/en/database/oracle/oracle-rest-data-services/26.2/ordig/)

## Implementation Layout

Application and test artifacts will be created outside `aidlc-docs/`:

```text
database/
  migrations/
  packages/
  seed/
  scripts/
ords/
  modules/
  security/
  openapi/
tests/
  unit/
  property/
  integration/
  contract/
  security/
  e2e/
scripts/
docker-compose.yml
.env.example
requirements.txt
```

Generated Markdown summaries and final reports remain under `aidlc-docs/construction/`.

## Migration Set

The detailed code-generation plan will finalize filenames, but the migration responsibilities are fixed:

1. Bootstrap the least-privilege `ERP_APP` application schema and required grants.
2. Create all 18 approved tables with Oracle-compatible types and generated numeric identities.
3. Add the approved primary keys, unique keys, checks, 17 foreign keys, indexes, and JSON validity constraints.
4. Create PL/SQL packages for request workflow, validation, duplicate detection, risk scoring, Reviewer decisions, dashboards, mock AI, mock Fusion/OIC outcomes, integration logging, and controlled retry.
5. REST-enable the application schema and define versioned ORDS modules, templates, handlers, roles, OAuth clients, privileges, and rate controls.
6. Seed governed reference data and representative workflow scenarios, ensuring every approved application table contains meaningful sample rows.
7. Create verification scripts for schema parity, invalid-object detection, seed completeness, and reset/rebuild repeatability.

Migration execution will be fail-fast and repeatable on a clean persistent volume. No application migration-history table will be introduced because it would violate the finalized 18-table contract; the runner will produce an external checksummed execution manifest and log instead.

## Endpoint Scope

All 42 approved ORDS endpoints will be implemented and described in an OpenAPI document, including:

- Request creation, update, submit/resubmit, detail, list, and attachments metadata.
- Automatic validation, duplicate detection, risk scoring, and AI summary operations.
- Reviewer decisions and targeted correction guidance.
- Requester, Reviewer, and Support/Admin dashboard projections.
- Request-scoped integration logs and controlled retry.
- Admin Settings lookups and governed validation, risk, duplicate, country, business-unit, and supplier-type maintenance.
- System/OIC supplier-reference and integration-result callbacks.

Requester projections will not expose internal risk scores, duplicate evidence, AI review evidence, or Reviewer-only selected factor codes.

## Seed Scenarios

The seed set will include at least:

- A valid Draft request.
- A Correction Requested request that can be edited and resubmitted.
- A request Under Review with validation, duplicate, risk, and AI evidence.
- A request marked as an exact-tax duplicate.
- A request with a same-bank-hash critical duplicate.
- A high-risk-country warning that does not block submission.
- An approved request awaiting mock Fusion submission.
- A Created in Fusion success with supplier and site identifiers.
- A retry-eligible technical integration failure with retry history.
- A rejected request and complete status-history evidence.
- Active and inactive validation/scoring settings and effective-dated high-risk countries.
- Existing supplier and site references used by exact and fuzzy matching.

All bank data will be masked or irreversibly hashed dummy data.

## Test Strategy

### Example-Based Tests

- Verify every functional requirement and all 14 user stories through concrete scenarios.
- Test all 42 endpoint method/path contracts, success envelopes, safe errors, and HTTP statuses.
- Test Requester ownership, Reviewer access, Support/Admin operations, System/OIC callbacks, and denied cross-role access.
- Test Draft and Correction Requested editing, automatic submit orchestration, critical blockers, warning-only findings, review decisions, and status transitions.
- Test mock Fusion success, business failure, technical failure, idempotency, retry eligibility, retry exhaustion, and atomic retry-history updates.
- Test Admin Settings activation/deactivation and effective-dated configuration.
- Verify every table is seeded and every foreign key remains valid.

### Property-Based Tests

- Normalization is idempotent.
- Duplicate and risk scores remain within 0 through 100.
- Risk-level classification is consistent with configured thresholds.
- JSON decision envelopes and retry histories round-trip without information loss.
- Requester projection always removes Reviewer-only evidence.
- `retry_count` always equals retry-history length.
- Replaying an idempotent supplier-reference callback does not create duplicates.

Hypothesis shrinking remains enabled and failing seeds will be logged for reproducibility.

### Additional Gates

- Schema-to-design parity check: 18 tables, 189 columns, and 17 foreign-key relationships.
- OpenAPI validation and endpoint-catalog parity.
- Dependency vulnerability scan and generated SBOM.
- Secret scan and assertion that committed files contain no passwords, tokens, or wallet material.
- SQL injection, malformed JSON, over-length input, invalid status transition, IDOR, and unauthorized-role tests.
- Local performance smoke test for request list/detail, submit validation, duplicate scoring, and Reviewer queue queries.

## Reports

The final consolidated package will include:

- `aidlc-docs/construction/build-and-test/consolidated-implementation-report.md`
- `aidlc-docs/construction/build-and-test/migration-summary.md`
- `aidlc-docs/construction/build-and-test/build-and-test-summary.md`
- Standard build, unit, integration, contract, security, end-to-end, and performance test instructions.
- Machine-readable test results, coverage, migration logs, schema inventory, OpenAPI validation output, vulnerability scan, and SBOM under an ignored local reports directory where appropriate.

The migration summary will list each migration, purpose, objects created or changed, execution order, checksum, result, rollback/reset approach, and schema-parity result.

## Manual Actions

No Oracle Cloud, Fusion, OIC, or live AI credentials are required for the local implementation.

The following may require user interaction only if local automation cannot complete them:

1. Start Docker Desktop and allow at least 4 CPUs and 8 GiB memory. Docker is installed, but its daemon is currently stopped.
2. Approve any macOS prompt raised by Docker Desktop for privileged networking or filesystem access.
3. Trust the generated local self-signed ORDS certificate in the browser only if interactive Database Actions/APEX access is desired. Automated tests will use the copied local CA certificate rather than disabling TLS verification.
4. Later provide customer-managed credentials and tenancy details when replacing mocks with Oracle Cloud ATP, OIC, Fusion, SSO, or a live AI provider.

Secrets will be generated into ignored local files. They will not be committed or written into documentation.

## Execution Checklist

- [x] Approve this construction workflow plan.
- [ ] Complete and approve UOW-001 functional, NFR, NFR-design, and infrastructure artifacts. Functional Design, NFR Requirements, and NFR Design are approved; Infrastructure Design is complete and awaiting explicit approval.
- [ ] Complete and approve the UOW-001 code-generation plan and implementation.
- [ ] Complete and approve UOW-002 functional, NFR, NFR-design, and infrastructure artifacts.
- [ ] Complete and approve the UOW-002 code-generation plan and implementation.
- [ ] Complete and approve UOW-003 functional, NFR, NFR-design, and infrastructure artifacts.
- [ ] Complete and approve the UOW-003 code-generation plan and implementation.
- [ ] Complete and approve UOW-004 functional, NFR, NFR-design, and infrastructure artifacts.
- [ ] Complete and approve the UOW-004 code-generation plan and implementation.
- [ ] Complete and approve UOW-005 functional, NFR, NFR-design, and infrastructure artifacts.
- [ ] Complete and approve the UOW-005 code-generation plan and implementation.
- [ ] Start the pinned local ATP/ORDS runtime and apply all migrations.
- [ ] Seed every approved application table and verify referential integrity.
- [ ] Execute unit, property, integration, contract, security, end-to-end, and performance tests.
- [ ] Correct failures and rerun the complete suite.
- [ ] Generate migration, test, and consolidated implementation reports.
- [ ] Present the final build-and-test review gate.

## Planning Checklist

- [x] Loaded approved requirements, verification answers, stories, personas, application design, units, schema, and endpoint catalog.
- [x] Verified the authoritative schema and DBML are equivalent.
- [x] Assessed the local ARM64 host, memory, Docker, Java, Node, and Python availability.
- [x] Selected a pinned official Oracle ATP-capable local image with bundled ORDS.
- [x] Incorporated enabled Security, Resiliency, and partial Property-Based Testing extensions.
- [x] Defined implementation boundaries, migration approach, seed scenarios, test categories, reports, and possible manual actions.

## Definition of Done

- A clean checkout can build the local environment from documented commands without committed secrets.
- The local database runs in ATP mode and ORDS serves HTTPS.
- The application schema exactly matches the finalized 18-table contract.
- All migrations complete successfully and a second clean rebuild produces the same schema.
- Every approved application table contains representative data.
- All 42 approved ORDS endpoints exist, are documented, and enforce role/object authorization.
- All 14 user stories and the mapped functional requirements have executable test coverage.
- Example, property, integration, contract, security, end-to-end, and performance test gates pass.
- The migration summary and consolidated report accurately record commands, results, residual limitations, and future cloud-integration steps.
