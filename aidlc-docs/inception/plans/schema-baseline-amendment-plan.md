# Schema Baseline Amendment Plan

## Scope

Align the approved Inception baseline with the requested rule-storage changes: consolidate risk and duplicate scoring rules, persist the Section 9.1 blocking-validation catalog, link failed validation results to that catalog, and remove AI summary feedback from the model and phase-one design.

## Design Decisions

- Replace `REF_RISK_RULE` and `REF_DUPLICATE_RULE` with `REF_SCORING_RULE`.
- Use `rule_type` with allowed values `RISK` and `DUPLICATE` to identify each scoring rule's domain and include it in the composite primary key with `rule_code` and `version`.
- Add `VALIDATION_RULES` with a generated `validation_rule_id` primary key and unique stable `rule_code`.
- Replace `VALIDATION_RESULT.rule_code` with required `validation_rule_id` referencing `VALIDATION_RULES.validation_rule_id`.
- Seed `VALIDATION_RULES` with `VAL-001` through `VAL-009` from technical-design Section 9.1.
- Remove `AI_SUMMARY_FEEDBACK` and its optional API/scope references.

## Execution Checklist

- [x] Record the complete schema amendment request and trace affected artifacts.
- [x] Update functional requirements, user stories, and traceability.
- [x] Update technical design tables, relationships, APIs, validation catalog, and configuration guidance.
- [x] Update `db-schema.dbml` tables, keys, indexes, groups, and relationships.
- [x] Regenerate the complete schema narrative, Mermaid ERD, relationship catalog, counts, and logical flow.
- [x] Update dependent application-design artifacts where the persistence dependencies change.
- [x] Validate DBML syntax, Mermaid structure, table/column/relationship counts, and cross-file naming consistency.
- [x] Update AI-DLC state and audit records with completion results.

## Validation Criteria

- No active design artifact contains `REF_RISK_RULE`, `REF_DUPLICATE_RULE`, or `AI_SUMMARY_FEEDBACK`.
- `REF_SCORING_RULE.rule_type` distinguishes `RISK` and `DUPLICATE` records.
- `VALIDATION_RULES` contains the Section 9.1 blocking-rule definitions `VAL-001` through `VAL-009`.
- `VALIDATION_RESULT.validation_rule_id` has a required physical foreign key to `VALIDATION_RULES.validation_rule_id`.
- All schema inventory totals and physical relationship counts match `db-schema.dbml`.
