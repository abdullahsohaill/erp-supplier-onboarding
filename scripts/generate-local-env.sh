#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
env_file="$project_root/.env"

if [[ -e "$env_file" ]]; then
  echo ".env already exists; refusing to overwrite it." >&2
  exit 1
fi

if ! command -v openssl >/dev/null 2>&1; then
  echo "openssl is required to generate local secrets." >&2
  exit 1
fi

admin_password="Aa1$(openssl rand -hex 10)"
wallet_password="Wa1$(openssl rand -hex 10)"
app_password="Ap1$(openssl rand -hex 10)"

umask 077
sed \
  -e "s/ReplaceWithGeneratedAdmin1/$admin_password/" \
  -e "s/ReplaceWithGeneratedWallet1/$wallet_password/" \
  -e "s/ReplaceWithGeneratedApp1/$app_password/" \
  "$project_root/.env.example" > "$env_file"

echo "Created $env_file with mode 600. ORDS OAuth secrets are populated after client creation."
