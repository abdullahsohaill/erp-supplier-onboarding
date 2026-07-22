# UOW-004 Tech Stack Decisions

| Area | Decision |
|---|---|
| Local integration | Deterministic PL/SQL mock in `ERP_INTEGRATION_PKG`. |
| Production boundary | OIC orchestration using documented ORDS/Fusion candidate mappings. |
| State/audit | Finalized request, integration-log, status-history, and supplier-reference tables. |
| API/security | Shared ORDS OAuth2 roles; System/OIC internal routes separated from Support routes. |
| Retry | Atomic JSON history in originating log, no extra table/queue. |
| Tests | pytest E2E/replay/property/security/restart/performance tests. |

No real OIC/Fusion credential or endpoint is required for the local construction baseline.
