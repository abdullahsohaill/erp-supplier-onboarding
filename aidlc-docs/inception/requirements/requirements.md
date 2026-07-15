# Requirements Specification

## Document Status

| Field | Value |
|---|---|
| Project | Supplier Onboarding, Duplicate Detection, and Risk Scoring |
| Phase | AI-DLC Inception |
| Status | Consolidated review-ready baseline; verification questions answered using customer transcript assumptions |
| Source | `Integration ERP.pdf` |
| Personas | Requester, Reviewer, Support/Admin User |
| Wireframes | Deferred until requirements and design are approved |

## Business Objective

Standardize supplier onboarding on the requested Oracle stack, reduce duplicate supplier creation, improve supplier request data quality, expose supplier risk before creation in Fusion, and provide transparent status and integration visibility from request submission through review, Fusion submission, success, or failure.

## Scope Summary

| Category | In Scope | Out of Scope For Phase One |
|---|---|---|
| User experience | Visual Builder request, review, dashboard, and support/admin flows. | Wireframes until explicitly requested later; email notifications. |
| Supplier process | New supplier onboarding with one Reviewer persona and human decision authority. | Existing supplier updates, supplier merge, full enterprise approval workflow. |
| Data and workflow | ATP staging, request status, validation results, duplicate results, risk scoring, AI summaries, integration logs, reference data. | Treating ATP as supplier master system of record. |
| Duplicate/risk | Explainable duplicate detection and rule-based risk scoring. | Full enterprise MDM matching platform; external sanctions/risk service integration. |
| AI | AI-generated risk/duplicate explanations and recommended reviewer actions. | AI approval, rejection, duplicate marking, or supplier creation. |
| Integration | OIC pattern for Fusion supplier creation and supplier reference sync; mock Fusion allowed for prototype. | Production hardening without customer environment decisions. |
| Documents | Document metadata and missing-document flags. | Production-grade document upload unless explicitly added later. |

## Personas and Access Summary

| Persona | Description | Primary Goals | Primary Access |
|---|---|---|---|
| Requester | Business user requesting a new supplier. | Submit a complete supplier request, fix missing data, track status, know which existing supplier to use if duplicate. | Create drafts, submit own requests, update correction-requested requests, view own status and reviewer comments. |
| Reviewer | Single business reviewer for the prototype. Owns completeness, duplicate, risk, payment-warning, and supplier-review decisions. | Review requests efficiently, understand duplicate/risk reasons, keep AI advisory only, approve/reject/request correction/mark duplicate. | View review queue, duplicate matches, risk reasons, AI summary, validation results, and perform review actions. |
| Support/Admin User | Technical support and configuration user. | Troubleshoot OIC/Fusion issues, retry eligible failures, maintain reference data. | View integration logs, inspect payload/response references, retry eligible failures, maintain reference data. |

## Functional Requirements

The phase-one solution is organized around five functional areas. Each requirement keeps a stable ID for traceability into user stories, technical design, test cases, and later wireframes.

### Request Intake and Status

#### FR-001: Guided Supplier Request Experience
**Priority:** Must

The application shall provide a guided Oracle Visual Builder experience for creating and submitting new supplier onboarding requests. Requesters must be able to create drafts, edit drafts, submit requests, and resubmit requests returned for correction.

Acceptance criteria:
- Requester can save Draft, edit Draft, submit, and resubmit Correction Requested supplier requests.
- Request captures supplier name, supplier type, country, address/site, contact person, contact email, phone, business unit, requester, business justification, product/service category, expected annual spend, tax registration where applicable, optional bank indicators, and document metadata.
- At least one supplier site or intended site/business-unit context is captured.
- Request receives a unique request number and is staged in ATP through ORDS.
- Visual Builder does not call Fusion supplier creation APIs directly.

Verification: UI walkthrough, ORDS/API trace, request payload tests.

#### FR-002: Supplier Request Lifecycle and Visibility
**Priority:** Must

The application shall track each request from draft through review, Fusion submission, success, rejection, duplicate marking, correction, or integration failure. Requesters should always know the current business outcome and what action, if any, is required from them.

Acceptance criteria:
- Supports Draft, Submitted, Validation Failed, Under Review, Correction Requested, Approved, Rejected, Marked Duplicate, Submitted to Fusion, Created in Fusion, and Integration Failed.
- Request detail shows current status, status history, timestamps, actor, and reviewer comments where applicable.
- Requester can see rejection, correction, or duplicate guidance in business language.
- If marked duplicate, requester sees the existing supplier reference to use instead.
- Invalid status transitions are blocked.

Verification: status transition tests and request-detail walkthrough.

#### FR-003: ATP Staging and Audit Data
**Priority:** Must

ATP shall be used as the staging, tracking, and audit database for the prototype. Fusion remains the supplier master system of record; ATP stores the request journey, validation evidence, duplicate evidence, risk scoring, AI summaries, and integration state.

Acceptance criteria:
- ATP stores request header, site/contact, optional bank/document metadata, status history, validation results, duplicate matches, risk assessments, AI summaries, integration logs, reference data, Fusion responses, and supplier number on success.
- All records are linked by request ID.
- ATP is not treated as the supplier master system of record.
- Records are available for audit, dashboards, retry, and demo reporting.

Verification: database inspection after demo scenarios.

#### FR-004: ORDS API Layer
**Priority:** Must

Visual Builder shall communicate with ATP through versioned ORDS APIs. The ORDS layer provides the application service boundary for request handling, validation, duplicate detection, risk scoring, AI summary retrieval, review actions, dashboards, logs, retry, and reference data.

Acceptance criteria:
- Visual Builder service connections target versioned ORDS endpoints.
- APIs return JSON payloads with consistent success/error envelopes.
- APIs enforce Requester, Reviewer, and Support/Admin access boundaries.
- APIs support request CRUD, submit, validation, duplicate check, risk score, AI summary, review actions, dashboards, logs, retry, and reference data lookups.
- API catalog is maintained in `technical-design.md`.

Verification: API tests and Visual Builder service connection review.

### Validation, Duplicate Detection, Risk, and AI

#### FR-005: Supplier Request Validation
**Priority:** Must

The application shall validate supplier request data before review and before Fusion submission. Validation should distinguish business data issues from technical integration errors so users receive the right message and support teams see the right diagnostic detail.

Acceptance criteria:
- Flags missing supplier name, country, supplier type, business unit, contact email, address/site context, and tax registration where applicable.
- Flags invalid business unit mapping and malformed contact email.
- Produces field-level validation result with rule code, severity, user-friendly message, blocking flag, and corrective guidance.
- Business validation errors are stored separately from OIC/Fusion technical errors.
- Blocking validation errors prevent approval until corrected or explicitly reclassified by approved policy.

Verification: validation test matrix.

#### FR-006: Duplicate Supplier Detection
**Priority:** Must

The application shall detect possible duplicate suppliers using exact and fuzzy matching against existing supplier reference data and staged requests. Duplicate detection is a primary project outcome and must be explainable to the Reviewer.

Acceptance criteria:
- Duplicate check runs after submission and before approval.
- Optional early duplicate preview can be provided while entering supplier data if schedule allows.
- Duplicate check compares against existing supplier reference data in ATP and relevant staged requests.
- Signals include normalized supplier name, tax registration, country, email domain, phone, address similarity, and bank token/hash when bank data is captured.
- Exact tax ID and same bank token/hash are Critical duplicate/risk triggers by default.
- Reviewer sees candidate supplier, score/level, and matched fields.

Verification: exact tax, fuzzy name, same bank, email/domain, and address match tests.

#### FR-007: Explainable Risk Scoring
**Priority:** Must

The application shall calculate an explainable supplier risk score and risk level. The risk model should be rules/configuration driven for the prototype and expose the reasons behind the result rather than presenting a black-box score.

Acceptance criteria:
- Uses Low, Medium, High, and Critical risk levels by default.
- Risk factors include missing tax, high-risk country, bank country mismatch, incomplete address, vague justification, high spend with weak justification, duplicate tax ID, same bank token/hash, duplicate score, missing documents, and invalid business unit mapping.
- Risk score stores scoring version, timestamp, score, level, and individual reasons.
- Reviewer can see each risk reason in business language.
- Risk can be recalculated after request correction.
- Thresholds/weights are seeded in ATP reference/config tables.

Verification: risk scoring test matrix and reference data inspection.

#### FR-008: AI-Assisted Explanation
**Priority:** Must

AI shall assist the Reviewer by explaining risk, duplicate indicators, missing information, and recommended review actions. AI remains advisory only and cannot perform business decisions or supplier creation.

Acceptance criteria:
- AI generates risk summary, duplicate explanation, missing information summary, and recommended reviewer actions only.
- AI does not approve, reject, mark duplicate, route escalation automatically, or create suppliers.
- AI receives curated facts only and does not receive full bank account numbers.
- AI output stores generated summary, prompt version, timestamp, provider/model metadata where available, and source risk/duplicate facts reference.
- AI summary can be regenerated after material request changes.
- Helpful/not-helpful feedback is documented as future enhancement, not phase-one scope.

Verification: AI/mock-AI output schema review.

### Review Workflow and Dashboards

#### FR-009: Manual Reviewer Decision Workflow
**Priority:** Must

The Reviewer shall remain the accountable business decision-maker. The application should support approval, rejection, correction requests, and duplicate marking while preventing high-risk or duplicate-risk requests from bypassing manual review.

Acceptance criteria:
- Reviewer can approve, reject, request correction, or mark duplicate.
- Approve is allowed only from Under Review and only when blocking validation is resolved.
- Reject, request correction, and mark duplicate require reviewer comment.
- Mark Duplicate requires existing supplier reference.
- High-risk or duplicate-risk requests cannot bypass manual review.
- Rejected and Marked Duplicate requests cannot be submitted/retried for Fusion creation.

Verification: workflow action and role tests.

#### FR-010: Role-Appropriate Dashboards and Filtering
**Priority:** Must

The application shall provide dashboards tailored to the three personas. Dashboards should help users find the right work quickly: requesters track their own requests, reviewers prioritize review work, and support/admin users troubleshoot integration issues.

Acceptance criteria:
- Requester dashboard shows own drafts, submitted, correction-needed, created, rejected, and duplicate-marked requests.
- Reviewer dashboard shows pending, under-review, high-risk, duplicate-risk, recently created, failed requests, and review queue.
- Support/Admin dashboard shows integration failures, retry eligibility, OIC instance IDs, retry counts, and reference/admin functions.
- Reviewer filters include business unit, country, supplier type, requester, status, risk level, duplicate risk, expected spend, and product/service category.
- Dashboard counts match filtered results.

Verification: dashboard demo and filter tests.

### Fusion/OIC Integration and Support

#### FR-011: Fusion Submission Through OIC or Mock
**Priority:** Must

Approved suppliers shall be submitted to Fusion through OIC, or through a realistic OIC-like mock if customer Fusion access is not available for the prototype. Visual Builder must not create suppliers directly in Fusion.

Acceptance criteria:
- OIC reads approved staged data from ATP/ORDS.
- OIC transforms request into Fusion supplier payload.
- OIC creates supplier header and at least one site where real Fusion access supports it.
- Bank account creation in Fusion is excluded in phase one; bank data is only captured, validated, and risk-scored.
- Fusion/mock success stores supplier number and response reference.
- Fusion/mock failure updates status to Integration Failed with error details.
- Visual Builder never submits directly to Fusion.

Verification: OIC or mock integration demo.

#### FR-012: Existing Supplier Reference Data
**Priority:** Must

The application shall use existing supplier reference data for duplicate detection. For the prototype, representative mock supplier master data is acceptable by default, while the design documents how OIC would synchronize real supplier data from Fusion.

Acceptance criteria:
- Prototype uses mock supplier master data in ATP by default, with OIC sync design documented for real Fusion.
- Reference data includes supplier number, name, country, tax registration, email domain, phone, address, site, and bank matching token where available.
- Duplicate detection uses supplier reference data, not only new staged requests.
- Sync/load metrics and errors are logged.

Verification: reference seed/sync test and duplicate detection tests.

#### FR-013: Integration Logging and Controlled Retry
**Priority:** Must

The application shall capture integration logs and support controlled retry for eligible failures. Business users should see clean business-safe messages, while Support/Admin users can inspect technical detail needed for troubleshooting.

Acceptance criteria:
- Logs include request ID, OIC instance ID, status, timestamp, payload reference, response reference, user-friendly message, technical message, retry eligibility, and retry count.
- Technical error details are visible to Support/Admin; business users see business-safe messages.
- Support/Admin can retry technical failures and corrected business failures.
- Retry is blocked for Rejected and Marked Duplicate requests.
- Retry attempts store actor, timestamp, and increment retry count.
- Retry uses request status/correlation safeguards to avoid duplicate supplier creation.

Verification: integration failure and retry demo.

### Governance, Sensitive Data, and Demo Readiness

#### FR-014: Sensitive Data and Reference Rule Controls
**Priority:** Must

The application shall protect sensitive supplier and bank data while allowing configured rules to support validation, duplicate detection, and risk scoring. Optional document handling is limited to metadata and missing-document indicators in phase one.

Acceptance criteria:
- Bank information is optional, masked in UI, and represented by token/hash for duplicate checks where captured.
- Full bank account number is not sent to AI or exposed in logs.
- Document metadata and missing-document flags are captured; full upload is excluded in phase one.
- High-risk countries, supplier types, business units, duplicate/risk thresholds, and mappings are stored as seed/reference data.
- Support/Admin can maintain selected reference data if included in scope.

Verification: security review and reference data inspection.

#### FR-015: Proposal and Demo Readiness
**Priority:** Must

The project shall produce a proposal-ready and demo-ready package before wireframes or build work begins. The package must include the functional baseline, technical design, assumptions, traceability, sample data, and demo scenarios needed to validate the approach with the customer.

Acceptance criteria:
- Documentation includes proposal, functional requirements, technical design, data model, API list, validation rules, risk scoring, duplicate logic, AI prompt approach, assumptions, limitations, demo script, traceability, and wireframe readiness.
- Sample data includes clean supplier, exact tax duplicate, fuzzy name duplicate, missing tax, bank country mismatch, incomplete address, same bank account, vague justification with high spend, and Fusion failure.
- Demo includes duplicate-risk request, clean supplier creation, high-risk incomplete request, and integration failure with retry.
- Wireframes are not generated until explicitly requested.

Verification: document review and demo walkthrough.

## Non-Functional Requirements

The following non-functional requirements apply across the prototype.

#### NFR-001: Oracle Stack Pattern
The design must demonstrate the requested Visual Builder, ORDS, ATP, OIC, and Fusion/mock Fusion architecture. UI-to-database interactions go through ORDS, and supplier creation goes through OIC or a documented OIC-like mock pattern.

Verification: architecture/design review and demo trace.

#### NFR-002: Role Separation
The application must enforce basic role separation for Requester, Reviewer, and Support/Admin User. Requesters cannot approve or retry, Reviewers do not receive sensitive technical payload access by default, and Support/Admin users cannot silently bypass review controls.

Verification: role access tests.

#### NFR-003: Explainability and Auditability
Validation, duplicate, risk, AI, and integration outcomes must be explainable and auditable. Validation errors have rule codes, duplicate candidates show matched fields, risk score shows contributing factors, AI output is timestamped/versioned, and integration logs include request/response references.

Verification: audit/log inspection.

#### NFR-004: Sensitive Data Protection
Sensitive supplier and bank data must be protected. Bank data is masked in UI, full bank values are not sent to AI, payload references do not expose sensitive data to unauthorized roles, and logs redact or secure sensitive values.

Verification: security review and masking tests.

#### NFR-005: Recoverable Failure Handling
Recoverable integration failures must not corrupt request state or create duplicate suppliers. OIC failures update status to Integration Failed, retries increment retry count and log attempts, and retry logic uses request status/correlation checks.

Verification: integration failure/retry tests.

#### NFR-006: Prototype Volume Without Hardcoding
The prototype should support realistic demo volumes without hardcoded demo-only logic. Duplicate checks should work over a few hundred reference suppliers, dashboards should filter 50-100 request records, and tests should not depend on one fixed demo ID.

Verification: volume smoke test.

#### NFR-007: Business-Friendly UI Language
Business users should see understandable messages. Requesters receive business-friendly missing-information messages, Reviewers see duplicate/risk explanations without reading logs, and Support/Admin technical detail is separated from business screens.

Verification: UX content review.

#### NFR-008: AI Guardrails
AI must remain an explanation aid only. Prompts instruct the model not to approve, reject, create suppliers, or mark duplicates; output schemas exclude final decision fields; and reviewer action is required for supplier creation.

Verification: AI prompt/output review.

## Business Rules

| Rule ID | Rule | Severity | Related Requirements |
|---|---|---|---|
| BR-001 | Supplier name, country, supplier type, business unit, contact email, business justification, product/service category, and at least one site/address context are required for submission. | Blocking | FR-001, FR-005 |
| BR-002 | Tax registration is required where country/supplier-type rule requires it. | Blocking or warning by configuration | FR-005, FR-007 |
| BR-003 | Exact tax ID match creates Critical duplicate/risk signal. | Critical | FR-006, FR-007 |
| BR-004 | Same bank token/hash creates Critical duplicate/risk signal when bank data is captured. | Critical | FR-006, FR-007, FR-014 |
| BR-005 | Bank country mismatch, high-risk country, vague justification, high spend with weak justification, incomplete address, missing documents, and invalid business unit mapping create risk reasons. | Warning or blocking by rule | FR-005, FR-007, FR-014 |
| BR-006 | Duplicate-risk or high-risk requests cannot be submitted to Fusion without Reviewer action. | Blocking | FR-007, FR-009, FR-011 |
| BR-007 | AI output cannot approve, reject, mark duplicate, route escalation automatically, retry integration, or create suppliers. | Blocking | FR-008 |
| BR-008 | Rejected and Marked Duplicate requests cannot be retried for Fusion creation. | Blocking | FR-009, FR-013 |

## Requirement Traceability

Detailed customer requirement traceability is maintained in `customer-requirements-traceability.md`.

## Answered Assumptions

The detailed question gate has been answered in `requirement-verification-questions.md` using conservative prototype assumptions from the customer transcript. These answers should be reviewed by the user/customer before final sign-off.
