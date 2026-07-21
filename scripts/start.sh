#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."
python3 scripts/generate_secrets.py
python3 scripts/preflight.py
python3 scripts/capture_image_metadata.py
docker compose up -d oracle-adb
.venv/bin/python -c 'from scripts.runtime import wait_for_container_healthy; wait_for_container_healthy()'
python3 scripts/trust.py
docker compose up -d erp-edge
python3 scripts/health.py
