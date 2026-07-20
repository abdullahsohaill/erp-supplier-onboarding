# Database Schema Design Diagram Plan

## Scope

Create the authoritative Markdown schema design companion to Section 7 of `technical-design.md`, presenting every ATP table as an ERD table box, showing every physical foreign-key connection, and documenting standalone configuration tables without inventing database relationships. Maintain `db-schema.dbml` as the synchronized machine-readable equivalent.

## Execution Checklist

- [x] Read the current AI-DLC state and applicable content/application-design rules.
- [x] Inspect the supplied schema-diagram reference image, Section 7 of `technical-design.md`, and `db-schema.dbml`.
- [x] Reconcile all tables, columns, primary keys, unique keys, foreign keys, and cardinalities.
- [x] Draft the full Mermaid ER diagram, relationship catalog, and text alternatives.
- [x] Validate Mermaid ER syntax, entity/relationship coverage, Markdown structure, and source consistency.
- [x] Create `aidlc-docs/inception/application-design/database-schema-design.md` and add a reference from Section 7.
- [x] Update AI-DLC state and audit records with completion and validation results.

## Validation Criteria

- All 18 current schema tables appear exactly once in the full ER diagram and DBML equivalent.
- All 17 current physical foreign-key references appear as relationships in both artifacts.
- Every diagram field has a matching DBML field with the same data type and key role.
- Standalone configuration tables are shown without false physical foreign keys.
- The diagram includes a text alternative and an explicit relationship catalog.
- Sensitive bank fields remain masked or hashed as defined by the baseline.
