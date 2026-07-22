# UOW-002 Infrastructure Design

UOW-002 reuses UOW-001's local Oracle Autonomous AI Database Free ATP-mode service, bundled ORDS, loopback Nginx edge, generated trust/secrets, external migration runner, and host Python test environment.

| Concern | Mapping |
|---|---|
| Compute | `ERP_ANALYSIS_PKG` and extended `ERP_GOV_CHECK_PORT_PKG` execute in `ERP_APP`. |
| Storage | Finalized validation, duplicate, risk, AI, scoring, and supplier-reference tables. |
| API | Seven protected analysis operations under the shared versioned ORDS module surface. |
| Identity | Reviewer, Support/Admin, and System/OIC execute operations; Requester has only safe validation read through UOW-001. |
| Monitoring | Trace envelopes, external test reports, Oracle invalid-object/schema checks. |
| AI | Deterministic local generator; no outbound provider call in phase-one local runtime. |

No messaging or independent service is justified. Production AI endpoint, model governance, network egress, key storage, content filtering, SLA, and centralized monitoring require customer approval.
