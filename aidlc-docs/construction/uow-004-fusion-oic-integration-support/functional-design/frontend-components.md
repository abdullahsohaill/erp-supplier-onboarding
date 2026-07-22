# UOW-004 Frontend Components

| Component | User/State | API |
|---|---|---|
| Support dashboard | Failed, eligible, successful counts and selected log | support summary/list |
| Integration log list | Request/OIC/status/category/eligibility filters | `GET /integration-logs` |
| Integration log detail | Safe/technical messages, references, complete retry history | `GET /integration-logs/{logId}` |
| Retry command | Enabled only for eligible log and allowed request | `POST .../retry` |
| Submit command | Approved request only | `POST .../submit-to-fusion` |
| Reference sync command | Accepted state and OIC monitoring ID | admin sync trigger |

Technical details and retry controls are Support/Admin only. Generated values and secrets are never rendered.
