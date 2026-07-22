# UOW-002 NFR Requirements

| ID | Requirement | Verification |
|---|---|---|
| U2-NFR-PERF-001 | Warm local explicit analysis calls should meet p95 2.5 seconds on the documented dataset; submission analysis should meet p95 4 seconds. | Timed API suite |
| U2-NFR-CAP-001 | Candidate queries and evidence projections are bounded to 100 rows and use approved indexes. | Query/contract tests |
| U2-NFR-REL-001 | Current-flag changes and new evidence persist atomically; failures retain the prior valid current run. | Fault-injection tests |
| U2-NFR-REL-002 | Identical facts plus configuration produce deterministic duplicate/risk output. | Property tests |
| U2-NFR-SEC-001 | Requesters cannot access duplicate candidate, risk, or AI endpoints/evidence. | Role/IDOR tests |
| U2-NFR-SEC-002 | Raw bank values, tokens, credentials, prompts, and protected candidate fields never enter logs or AI input. | Static/runtime scans |
| U2-NFR-SEC-003 | Only allowlisted roles may rerun analysis; calculated fields are server-owned. | Authz/mass-assignment tests |
| U2-NFR-EXP-001 | Every finding/reason includes stable rule identity, version where applicable, and business-safe explanation. | Data/API assertions |
| U2-NFR-AI-001 | AI output validates against the approved advisory schema and cannot trigger state changes. | Contract/negative tests |
| U2-NFR-MNT-001 | Rule participation and thresholds remain configuration-driven without schema edits. | Toggle/version tests |
| U2-NFR-TST-001 | Example tests cover every critical path; PBT covers normalization, determinism, bounds, and invariants. | Coverage matrix |

Production throughput, provider SLA, model hosting, and compliance classifications remain customer gates; no production claim is made.
