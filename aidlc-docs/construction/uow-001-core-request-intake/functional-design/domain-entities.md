# UOW-001 Domain Entities

## Aggregate Overview

`SupplierRequest` is the aggregate root. Its child entities are persisted only in the context of their owning request. `StatusHistoryEntry` is append-only. Validation, duplicate, risk, AI, and integration entities are external evidence aggregates consumed by later units.

## SupplierRequest

| Domain Field | Physical Field | Type/Rule |
|---|---|---|
| Request identity | `SUPPLIER_REQUEST.request_id` | Generated positive integer; immutable. |
| Request number | `request_number` | Unique `REQ-<year>-<id>` display identifier; immutable. |
| Status | `status` | Approved lifecycle value; server-managed. |
| Supplier name | `supplier_name` | Draft optional, submit required. |
| Supplier type | `supplier_type_code` | Active governed code at submit. |
| Supplier country | `country_code` | Submit required. |
| Business unit | `business_unit_id` | Resolved from active code; submit required. |
| Owner | `requester_user` | Authenticated Requester principal; immutable. |
| Justification | `business_justification` | Submit required; later warning analysis may classify vagueness. |
| Category | `product_service_category` | Submit required. |
| Annual spend | `expected_annual_spend` | Non-negative decimal. |
| Tax registration | `tax_registration_number` | Conditional; preserved for display and normalized separately for duplicate comparison. |
| Fusion identifiers | `fusion_supplier_id`, `fusion_supplier_number` | Server-managed by UOW-004. |
| Fusion outcome | `fusion_created_at`, `fusion_response_ref` | Server-managed by UOW-004. |
| Timestamps | `created_at`, `submitted_at`, `last_updated_at` | UTC; server-managed. |

Aggregate relationships:

- One request owns zero or more Draft sites and requires at least one complete site at submit.
- One request owns zero or more Draft contacts and requires at least one valid contact at submit.
- One request owns zero or one bank metadata entity in the phase-one API.
- One request owns zero or more document metadata entities.
- One request has zero or more append-only history entries.

## SupplierSite

| Domain Field | Physical Field | Rule |
|---|---|---|
| Site identity | `SUPPLIER_REQUEST_SITE.site_id` | Generated positive integer. |
| Owner request | `request_id` | Required aggregate foreign key. |
| Site name | `site_name` | May be derived from supplier name and city. |
| Site country | `country_code` | Submit required. |
| Address Line 1 | `address_line1` | Submit required; maximum 20 characters. |
| Address Line 2 | `address_line2` | Submit required; maximum 20 characters. |
| City | `city` | Submit required. |
| Region | `region` | Submit required. |
| Postal code | `postal_code` | Optional where not applicable. |
| Intended business unit | `intended_business_unit_id` | Defaults to header business unit in phase one. |
| Primary indicator | `is_primary` | Boolean-like flag; at most one true per request. |

The Requester form labels the physical address fields without inventing separate building, street, or province columns. Street/area content belongs in the two approved address lines; `region` represents province/state/region.

## SupplierContact

| Domain Field | Physical Field | Rule |
|---|---|---|
| Contact identity | `SUPPLIER_REQUEST_CONTACT.contact_id` | Generated positive integer. |
| Owner request | `request_id` | Required aggregate foreign key. |
| Name | `contact_name` | Submit required for the primary contact. |
| Email | `contact_email` | Submit required and format validated. |
| Phone | `phone_number` | Stored display value; format/length validated when supplied. |
| Email domain | `email_domain` | Server-derived lowercase domain. |

## SupplierBankMetadata

| Domain Field | Physical Field | Rule |
|---|---|---|
| Bank identity | `SUPPLIER_REQUEST_BANK.bank_id` | Generated positive integer. |
| Owner request | `request_id` | Required aggregate foreign key. |
| Bank country | `bank_country_code` | Optional unless bank-provided flag is true. |
| Masked display | `masked_account_display` | Contains masking plus last four only. |
| Last four | `account_last4` | Exactly four permitted account suffix characters when supplied. |
| Account token/hash | `account_hash` | Trusted irreversible value; never returned to Requester. |
| Provided indicator | `bank_provided_flag` | Distinguishes omitted bank metadata from incomplete supplied metadata. |

This entity never contains a full account number. Missing bank metadata is not itself a phase-one risk when bank details were not marked as provided.

## SupplierDocumentMetadata

| Domain Field | Physical Field | Rule |
|---|---|---|
| Document identity | `SUPPLIER_REQUEST_DOCUMENT.document_id` | Generated positive integer. |
| Owner request | `request_id` | Required aggregate foreign key. |
| Type | `document_type` | Governed/allowlisted business code. |
| Status | `document_status` | Metadata status only. |
| Required indicator | `is_required` | Server/governed indicator where applicable. |
| Metadata | `metadata_json` | Validated JSON metadata; no file bytes or secrets. |
| Missing indicator | `missing_flag` | Supports warnings and Requester guidance. |

## StatusHistoryEntry

| Domain Field | Physical Field | Rule |
|---|---|---|
| History identity | `STATUS_HISTORY.history_id` | Generated positive integer. |
| Request | `request_id` | Required request foreign key. |
| Prior status | `from_status` | Null only for initial creation where physically allowed. |
| New status | `to_status` | Approved lifecycle value. |
| Action | `action_code` | Stable server action code. |
| Actor | `actor_user` | Authenticated principal/system actor. |
| Comment/evidence | `action_comment` | Business-safe plain text for non-decisions; structured decision envelope is owned by UOW-003. |
| Timestamp | `action_timestamp` | Server UTC timestamp. |

History entries are never updated or deleted through the business API.

## Value Objects and Projections

These are logical types and do not create database tables.

| Value Object | Fields | Invariant |
|---|---|---|
| RequestPrincipal | subject, role set | Subject is authenticated; Requester operations require Requester role. |
| RequestNumber | UTC year, request identity | Stable approved format and unique physical value. |
| StructuredAddress | line1, line2, city, region, country, postal code | Lines at most 20; required parts enforced at submit. |
| ContactInput | name, email, phone | Valid email; derived domain is not client-writable. |
| MaskedBankInput | provided, country, masked display, last4, trusted hash | Contains no full account number. |
| RequesterRequestSummary | request number, supplier name, status, next action, timestamps, supplier number | Owner-scoped and evidence-safe. |
| RequesterRequestDetail | permitted aggregate data, safe timeline, correction guidance, final outcome | Excludes internal review and technical evidence. |
| SubmitOutcome | submitted flag, current status, warnings/findings | Blocked outcome retains editable status. |

## Status Value Set

| Status | UOW-001 Relationship |
|---|---|
| Draft | Created and editable. |
| Submitted | Auditable transient transition during successful submit/resubmit. |
| Under Review | Successful UOW-001 terminal handoff to UOW-003. |
| Correction Requested | Editable entry point returned by UOW-003. |
| Approved | Read-only to Requester; owned by UOW-003. |
| Rejected | Read-only final business outcome. |
| Marked Duplicate | Read-only final business outcome with existing supplier guidance. |
| Submitted to Fusion | Read-only integration status. |
| Created in Fusion | Read-only final outcome with supplier number. |
| Integration Failed | Read-only integration outcome unless later corrected by governed workflow. |

`Validation Failed` is not a status value.

## Aggregate Invariants

1. Every child row references exactly one existing request.
2. A Requester mutation can affect only an aggregate they own.
3. A Requester mutation is allowed only while status is Draft or Correction Requested.
4. A successful submission has at least one complete site and valid contact.
5. No request has more than one primary site.
6. No phase-one bank entity or projection contains a full account number.
7. Request status and status history agree after every successful lifecycle command.
8. A blocked submission does not append lifecycle history.
9. Requester projections contain only the approved role-safe field set.

## Physical Schema Consistency

UOW-001 introduces no new tables or columns. It uses the approved core tables and existing reference foreign keys. Validation, duplicate, risk, AI, integration, and supplier-reference tables remain physically unchanged and are accessed only through their owning unit contracts.

## Testable Properties

- **Round-trip**: Valid request aggregates serialize and deserialize without changing client-permitted values.
- **Invariant**: Every generated child entity retains the correct request owner.
- **Invariant**: Every generated Requester projection excludes the forbidden evidence field set.
- **Invariant**: Address-line and spend boundaries are consistently enforced.
- **Stateful model**: Random valid command sequences preserve ownership, editable-state, and status/history invariants.
- **Easy verification**: Request numbers are unique and match the approved pattern.
