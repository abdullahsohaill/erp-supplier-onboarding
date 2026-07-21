# UOW-001 Business Rules

## Rule Catalog

| Rule ID | Rule | Enforcement Point | Failure Outcome |
|---|---|---|---|
| CRI-BR-001 | Only an authenticated Requester can create a supplier request through the Requester command surface. | Authorization boundary | 401 or 403. |
| CRI-BR-002 | `requester_user` is derived from the authenticated principal and cannot be assigned by payload. | Create/update command | 400 for conflicting owner input or ignore by documented contract. |
| CRI-BR-003 | A Requester can list, view, update, submit, and resubmit only their own requests. | Every object-level operation | 403 without resource details. |
| CRI-BR-004 | Every created request starts in Draft with a unique request number and UTC timestamps. | Create Draft | Transaction rollback on generation/persistence failure. |
| CRI-BR-005 | Only Draft and Correction Requested requests are editable by a Requester. | Update command | 409. |
| CRI-BR-006 | An initial submit is allowed only from Draft; a resubmit is allowed only from Correction Requested. | Submit command | 409. |
| CRI-BR-007 | Draft data may be incomplete, but supplied values must satisfy type, length, format, and sensitive-data restrictions. | Create/update input validation | 400. |
| CRI-BR-008 | Submission requires supplier name, active supplier type, supplier country, active business unit with mapping, business justification, category, non-negative annual spend, at least one complete site, and at least one valid contact. | Governed submit validation | 422; editable status retained. |
| CRI-BR-009 | Each submitted site requires Address Line 1, Address Line 2, city, region/province/state, and country; each address line is at most 20 characters. Postal code is optional where not applicable. | Input and submit validation | 400 for over-length input; 422 for submit completeness. |
| CRI-BR-010 | At most one site is primary within a request. At least one site must be present at successful submission. | Aggregate update and submit validation | 400/422. |
| CRI-BR-011 | Contact email must be valid and its lowercase domain is derived server-side. Phone is normalized only for comparison; the display value is retained. | Aggregate update | 400. |
| CRI-BR-012 | Expected annual spend must be numeric and non-negative. | Input/database constraint | 400. |
| CRI-BR-013 | Tax registration is conditionally governed by supplier type and country. Missing tax is a baseline warning, not a universal blocker, unless Admin Settings changes the active policy. | UOW-002 governed validation | Warning or configured 422. |
| CRI-BR-014 | Bank metadata is optional. If provided, only bank country, masked display, last four digits, trusted hash/token, and provided flag may be persisted. | Input mapping | 400 for full/raw account data. |
| CRI-BR-015 | A client must never receive or submit a full bank account number through the phase-one API. | Input/output boundary | 400 and security event logging. |
| CRI-BR-016 | Document handling stores metadata and flags only; file content is outside phase one. | Attachment metadata command | 400 for unsupported binary/content fields. |
| CRI-BR-017 | Duplicate detection runs automatically during submit/resubmit. The Requester has no duplicate-preview command. | Submit orchestration | N/A; missing orchestration is a system failure. |
| CRI-BR-018 | Exact tax duplicate and same bank hash/token are critical blockers when their governed rules are active. | UOW-002 duplicate result | 422; editable status retained. |
| CRI-BR-019 | High-risk country is warning-only by baseline and does not independently block submission. | UOW-002 risk result | Submit may continue with warning. |
| CRI-BR-020 | Any active blocking validation prevents transition to Submitted and Under Review. | Submit orchestration | 422; editable status retained. |
| CRI-BR-021 | A successful submit/resubmit records both Submitted and Under Review transitions atomically and sets the final current status to Under Review. | Submit transaction | Full rollback on failure. |
| CRI-BR-022 | A failed submit attempt does not create a status-history transition or Reviewer queue entry. | Submit transaction | Editable status retained. |
| CRI-BR-023 | Ordinary field edits update `last_updated_at` but do not append status history. | Update command | N/A. |
| CRI-BR-024 | A stale update detected through expected `last_updated_at` must not overwrite newer data. | Update command | 409. |
| CRI-BR-025 | Requester reads exclude risk score/level/reasons, duplicate-candidate details, AI summaries, Reviewer selected factors, technical errors, and payload/response references. | Projection policy | Field omitted; leakage test fails build. |
| CRI-BR-026 | Requester reads may include business-safe comments, targeted correction items, final duplicate supplier reference, business-safe integration outcome, and Fusion supplier number. | Projection policy | N/A. |
| CRI-BR-027 | Calculated validation, duplicate, risk, AI, status, Fusion, and integration fields are server-managed and cannot be written through create/update payloads. | Input allowlist | 400. |
| CRI-BR-028 | All mutations fail closed and roll back on authorization, validation, persistence, audit, or orchestration failure. | Transaction boundary | Safe error response. |

## Status Transition Rules

| Current Status | Requester Command | Result |
|---|---|---|
| Draft | Update | Draft with changed fields. |
| Draft | Submit with blocker | Draft plus current business-safe findings. |
| Draft | Submit without blocker | Under Review after auditable Submitted transition. |
| Correction Requested | Update | Correction Requested with changed fields. |
| Correction Requested | Resubmit with blocker | Correction Requested plus current business-safe findings. |
| Correction Requested | Resubmit without blocker | Under Review after auditable Submitted transition. |
| Any other status | Update/submit/resubmit | 409 Conflict; no mutation. |

Transitions after Under Review are owned by UOW-003 and UOW-004.

## Payload Rules

### Client-Writable Header Fields

- Supplier name
- Supplier type code
- Supplier country code
- Business unit code, resolved server-side to its identifier
- Business justification
- Product/service category
- Expected annual spend
- Conditional tax registration number

### Client-Writable Child Fields

- Site name, address lines, city, region, country, postal code, intended business unit, and primary flag
- Contact name, email, and phone
- Optional masked bank metadata and trusted hash/token
- Document type, document status, required flag, metadata object, and missing flag

### Server-Managed Fields

- All technical identifiers
- Request number and requester owner
- Request status and lifecycle timestamps
- Email domain and other normalized comparison values
- Fusion identifiers and response reference
- Validation, duplicate, risk, AI, status-history, and integration outputs

Unknown fields are rejected instead of silently accepted.

## Validation Layering

| Layer | Responsibility |
|---|---|
| API shape validation | JSON structure, allowed fields, types, collection limits, string limits, date/number format. |
| Aggregate rules | Ownership, editable status, child ownership, one primary site, sensitive-data prohibition. |
| Governed submission validation | Active completeness, mapping, conditional tax, exact duplicate, bank duplicate, and other business rules. |
| Database constraints | Keys, nullability where physically defined, referential integrity, uniqueness, non-negative spend, valid JSON, approved status values. |

## Business-Safe Finding Contract

A Requester-visible finding contains only:

- Stable business code
- Field name where applicable
- Blocking or warning classification
- Business-safe message
- Suggested correction where applicable

It does not contain candidate supplier internals, scoring weights, raw matched values, bank hashes, AI evidence, SQL errors, stack traces, or technical diagnostics.

## Testable Rule Properties

| Property | Category | Rule Coverage |
|---|---|---|
| Owner isolation holds for every generated principal/request pair. | Invariant | CRI-BR-002, CRI-BR-003 |
| Generated Requester outputs contain none of the forbidden field set. | Invariant | CRI-BR-015, CRI-BR-025 |
| Every generated valid lifecycle command sequence follows the transition table. | Stateful model | CRI-BR-005, CRI-BR-006, CRI-BR-020 through CRI-BR-023 |
| Blocked submission never changes the editable status. | Invariant | CRI-BR-018 through CRI-BR-022 |
| Address lines longer than 20 characters are always rejected; lengths 0 through 20 are classified consistently with draft/submit rules. | Boundary invariant | CRI-BR-007, CRI-BR-009 |
| Valid masked bank inputs never produce a full-account-like value in persistence or output. | Invariant | CRI-BR-014, CRI-BR-015 |
| Domain serialization/deserialization preserves permitted values. | Round-trip | CRI-BR-007, CRI-BR-027 |

## Traceability

| Rules | Requirements/Stories |
|---|---|
| CRI-BR-001 through CRI-BR-007 | FR-001, FR-002, FR-004; US-001, US-002 |
| CRI-BR-008 through CRI-BR-020 | FR-001, FR-005; US-001, US-002 |
| CRI-BR-021 through CRI-BR-024 | FR-002, FR-003; US-001, US-002, US-003 |
| CRI-BR-025 through CRI-BR-028 | FR-002, FR-003, FR-004; US-003 |
