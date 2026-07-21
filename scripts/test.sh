#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."
.venv/bin/ruff check scripts tests
.venv/bin/python -m compileall -q scripts tests
.venv/bin/pytest "$@"
