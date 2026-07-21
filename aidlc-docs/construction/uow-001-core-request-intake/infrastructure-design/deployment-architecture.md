# UOW-001 Deployment Architecture

## Architecture Context

UOW-001 uses one local autonomous database container with bundled ORDS. Browser/mock clients and the automated test harness reach ORDS through loopback HTTPS. Migration and verification tools reach Oracle through loopback TLS/mTLS. Application behavior executes in `ERP_APP` PL/SQL packages and the finalized Oracle tables.

This is a local deployment architecture, not a production cloud topology.

## Topology Model

| Layer | Components | Boundary |
|---|---|---|
| Local clients | Static wireframe/browser inspection, API test clients, Python migration/test/report commands | Untrusted request and operator-input boundary. |
| Host controls | Docker Compose, generated-secret bootstrap, trust store, `.venv`, lifecycle scripts, local reports | Developer-machine control plane; destructive commands require local target verification. |
| Container boundary | `oracle-adb` autonomous ATP-mode database plus bundled ORDS/APEX/Database Actions | Isolated Docker process with only explicit loopback-published ports. |
| ORDS security boundary | HTTPS listener, OAuth2 token handling, roles, privileges, route/body controls | Authenticates and performs function-level authorization before PL/SQL. |
| Application boundary | `ERP_APP` API, authorization, workflow, projection, and utility packages | Enforces object ownership, validation, transactions, and safe envelopes. |
| Data boundary | Approved 18 application tables, constraints, indexes, and status/evidence rows | Oracle-encrypted persistent state in named volume. |
| Evidence boundary | Redacted Docker/ORDS logs and ignored migration/test/scan/report files | Operational evidence only; no secrets or protected payloads. |

### Textual Deployment View

1. A local client connects to `https://127.0.0.1:8443` and validates the generated local certificate authority.
2. Bundled ORDS validates OAuth2 credentials and endpoint privileges.
3. Thin ORDS handlers derive the trusted principal and invoke `ERP_APP` package procedures/functions.
4. PL/SQL performs object authorization and accesses only the approved Oracle application objects.
5. Oracle commits or rolls back the complete aggregate transaction and retains committed state in `oracle_adb_data`.
6. ORDS returns a role-safe envelope and emits redacted access metadata.
7. Host test/report tools collect schema, API, security, recovery, performance, and supply-chain evidence into `.local/reports/`.

No request crosses a public network, message broker, cache, remote AI service, OIC endpoint, or Fusion endpoint in UOW-001.

## Deployment Units

| Unit | Type | Lifecycle | Version/Identity |
|---|---|---|---|
| Oracle ADB Free image | OCI container image | Pull once, start/stop/recreate through Compose | Exact `26.2.4.2-26ai` tag plus resolved digest. |
| Compose definition | Versioned configuration | Validated before every startup | Repository commit and Compose config hash. |
| Database migrations | Ordered SQL/PLSQL | Applied after DB readiness; fail-fast | Sequence plus SHA-256 in external manifest. |
| ORDS definitions | SQL/PLSQL metadata definitions | Applied after packages and before API tests | Versioned base path and endpoint inventory. |
| OpenAPI contract | Versioned YAML/JSON | Validated against handler catalog | OpenAPI 3.0.3 document checksum. |
| Seed data | Ordered deterministic scripts | Applied only after schema validity | Seed-set version/checksum. |
| Python tooling | Host virtual environment | Recreated from exact dependency metadata | Python 3.13 plus pinned package versions/hashes. |
| Test/evidence run | Bounded host process | Runs after all health gates | Test run ID, timestamp, Git commit, image digest, Hypothesis profile/seed. |

## Resource Dependency Order

| Order | Resource/Action | Required Predecessor | Success Condition |
|---:|---|---|---|
| 1 | Host preflight | Clean checkout | Architecture, Docker daemon, Compose, CPU/memory, FileVault, ports, paths pass. |
| 2 | Local secret generation | Preflight | Strong ignored files exist with owner-only permissions. |
| 3 | Image resolution | Preflight | Exact tag resolves; digest is captured and approved scanner can inspect it. |
| 4 | Network/volume/service creation | Secrets and image | Compose project resources exist under expected names. |
| 5 | Database startup | Service creation | Expected ATP database is queryable over TLS/mTLS. |
| 6 | Trust bootstrap | Database startup | Wallet/CA material copied locally and certificate verification passes. |
| 7 | Schema bootstrap/migrations | Database health | Ordered manifest succeeds; zero invalid application objects. |
| 8 | ORDS configuration | Required packages | Protected base path and token/role checks pass over HTTPS. |
| 9 | Schema parity | Migrations | Exact 18 tables, 189 columns, and 17 physical foreign keys. |
| 10 | Seed | Schema parity | Every approved table has representative, referentially valid dummy data. |
| 11 | Full verification | Seed and OAuth health | Contract, behavior, security, recovery, PBT, and performance gates pass. |
| 12 | Evidence/report generation | Verification | Redacted manifest and consolidated result set are complete. |

A failed step stops all dependent steps. Rerun begins from a verified state; it never silently skips a failed prerequisite.

## Runtime Request Paths

### Create or Update Draft

| Hop | Control | Failure Behavior |
|---|---|---|
| Client to ORDS HTTPS | Certificate validation, OAuth token, media/body/rate controls | 401/403/413/429 or safe 400 before business processing. |
| ORDS to API package | Endpoint privilege, trusted principal adapter, allowlisted JSON mapping | Safe failure envelope; no dynamic SQL. |
| API package to request package | Requester role, owner, editable status, expected update timestamp | 403/404/409 with no unauthorized mutation. |
| Request package to Oracle tables | One short aggregate transaction and constraints | Complete rollback on error. |
| Projection to response | Allowlisted Requester fields and trace ID | Internal evidence and technical detail remain absent. |

### Submit or Resubmit

| Hop | Control | Failure Behavior |
|---|---|---|
| ORDS boundary | Same transport/auth/rate/body controls as mutation | No transaction on boundary rejection. |
| Authorization package | Owner and Draft/Correction Requested status | Denied or conflict response; no change. |
| Submission package | Stable aggregate load and database-local governed check interface | Exact tax/same bank blockers return 422 and preserve editable status. |
| Successful transition | Status/history written atomically | Rollback if either status or history fails. |
| Response projection | Safe findings/status/next action only | No score, matched-field evidence, or Reviewer-only reason leakage. |

### List, Detail, Findings, and Dashboard

| Hop | Control | Failure Behavior |
|---|---|---|
| ORDS/query parameters | Type, length, page, size, sort, filter allowlist | Safe 400 for invalid input. |
| Query package | Mandatory Requester subject predicate and role-safe view/projection | Cross-owner data is structurally excluded. |
| Oracle query | Approved index path and bounded result set | Diagnostic trace is internal; user sees safe error. |

## Trust Boundaries and Threat Controls

| Boundary | Primary Threats | Controls | Verification |
|---|---|---|---|
| Local client to ORDS | Token theft, malformed JSON, replay/abuse, oversized input | HTTPS, external secrets, OAuth2, throttles, body/schema limits | Contract and security tests. |
| ORDS route to package | Function-level bypass, forged actor/role, injection | Explicit privileges, server-derived principal, typed package calls, bind/static SQL | Wrong-role and adversarial tests. |
| Principal to object | IDOR/cross-owner access | PL/SQL owner predicate on every resource method | Two-Requester generated isolation tests. |
| Package to database | Partial writes, invalid transitions, mass assignment | Transactions, constraints, allowlists, locks/conflict check | Fault-injection and lifecycle tests. |
| Database to local volume | Data loss or at-rest exposure | Named volume, Oracle encryption, FileVault, explicit reset guard | Restart persistence and preflight. |
| Runtime to logs/reports | Secret/PII leakage, evidence tampering | Redaction allowlist, ignored local paths, checksums, no body logs | Secret/redaction scans. |
| Operator to destructive automation | Wrong target or accidental volume deletion | Loopback/database fingerprint, Compose project check, explicit destructive flag | Negative reset tests. |

## Network Policy

### Published Ports

| Host | Container | Consumer | Policy |
|---|---:|---|---|
| `127.0.0.1:8443` | 8443 | Browser and HTTPS test clients | ORDS HTTPS only; certificate verification required. |
| `127.0.0.1:1521` | 1522 | TLS-capable database tooling according to generated aliases | Local automation only. |
| `127.0.0.1:1522` | 1522 | mTLS database tooling | Wallet required; local automation only. |

The design intentionally omits public interface bindings, port 27017, port 80, SSH, a reverse proxy, a load balancer, and an externally reachable Docker network.

### CORS and API Base

- Versioned base path: `/ords/erp/supplier-onboarding/v1`.
- CORS accepts only configured local wireframe/application origins.
- Command-line tests can omit browser CORS headers but still require OAuth2.
- Preflight behavior is contract-tested; authenticated wildcard origin is prohibited.
- Database Actions/APEX paths are not part of the application endpoint contract.

### UOW-001 ORDS Deployment Catalog

| Method | Relative Path | ORDS Role | Database Authorization |
|---|---|---|---|
| POST | `/requests` | `ERP_REQUESTER` | Requester role; server derives owner. |
| GET | `/requests` | `ERP_REQUESTER` | Mandatory owner scope plus bounded filters/page. |
| GET | `/requests/{requestId}` | `ERP_REQUESTER` | Owner check and Requester-safe projection. |
| PATCH | `/requests/{requestId}` | `ERP_REQUESTER` | Owner, Draft/Correction Requested, and conflict check. |
| POST | `/requests/{requestId}/submit` | `ERP_REQUESTER` | Owner, editable status, and governed submit orchestration. |
| GET | `/requests/{requestId}/validation-results` | `ERP_REQUESTER` | Owner and Requester-safe correctable findings only. |
| GET | `/requests/{requestId}/attachments` | `ERP_REQUESTER` | Owner and metadata-only projection. |
| POST | `/requests/{requestId}/attachment-metadata` | `ERP_REQUESTER` | Owner and editable status; no file-byte or raw bank storage. |
| GET | `/dashboard/requester-summary` | `ERP_REQUESTER` | Counts scoped to authenticated owner. |
| GET | `/reference/business-units` | `ERP_REQUESTER` | Active governed lookup values only. |
| GET | `/reference/supplier-types` | `ERP_REQUESTER` | Active governed lookup values only. |

The OpenAPI/ORDS parity gate requires exactly these 11 UOW-001 method/path contracts. Validation execution, duplicate/risk/AI operations, Reviewer decisions, support endpoints, admin maintenance, and System/OIC callbacks belong to later units even when their shared database objects are present.

## Identity and Privilege Deployment

### Layered Authorization

1. ORDS token validation identifies a local OAuth2 client.
2. ORDS privilege maps the endpoint template to an allowed role.
3. Principal Adapter derives subject and role context from ORDS runtime state.
4. PL/SQL Authorization Guard verifies function, object owner, and lifecycle status.
5. Query/Projection packages enforce field-level disclosure.

No UI state or client-supplied role/owner/status can replace these controls.

### Privilege Deployment Order

1. Create deterministic role names.
2. Create privileges with explicit module/template patterns.
3. Associate only the required roles with each privilege.
4. Create separate generated-secret clients for Requester A, Requester B, Reviewer, Support/Admin, and System/OIC.
5. Grant each client only its intended role.
6. Run unauthenticated, wrong-role, cross-owner, and allowed-role smoke tests.
7. Export a sanitized privilege/client inventory without client secrets.

## Storage and State Architecture

| State | Source of Truth | Recovery Method |
|---|---|---|
| Application requests/evidence/config/reference data | Oracle tables in named volume | Ordinary restart; local clean rebuild from migrations/seeds if reset. |
| PL/SQL/views/ORDS metadata | Versioned source plus database objects | Reapply ordered definitions to a clean environment. |
| Migration state | External checksummed manifest plus database inventory | Compare manifest and schema; clean rebuild on drift. |
| OAuth2 clients/privileges | Versioned definitions plus generated local secrets/ORDS metadata | Recreate from definitions and regenerate secrets. |
| Wallet/certificates | Container-generated source and ignored local copies | Recopy/regenerate; never recover from Git. |
| Test evidence | Ignored reports with sanitized promoted summaries | Rerun deterministic build/test pipeline. |

There is no cache state and no message state to reconcile.

## Environment Profiles

| Profile | Database State | Credentials | Allowed Operations |
|---|---|---|---|
| `local-dev` | Persistent developer seed/scenarios | Generated local credentials | Start, migrate, seed, inspect, targeted tests. |
| `local-test` | Clean deterministic reset/rebuild | Separate generated local test credentials where practical | Full destructive reset, full suite, reports. |
| `production` | Not implemented | None in repository | Rejected by local scripts; requires a separately approved cloud design. |

Every mutating script validates the profile and database fingerprint. The mere presence of environment variables is not sufficient proof of a safe target.

## Health and Startup State Model

| State | Entry Condition | Allowed Next State |
|---|---|---|
| `HOST_BLOCKED` | Docker unavailable, insufficient resources, disk encryption off, ports occupied, or unsafe paths | `HOST_READY` after corrective action. |
| `HOST_READY` | Preflight passes | `CONTAINER_STARTING`. |
| `CONTAINER_STARTING` | Compose service created | `DATABASE_READY` or `FAILED`. |
| `DATABASE_READY` | Expected ATP identity responds over TLS/mTLS | `SCHEMA_READY`. |
| `SCHEMA_READY` | Migrations and parity/validity checks pass | `ORDS_READY`. |
| `ORDS_READY` | HTTPS/token/protected-route probes pass | `SEEDED`. |
| `SEEDED` | Every approved table has valid representative data | `VERIFIED`. |
| `VERIFIED` | Required test/scan/report gates pass | Reviewable local implementation. |
| `FAILED` | Any bounded stage fails | Correct cause, then rerun from a verified prerequisite or clean reset. |

Health scripts use bounded timeouts and meaningful exit codes. They do not wait forever or treat a running container process as proof that the database and ORDS are ready.

## Failure Domains and Recovery

| Failure Domain | Blast Radius | Recovery/Containment |
|---|---|---|
| Docker daemon stopped | Entire local runtime unavailable | Restart Docker; preserve named volume; rerun health. |
| Oracle process/container restart | Database/ORDS temporarily unavailable | Compose restart; wait for database and HTTPS health; verify committed Draft. |
| Named-volume corruption/deletion | Local database state lost | Explicit clean rebuild from migrations/seed; record loss. No production recovery claim. |
| Invalid migration/package | Schema stage blocked | Stop before seed; inspect manifest/error; correct source; clean rebuild. |
| ORDS privilege error | Affected API unavailable/overexposed | Deny-by-default tests block completion; correct metadata and rerun full authorization suite. |
| Local certificate/wallet drift | Client connections fail closed | Recopy/regenerate trust material; never disable verification. |
| Secret exposure in source/report | Security gate failure | Stop, remove artifact, rotate generated local secret, rescan. |
| Test/PBT failure | Completion blocked | Preserve seed/shrunk example, fix, rerun required suites. |
| Insufficient Docker memory | Image startup unsupported/unreliable | Preflight blocks startup until allocation is at least 8 GiB. |

## Observability Deployment

| Source | Collection | Local Review |
|---|---|---|
| Docker service | `docker compose logs` through bounded diagnostic wrapper | Startup/crash/ORDS diagnostics with secret filtering. |
| ORDS access/security | Structured access fields and safe event categories | Authorization/rate/error test evidence. |
| Oracle schema/packages | Health SQL, invalid-object query, business audit tables where approved | Schema and transaction reports. |
| Migration runner | External checksummed JSON/log manifest | Migration summary and reproducibility evidence. |
| pytest/Hypothesis | JUnit XML, test log, seed/profile, shrunk failures | Build/test and property reports. |
| Security/supply chain tools | Secret/vulnerability scan and CycloneDX JSON | Blocking gate and implementation report. |
| Performance harness | JSON/CSV measurements and sanitized Markdown | p95 target review with host/dataset context. |

Application code cannot use report/log infrastructure to authorize requests or determine business outcomes.

## Deployment Validation Gates

| Gate | Required Evidence |
|---|---|
| Compose validation | Resolved config contains pinned image reference, loopback bindings, required volume, no plaintext secrets, and no unexpected service. |
| Image integrity | Exact release tag, resolved digest, architecture, and vulnerability result recorded. |
| Secret hygiene | Git ignore assertion, permission check, secret scan, no credential in Compose config/report. |
| Schema parity | 18 tables, 189 columns, 17 FKs, expected constraints/indexes, zero invalid application objects. |
| ORDS parity | Implemented method/path/security inventory equals approved UOW-001/OpenAPI scope. |
| Authorization | 401 unauthenticated, 403 wrong-role, no cross-owner data, allowed paths succeed. |
| Recovery | Draft survives restart; clean rebuild returns same schema/seed contract. |
| Performance | Approved p95/concurrency measurements with host allocation and dataset. |
| Evidence | All manifests and reports are complete, redacted, and tied to Git/image/schema identities. |

## Local-to-Production Mapping

| Local Component | Future Production Equivalent | Required Customer Decision |
|---|---|---|
| ADB Free ATP-mode container | Oracle Cloud Autonomous Transaction Processing | Tenancy, region, edition, sizing, private endpoint, maintenance. |
| Docker named volume | Managed ATP storage/backups | Retention, restore tests, RPO/RTO, DR region. |
| Bundled ORDS | Managed or approved ORDS deployment | Network, scaling, HA, patching, certificates, WAF/API gateway. |
| Local ORDS OAuth clients | Customer identity provider/SSO/OIDC | Claims, role mapping, MFA, sessions, joiner/mover/leaver process. |
| Local generated secret files | Customer secrets manager | Ownership, rotation, access policy, audit. |
| Docker/ORDS local logs | Central logging/SIEM/APM | Retention, tamper evidence, alert routing, dashboards, incident process. |
| Local host test runner | CI/CD runners and deployment approvals | Pipeline platform, environments, separation of duties, artifact signing. |
| Local deterministic mocks | OIC, Fusion, and approved AI services | Endpoints, credentials, payload mapping, network, retry/SLA policy. |

Production is a separate infrastructure approval exercise. Local definitions must not contain assumptions that silently activate against customer systems.

## Implementation Handoff

The approved Code Generation plan must translate this architecture into:

- A validated `docker-compose.yml` and `.env.example` with no real secrets.
- Preflight, secret bootstrap, start, health, migration, seed, verify, test, report, stop, and protected reset commands.
- Exact SQL/PLSQL and ORDS source with external migration checksums.
- OpenAPI 3.0.3 and endpoint/security parity tests.
- Pinned Python dependencies, secret/vulnerability scanning, and CycloneDX generation.
- Automated verification of all gates in this document.

No runtime resource has been created by this design stage.
