# UOW-001 NFR Design Patterns

## Design Posture

UOW-001 is a synchronous, database-local request-intake unit. ORDS provides the authenticated REST boundary and PL/SQL owns business authorization, aggregate mutation, transaction control, projections, and audit persistence. The design favors simple, testable patterns appropriate to 50-100 requests and a few hundred reference suppliers.

No cache, queue, circuit breaker, distributed transaction, or external retry loop is introduced. Those patterns would add failure modes without helping the approved UOW-001 workload. OIC, Fusion, and AI dependency patterns belong to later units.

## Security Patterns

### U1-PAT-SEC-001: Layered Authentication and Authorization

1. ORDS validates the OAuth2 token and maps it to approved local roles.
2. ORDS privilege patterns reject callers without the endpoint role.
3. A Principal Adapter derives subject and role context from trusted ORDS runtime state.
4. PL/SQL command/query services recheck role and request ownership.
5. Database grants permit ORDS to execute approved package interfaces, not arbitrary table operations.

Client-supplied owner, role, status, actor, calculated fields, and technical identifiers are never authoritative.

### U1-PAT-SEC-002: Object-Level Ownership Guard

Every Requester operation resolves the request by both request ID and authenticated subject. Authorization is checked before returning existence-sensitive data. Cross-owner operations fail closed and never return the other Requester's supplier name, status, timestamps, or guidance.

### U1-PAT-SEC-003: Input Allowlist and Boundary Validation

Validation proceeds in layers:

| Layer | Controls |
|---|---|
| ORDS handler | Body size, JSON parse, required path/query type, basic media type. |
| API contract validator | Allowed fields, types, string/collection bounds, unknown-field rejection. |
| Domain validator | Editable status, ownership, address/contact/bank/document rules, one-primary-site invariant. |
| Governed submit validator | Active completeness, mapping, critical duplicate, and risk-warning rules through UOW-002. |
| Database | Keys, foreign keys, uniqueness, approved checks, and JSON validity. |

All SQL is static or uses bind variables.

### U1-PAT-SEC-004: Safe Projection

Requester responses are built from an explicit allowlist, never by serializing a complete database row or evidence object and deleting selected fields afterward. The projection has no fields for internal risk, duplicate candidates, AI, Reviewer factors, technical errors, payload references, response references, or bank hashes.

### U1-PAT-SEC-005: Sensitive Data Minimization

- Reject full bank account input.
- Persist only provided flag, bank country, masked display, last four, and trusted hash/token.
- Never log request bodies or bank metadata.
- Never include hashes/tokens in Requester responses.
- Use generated dummy values in seeds and tests.
- Scan source, fixtures, logs, and reports for accidental secrets/full-account patterns.

### U1-PAT-SEC-006: Externalized Secrets and Trust Material

Passwords, OAuth client secrets, wallets, certificates, and tokens live in ignored local files or container secrets. Committed files contain placeholders and variable names only. Startup fails when secrets are missing or weak rather than falling back to defaults.

### U1-PAT-SEC-007: Rate and Size Guard

ORDS applies client-specific read and mutation limits before PL/SQL work. The service separately enforces payload and collection bounds so a missing gateway control cannot cause unbounded allocation or query work.

### U1-PAT-SEC-008: Safe Error Envelope

Internal exceptions map to stable business categories and a transient trace ID. SQL codes, stack traces, object names, file paths, credentials, tokens, and payloads remain in redacted diagnostics only. Authorization, validation, audit-write, and persistence errors always fail closed.

## Performance and Capacity Patterns

### U1-PAT-PERF-001: Bounded Pagination

- Default page size 25; maximum 100.
- Stable primary sort plus request identity as a deterministic tie-breaker.
- Query predicates always include the Requester owner for Requester lists.
- Invalid page sizes are rejected rather than silently expanded.

At prototype volume, Oracle `OFFSET/FETCH` is acceptable. A cursor/keyset contract may replace it before production if measured growth requires it.

### U1-PAT-PERF-002: Role-Specific Read Models

List, detail, dashboard, and findings endpoints query only the fields needed by their role-safe response. Requester list queries do not join risk, duplicate, AI, or integration-detail tables. Child collections are loaded with bounded set queries, not one query per child row.

### U1-PAT-PERF-003: Index-Aligned Access

Use the finalized indexes for owner/status/list filters, request child foreign keys, request number, status history time order, and governed reference resolution. Performance tests capture execution plans for list, detail, dashboard, and submit lookup paths and flag full scans where the approved volume/query does not justify one.

### U1-PAT-PERF-004: Single Aggregate Mutation

Create/update uses one short database session and transaction. Child changes are set-oriented where practical. The service does not perform repeated commits, remote calls, or redundant read-after-write cycles inside the command.

### U1-PAT-PERF-005: No Prototype Cache

Oracle remains the source for current request status and guidance. Avoiding a cache removes stale authorization/status risk. A future cache requires measured need, owner-aware keys, bounded TTL, invalidation design, and security review.

## Resilience and Consistency Patterns

### U1-PAT-RES-001: Transactional Aggregate

Create and update commit header plus affected child rows together. Successful submit commits current governed outputs, Submitted history, Under Review history, header status, and timestamps together. Any exception rolls back the complete operation.

### U1-PAT-RES-002: Blocker-State Preservation

Governed blockers are a business outcome, not a partial failure. Findings may be committed as the current run while request status remains Draft or Correction Requested. No Submitted/Under Review history or queue membership is created.

### U1-PAT-RES-003: Optimistic Conflict Guard

Update compares the expected and current `last_updated_at`. A mismatch returns 409 before field mutation. Submit additionally locks the request row during its short transition transaction so simultaneous submit attempts cannot append duplicate history.

### U1-PAT-RES-004: Idempotent Observable Outcome

Repeated reads are side-effect free. Reapplying an equivalent editable representation yields equivalent business state. A repeated submit after the first succeeds does not append another transition; it returns a conflict/current-status result.

Create is not inherently idempotent because the finalized schema has no persisted idempotency key. Clients must not automatically retry a timed-out create without first resolving whether a request number was returned/found. Production may add a separately approved idempotency design if required.

### U1-PAT-RES-005: Health and Dependency Gates

Automation waits in order for:

1. Container runtime readiness.
2. Oracle database connectivity.
3. Application schema/object validity.
4. ORDS HTTPS readiness.
5. OAuth token readiness for protected API tests.

Downstream steps stop at the first failed gate and report redacted diagnostics.

### U1-PAT-RES-006: Persistent Restart and Clean Rebuild

Named-volume restart verifies committed-data survival. Clean rebuild verifies deterministic schema, packages, ORDS modules, OAuth configuration, seeds, and tests. Reset commands require explicit local-profile confirmation and never infer permission from a hostname alone.

### U1-PAT-RES-007: Fault Injection

Tests inject failures before/after header, child, finding, and status-history writes to prove rollback or blocker-state semantics. Fault hooks exist only in test configuration and cannot be enabled in a production profile.

## Observability and Audit Patterns

### U1-PAT-OBS-001: Trace Context

ORDS creates or accepts an approved trace identifier, validates its size/format, and returns it in every envelope. The trace ID is operational metadata and is not added to the finalized ATP schema.

### U1-PAT-OBS-002: Structured Redacted Access Event

One event per request records UTC timestamp, trace ID, authenticated subject identifier, role, method, route template, response status, duration, and safe error category. It excludes request/response bodies, supplier data, bank data, OAuth tokens, secrets, and SQL text containing values.

### U1-PAT-OBS-003: Append-Only Lifecycle Audit

Create and successful lifecycle transitions append status history with actor and UTC time. Ordinary field edits do not manufacture lifecycle events. Reviewer decision envelopes remain owned by UOW-003.

### U1-PAT-OBS-004: Health and Build Evidence

Migration, schema-parity, invalid-object, seed, OpenAPI, dependency, authorization, and test results are saved as machine-readable artifacts and summarized in Markdown. Logs are sufficient to reproduce failures without exposing protected values.

## Maintainability and Supply-Chain Patterns

### U1-PAT-MNT-001: Package Interface Boundary

ORDS handlers call package APIs. Business logic is not duplicated across handler source blocks. Command, query/projection, shared error/envelope, and UOW-002 orchestration interfaces are separated by responsibility.

### U1-PAT-MNT-002: Contract-First API

OpenAPI schemas define request/response fields, bounds, role notes, status codes, and safe errors. Contract tests compare the catalog, OpenAPI document, and deployed ORDS handlers.

### U1-PAT-MNT-003: Ordered External-Manifest Migrations

Numbered scripts run fail-fast. An external manifest records path, SHA-256, timing, and result. No migration-history table is added to the approved application schema. Schema inventory and invalid-object checks are mandatory after migration.

### U1-PAT-MNT-004: Configuration over Demo Logic

Origins, rate limits, page sizes, test profiles, service names, and secrets are external configuration. Business behavior uses generated request IDs and governed data, never one hardcoded demo request.

### U1-PAT-MNT-005: Pinned and Scanned Supply Chain

Resolve the Oracle image digest, pin Python dependencies exactly, generate an SBOM, scan dependencies/container/filesystem, and block unresolved High/Critical findings unless explicitly documented and approved.

## Test Design Patterns

### U1-PAT-TST-001: Test Pyramid by Boundary

| Level | Focus |
|---|---|
| Pure/domain | Validation, projection, transition, masking, request-number, and mapping logic where separable. |
| Database integration | PL/SQL packages, transactions, constraints, ownership, history, and schema parity. |
| ORDS contract | OAuth roles, method/path, JSON schema, status/envelope, CORS/rate/size controls. |
| End-to-end | US-001 create/submit, US-002 correction/resubmit, US-003 status/outcome. |
| Performance/recovery | p95 targets, concurrency, restart persistence, clean rebuild, fault injection. |

### U1-PAT-TST-002: Example Plus Property Coverage

Concrete examples pin every critical business scenario. Hypothesis explores round-trip mapping, owner/projection invariants, address/spend boundaries, bank-data minimization, equivalent updates, and stateful lifecycle sequences.

### U1-PAT-TST-003: Domain-Specific Generators

Reusable strategies generate coherent request aggregates rather than unrelated primitives. Strategies distinguish partial Drafts, submit-complete requests, blocker-triggering requests, owners, statuses, and safe bank/document metadata. Boundary values are deliberately weighted.

### U1-PAT-TST-004: Reproducibility

Hypothesis shrinking remains enabled. Reports include profile, seed/replay instructions, and the minimal failing example. A shrunk production-relevant failure becomes a permanent example-based regression test.

### U1-PAT-TST-005: Security Negative Suite

Generate missing/expired/wrong-role tokens, cross-owner IDs, mass-assignment fields, SQL metacharacters, oversize payloads, invalid media, raw-bank patterns, malformed JSON, repeated submit, and stale-update inputs. Every case verifies both denial and absence of data/state leakage.

## Misuse and Abuse Cases

| Case | Preventive Patterns | Expected Outcome |
|---|---|---|
| Guess another Requester's ID | Layered auth plus owner guard | 403/404 policy response with no resource data. |
| Add `status` or `requesterUser` to payload | Input allowlist | 400; no mass assignment. |
| Submit full bank account | Sensitive-data minimization | 400; redacted security event. |
| Double-click submit | Row lock plus transition check | One successful transition; later attempt conflicts. |
| Oversized child collections | Rate/size guard | 400 before expensive processing. |
| Inject SQL in supplier fields | Bind/static SQL plus validation | Stored/rejected as data according to field policy; query behavior unchanged. |
| Infer risk from Requester response | Safe projection | Internal evidence fields are structurally absent. |
| Run destructive reset against remote DB | Local-profile guard | Command exits before connection/mutation. |

## Pattern Traceability

| NFR Category | Primary Patterns |
|---|---|
| Performance/capacity | U1-PAT-PERF-001 through 005 |
| Reliability/recovery | U1-PAT-RES-001 through 007 |
| Security/privacy | U1-PAT-SEC-001 through 008, U1-PAT-OBS-002, U1-PAT-MNT-005 |
| Audit/observability | U1-PAT-OBS-001 through 004 |
| Maintainability | U1-PAT-MNT-001 through 005 |
| Usability | Safe projection, safe error envelope, role-specific read models |
| Testability | U1-PAT-TST-001 through 005 |

### Requirement-to-Design Matrix

| Requirement | Design Realization |
|---|---|
| U1-NFR-PERF-001 | U1-PAT-PERF-001/002/003; U1-LC-010/012. |
| U1-NFR-PERF-002 | U1-PAT-PERF-004; U1-LC-008/012. |
| U1-NFR-PERF-003 | U1-PAT-PERF-004 and U1-PAT-RES-001/002; U1-LC-009/014. |
| U1-NFR-PERF-004 | U1-PAT-PERF-002/003; U1-LC-010/011. |
| U1-NFR-PERF-005 | U1-PAT-SEC-003/007 and U1-PAT-PERF-001; U1-LC-005/006. |
| U1-NFR-PERF-006 | U1-PAT-PERF-001; U1-LC-005/010. |
| U1-NFR-PERF-007 | U1-PAT-PERF-003/004 and U1-PAT-RES-003; U1-LC-001/008/010/020. |
| U1-NFR-REL-001 | U1-PAT-RES-006 and U1-PAT-MNT-004; local-only scope is explicit. |
| U1-NFR-REL-002 | U1-PAT-RES-006; U1-LC-017/018/020. |
| U1-NFR-REL-003 | U1-PAT-RES-006 and U1-PAT-MNT-003; U1-LC-017/018/019. |
| U1-NFR-REL-004 | U1-PAT-RES-001/007; U1-LC-008/009/012/013/020. |
| U1-NFR-REL-005 | U1-PAT-RES-002; U1-LC-009/013/014. |
| U1-NFR-REL-006 | U1-PAT-RES-003; U1-LC-007/008/012. |
| U1-NFR-REL-007 | U1-PAT-RES-005; U1-LC-017/019. |
| U1-NFR-SEC-001 | U1-PAT-SEC-001; U1-LC-001/017. |
| U1-NFR-SEC-002 | U1-PAT-SEC-005; infrastructure must retain Oracle encryption defaults. |
| U1-NFR-SEC-003 | U1-PAT-SEC-001; U1-LC-002/003. |
| U1-NFR-SEC-004 | U1-PAT-SEC-002; U1-LC-004/007/010/011. |
| U1-NFR-SEC-005 | U1-PAT-SEC-001; U1-LC-002/003/004. |
| U1-NFR-SEC-006 | U1-PAT-SEC-001; U1-LC-001. |
| U1-NFR-SEC-007 | U1-PAT-SEC-003/007; U1-LC-005/006. |
| U1-NFR-SEC-008 | U1-PAT-SEC-003; U1-LC-006/008/010/012. |
| U1-NFR-SEC-009 | U1-PAT-SEC-005; U1-LC-006/011/012/016/021. |
| U1-NFR-SEC-010 | U1-PAT-SEC-006 and U1-PAT-MNT-005; U1-LC-018/021. |
| U1-NFR-SEC-011 | U1-PAT-SEC-006; startup and health gates reject absent/weak secrets. |
| U1-NFR-SEC-012 | U1-PAT-SEC-008; U1-LC-015/016. |
| U1-NFR-SEC-013 | U1-PAT-SEC-007; U1-LC-005. |
| U1-NFR-SEC-014 | U1-PAT-MNT-005; U1-LC-021. |
| U1-NFR-SEC-015 | U1-PAT-SEC-001; N/A to UOW-001 JSON handlers and gated for future UI delivery. |
| U1-NFR-OBS-001 | U1-PAT-OBS-001; U1-LC-001/015/016. |
| U1-NFR-OBS-002 | U1-PAT-OBS-002; U1-LC-016. |
| U1-NFR-OBS-003 | U1-PAT-OBS-003; U1-LC-013. |
| U1-NFR-OBS-004 | U1-PAT-OBS-002; U1-LC-005/015/016. |
| U1-NFR-OBS-005 | U1-PAT-OBS-004 and U1-PAT-RES-005; U1-LC-017/019/021. |
| U1-NFR-OBS-006 | U1-PAT-OBS-002/004; production retention and alerting remain an infrastructure gate. |
| U1-NFR-MNT-001 | U1-PAT-MNT-003; U1-LC-018. |
| U1-NFR-MNT-002 | U1-PAT-MNT-003; U1-LC-019. |
| U1-NFR-MNT-003 | U1-PAT-MNT-001; U1-LC-008/009/010/011/019. |
| U1-NFR-MNT-004 | U1-PAT-MNT-002; U1-LC-001/015/020. |
| U1-NFR-MNT-005 | U1-PAT-MNT-004; U1-LC-008/009/014. |
| U1-NFR-MNT-006 | U1-PAT-MNT-003/005; U1-LC-017/018/019/020/021. |
| U1-NFR-MNT-007 | U1-PAT-RES-006 and U1-PAT-MNT-003; U1-LC-018. |
| U1-NFR-USE-001 | U1-PAT-SEC-008; U1-LC-006/015. |
| U1-NFR-USE-002 | U1-PAT-RES-001; U1-LC-008/009. |
| U1-NFR-USE-003 | U1-PAT-SEC-004 and U1-PAT-PERF-002; U1-LC-010/011/015. |
| U1-NFR-USE-004 | U1-PAT-MNT-002; N/A to UOW-001 backend and gated for future UI implementation. |
| U1-NFR-TST-001 | U1-PAT-TST-001/002; U1-LC-020/021. |
| U1-NFR-TST-002 | U1-PAT-TST-001/005; U1-LC-001/020/021. |
| U1-NFR-TST-003 | U1-PAT-TST-002/003; U1-LC-020. |
| U1-NFR-TST-004 | U1-PAT-TST-004; U1-LC-020/021. |
| U1-NFR-TST-005 | U1-PAT-TST-003; U1-LC-020. |
| U1-NFR-TST-006 | U1-PAT-TST-003/004 and U1-PAT-MNT-004; U1-LC-020. |
| U1-NFR-TST-007 | U1-PAT-TST-005 and U1-PAT-MNT-005; U1-LC-019/020/021. |

## Extension Compliance

### Security Baseline

| Rules | Status | Design Mapping |
|---|---|---|
| SECURITY-01 through SECURITY-03 | Compliant | TLS/storage protection, access events, and structured diagnostics are designed. |
| SECURITY-04 | N/A to JSON-only UOW-001 handlers | Future HTML security headers remain gated. |
| SECURITY-05 through SECURITY-09 | Compliant | Layered validation, least privilege, local restrictions, ownership, hardening, and safe errors are designed. |
| SECURITY-10 through SECURITY-13 | Compliant | Pinning/scanning/SBOM, rate/abuse controls, external secrets, safe parsing, checksums, and audit are designed. |
| SECURITY-14 | Compliant at local-design scope | Security events and evidence are designed; production retention/alerts remain an infrastructure gate. |
| SECURITY-15 | Compliant | Transaction rollback, cleanup, and fail-closed error mapping are designed. |

### Resiliency Baseline

| Rules | Status | Design Mapping |
|---|---|---|
| RESILIENCY-01 through RESILIENCY-07 | Compliant | Workload classification, explicit prototype targets, change/rebuild automation, health, and observability patterns are designed. |
| RESILIENCY-08/09 | N/A to fixed local prototype | Production topology and scaling remain customer gates. |
| RESILIENCY-10 | Compliant | UOW-001 has no remote dependency; transaction boundaries are isolated. |
| RESILIENCY-11 | N/A to local prototype | Production DR remains a customer gate. |
| RESILIENCY-12 through RESILIENCY-15 | Compliant for local scope | Restart persistence, clean recovery, fault injection, and corrective evidence are designed. |

### Partial Property-Based Testing

| Rule | Status | Design Mapping |
|---|---|---|
| PBT-02 | Compliant | Round-trip mapping pattern. |
| PBT-03 | Compliant | Owner, projection, status, bounds, and masking invariants. |
| PBT-07 | Compliant | Domain-specific generator pattern. |
| PBT-08 | Compliant | Shrinking and replay evidence pattern. |
| PBT-09 | Compliant | Hypothesis plus pytest selected. |

No applicable enabled-extension blocking finding remains at UOW-001 NFR Design.
