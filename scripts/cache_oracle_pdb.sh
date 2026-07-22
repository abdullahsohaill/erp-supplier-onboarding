#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

image="ghcr.io/oracle/adb-free:26.2.4.2-26ai"
volume="erp_oracle_adb_data"
cache_dir=".local/cache"
cache_file="$cache_dir/ERPATP.pdb"
url="https://objectstorage.us-phoenix-1.oraclecloud.com/n/dwcsdev/b/adb-free/o/ADBS-26.2.4.2-26ai/aarch64/MY_ATP.pdb"
expected_size="695140767"
expected_md5="EYH+bZniNhgme6k3/I7Eiw=="

docker volume inspect "$volume" >/dev/null 2>&1 || docker volume create "$volume" >/dev/null

if docker run --rm --entrypoint /bin/sh -v "$volume:/u01/data" "$image" \
    -c 'test -f /u01/data/ERPATP.pdb'; then
    exit 0
fi

mkdir -p "$cache_dir"
chmod 700 "$cache_dir"
curl --fail --location --continue-at - --retry 20 --retry-all-errors --retry-delay 2 \
    --output "$cache_file" "$url"

actual_size="$(wc -c < "$cache_file" | tr -d ' ')"
actual_md5="$(openssl dgst -md5 -binary "$cache_file" | openssl base64 -A)"
if [ "$actual_size" != "$expected_size" ] || [ "$actual_md5" != "$expected_md5" ]; then
    printf '%s\n' 'Oracle PDB cache integrity validation failed' >&2
    exit 1
fi

chmod 600 "$cache_file"
docker run --rm --user 0:0 --entrypoint /bin/sh \
    -v "$PWD/$cache_dir:/cache:ro" \
    -v "$volume:/u01/data" \
    "$image" \
    -c 'cp /cache/ERPATP.pdb /u01/data/ERPATP.pdb && chown 1001:1001 /u01/data/ERPATP.pdb && chmod 600 /u01/data/ERPATP.pdb'

printf '%s\n' 'Oracle ATP PDB cache is complete and checksum verified'
