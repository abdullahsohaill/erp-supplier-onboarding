# UOW-001 NFR Requirements

## Scope and Classification

- **Unit**: UOW-001 Core Request Intake
- **Workload class**: Medium-criticality, non-production prototype
- **Primary actors**: Requester; Reviewer and Support/Admin consume later projections
- **Target volume**: 50-100 supplier requests and a few hundred supplier-reference records
- **Production SLA**: Not claimed
- **Authoritative data model**: Finalized 18-table ATP schema; this stage adds no tables or columns

The targets below are local prototype acceptance criteria. Production availability, RTO, RPO, topology, compliance, identity-provider, and capacity targets remain customer decisions.

## Performance and Capacity

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-PERF-001 | Owner-scoped request list and detail reads must remain responsive at the approved demo volume. | With 100 requests and 500 supplier-reference records, p95 response time is at most 2 seconds for list/detail over 100 sequential test calls after warm-up. |
| U1-NFR-PERF-002 | Draft create and editable update must remain responsive. | p95 response time is at most 2 seconds for create/update at demo volume, excluding client rendering. |
| U1-NFR-PERF-003 | Submit/resubmit may run validation, duplicate, and risk logic but must finish within a business-usable interval. | p95 response time is at most 5 seconds for local deterministic processing at demo volume. |
| U1-NFR-PERF-004 | Requester dashboard summary must not scan unbounded result sets. | p95 response time is at most 3 seconds at demo volume; query plan uses approved indexes. |
| U1-NFR-PERF-005 | Collection and payload sizes must be bounded. | Request body is at most 1 MiB; a request contains at most 10 sites, 10 contacts, 25 document-metadata entries, and one phase-one bank-metadata entry. Larger input returns 400. |
| U1-NFR-PERF-006 | List endpoints must paginate predictably. | Default page size 25, maximum 100, deterministic secondary sort by request identity. |
| U1-NFR-PERF-007 | Prototype concurrency must support a small review team without errors. | Ten concurrent authenticated clients complete mixed list/detail/create/update operations for five minutes with less than 1 percent server error rate and no authorization leakage. |

These targets are validated on the documented 4 CPU/8 GiB local container allocation and are not production benchmarks.

## Availability and Recoverability

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-REL-001 | No production uptime commitment is implied by the local prototype. | Documentation labels the runtime non-production and contains no SLA claim. |
| U1-NFR-REL-002 | Committed request data must survive an ordinary container restart. | Create a Draft, restart the stack without deleting the named volume, and verify the same request and children remain. |
| U1-NFR-REL-003 | A clean environment must be reproducible. | Excluding first image download, documented reset, startup, migration, seed, and health verification complete within 30 minutes on the target host. |
| U1-NFR-REL-004 | A failed mutation must not leave partial aggregate or lifecycle state. | Fault-injection tests verify rollback of header, children, findings, status, and history at each transactional failure point. |
| U1-NFR-REL-005 | A blocked submit must preserve business continuity. | Initial submit remains Draft; resubmit remains Correction Requested; neither creates a Reviewer queue transition. |
| U1-NFR-REL-006 | Stale writes must not silently overwrite newer edits. | Expected `last_updated_at` mismatch returns 409 with no mutation. |
| U1-NFR-REL-007 | Health must be machine-verifiable before migrations/tests run. | Database connectivity, application-schema validity, and ORDS HTTPS checks all pass before dependent steps begin. |

Production RTO/RPO, backup retention, multi-zone/region topology, and DR testing remain mandatory customer gates before go-live.

## Security and Privacy

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-SEC-001 | Data in transit must use TLS 1.2 or later. | ORDS is accessed through HTTPS; tests reject plain HTTP or redirect it to HTTPS where the runtime exposes HTTP. Database connectivity uses the generated TLS/mTLS wallet configuration. |
| U1-NFR-SEC-002 | Database files must use Oracle-provided encryption at rest. | The selected Autonomous Database Free runtime retains its encrypted database storage behavior; production ATP uses managed encryption. |
| U1-NFR-SEC-003 | APIs must deny access by default. | Every protected endpoint returns 401 without a valid token and 403 for a token without the required role. |
| U1-NFR-SEC-004 | Object-level Requester ownership must be enforced server-side. | Cross-owner list, detail, update, submit, attachments, findings, and dashboard tests return no protected data. |
| U1-NFR-SEC-005 | Local role testing must use ORDS OAuth2 privileges/roles. | Separate Requester, Reviewer, Support/Admin, and System/OIC clients receive only their approved scopes. Production maps customer SSO identities to equivalent roles. |
| U1-NFR-SEC-006 | CORS must use an allowlist. | Authenticated endpoints never return wildcard origin; local origins are explicit configuration values. |
| U1-NFR-SEC-007 | Every API parameter and body must be validated. | Type, allowlist, length, format, numeric range, collection size, unknown-field, and body-size negative tests pass. |
| U1-NFR-SEC-008 | SQL injection must be prevented. | PL/SQL handlers use bind variables/static SQL; adversarial input tests change no query structure or unauthorized data. |
| U1-NFR-SEC-009 | Full bank account values must never enter the phase-one boundary. | Raw/full-number input is rejected; persistence, API output, logs, reports, fixtures, and AI/mock payload scans contain no full account value. |
| U1-NFR-SEC-010 | Secrets must remain outside version control. | Passwords, wallet files, client secrets, tokens, and generated certificates are ignored; repository secret scan passes. |
| U1-NFR-SEC-011 | Default credentials must not be used. | Setup generates compliant local passwords into ignored files and fails when required secrets are absent or weak. |
| U1-NFR-SEC-012 | Errors must be safe and fail closed. | User responses contain no SQL, stack trace, path, credential, token, or technical payload; failed authorization/validation never proceeds. |
| U1-NFR-SEC-013 | Request APIs must be throttled. | Local policy limits authenticated reads to 120 requests/minute/client and mutations to 30 requests/minute/client; excess returns 429 without processing. Production values are customer-tunable. |
| U1-NFR-SEC-014 | Software supply chain must be controlled. | Container image is pinned by immutable release tag and recorded digest; Python dependencies use exact versions and hashes/lock evidence; vulnerability scan and CycloneDX SBOM are generated. |
| U1-NFR-SEC-015 | Browser-serving platforms must apply security headers. | Future Visual Builder/HTML delivery must provide CSP, HSTS, `X-Content-Type-Options`, `X-Frame-Options`, and `Referrer-Policy`; this is N/A to database-only ORDS JSON handlers. |

## Authorization Matrix

| UOW-001 Capability | Requester | Reviewer | Support/Admin | System/OIC |
|---|---:|---:|---:|---:|
| Create Draft | Own | Deny | Deny by default | Deny |
| List/view request | Own only | Later-unit authorized projection | Authorized support projection | Deny by default |
| Update Draft/Correction Requested | Own only | Deny | Deny by default | Deny |
| Submit/resubmit | Own only | Deny | Deny by default | Deny |
| View Requester-safe validation findings | Own only | Full evidence in UOW-002 | Full support evidence where approved | Internal orchestration only |
| Maintain attachment metadata | Own only | Deny | Deny by default | Deny |
| Requester dashboard | Own only | Deny | Deny | Deny |

No client-supplied role, owner, status, calculated score, or server-managed identifier is trusted.

## Audit and Observability

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-OBS-001 | Every API response must carry a transient trace ID. | Contract tests verify non-empty trace ID in success and error envelopes. |
| U1-NFR-OBS-002 | Access logs must be structured and redacted. | Log events include UTC timestamp, trace ID, authenticated subject identifier, role, method, route template, status, and latency; they exclude request bodies, supplier PII, bank metadata, tokens, and secrets. |
| U1-NFR-OBS-003 | Lifecycle transitions must be auditable. | Successful create/submit/resubmit history includes action, actor, from/to status, and UTC time; field edits do not fabricate status transitions. |
| U1-NFR-OBS-004 | Authorization and security events must be distinguishable. | Repeated 401/403, malformed input, raw-bank-data rejection, and rate-limit events are test-observable without sensitive values. |
| U1-NFR-OBS-005 | Local diagnostics must be accessible without changing business data. | Container/application logs and health commands provide enough data to identify startup, migration, invalid-object, and ORDS failures. |
| U1-NFR-OBS-006 | Production logs require tamper-resistant storage and retention. | Minimum 90-day production retention and security alert routing remain required infrastructure decisions; local logs need only persist for the test/report run. |

## Maintainability and Change Control

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-MNT-001 | Database changes must be ordered and repeatable. | Numbered SQL migrations execute fail-fast on a clean schema and produce an external checksum/result manifest without adding a migration table. |
| U1-NFR-MNT-002 | The finalized schema must remain verifiable. | Automated inventory confirms 18 application tables, 189 columns, and 17 physical foreign-key relationships after migration. |
| U1-NFR-MNT-003 | PL/SQL interfaces must be modular and valid. | Request, projection, validation-orchestration, and utility packages compile with no invalid application objects. |
| U1-NFR-MNT-004 | API contracts must be versioned and machine-readable. | OpenAPI describes every implemented UOW-001 method/path, envelope, role, schema, and error response and passes validation. |
| U1-NFR-MNT-005 | Business configuration and rules must not be hidden in demo IDs. | Tests and handlers work for generated request identities and governed reference values; no fixed request ID controls behavior. |
| U1-NFR-MNT-006 | Build/test commands must be automated. | Single documented commands start, migrate, seed, verify, test, report, and reset the local environment. |
| U1-NFR-MNT-007 | Changes must be reversible in development. | Reset procedure removes/recreates only the local environment and never runs implicitly against a non-local connection. |

## Usability and Accessibility Contract

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-USE-001 | Requester errors must be actionable and business-safe. | 400/409/422 tests verify stable code, field where applicable, plain message, and no technical detail. |
| U1-NFR-USE-002 | Draft save must tolerate missing submit-required fields. | Partial valid payload saves successfully; submit identifies missing values. |
| U1-NFR-USE-003 | Role-safe outcomes must clearly state the next action. | Correction, duplicate, rejection, review, integration-failure, and Fusion-created projections return approved business guidance only. |
| U1-NFR-USE-004 | A future UI must meet WCAG 2.1 AA for the defined Requester workflow. | Keyboard, focus, labels, error association, contrast, and status-announcement checks are required when Visual Builder implementation is approved. N/A to the current backend build. |

## Testability and Quality Gates

| ID | Requirement | Acceptance Measure |
|---|---|---|
| U1-NFR-TST-001 | All 28 UOW-001 business rules require executable coverage. | Rule-to-test matrix has no uncovered blocking/security rule. |
| U1-NFR-TST-002 | All 11 UOW-001 endpoint contracts require positive and negative tests. | Method/path, schema, role, ownership, status, and error-envelope tests pass. |
| U1-NFR-TST-003 | Critical paths require example tests plus property tests where applicable. | Draft, blocked submit, successful submit, correction resubmit, owner isolation, projection redaction, and bank masking have concrete examples; general invariants use Hypothesis. |
| U1-NFR-TST-004 | Property tests must shrink and reproduce failures. | Hypothesis shrinking remains enabled and CI/test reports log a replayable seed/profile. |
| U1-NFR-TST-005 | Domain generators must be realistic. | Reusable strategies generate valid owners, supplier requests, contacts, structured addresses, optional bank/document metadata, and lifecycle command sequences with boundary cases. |
| U1-NFR-TST-006 | Tests must be independent of fixed demo identities. | Each test creates or selects data by returned identifiers and can run after a clean reset. |
| U1-NFR-TST-007 | Security and dependency gates must fail the build. | Secret scan, vulnerability scan, OpenAPI validation, schema parity, invalid-object query, and authorization tests all pass. |

## Production Decision Gates

The following are deliberately unresolved for the local prototype and must be approved before production implementation:

- Customer Oracle Cloud ATP tenancy, network, wallet, and backup policy.
- Customer identity provider, SSO claims, role mapping, MFA, session, and account lifecycle.
- Production traffic, concurrency, growth, latency, throughput, and rate-limit targets.
- Availability target, RTO, RPO, retention, restore testing, multi-zone/region, and DR strategy.
- Central logging, security monitoring, alert routing, incident response, and change-management process.
- Regulatory/compliance classification and data-retention/deletion requirements.
- Visual Builder hosting, CSP/CORS origins, accessibility sign-off, and browser support matrix.

## Extension Compliance

### Security Baseline

| Rule | Status | Requirement Coverage |
|---|---|---|
| SECURITY-01 | Compliant | U1-NFR-SEC-001/002 require encrypted transport and storage. |
| SECURITY-02 | Compliant | U1-NFR-OBS-002 requires ORDS access logging. |
| SECURITY-03 | Compliant | U1-NFR-OBS-001/002/005 define structured application diagnostics. |
| SECURITY-04 | N/A for UOW-001 backend | U1-NFR-SEC-015 gates future HTML delivery. |
| SECURITY-05 | Compliant | U1-NFR-SEC-007/008 define complete validation and injection prevention. |
| SECURITY-06 | Compliant | Role/endpoint matrix is least privilege; infrastructure grants are detailed later. |
| SECURITY-07 | Compliant at requirement level | Local ports/origins are restricted; topology is detailed in Infrastructure Design. |
| SECURITY-08 | Compliant | U1-NFR-SEC-003 through 006 require auth, roles, ownership, and restricted CORS. |
| SECURITY-09 | Compliant | U1-NFR-SEC-010/011/012/014 prohibit defaults, leakage, and unpinned runtime. |
| SECURITY-10 | Compliant | U1-NFR-SEC-014 requires pinning, scanning, and SBOM. |
| SECURITY-11 | Compliant | Ownership, rate limiting, role separation, and abuse cases are explicit. |
| SECURITY-12 | Compliant for local API auth | OAuth2 secrets are external; production SSO/MFA is a documented gate. No password login is implemented by UOW-001. |
| SECURITY-13 | Compliant | Safe JSON handling, checksums, audit history, and scan requirements are explicit. |
| SECURITY-14 | Compliant at requirement level | U1-NFR-OBS-004/006 define security events and production retention/alerts. |
| SECURITY-15 | Compliant | U1-NFR-REL-004/005 and U1-NFR-SEC-012 require rollback and fail-closed errors. |

### Resiliency Baseline

| Rule | Status | Requirement Coverage |
|---|---|---|
| RESILIENCY-01 | Compliant | Workload is classified medium-criticality and non-production. |
| RESILIENCY-02 | Compliant | No prototype SLA is claimed; production targets are explicit gates. |
| RESILIENCY-03 | Compliant at requirement level | Ordered migrations, checksums, tests, and approval gates define controlled change. |
| RESILIENCY-04 | Compliant at requirement level | Automated rebuild/reset and rollback-safe local procedures are required. |
| RESILIENCY-05 | Compliant at requirement level | Security/health events and production alert decisions are defined. |
| RESILIENCY-06 | Compliant | U1-NFR-REL-007 requires database/schema/ORDS health checks. |
| RESILIENCY-07 | Compliant at requirement level | Trace, latency, error, authorization, and health observability are required. |
| RESILIENCY-08 | N/A for local prototype | Production topology is a customer gate. |
| RESILIENCY-09 | N/A for local prototype | Fixed local capacity is documented; production scaling is a customer gate. |
| RESILIENCY-10 | Compliant | UOW-001 submission has no remote dependency and no open transaction across later remote calls. |
| RESILIENCY-11 | N/A for local prototype | Production DR strategy is a customer gate. |
| RESILIENCY-12 | Compliant for local scope | Named-volume restart persistence is tested; production backups remain a gate. |
| RESILIENCY-13 | Compliant for local scope | Rebuild/reset and restart verification are required; production failover remains a gate. |
| RESILIENCY-14 | Compliant for local scope | Transaction fault injection is required; production chaos/DR testing remains a gate. |
| RESILIENCY-15 | Compliant at requirement level | Safe diagnostics, health checks, failure reports, and corrective reruns are required. |

### Partial Property-Based Testing

| Rule | Status | Requirement Coverage |
|---|---|---|
| PBT-02 | Compliant | Round-trip request/domain mapping property required. |
| PBT-03 | Compliant | Ownership, projection, status, bounds, and masking invariants required. |
| PBT-07 | Compliant | Reusable domain-specific generators required. |
| PBT-08 | Compliant | Shrinking and reproducible seed/profile reporting required. |
| PBT-09 | Compliant | Hypothesis is selected in the technology decision artifact. |

No applicable enabled-extension blocking finding remains at the UOW-001 NFR Requirements stage.
