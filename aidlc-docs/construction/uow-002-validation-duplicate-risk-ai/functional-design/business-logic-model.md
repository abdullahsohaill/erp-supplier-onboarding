# UOW-002 Business Logic Model

## Scope

UOW-002 implements US-004 through US-006 and FR-005 through FR-008 through one governed analysis pipeline. It extends the stable UOW-001 governed-check port without changing request routes or the finalized 18-table schema.

## Analysis Pipeline

1. Authorize Requester submit orchestration or an explicit Reviewer, Support/Admin, or System analysis call.
2. Lock/load the request aggregate and create a unique `run_id`.
3. Mark prior current validation, duplicate, risk, and AI rows non-current within the transaction.
4. Evaluate active `VALIDATION_RULES` entries and persist failed `VALIDATION_RESULT` rows with rule FK, field, severity, blocking flag, message, and corrective guidance.
5. Normalize request and candidate facts; evaluate active `DUPLICATE` scoring rules against existing supplier references and eligible staged requests.
6. Persist explainable `DUPLICATE_MATCH` candidates and matched-fields JSON. Exact tax and same bank hash also feed `VAL-008`/`VAL-009` blockers.
7. Evaluate active `RISK` rules and thresholds; persist one current `RISK_ASSESSMENT` with score, level, version, and factor JSON.
8. Generate a schema-constrained advisory `AI_SUMMARY` from curated analysis facts.
9. Return blocking count and role-safe evidence. UOW-001 changes status only when blocker count is zero.

## Failure Semantics

- A failed analysis transaction does not create a partial current run.
- Business blockers return HTTP 422 from requester submission and preserve Draft or Correction Requested.
- Explicit analysis returns safe 404 for missing requests and safe 500 for internal failures.
- Inactive rules do not contribute findings, scores, or thresholds.
- AI failure never changes validation, duplicate, risk, or request status.

## Projections

Requester output contains actionable validation text but no candidate internals, automatic risk score/level/reasons, or AI evidence. Reviewer and Support/Admin receive persisted evidence through dedicated endpoints.
