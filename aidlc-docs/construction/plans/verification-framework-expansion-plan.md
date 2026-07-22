# Verification Framework Expansion Plan

## Status and Scope

Approved by the user's direct request on 2026-07-22. This Build and Test amendment expands self-service verification without changing the finalized 18-table, 189-column, 17-relationship schema.

## Step 1: Resolve the Oracle Free ATP Runtime Decision

- [x] Recheck Oracle's current official ADB Free container release and managed Always Free Autonomous AI Database options.
- [x] Select managed Always Free Autonomous AI Database in Transaction Processing mode as the supported clean target for shared/cloud verification.
- [x] Retain the local ATP-mode ADB Free container as an isolated development fallback with its vendor-image finding documented.

## Step 2: Expand the Executable Contract Matrix

- [x] Add a single source of truth for all 42 operations, role access, sample paths, and safe request payloads.
- [x] Parameterize static OpenAPI operation, role, response, and request-shape checks per operation.
- [x] Parameterize runtime unauthenticated, wrong-role, and allowed-role reachability checks per operation.

## Step 3: Expand Database Verification

- [x] Grant the existing local-only ERP_VERIFY principal read-only access to finalized application tables and views.
- [x] Add per-table columns, primary keys, foreign keys, constraints, indexes, JSON validity, seed, and package/view verification.
- [x] Add a read-only query utility and curated inspection query catalog.

## Step 4: Deliver Self-Service API and Flow Tooling

- [x] Generate a secret-free Postman Collection 2.1 containing all 42 operations and guided role/workflow folders.
- [x] Generate an ignored local Postman environment from existing generated OAuth clients.
- [x] Add a command-line QA runner for database, contract, authentication/authorization, stories, and full regression modes.

## Step 5: Prepare Managed Always Free ATP

- [x] Add a secret-free cloud profile template and connection preflight using an ignored instance wallet.
- [x] Document the manual OCI database, wallet, network, ORDS, and credential steps.
- [x] Keep cloud credentials/wallets out of Git and do not claim cloud execution before they are supplied.

## Step 6: Execute and Correct

- [x] Apply the grant asset, rerun migrations/seeds, and verify 18/189/17 remains unchanged.
- [x] Run all expanded static/runtime/database/API/auth/story/Postman-generation checks.
- [x] Correct failures and capture exact totals by category.

## Step 7: Report and Publish

- [x] Update README, Build/Test instructions, security decision, test report, consolidated report, state, and audit.
- [ ] Validate Markdown/JSON/OpenAPI, scan for secrets/vulnerabilities, commit, and push to construction-phase.
