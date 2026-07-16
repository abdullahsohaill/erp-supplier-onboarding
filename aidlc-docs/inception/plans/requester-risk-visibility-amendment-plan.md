# Requester Risk Visibility Amendment Plan

## Scope

Remove Requester access to the persisted risk-assessment API and remove risk scores/reasons from requester-facing views. Keep risk assessment available to Reviewer and Support/Admin users, and preserve requester access to status, reviewer guidance, final duplicate outcome, and Fusion outcome.

## Execution Checklist

- [x] Read the attached decision, current AI-DLC state, and applicable requirements/content-validation rules.
- [x] Trace requester risk visibility across requirements, personas, stories, technical design, wireframe specification, and mockup.
- [x] Update requirements, persona/story boundaries, and the technical API/access design.
- [x] Remove risk scores and reasons from requester wireframe documentation and requester mockup screens.
- [x] Validate cross-artifact consistency and verify requester/reviewer views in the local browser.
- [x] Record completion and validation results in `aidlc-docs/audit.md`.

## Validation Criteria

- `GET /requests/{requestId}/risk-assessment` authorizes Reviewer and Support/Admin only.
- The Requester projection from `GET /requests/{requestId}` contains status and actionable guidance but no internal risk score, level, reasons, or AI evidence.
- Requester dashboard and request-detail mockups expose no persisted risk assessment.
- Reviewer dashboard, review detail, and evidence panel retain risk information.
- Existing duplicate outcome, correction guidance, and Fusion outcome visibility remain unchanged.
