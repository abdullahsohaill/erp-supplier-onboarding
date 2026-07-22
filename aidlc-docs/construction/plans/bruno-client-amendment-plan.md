# Account-Free Bruno Client Amendment Plan

## Scope

Add an offline-first local API client that requires no account or sign-in. Preserve the finalized database schema, 42-operation ORDS contract, OAuth2 controls, generated-secret handling, and existing Postman assets.

## Execution

- [x] Install Bruno Desktop and a pinned Bruno CLI on the local Mac.
- [x] Generate a native Bruno collection from the committed OpenAPI contract.
- [x] Generate an ignored owner-only local workspace from existing OAuth2 credentials.
- [x] Configure verified local TLS and role-specific authentication without committed secrets.
- [x] Execute collection smoke tests against the running ORDS stack.
- [x] Add opening/usage instructions and align README and Build/Test documentation.
- [x] Run content, source, security, and Git checks.
- [x] Commit and push the amendment to `construction-phase` without changing `main`.

## Extension Compliance

- Security Baseline: generated client credentials remain under ignored owner-only `.local/` paths; TLS verification stays enabled.
- Resiliency Baseline: collection and environment generation must be repeatable.
- Property-Based Testing: N/A because this amendment adds no new transformation or business invariant.
