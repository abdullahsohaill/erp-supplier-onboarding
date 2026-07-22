# UOW-005 Business Logic Model

## Admin Settings

1. Support/Admin authenticates and selects High-Risk Countries, Validation Rules, Scoring Rules, Business Units, or Supplier Types.
2. Read operations return active and inactive configuration with stable business keys and versions.
3. Update operations accept allowlisted fields, validate composite/business keys and policy values, derive actor/timestamps, and update/merge one governed item.
4. Validation rules expose independent active toggles for `VAL-001` through `VAL-009`.
5. Risk and duplicate rules share `REF_SCORING_RULE`, remain separated by `rule_type`, and support independent active/weight/severity/critical settings on existing versions.
6. Business-unit/supplier-type updates preserve Fusion/tax behavior and active state; country periods preserve effective dates.

## Demo and Proposal Acceptance

Deterministic seeds cover every table and the approved scenarios: clean creation, exact-tax/same-bank blockers, fuzzy duplicate, high-risk warnings, missing expected tax, incomplete address/metadata, weak high-spend justification, correction/resubmit, all decisions, integration failure/retry, final created/rejected/duplicate outcomes, active/inactive rules, and reference sync/upsert.

The consolidated reports map migrations, objects, 42 endpoints, 14 stories, tests, scans, performance evidence, limitations, and manual production gates. No demo data is represented as customer or production data.
