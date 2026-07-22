#!/usr/bin/env sh
set -eu

cd "$(dirname "$0")/.."

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is required to locate the local OpenJDK and Oracle SQLcl installations."
    exit 1
fi

OPENJDK_PREFIX="$(brew --prefix openjdk)"
SQLCL_CASKROOM="$(brew --caskroom sqlcl)"
SQLCL_BIN=""
for candidate in "$SQLCL_CASKROOM"/*/sqlcl/bin/sql; do
    if [ -x "$candidate" ]; then
        SQLCL_BIN="$candidate"
    fi
done

if [ -z "$SQLCL_BIN" ]; then
    echo "Oracle SQLcl is not installed. Run: brew install --cask sqlcl"
    exit 1
fi

export JAVA_HOME="$OPENJDK_PREFIX/libexec/openjdk.jdk/Contents/Home"
export TNS_ADMIN="$PWD/.local/trust/tls_wallet"

if [ "$#" -eq 0 ]; then
    set -- "ERP_VERIFY@erpatp_tp"
fi

exec "$SQLCL_BIN" -L "$@"
