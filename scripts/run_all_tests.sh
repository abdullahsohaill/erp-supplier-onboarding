#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
cd "$project_root"

uv sync --locked
uv run pytest -q --junitxml=reports/pytest-all.xml
uv export --format cyclonedx1.5 --locked --no-emit-project -o reports/sbom.cdx.json
uvx pip-audit -r requirements.txt --format json --output reports/vulnerability-scan.json

echo "Test results, SBOM, and vulnerability scan are in reports/."
