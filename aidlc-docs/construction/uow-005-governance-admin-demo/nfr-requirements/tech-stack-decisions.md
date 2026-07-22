# UOW-005 Tech Stack Decisions

| Area | Decision |
|---|---|
| Admin service | `ERP_ADMIN_PKG` in Oracle with thin ORDS handlers. |
| Governance storage | Five finalized typed reference/configuration tables, not a generic key-value store. |
| Demo data | Ordered deterministic Oracle seed SQL covering every table. |
| Evidence | External JSON/JUnit/SBOM/scan/performance results under ignored `.local/reports`. |
| Reports | Sanitized Markdown under `aidlc-docs/construction` plus root README commands. |
| Testing | Shared pytest/Hypothesis/API/DB/security/rebuild/performance suite. |

The construction baseline does not generate a new Visual Builder project or production deployment package.
