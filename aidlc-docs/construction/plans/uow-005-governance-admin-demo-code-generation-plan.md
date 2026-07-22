# UOW-005 Code Generation Plan

## Status and Context

Approved under the user's blanket authorization. Implements US-013/US-014 and FR-014/FR-015, completes all 42 endpoints, and closes the local construction baseline with deterministic demo data and consolidated evidence.

## Steps

### Step 1: Load Approved Design
- [x] Load UOW-005 governance, Admin Settings, sensitive-data, seed, demo, reporting, API, and schema contracts.
- [x] Confirm typed finalized tables remain authoritative and no generic settings/demo/migration table is introduced.

### Step 2: Generate Admin Logic
- [x] Generate `ERP_ADMIN_PKG` for five governed setting families.
- [x] Enforce Support/Admin role, stable identities, active toggles, allowlisted fields, and audit values.
- [x] Preserve Admin Settings label and Reviewer-only decision-factor selection boundary.

### Step 3: Generate ORDS and OpenAPI
- [x] Generate `ords/modules/uow005_admin_module.sql` with eleven approved handlers.
- [x] Complete shared ORDS roles/privileges, client registration, and exact 42-operation OpenAPI contract.

### Step 4: Generate Data and Tests
- [x] Generate deterministic every-table seeds and all approved happy/non-happy demo scenarios.
- [x] Generate US-013/US-014 E2E, admin auth/input/audit/toggle, rebuild, secret, contract, and performance tests.

### Step 5: Compile and Execute
- [x] Compile package/ORDS with zero invalid objects and verify exact 18/189/17 schema.
- [x] Run complete 14-story/database/API/property/security/recovery/performance suite to green.

### Step 6: Report and Close
- [ ] Generate migration, implementation, test, security, performance, limitation, and manual-step reports.
- [ ] Generate Build and Test instruction set and consolidated report.
- [ ] Update state/audit/traceability and commit/push all verified construction artifacts on `construction-phase`.
