# ERP Supplier Onboarding

AI-DLC implementation workspace for an ERP supplier onboarding prototype.

## Scope

The project defines a supplier onboarding solution using Oracle Visual Builder, ORDS, ATP, OIC, and Fusion or a realistic Fusion mock. The proposal package covers supplier request intake, duplicate detection, explainable risk scoring, AI-assisted reviewer explanations, manual review decisions, integration logging, and controlled retry.

## Current Phase

Construction through UOW-005 is implemented on the `construction-phase` branch. The local target is Oracle Autonomous AI Database Free 26ai in ATP mode with bundled ORDS, fronted by a loopback-only HTTPS Nginx gateway. Managed Oracle Always Free Autonomous AI Database in Transaction Processing mode is the supported shared/cloud target. The finalized 18-table, 189-column, 17-relationship schema remains the database contract.

## Safe Prerequisites

- Apple Silicon macOS with FileVault enabled.
- Docker Desktop with at least 4 CPUs and 8 GiB available to its Linux VM. Ten GiB is recommended when scans and tests run beside Oracle.
- Python 3.13 and OpenSSL.
- At least 25 GiB free disk space for the Oracle image and persistent database volume.

Do not put real supplier, bank, customer, Fusion, OIC, SSO, or AI credentials in this repository. Local secrets and certificates are generated under ignored `.local/` paths.

## Local Setup

Create the hash-verified Python environment once:

```bash
python3.13 -m venv .venv
.venv/bin/python -m pip install --require-hashes -r requirements.txt
```

Start the local ATP/ORDS runtime, apply all ordered assets, seed every table, and verify the contract:

```bash
./scripts/start.sh
python3 scripts/migrate.py
python3 scripts/seed.py
.venv/bin/python scripts/verify.py
```

The first Oracle startup downloads the ATP PDB and can take several minutes. Generated passwords, OAuth clients, certificates, and wallets remain under ignored `.local/` paths and are never printed by the setup scripts.

## Test and Evidence Commands

```bash
./scripts/qa.sh all
./scripts/qa.sh db
./scripts/qa.sh contract
./scripts/qa.sh auth
./scripts/qa.sh flows
ERP_RUNTIME_TESTS=1 ./scripts/test.sh -q
ERP_PERF_DURATION_SECONDS=300 \
  ERP_PERF_READ_SAMPLES=60 \
  ERP_PERF_WRITE_CYCLES=10 \
  .venv/bin/python scripts/performance.py
.venv/bin/python scripts/report.py
```

The full QA command currently runs 583 tests and writes JUnit evidence under ignored `.local/reports/`. See `aidlc-docs/construction/build-and-test/self-service-testing-instructions.md` for suite meanings, read-only Oracle queries, Postman setup, and authorization checks.

Generate the complete 42-operation Postman collection and ignored local credential environment:

```bash
./scripts/qa.sh generate
```

Use `postman/erp-supplier-onboarding.postman_collection.json` with `.local/postman/erp-local.postman_environment.json`. Keep TLS verification enabled and trust `.local/trust/local-ca.crt`.

Inspect Oracle as the read-only verifier:

```bash
.venv/bin/python scripts/query.py --catalog
.venv/bin/python scripts/query.py --file 01_schema_inventory.sql
```

Install and run the pinned scanners using the commands in `aidlc-docs/construction/build-and-test/security-test-instructions.md`. Raw local evidence is written under ignored `.local/reports/`.

Stop without deleting data:

```bash
./scripts/stop.sh
```

`stop.sh` preserves the named database volume. Destructive local reset requires `./scripts/reset-local.sh --confirm-local-reset` and refuses non-local targets.

To trust the local edge certificate in macOS browsers, manually add `.local/trust/local-ca.crt` to the login keychain and mark it trusted. CLI tests use the generated CA file directly and do not disable TLS verification.

## Managed Always Free ATP

The repository includes a secret-free cloud profile and wallet/TLS connection preflight. Creating the OCI database and downloading its instance wallet require the user's OCI account:

```bash
cp config/atp-cloud.env.example .local/secrets/atp-cloud.env
.venv/bin/python scripts/cloud_atp_preflight.py
```

Follow `aidlc-docs/construction/build-and-test/oracle-always-free-atp-instructions.md`. No cloud deployment is claimed until the supplied wallet, credentials, network policy, and ORDS endpoint have been tested.

## Security Gate

Python dependency, source-secret, filesystem, and Nginx image scans are clean. The latest official Oracle ADB Free 26ai image available during construction contains vendor-fixed High/Critical package findings. The local prototype mitigates exposure with loopback-only ingress, verified TLS, OAuth2, exact per-operation role guards, a route allowlist, and disabled optional ORDS surfaces, but the image finding remains a local-container release gate. Use managed Always Free ATP for shared/cloud verification because Oracle manages service patching. Do not use the local stack as a production deployment baseline.

Key documents:

- `aidlc-docs/proposal/proposal.md`
- `aidlc-docs/inception/requirements/requirements.md`
- `aidlc-docs/inception/requirements/requirement-verification-questions.md`
- `aidlc-docs/inception/user-stories/personas.md`
- `aidlc-docs/inception/user-stories/stories.md`
- `aidlc-docs/inception/application-design/technical-design.md`
- `aidlc-docs/inception/application-design/database-schema-design.md` (authoritative ATP schema design)
- `aidlc-docs/inception/application-design/db-schema.dbml` (machine-readable physical equivalent)
- `aidlc-docs/inception/application-design/wireframe-readiness.md`
- `aidlc-docs/inception/wireframes/wireframe-spec.md`
- `mockups/supplier-onboarding-wireframes.html`

To open the static mockup locally:

```bash
open mockups/supplier-onboarding-wireframes.html
```

## Notes

Customer source PDFs are intentionally excluded from version control. The repository contains the generated working artifacts and AI-DLC workflow files.
