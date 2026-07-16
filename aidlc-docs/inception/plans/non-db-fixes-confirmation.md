# Non-DB Fixes To Confirm

## Purpose

This note captures the proposed non-database fixes from the supervisor meeting before implementation. The goal is to confirm the expected behavior and screen/documentation changes before updating the requirements, user stories, technical design, wireframe specification, and mockup.

## Scope Boundary

- These fixes should update functional requirements, technical design wording, user stories where needed, wireframe specification, and HTML mockups.
- Database schema, DBML, and database-schema-design files should not be modified in this pass.
- Any backend schema/config implications should be noted clearly for separate database handling.

## Confirmed Fixes

### 1. Requester Dashboard Action Column

- Remove the separate `Needs Attention` card from the requester dashboard.
- In `My Supplier Requests`, add a new right-side `Actions` column after `Next Action`.
- Show `Edit and Resubmit` only for rows with status `Correction Requested`.
- Confirmed behavior:
  - `Correction Requested`: show enabled `Edit and Resubmit`.
  - All other statuses: show non-clickable `None`.

### 2. Rename Reference Data To Admin Settings

- Rename `Reference Data` to `Admin Settings` in mockups and wireframe/spec wording.
- This screen is where Support/Admin manages configuration-like data, such as:
  - Validation rules.
  - Risk factors.
  - High-risk countries.
  - Supplier types.
  - Duplicate rules.
  - Business unit mappings.

### 3. Validation And Risk On/Off Controls

- Add an `Admin Settings > Validation Rules` section with global on/off toggles.
- Add an `Admin Settings > Risk Factors` section with on/off toggles plus weight/severity display.
- Example configurable toggles:
  - Tax registration required rule.
  - Address completeness rule.
  - Exact tax duplicate critical block.
  - Same bank token/hash critical block.
  - High-risk country risk warning.
  - Vague justification risk warning.
  - Bank country mismatch warning.
- Confirmed behavior:
  - This pass should represent these controls in docs/mockups.
  - Backend/database handling remains separate.
  - Schema files should not be changed in this pass.

### 4. Duplicate Preview Removal

- Remove the `Run Duplicate Preview` button from the supplier request form.
- Remove the `Duplicate Preview` panel from the request form screen.
- Remove wording that implies the Requester manually runs duplicate preview.
- Duplicate detection should happen automatically as part of validation/submission.
- On submit or resubmit, the system should run:
  - Validation checks.
  - Duplicate detection.
  - Risk scoring.
- Reviewer sees duplicate evidence after submission.
- Requester does not need an explicit duplicate-check button.

### 5. Critical Duplicate Triggers

- Exact tax registration duplicate and same bank token/hash duplicate should become blocking validation errors.
- This means the Requester cannot submit the application in the first place until the issue is resolved or corrected.
- These critical triggers should appear in validation results, not only as risk score reasons.
- High-risk country should not be a blocker. It should stay as a risk warning for the Reviewer.

### 6. Address Validation

- Do not use a regex-heavy single address field as the primary validation strategy.
- Replace the single address approach with structured address fields:
  - Address Line 1, maximum 20 characters.
  - Address Line 2, maximum 20 characters.
  - Street/Area.
  - Province/State.
  - City.
  - Address Country.
- Validation should check that the required address parts are present.
- If the address still looks suspicious or incomplete after structured validation, the Reviewer or AI can flag it manually as weak/incomplete address.

### 7. Bank And Payment Setup

- Keep bank/payment fields as metadata, masked/tokenized where applicable.
- Do not expose the full bank account number.
- Confirmed behavior:
  - Rename the bank-related risk factor.
  - Do not include payment setup as a phase-one workflow.
  - Treat payment setup as out of scope for phase one.
- Current wording to replace:
  - `Missing bank details when payment setup is required`
- Recommended revised wording:
  - `Missing or incomplete bank details`

### 8. Tax Registration Mandatory Rule

- Tax registration should not be globally mandatory for every supplier.
- It should be conditionally mandatory based on:
  - Country.
  - Supplier type.
  - Admin validation rule configuration.
- If tax registration is not required by configuration, missing tax can be a warning/risk reason instead of a blocking validation error.

### 9. Reviewer Feedback On Specific Fields

- Reviewer should be able to mark specific validation, risk, or evidence items for correction.
- Example targeted feedback items:
  - `Business Justification` is weak.
  - `Tax Registration` is missing.
  - `Address` is incomplete.
- Requester should see targeted correction guidance instead of only one generic reviewer comment.

## Confirmed Decisions Summary

- Requester dashboard action column should show `Edit and Resubmit` for `Correction Requested`; otherwise show non-clickable `None`.
- Bank/payment risk factor should be renamed only.
- Payment setup is out of scope for phase one.
- `Admin Settings` should include UI controls in the mockup/docs for now, while backend/database handling remains separate.
- Critical duplicate triggers should block requester submission in the first place.
