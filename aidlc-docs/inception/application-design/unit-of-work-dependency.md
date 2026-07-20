# Unit of Work Dependencies

| Unit | Depends On | Can Run In Parallel? | Notes |
|---|---|---:|---|
| UOW-001 Core Request Intake | None | No | Foundation for all later units. |
| UOW-002 Validation/Duplicate/Risk | UOW-001 | Partially | Rule design can start early; implementation needs schema. |
| UOW-003 Review Workflow and Business Dashboards | UOW-001, UOW-002 | Partially | UI shell can start early; decisions need statuses, duplicate results, risk outputs, and AI summaries. |
| UOW-004 Fusion/OIC Integration and Support | UOW-001, UOW-003 | Partially | Payload mapping can start early; final submission needs approved request status and retry governance. |
| UOW-005 Governance, Admin Settings, Demo, and Proposal Hardening | All units | Yes, ongoing | Admin Settings/reference-table behavior, sample scenarios, tests, and proposal materials should guide each unit from the start. |
