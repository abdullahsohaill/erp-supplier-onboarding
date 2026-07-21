#!/usr/bin/env sh
set -eu

VERSION="0.72.0"
ARCHIVE="trivy_${VERSION}_macOS-ARM64.tar.gz"
URL="https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/${ARCHIVE}"
CHECKSUMS_URL="https://github.com/aquasecurity/trivy/releases/download/v${VERSION}/trivy_${VERSION}_checksums.txt"
DEST="${1:-.local/tools/trivy}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$DEST"
curl --fail --location --silent --show-error "$URL" --output "$TMP/$ARCHIVE"
curl --fail --location --silent --show-error "$CHECKSUMS_URL" --output "$TMP/checksums.txt"
EXPECTED_SHA256="$(awk -v name="$ARCHIVE" '$2 == name {print $1}' "$TMP/checksums.txt")"
test -n "$EXPECTED_SHA256"
printf '%s  %s\n' "$EXPECTED_SHA256" "$TMP/$ARCHIVE" | shasum -a 256 -c -
tar -xzf "$TMP/$ARCHIVE" -C "$DEST" trivy LICENSE README.md
chmod 0755 "$DEST/trivy"
"$DEST/trivy" --version
