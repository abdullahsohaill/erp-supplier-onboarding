# UOW-005 NFR Requirements

| ID | Requirement | Verification |
|---|---|---|
| U5-NFR-PERF-001 | Warm local Admin reads/updates meet p95 1.5 seconds on the governed dataset. | Timed API tests |
| U5-NFR-REL-001 | One setting mutation is atomic and survives normal container restart. | DB/restart tests |
| U5-NFR-REL-002 | Seed reruns are deterministic or fail clearly without silent duplication. | Rebuild/rerun tests |
| U5-NFR-SEC-001 | All Admin routes require Support/Admin; System/Requester/Reviewer are denied. | OAuth tests |
| U5-NFR-SEC-002 | Updates use allowlists, bounds, stable keys, server actor/time, and safe errors. | Abuse/DB assertions |
| U5-NFR-SEC-003 | Reports, source, logs, and artifacts contain no generated secrets or sensitive supplier/bank material. | Gitleaks/static/runtime scans |
| U5-NFR-AUD-001 | Governed rows preserve created/updated actor/time and version identity. | DB assertions |
| U5-NFR-MNT-001 | Every FR, US, API, package, migration, and test remains traceable in reports. | Traceability validation |
| U5-NFR-USE-001 | Admin labels use business language, clear active state, and visible save/error outcomes. | Wireframe/contract review |
| U5-NFR-REP-001 | Clean rebuild produces exact 18/189/17 schema and representative data in all tables. | Automated rebuild suite |
| U5-NFR-REP-002 | Reports record Git/image/tool versions, commands, environment, results, limitations, and manual gates. | Report validation |

Production governance approval workflow, dual control, retention, SSO/MFA, audit export, deployment, and monitoring remain customer gates.
