# UOW-004 Code Generation Plan

## Status and Context

Approved under the user's blanket authorization. Implements US-010 through US-012 and FR-011 through FR-013 using deterministic local Fusion/OIC behavior and the approved production adapter contracts.

## Steps

### Step 1: Load Approved Design
- [x] Load UOW-004 design, integration/retry JSON, mock/OIC/Fusion, security, API, and schema contracts.
- [x] Confirm no retry-history table, requestless integration log, or bank/payment creation is permitted.

### Step 2: Generate Integration Logic
- [x] Generate `ERP_INTEGRATION_PKG` for submit, controlled retry, logs, dashboard, reference sync/upsert, and callback.
- [x] Implement deterministic local supplier creation and retry with idempotency/status guards.
- [x] Implement atomic embedded retry history and role-safe diagnostics.

### Step 3: Generate ORDS and OpenAPI
- [x] Generate `ords/modules/uow004_integration_module.sql` with nine approved handlers.
- [x] Add exact Support/Admin and System/OIC operations/schemas/privileges to shared contracts.

### Step 4: Generate Tests
- [x] Generate US-010 through US-012 E2E plus success/failure/retry/replay/upsert/security/restart/property/performance tests.

### Step 5: Compile and Execute
- [x] Compile package/ORDS with zero invalid objects.
- [x] Run database, API, story, security, recovery, contract, and performance tests to green.

### Step 6: Summarize and Close
- [x] Create implementation/API/test summary in the UOW-004 code directory.
- [x] Update state/audit/traceability and commit/push the verified unit on `construction-phase`.
