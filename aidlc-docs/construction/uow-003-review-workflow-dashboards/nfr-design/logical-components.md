# UOW-003 Logical Components

| Component | Responsibility |
|---|---|
| Review API facade | Queue/detail/dashboard and four decision interfaces. |
| Decision validator | Allowed keys, required fields, array bounds, status/action policy. |
| Decision transaction | Request lock, history append, status update. |
| Decision projection | Safe Reviewer result and Requester guidance. |
| Queue query | Bounded status/filter/sort pagination. |
| Dashboard aggregator | Role-specific counts using shared filter semantics. |
| Authorization guard | Reviewer role and Requester ownership. |
| Review test harness | Contract, E2E, security, atomicity, filter and performance checks. |

The implementation boundary is `ERP_REVIEW_PKG`; it reads UOW-002 evidence but never mutates automatic analysis.
