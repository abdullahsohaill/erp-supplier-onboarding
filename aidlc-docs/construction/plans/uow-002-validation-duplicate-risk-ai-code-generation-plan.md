# UOW-002 Code Generation Plan

## Status and Context

Approved under the user's blanket authorization. Implements US-004 through US-006 and FR-005 through FR-008 after UOW-001. Application code remains at workspace root; Markdown summaries belong in this unit's `code/` directory.

## Steps

### Step 1: Load Approved Design and Shared Contracts
- [x] Load UOW-002 design, schema, package, API, role, and UOW-001 governed-port contracts.
- [x] Confirm no schema migration or new application table is required.

### Step 2: Generate Analysis Business Logic
- [x] Extend `ERP_GOV_CHECK_PORT_PKG` with automatic validation, duplicate, risk, and advisory-AI analysis.
- [x] Generate `ERP_ANALYSIS_PKG` with explicit run/read interfaces and role-safe envelopes.
- [x] Preserve active/inactive configuration, current/history, critical-blocker, warning, and AI guardrail rules.

### Step 3: Generate ORDS and OpenAPI
- [x] Generate `ords/modules/uow002_analysis_module.sql` with seven approved handlers.
- [x] Add exact protected operations/schemas to the shared OpenAPI contract and ORDS privileges.

### Step 4: Generate Tests
- [x] Generate examples for critical blockers, warning-only high-risk country, evidence, and advisory AI.
- [x] Generate configuration/determinism/normalization/property, contract, authorization, and performance tests.

### Step 5: Compile and Execute
- [x] Compile packages/ORDS with zero invalid objects.
- [x] Run database, API, story, property, security, and performance tests to green.

### Step 6: Summarize and Close
- [x] Create implementation/API/test summary in the UOW-002 code directory.
- [x] Update state/audit/traceability and commit/push the verified unit on `construction-phase`.
