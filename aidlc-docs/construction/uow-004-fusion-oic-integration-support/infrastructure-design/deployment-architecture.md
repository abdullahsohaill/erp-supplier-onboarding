# UOW-004 Deployment Architecture

| Method | Path | Role |
|---|---|---|
| POST | `/requests/{requestId}/submit-to-fusion` | Support/Admin, System/OIC |
| GET | `/dashboard/support-summary` | Support/Admin |
| GET | `/integration-logs` | Support/Admin |
| GET | `/integration-logs/{logId}` | Support/Admin |
| POST | `/integration-logs/{logId}/retry` | Support/Admin |
| PUT | `/internal/supplier-references/{fusionSupplierId}` | System/OIC |
| PUT | `/internal/supplier-references/{fusionSupplierId}/sites/{fusionSiteId}` | System/OIC |
| POST | `/internal/requests/{requestId}/integration-results` | System/OIC |

Local path: client to edge to private ORDS to `ERP_INTEGRATION_PKG` to Oracle tables/mock. Production path adds OIC/Fusion beyond the package adapter; it is deliberately not activated by local construction credentials.
