# Schema Ground-Truth Reconciliation Plan

## Objective

Conduct a complete AI-DLC Inception baseline review using the committed `origin/main` version of `aidlc-docs/inception/application-design/database-schema-design.md` as the authoritative ATP schema design. Align every active artifact without adding tables, columns, keys, or relationships that are absent from that schema.

## Ground-Truth Rules

- The committed `database-schema-design.md` at `origin/main` is authoritative for ATP tables, columns, nullability, keys, indexes, and physical relationships.
- `db-schema.dbml` must remain a complete machine-readable physical equivalent of that design.
- Requirements and UI behavior may use application validation and derived API fields, but must not claim unsupported ATP persistence.
- Global OIC activity that has no request-owned ATP row must use OIC-native observability rather than a fabricated `INTEGRATION_LOG.request_id`.
- Any future schema enhancement must be listed as a construction/customer decision, not silently added to the approved baseline.

## Execution Checklist

- [x] Verify local HEAD and `origin/main` are synchronized and identify uncommitted schema divergence.
- [x] Restore the DBML and complete ERD companion to the committed schema ground truth.
- [x] Build and verify the authoritative table, column, key, relationship, and JSON-field inventory.
- [x] Audit requirements, verification answers, traceability, business rules, and proposal/demo against the schema.
- [x] Audit personas, stories, sequence diagrams, units, components, methods, services, and dependencies against the schema.
- [x] Audit technical architecture, status model, ORDS endpoints, payloads, OIC/Fusion flows, security, resiliency, and test contracts against the schema.
- [x] Audit wireframe specification and HTML mockup fields/actions against the schema and approved behavior.
- [x] Correct every active-artifact contradiction without changing the authoritative schema model.
- [x] Validate Markdown, Mermaid structure, JSON, DBML/ERD parity, traceability, terminology, HTML/JavaScript, and absence of unsupported schema claims.
- [x] Update AI-DLC state and record completion plus extension compliance in the audit log.

## Completion Criteria

- Every ATP persistence claim resolves to an existing DBML table and column.
- The DBML has exactly the same tables, fields, and physical relationships as the authoritative schema design.
- All 15 functional requirements remain mapped across no more than 14 user stories.
- Submit blockers preserve an editable request status and never enter the Reviewer queue.
- Reviewer selections and targeted feedback use an explicitly documented existing-schema representation or are identified as non-persistent UI state.
- Request-scoped integration retries match `INTEGRATION_LOG`; global supplier synchronization uses OIC-native logs.
- Wireframe fields have an explicit API-to-schema mapping and do not imply nonexistent ATP columns.
- The baseline is ready for the next, separately approved mock-data and ORDS planning stage.
