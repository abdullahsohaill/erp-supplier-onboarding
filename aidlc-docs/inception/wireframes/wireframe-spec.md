# Wireframe Specification

## Document Status

| Field | Value |
|---|---|
| Project | Supplier Onboarding, Duplicate Detection, and Risk Scoring |
| Phase | AI-DLC Inception - Wireframes / Mockups |
| Status | Complete first pass for review |
| Source Baseline | Approved `aidlc-docs/inception/requirements/requirements.md`, `aidlc-docs/inception/user-stories/stories.md`, `aidlc-docs/inception/requirements/requirement-verification-questions.md`, and `aidlc-docs/inception/application-design/technical-design.md` |
| Mockup Artifact | `mockups/supplier-onboarding-wireframes.html` |

## Wireframe Goals

These wireframes translate the approved requirements into a reviewable screen model before implementation. They are intentionally focused on workflow, information architecture, field coverage, role boundaries, and decision support. They are not final branded UI design.

Primary goals:
- Show how Requesters create, correct, and track supplier requests.
- Show how the single Reviewer evaluates validation, duplicate, risk, and AI explanation evidence before making a manual decision.
- Show how Support/Admin users inspect integration failures, retry eligible failures, and maintain Admin Settings controls.
- Keep AI advisory only and make human decision ownership visible.
- Keep OIC/Fusion boundaries visible without making Visual Builder appear to create suppliers directly.

## Navigation Model

The mockup uses a left navigation shell with role-oriented screens:

- Requester: dashboard, request form, request detail.
- Reviewer: review dashboard, request review detail, duplicate/risk/AI evidence panel, decision modal.
- Support/Admin: integration dashboard, integration log detail, Admin Settings maintenance.

Top-level request states used in the wireframes:

```text
Draft -> Submitted -> Validation Failed / Under Review -> Correction Requested / Approved / Rejected / Marked Duplicate -> Submitted to Fusion -> Created in Fusion / Integration Failed
```

## Screen Inventory and Traceability

| Screen ID | Screen | Primary Persona | Primary Stories | Functional Requirements |
|---|---|---|---|---|
| WF-001 | Requester Dashboard | Requester | US-003, US-009 | FR-002, FR-010 |
| WF-002 | Supplier Request Form | Requester | US-001, US-002 | FR-001, FR-003, FR-004, FR-005, FR-014 |
| WF-003 | Request Detail / Status Timeline | Requester | US-003, US-008 | FR-002, FR-009, FR-011 |
| WF-004 | Reviewer Dashboard | Reviewer | US-004, US-005, US-006, US-009 | FR-005, FR-006, FR-007, FR-008, FR-010 |
| WF-005 | Request Review Detail | Reviewer | US-004, US-005, US-006, US-007, US-008 | FR-002, FR-005, FR-006, FR-007, FR-008, FR-009 |
| WF-006 | Duplicate / Risk / AI Evidence Panel | Reviewer | US-004, US-005, US-006 | FR-006, FR-007, FR-008, FR-014 |
| WF-007 | Review Decision Modal, embedded at the end of WF-005 | Reviewer | US-007, US-008 | FR-002, FR-009 |
| WF-008 | Support/Admin Integration Dashboard | Support/Admin User | US-010 | FR-010, FR-013 |
| WF-009 | Integration Log Detail | Support/Admin User | US-010, US-011 | FR-011, FR-013 |
| WF-010 | Admin Settings Maintenance | Support/Admin User | US-013 | FR-014 |

## Global UI Patterns

### Header
- Shows current workspace name, environment badge, selected role, and current screen context.
- Keeps prototype status visible as "Mock Fusion / ATP staging" to reinforce implementation boundaries.

### Status Badges
- Draft: neutral.
- Submitted / Under Review: active.
- Correction Requested / Validation Failed: warning.
- Approved / Submitted to Fusion: positive but not final.
- Created in Fusion: success.
- Rejected / Marked Duplicate: final negative/duplicate.
- Integration Failed: support attention.

### Tables and Filters
- Operational tables use dense but readable rows.
- Reviewer filters include status, business unit, country, supplier type, requester, risk, duplicate risk, spend, and category.
- Support filters include integration status, retry eligibility, OIC instance ID, and error category.

### Evidence Cards
- Validation, duplicate, risk, and AI evidence are visually separated.
- Risk and duplicate reasons show concrete matched fields and scores.
- AI content is labeled as advisory and does not contain decision controls.

### Sensitive Data Handling
- Bank account values are masked.
- Payload and response values appear as references, not raw sensitive payloads.
- Support/Admin can see technical messages; Requester/Reviewer see business-safe messages.

## Screen Details

### WF-001: Requester Dashboard

Purpose: Give the Requester a fast view of their own supplier requests, outstanding corrections, created suppliers, and duplicate/rejected outcomes.

Key content:
- Summary counters: Drafts, Submitted, Correction Needed, Created in Fusion.
- Request table with request number, supplier, status, next action, and actions.
- Actions column shows `Edit and Resubmit` only for Correction Requested rows; all other rows show non-clickable `None`.
- Quick action to create a new supplier request.
- No internal risk score, level, reasons, or AI review evidence is shown to the Requester.

Primary actions:
- Create New Request.
- Continue Draft.
- Open Request Detail.
- Edit and Resubmit Correction Requested request.
- No action for non-correction request rows in the requester dashboard.

States:
- Empty: no requests yet, show Create New Request.
- Correction needed: show targeted correction guidance in next action and an enabled Edit and Resubmit row action.
- Created: show Fusion supplier number.
- Duplicate: show existing supplier reference.

### WF-002: Supplier Request Form

Purpose: Capture standardized supplier request data and stage it through ORDS into ATP.

Sections:
- Supplier basics: name, supplier type, country, business unit, category, expected annual spend.
- Contact: contact person, email, phone, email domain derived for duplicate checks.
- Site/address: Address Line 1, Address Line 2, street/area, province/state, city, and address country. Address Line 1 and Address Line 2 show a 20-character maximum hint.
- Tax and bank indicators: conditional tax registration, bank country, masked account preview/last four, bank provided flag.
- Documents: metadata rows for required/pending documents and missing flags.
- Justification: business justification and notes.

Primary actions:
- Save Draft.
- Submit Request.

Validation behavior:
- Required fields are marked.
- Blocking validation appears inline and in a top validation summary.
- Submit/resubmit automatically runs validation, duplicate detection, and risk scoring.
- Exact tax registration duplicate and same bank token/hash duplicate appear as blocking validation errors and prevent requester submission.
- High-risk country remains a risk warning for Reviewer review, not a requester submission blocker.
- Optional bank values are masked and never displayed as full account numbers.

### WF-003: Request Detail / Status Timeline

Purpose: Let Requesters understand current status, history, reviewer comments, duplicate outcome, and Fusion supplier number without contacting support.

Key content:
- Request summary and status badge.
- Status timeline with actor, timestamp, and comment.
- Validation/correction guidance.
- Duplicate result, if marked duplicate.
- Fusion supplier number, if created.
- Business-safe integration message if failed.
- No internal risk score, level, reasons, scoring version, or AI review evidence.

Primary actions:
- Edit and Resubmit when status is Correction Requested.
- View existing supplier when marked duplicate.

### WF-004: Reviewer Dashboard

Purpose: Help the Reviewer prioritize requests based on validation, duplicate, risk, and operational status.

Key content:
- Queue counters: Pending Review, High Risk, Duplicate Risk, Recently Created, Integration Failed.
- Filter bar for BU, country, supplier type, requester, status, risk, duplicate risk, spend, and category.
- Review queue table with supplier, requester, BU, risk, duplicate score, validation state, age, and next step.

Primary actions:
- Open Review Detail.
- Apply filters.
- Sort by risk, duplicate score, or request age.

### WF-005: Request Review Detail

Purpose: Provide a single decision workspace for the Reviewer.

Sections:
- Supplier summary and request metadata.
- Request data tabs: supplier, site/contact, tax/bank/document metadata, justification.
- Validation findings.
- Duplicate matches.
- Risk assessment.
- Per-request Reviewer Risk Factors checklist containing all Section 11.1 factors: missing tax registration, high-risk country, bank-country mismatch, incomplete address, missing/incomplete bank details, vague justification, high spend with weak justification, missing document metadata, High duplicate score, and Medium duplicate score.
- AI explanation.
- Status history.
- Decision Modal preview as the final section, with access to the shared decision modal.

Primary actions:
- Approve.
- Request Correction.
- Reject.
- Mark Duplicate.
- Regenerate AI Summary.
- Independently tick or clear each risk factor for the current request.

Guardrails:
- Approve is visually disabled if blocking validation remains.
- Request Correction can target specific validation, risk, or evidence fields.
- Mark Duplicate requires an existing supplier reference.
- AI does not make or execute any decision.

### WF-006: Duplicate / Risk / AI Evidence Panel

Purpose: Make the review evidence readable enough for the Reviewer to act without treating AI as the decision-maker.

Panel content:
- Duplicate candidates with score, level, matched fields, and existing supplier number.
- Risk score with level, scoring version, and factor-level reasons.
- AI summary with risk summary, duplicate explanation, missing information, and recommended reviewer actions.
- Data minimization note for bank values and AI input.

Primary actions:
- Open candidate supplier reference.
- Recalculate risk after correction.
- Regenerate AI summary.
- Mark AI summary helpful/not helpful as future enhancement indicator only.

### WF-007: Review Decision Modal

Purpose: Capture Reviewer decision in a controlled, auditable way. WF-007 is embedded at the end of WF-005 Request Review Detail and is not a separate navigation tab.

Decision modes:
- Approve: requires no blocking validations.
- Request Correction: requires comment and can include targeted correction items.
- Reject: requires comment.
- Mark Duplicate: requires existing supplier reference and comment.

Modal fields:
- Decision type.
- Reviewer comment.
- Targeted correction items for fields/evidence needing requester changes.
- Existing supplier reference when duplicate.
- Confirmation summary of downstream result.

### WF-008: Support/Admin Integration Dashboard

Purpose: Give Support/Admin users a focused view of integration failures, retry eligibility, and OIC/Fusion correlation details.

Key content:
- Failure counters: Integration Failed, Retry Eligible, Business Mapping Issue, Technical Failure.
- Integration log table with request, supplier, integration name, OIC instance ID, status, retry count, retry eligibility, and last error.
- Retry queue filter.

Primary actions:
- Open Integration Log Detail.
- Retry Eligible Failure.
- View related request.

### WF-009: Integration Log Detail

Purpose: Show technical evidence for one integration event without exposing sensitive payload values.

Key content:
- Request and supplier summary.
- Integration metadata: OIC instance ID, direction, timestamps, status, retry count.
- Payload and response references.
- User-safe message and technical message.
- Retry history sourced from the selected integration log's embedded retry-history array.

Primary actions:
- Retry, when eligible.
- Mark as business correction needed, when error category indicates mapping/data issue.
- Copy correlation ID.

### WF-010: Admin Settings Maintenance

Purpose: Let Support/Admin users maintain selected global Admin Settings controls that affect blocking validation and duplicate detection.

Sections:
- Business unit mappings.
- Supplier types and tax-required flag.
- High-risk countries.
- Global Validation Rules with independent on/off controls for VAL-001 through VAL-009 from Section 9.1 of the technical design.
- Duplicate rule weights and blocking critical triggers.

Primary actions:
- Edit Admin Settings row.
- Turn each global validation rule on or off.
- Save changes.

Guardrails:
- Changes are versioned or audit-friendly.
- Historical requests keep their original scoring version.
- Support/Admin maintenance does not bypass Reviewer decision controls.
- Risk-factor marking is request-specific Reviewer work and is not configured globally from Admin Settings.

## Mockup Review Checklist

- [ ] Requester flow is clear from dashboard to form to status detail.
- [ ] Reviewer can see validation, duplicate, risk, and AI evidence before decisions.
- [ ] Decision modal enforces required comments and duplicate reference.
- [ ] Support/Admin screens show retry eligibility and technical detail without exposing sensitive payloads.
- [ ] Admin Settings maintenance matches phase-one scope.
- [ ] Mockups do not imply Visual Builder creates suppliers directly in Fusion.
- [ ] AI is visibly advisory only.

## Out of Scope For This Wireframe Pass

- Final brand styling.
- Production component library implementation.
- Real API integration.
- Document upload UI beyond metadata and missing flags.
- Fusion bank account creation.
- Multi-step enterprise approval workflow.
