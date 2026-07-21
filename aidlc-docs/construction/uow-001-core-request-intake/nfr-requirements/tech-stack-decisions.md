# UOW-001 Technology Stack Decisions

## Decision Summary

| Layer | Selection | Status |
|---|---|---|
| Local database/runtime | Oracle Autonomous AI Database Free 26ai, image `ghcr.io/oracle/adb-free:26.2.4.2-26ai`, ATP workload | Approved construction baseline |
| Local orchestration | Docker Compose v2 | Approved construction baseline |
| Database schema and logic | Oracle SQL and PL/SQL | Selected |
| REST API | Bundled Oracle REST Data Services | Selected |
| Local API authentication | ORDS OAuth2 clients, roles, and privileges | Selected for automated local testing |
| Production authentication | Customer Oracle identity/SSO mapped to application roles | Deferred customer gate |
| API contract | OpenAPI 3.0.3 plus JSON Schema-compatible component schemas | Selected |
| Migration execution | Ordered SQL files plus fail-fast shell/Python runner and external checksum manifest | Selected |
| Test language | Python 3.13 | Selected |
| Database driver | `python-oracledb` thin mode with generated wallet/TLS configuration | Selected |
| Example test runner | `pytest` | Selected |
| Property test framework | `hypothesis` | Selected per PBT-09 |
| HTTP client | `requests` | Selected |
| Contract validation | `jsonschema`, OpenAPI validator, and endpoint contract tests | Selected |
| Dependency/security scanning | `pip-audit`, secret scan, and filesystem/container vulnerability scanner | Selected; exact tool invocation finalized in code plan |
| SBOM | CycloneDX JSON | Selected |
| Reporting | JUnit XML, coverage where applicable, migration logs, JSON/Markdown summaries | Selected |

## Database Runtime Decision

### Choice

Use the pinned official Oracle Autonomous AI Database Free 26ai container in ATP mode.

### Rationale

- Closest supported local equivalent to Oracle Cloud ATP.
- Native ARM64 support for the development Mac.
- Bundles ORDS and HTTPS, reducing configuration drift.
- Supports Oracle SQL/PLSQL, wallets, Database Actions, and ATP-like service behavior.
- Keeps local setup reproducible without installing Oracle Database directly on macOS.

### Constraints

- Allocate at least 4 CPUs and 8 GiB RAM.
- Use a named volume for restart persistence.
- Pin the release tag and record the resolved image digest; never use `latest`.
- Expose database and ORDS ports only for local development.
- Treat self-signed local certificates as development trust material, never production certificates.

### Rejected Alternatives

| Alternative | Reason Not Selected |
|---|---|
| Oracle Cloud ATP immediately | Requires tenancy, wallet, network, cost/governance, and customer approvals not needed for local implementation. |
| Oracle Database Free with separate ORDS | More installation/configuration work and less ATP-like than the approved autonomous container. |
| Native macOS Oracle installation | Not a supported equivalent for the ARM64 local target. |
| Podman | Valid fallback, but Docker is already installed and the approved plan selected Docker Compose. |

## Database Logic Decision

Use modular PL/SQL packages behind ORDS handlers:

- Request command package for create, update, and submit/resubmit facade.
- Request query/projection package for owner-scoped list/detail/dashboard reads.
- Shared envelope/error utility package.
- UOW-002 package interfaces for governed validation, duplicate, and risk processing.

All data access uses static SQL or bind variables. The code-generation plan will define package names and signatures after NFR/Infrastructure Design approval.

## Migration Decision

Use ordered, numbered SQL scripts with an external runner:

- Scripts fail on SQL/PLSQL error.
- The runner records filename, SHA-256 checksum, start/end time, and result outside the 18-table application schema.
- A clean rebuild is the authoritative local rollback path.
- Destructive reset requires an explicit local-environment guard.
- Schema verification compares the migrated inventory to `database-schema-design.md` and `db-schema.dbml`.

Flyway/Liquibase are not selected because their schema-history tables would alter the finalized application-table inventory unless isolated in another schema. A lightweight external manifest is sufficient for this prototype.

## ORDS and API Decision

- Versioned base: `/ords/erp/supplier-onboarding/v1`.
- ORDS modules/templates/handlers call PL/SQL package interfaces.
- JSON response envelopes follow `technical-design.md`.
- Local OAuth2 roles: Requester, Reviewer, Support/Admin, System/OIC.
- Privileges deny by default and protect endpoint patterns by role.
- Requester ownership is verified inside PL/SQL, not only by ORDS URL privilege.
- CORS origins, rate limits, body sizes, and log redaction are configuration-driven.
- OpenAPI 3.0.3 is generated/maintained with tests asserting parity to implemented handlers.

## Local Identity Decision

ORDS OAuth2 client credentials provide deterministic role testing locally. The token's authenticated client/subject becomes the local actor identity. Separate clients allow owner-isolation tests with at least two Requester subjects.

This is not the production human-login design. Production requires customer SSO/OAuth/OIDC policy, MFA for privileged users, user lifecycle, claims mapping, session policy, and approved Visual Builder integration.

## Test Stack Decision

### Example Tests

Use `pytest` for:

- Migration/schema verification.
- PL/SQL behavior through database/API boundaries.
- ORDS endpoint contracts and role/owner authorization.
- Concrete US-001 through US-003 scenarios.
- Transaction fault injection and restart persistence.
- Security, redaction, rate-limit, and input-boundary tests.

### Property Tests

Use Hypothesis because it supports:

- Reusable composite domain strategies.
- Automatic shrinking.
- Reproducible examples and seeded profiles.
- Stateful rule-based testing for request lifecycle commands.
- Direct integration with pytest.

Required strategy modules will generate:

- Actor identities and role combinations.
- Partial and complete supplier-request aggregates.
- Structured addresses at 0, 1, 19, 20, and 21-character boundaries.
- Valid/invalid contacts and non-negative/invalid spend values.
- Optional masked bank and document metadata.
- Valid and invalid request lifecycle command sequences.

Example-based tests remain mandatory for all critical business scenarios even where a property test exists.

## Dependency Version Policy

- Every Python dependency uses an exact version in committed dependency metadata.
- A generated lock/hash artifact records transitive resolution where the chosen installer supports it.
- The container image uses the exact approved release tag plus recorded digest.
- GitHub Actions and scanner versions use pinned major or immutable references according to tool support.
- Exact current package versions are resolved and vulnerability-checked during Code Generation, then fixed in the code-generation plan and lock files.
- No unreviewed package is added merely for convenience.

## Security Tooling Decision

| Control | Tool/Approach |
|---|---|
| Secret detection | Repository secret scanner plus explicit ignored-secret assertions. |
| Python vulnerabilities | `pip-audit` against exact dependency set. |
| Container/filesystem vulnerabilities | A pinned scanner selected in the code-generation plan, with High/Critical findings blocking unless documented and accepted. |
| SBOM | CycloneDX JSON for Python dependencies plus container image reference/digest in the implementation report. |
| SQL injection | Static review plus adversarial ORDS tests. |
| API contract | OpenAPI validator and negative schema tests. |
| Authorization | Role matrix and cross-owner endpoint tests. |

## Environment Separation

| Environment | Purpose | Data/Secrets |
|---|---|---|
| Local development | Build, migrate, seed, inspect, and debug | Generated dummy data and ignored local secrets only. |
| Local test/reset | Repeatable full-suite execution | Deterministic isolated dummy data; explicit destructive guard. |
| Production target | Future Oracle Cloud ATP/ORDS/OIC/Fusion | Customer-managed identity, keys, wallets, secrets, data, networking, backups, and monitoring. |

No local script may silently target a non-local database. Connection validation must reject destructive operations unless the configured host/service matches the explicit local profile.

## Technology Traceability

| Requirement | Technology Support |
|---|---|
| NFR-001 Oracle stack | ATP-mode Oracle autonomous container, ORDS, PL/SQL; OIC/Fusion mock boundary later. |
| NFR-002 role separation | ORDS OAuth2 roles/privileges plus PL/SQL ownership checks. |
| NFR-003 auditability | Status history, structured trace IDs/logs, migration/test reports. |
| NFR-004 sensitive data | TLS/wallet, masked/hash-only bank metadata, redaction and secret scanning. |
| NFR-005 recoverability | Atomic PL/SQL transactions, persistent volume, fail-fast rebuild/reset. |
| NFR-006 prototype volume | Approved indexes, pagination, bounded payloads, performance smoke tests. |
| NFR-007 business language | Stable safe error envelope and Requester projection tests. |
| PBT-09 | Python Hypothesis integrated with pytest. |

## Deferred Decisions

- Exact customer production identity provider and claims.
- Oracle Cloud ATP edition, region, network, wallet rotation, backup, and DR policy.
- Production OIC/Fusion endpoints, credentials, role grants, and payload mapping.
- Live AI provider and model.
- Visual Builder source project and deployment pipeline.
- Production central logging, metrics, alerting, and incident tooling.
