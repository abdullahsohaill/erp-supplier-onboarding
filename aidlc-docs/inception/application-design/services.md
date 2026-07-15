# Services

## Request Management Service

Coordinates supplier request creation, update, submission, status transitions, and requester visibility.

## Review Workflow Service

Coordinates reviewer actions: approve, reject, request correction, and mark duplicate. It enforces that high-risk and duplicate-risk requests remain human-reviewed.

## Validation Service

Runs mandatory and conditional validations and writes categorized findings.

## Duplicate Detection Service

Runs exact and fuzzy duplicate checks against existing supplier references and active staged requests.

## Risk Assessment Service

Calculates explainable risk score and level from validation results, duplicate results, country risk, bank mismatch, and justification quality.

## AI Explanation Service

Generates plain-language summary and recommended actions from deterministic validation, duplicate, and risk facts.

## Fusion Submission Service

Uses OIC to transform and submit approved supplier requests to Fusion or mock Fusion endpoint.

## Supplier Reference Sync Service

Uses OIC to synchronize supplier reference records from Fusion or load mock data for prototype duplicate detection.

## Integration Observability Service

Stores OIC instance IDs, payload references, response references, errors, timestamps, and retry counts.
