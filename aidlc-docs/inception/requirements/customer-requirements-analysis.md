# Customer Requirements Analysis

## Source

Primary source: `Integration ERP.pdf`, a 14-page customer requirement discovery call transcript.

The highlighted PDF has the same extractable transcript text. It should still be retained as a visual source copy in case highlighted emphasis is useful in stakeholder review.

## Highlighted Emphasis From Source

The highlighted version visually emphasizes these proposal-critical themes:
- The problem is supplier onboarding standardization, not only an integration exercise.
- Duplicate supplier prevention is a primary requirement.
- The process must separate request intake, staging, validation, review, and Fusion creation.
- AI is for explanation and recommendation only, not decision automation.
- Existing Fusion supplier master data must be available in ATP for duplicate checks.
- Bank data handling must be careful and masked.
- Status visibility and integration failure diagnostics are part of the expected value.

## Customer Goal

The customer wants a realistic Oracle-stack prototype for supplier onboarding that reduces duplicate supplier creation, improves supplier request data quality, exposes risk before supplier creation, and gives requesters/reviewers/IT clear status visibility.

The solution must use:
- Oracle Visual Builder for the application UI.
- Oracle ATP as staging and tracking database.
- ORDS REST APIs between Visual Builder and ATP.
- Oracle Integration Cloud for Oracle Fusion ERP integration.
- Oracle Fusion ERP as the supplier master system of record.
- AI only for explanation, summarization, and recommendation. AI must not approve, reject, or create suppliers.

## Stakeholder View

### Procurement Operations
Priya's main concern is process standardization. Supplier requests currently arrive through email, spreadsheets, and service desk tickets. The desired application should provide a guided form, status tracking, and a reviewer workflow.

### Finance Shared Services
James is concerned about downstream Payables impact. Duplicate suppliers and incorrect supplier sites cause payment errors, poor reporting, and unreliable spend analysis. Finance also needs visibility into requests that fail during Fusion creation.

### IT Integration
Omar wants a clean architecture: Visual Builder should not write directly to Fusion. ATP should stage and track requests. ORDS should expose ATP-backed APIs. OIC should own Fusion integration. Business validation failures must be distinguishable from technical integration failures.

### Master Data Governance
Linda considers duplicate detection central, not secondary. The system must compare new requests against existing Fusion supplier master data, not only against new requests in the staging app.

### Compliance and Risk
Rachel wants early risk identification and explainable scoring. Risk should be based on transparent factors such as missing tax data, bank country mismatch, high-risk country, duplicate tax ID, same bank account, incomplete address, and vague business justification.

## Current Pain Points

- Supplier request intake is fragmented across emails, spreadsheets, and tickets.
- Required data is inconsistent and often incomplete.
- Duplicate suppliers are created due to name variation, abbreviation, missing tax details, or weak matching.
- Users cannot easily track request status.
- Reviewers lack a clear risk explanation.
- Integration failures are not separated from business validation errors.
- Sensitive bank data must be handled carefully.

## Scope For Phase One Prototype

Included:
- Guided supplier request submission.
- One supplier with at least one supplier site.
- ATP staging and request tracking.
- ORDS API layer.
- Duplicate detection using exact and fuzzy signals.
- Explainable risk scoring.
- AI-generated risk and duplicate explanation.
- Manual review/approve/reject/mark duplicate/request correction.
- OIC submit-to-Fusion pattern.
- Existing supplier master sync pattern.
- Mock Fusion payloads if Fusion access is unavailable.
- Dashboard and integration logs.
- Retry for eligible failures.
- Demo scenarios covering success, duplicate risk, high risk, and integration failure.

Excluded from phase one:
- Full enterprise approval workflow.
- Supplier merge.
- Existing supplier updates.
- Third-party sanctions or external risk services.
- Email notifications.
- Full attachment upload, unless time allows. Document metadata and missing-document flags are enough.
- AI-based final approval/rejection/creation decisions.

## Expected Demo Scenarios

1. Requester submits a new supplier from Visual Builder.
2. System detects a possible duplicate because of similar name and/or matching tax ID.
3. AI explains duplicate and risk reasons in reviewer-friendly language.
4. Reviewer rejects or marks duplicate and references the existing supplier.
5. Clean supplier request is approved and submitted to Fusion.
6. Fusion returns a supplier number and the request is updated.
7. One integration failure is shown in support dashboard with OIC instance ID, error, retry count, and retry action.

## Prototype Timeline

Customer expectation: approximately three weeks for a realistic end-to-end prototype.

## Key Design Implications

- Duplicate detection must be explainable and auditable.
- Risk scoring must be rule-based and transparent, not black-box.
- AI output must be stored with timestamp and regeneratable after data changes.
- Bank account display should be masked, preferably last four digits only.
- ATP is not the supplier master. Fusion remains the system of record.
- Existing supplier data must be synchronized into ATP for duplicate checking.
- The solution should be designed to swap mock Fusion calls with real Fusion APIs.

## Requirements Audit

Detailed traceability is maintained in `aidlc-docs/inception/requirements/customer-requirements-traceability.md`.
