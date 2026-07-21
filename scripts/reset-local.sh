#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."
EXPECTED='--confirm-destroy-local-erpatp'
if [ "${1:-}" != "$EXPECTED" ]; then
  printf '%s\n' "Refusing reset. Pass $EXPECTED for the local ERPATP target." >&2
  exit 2
fi
if [ "${ERP_ENVIRONMENT:-local-dev}" != 'local-dev' ] && [ "${ERP_ENVIRONMENT:-local-dev}" != 'local-test' ]; then
  printf '%s\n' 'Refusing reset outside local-dev/local-test.' >&2
  exit 2
fi
if [ "${DATABASE_NAME:-ERPATP}" != 'ERPATP' ]; then
  printf '%s\n' 'Refusing reset for a database other than ERPATP.' >&2
  exit 2
fi
case "${DB_HOST:-127.0.0.1}" in
  127.0.0.1|localhost) ;;
  *) printf '%s\n' 'Refusing reset for a non-loopback target.' >&2; exit 2 ;;
esac
docker compose down --volumes
printf '%s\n' 'Local ERPATP containers and named volume removed.'
