#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."
python3 scripts/generate_secrets.py
python3 scripts/preflight.py
python3 scripts/capture_image_metadata.py
docker volume inspect erp_oracle_adb_data >/dev/null 2>&1 || \
    docker volume create erp_oracle_adb_data >/dev/null
docker run --rm --user 0:0 --entrypoint /bin/sh \
    -v erp_oracle_adb_data:/u01/data \
    ghcr.io/oracle/adb-free:26.2.4.2-26ai \
    -c 'chown 1001:1001 /u01/data && chmod 700 /u01/data'
./scripts/cache_oracle_pdb.sh
docker compose up -d oracle-adb
.venv/bin/python -c 'from scripts.runtime import wait_for_container_healthy; wait_for_container_healthy()'
python3 scripts/harden_ords.py
python3 scripts/trust.py
docker compose up -d erp-edge
python3 scripts/health.py
