# UOW-004 NFR Design Patterns

| Pattern | Control |
|---|---|
| Port/adapter integration | Deterministic local mock and future OIC implementation share contracts. |
| Idempotency guard | Approved status, existing supplier identifiers, Fusion business IDs, and locked log/request. |
| Atomic embedded retry | Append JSON and update count/latest/result/request in one transaction. |
| Safe diagnostic split | User message separated from Support-only technical message. |
| Callback allowlist | System/OIC role, typed fields, raw-bank rejection, replay-safe updates. |
| Bounded recovery | Eligibility/status gates and no automatic retry loop. |
| Request correlation | Every application log carries request and OIC identities. |
| Reference upsert | Merge by Fusion supplier/site identity and normalized values. |
| Restart-safe persistence | Oracle named volume and committed log/request state. |
