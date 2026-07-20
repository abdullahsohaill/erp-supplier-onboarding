# Customer Requirements Traceability and Coverage Audit

## Purpose

This file checks whether the consolidated requirements and design artifacts still cover the customer discovery transcript in `Integration ERP.pdf`.

The requirements have intentionally been consolidated into 15 functional requirements. The customer scope is preserved in acceptance criteria, business rules, technical design, and user stories rather than represented as dozens of separate requirement rows.

## Coverage Matrix

| Customer Requirement Area | Transcript Need | Consolidated Coverage |
|---|---|---|
| Standardized supplier request intake | Replace emails, spreadsheets, and tickets with controlled supplier request form. | FR-001, US-001, US-002 |
| New supplier onboarding scope | Focus on new supplier requests; exclude supplier updates and merges. | Scope Summary, FR-001, FR-015 |
| Three application personas | Requester, single Reviewer, Support/Admin. | Persona Summary, FR-004, personas.md |
| Visual Builder UI | UI should be Oracle Visual Builder. | FR-001, technical-design.md architecture |
| ATP staging and tracking | Store requests, validations, duplicates, risk, AI summaries, logs, Fusion responses. | FR-003, technical-design.md data model |
| ORDS API layer | Visual Builder should call ATP via ORDS APIs. | FR-004, technical-design.md API catalog |
| OIC and Fusion integration | OIC submits approved suppliers to Fusion or mock Fusion; Visual Builder does not call Fusion directly. | FR-011, technical-design.md OIC/Fusion design |
| Status tracking | Users should see Draft, Submitted, Under Review, Correction Requested, Approved, Rejected, Marked Duplicate, Submitted to Fusion, Created, Integration Failed, and related statuses. Blocking submit findings remain attached to the editable Draft/Correction Requested request rather than creating a persisted Validation Failed status. | FR-002, FR-005, technical-design.md status model |
| Business vs technical failures | Validation failures must be separate from OIC/Fusion failures; submit validation returns an HTTP 422 business outcome without entering the integration-failure lifecycle. | FR-005, FR-013, NFR-003, NFR-005 |
| Manual review | Supplier should not be created automatically after submission. | FR-009, US-007 |
| Request correction | Reviewer can send incomplete request back without full rejection and identify the exact fields/evidence to correct. | FR-002, FR-009, US-002, US-007; structured correction array in `STATUS_HISTORY.action_comment` |
| Duplicate detection | Compare against existing supplier master data and staged requests. | FR-006, FR-012 |
| Duplicate signals | Name similarity, tax ID, country, email domain, phone, address, and bank where available. | FR-006, technical-design.md duplicate design |
| Exact tax and bank duplicates | Exact tax ID and same bank account should be strong/serious warnings. | FR-006, FR-007, BR-003, BR-004 |
| Optional real-time duplicate warning | Nice to have in the transcript but removed from the approved phase-one baseline. | FR-006, answered Q8 as submit/resubmit-only automatic detection |
| Risk scoring | Low/Medium/High/Critical risk using explainable rules. | FR-007, technical-design.md risk scoring |
| Risk factors | Missing tax, high-risk country, bank mismatch, incomplete address, incomplete bank metadata when marked provided, vague justification, high spend, missing documents, and non-blocking duplicate signals. | FR-007, BR-005 |
| Reviewer risk confirmation | Reviewer can confirm which risk factors apply to an individual request without changing global scoring configuration. | FR-009, US-005; selected factor codes stored with the decision in `STATUS_HISTORY.action_comment` |
| High-risk countries | Configurable internal list, no third-party dependency in phase one. | FR-007, FR-014, answered Q14 |
| AI explanation | AI explains risk, duplicate reasons, missing info, and recommended actions. | FR-008, technical-design.md AI design |
| AI guardrails | AI must not approve, reject, mark duplicate, or create suppliers. | FR-008, NFR-008, BR-007 |
| AI storage/regeneration | Store summary/timestamp/version metadata and allow regeneration after data changes. | FR-008, technical-design.md AI prompt governance |
| AI feedback | Excluded from the approved persistence and API baseline. | FR-008, superseded Q19 disposition |
| Dashboard and filters | Requester, Reviewer, and Support/Admin visibility; reviewer filters by BU/country/type/requester/status/risk/duplicate risk and useful extra filters. | FR-010 |
| Existing supplier reference sync | Existing Fusion supplier data must be available in ATP, mocked if access limited. | FR-012 |
| Bank data masking | Display last four only where needed; avoid exposing full bank details. | FR-014, NFR-004 |
| Bank account Fusion creation | Not required for phase one. | FR-011, FR-014, answered Q22 |
| Attachments/documents | Metadata and missing-document flags are enough; full upload optional/future. | FR-014 |
| Integration logs | Request-scoped ATP logs contain request ID, OIC instance ID, error, timestamp, retry summary, embedded retry history, and payload/response references; global supplier sync uses OIC-native monitoring. | FR-012, FR-013 |
| Retry | Support/Admin can retry technical or corrected business failures; not duplicate/rejected; every attempt is appended to the originating integration log. | FR-013, US-010 |
| Sample data | Include clean, exact tax duplicate, fuzzy name duplicate, missing tax, bank mismatch, incomplete address, same bank account, vague justification/high spend, Fusion failure. | FR-015, US-014 |
| Demo scenarios | Duplicate risk, AI explanation, clean creation, and integration failure/retry. | FR-015, demo-script.md |
| Documentation deliverables | Proposal, functional requirements, technical design, integration flow, data model, API list, validation/risk/AI logic, limitations. | FR-015, technical-design.md, proposal.md |
| Timeline | Approximately three-week prototype. | answered Q34 as fixed/tight scope |

## Audit Conclusion

The consolidated 15 functional requirements and 14 user stories cover the customer transcript and the approved later amendments. Requirements, assumptions, schema, and first-pass wireframes are now at a combined review gate before construction-stage design.
