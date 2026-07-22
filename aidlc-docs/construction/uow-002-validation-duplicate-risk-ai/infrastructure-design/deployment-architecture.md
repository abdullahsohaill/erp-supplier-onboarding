# UOW-002 Deployment Architecture

## Runtime Path

1. Authorized HTTPS request enters the loopback edge and private ORDS listener.
2. ORDS invokes `ERP_ANALYSIS_PKG` with server-derived principal context.
3. The package calls the governed-check port inside Oracle.
4. Active catalogs and request/reference facts are read; evidence rows are written atomically.
5. Role-safe JSON returns through ORDS and the edge.

## Protected Operations

| Method | Path | Roles |
|---|---|---|
| POST | `/requests/{requestId}/validate` | Reviewer, Support/Admin, System/OIC |
| POST | `/requests/{requestId}/duplicate-check` | Reviewer, Support/Admin, System/OIC |
| GET | `/requests/{requestId}/duplicate-matches` | Reviewer, Support/Admin |
| POST | `/requests/{requestId}/risk-score` | Reviewer, Support/Admin, System/OIC |
| GET | `/requests/{requestId}/risk-assessment` | Reviewer, Support/Admin |
| POST | `/requests/{requestId}/ai-summary` | Reviewer, Support/Admin |
| GET | `/requests/{requestId}/ai-summaries` | Reviewer, Support/Admin |

ORDS remains private, database ports remain loopback-only, and no AI/provider port or public ingress is added.
