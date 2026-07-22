# Migration Summary

## Result

The external migration runner installed and verified 47 ordered assets against local Oracle ADB Free in ATP mode. A restart/rerun completed successfully with exact 18-table, 189-column, 17-foreign-key parity and zero invalid objects.

## Asset Breakdown

| Asset group | Count | Purpose |
|---|---:|---|
| DDL migrations | 7 | Reference, workflow, analysis, integration tables; constraints; indexes; views |
| Local QA read grant | 1 | `ERP_VERIFY` receives SELECT on finalized tables/views and no write privilege |
| Validators | 2 | Exact schema fingerprint and valid-object checks |
| Package specs/bodies | 30 | 15 modular PL/SQL packages |
| ORDS modules | 5 | 42 versioned handlers |
| ORDS security assets | 2 | Roles/privileges and generated-secret local clients |
| Total | 47 | Complete install manifest |

## Ordered DDL

1. Create typed reference/configuration tables.
2. Create supplier request aggregate and status history.
3. Create validation, duplicate, risk, and AI evidence.
4. Create integration and existing-supplier reference data.
5. Apply the 17 foreign keys and other constraints.
6. Apply indexes for owner/status, review, evidence, reference, and support queries.
7. Create four role-safe/helper views.

## Rerun and Seed Behavior

The runner records source checksums in ignored evidence rather than adding an unsupported application table. It skips only unchanged assets when the live schema has the expected 18-table fingerprint; the verifier grant and validators always rerun. Package-spec changes force package recompilation. The final verified rerun recorded 44 unchanged assets as `SKIPPED_VERIFIED` and passed the grant plus two validators. Three idempotent seed files populate all 18 tables, then identity values are synchronized and seed/retry invariants are checked.
