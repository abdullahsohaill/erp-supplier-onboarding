# Local Oracle Demonstration Completion Plan

## Status and Scope

Approved by the user's direct construction-completion request on 2026-07-22. This amendment completes a locally demonstrable Oracle ADB Free environment for database inspection, ORDS/Postman execution, migration and seed review, use-case evidence, and team-lead reporting. It does not change the finalized 18-table, 189-column, 17-relationship application schema.

## Step 1: Complete Local Tooling

- [x] Verify the pinned Oracle ADB Free ATP-mode database, ORDS, generated wallet, and local certificates.
- [x] Install Postman Desktop for manual API execution.
- [x] Install a Java runtime and Oracle SQLcl for native Oracle wallet connections.
- [x] Validate that generated credentials and wallet files remain ignored and owner-restricted.

## Step 2: Provide Localhost Database Inspection

- [x] Enable Oracle Database Actions and its required ORDS services for the dedicated local demonstration profile.
- [x] Expose Database Actions only through a TLS-protected loopback listener separate from the application API.
- [x] REST-enable the read-only `ERP_VERIFY` schema with a non-schema alias and retain SELECT-only database grants.
- [x] Add automated checks for loopback exposure, authenticated Database Actions availability, and read-only enforcement.

## Step 3: Rebuild and Exercise the System

- [x] Reapply all ordered migrations and PL/SQL/ORDS assets without changing the 18/189/17 schema contract.
- [x] Reseed deterministic representative data in every table and regenerate Postman assets.
- [x] Run all broad tests covering the 14 user stories, 42 operations, authorization, database contracts, properties, and performance smoke.
- [x] Execute read-only SQLcl and curated query demonstrations through the generated wallet.
- [x] Validate representative Requester, Reviewer, Support/Admin, duplicate, risk, correction, Fusion mock, and retry flows.

## Step 4: Deliver Presentation Evidence

- [x] Create a detailed team-lead construction report covering architecture, runtime, database objects/data, APIs, use-case tests, security, and limitations.
- [x] Create an exact migration summary with ordered purpose, execution result, and schema impact.
- [x] Create a concise local demonstration runbook for Database Actions, SQLcl, Postman, queries, credentials, startup, and shutdown.
- [x] Update README, Build/Test documentation, AI-DLC state, and audit with verified results.
- [ ] Validate content and references, commit in logical checkpoints, and push `construction-phase` without changing `main`.

## Extension Compliance

- Security Baseline: Enabled. Database Actions must remain loopback-only, TLS-protected, authenticated, and use the read-only verifier for demonstrations. Generated credentials are never committed or written into reports.
- Resiliency Baseline: Enabled. Startup, migrations, seeds, and demonstrations must be repeatable against the persistent named volume.
- Property-Based Testing: Partial mode remains enabled; existing deterministic property tests stay in the executable suite.
