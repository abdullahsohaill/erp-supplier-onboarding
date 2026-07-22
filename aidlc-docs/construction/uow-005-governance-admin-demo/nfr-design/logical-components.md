# UOW-005 Logical Components

| Component | Responsibility |
|---|---|
| Admin API facade | Five setting families plus reference-sync trigger. |
| Admin authorization | Support/Admin role assertion and safe errors. |
| Typed setting repositories | Read/update stable keys and audit fields. |
| Seed orchestrator | Ordered representative fixtures across all tables. |
| Schema/seed verifier | Exact parity, FK/JSON/current/retry invariants. |
| Scenario runner | Execute US-001 through US-014 and non-happy paths. |
| Quality gate runner | Lint, contracts, tests, scans, SBOM, performance. |
| Evidence reporter | Redacted machine evidence and consolidated Markdown. |
| Proposal/demo packager | Traceable limitations, manual gates, walkthrough. |
