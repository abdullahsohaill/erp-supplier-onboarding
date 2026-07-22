# UOW-004 NFR Requirements

| ID | Requirement | Verification |
|---|---|---|
| U4-NFR-PERF-001 | Local mock submission/retry calls meet p95 3 seconds; list/detail/dashboard meet p95 1.5 seconds. | Timed tests |
| U4-NFR-REL-001 | Submission/retry callbacks are idempotent against existing supplier identifiers and business keys. | Replay tests |
| U4-NFR-REL-002 | Retry history/count/latest fields and request outcome commit atomically. | Fault injection |
| U4-NFR-REL-003 | Timeouts/retries are bounded; permanent business errors do not retry automatically. | Negative tests |
| U4-NFR-SEC-001 | Only Support/Admin sees technical messages/retry controls; only System/OIC can use internal callbacks/upserts. | OAuth tests |
| U4-NFR-SEC-002 | Raw bank, credentials, tokens, payload bodies, and protected data do not enter logs. | Leakage scans |
| U4-NFR-AUD-001 | Each request integration and retry records traceable request/OIC/actor/time/result identities. | DB/API assertions |
| U4-NFR-REC-001 | Failed eligible attempts remain diagnosable and recoverable after restart. | Restart/retry E2E |
| U4-NFR-MNT-001 | Local mock and production OIC/Fusion adapters share request/result contracts. | Contract tests |
| U4-NFR-TST-001 | Success, failure, ineligible retry, duplicate prevention, callback replay, reference upsert, and history invariants are executable. | Coverage matrix |

Production OIC/Fusion credentials, API versions, SLAs, network, certificate rotation, reconciliation, and disaster recovery remain customer gates.
