# UOW-005 Infrastructure Design

UOW-005 reuses the shared Oracle ATP/ORDS/edge runtime. `ERP_ADMIN_PKG` runs in `ERP_APP`; Admin ORDS routes use the Support/Admin role. Seed, verification, scans, SBOM, performance, and reporting are bounded host processes using the existing `.venv`, pinned tools, and ignored `.local/reports`/cache roots.

No long-running demo, report, or governance service is added. Application state remains in the finalized 18 tables; migration and test evidence remains external.

Production requires customer governance for configuration promotion/approval, SSO/MFA, separation of duties, secrets manager, centralized immutable audit, backup/DR, deployment approvals, monitoring, retention, and real ATP/OIC/Fusion/AI services.
