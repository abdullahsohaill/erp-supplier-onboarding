#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."
docker compose down
printf '%s\n' 'Local containers stopped; persistent Oracle volume preserved.'
