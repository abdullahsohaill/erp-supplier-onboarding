# Build Instructions

## Prerequisites

- Apple Silicon macOS with FileVault enabled.
- Docker Desktop with at least 4 CPUs and 8 GiB; 10 GiB is recommended.
- Python 3.13, OpenSSL, Git, Homebrew OpenJDK, Oracle SQLcl, Postman Desktop, and at least 25 GiB free disk.
- Branch `construction-phase`.

## Build and Provision

```bash
python3.13 -m venv .venv
.venv/bin/python -m pip install --require-hashes -r requirements.txt
./scripts/start.sh
python3 scripts/migrate.py
python3 scripts/seed.py
.venv/bin/python scripts/verify.py
```

Success means two healthy containers, exact 18/189/17 schema parity, zero invalid objects, 47 ordered assets applied or verified, and every application table seeded.

For the complete self-service build and regression workflow, run `./scripts/qa.sh all`.

## Lifecycle

```bash
python3 scripts/health.py
./scripts/logs.sh
./scripts/stop.sh
```

`stop.sh` preserves `erp_oracle_adb_data`. Use `./scripts/reset-local.sh --confirm-destroy-local-erpatp` only for an intentional local rebuild.

## Troubleshooting

- If preflight rejects memory, allocate at least 8 GiB to Docker Desktop.
- First boot downloads the ATP PDB and can take several minutes.
- If ports 1521, 1522, 8443, or 8444 are occupied, stop the conflicting local service.
- Never bypass certificate validation; rerun `scripts/trust.py` after Oracle certificate replacement.
- Do not commit anything under `.local/`.
