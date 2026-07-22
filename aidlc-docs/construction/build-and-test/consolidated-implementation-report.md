# Oracle ATP and ORDS Construction Completion Report

## 1. Executive Summary

The Oracle ATP and ORDS construction plan has been implemented and verified as a working local supplier-onboarding backend.

The delivered solution includes:

- Oracle Autonomous AI Database Free running locally in ATP workload mode.
- The approved supplier-onboarding database schema and governed reference data.
- PL/SQL services for request processing, validation, duplicate detection, risk scoring, review decisions, dashboards, administration, and mock Fusion integration.
- A secured ORDS REST API with 42 implemented operations.
- OAuth clients and role-based access for Requester, Reviewer, Support/Admin, and System/OIC personas.
- Eleven representative supplier-request scenarios covering the full business lifecycle.
- Automated unit, property, contract, security, database, API, end-to-end, and performance tests.

### Final verified result

| Measure | Result |
|---|---:|
| Application tables | 18 of 18 |
| Application columns | 189 of 189 |
| Foreign keys | 17 of 17 |
| Invalid Oracle objects | 0 |
| Seeded application tables | 18 of 18 |
| ORDS API operations | 42 of 42 |
| OAuth roles and local clients | 4 of 4 |
| Automated tests | 64 passed |
| Failed or skipped tests | 0 |
| Known dependency vulnerabilities | 0 |

The local environment is ready for demonstrations, API evaluation, and continued application development. Fusion/OIC and AI-provider integrations are deterministic local mocks until customer environments and credentials are available.

## 2. Scope Delivered Against the Construction Plan

| Planned area | What was delivered | Status |
|---|---|---|
| Local Oracle ATP environment | Pinned Oracle Autonomous AI Database Free container configured with `WORKLOAD_TYPE=ATP`, persistent storage, and bundled HTTPS ORDS | Complete |
| Database implementation | Exact 18-table schema with 189 columns, 17 foreign keys, constraints, indexes, and JSON validation | Complete |
| Supplier onboarding services | Request intake, update, submit/resubmit, validation, duplicate detection, risk scoring, AI explanation, review decisions, and status history | Complete |
| Integration services | Deterministic Fusion submission, supplier-reference callbacks, integration logs, technical failures, and controlled retry | Complete for mock scope |
| Administration | Global validation rules, risk/duplicate scoring rules, high-risk countries, business units, supplier types, and reference synchronization | Complete |
| REST API | 42 ORDS handlers matching the OpenAPI contract | Complete |
| Security | OAuth client credentials, four application roles, protected routes, request ownership, and business-level authorization | Complete for local scope |
| Demonstration data | Eleven request scenarios and meaningful rows in every application table | Complete |
| Quality verification | 64 automated tests, schema verification, SBOM, and dependency audit | Complete |

## 3. Solution Overview

The solution follows this processing path:

```text
Requester / Reviewer / Admin / System
                 |
                 v
        OAuth authentication
                 |
                 v
        ORDS role and URL checks
                 |
                 v
       Versioned REST API handlers
                 |
                 v
     PL/SQL authorization and services
                 |
                 v
        Oracle ATP-mode database
                 |
                 v
       Mock Fusion/OIC integration
```

### Main implementation components

| Component | Responsibility |
|---|---|
| Oracle ATP-mode schema | Persists supplier requests, child records, validation results, duplicate/risk evidence, decisions, reference data, and integration history |
| ORDS API | Publishes the 42 versioned HTTPS operations |
| Security service | Resolves the authenticated client, checks roles, enforces Requester ownership, and prevents invalid state changes |
| Request service | Creates, updates, submits, resubmits, lists, and retrieves supplier requests |
| Validation service | Executes the nine configurable global validation rules and persists failed rules |
| Duplicate service | Performs exact and weighted duplicate matching against requests and existing suppliers |
| Risk service | Calculates explainable scores using governed risk factors and thresholds |
| Review service | Records approval, rejection, correction, and duplicate decisions with selected risk factors and comments |
| Integration service | Simulates Fusion submission, success/failure responses, integration logging, and retry |
| Admin service | Maintains governed configuration and supplier reference data |
| Test suite | Verifies the schema, business behavior, API contract, security boundaries, scenarios, and local performance |

## 4. Database and API Outcome

### Database contract

The database matches the approved design exactly:

- 18 application tables.
- 189 application columns.
- 17 foreign-key relationships.
- No extra application tables.
- No missing tables or columns.
- No invalid Oracle objects.
- Representative rows in every application table.

The finalized design decisions are reflected in the implementation:

- Risk and duplicate configuration share `REF_SCORING_RULE`, distinguished by `RULE_TYPE`.
- The nine global rules are stored in `VALIDATION_RULES`.
- Each failed `VALIDATION_RESULT` references the exact validation rule.
- `AI_SUMMARY_FEEDBACK` is not present.
- Retry attempts are embedded in `INTEGRATION_LOG.RETRY_HISTORY_JSON` rather than a separate retry table.
- Full bank account numbers are not stored; only masked values, last four digits, and trusted hashes/tokens are retained.

### API contract

| API group | Operations |
|---|---:|
| Requests and attachments | 7 |
| Validation | 2 |
| Duplicate detection | 2 |
| Risk scoring | 2 |
| AI summaries | 2 |
| Review decisions | 4 |
| Integration and retry | 4 |
| Dashboards | 3 |
| Reference data | 2 |
| Admin Settings | 11 |
| Internal System/OIC callbacks | 3 |
| **Total** | **42** |

All operations use HTTPS and OAuth. Requester responses exclude internal risk, duplicate, AI, and technical evidence. Reviewer decisions and Admin/System operations receive additional business-level authorization in PL/SQL.

## 5. Exact Seeded Demonstration Scenarios

The database contains eleven request scenarios. Together they provide checkpoints for every major workflow path required by the construction plan.

| ID | Request | Supplier | Current status | Purpose and evidence |
|---:|---|---|---|---|
| 1 | `REQ-2026-0001` | Bluebird Cleaning | Draft | Baseline editable request with site, contact, masked bank details, and document metadata |
| 2 | `REQ-2026-0002` | Alpine Consulting | Correction Requested | Reviewer returned the request with a missing-tax risk selection, a clear comment, and a document correction item |
| 3 | `REQ-2026-0003` | Northstar Facility Services | Under Review | Medium duplicate match at 55, Medium risk at 55, missing tax/insurance information, and an advisory AI summary |
| 4 | `REQ-2026-0004` | Tax Duplicate Example | Draft | Exact tax-registration duplicate with Critical score 100; blocking `VAL-008` prevents submission; risk score 25/Low is retained as evidence |
| 5 | `REQ-2026-0005` | Bank Duplicate Example | Draft | Same trusted bank hash with Critical score 100; blocking `VAL-009` prevents submission; risk score 45/Medium |
| 6 | `REQ-2026-0006` | Enhanced Review Trading | Under Review | Warning-only high-risk-country case with bank-country mismatch, high spend, missing metadata, and High risk score 80 |
| 7 | `REQ-2026-0007` | Ready Services | Approved | Reviewer-approved request ready for Fusion submission |
| 8 | `REQ-2026-0008` | Created Supplier Demo | Created in Fusion | Successful mock integration with Fusion supplier number `SUP-00000008` and a successful integration log |
| 9 | `REQ-2026-0009` | Fail Integration Demo | Integration Failed | Retry-eligible technical failure with a safe user message, technical evidence, and an embedded retry-history entry |
| 10 | `REQ-2026-0010` | Rejected Supplier Demo | Rejected | Reviewer rejection with the reason that the request is outside the approved sourcing policy |
| 11 | `REQ-2026-0011` | Northstar Facilities Ltd | Marked Duplicate | Reviewer-selected existing supplier `SUP-1001`, High duplicate score 80, selected duplicate risk factor, and requester guidance |

The seed data also includes:

- Nine validation rules, including mandatory data, email, address, exact-tax, and same-bank checks.
- Twelve risk-scoring configuration rows and ten duplicate-scoring rows.
- Effective-dated high-risk countries.
- Active and inactive business units and supplier types.
- Three existing suppliers and three supplier sites for matching.
- Masked or irreversibly hashed synthetic bank data.
- Complete status-history examples for create, submit, correction, approval, rejection, duplicate, Fusion success, and integration failure actions.

## 6. End-to-End Flows for Presentation

### Flow 1: Successful request submission and entry into review

Representative checkpoints: request 1 for Draft and request 3 for Under Review.

1. The Requester obtains an OAuth token using the local Requester client.
2. `POST /requests` creates the request in Draft status.
3. The Requester adds or updates supplier, site, contact, bank, and document information.
4. `POST /requests/{requestId}/submit` automatically runs:
   - all active global validation rules;
   - duplicate detection;
   - risk scoring and risk-reason generation.
5. When no blocking validation exists, the transaction records Draft to Submitted and Submitted to Under Review history entries.
6. The Reviewer retrieves the request, duplicate evidence, validation results, and risk assessment.
7. The Reviewer may generate an advisory AI summary. The summary highlights facts and missing information but cannot make the decision.
8. The request is ready for Approve, Reject, Request Correction, or Mark Duplicate.

Demonstrated outcome: request 3 is Under Review with a Medium duplicate match, Medium risk score, explainable reasons, missing-document evidence, and a guarded AI summary.

### Flow 2: Submission blocked by a critical duplicate

Representative checkpoints: requests 4 and 5.

1. The Requester submits an editable Draft request.
2. Validation, duplicate detection, and risk scoring run in the same submission transaction.
3. Request 4 matches an existing supplier's normalized tax registration:
   - duplicate level: Critical;
   - duplicate score: 100;
   - failed rule: `VAL-008`;
   - result: HTTP 422 and the request remains Draft.
4. Request 5 matches an existing supplier's trusted bank hash:
   - duplicate level: Critical;
   - duplicate score: 100;
   - failed rule: `VAL-009`;
   - result: HTTP 422 and the request remains Draft.
5. The failed validation and duplicate evidence remain available for correction and review without incorrectly placing the request in the Reviewer queue.

Demonstrated outcome: exact-tax and same-bank duplicates block submission, while explainable validation, duplicate, and risk evidence is preserved.

### Flow 3: Reviewer requests correction and Requester resubmits

Representative checkpoint: request 2.

1. A request reaches Under Review.
2. The Reviewer selects one or more risk factors, provides a requester-facing comment, and identifies correction items.
3. `POST /requests/{requestId}/request-correction` records the complete decision envelope in status history.
4. The status becomes Correction Requested.
5. The Requester sees the guidance but does not receive internal risk scores, duplicate evidence, AI evidence, or technical messages.
6. The Requester updates the missing document/data using `PATCH /requests/{requestId}`.
7. Resubmission reruns validation, duplicate detection, and risk scoring using the current governed rules.
8. If blockers are cleared, the request returns to Under Review with new status-history evidence.

Demonstrated outcome: request 2 contains the comment “Provide the missing tax certificate,” the selected `MISSING_TAX` factor, and a specific document correction item.

### Flow 4: Reviewer approval and successful Fusion creation

Representative checkpoints: request 7 for Approved and request 8 for Created in Fusion.

1. The Reviewer examines validation, duplicate, risk, document, and optional AI evidence.
2. `POST /requests/{requestId}/approve` verifies that no blocking validation remains.
3. The review decision, comment, selected risk factors, actor, and timestamp are recorded in status history.
4. The request status becomes Approved.
5. Support/Admin or System/OIC calls `POST /requests/{requestId}/submit-to-fusion`.
6. The request moves through Submitted to Fusion.
7. The deterministic success path creates an integration log, assigns mock Fusion identifiers, and records Created in Fusion.
8. Repeating the submit operation is idempotent when a Fusion supplier number already exists.

Demonstrated outcome: request 8 is Created in Fusion with supplier number `SUP-00000008`, response evidence, and a successful integration log.

### Flow 5: Technical integration failure and controlled retry

Representative checkpoint: request 9 and integration log 2.

1. An Approved request is submitted to the mock Fusion service.
2. A technical failure creates an `INTEGRATION_LOG` row and changes the request to Integration Failed.
3. The log keeps a safe user message separate from technical diagnostic information.
4. The failure is marked retry eligible.
5. Support/Admin retrieves the log and its embedded retry history.
6. `POST /integration-logs/{logId}/retry` checks eligibility, current status, retry history, and whether a Fusion supplier already exists.
7. The retry result is appended atomically to `RETRY_HISTORY_JSON`, and `RETRY_COUNT` is synchronized with the JSON history length.
8. On success, the request becomes Created in Fusion, the log becomes successful, and retry eligibility is removed.

Demonstrated outcome: request 9 contains a retry-eligible synthetic timeout and an embedded attempt record attributed to `local-admin`.

### Flow 6: Role and data-access protection

1. Requester, Reviewer, Admin, and System clients obtain separate OAuth access tokens.
2. ORDS restores the role associated with the authenticated client and checks the requested URL privilege.
3. PL/SQL performs a second check for request ownership or role-specific operations.
4. A Requester can read an owned request but cannot retrieve Reviewer risk evidence.
5. A Reviewer can retrieve risk and duplicate evidence and make review decisions.
6. Support/Admin can maintain settings and inspect/retry integration failures.
7. System/OIC can use trusted internal callback operations.

Demonstrated outcome: the live tests return HTTP 200 for permitted Requester, Reviewer, and Admin calls and deny the Requester risk-evidence call with HTTP 403.

## 7. Test Coverage and Results

### Test result by category

| Category | Tests | What was verified | Result |
|---|---:|---|---|
| Unit | 9 | Normalization, score thresholds, submission states, requester projection, retry count, and monetary validation | Passed |
| Property | 8 | Idempotence, score ranges, JSON round trips, workflow invariants, projection minimization, retry-history consistency, and money bounds | Passed |
| Contract | 13 | Migration checksums, SQL/package structure, exact schema parity, seed coverage, OpenAPI completeness, and all 42 endpoint declarations | Passed |
| Security | 8 | Loopback binding, secret exclusion, bank masking, OAuth coverage, requester data minimization, safe TLS use, and rate-policy limits | Passed |
| Database and ORDS integration | 8 | Live schema, seed integrity, foreign-key references, retry JSON, OAuth role access, and API response boundaries | Passed |
| End-to-end user stories | 14 | US-001 through US-014 business scenarios | Passed |
| Performance smoke | 4 | Bounded request-list, request-detail, duplicate, and risk queries | Passed |
| **Total** | **64** | **Complete local construction gate** | **Passed** |

### Exact end-to-end business tests

| Story | Test case and expected evidence | Result |
|---|---|---|
| US-001 | A Draft request has supplier, site, and contact data and is ready for submission | Passed |
| US-002 | A Correction Requested request has structured Reviewer guidance in status history | Passed |
| US-003 | Requests cover at least eight statuses, including a Created in Fusion request with a supplier number | Passed |
| US-004 | Current blocking validation results and at least two Critical duplicate matches exist | Passed |
| US-005 | Risk scores remain between 0 and 100 and contain machine-readable reason codes | Passed |
| US-006 | AI output contains an explicit decision guardrail and no approve/reject/create action | Passed |
| US-007 | Approve, Reject, Request Correction, and Mark Duplicate decisions are recorded as structured audit evidence | Passed |
| US-008 | Correction, rejection, and duplicate outcomes include requester-facing guidance | Passed |
| US-009 | Requester and Reviewer dashboard source data is populated | Passed |
| US-010 | A technical integration failure is retry eligible and contains retry history | Passed |
| US-011 | A Created in Fusion request contains both Fusion supplier ID and number | Passed |
| US-012 | Existing supplier and supplier-site reference data has been synchronized and seeded | Passed |
| US-013 | Nine validation rules, risk/duplicate configuration, and masked bank data are present | Passed |
| US-014 | Draft, Correction Requested, Under Review, Approved, Rejected, Marked Duplicate, Created in Fusion, and Integration Failed demo states all exist | Passed |

### Exact live API authorization tests

| Test | Expected result | Result |
|---|---|---|
| Requester retrieves owned request 3 | HTTP 200; no risk score, selected risk factors, or technical message in the response | Passed |
| Requester calls request 3 risk-assessment endpoint | HTTP 403 | Passed |
| Reviewer retrieves request 3 risk and duplicate evidence | HTTP 200 for both endpoints | Passed |
| Admin retrieves integration log 2 and embedded retry history | HTTP 200; retry count equals history length | Passed |

### Additional business and technical gates

The test suite also verifies:

- All nine validation rules are present and failed results reference exact rule IDs.
- All twelve risk and ten duplicate configuration rows are seeded.
- Normalization is idempotent and duplicate/risk scores always remain within 0–100.
- Exact-tax and same-bank matches produce critical duplicate evidence.
- Blocking findings prevent submission; warning-only findings can proceed to review.
- Invalid status transitions are rejected.
- Reviewer approval is prevented while blocking validations remain.
- Mock Fusion processing is idempotent.
- Retry count always equals the embedded retry-history length.
- Every application table contains seed data and every foreign key remains valid.
- The authoritative schema design, executable DDL, OpenAPI contract, and endpoint implementation remain synchronized.
- No committed passwords, OAuth secrets, wallets, reports, or full bank account numbers are present.
- The dependency audit reports no known vulnerabilities.

## 8. Demonstration Recommendation

A concise project-lead demonstration can use these scenarios in order:

1. **Request 1 — Draft:** show the base supplier, site, contact, document, and masked bank model.
2. **Request 4 or 5 — Blocked duplicate:** show the exact-tax or same-bank blocker, HTTP 422 behavior, and preserved evidence.
3. **Request 3 — Under Review:** show validation, duplicate score, risk reasons, AI guardrail, and the Requester/Reviewer data-access difference.
4. **Request 2 — Correction Requested:** show selected risk factors, correction guidance, Requester editability, and resubmission behavior.
5. **Request 8 — Created in Fusion:** show successful integration identifiers and the integration log.
6. **Request 9 — Integration Failed:** show technical/user message separation, embedded retry history, and Admin retry behavior.
7. **Request 11 — Marked Duplicate:** show the Reviewer-selected existing supplier and requester-facing guidance.

This sequence demonstrates the normal path, automated controls, human review, security boundaries, successful integration, failure recovery, and duplicate resolution without creating additional data during the presentation.

## 9. Remaining Production Activities

The following are intentionally outside the local construction scope:

- Provisioning the managed ATP database in the customer's Oracle Cloud tenancy.
- Replacing local OAuth persona clients with production SSO, MFA, identity lifecycle, and customer role assignments.
- Connecting to live Fusion and OIC endpoints and replacing deterministic mocks.
- Selecting and governing a live AI provider.
- Installing production certificates, secrets management, API-management rate enforcement, and centralized logging/monitoring.
- Defining customer SLA, throughput, concurrency, backup/restore, RTO/RPO, and disaster-recovery requirements.

## 10. Completion Statement

The Oracle ATP and ORDS construction plan is complete for the approved local prototype scope. The database is healthy, the schema matches the approved design, every application table is seeded, all 42 API operations are installed, role-protected API calls work, and all 64 automated tests pass without failures or skips.

The implemented scenarios and flows provide direct evidence that the solution supports supplier intake, automated validation and scoring, Reviewer decisions, correction, duplicate handling, successful Fusion creation, technical failure diagnosis, and controlled retry.
