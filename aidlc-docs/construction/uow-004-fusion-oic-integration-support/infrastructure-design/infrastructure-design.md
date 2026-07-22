# UOW-004 Infrastructure Design

The executable local baseline uses `ERP_INTEGRATION_PKG` inside the shared Oracle ATP runtime as a deterministic OIC/Fusion mock. ORDS exposes Support/Admin and System/OIC routes through the existing loopback edge and private listener. The finalized Oracle volume stores request/log/retry/reference state.

No local OIC server, Fusion clone, message broker, or new database service is introduced. Mock references use `mock://` identifiers and have no external side effect.

Production replaces only the adapter boundary with customer OIC and Fusion REST connections. It requires approved endpoints, OAuth/credentials, certificates, private networking, timeouts, retry/reconciliation policy, monitoring, payload mappings, Fusion feature/API versions, and DR/SLA decisions.
