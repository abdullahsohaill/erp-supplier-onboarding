# Local Oracle ATP and ORDS Build Instructions

## Prerequisites

- Linux AMD64 or ARM64 host.
- Docker Engine with the Compose plugin.
- At least 4 CPUs and 8 GiB memory available to the database container; the checked-in Compose definition assigns 4 CPUs and 10 GiB.
- `/dev/fuse` available to the container and permission to add `SYS_ADMIN`, as required by the official ADB Free image.
- `uv`; it provisions the locked Python 3.13 interpreter automatically.

## Build and Initialize

From the repository root:

```bash
./scripts/bootstrap-local.sh
docker compose ps
docker compose logs -f adb
```

The first ADB Free startup commonly takes 10-20 minutes. Wait until the container health check passes, then copy the generated TLS wallet:

```bash
./scripts/copy-wallet.sh
```

Apply the checksummed manifest in fail-fast sequence:

```bash
uv sync --locked
uv run python scripts/run_migrations.py --wait
```

The runner:

1. validates every file against `database/migrations/manifest.json`;
2. creates and REST-enables `ERP_APP` using the ADMIN connection;
3. creates the exact 18-table schema and its constraints/indexes;
4. installs all PL/SQL service packages;
5. creates ORDS roles, 42 handlers, and local OAuth clients; and
6. clears/reloads synthetic data in all 18 tables.

Execution output is written to the ignored `reports/migration-execution.json` file. No migration-history table is added to the application schema.

## OAuth Client Secrets

ORDS creates four local clients: `local-requester`, `local-reviewer`, `local-admin`, and `local-system`. Retrieve their generated IDs/secrets through the ADB/ORDS administration interface and replace the placeholder client values in the ignored `.env` file. Do not copy secrets into documentation or tracked files.

## Verification

```bash
uv run python scripts/verify_schema.py
uv run python scripts/wait_for_ords.py
uv run pytest -q
```

Successful schema verification requires exactly 18 application tables, 189 columns, 17 foreign keys, no invalid objects, and at least one seeded row in every table.

## Reset and Rebuild

The seed phase is intentionally repeatable and begins with `database/seed/000_clear_seed.sql`. To reload only local synthetic data:

```bash
uv run python scripts/run_migrations.py --phase seed
```

For a clean database rebuild, remove only the named project volume and recreate it:

```bash
docker compose down
docker volume rm erp-supplier-onboarding-adb-data
./scripts/bootstrap-local.sh
./scripts/copy-wallet.sh
uv run python scripts/run_migrations.py --wait
```

The volume removal irreversibly deletes the local prototype database. Never run that command against a volume containing non-synthetic data.
