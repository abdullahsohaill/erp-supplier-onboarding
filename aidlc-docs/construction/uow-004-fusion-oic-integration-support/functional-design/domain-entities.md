# UOW-004 Domain Entities

| Entity | Persistence/Contract | Invariant |
|---|---|---|
| Integration attempt | `INTEGRATION_LOG` | Request-scoped, OIC identity, status, safe/technical messages, references. |
| Retry entry | `retry_history_json` | Attempt, actor, timestamp, result, message, retry OIC ID; append-only. |
| Fusion outcome | `SUPPLIER_REQUEST` Fusion/status columns | Supplier identifiers appear only after successful creation. |
| Existing supplier | `EXISTING_SUPPLIER_REF` | Idempotent Fusion key, normalized duplicate facts, last sync. |
| Existing supplier site | `EXISTING_SUPPLIER_SITE_REF` | Idempotent site key linked to existing supplier. |
| OIC sync run | OIC monitoring contract | Not persisted as requestless application log. |
| Local Fusion mock | Deterministic adapter result | `SUP-MOCK-*`/safe references, no external side effect. |

The finalized merged integration-log/retry schema is used without a retry-history table.
