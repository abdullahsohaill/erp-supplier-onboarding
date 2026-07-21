# UOW-001 Logical Components

## Component Model

| ID | Logical Component | Responsibility | Trust/Transaction Notes |
|---|---|---|---|
| U1-LC-001 | ORDS HTTPS Gateway | Terminate HTTPS, route versioned endpoints, enforce media/body controls, emit access status. | External trust boundary. |
| U1-LC-002 | OAuth2 Token Validator | Validate token and resolve local client identity/roles. | Deny by default. |
| U1-LC-003 | Endpoint Privilege Guard | Map route patterns to Requester/Reviewer/Support/System roles. | Function-level authorization only; not sufficient for ownership. |
| U1-LC-004 | Principal Adapter | Derive trusted subject and role context from ORDS runtime state. | Never reads actor/owner from payload. |
| U1-LC-005 | Rate and Size Guard | Enforce rate, body, page, and collection limits. | Reject before business processing. |
| U1-LC-006 | Request Input Mapper | Parse allowlisted JSON into domain commands and validate types/bounds. | No dynamic SQL; unknown fields rejected. |
| U1-LC-007 | Request Authorization Guard | Verify Requester role, object ownership, and allowed lifecycle operation. | Runs inside PL/SQL service boundary. |
| U1-LC-008 | Request Command Service | Create Draft and update editable aggregate. | Owns short Oracle transaction. |
| U1-LC-009 | Submission Orchestrator | Run governed UOW-002 checks and apply blocked/success state semantics. | Database-local; one short transaction for successful transition. |
| U1-LC-010 | Request Query Service | List/detail/dashboard and safe findings queries. | Owner filter is mandatory for Requester scope. |
| U1-LC-011 | Requester Projection Policy | Build allowlisted summaries/details and safe guidance. | Structurally excludes internal evidence. |
| U1-LC-012 | Request Aggregate Repository | Persist header, sites, contacts, optional bank/document metadata. | Finalized core tables only. |
| U1-LC-013 | Status History Writer | Append create/submit/resubmit lifecycle actions. | Append-only; atomic with status changes. |
| U1-LC-014 | Governed Check Port | Interface to UOW-002 validation, duplicate, and risk processing. | No remote call; implementation arrives with UOW-002. |
| U1-LC-015 | Envelope and Error Mapper | Produce stable success/error JSON and trace ID. | Redacts internal errors. |
| U1-LC-016 | Structured Redacted Logger | Emit safe access/security/health events. | No request bodies, PII, bank data, tokens, or secrets. |
| U1-LC-017 | Health Gate | Verify database, application objects, ORDS HTTPS, and OAuth readiness. | Blocks dependent automation on failure. |
| U1-LC-018 | Migration Runner | Execute ordered SQL and external checksum/result manifest. | Destructive operations require explicit local guard. |
| U1-LC-019 | Schema Verifier | Compare tables/columns/relationships and invalid objects to approved design. | Read-only metadata inspection. |
| U1-LC-020 | Automated Test Harness | Run example, property, database, API, security, recovery, and performance tests. | Uses isolated dummy users/data. |
| U1-LC-021 | Evidence Reporter | Consolidate JUnit, PBT replay, schema, migration, scan, SBOM, and performance evidence. | Redacts secrets and protected data. |

## Trust Boundaries

| Boundary | Untrusted Side | Trusted Side | Required Controls |
|---|---|---|---|
| Client to ORDS | Browser/test client and all payload fields | Authenticated ORDS request context | TLS, OAuth2, CORS allowlist, rate/body limits, media/JSON validation. |
| ORDS handler to PL/SQL | Route/path/body values | Package API | Bind/static SQL, input mapper, trusted principal adapter, safe errors. |
| Principal to request object | Authenticated subject with guessed/requested ID | Owner-authorized aggregate | Role plus object-level ownership check. |
| Command service to ATP | Validated command | Oracle transaction | Least-privilege execute/grants, constraints, rollback. |
| Logs/reports | Runtime data and failures | Redacted evidence | Field allowlist, no bodies/secrets/PII, retention policy. |
| Local automation to database | Environment configuration | Destructive migration/reset runner | Explicit local profile, target verification, opt-in reset. |

## Component Interfaces

### Principal Context

| Field | Source | Rule |
|---|---|---|
| Subject | ORDS authenticated identity/client | Required; normalized stable identifier. |
| Roles | ORDS token/privilege context | Server-derived set. |
| Trace ID | ORDS request context | Validated bounded operational identifier. |

### Request Command Interface

| Operation | Input | Output |
|---|---|---|
| Create Draft | Principal plus partial allowlisted aggregate | Requester-safe Draft detail and HTTP 201. |
| Update Request | Principal, request ID, partial/complete mutation, expected update time | Updated Requester-safe detail. |
| Submit/Resubmit | Principal plus request ID | Under Review success or HTTP 422 safe findings with editable status retained. |
| Maintain Document Metadata | Principal, request ID, metadata command | Updated safe metadata collection. |

### Request Query Interface

| Operation | Input | Output |
|---|---|---|
| List Own Requests | Principal, filters, page, size, sort | Owner-scoped summaries. |
| Get Own Request | Principal, request ID | Role-safe aggregate, timeline, guidance, final outcome. |
| Get Safe Findings | Principal, request ID | Requester-correctable validation findings only. |
| Get Own Dashboard | Principal | Owner-scoped counts. |
| Get Reference Lookup | Principal, lookup filters | Active business units/supplier types. |

### Governed Check Port

| Operation | Responsibility |
|---|---|
| Validate Aggregate | Return governed blocking/warning findings tied to active rule identifiers. |
| Detect Duplicates | Persist current candidates and identify active critical triggers. |
| Calculate Risk | Persist current deterministic risk evidence for Reviewer use. |
| Build Requester Findings | Translate only approved blocker/warning guidance into the safe contract. |

UOW-001 depends on the interface semantics. UOW-002 owns algorithms and evidence persistence.

## Create Draft Flow

1. ORDS Gateway accepts HTTPS POST and applies token, privilege, rate, body, and JSON controls.
2. Principal Adapter derives subject/roles; Input Mapper creates a partial Draft command.
3. Authorization Guard confirms Requester role.
4. Command Service starts a short transaction.
5. Repository creates header/children and derives owner, request number, timestamps, and normalized fields.
6. Status History Writer appends Draft creation.
7. Transaction commits.
8. Projection Policy builds a Requester-safe detail.
9. Envelope Mapper returns HTTP 201 with trace ID; Logger records safe access metadata.

Any failure before commit rolls back the complete aggregate.

## Update Flow

1. Gateway and guards validate request and principal.
2. Authorization Guard resolves the row by request ID and owner and checks Draft/Correction Requested.
3. Command Service locks/checks expected `last_updated_at`.
4. Input Mapper and aggregate rules validate writable fields and child ownership.
5. Repository applies all changes in one transaction and updates `last_updated_at`.
6. No status history is written for ordinary edits.
7. Commit, safe projection, envelope, and redacted event complete the request.

Stale state returns 409 without mutation.

## Submit/Resubmit Flow

1. Gateway authenticates and applies Requester privilege, rate, and size controls.
2. Authorization Guard verifies owner and Draft/Correction Requested status.
3. Submission Orchestrator locks the request and loads one aggregate snapshot.
4. Governed Check Port runs validation, duplicate detection, and risk calculation.
5. On blocker:
   - Persist current governed findings according to UOW-002 semantics.
   - Keep Draft or Correction Requested.
   - Do not append lifecycle history.
   - Return HTTP 422 safe findings.
6. Without blocker:
   - Append Submitted history.
   - Set submitted timestamp.
   - Append automatic route-to-review history.
   - Set final status Under Review.
   - Commit outputs and lifecycle changes atomically.
7. Projection/Envelope returns only status, safe warnings, and next action.

No OIC, Fusion, or AI network call occurs in this flow.

## Read Flow

1. Gateway validates token/privilege and bounded filters/pagination.
2. Query Service always includes Requester subject in the data predicate.
3. Repository executes index-aligned set queries.
4. Projection Policy builds the exact role-safe shape.
5. Envelope and Logger return/record operational metadata without body content.

The projection is allowlisted at construction time; forbidden evidence cannot appear because it has no output field mapping.

## Failure and Recovery Matrix

| Failure Point | Component Response | Data Result | Client Result |
|---|---|---|---|
| Invalid/oversized input | Gateway/Input Mapper rejects | No transaction | 400 or 413 policy mapping. |
| Missing/invalid token | Token Validator rejects | No transaction | 401. |
| Wrong role/non-owner | Privilege/Authorization Guard rejects | No transaction | 403/404 policy response. |
| Stale update | Command Service rejects | No mutation | 409. |
| Governed blocker | Submission Orchestrator commits current findings only | Editable status preserved | 422 safe findings. |
| Database error before commit | Oracle rolls back | Prior aggregate unchanged | 500 safe envelope. |
| Audit/history error | Oracle rolls back successful transition | Prior status unchanged | 500 safe envelope. |
| ORDS unavailable | Health Gate blocks dependent run | Committed DB state retained | Service unavailable outside API. |
| Container restart | Named volume reloads database | Committed state retained | Health wait before API use. |

## Logical Data Ownership

| Data | Owner Component | Physical Location |
|---|---|---|
| Request header/sites/contacts/bank/documents | Request Aggregate Repository | Approved core request tables. |
| Lifecycle events | Status History Writer | `STATUS_HISTORY`. |
| Validation/duplicate/risk evidence | UOW-002 components | Approved evidence tables. |
| Requester-safe projection | Requester Projection Policy | Derived at read time; no new table. |
| Trace/access/security events | Structured Logger/runtime | Operational logs; no new application column/table. |
| Migration history/checksums | Migration Runner | External local report/manifest; no application table. |

## Dependency Direction

| From | Depends On | Reason |
|---|---|---|
| ORDS handlers | Principal Adapter, Input Mapper, command/query interfaces, Envelope Mapper | Thin transport adapter. |
| Command Service | Authorization Guard, Repository, Status Writer | Aggregate mutation. |
| Submission Orchestrator | Authorization Guard, Repository, Governed Check Port, Status Writer | Business handoff. |
| Query Service | Authorization Guard, Repository, Projection Policy | Safe role-specific reads. |
| Projection Policy | Domain/read values only | Must not call external systems or mutate state. |
| Test Harness | Public/package interfaces, health, schema verifier | Verify behavior without production shortcuts. |

Business services do not depend on the test harness, reports, Docker commands, or client/UI code.

## Performance Design Checks

- Query owner/status/request predicates match approved indexes.
- Pagination is always bounded and deterministically sorted.
- Detail child queries are set-based and bounded by request ID.
- Dashboard counts are calculated in one aggregate query per role projection where practical.
- Create/update use one transaction and avoid per-field round trips.
- Submit loads one stable aggregate snapshot and invokes each governed engine once per run.
- Performance reports include warm-up, dataset size, concurrency, p50/p95/max, errors, and host allocation.

## Security Design Checks

- ORDS privilege and PL/SQL ownership controls are both present.
- Database object grants do not permit OAuth clients/direct callers to bypass packages.
- No request/response body logging.
- No default secrets or committed trust material.
- CORS never uses wildcard on authenticated endpoints.
- Raw bank input and server-managed field mass assignment are rejected.
- Safe errors contain a trace ID but no system detail.
- Reset/migration scripts refuse non-local destructive targets.

## Test Seams

| Seam | Test Technique |
|---|---|
| Principal Adapter | Inject known local OAuth clients and compare derived subjects/roles. |
| Authorization Guard | Generate owner/non-owner pairs and role combinations. |
| Input Mapper | Schema examples plus Hypothesis boundaries/unknown fields. |
| Projection Policy | Forbidden-field invariant and approved-field round trip. |
| Command Service | Database integration and injected transaction failures. |
| Submission Orchestrator | Stub/controlled UOW-002 result sets for blocker/warning/success; later full integration. |
| Migration/Schema Verifier | Clean rebuild, checksum, 18/189/17 inventory, invalid-object query. |
| ORDS boundary | OAuth, CORS, rate, body, media, path, envelope, and latency tests. |

## Infrastructure Mapping Boundary

This artifact defines logical components only. UOW-001 Infrastructure Design will map them to the Docker Compose services, Oracle autonomous container, ORDS schemas/modules, wallets/certificates, named volumes, ports, health commands, local secret files, test runner, report directories, and future production Oracle services.

No unsupported application table or column is introduced by this component model.
