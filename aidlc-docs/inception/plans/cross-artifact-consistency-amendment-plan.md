# Cross-Artifact Consistency Amendment Plan

## Status

**Superseded. Do not use as an implementation baseline.**

This draft attempted to reconcile the artifacts by changing the ATP schema. A later source-of-truth review established that the committed `origin/main` `database-schema-design.md` must remain authoritative and that `db-schema.dbml` must mirror it. The active replacement is `schema-ground-truth-reconciliation-plan.md`.

## Rejected Draft Decisions

- Adding address columns that are absent from `SUPPLIER_REQUEST_SITE`.
- Adding a persisted integration correlation column or making `INTEGRATION_LOG.request_id` nullable.
- Adding dedicated Reviewer-selection or correction-item tables.
- Writing requestless supplier-reference synchronization runs into ATP integration logs.

## Superseding Decisions

- Keep the committed 18-table schema design and its 17 physical relationships unchanged; keep DBML synchronized to it.
- Map the UI address to `address_line1`, `address_line2`, `city`, `region`, `country_code`, and optional `postal_code`.
- Store Reviewer decision evidence and targeted guidance in the versioned JSON decision envelope inside `STATUS_HISTORY.action_comment`.
- Keep every ATP `INTEGRATION_LOG` request-scoped; monitor global supplier-reference sync in OIC.
- Use request ID, log ID, and OIC instance ID for request-integration troubleshooting.

## Closure

- [x] Draft identified as inconsistent with the committed schema.
- [x] DBML and schema-design companion restored to `origin/main`.
- [x] Work transferred to the schema-ground-truth reconciliation plan.
