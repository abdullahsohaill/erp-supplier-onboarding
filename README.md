# ERP Supplier Onboarding

Executable local Oracle ATP/ORDS supplier-onboarding prototype plus its requirements and design baseline.

## Scope

The project defines a supplier onboarding solution using Oracle Visual Builder, ORDS, ATP, OIC, and Fusion or a realistic Fusion mock. The proposal package covers supplier request intake, duplicate detection, explainable risk scoring, AI-assisted reviewer explanations, manual review decisions, integration logging, and controlled retry.

## Implemented Construction Baseline

The repository now contains:

- A pinned Oracle Autonomous AI Database Free 26ai ATP runtime definition with bundled ORDS.
- Executable migrations for the authoritative 18 tables, 189 columns, and 17 foreign keys.
- PL/SQL packages for request workflow, validation, duplicate/risk scoring, deterministic AI summaries, review decisions, dashboards, Admin Settings, mock Fusion submission, and retry.
- All 42 approved ORDS handlers, OAuth role definitions, and an OpenAPI 3.1 contract.
- Synthetic governed reference data and representative rows in every application table.
- Unit, property, contract, security, database, ORDS, end-to-end, and performance tests.

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

Implementation entry points:

- `docker-compose.yml`
- `database/migrations/manifest.json`
- `ords/openapi/openapi.yaml`
- `scripts/bootstrap-local.sh`
- `scripts/run_migrations.py`
- `scripts/verify_schema.py`
- `tests/`

## Local Build

Prerequisites are Docker Engine with the Compose plugin, at least 4 CPUs and 8 GiB available to the database container, FUSE device access, and `uv`.

```bash
./scripts/bootstrap-local.sh
./scripts/copy-wallet.sh
uv run python scripts/run_migrations.py --wait
uv run python scripts/verify_schema.py
uv run pytest -q
```

The first database startup can take 10-20 minutes. Secrets are generated into ignored `.env` and wallet paths. HTTPS tests use the generated local CA certificate and never disable certificate verification.

To open the static mockup locally:

```bash
open mockups/supplier-onboarding-wireframes.html
```

## Static Verification Without Oracle

```bash
uv sync --locked
uv run pytest -q tests/unit tests/property tests/contract tests/security
```

This verifies exact schema parity, all 42 endpoint contracts, seed coverage, request/risk/duplicate/retry properties, role-safe projections, secret handling, and migration checksums without requiring the container.

## Notes

Customer source PDFs and local secrets/runtime reports are intentionally excluded from version control.
