# UOW-004 Business Rules

| ID | Rule |
|---|---|
| INT-BR-001 | Only Approved requests can begin supplier creation. |
| INT-BR-002 | Visual Builder never calls Fusion directly. |
| INT-BR-003 | Existing Fusion supplier number/id blocks duplicate creation. |
| INT-BR-004 | Every application integration log has a required request ID. |
| INT-BR-005 | Business users receive safe messages; technical detail is Support/Admin only. |
| INT-BR-006 | Retry requires failed status and retry eligibility on the selected log. |
| INT-BR-007 | Rejected, Marked Duplicate, or already-created requests cannot retry. |
| INT-BR-008 | Retry append, count, latest actor/time, result, and request outcome are atomic. |
| INT-BR-009 | `retry_count` equals embedded retry-array length after every completed retry. |
| INT-BR-010 | Supplier-reference upsert is idempotent on Fusion supplier/site IDs. |
| INT-BR-011 | Reference sync is monitored by OIC instance and does not create a requestless integration log. |
| INT-BR-012 | Full bank values and credentials are prohibited from payloads, logs, responses, and mocks. |
| INT-BR-013 | Bank account creation/payment setup is out of phase-one scope. |
| INT-BR-014 | Local deterministic mocks preserve the production contract shape without claiming real Fusion creation. |
