# UOW-001 Frontend Component Contract

## Scope

This artifact defines the Requester interaction contract used by the existing wireframe and a future Oracle Visual Builder implementation. The approved local construction iteration implements the ATP/ORDS backend and automated tests; it does not generate a new production Visual Builder application unless separately approved.

## Component Hierarchy

| Screen/Component | Responsibility | Primary API Interaction |
|---|---|---|
| Requester Dashboard | Show owner-scoped counts and request rows. | GET requester summary; GET requests. |
| My Supplier Requests table | Show request number, supplier, status, next action, and Actions column. | GET requests. |
| Supplier Request Form | Create Draft, edit Draft, or edit/resubmit Correction Requested. | POST request; PATCH request; POST submit. |
| Request Form sections | Capture supplier/business, contact, site/address, optional bank metadata, and document metadata. | Local form state mapped to create/update payload. |
| Request Detail | Show permitted aggregate details, current status, next action, and final outcome. | GET request detail. |
| Status Timeline | Show business-safe history entries and Reviewer guidance. | Included in request detail. |
| Validation Summary | Show field-addressable submit blockers/warnings. | Submit response; GET validation results. |
| Document Metadata panel | Maintain metadata/status/missing indicators only. | GET attachments; POST attachment metadata. |

## Requester Dashboard Behavior

| Request Status | Actions Cell | Interaction |
|---|---|---|
| Correction Requested | `Edit and Resubmit` | Opens the corresponding request in correction mode. |
| Any other status | `None` | Plain, non-clickable text. |

The table does not contain a risk column. Request numbers may open the correctly identified request detail only when row-specific navigation is implemented; no row may route to a hardcoded sample request.

## Form Modes

| Mode | Entry | Editable | Primary Command |
|---|---|---:|---|
| New Draft | Create request | Yes | Save Draft or Submit. |
| Edit Draft | Open owned Draft | Yes | Save Draft or Submit. |
| Correction | Open owned Correction Requested | Yes | Save changes or Edit and Resubmit. |
| Read-only | Any other status | No | Return/view status only. |

## Form Sections and State

### Supplier and Business

- Supplier name
- Supplier type
- Supplier country
- Business unit
- Business justification
- Product/service category
- Expected annual spend
- Conditional tax registration number

### Contact

- Contact name
- Contact email
- Phone number

### Site and Address

- Site name where needed
- Address Line 1, maximum 20 characters
- Address Line 2, maximum 20 characters
- City
- Province/State/Region
- Country
- Postal code where applicable
- Intended business unit and primary-site indicator where multiple sites are enabled

### Optional Bank Metadata

- Bank details provided toggle
- Bank country
- Masked display/last four
- Trusted token/hash boundary input where applicable

The UI never captures or displays a full account number in phase one.

### Document Metadata

- Document type
- Metadata status
- Required/missing indicators
- Descriptive metadata only

No production file upload is implied.

## Client Validation

Client validation improves usability but never replaces server validation.

| Input | Client Rule |
|---|---|
| Address lines | Live character count; reject more than 20 characters. |
| Email | Basic format validation and clear field message. |
| Annual spend | Numeric and non-negative. |
| Country/type/business unit | Select from active lookup values. |
| Submit-required fields | Highlight missing fields on submit, while allowing incomplete Draft save. |
| Bank metadata | Reveal dependent fields only when provided toggle is on; never request full account value. |
| Unknown/server-managed fields | Never include in mutation payload. |

## Submit Interaction

1. Disable repeated submission while one request is in progress.
2. Save current editable values if needed.
3. Call submit/resubmit; duplicate detection runs automatically on the server.
4. On success, navigate to Request Detail showing Under Review.
5. On HTTP 422, remain in the current form mode and display business-safe field findings.
6. On HTTP 409, reload the latest status and explain that the request is no longer editable or was changed elsewhere.
7. On authentication/authorization failure, do not display any cached protected data.
8. On technical failure, retain local unsaved input where safe and show a generic retry message with trace ID.

No `Run Duplicate Preview` button or duplicate-preview panel exists.

## Requester-Safe Detail Model

Allowed:

- Supplier and request fields owned by the Requester
- Masked bank display only
- Document metadata
- Current status and safe history
- Correction/rejection guidance
- Final existing supplier reference after Marked Duplicate
- Fusion supplier number after Created in Fusion
- Business-safe integration status

Prohibited:

- Risk score, level, reasons, factors, or weights
- Duplicate candidate details or matched-field evidence
- AI summary or prompts
- Reviewer-selected factors
- Technical integration errors
- Raw payloads/responses
- Bank hashes/tokens or full account data

## Stable Automation Identifiers

A future Visual Builder implementation should provide stable identifiers equivalent to:

| Element | Stable Test Identifier |
|---|---|
| New request command | `requester-dashboard-new-request-button` |
| Request table | `requester-dashboard-requests-table` |
| Correction action | `requester-request-edit-resubmit-button` |
| Request form | `supplier-request-form` |
| Save Draft command | `supplier-request-save-draft-button` |
| Submit command | `supplier-request-submit-button` |
| Address fields | `supplier-request-address-line-1-input`, `supplier-request-address-line-2-input` |
| Validation summary | `supplier-request-validation-summary` |
| Status timeline | `request-detail-status-timeline` |

Identifiers are contract examples; they do not add ATP fields.

## API Mapping

| User Interaction | Method/Path |
|---|---|
| Create Draft | POST `/requests` |
| List own requests | GET `/requests` |
| View own request | GET `/requests/{requestId}` |
| Update editable request | PATCH `/requests/{requestId}` |
| Submit/resubmit | POST `/requests/{requestId}/submit` |
| View safe findings | GET `/requests/{requestId}/validation-results` |
| View document metadata | GET `/requests/{requestId}/attachments` |
| Maintain document metadata | POST `/requests/{requestId}/attachment-metadata` |
| Requester counts | GET `/dashboard/requester-summary` |
| Business-unit lookup | GET `/reference/business-units` |
| Supplier-type lookup | GET `/reference/supplier-types` |

The versioned base path remains `/ords/erp/supplier-onboarding/v1`.

## Frontend State Invariants

- Edit controls are enabled only for Draft and Correction Requested owned requests.
- Edit and Resubmit appears only for Correction Requested rows.
- Every other Actions cell displays non-clickable `None`.
- A 422 response never navigates to the Reviewer queue or changes the displayed editable status.
- Requester state never stores or renders internal risk, duplicate, AI, or technical evidence.
- A row/detail action always uses that row's request identity.

## Traceability

| Story | Components |
|---|---|
| US-001 | Request form, Draft save, submit behavior, validation summary. |
| US-002 | Correction mode, Reviewer guidance, Edit and Resubmit action. |
| US-003 | Dashboard, request detail, status timeline, final outcome. |
