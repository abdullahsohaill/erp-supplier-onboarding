#!/usr/bin/env bash
set -euo pipefail

project_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
wallet_root="$project_root/wallet"
wallet_dir="$wallet_root/tls_wallet"
cert_dir="$project_root/certs"
ords_cert="$cert_dir/ords-self-signed.crt"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required to copy the generated ADB wallet." >&2
  exit 1
fi

mkdir -p "$wallet_root"
if [[ -e "$wallet_dir" ]]; then
  echo "$wallet_dir already exists; refusing to overwrite it." >&2
  exit 1
fi

docker cp erp-adb-free:/u01/app/oracle/wallets/tls_wallet "$wallet_dir"
chmod -R go-rwx "$wallet_dir"
echo "Copied the local TLS wallet to $wallet_dir."

mkdir -p "$cert_dir"
if [[ -e "$ords_cert" ]]; then
  echo "$ords_cert already exists; refusing to overwrite it." >&2
  exit 1
fi
docker cp erp-adb-free:/u01/ords/self-signed.crt "$ords_cert"
chmod go-rwx "$ords_cert"
echo "Copied the local ORDS HTTPS certificate to $ords_cert."
