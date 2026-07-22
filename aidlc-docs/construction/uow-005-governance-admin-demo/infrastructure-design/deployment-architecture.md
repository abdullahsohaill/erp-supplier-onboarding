# UOW-005 Deployment Architecture

| Method | Path | Role |
|---|---|---|
| GET/PUT | `/admin-settings/high-risk-countries...` | Support/Admin |
| GET/PUT | `/admin-settings/validation-rules...` | Support/Admin |
| GET/PUT | `/admin-settings/scoring-rules...` | Support/Admin |
| GET/PUT | `/admin-settings/business-units...` | Support/Admin |
| GET/PUT | `/admin-settings/supplier-types...` | Support/Admin |
| POST | `/admin-settings/supplier-reference-sync` | Support/Admin |

Runtime calls follow loopback edge to private ORDS to `ERP_ADMIN_PKG` to typed finalized tables. Build/test/report commands run from the host, connect only to the local fingerprinted runtime, and write generated evidence to ignored paths.
