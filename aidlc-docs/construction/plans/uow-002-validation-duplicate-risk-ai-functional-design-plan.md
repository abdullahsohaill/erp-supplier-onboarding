# UOW-002 Functional Design Plan

## Status

Approved and completed under the user's blanket authorization to finish Construction through UOW-005.

- [x] Read UOW-002, US-004 through US-006, FR-005 through FR-008, the final schema, and technical design.
- [x] Resolve business-logic, domain, rule, data-flow, integration, error, scenario, and UI questions from the approved baseline.
- [x] Define automatic validation, duplicate, risk, and deterministic advisory-AI flows.
- [x] Define configuration, current-run/history, authorization, and safe-projection invariants.
- [x] Validate complete story/requirement/rule/schema traceability.

## Resolved Questions

- Validation and duplicate detection run automatically on submit/resubmit; Reviewer/Support/System routes may rerun analysis. [Answer]: Approved baseline.
- `VAL-008` and `VAL-009` block submission when active; high-risk country remains a warning. [Answer]: Approved baseline.
- Reviewer-selected factors are decision evidence and never alter automatic scoring. [Answer]: Approved baseline.
- AI is deterministic locally, advisory only, and receives curated facts without raw bank data. [Answer]: Approved baseline.
