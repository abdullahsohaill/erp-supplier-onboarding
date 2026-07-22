# UOW-001 Infrastructure Design

## Scope

This design maps UOW-001 Core Request Intake to a reproducible local, non-production Oracle ATP/ORDS environment. It supports US-001 through US-003, FR-001 through FR-004, the 28 approved UOW-001 business rules, and all 53 approved UOW-001 NFRs.

The finalized 18-table, 189-column, 17-relationship application schema remains authoritative. Infrastructure metadata, Oracle accounts, PL/SQL objects, ORDS metadata, indexes, views, logs, wallets, manifests, and test reports do not add application tables or columns.

## Design Decisions

| Area | UOW-001 Decision |
|---|---|
| Environment | Local non-production runtime on the approved ARM64 Mac using Docker Desktop and Docker Compose v2. |
| Database | `ghcr.io/oracle/adb-free:26.2.4.2-26ai` in ATP mode. The code-generation stage resolves and records the immutable digest before first use. |
| REST tier | A loopback-only Nginx edge terminates local HTTPS, applies token-scoped throttling, and proxies allowlisted application paths to ORDS bundled inside the Oracle autonomous container over verified private HTTPS. |
| Database logic | SQL and PL/SQL packages owned by `ERP_APP`; thin ORDS handlers call package interfaces. |
| API identity | Local ORDS OAuth2 clients, roles, and privileges; production SSO remains a customer decision gate. |
| Persistence | Named Docker volume mounted at `/u01/data`; committed data survives normal container restarts. |
| Secrets | Generated into ignored, permission-restricted `.local/` files; never committed or written into AI-DLC documents. |
| Tests | Host Python 3.13 virtual environment using pinned dependencies; it connects through loopback HTTPS and mTLS/TLS database endpoints. |
| Messaging/cache | None for UOW-001. Request intake is synchronous and database-local; Oracle is the system of record. |
| Production | Not designed or claimed. Oracle Cloud networking, identity, HA, backup/DR, monitoring, and scaling require customer approval. |

Oracle's official container documentation confirms ATP workload support, ARM64 support, the 4 CPU/8 GiB minimum, `/u01/data` persistence, ORDS HTTPS on 8443, database ports, and wallet generation: <https://github.com/oracle/adb-free>.

## Concrete Resource Inventory

| ID | Resource | Proposed Name/Location | Responsibility |
|---|---|---|---|
| U1-INF-001 | Developer host | ARM64 macOS host | Runs Docker Desktop, Compose, Python tests, source control, and local reports. |
| U1-INF-002 | Compose project | `erp-supplier-onboarding` | Owns local service, network, volume, and lifecycle labels. |
| U1-INF-003 | ATP/ORDS service | `oracle-adb` | Runs Oracle Autonomous AI Database Free in ATP mode with bundled ORDS. |
| U1-INF-004 | Local bridge network | `erp_backend` | Private service network; no external ingress path. |
| U1-INF-005 | Persistent database volume | `oracle_adb_data` | Mounted at `/u01/data`; retains committed database state across restart/recreate. |
| U1-INF-006 | Local secret root | `.local/secrets/` | Holds generated database, wallet, and OAuth secret inputs with owner-only permissions. |
| U1-INF-007 | Local trust root | `.local/trust/` | Holds copied wallet/trust material and the ORDS local CA/certificate used by tools. |
| U1-INF-008 | Python environment | `.venv/` | Runs migration orchestration, verification, API tests, PBT, scans, and reporting. |
| U1-INF-009 | Local reports root | `.local/reports/` | Stores migration manifests, JUnit, scans, SBOM, performance data, and consolidated evidence. |
| U1-INF-010 | Database source | `database/` | Versioned migrations, packages, seeds, and verification SQL. |
| U1-INF-011 | ORDS source | `ords/` | Versioned modules, security definitions, and OpenAPI contract. |
| U1-INF-012 | Automation source | `scripts/` and `tests/` | Versioned lifecycle commands and executable test suites. |
| U1-INF-013 | Local HTTPS edge | `erp-edge` Nginx container | Loopback HTTPS ingress, route allowlist, body limits, redacted access logs, and token-scoped read/mutation throttles. |
| U1-INF-014 | Oracle bootstrap egress network | `erp_oracle_bootstrap_egress` | Gives only the Oracle container outbound HTTPS/DNS needed to obtain the official ATP PDB during first initialization; publishes no host port. |
| U1-INF-015 | Edge ingress bridge | `erp_edge_ingress` | Allows Docker Desktop to publish only `127.0.0.1:8443` for the edge; it is separate from the internal edge-to-ORDS backend. |

U1-INF-003 and U1-INF-013 are the only long-running services. U1-INF-014 and U1-INF-015 are network plumbing, not services. Test and migration commands run as bounded host processes. The edge is a local enforcement adapter, not a business-logic service or production gateway claim.

## Logical Component Mapping

| Logical Component | Infrastructure Mapping | Deployment/Control Boundary |
|---|---|---|
| U1-LC-001 ORDS HTTPS Gateway | U1-INF-013 accepts loopback HTTPS and proxies allowlisted paths to bundled ORDS in U1-INF-003 over verified private HTTPS | HTTPS only; explicit CORS origins; token-scoped throttling; structured redacted access events. |
| U1-LC-002 OAuth2 Token Validator | ORDS OAuth2 metadata in the autonomous database | Validates local client token and denies absent/invalid credentials. |
| U1-LC-003 Endpoint Privilege Guard | ORDS roles and privileges | Route patterns are bound to least-privilege role sets. |
| U1-LC-004 Principal Adapter | `ERP_APP` PL/SQL utility package called by handlers | Derives trusted subject and roles from ORDS runtime context. |
| U1-LC-005 Rate and Size Guard | Nginx request zones/body limits plus ORDS and handler validation | Rejects excessive token-scoped rates, bodies, pages, and collections before mutation. |
| U1-LC-006 Request Input Mapper | `ERP_APP` request/API package | Validates allowlisted JSON and converts it to typed PL/SQL values. |
| U1-LC-007 Request Authorization Guard | `ERP_APP` authorization package | Enforces role, owner, and lifecycle state inside the database transaction. |
| U1-LC-008 Request Command Service | `ERP_APP` request command package | Owns Draft create/update transactions. |
| U1-LC-009 Submission Orchestrator | `ERP_APP` request workflow package | Coordinates UOW-002 governed checks and atomic submit/resubmit state. |
| U1-LC-010 Request Query Service | `ERP_APP` query package and approved views | Performs bounded, owner-scoped list/detail/dashboard reads. |
| U1-LC-011 Requester Projection Policy | `ERP_APP` projection package | Emits allowlisted JSON and excludes Reviewer-only evidence. |
| U1-LC-012 Request Aggregate Repository | `ERP_APP` tables and data-access package | Persists only approved request aggregate tables/columns. |
| U1-LC-013 Status History Writer | `ERP_APP` workflow package and `STATUS_HISTORY` | Appends lifecycle events in the same transaction as status changes. |
| U1-LC-014 Governed Check Port | PL/SQL package specification implemented by UOW-002 | Database-local interface; no UOW-001 remote service. |
| U1-LC-015 Envelope and Error Mapper | `ERP_APP` API utility package and ORDS handlers | Produces stable JSON/status/trace output without internal details. |
| U1-LC-016 Structured Redacted Logger | ORDS/container logs and controlled operational event output | Excludes bodies, PII, bank data, credentials, and tokens. |
| U1-LC-017 Health Gate | `scripts/health-*`, SQL probes, HTTPS probes | Blocks migration/seed/test stages until container, DB, schema, ORDS, and OAuth checks pass. |
| U1-LC-018 Migration Runner | Python/shell orchestration in U1-INF-008 | Executes ordered SQL fail-fast and records external checksums/results. |
| U1-LC-019 Schema Verifier | SQL/Python verifier in U1-INF-008 | Confirms 18 tables, 189 columns, 17 FKs, constraints, and valid objects. |
| U1-LC-020 Automated Test Harness | `pytest`/Hypothesis in U1-INF-008 | Runs isolated API, DB, property, security, recovery, and performance tests. |
| U1-LC-021 Evidence Reporter | Python report command writing U1-INF-009 | Consolidates redacted machine-readable and Markdown evidence. |

## Docker Compose Design

### Oracle Service Contract

| Setting | Design Value |
|---|---|
| Image | `ghcr.io/oracle/adb-free:26.2.4.2-26ai`; digest recorded after pull and pinned before acceptance. |
| Platform | Native `linux/arm64`; no emulation. |
| Workload | `WORKLOAD_TYPE=ATP`. |
| Database name | `DATABASE_NAME=ERPATP`; alphanumeric as required by the image. |
| Credentials | `ADMIN_PASSWORD` and `WALLET_PASSWORD` injected from ignored generated environment material. |
| Password validation | Setup rejects missing, default, weak, or format-invalid values before Compose starts. |
| Capability/device | `SYS_ADMIN` and `/dev/fuse` only because the official image requires them for its OFS mount. This exception is documented and limited to the database service. |
| Volume | `oracle_adb_data:/u01/data`. |
| Volume ownership | Before the database starts, a bounded root one-shot using the pinned Oracle image sets only the volume root to Oracle's declared `1001:1001` runtime identity and mode `0700`; the long-running service remains non-root. |
| Restart | `unless-stopped` for developer convenience; readiness is still determined by explicit health gates. |
| Shutdown | Graceful Compose stop before forced termination; no volume deletion by ordinary stop/down. |
| Resource preflight | At least 4 Docker CPUs and 8 GiB available memory. Startup fails before image execution if below target. |

The current host has 10 Docker CPUs but reports approximately 7.65 GiB to containers. Docker Desktop must be raised slightly to at least 8 GiB before runtime construction. The image is not currently pulled; Code Generation records its resolved digest after the approved pull.

### Edge Service Contract

| Setting | Design Value |
|---|---|
| Image | `nginx:1.30.4-alpine3.24`; resolved ARM64 digest recorded before startup. |
| Ingress | `127.0.0.1:8443` only, with a generated local CA/server certificate. |
| Upstream | Private `https://oracle-adb:8443`; hostname and certificate chain verification are mandatory. |
| Routes | Application base path and OAuth token path only; Database Actions, APEX, REST-enabled SQL, and unrecognized paths are denied. |
| Rate keys | Bearer token for authenticated API traffic; loopback address for token issuance. Authorization values are never logged. |
| Limits | 120 reads/minute/token and 30 mutations/minute/token; excess returns 429. |
| Logs | UTC, request ID, method, normalized route, status, latency, and safe client category only. |

This local token-scoped control approximates the deterministic one-token-per-client test model. Production requires an identity-aware customer gateway/WAF policy and must not inherit this prototype assumption.

### Compose Profiles

| Profile/Command Class | Purpose | Persistent Effect |
|---|---|---|
| Default | Start/stop U1-INF-003, U1-INF-013, the private network, and Oracle bootstrap egress. | Preserves U1-INF-005. |
| Bootstrap | Generate local secrets, initialize the named-volume root for Oracle UID/GID, resume and checksum-verify the release-specific official ATP PDB into an ignored cache when absent, start service, copy trust material, and wait for database/ORDS readiness. | Creates ignored local files and persistent database state. |
| Migrate | Apply ordered schema/package/ORDS definitions after readiness. | Creates approved database and ORDS objects. |
| Seed | Load deterministic dummy data only after migration/schema checks. | Populates all approved application tables. |
| Verify/test | Run schema, contract, security, functional, property, and performance checks. | Writes only test data and ignored evidence; cleanup is explicit. |
| Reset | Destroy and recreate only the recognized local Compose project/volume. | Destructive; requires explicit confirmation and target fingerprint. |

Migration, seed, test, and reset remain scripts rather than long-running Compose services. This keeps one runtime source of truth and makes every mutating action explicit.

## Database and Schema Boundaries

### Database Principals

| Principal | Purpose | Permitted Use |
|---|---|---|
| `ADMIN` | One-time local bootstrap and tightly scoped account/grant management | Never used by ORDS handlers or normal tests. Secret remains local. |
| `ERP_APP` | Owns the 18 application tables, packages, views, constraints, indexes, and ORDS module definitions | DDL migrations and runtime package execution. Direct table grants to OAuth callers are prohibited. |
| `ERP_VERIFY` | Read-only verification principal where supported by ATP local runtime | Metadata/schema checks and approved read-only seed assertions; no DML/DDL. |

If ATP restrictions prevent a dedicated verifier from reading required dictionary views, the verifier may connect as `ERP_APP` only for read-only checks. The exception must be explicit in the migration report and cannot be used for API behavior tests.

### Object and Grant Rules

- The application inventory remains exactly 18 business tables, 189 columns, and 17 physical foreign keys.
- PL/SQL package specifications are the runtime API; ORDS handlers do not embed broad ad hoc SQL.
- Runtime callers receive package execution through ORDS, not direct table privileges.
- `ADMIN` grants only the capabilities needed to create and maintain `ERP_APP` objects.
- Server-managed IDs, owners, statuses, scores, timestamps, and audit values are never accepted as authoritative client fields.
- Migration history stays in the external checksum manifest; no migration table is added.
- Test fault-injection hooks, if required, are disabled outside the explicit local test profile and create no table/column.

## Storage, Encryption, and Data Lifecycle

| Data Class | Location | Persistence | Protection/Handling |
|---|---|---|---|
| Oracle database files | Named volume U1-INF-005 | Survives restart/recreate until explicit reset | Oracle autonomous encryption behavior plus FileVault-enabled host storage. |
| Database/wallet secrets | U1-INF-006 | Local until explicit secure cleanup | Owner-only permissions; ignored by Git; never logged. |
| Wallet and ORDS trust material | U1-INF-007 | Regenerated/copied per environment lifecycle | Owner-only permissions; certificate validation remains enabled. |
| Source migrations/config/tests | Repository | Version controlled | Contains no secret values or generated wallets. |
| Migration/test/scan reports | U1-INF-009 | Retained for the current build/review cycle | Redacted; ignored unless an intentionally sanitized Markdown summary is promoted. |
| Container logs | Docker Desktop local logging | Local development retention | Accessed by diagnostics; no body/PII/token logging; production centralization is deferred. |

Ordinary `docker compose down` must not delete the named volume. Reset requires all of the following: explicit reset command, Compose project name match, expected database/service fingerprint, loopback target, typed confirmation or dedicated destructive flag, and a pre-reset evidence snapshot when requested.

Local rebuild is the rollback mechanism. Production backup retention, point-in-time recovery, RTO/RPO, and disaster recovery are customer gates.

## Network and Transport Design

| Host Binding | Container Target | Protocol/Purpose | Exposure Rule |
|---|---|---|---|
| `127.0.0.1:8443` | U1-INF-013 `8443` | HTTPS application/OAuth ingress | Required locally; never bind to all interfaces. |
| `127.0.0.1:1521` | `1522` | Oracle TLS-compatible local mapping used by approved aliases/tools | Required only for host database automation. |
| `127.0.0.1:1522` | `1522` | Oracle mTLS connection using generated wallet | Required for wallet-based verification. |

Port 27017 is not exposed because Mongo API is outside scope. No HTTP port, public load balancer, ingress controller, NAT rule, or cloud API gateway is introduced.

Network controls:

- Docker publishes required ports only to `127.0.0.1`.
- `erp_edge_ingress` is attached only to Nginx so Docker Desktop can implement the loopback host publication; ORDS is absent from that network.
- The edge and ORDS upstream both use HTTPS; tests and proxy configuration never disable certificate verification.
- ORDS port 8443 is private to `erp_backend` and is not published directly to the host.
- Only `oracle-adb` joins `erp_oracle_bootstrap_egress`; it provides first-boot DNS/HTTPS access to Oracle Object Storage but no host or external ingress.
- The copied local CA/wallet is the trust source for Python and database clients.
- CORS contains explicit local development origin values and never uses wildcard origins for authenticated APIs.
- Body, collection, page-size, and rate controls are applied before expensive business processing.
- Database clients use generated TLS/mTLS aliases; plaintext database connections are rejected.
- Outbound remote OIC, Fusion, and AI calls do not exist in UOW-001. Oracle first-boot retrieval of the official ATP PDB is the sole runtime bootstrap-egress exception.

## OAuth2 and Authorization Infrastructure

### Roles and Local Test Clients

| ORDS Role | Local Client Set | UOW-001 Access |
|---|---|---|
| `ERP_REQUESTER` | At least `requester_a` and `requester_b` | Own Draft create/list/detail/update/submit/resubmit/findings/dashboard. |
| `ERP_REVIEWER` | `reviewer_test` | No UOW-001 mutation; later-unit protected projections only. |
| `ERP_SUPPORT_ADMIN` | `support_admin_test` | No Requester mutation; later support/admin endpoints only. |
| `ERP_SYSTEM_OIC` | `system_oic_test` | No Requester workflow access; later callbacks only. |

Each client has a generated secret in U1-INF-006. Privileges bind explicit endpoint patterns to roles and deny all unmatched routes. ORDS function-level privilege is always combined with `ERP_APP` object-owner authorization. Client-supplied actor, role, or owner values are ignored.

Local client credentials are test identities, not a human login solution. Production requires customer SSO/OIDC, MFA and lifecycle policy, trusted claim mapping, session controls, and role governance.

## Migration, Seed, and Contract Infrastructure

### Ordered Execution

1. Preflight validates host architecture, Docker/Compose versions, Docker CPU/memory, FileVault, loopback port availability, ignored local paths, and local-target fingerprint.
2. Secret bootstrap generates compliant values without echoing them.
3. Compose starts U1-INF-003 and waits for container/database/ORDS readiness.
4. Wallet/trust bootstrap copies material from the container and fixes local permissions.
5. Bootstrap creates/validates `ERP_APP` and optional `ERP_VERIFY` with least privilege.
6. Ordered SQL creates the approved tables, relationships, constraints, indexes, packages, and views.
7. ORDS scripts enable the schema and create versioned module/handler/security metadata.
8. Schema and invalid-object gates run before seed.
9. Deterministic seed scripts populate approved representative scenarios.
10. OpenAPI/endpoint parity, role isolation, functional, property, resilience, and performance tests run.
11. Evidence reporter writes checksums, results, versions, digest, schema inventory, and sanitized summaries.

### External Migration Manifest

For every migration the runner records filename, SHA-256 checksum, sequence, start/end UTC timestamps, database fingerprint, result, and sanitized error summary. The manifest is written to U1-INF-009 and never to an application table. A failed migration stops later files and prevents seeding/testing.

### Seed Isolation

- Seed values are deterministic dummy data and include every approved table.
- Full bank account values are prohibited; only masked/tokenized/hash dummy metadata is allowed.
- At least two Requester owners support object-isolation tests.
- Seed and test identifiers are discovered from returned/business keys, not assumed fixed IDs.
- Seed rerun behavior is explicit and tested; clean rebuild remains the authoritative reproducibility path.

## Health, Readiness, and Recovery

| Gate | Verification | Blocks |
|---|---|---|
| Host preflight | ARM64, Docker daemon, Compose v2, CPU/memory, FileVault, free ports, disk space | Image pull/start. |
| Container health | Service running and expected database identity/workload visible | Wallet/bootstrap. |
| Database health | Authenticated TLS/mTLS `SELECT` probe to expected `ERPATP` service | Migrations. |
| Schema health | Expected owner, 18/189/17 inventory, required constraints/indexes, zero invalid application objects | Seed/tests. |
| ORDS health | HTTPS certificate validation, expected base path, token endpoint, protected route returns expected auth result | API tests. |
| OAuth health | Each local role/client receives token and allowed/denied smoke checks match matrix | Full tests. |
| Evidence health | Manifest/report paths writable and secret/redaction checks pass | Completion report. |

Recovery rules:

- A container restart must preserve committed Draft and child records in U1-INF-005.
- A failed migration or seed stops immediately and leaves a complete external failure record.
- A failed UOW-001 transaction rolls back the aggregate and lifecycle changes.
- A blocked submit may commit governed findings but preserves Draft/Correction Requested status according to functional design.
- Reset/rebuild is permitted only against the verified local project and must recreate the same schema inventory.
- No automatic retry is applied to non-idempotent DDL or request mutations.

## Observability and Evidence

| Signal | Minimum Fields | Destination |
|---|---|---|
| ORDS access event | UTC timestamp, trace ID, subject identifier, role, method, route template, status, latency | Docker/ORDS local logs and sanitized test evidence. |
| Security event | UTC timestamp, trace ID, event category, role/client, route, outcome | Redacted local event/report stream. |
| Migration event | Sequence, file, checksum, database fingerprint, duration, result | External migration manifest. |
| Health event | Component, probe, UTC time, status, bounded diagnostic code | Health report. |
| Test event | Suite/case, duration, result, reproducibility seed/profile where applicable | JUnit/JSON/Markdown reports. |
| Performance event | Dataset, host allocation, concurrency, p50/p95/max, errors | Performance report. |

Request/response bodies, supplier PII, bank metadata, tokens, passwords, wallets, and raw stack/database errors are excluded. Local security tests detect repeated authentication/authorization failures and verify event emission. Production centralized, tamper-evident logging, 90-day retention, alert routing, and dashboards remain mandatory customer decisions.

## Capacity and Performance Controls

- Docker preflight requires at least 4 CPUs and 8 GiB; the design does not overcommit additional long-running services.
- Oracle storage remains within the image's documented local limit; the prototype dataset is far below that boundary.
- Lists default to 25 and cap at 100 with deterministic ordering.
- Request bodies cap at 1 MiB; child collections use the approved limits.
- Owner/status/request queries require approved indexes and measured query plans.
- Local API limits are 120 authenticated reads/minute/client and 30 mutations/minute/client.
- Performance evidence uses 100 requests, 500 supplier references, documented warm-up, and the approved p95 targets.
- Ten-client mixed-operation smoke testing verifies error and authorization behavior without claiming production capacity.

## Source and Generated-File Boundary

| Versioned | Generated/Ignored |
|---|---|
| `docker-compose.yml`, `.env.example`, migration/package/seed SQL, ORDS definitions, OpenAPI, scripts, tests, exact dependency metadata | `.env`, `.local/secrets/`, `.local/trust/`, `.local/reports/`, `.venv/`, wallets, certificates, tokens, passwords, resolved temporary files |

Repository secret scanning and explicit ignore assertions must fail the build if protected material is staged or committed.

## Requirement Traceability

| Requirement | Infrastructure Control |
|---|---|
| U1-NFR-PERF-001 | Indexed owner-scoped queries, bounded dataset, host performance harness. |
| U1-NFR-PERF-002 | Single local Oracle service and short transactional package calls. |
| U1-NFR-PERF-003 | Database-local submission checks; no remote dependency. |
| U1-NFR-PERF-004 | Indexed aggregate dashboard query and measured plan. |
| U1-NFR-PERF-005 | ORDS/body and package collection limits. |
| U1-NFR-PERF-006 | ORDS/query pagination guard with default 25 and maximum 100. |
| U1-NFR-PERF-007 | Ten-client host smoke harness and documented Docker allocation. |
| U1-NFR-REL-001 | Local non-production labels and no SLA claim. |
| U1-NFR-REL-002 | Named `oracle_adb_data` volume and restart test. |
| U1-NFR-REL-003 | Automated preflight/bootstrap/migrate/seed/verify lifecycle. |
| U1-NFR-REL-004 | Oracle transactions plus fault-injection test profile. |
| U1-NFR-REL-005 | Database-local blocker handling and status verification. |
| U1-NFR-REL-006 | Conflict checks inside package transaction; concurrent test harness. |
| U1-NFR-REL-007 | Host, container, database, schema, ORDS, OAuth, and evidence gates. |
| U1-NFR-SEC-001 | Oracle storage encryption, FileVault, HTTPS, and TLS/mTLS database bindings. |
| U1-NFR-SEC-002 | Oracle autonomous encrypted storage behavior on encrypted host disk. |
| U1-NFR-SEC-003 | ORDS protected-by-default roles/privileges. |
| U1-NFR-SEC-004 | Two Requester clients plus PL/SQL owner guard and IDOR tests. |
| U1-NFR-SEC-005 | Four explicit ORDS roles and isolated local clients. |
| U1-NFR-SEC-006 | Configuration-driven explicit local CORS origins. |
| U1-NFR-SEC-007 | ORDS/package validation and request-size controls. |
| U1-NFR-SEC-008 | PL/SQL static/bind SQL and adversarial tests. |
| U1-NFR-SEC-009 | Raw-bank rejection, masked/hash-only fixtures, repository/report scans. |
| U1-NFR-SEC-010 | Ignored permission-restricted `.local/` material and secret scan. |
| U1-NFR-SEC-011 | Generated credential bootstrap and preflight rejection of defaults/weak values. |
| U1-NFR-SEC-012 | Central package/ORDS error mapping and redacted logs. |
| U1-NFR-SEC-013 | Token-scoped Nginx read/mutation throttles for deterministic local clients; production identity-aware gateway remains gated. |
| U1-NFR-SEC-014 | Pinned image tag/digest, exact Python dependencies, scan, and CycloneDX SBOM. |
| U1-NFR-SEC-015 | N/A to JSON-only handlers; future HTML delivery remains gated. |
| U1-NFR-OBS-001 | ORDS/package trace IDs in every envelope/event. |
| U1-NFR-OBS-002 | Structured redacted ORDS/container events. |
| U1-NFR-OBS-003 | Transactional `STATUS_HISTORY` package path. |
| U1-NFR-OBS-004 | Authentication, authorization, malformed input, bank rejection, and throttling evidence. |
| U1-NFR-OBS-005 | Health commands, Docker logs, schema checks, and migration diagnostics. |
| U1-NFR-OBS-006 | Local report-cycle retention; production durable retention/alerts remain gated. |
| U1-NFR-MNT-001 | Ordered SQL and external checksum manifest. |
| U1-NFR-MNT-002 | Automated 18/189/17 schema verifier. |
| U1-NFR-MNT-003 | Package-based component boundaries and invalid-object gate. |
| U1-NFR-MNT-004 | Versioned OpenAPI and endpoint parity tests. |
| U1-NFR-MNT-005 | Config-driven identities/rules and generated test IDs. |
| U1-NFR-MNT-006 | Single-purpose lifecycle scripts and documented aggregate commands. |
| U1-NFR-MNT-007 | Local fingerprint-protected reset/rebuild. |
| U1-NFR-USE-001 | Stable API envelope, trace ID, and field-safe error tests. |
| U1-NFR-USE-002 | Draft package endpoint allows incomplete submit-required fields. |
| U1-NFR-USE-003 | Role-safe projection package and contract tests. |
| U1-NFR-USE-004 | N/A to backend infrastructure; future UI accessibility gate retained. |
| U1-NFR-TST-001 | Business-rule-to-test matrix in host test infrastructure. |
| U1-NFR-TST-002 | OpenAPI and all UOW-001 endpoint contract tests. |
| U1-NFR-TST-003 | Separate example and Hypothesis suites. |
| U1-NFR-TST-004 | Hypothesis shrinking and seed/profile evidence. |
| U1-NFR-TST-005 | Central reusable domain strategy module. |
| U1-NFR-TST-006 | Clean-reset and returned-identifier test isolation. |
| U1-NFR-TST-007 | Schema, OpenAPI, secret, vulnerability, SBOM, and authorization gates. |

## Enabled Extension Compliance

### Security Baseline

| Rule | Status | Infrastructure Mapping |
|---|---|---|
| SECURITY-01 | Compliant for local scope | Oracle/FileVault encryption and HTTPS/TLS/mTLS are mandatory. Production key policy remains a customer gate. |
| SECURITY-02 | Compliant for local scope | The ORDS network intermediary emits structured access events to local Docker/ORDS logs and sanitized evidence. |
| SECURITY-03 | Compliant for local scope | Package/ORDS/health diagnostics are structured, correlated, and redacted. Production centralized logging remains gated. |
| SECURITY-04 | N/A | UOW-001 serves JSON only; future HTML security headers remain gated. |
| SECURITY-05 | Compliant | ORDS/body controls and typed, allowlisted PL/SQL validation cover all API parameters. |
| SECURITY-06 | Compliant | `ADMIN`, `ERP_APP`, optional `ERP_VERIFY`, ORDS roles, and package/table grants are least privilege. |
| SECURITY-07 | Compliant | Required ports bind only to loopback; no public interface, public ingress, or unused Mongo port is exposed. |
| SECURITY-08 | Compliant | ORDS authentication/privileges and PL/SQL object ownership are both mandatory; CORS is allowlisted. |
| SECURITY-09 | Compliant | Setup rejects defaults/weak credentials, handlers return safe errors, and unused exposed services are omitted. |
| SECURITY-10 | Compliant | Exact image tag/digest, exact Python versions, scans, trusted registries, and SBOM are required. |
| SECURITY-11 | Compliant | Authentication, authorization, validation, encryption, throttling, and misuse controls are separated and layered. |
| SECURITY-12 | Compliant for local OAuth scope | Generated client/database secrets remain outside Git. Human password login/session/MFA are not implemented; production SSO/MFA remains gated. |
| SECURITY-13 | Compliant | Typed JSON handling, migration checksums, image digest, controlled source, and lifecycle audit are defined. |
| SECURITY-14 | Compliant for local scope | Security event evidence is tested; production tamper-evident retention/alerts/dashboard remain an explicit gate. |
| SECURITY-15 | Compliant | Fail-fast health/migration behavior, rollback, safe errors, and cleanup are defined. |

### Resiliency Baseline

| Rule | Status | Infrastructure Mapping |
|---|---|---|
| RESILIENCY-01 | Compliant | UOW-001 is classified as a medium-criticality non-production prototype. |
| RESILIENCY-02 | Compliant | Local performance/recovery targets are measurable; no production SLA/RTO/RPO is claimed. |
| RESILIENCY-03 | Compliant | Ordered checksummed migrations, source review, and approval gates define controlled change. |
| RESILIENCY-04 | Compliant for local scope | Bootstrap/migrate/seed/verify/reset are automated; clean rebuild is the local rollback path. |
| RESILIENCY-05 | Compliant for local scope | Health/security failures block progression and produce local evidence; production alert routing remains gated. |
| RESILIENCY-06 | Compliant | Host, container, database, schema, ORDS, OAuth, and evidence health gates are explicit. |
| RESILIENCY-07 | Compliant | Trace, access, health, migration, test, and performance signals are defined. |
| RESILIENCY-08 | N/A to fixed local prototype | Multi-zone/region deployment requires a separately approved production design. |
| RESILIENCY-09 | N/A to fixed local prototype | The local runtime has fixed capacity; production scaling remains a customer gate. |
| RESILIENCY-10 | Compliant | UOW-001 has no remote runtime dependency; one local Oracle transaction boundary is used. |
| RESILIENCY-11 | N/A to local prototype | Production DR requires customer RTO/RPO and topology decisions. |
| RESILIENCY-12 | Compliant for local scope | Named-volume restart persistence is tested; production backup/replication remains gated. |
| RESILIENCY-13 | Compliant for local scope | Restart, health re-entry, and clean rebuild procedures are defined and testable. |
| RESILIENCY-14 | Compliant for local scope | Transaction fault injection and restart/rebuild tests are defined; production chaos/DR exercises remain gated. |
| RESILIENCY-15 | Compliant for local scope | Failures preserve diagnostics, stop dependents, and require a verified corrective rerun. |

### Partial Property-Based Testing

| Rule | Status | Infrastructure Mapping |
|---|---|---|
| PBT-02 | Compliant | Host Hypothesis environment supports write/read and serialization round trips. |
| PBT-03 | Compliant | Infrastructure exposes isolated API/database seams for ownership, status, bounds, and projection invariants. |
| PBT-07 | Compliant | Central reusable domain-strategy location is included in test infrastructure. |
| PBT-08 | Compliant | Reports capture shrinking output and replayable seed/profile information. |
| PBT-09 | Compliant | Python 3.13, pytest, and Hypothesis are selected and host-available. |

No applicable enabled-extension blocking finding remains at UOW-001 Infrastructure Design.

## Production Decision Gates

Before production, the customer must approve Oracle Cloud ATP tenancy/region/edition, private endpoint/VCN topology, key management, backup and restore, RTO/RPO/DR, OIC/Fusion connectivity, production identity and MFA, secrets manager, WAF/API gateway/load balancing, centralized logs/metrics/alerts, 90-day or regulatory retention, capacity/scaling, patch/change process, and compliance classification.

The local design is a construction and test environment. It must not be represented as production-ready infrastructure.
