# UOW-004 Logical Components

| Component | Responsibility |
|---|---|
| Integration facade | Submit, retry, logs, dashboard, sync trigger, callbacks. |
| Fusion mock adapter | Deterministic local success/retry outcome. |
| OIC/Fusion port | Future production payload/result boundary. |
| Integration repository | Request-scoped logs and JSON retry history. |
| Retry coordinator | Eligibility, idempotency, append/count/outcome transaction. |
| Reference repository | Idempotent supplier/site upsert and normalization. |
| Support projection | Technical detail and history restricted to Support/Admin. |
| System callback guard | System/OIC role and allowlisted payloads. |
| Integration test harness | Success/failure/retry/replay/upsert/security/restart/performance. |
