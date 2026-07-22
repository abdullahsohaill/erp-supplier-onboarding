# UOW-003 Code Generation Plan

## Status and Context

Approved under the user's blanket authorization. Implements US-007 through US-009 and FR-009/FR-010 after UOW-002, reusing the finalized schema and shared request/analysis projections.

## Steps

### Step 1: Load Approved Design
- [x] Load UOW-003 design, status model, decision JSON contract, APIs, roles, and wireframe behavior.
- [x] Confirm no decision-selection/correction table or other schema change is permitted.

### Step 2: Generate Review Logic
- [x] Generate `ERP_REVIEW_PKG` for queue/detail/dashboard and four atomic decisions.
- [x] Enforce role/state/comment/correction/supplier requirements and server-derived audit.
- [x] Preserve automatic score evidence and safe Requester guidance/action projections.

### Step 3: Generate ORDS and OpenAPI
- [x] Generate `ords/modules/uow003_review_module.sql` with five approved review handlers.
- [x] Add exact methods/schemas/privileges to the shared OpenAPI/security source.

### Step 4: Generate Tests
- [x] Generate US-007 through US-009 E2E, status/rollback/concurrency, role/projection, dashboard/filter, and performance tests.

### Step 5: Compile and Execute
- [x] Compile package/ORDS with zero invalid objects.
- [x] Run database, API, story, security, contract, and performance tests to green.

### Step 6: Summarize and Close
- [x] Create implementation/API/test summary in the UOW-003 code directory.
- [ ] Update state/audit/traceability and commit/push the verified unit on `construction-phase`.
