# Integration Log and Retry History Merge Amendment Plan

## Scope

Merge `INTEGRATION_RETRY_HISTORY` into `INTEGRATION_LOG` while preserving retry auditability, dashboard performance, and controlled-retry behavior across the requirements and application-design baseline.

## Design Decisions

- Remove the standalone `INTEGRATION_RETRY_HISTORY` table and its two physical foreign keys.
- Add `INTEGRATION_LOG.retry_history_json` as an append-only JSON array.
- Store `attemptNumber`, `actorUser`, `attemptedAt`, `result`, `message`, and `oicInstanceId` in every retry-history entry.
- Retain `retry_count`, `retry_eligible_flag`, `last_retry_at`, and `last_retry_by` as searchable summary columns.
- Append the JSON entry and update all retry summary columns atomically in one transaction.
- Preserve the current retry API and support/admin experience; only the persistence shape changes.

## Execution Checklist

- [x] Record the complete merge request and trace all retry-history references.
- [x] Update requirements, user stories, and traceability where persistence behavior is specified.
- [x] Update technical design tables, relationships, constraints, JSON contract, APIs, and retry flow.
- [x] Update `db-schema.dbml` to remove the retry-history table and add retry JSON to the integration log.
- [x] Regenerate the schema inventory, Mermaid ERD, relationship catalog, counts, and schema rules.
- [x] Update dependent component, service, unit, and planning artifacts.
- [x] Validate DBML/ERD structure, JSON examples, counts, legacy-name removal, and cross-file consistency.
- [x] Update AI-DLC state and audit records with completion results.

## Validation Criteria

- No active design artifact contains an `INTEGRATION_RETRY_HISTORY` table or foreign key.
- `INTEGRATION_LOG.retry_history_json` is defined consistently in DBML, technical design, requirements, and the complete schema companion.
- The retry JSON entry contract contains all six required fields.
- Retry history remains visible to Support/Admin without changing the current wireframe behavior.
- Schema table, column, and physical-relationship totals match between DBML and the Mermaid ERD.
