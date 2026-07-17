# Non-DB Fixes Implementation Plan

## Scope

Implement the approved non-database fixes across the AI-DLC inception artifacts and HTML mockup.

## In Scope

- Requirements updates.
- User story updates where acceptance criteria need to reflect the approved behavior.
- Technical design wording and API/validation behavior updates.
- Wireframe specification updates.
- HTML mockup updates.
- Audit/state updates.

## Out Of Scope

- Database schema changes.
- DBML changes.
- `database-schema-design.md` changes.
- Payment setup workflow implementation for phase one.

## Confirmed Decisions

- Requester dashboard rows show `Edit and Resubmit` only for `Correction Requested`; all other rows show non-clickable `None`.
- Duplicate checks run automatically during submit/resubmit validation, without a requester-triggered preview button.
- Exact tax registration duplicates and same bank token/hash duplicates are blocking validation errors that prevent requester submission.
- High-risk country remains a reviewer risk warning, not a requester submission blocker.
- Address validation uses structured fields and completeness checks, not a regex-heavy single address field; Address Line 1 and Address Line 2 are capped at 20 characters each.
- Bank-related risk factor is renamed to `Missing or incomplete bank details`; payment setup is out of phase-one scope.
- `Reference Data` is renamed to `Admin Settings`.
- Admin Settings mockups/docs show the approved controls; backend/database handling was deferred from this non-DB plan and is now aligned by `schema-baseline-amendment-plan.md`.
- Reviewer can mark specific validation, risk, or evidence items for correction.

## Execution Checklist

- [x] Create AI-DLC amendment plan and capture confirmed scope.
- [x] Update requirements and business rules.
- [x] Update user stories and acceptance criteria where needed.
- [x] Update technical design validation, duplicate, risk, API/config wording.
- [x] Update wireframe specification.
- [x] Update HTML mockup.
- [x] Validate no DB/schema artifacts were modified.
- [x] Validate content consistency and search for stale wording.
- [x] Record completion in audit/state.
- [x] Prepare changes for commit and push.
