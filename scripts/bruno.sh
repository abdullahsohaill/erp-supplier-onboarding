#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

VERSION="3.5.2"
TOOLS=".local/tools/bruno-cli"
CLI="$TOOLS/node_modules/.bin/bru"
COLLECTION=".local/bruno/erp-supplier-onboarding"
MANIFEST="config/bruno-cli-package.json"

install_cli() {
    if [ ! -x "$CLI" ] || ! cmp -s "$MANIFEST" "$TOOLS/package.json"; then
        mkdir -p "$TOOLS"
        cp "$MANIFEST" "$TOOLS/package.json"
        npm install --prefix "$TOOLS" --no-audit --no-fund
    fi
    installed_version=$($CLI --version | tail -1)
    [ "$installed_version" = "$VERSION" ] || {
        echo "Expected Bruno CLI $VERSION, found $installed_version" >&2
        exit 1
    }
}

generate() {
    install_cli
    .venv/bin/python scripts/generate_postman.py
    .venv/bin/python scripts/generate_postman_environment.py
    node scripts/generate_bruno.js
}

case "${1:-open}" in
    generate)
        generate
        ;;
    test)
        generate
        (
            cd "$COLLECTION"
            "../../tools/bruno-cli/node_modules/.bin/bru" run \
                "00 Authentication" \
                "01 Requester Operations/GET listRequests.bru" \
                "02 Reviewer Operations/GET getReviewerSummary.bru" \
                "03 SupportAdmin Operations/GET getSupportSummary.bru" \
                -r \
                --cacert ../../trust/local-ca.crt \
                --ignore-truststore \
                --bail \
                --reporter-skip-all-headers \
                --reporter-junit ../../reports/bruno-smoke.xml
        )
        ;;
    open)
        generate
        if [ ! -d /Applications/Bruno.app ]; then
            echo "Bruno Desktop is missing. Install it with: brew install --cask bruno" >&2
            exit 1
        fi
        open -a Bruno "$COLLECTION"
        ;;
    *)
        echo "Usage: ./scripts/bruno.sh [generate|test|open]" >&2
        exit 2
        ;;
esac
