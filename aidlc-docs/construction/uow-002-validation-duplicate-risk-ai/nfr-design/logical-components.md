# UOW-002 Logical Components

| Component | Responsibility | Interface |
|---|---|---|
| Analysis API facade | Role checks, safe envelope, explicit run/read operations | `ERP_ANALYSIS_PKG` |
| Governed check port | Orchestrates validation, duplicate, risk, AI in one transaction | `ERP_GOV_CHECK_PORT_PKG` |
| Validation evaluator | Active catalog evaluation and finding persistence | `VALIDATION_RULES`, `VALIDATION_RESULT` |
| Duplicate evaluator | Candidate normalization/scoring and critical signals | `DUPLICATE_MATCH`, supplier references |
| Risk evaluator | Active factors, thresholds, reason JSON | `RISK_ASSESSMENT` |
| Advisory AI generator | Deterministic local explanation and source hash | `AI_SUMMARY` |
| Evidence projection | Role-safe bounded JSON | shared projection package |
| Contract/security tests | Route parity, authorization, schema, leakage, properties | pytest/Hypothesis |

Dependency direction is ORDS handler to analysis facade to governed check port to approved tables/utilities. Evidence engines never call Reviewer or integration workflow packages.
