# UOW-002 Domain Entities

| Domain Object | Finalized Persistence | Key Invariants |
|---|---|---|
| Validation rule | `VALIDATION_RULES` | Stable code, severity/blocking semantics, independent active flag. |
| Validation finding | `VALIDATION_RESULT` | Request/run/rule identity, current flag, actionable safe text. |
| Scoring rule version | `REF_SCORING_RULE` | Composite `rule_type`, `rule_code`, `version`; nonnegative weight. |
| Duplicate candidate | `DUPLICATE_MATCH` | Request/run/candidate, score/level, matched-fields JSON, current flag. |
| Risk assessment | `RISK_ASSESSMENT` | One score/level/version plus factor JSON for a run. |
| AI explanation | `AI_SUMMARY` | Advisory schema, provider/model/prompt metadata, source-facts hash. |
| Existing supplier facts | `EXISTING_SUPPLIER_REF`, `EXISTING_SUPPLIER_SITE_REF` | Normalized duplicate inputs; ATP reference, not supplier master. |

No new table or column is introduced. Reviewer-selected factors belong to the later decision envelope in `STATUS_HISTORY.action_comment`, not these analysis entities.
