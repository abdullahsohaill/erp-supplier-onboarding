# UOW-005 Domain Entities

| Governance Entity | Finalized Table/Artifact | Identity |
|---|---|---|
| Validation rule | `VALIDATION_RULES` | rule code and generated ID |
| Scoring rule version | `REF_SCORING_RULE` | type, code, version |
| High-risk country period | `REF_HIGH_RISK_COUNTRY` | country, effective from |
| Business unit | `REF_BUSINESS_UNIT` | business unit code |
| Supplier type | `REF_SUPPLIER_TYPE` | supplier type code |
| Demo scenario | Deterministic seed rows across all 18 tables | request/reference business keys |
| Migration evidence | Ignored external manifest plus sanitized report | path/checksum/run time |
| Test evidence | Ignored machine results plus sanitized summary | run/Git/image identities |
| Proposal package | Approved Inception plus Construction reports | traceable FR/US/design/test IDs |

No generic settings table, feature-flag table, demo table, or migration-history table is added.
