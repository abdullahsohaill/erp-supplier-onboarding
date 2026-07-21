# UOW-001 Business Logic Model

## Purpose

UOW-001 manages supplier-request capture, requester ownership, editable-state changes, submit/resubmit orchestration, request status visibility, and the auditable transition into the Reviewer queue. It implements US-001 through US-003 without making review, risk, duplicate, AI, or Fusion decisions.

## Functional Boundary

UOW-001 owns:

- Create a Requester-owned Draft.
- Read and update the Requester's own Draft or Correction Requested request.
- Persist request header, sites, contacts, optional bank metadata, and document metadata.
- Attempt submit or resubmit.
- Preserve the editable status when blocking findings exist.
- Atomically transition a successful attempt through Submitted to Under Review.
- Return role-safe request summaries, details, status history, and actionable guidance.

UOW-001 invokes but does not own:

- Governed validation, duplicate detection, and risk calculation from UOW-002.
- Reviewer decisions and structured correction envelopes from UOW-003.
- OIC/Fusion submission and integration retry from UOW-004.
- Admin Settings maintenance from UOW-005.

## Request Aggregate

The aggregate root is `SupplierRequest`. Its transactional boundary contains:

| Aggregate Member | Cardinality | Responsibility |
|---|---:|---|
| Supplier request header | Exactly 1 | Ownership, lifecycle, supplier/business data, Fusion outcome references. |
| Sites | 1 or more at successful submission | Structured address and intended business-unit context. |
| Contacts | 1 or more at successful submission | Supplier contact details and normalized email domain. |
| Bank metadata | 0 or 1 in phase one | Optional masked/hash metadata; never a full account number. |
| Document metadata | 0 or more | Metadata, requirement, status, and missing flags; no file content. |
| Status history | Append-only | Successful status transitions and later Reviewer guidance. |

Drafts may be incomplete. Submission completeness is evaluated only during submit/resubmit, allowing Requesters to save work incrementally.

## Command Model

### Create Draft

Input: authenticated Requester principal plus a syntactically valid partial request payload.

Processing:

1. Derive `requester_user` from the authenticated principal; ignore or reject a client-supplied owner.
2. Allocate `request_id` using an Oracle-generated numeric identity.
3. Derive a stable request number using `REQ-<UTC year>-<zero-padded request_id>` and enforce uniqueness.
4. Set status to Draft and assign UTC creation/update timestamps.
5. Persist any supplied header, site, contact, bank, and document metadata in one transaction.
6. Append a Draft-created status-history action.
7. Return HTTP 201 with the request number, Draft status, and current representation.

### Update Editable Request

Input: request ID, authenticated Requester principal, mutation payload, and expected `last_updated_at` value where supplied.

Preconditions:

- The request exists.
- The principal owns it.
- Status is Draft or Correction Requested.
- Any supplied child identifier belongs to the same request.
- The expected update timestamp matches when optimistic concurrency is requested.

Processing:

1. Lock the request row for the short update transaction.
2. Validate payload shape, types, lengths, formats, and sensitive-data restrictions.
3. Apply header and child upserts/removals within the aggregate boundary.
4. Ensure no second primary site is introduced.
5. Update `last_updated_at` in UTC.
6. Do not create status history for ordinary field edits because no lifecycle transition occurred.
7. Return the updated role-safe representation.

### Submit or Resubmit

Input: request ID and authenticated Requester principal.

Preconditions:

- The request exists and is owned by the principal.
- Initial submit starts in Draft; resubmit starts in Correction Requested.

Processing:

1. Lock and read the current aggregate snapshot.
2. Invoke the active governed validation rules.
3. Invoke duplicate detection automatically; no Requester duplicate-preview action exists.
4. Invoke risk calculation for deterministic downstream Reviewer evidence.
5. If a blocking validation or critical duplicate trigger exists:
   - Persist the current run's governed findings through UOW-002.
   - Keep Draft for initial submit or Correction Requested for resubmit.
   - Do not append Submitted or Under Review status history.
   - Do not expose internal duplicate/risk evidence to the Requester.
   - Return HTTP 422 with business-safe, field-addressable findings.
6. If no blocker exists:
   - Mark previous validation, duplicate, and risk runs non-current as governed by UOW-002.
   - Append Draft/Correction Requested to Submitted history with `SUBMIT` or `RESUBMIT`.
   - Set `submitted_at` in UTC.
   - Append Submitted to Under Review history with `AUTO_ROUTE_TO_REVIEW`.
   - Persist final status Under Review.
   - Commit the status, history, and calculated outputs atomically.
7. Return HTTP 200 with Under Review status and business-safe warning messages, if any.

No transaction remains open across a remote AI, OIC, or Fusion call. Those operations do not participate in request submission.

### Read Request List

Requester scope always applies `requester_user = authenticated principal`. Supported business filters include status and stable pagination/sort inputs. The list projection contains request number, supplier name, status, next action, timestamps, and final Fusion supplier number where applicable. It excludes internal risk, duplicate, AI, and technical-integration evidence.

### Read Request Detail

The Requester detail projection contains:

- Own request header, sites, contacts, masked bank metadata, and document metadata.
- Current status and business-safe status timeline.
- Current actionable correction items and Reviewer comment parsed by UOW-003.
- Existing supplier reference after Marked Duplicate.
- Fusion supplier number after Created in Fusion.
- Business-safe integration outcome where relevant.

It never contains risk score, risk level, risk reasons, duplicate candidate details, AI summaries, Reviewer-only selected factors, technical errors, raw payloads, response payloads, or full bank data.

## Query Model

| Query | Actor Scope | Output |
|---|---|---|
| List own requests | Requester owner | Paginated role-safe request summaries. |
| Get own request | Requester owner | Aggregate detail plus role-safe timeline and guidance. |
| Get attachment metadata | Requester owner | Document metadata and missing flags only. |
| Get validation findings | Requester owner | Business-safe findings needed to correct or submit; no internal duplicate/risk evidence. |
| Requester dashboard summary | Requester | Counts computed only from the principal's requests. |

Reviewer and Support/Admin read scopes use the same persisted aggregate but are defined by UOW-003/UOW-005 projections.

## Transaction and Consistency Model

| Operation | Atomic Boundary | Failure Result |
|---|---|---|
| Create Draft | Header, supplied children, Draft history | Entire create rolls back. |
| Edit request | Header and affected children | Entire edit rolls back; existing aggregate remains unchanged. |
| Blocked submit | Current governed findings plus unchanged request status | HTTP 422; no queue entry or lifecycle transition. |
| Successful submit | Current findings, Submitted history, Under Review history, header timestamps/status | Entire transition rolls back on any persistence failure. |
| Read projection | Consistent query snapshot | Safe not-found/forbidden response without data leakage. |

Database constraints protect structural integrity. Command rules protect conditional completeness, ownership, status transitions, and role-safe output.

## Error Outcomes

| Condition | Category | HTTP Status | Observable Result |
|---|---|---:|---|
| Invalid JSON/type/length/format | INPUT_VALIDATION | 400 | No mutation; field-safe message. |
| Unauthenticated | AUTHENTICATION | 401 | No resource information disclosed. |
| Wrong role or non-owner | AUTHORIZATION | 403 | No request details disclosed. |
| Unknown request | NOT_FOUND | 404 | No mutation. |
| Stale update or invalid status transition | CONFLICT | 409 | Existing state retained. |
| Governed submit blocker | BUSINESS_VALIDATION | 422 | Findings returned; editable status retained. |
| Unexpected database/service failure | SYSTEM_ERROR | 500 | Transaction rolled back; generic user message and internal trace ID. |

## Testable Properties

| Component/Operation | Category | Property |
|---|---|---|
| Request payload mapping | Round-trip | For valid domain payloads, API-to-domain-to-role-safe-API mapping preserves all permitted business values, except documented normalization/derived fields. |
| Requester projection | Invariant | Projection never contains Reviewer-only risk, duplicate, AI, technical error, payload, response, or selected-factor fields. |
| Request ownership filter | Invariant | Every list/detail result belongs to the authenticated Requester. |
| Request number generation | Invariant/easy verification | Every generated number matches the approved format and is unique for its request identity. |
| Editable-state command | Invariant | A successful edit never changes the request status. |
| Submit blocker handling | Invariant | A blocked initial submit remains Draft; a blocked resubmit remains Correction Requested; neither creates queue history. |
| Successful submit | Stateful model | Valid command sequences follow only approved transitions and end in Under Review after submit/resubmit. |
| Update retry with same representation | Idempotence | Reapplying the same complete editable representation leaves observable business state equivalent apart from the update timestamp. |
| Masked bank projection | Invariant | No generated Requester response contains a full account number or unmasked bank token/hash. |

These properties must be carried into the UOW-001 code-generation plan. Domain-specific generators must create realistic requests, addresses, contacts, optional bank metadata, document metadata, owners, and valid/invalid lifecycle command sequences.

## Traceability

| Story | Covered Behavior |
|---|---|
| US-001 | Draft creation, partial save, complete submit, aggregate persistence, automatic blocker orchestration. |
| US-002 | Correction Requested edit/resubmit, guidance visibility, blocker preservation, successful reroute. |
| US-003 | Owner-scoped list/detail, timeline, business outcome, duplicate/Fusion guidance, hidden internal evidence. |
| FR-001 | Guided request data, unique request number, ATP staging through service boundary. |
| FR-002 | Approved status model, transition enforcement, role-safe visibility. |
| FR-003 | Core request and audit persistence boundaries. |
| FR-004 | Versioned request API behavior and consistent envelopes. |

## Extension Compliance

| Extension | Status | Functional-Design Assessment |
|---|---|---|
| Security Baseline | Compliant for applicable design rules | Deny-by-default authentication, Requester ownership checks, input allowlists/bounds, sensitive-data rejection, role-safe projection, atomic audit history, safe errors, and fail-closed rollback are explicit. Runtime TLS, OAuth configuration, dependency scanning, and operational monitoring are deferred to NFR/infrastructure/code stages. |
| Resiliency Baseline | Compliant for applicable design rules | Short transactions, atomic status/history updates, blocker-state preservation, optimistic conflict handling, and no transaction across remote dependencies are explicit. Production RTO/RPO, backup, scaling, and alert topology are N/A in technology-agnostic functional design. |
| Property-Based Testing, Partial | Compliant | PBT-01 is advisory in partial mode but is fully addressed. Round-trip, invariant, idempotence, stateful-model, and easy-verification properties are identified for later code-generation planning. PBT framework configuration and execution are deferred to NFR/code/build stages. |

No applicable enabled-extension blocking finding remains for UOW-001 Functional Design.
