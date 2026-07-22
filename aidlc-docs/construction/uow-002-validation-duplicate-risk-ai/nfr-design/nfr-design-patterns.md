# UOW-002 NFR Design Patterns

| ID | Pattern | Applied Control |
|---|---|---|
| U2-PAT-001 | Atomic evidence run | Lock request, supersede current flags, insert complete new run, commit once. |
| U2-PAT-002 | Configuration snapshot | Persist scoring version and rule/reason codes with every result. |
| U2-PAT-003 | Deterministic normalization | Trim/case/whitespace normalization and bounded comparison functions. |
| U2-PAT-004 | Critical-signal adapter | Exact duplicate signals become validation blockers only when corresponding validation rule is active. |
| U2-PAT-005 | Safe role projection | Requester and Reviewer/Support views have separate field allowlists. |
| U2-PAT-006 | Advisory AI boundary | Curated facts in, schema-constrained explanation out, no command interface. |
| U2-PAT-007 | Bounded evidence query | Indexed request/run/current predicates and capped candidate arrays. |
| U2-PAT-008 | Fail-safe analysis | Internal failures roll back and expose a stable trace-bearing safe error. |
| U2-PAT-009 | Hybrid test oracle | Critical examples plus deterministic/property/metamorphic checks. |

These patterns cover all U2 NFRs without introducing infrastructure or schema outside the approved baseline.
