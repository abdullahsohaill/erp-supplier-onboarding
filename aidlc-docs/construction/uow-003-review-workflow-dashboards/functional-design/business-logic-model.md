# UOW-003 Business Logic Model

## Review Flow

1. Reviewer lists a bounded role-scoped queue and opens an Under Review request.
2. Reviewer inspects validation, duplicate, risk, AI, request, and document metadata evidence.
3. Reviewer chooses Approve, Reject, Request Correction, or Mark Duplicate.
4. The command validates role, current status, required comment/correction items/existing supplier reference, and bounded allowlisted JSON.
5. One transaction locks the request, appends a `STATUS_HISTORY` action, changes status, and commits.
6. Requester projections expose only business comment, targeted corrections, next action, or final existing supplier reference.

## Dashboard Flow

- Requester counts/lists are always owner scoped. Only Correction Requested rows expose `Edit and Resubmit`; all others return non-clickable `None`.
- Reviewer queue defaults to review-relevant statuses and supports approved bounded filters.
- Dashboard counts and filtered list predicates share the same status/role interpretation.

## Failure Semantics

Invalid state or decision payload returns safe conflict/bad-request behavior with no history or status mutation. Missing/cross-scope resources return safe not-found/forbidden outcomes. A decision never recalculates or rewrites automatic analysis evidence.
