# UOW-003 NFR Design Patterns

| Pattern | Control |
|---|---|
| Atomic decision command | Lock, validate, append history, update status, commit once. |
| State-transition guard | Explicit Under Review source and allowed target/action combinations. |
| Immutable decision envelope | Versioned JSON, server actor/time, bounded arrays, allowlisted keys. |
| Safe role projection | Separate Requester and Reviewer/Support field allowlists. |
| Shared filter specification | Counts and rows derive from the same normalized filters. |
| Bounded query | Capped page size, allowlisted sort/filter, index-aligned predicates. |
| Fail-closed authorization | ORDS role plus package role and object/state checks. |
| Concurrency conflict | Row lock prevents competing final outcomes. |
| Example plus property tests | Decision examples plus owner/projection/filter invariants. |
