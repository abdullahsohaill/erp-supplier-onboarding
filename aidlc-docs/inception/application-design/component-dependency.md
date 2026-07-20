# Component Dependencies

| From | To | Dependency Type | Notes |
|---|---|---|---|
| Visual Builder UI | ORDS API Layer | REST | UI never writes directly to Fusion. |
| ORDS API Layer | ATP | SQL/PLSQL | Main persistence and business rule execution. |
| Validation Component | ATP | Data | Reads request data and active `VALIDATION_RULES`; writes `VALIDATION_RESULT` findings with required rule foreign keys. |
| Duplicate Component | ATP | Data | Reads `DUPLICATE` rows from `REF_SCORING_RULE`, requests, and existing supplier references; writes match results. |
| Risk Component | ATP | Data | Reads `RISK` rows from `REF_SCORING_RULE`, validations, duplicates, and country risk data; writes assessments. |
| Review Workflow Component | ATP | Data | Reads request evidence and atomically appends the validated decision envelope to `STATUS_HISTORY.action_comment` with actor and timestamp. |
| AI Summary Component | AI Provider | REST/SDK | Provider decision pending. Avoid sensitive data in prompts. |
| AI Summary Component | ATP | Data | Stores generated summary and metadata. |
| OIC Submit Component | ATP/ORDS | REST/DB Adapter | Reads approved requests and writes integration outcomes plus atomic retry-history JSON and summary updates. |
| OIC Submit Component | Fusion ERP | REST | Creates supplier/site or calls mock endpoint. |
| OIC Sync Component | Fusion ERP and ATP/ORDS | REST | Reads suppliers/sites, upserts duplicate-reference rows, updates `last_sync_at`, and keeps global run outcomes in OIC-native monitoring. |
| Support/Admin UI | Integration Logs | REST | Exposes troubleshooting, embedded retry history, and retry controls. |

## Data Flow Summary

1. Requester submits data in Visual Builder.
2. Visual Builder calls ORDS.
3. ORDS writes request to ATP.
4. Validation, duplicate, and risk components calculate findings.
5. AI summary is generated from curated deterministic findings; Reviewer checkbox selections remain temporary UI decision state.
6. Reviewer approves/rejects/corrects/duplicates the request; factor selections and targeted correction guidance are written in the status-history decision envelope without changing the automatic score.
7. Approved request is submitted by OIC to Fusion or mock Fusion.
8. Fusion response updates ATP and appears in UI.
