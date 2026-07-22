# Local Oracle Broad Test Suite Amendment Plan

## Status and Scope

Approved by the user's direct request on 2026-07-22. This Build and Test amendment keeps the official local Oracle Autonomous Database Free runtime in ATP mode as the only active execution target and consolidates the verification suite to 60-70 broad tests. It does not change the finalized 18-table, 189-column, 17-relationship schema, the 42-operation API contract, or runtime authorization behavior.

## Step 1: Select the Local Runtime

- [x] Confirm the existing local Oracle ADB Free ATP and bundled ORDS services are healthy.
- [x] Remove the managed-cloud profile, preflight, test, and setup guide from the active repository workflow.
- [x] Keep generated local credentials, certificates, and trust material under ignored `.local/` paths.

## Step 2: Consolidate Test Granularity

- [x] Consolidate query-guard examples into broad accepted-input and rejected-input tests.
- [x] Consolidate database contract cases while retaining every table, column, key, index, JSON, seed, package, and view assertion.
- [x] Consolidate OpenAPI and ORDS contract cases while retaining all 42 operation and role checks.
- [x] Consolidate runtime authentication and authorization cases while retaining unauthenticated, wrong-role, and allowed-role coverage for every applicable operation.
- [x] Keep property, workflow, Postman, and performance coverage and hold the collected total between 60 and 70 tests.

## Step 3: Execute Local Verification

- [x] Reapply migrations and deterministic seed data to the local Oracle ATP-mode database.
- [x] Run the complete broad test suite and capture JUnit evidence.
- [x] Run static validation and application-controlled security checks.
- [x] Confirm the schema remains exactly 18 tables, 189 columns, and 17 foreign keys.

## Step 4: Align Documentation and Publish

- [x] Update README, Build/Test instructions, reports, limitations, manual steps, AI-DLC state, and audit for the local-only 60-70-test workflow.
- [x] Mark the prior cloud-target expansion plan as superseded where applicable without rewriting its historical completion record.
- [x] Validate Markdown and repository references, commit the amendment in logical checkpoints, and push `construction-phase` without changing `main`.

## Extension Compliance

- Security Baseline: Applicable and enforced. Local TLS, OAuth2, least privilege, ignored secrets, scans, and the documented Oracle image finding remain in scope.
- Resiliency Baseline: Applicable and enforced. Persistent local storage, idempotent migrations/seeds, bounded retry, and restart behavior remain unchanged.
- Property-Based Testing: Applicable in partial mode. Existing deterministic property tests remain part of the broad suite.
