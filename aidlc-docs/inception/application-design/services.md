# Services

## Request Management Service

Coordinates supplier request creation, update, submission, status transitions, and requester visibility.

## Review Workflow Service

Coordinates reviewer actions: approve, reject, request correction, and mark duplicate. It enforces human review, validates the decision payload, and writes comments, selected risk-factor codes, targeted correction items, and any duplicate reference into the new `STATUS_HISTORY.action_comment` decision envelope. Requester reads receive only role-safe comments and correction guidance.

## Validation Service

Loads active definitions from `VALIDATION_RULES`, runs mandatory and conditional validations before a submit/resubmit transition is committed, and writes categorized failed findings linked to the exact rule identifier. Blocking findings preserve Draft or Correction Requested and keep the request outside the Reviewer queue.

## Duplicate Detection Service

Loads `DUPLICATE` rows from `REF_SCORING_RULE` and runs exact and fuzzy duplicate checks against existing supplier references and active staged requests.

## Risk Assessment Service

Loads `RISK` rows from `REF_SCORING_RULE` and calculates explainable risk score and level from validation results, duplicate results, country risk, bank mismatch, and justification quality.

## AI Explanation Service

Generates plain-language summary and recommended actions from deterministic validation, duplicate, and risk facts.

## Fusion Submission Service

Uses OIC to transform and submit approved supplier requests to Fusion or mock Fusion endpoint.

## Supplier Reference Sync Service

Uses OIC to synchronize supplier reference records from Fusion or load mock data for prototype duplicate detection. OIC-native monitoring records each global run and its integration instance ID; synchronized ATP reference rows update `last_sync_at`.

## Integration Observability Service

Stores request-scoped OIC instance IDs, required request IDs, payload/response references, errors, timestamps, retry summaries, and append-only retry-history JSON. Global supplier-reference sync runs remain in OIC monitoring because the committed `INTEGRATION_LOG.request_id` is mandatory.
