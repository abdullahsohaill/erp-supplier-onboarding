# Risk and Validation Cards Wireframe Amendment Plan

## Scope

Update the static HTML mockup and wireframe specification without changing the database schema or technical design. Move risk-factor selection to the per-request Reviewer workspace and replace Admin risk-factor controls with global blocking-validation controls.

## Source Baseline

- Risk-factor checklist: Section 11.1 of `aidlc-docs/inception/application-design/technical-design.md`.
- Global validation rules: Section 9.1 of `aidlc-docs/inception/application-design/technical-design.md`.
- Mockup: `mockups/supplier-onboarding-wireframes.html`.
- Wireframe specification: `aidlc-docs/inception/wireframes/wireframe-spec.md`.

## Execution Checklist

- [x] Record the complete amendment request and confirm that schema changes are deferred.
- [x] Inspect the current Reviewer Request Review Detail and Admin Settings cards.
- [x] Add all Section 11.1 risk factors as independent per-request Reviewer checkboxes.
- [x] Remove the Admin Settings Risk Factors card.
- [x] Add all Section 9.1 blocking validations as independent global Admin on/off controls.
- [x] Update the wireframe specification to match the new responsibility boundaries.
- [x] Validate exact rule coverage, HTML structure, and unchanged schema/technical-design scope.
- [x] Verify Reviewer and Admin checkbox behavior in the local browser.
- [x] Update AI-DLC state and audit records with completion results.

## Validation Criteria

- Request Review Detail contains exactly the ten risk factors listed in Section 11.1.
- Each request-level risk factor is represented by an independently operable checkbox.
- Admin Settings contains no Risk Factors card.
- Global Validation Rules contains exactly VAL-001 through VAL-009 from Section 9.1.
- Each global validation rule is represented by an independently operable on/off checkbox.
- No database schema, DBML, schema-design, or technical-design content is changed by this amendment.
