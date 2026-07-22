#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker Engine with the Compose plugin is required." >&2
  exit 1
fi

if [[ ! -f .env ]]; then
  ./scripts/generate-local-env.sh
fi

docker compose up -d adb
docker compose ps

echo "ADB Free is starting. First startup can take 10-20 minutes."
echo "After it is healthy, run: ./scripts/copy-wallet.sh"
echo "Run: uv run python scripts/run_migrations.py --wait"
