# Component Dependencies

| From | To | Dependency Type | Notes |
|---|---|---|---|
| Visual Builder UI | ORDS API Layer | REST | UI never writes directly to Fusion. |
| ORDS API Layer | ATP | SQL/PLSQL | Main persistence and business rule execution. |
| Validation Component | ATP | Data | Reads request data and active `VALIDATION_RULES`; writes `VALIDATION_RESULT` findings with required rule foreign keys. |
| Duplicate Component | ATP | Data | Reads `DUPLICATE` rows from `REF_SCORING_RULE`, requests, and existing supplier references; writes match results. |
| Risk Component | ATP | Data | Reads `RISK` rows from `REF_SCORING_RULE`, validations, duplicates, and country risk data; writes assessments. |
| AI Summary Component | AI Provider | REST/SDK | Provider decision pending. Avoid sensitive data in prompts. |
| AI Summary Component | ATP | Data | Stores generated summary and metadata. |
| OIC Submit Component | ATP/ORDS | REST/DB Adapter | Reads approved requests and writes integration results. |
| OIC Submit Component | Fusion ERP | REST | Creates supplier/site or calls mock endpoint. |
| OIC Sync Component | Fusion ERP | REST | Reads suppliers/sites for duplicate reference data. |
| Support/Admin UI | Integration Logs | REST | Exposes troubleshooting and retry controls. |

## Data Flow Summary

1. Requester submits data in Visual Builder.
2. Visual Builder calls ORDS.
3. ORDS writes request to ATP.
4. Validation, duplicate, and risk components calculate findings.
5. AI summary is generated from deterministic findings.
6. Reviewer approves/rejects/corrects/duplicates the request.
7. Approved request is submitted by OIC to Fusion or mock Fusion.
8. Fusion response updates ATP and appears in UI.
