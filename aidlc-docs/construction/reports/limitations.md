# Limitations and Production Gates

- The runtime is a local prototype, not a production Oracle Cloud deployment.
- The selected environment is local Oracle ADB Free in ATP mode; no Oracle Playground or managed cloud database is configured or required.
- Bundled ORDS reports version 25.4 even though the ADB release is 26ai.
- Fusion and OIC behavior is deterministic local PL/SQL mock behavior; no real tenant calls were made.
- Supplier-reference sync is represented through protected contracts and mock data, not a deployed OIC schedule.
- AI explanations are deterministic advisory output, not a live model call.
- Visual Builder screens are specified and mocked, not deployed as a production application.
- Production SSO, centralized logs, tamper-evident retention, alerts, backups, HA, RTO/RPO, and compliance controls require customer decisions and cloud infrastructure.
- Performance results describe one local Apple Silicon/Docker host and must not be used as production capacity evidence.
- The official local Oracle ADB Free 26ai image has a blocking production-use vendor vulnerability finding documented in the security report.
- Full bank account values and phase-1 payment setup are intentionally out of scope; only masked/tokenized metadata is handled.
