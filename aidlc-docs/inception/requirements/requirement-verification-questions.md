# Detailed Requirement Verification Questions

These questions are answered using the customer transcript and conservative three-week prototype assumptions. Review these answers before customer sign-off.

## Section 1: Scope and Personas

## Question 1
Should the prototype role model be locked to exactly three personas?

A) Yes: Requester, Reviewer, and Support/Admin User.

B) No: keep the three primary personas, but document extra stakeholder personas for finance, compliance, and master data governance.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: The user clarified there is a single reviewer, so the application model should stay at three personas.

## Question 2
For the single Reviewer persona, should the reviewer own all review decisions in the prototype?

A) Yes: the single reviewer handles completeness, duplicate, payment warning, compliance/risk, approve, reject, request correction, and mark duplicate actions.

B) Partially: the reviewer performs most actions, but certain high-risk cases should be shown as requiring escalation outside the system.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Phase one does not require enterprise approval workflow or escalation routing.

## Question 3
Should `Correction Requested` be included as a formal status/action?

A) Yes: reviewers can send incomplete requests back without rejecting them.

B) No: keep only approve, reject, and mark duplicate.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Correction is useful for incomplete requests and avoids unnecessary rejection.

## Section 2: Request Intake and Data Capture

## Question 4
Which supplier request fields should be mandatory at submission?

A) Supplier name, country, supplier type, business unit, contact email, address, requester, business justification, product/service category, and at least one site.

B) Same as A, plus tax registration number for all suppliers.

C) Same as A, with tax registration required only based on country/supplier type rules.

X) Other (please describe after `[Answer]:`).

[Answer]: C

Rationale: The transcript says tax registration is mandatory where applicable, not universally.

## Question 5
How should bank information be handled in phase one?

A) Optional capture; validate if provided; mask display; use token/hash for duplicate checks; do not create bank accounts in Fusion.

B) Required capture for every supplier request; validate and include in Fusion payload where possible.

C) Do not capture bank details; only capture whether bank details are pending/provided.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Bank details may not always be available initially, but if provided they are important for risk/duplicate checks.

## Question 6
How should supplier sites be handled?

A) Require exactly one site for phase one, with a model that can support multiple later.

B) Support multiple supplier sites in phase one.

C) Capture only intended business unit/site intent, not full supplier site details.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: The transcript says at least one site is acceptable for phase one.

## Question 7
How should attachments/documents be handled?

A) Capture document metadata and missing-document flags only; no file upload in phase one.

B) Implement actual attachment upload in Visual Builder/ATP or object storage.

C) Exclude attachments entirely from phase one.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: The customer said attachments are nice-to-have and metadata is enough.

## Section 3: Validation and Duplicate Detection

## Question 8
When should duplicate detection run?

A) Required after submission and before approval; optional early warning while entering supplier name/tax/email if time allows.

B) Real-time while entering data must be included in phase one.

C) Only after submission; no real-time checks.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: The transcript says real-time is nice, but post-submission is acceptable for phase one.

## Question 9
Which duplicate signals should be included in phase one?

A) Supplier name similarity, tax registration, country, email domain, phone, address similarity, and bank token/hash if bank data is captured.

B) Only tax ID, supplier name, and country.

C) Full set including bank, address, phone, email domain, site, and business unit.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: This matches the transcript without over-weighting site/business unit as core duplicate signals.

## Question 10
Should exact tax ID match and same bank account be treated as Critical duplicate/risk triggers?

A) Yes: exact tax ID or same bank token/hash should trigger Critical.

B) No: use only Low, Medium, and High levels.

C) Tax ID should be Critical, bank account should be High.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Tax ID and bank account were called out as strong/serious indicators.

## Question 11
Should duplicate thresholds and weights be configurable?

A) Yes: store thresholds/weights in ATP reference tables, with no UI maintenance in phase one.

B) Yes: make them maintainable by Support/Admin UI in phase one.

C) No: hardcode thresholds for the prototype.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Config tables keep the prototype realistic without requiring extra admin UI scope.

## Section 4: Risk Scoring

## Question 12
Which risk levels should the prototype use?

A) Low, Medium, High, and Critical.

B) Low, Medium, and High only.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Critical is useful for exact tax ID or same bank token/hash.

## Question 13
Which risk factors must be included?

A) Missing tax, high-risk country, bank country mismatch, incomplete address, vague justification, high spend with weak justification, duplicate tax ID, same bank account, and duplicate score.

B) Only missing tax, high-risk country, bank mismatch, and duplicate score.

C) Include all of A plus missing documents and invalid business unit mapping.

X) Other (please describe after `[Answer]:`).

[Answer]: C

Rationale: The transcript includes missing documents as a flag and invalid business unit mapping as a likely failure/demo scenario.

## Question 14
How should high-risk country rules be maintained?

A) ATP reference table maintained by support/admin user or seed script.

B) Hardcoded list for prototype.

C) External risk/sanctions service integration.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Customer wanted configurable internal indicators and no third-party dependency in phase one.

## Question 15
What should count as a vague business justification?

A) Simple keyword/length heuristic for prototype, such as too short or generic phrases like "needed for project."

B) AI-assisted classification, with deterministic reviewer-visible reason.

C) Reviewer decides manually; system only displays justification.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Deterministic heuristic is safer and easier to explain for phase one.

## Section 5: AI Assistance

## Question 16
Which AI runtime/provider should be assumed?

A) Customer-approved enterprise AI service, with exact provider left as implementation decision.

B) Oracle AI services if available in the tenancy.

C) OpenAI API for prototype only, subject to customer approval.

D) No live AI service; mock AI summaries for the demo.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: The customer wants AI safely, but provider choice should follow customer approval and environment constraints.

## Question 17
What should AI be allowed to generate?

A) Risk summary, duplicate explanation, missing information summary, and recommended reviewer actions only.

B) Same as A, plus suggested corrected business justification text for the requester.

C) Same as A, plus automatic routing/escalation recommendation.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Keeps AI advisory and avoids scope creep or automated routing decisions.

## Question 18
Should AI prompt and response history be stored?

A) Store generated summary, prompt version, timestamp, model/provider, and source risk/duplicate facts; avoid storing full sensitive prompt text if it includes bank data.

B) Store full prompt and full response for complete auditability.

C) Store only latest summary text and timestamp.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Balances auditability with sensitive data minimization.

## Question 19
Should helpful/not-helpful AI feedback be included?

A) No, document as future enhancement.

B) Yes, capture simple helpful/not-helpful flag and optional comment.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Customer said it would be nice but not mandatory.

## Section 6: Oracle Fusion, OIC, and APIs

## Question 20
Which Fusion integration mode should be targeted first?

A) Mock Fusion endpoints first, then switch to real Fusion APIs when credentials and roles are ready.

B) Real Fusion APIs from day one.

C) Hybrid: real supplier reference sync, mock supplier creation.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Customer explicitly allowed mock payloads if Fusion access is limited, while keeping the pattern realistic.

## Question 21
How should supplier creation be performed after approval?

A) OIC calls Fusion Supplier REST API with supplier header and at least one site where possible.

B) OIC creates only supplier header in Fusion; site is mocked or deferred.

C) OIC writes a Fusion-like mock payload only for prototype.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Customer expects supplier creation and at least one site where feasible.

## Question 22
Should bank account creation in Fusion be included in phase one?

A) No: capture/validate/risk-score bank details only; do not create Fusion bank accounts.

B) Yes: create supplier bank account records in Fusion if API access is available.

C) Mock bank account payload only.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Bank data is sensitive and phase-one value can be shown without Fusion bank account creation.

## Question 23
How should existing supplier data be loaded for duplicate checks?

A) Mock supplier master data in ATP for prototype, with documented OIC sync design.

B) OIC real sync from Fusion supplier APIs.

C) CSV/manual seed into ATP, no OIC sync in prototype.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Mock data is acceptable if realistic, while the design still documents OIC sync.

## Question 24
What integration log detail should be visible in the UI?

A) OIC instance ID, request ID, status, user-friendly error, technical error, timestamp, retry count, payload reference, and response reference.

B) Same as A, but hide technical error from business reviewer and show it only to support/admin.

C) Minimal log only: status, timestamp, and error message.

X) Other (please describe after `[Answer]:`).

[Answer]: B

Rationale: Business users need understandable status; technical details should be limited to Support/Admin.

## Section 7: Dashboards and Workflow

## Question 25
Which dashboard views are required?

A) Requester dashboard, reviewer queue/dashboard, and support/admin integration dashboard.

B) Requester and reviewer dashboards only.

C) Single shared dashboard with role-based filters.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Transcript explicitly separates requester/reviewer visibility and IT support log needs.

## Question 26
Which reviewer filters are required?

A) Business unit, country, supplier type, requester, status, risk level, and duplicate risk.

B) Same as A, plus expected annual spend and product/service category.

C) Status and risk only.

X) Other (please describe after `[Answer]:`).

[Answer]: B

Rationale: Spend and category are captured fields and useful for prioritizing review.

## Question 27
Which retry behavior should be supported?

A) Support/admin can retry technical failures and corrected business failures; retry is blocked for duplicate/rejected requests.

B) Reviewer can retry integration failures directly.

C) No retry UI; support reruns OIC manually.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Retry is a support/admin concern and must not bypass duplicate/rejected outcomes.

## Section 8: Security and Non-Functional Requirements

## Question 28
Should the AI-DLC Security Baseline extension be enforced as a blocking design constraint?

A) Yes, enforce security rules for the proposal and design because bank data and ERP supplier data are sensitive.

B) No, keep security as guidance only because this is a short prototype.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: ERP supplier and bank data require security-by-design even in prototype.

## Question 29
Should the resiliency baseline be applied?

A) Yes, apply it as design-time guidance for OIC retries, observability, idempotency, and recovery.

B) No, keep resiliency lightweight for prototype speed.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Retry, integration logs, and idempotency are core to the requested exception handling.

## Question 30
Should property-based testing be included in the technical plan?

A) Partial: apply it to deterministic scoring, duplicate matching normalization, and payload transformations only.

B) Yes, apply it broadly as a blocking rule.

C) No, use conventional unit and integration tests only.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: It is useful for deterministic matching/scoring logic without overburdening the prototype.

## Section 9: Demo and Delivery

## Question 31
Which demo scenarios must be shown?

A) Duplicate-risk request, clean supplier creation, high-risk incomplete request, and integration failure with retry.

B) Same as A, plus real-time duplicate warning while typing supplier details.

C) Only clean supplier creation and duplicate-risk request.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Matches the customer’s requested success and exception scenarios without making real-time preview mandatory.

## Question 32
What should be the source of demo data?

A) Mock data created by us, covering all customer-requested scenarios.

B) Customer-provided anonymized supplier master sample.

C) Mix of customer-provided supplier master and our mock edge-case requests.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Customer said mock data is acceptable if representative.

## Question 33
What is the expected output of this current proposal phase?

A) Proposal, functional requirements, technical design, API list, data model, validation/risk/duplicate logic, demo script, assumptions, and verification questions.

B) Same as A, plus implementation-ready database DDL and ORDS OpenAPI specs.

C) Same as A, plus a wireframe-ready screen inventory only, without creating the actual wireframe yet.

X) Other (please describe after `[Answer]:`).

[Answer]: C

Rationale: The current phase should be wireframe-ready but should not create wireframes until requested.

## Question 34
Is the three-week prototype timeline fixed?

A) Yes, design for a three-week prototype and keep scope tight.

B) Flexible: prioritize completeness over the three-week target.

C) Split into a two-week demo and a later hardening phase.

X) Other (please describe after `[Answer]:`).

[Answer]: A

Rationale: Customer expectation is approximately three weeks, so scope should remain tight.
