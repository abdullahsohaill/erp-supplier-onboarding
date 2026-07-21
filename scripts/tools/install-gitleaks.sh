#!/usr/bin/env sh
set -eu

VERSION="8.30.1"
ARCHIVE="gitleaks_${VERSION}_darwin_arm64.tar.gz"
URL="https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/${ARCHIVE}"
EXPECTED_SHA256="b40ab0ae55c505963e365f271a8d3846efbc170aa17f2607f13df610a9aeb6a5"
DEST="${1:-.local/tools/gitleaks}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

mkdir -p "$DEST"
curl --fail --location --silent --show-error "$URL" --output "$TMP/$ARCHIVE"
printf '%s  %s\n' "$EXPECTED_SHA256" "$TMP/$ARCHIVE" | shasum -a 256 -c -
tar -xzf "$TMP/$ARCHIVE" -C "$DEST" gitleaks LICENSE README.md
chmod 0755 "$DEST/gitleaks"
"$DEST/gitleaks" version
