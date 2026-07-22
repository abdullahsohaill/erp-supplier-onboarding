# UOW-003 Infrastructure Design

UOW-003 is deployed into the shared local Oracle ATP/ORDS runtime. `ERP_REVIEW_PKG` owns decision commands and queue/dashboard projections; thin ORDS handlers expose the approved review operations through the existing edge and OAuth2 boundary.

| Resource | Use |
|---|---|
| Oracle ATP | Request locks, status/history transaction, bounded queue/count SQL. |
| Bundled ORDS | Reviewer and shared request/detail/dashboard routes. |
| Nginx edge | Loopback HTTPS, route/body/rate policy, redacted access logs. |
| Host test environment | Decision, dashboard, role, conflict, projection, and performance tests. |

No asynchronous messaging is needed because a decision is one short synchronous transaction. Production identity/MFA, availability, centralized audit, retention, and UI hosting remain customer decisions.
