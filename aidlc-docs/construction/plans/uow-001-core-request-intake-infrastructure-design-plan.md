# UOW-001 Core Request Intake Infrastructure Design Plan

## Status

Complete; awaiting explicit approval.

## Unit Context

- **Unit**: UOW-001 Core Request Intake
- **Approved functional design**: `aidlc-docs/construction/uow-001-core-request-intake/functional-design/`
- **Approved NFR requirements**: `aidlc-docs/construction/uow-001-core-request-intake/nfr-requirements/`
- **Approved NFR design**: `aidlc-docs/construction/uow-001-core-request-intake/nfr-design/`
- **Stories**: US-001, US-002, US-003
- **Dependencies**: None; UOW-001 is the foundation for later units.
- **Enabled extensions**: Security Baseline, Resiliency Baseline design guidance, Partial Property-Based Testing.

## Infrastructure Question Assessment

No new question file is required because the approved construction plan and NFR artifacts already resolve every mandatory category for the local prototype:

| Category | Approved Decision | Ambiguity Assessment |
|---|---|---|
| Deployment environment | Local non-production Docker Compose environment; future Oracle Cloud production is deferred. | Resolved. |
| Compute infrastructure | Official ARM64 Oracle Autonomous AI Database Free container with at least 4 CPUs and 8 GiB RAM. | Resolved. |
| Storage infrastructure | ATP-mode Oracle database with encrypted Oracle-managed storage behavior and a persistent named Docker volume; clean rebuild for local reset. | Resolved. |
| Messaging infrastructure | None for UOW-001; request intake and governed checks are synchronous and database-local. | N/A with explicit rationale. |
| Networking infrastructure | Loopback-bound database/ORDS ports, HTTPS ORDS boundary, generated local trust material, explicit CORS allowlist, no public load balancer. | Resolved. |
| Monitoring infrastructure | Container/ORDS/database health checks, structured redacted logs, external migration/test manifests, and local evidence reports. | Resolved. |
| Shared infrastructure | One local ATP/ORDS stack and application schema shared by UOW-001 through UOW-005; role and package boundaries provide logical isolation. | Resolved. |

Production ATP tenancy, region, network, identity, availability, backup/DR, monitoring retention, and scaling remain customer gates and are not guessed in this local design.

## Execution Checklist

- [x] Load approved Functional Design, NFR Requirements, NFR Design, unit dependencies, and construction baseline.
- [x] Evaluate all mandatory infrastructure question categories and document why no new answers are required.
- [x] Map all 21 logical components to concrete local infrastructure resources and ownership boundaries.
- [x] Define Docker Compose services, resource allocation, lifecycle, profiles, and dependency health gates.
- [x] Define ATP-mode Oracle schemas, least-privilege principals, object grants, ORDS metadata, and shared-unit boundaries without changing the 18-table contract.
- [x] Define persistent and ephemeral storage, encryption, local secret/trust material, retention, backup/reset, and non-local safety guards.
- [x] Define loopback networking, HTTPS, ports, CORS, OAuth2 roles/clients/privileges, rate limits, and access logging.
- [x] Define migration, schema verification, seed, test-runner, OpenAPI, scan, SBOM, and report infrastructure.
- [x] Define health, startup, restart, failure recovery, observability, and local capacity behavior.
- [x] Document future Oracle Cloud ATP/ORDS/OIC/SSO mapping and production decision gates without claiming a production design.
- [x] Map all 53 UOW-001 NFRs and applicable enabled-extension rules to infrastructure controls.
- [x] Validate Markdown, configuration examples, terminology, traceability, and schema boundary.
- [x] Update AI-DLC state, master plan, and audit with Infrastructure Design completion.

## Deliverables

- `aidlc-docs/construction/uow-001-core-request-intake/infrastructure-design/infrastructure-design.md`
- `aidlc-docs/construction/uow-001-core-request-intake/infrastructure-design/deployment-architecture.md`

Shared infrastructure is described within these UOW-001 artifacts because UOW-001 establishes the common local stack. A separate shared-infrastructure artifact is unnecessary at this stage.

## Completion Gate

UOW-001 Infrastructure Design must be explicitly approved before UOW-001 Code Generation planning begins. This stage creates design documentation only; it does not start containers, create schemas, apply migrations, seed data, or configure endpoints.
