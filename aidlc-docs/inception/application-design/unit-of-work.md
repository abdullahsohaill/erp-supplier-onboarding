# Units of Work

## UOW-001: Core Request Intake

Build supplier request capture, draft/save/submit behavior, requester status tracking, core ATP tables, and ORDS request APIs.

## UOW-002: Validation, Duplicate Detection, and Risk Scoring

Implement the governed validation-rule catalog, failed-result rule references, consolidated risk/duplicate scoring-rule configuration, duplicate matching, risk scoring, Reviewer factor selection as decision-time UI state, AI explanation support, explainable results, and related UI display.

## UOW-003: Review Workflow and Business Dashboards

Implement review decisions, status-history decision envelopes containing selected factor codes and targeted correction items, reviewer queue, requester dashboard, reviewer dashboard, status guidance, and filters.

## UOW-004: Fusion/OIC Integration and Support

Implement support/admin dashboard, submit-to-Fusion or mock integration, OIC-monitored supplier-reference sync, request-scoped integration-log/retry persistence, controlled retry, and Fusion response handling.

## UOW-005: Governance, Admin Settings, Demo, and Proposal Hardening

Create Admin Settings and reference-table support, sample scenarios, demo script, test cases, known limitations, and final customer-facing proposal package.

## Code Organization Strategy

This is currently a documentation/proposal project. If implementation begins, recommended top-level folders:

- `database/` for ATP schema, PL/SQL packages, seed data.
- `ords/` for ORDS module definitions and OpenAPI specs.
- `oic/` for integration design exports/specs and payload mappings.
- `visual-builder/` for UI export or implementation notes.
- `tests/` for API, scoring, matching, and integration test assets.
