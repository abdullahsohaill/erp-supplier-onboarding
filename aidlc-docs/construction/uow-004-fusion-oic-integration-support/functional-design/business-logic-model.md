# UOW-004 Business Logic Model

## Approved Supplier Submission

1. Support/Admin or System/OIC requests submission for an Approved request.
2. Lock the request; reject wrong status, existing supplier number, or duplicate final state.
3. Move to Submitted to Fusion and append history.
4. Local mode invokes a deterministic mock producing stable supplier/response references; production mode delegates to OIC outside this local package boundary.
5. Success records request identifiers, request-scoped integration log, Created in Fusion status, and history atomically.
6. Failure/callback records safe business and Support-only technical diagnostics and Integration Failed status.

## Controlled Retry

1. Support/Admin locks the selected failed log and linked request.
2. Verify request linkage, failed/eligible state, allowed request status, no existing supplier number, and retry history/count agreement.
3. Execute deterministic retry/mock or production OIC adapter.
4. Append one immutable history object and update count/latest actor/time/status in the same transaction.
5. On success, update the original log and request to Created in Fusion; no second requestless log is created.

## Reference Synchronization

Support/Admin trigger returns an OIC monitoring identity. System/OIC idempotently upserts supplier and site references by Fusion business IDs, normalizes matching fields, prohibits raw bank values, and records `last_sync_at`. Global sync is monitored in OIC rather than request-scoped `INTEGRATION_LOG`.
