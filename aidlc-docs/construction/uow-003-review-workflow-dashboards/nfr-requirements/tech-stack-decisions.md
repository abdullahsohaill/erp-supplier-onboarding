# UOW-003 Tech Stack Decisions

| Area | Decision |
|---|---|
| Workflow | Oracle PL/SQL transaction in `ERP_REVIEW_PKG`. |
| Audit | Existing `STATUS_HISTORY` with validated versioned JSON envelope. |
| Queries | Bounded Oracle SQL projections using finalized indexes. |
| API/security | Shared bundled ORDS 25.4 OAuth2 roles/privileges and edge controls. |
| Contract | Shared OpenAPI 3.0.3 paths/schemas. |
| UI | Approved static wireframe specification; no Visual Builder code generated. |
| Tests | pytest direct DB/API/E2E/property/security/performance suite. |

No workflow engine, queue, cache, or additional audit table is required.
