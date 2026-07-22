# UOW-003 Domain Entities

| Entity | Persistence/View | Invariants |
|---|---|---|
| Review request | `SUPPLIER_REQUEST` plus role-safe projections | Under Review is the sole decision source state. |
| Decision event | `STATUS_HISTORY` | Immutable transition, action code, actor/time, validated envelope. |
| Selected factor | `action_comment.selectedRiskFactorCodes` | Versioned codes, decision evidence only. |
| Correction item | `action_comment.correctionItems` | Specific source/field/code/message for Requester action. |
| Duplicate disposition | Status plus `existingSupplierNumber` envelope field | Required only for Mark Duplicate. |
| Reviewer queue | Bounded query over request/evidence tables | Role-safe approved filters. |
| Requester dashboard action | Derived projection | Edit and Resubmit iff Correction Requested, else None. |

No new review-selection or correction-item table is introduced.
