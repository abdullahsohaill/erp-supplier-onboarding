# UOW-005 NFR Design Patterns

| Pattern | Control |
|---|---|
| Typed governance repositories | Dedicated finalized tables and business keys per setting family. |
| Version-preserving update | Scoring updates target an existing type/code/version identity. |
| Atomic single-setting command | Allowlist, validate, update actor/time, commit once. |
| Deny-by-default admin boundary | ORDS role plus package Support/Admin assertion. |
| Deterministic fixture set | Stable business keys, synthetic values, valid JSON/FKs, every-table coverage. |
| Reproducible rebuild | Ordered bootstrap/migration/package/ORDS/seed manifest plus parity gates. |
| Evidence chain | Git/image/checksum/test/run identity in ignored machine reports and sanitized summaries. |
| Redaction promotion gate | Only reviewed sanitized Markdown is committed. |
| Scenario traceability | Demo scenarios map to stories, requirements, endpoints, rows, and tests. |
