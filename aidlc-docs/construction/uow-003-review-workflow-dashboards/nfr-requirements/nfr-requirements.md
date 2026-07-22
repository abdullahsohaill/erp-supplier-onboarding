# UOW-003 NFR Requirements

| ID | Requirement | Verification |
|---|---|---|
| U3-NFR-PERF-001 | Warm local dashboard/list/detail calls meet p95 1.5 seconds; decisions meet p95 2 seconds. | Timed API tests |
| U3-NFR-CAP-001 | Lists cap at 100 rows and all filters are allowlisted/index-aligned. | Contract/query tests |
| U3-NFR-REL-001 | Decision status and history commit once or roll back together. | Fault injection |
| U3-NFR-REL-002 | Concurrent/stale decisions cannot create two outcomes. | Lock/conflict tests |
| U3-NFR-SEC-001 | Reviewer role and object-level rules protect all decision operations. | OAuth/wrong-role tests |
| U3-NFR-SEC-002 | Requester projections omit risk score, reasons, AI, candidates, and technical detail. | Leakage/property tests |
| U3-NFR-AUD-001 | Every decision records server-derived actor/time, action code, from/to status, and valid versioned envelope. | DB assertions |
| U3-NFR-USE-001 | Reviewer guidance uses business language; corrections identify actionable items. | Contract/UI review |
| U3-NFR-USE-002 | Counts match active filters and empty/None actions do not behave as links. | E2E tests |
| U3-NFR-TST-001 | All four decisions, state guards, evidence limits, filters, owner isolation, and rollback paths have executable tests. | Coverage matrix |

Production concurrency, availability, accessibility certification, retention, and SSO remain customer gates.
