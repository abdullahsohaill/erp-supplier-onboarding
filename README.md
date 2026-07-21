# ERP Supplier Onboarding

AI-DLC implementation workspace for an ERP supplier onboarding prototype.

## Scope

The project defines a supplier onboarding solution using Oracle Visual Builder, ORDS, ATP, OIC, and Fusion or a realistic Fusion mock. The proposal package covers supplier request intake, duplicate detection, explainable risk scoring, AI-assisted reviewer explanations, manual review decisions, integration logging, and controlled retry.

## Current Phase

Construction is in progress on the `construction-phase` branch. The local target is Oracle Autonomous AI Database Free 26ai in ATP mode with bundled ORDS, fronted by a loopback-only HTTPS Nginx gateway. The finalized 18-table, 189-column, 17-relationship schema remains the database contract.

## Safe Prerequisites

- Apple Silicon macOS with FileVault enabled.
- Docker Desktop with at least 4 CPUs and 8 GiB available to its Linux VM.
- Python 3.13 and OpenSSL.
- At least 25 GiB free disk space for the Oracle image and persistent database volume.

Do not put real supplier, bank, customer, Fusion, OIC, SSO, or AI credentials in this repository. Local secrets and certificates are generated under ignored `.local/` paths.

## Construction Commands

The lifecycle commands are added and validated during UOW-001 construction. The intended command surface is:

```bash
./scripts/start.sh
python3 scripts/migrate.py
python3 scripts/seed.py
python3 scripts/verify.py
./scripts/test.sh
./scripts/stop.sh
```

`stop.sh` preserves the named database volume. Destructive local reset requires an explicit confirmation argument and refuses non-local targets.

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
