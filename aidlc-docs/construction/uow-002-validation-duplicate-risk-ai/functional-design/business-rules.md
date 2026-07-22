# UOW-002 Business Rules

| ID | Rule | Outcome |
|---|---|---|
| ANA-BR-001 | Only active validation/scoring configuration participates in a run. | Governed behavior |
| ANA-BR-002 | Every failed field validation references one `VALIDATION_RULES` row. | Referential explainability |
| ANA-BR-003 | `VAL-001` through `VAL-007` evaluate completeness/mapping; `VAL-008` exact tax and `VAL-009` same bank hash evaluate critical duplicate triggers. | Blocking when active |
| ANA-BR-004 | High-risk country, missing expected tax, bank-country mismatch, incomplete metadata/address, weak justification, high spend, missing documents, and noncritical duplicate signals are warnings. | Reviewer evidence |
| ANA-BR-005 | Exact tax and same bank hash compare against existing references and eligible staged requests. | Submission blocker |
| ANA-BR-006 | Duplicate candidates retain score, level, rule version, and matched-fields JSON. | Explainability |
| ANA-BR-007 | Duplicate and risk thresholds come from versioned `REF_SCORING_RULE` rows. | No hardcoded policy |
| ANA-BR-008 | One row per evidence type is current for a request/run while prior runs remain auditable. | History invariant |
| ANA-BR-009 | Reviewer factor selections do not modify risk score or reasons. | Separation of duties |
| ANA-BR-010 | AI output cannot decide, integrate, retry, or mutate governed evidence. | Advisory-only guardrail |
| ANA-BR-011 | Curated AI facts exclude full bank account values and credentials. | Sensitive-data control |
| ANA-BR-012 | Material correction/resubmission generates a new run and supersedes current flags atomically. | Recalculation |

## Required Examples

- Exact tax and same bank hash block submit.
- Fuzzy name plus country creates a candidate without automatically blocking.
- High-risk country changes risk evidence but not submit eligibility.
- Deactivating one risk rule removes only that factor from the next run.
- AI output remains schema valid and advisory when duplicate/risk evidence is empty.
