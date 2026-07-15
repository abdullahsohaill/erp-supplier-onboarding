# Requirements and Design Review Checklist

Use this checklist before approving the requirements/design package and before asking for wireframes.

## Persona and Scope

- [ ] Confirm there are exactly three prototype personas: Requester, Reviewer, Support/Admin User.
- [ ] Confirm the single Reviewer owns completeness, duplicate, risk, payment-warning, and review decisions for the prototype.
- [ ] Confirm supplier updates, supplier merge, sanctions screening, email notifications, and production-grade attachments are out of phase-one scope.
- [ ] Confirm wireframes are intentionally deferred until after this review.

## Requirements

- [ ] Review `requirements.md` business objective and scope.
- [ ] Review every functional requirement section and its acceptance criteria.
- [ ] Confirm the mixed narrative/structured requirement format is acceptable for customer review.
- [ ] Confirm validation rules match the customer transcript.
- [ ] Confirm duplicate detection is treated as a primary requirement.
- [ ] Confirm risk scoring is explainable and not black-box.
- [ ] Confirm AI cannot approve, reject, mark duplicate, or create suppliers.
- [ ] Confirm requester status visibility and duplicate/rejection guidance are sufficient.
- [ ] Confirm support/admin retry and integration log requirements are sufficient.

## Technical Design

- [ ] Review Visual Builder, ORDS, ATP, OIC, and Fusion boundaries.
- [ ] Confirm Visual Builder does not create suppliers directly in Fusion.
- [ ] Review ATP data model and confirm required entities are present.
- [ ] Review ORDS endpoint catalog and role access.
- [ ] Review duplicate normalization, scoring, and thresholds.
- [ ] Review risk scoring factors and levels.
- [ ] Review AI input/output schema and data minimization.
- [ ] Review OIC flows for supplier sync, supplier submission, and retry.
- [ ] Review Fusion candidate API mapping and confirm it remains subject to customer tenancy validation.
- [ ] Review error categories and integration logging design.
- [ ] Review security, bank masking, and payload redaction notes.
- [ ] Review the technical design completeness assessment.

## Answered Assumptions

- [ ] Review every answered `[Answer]:` tag and rationale in `requirement-verification-questions.md`.
- [ ] Update requirements/design if any answered assumption should change.

## Ready For Wireframes

Only move to wireframes after:
- [ ] Requirements are accepted or changes are listed.
- [ ] Technical design is accepted or changes are listed.
- [ ] Answered assumptions are accepted or changes are listed.
- [ ] Demo scope is confirmed.
- [ ] Screen inventory and navigation priorities are confirmed.
