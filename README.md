# ERP Supplier Onboarding

AI-DLC implementation workspace for an ERP supplier onboarding prototype.

## Scope

The project defines a supplier onboarding solution using Oracle Visual Builder, ORDS, ATP, OIC, and Fusion or a realistic Fusion mock. The proposal package covers supplier request intake, duplicate detection, explainable risk scoring, AI-assisted reviewer explanations, manual review decisions, integration logging, and controlled retry.

## Current Phase

Construction through UOW-005 is implemented on the `construction-phase` branch. The local target is Oracle Autonomous AI Database Free 26ai in ATP mode with bundled ORDS, fronted by a loopback-only HTTPS Nginx gateway. The finalized 18-table, 189-column, 17-relationship schema remains the database contract.

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
ERP_RUNTIME_TESTS=1 ./scripts/test.sh -q
ERP_PERF_DURATION_SECONDS=300 \
  ERP_PERF_READ_SAMPLES=60 \
  ERP_PERF_WRITE_CYCLES=10 \
  .venv/bin/python scripts/performance.py
.venv/bin/python scripts/report.py
```

Install and run the pinned scanners using the commands in `aidlc-docs/construction/build-and-test/security-test-instructions.md`. Raw local evidence is written under ignored `.local/reports/`.

Stop without deleting data:

```bash
./scripts/stop.sh
```

`stop.sh` preserves the named database volume. Destructive local reset requires `./scripts/reset-local.sh --confirm-local-reset` and refuses non-local targets.

To trust the local edge certificate in macOS browsers, manually add `.local/trust/local-ca.crt` to the login keychain and mark it trusted. CLI tests use the generated CA file directly and do not disable TLS verification.

## Security Gate

Python dependency, source-secret, filesystem, and Nginx image scans are clean. The latest official Oracle ADB Free 26ai image available during construction contains vendor-fixed High/Critical package findings. The local prototype mitigates exposure with loopback-only ingress, verified TLS, OAuth2, a route allowlist, and disabled optional ORDS surfaces, but the image finding remains a release gate until Oracle publishes a patched image or the customer explicitly accepts the documented local-prototype exception. Do not use this stack as a production deployment baseline.

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
