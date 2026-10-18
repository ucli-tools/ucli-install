#!/usr/bin/env bash
# Token check. Fails when a var(--u-...) used in src/ is not defined in the kit's tokens.css, or when
# markup uses a Tailwind colour class that v4 removed (ink3, accent, warn).
set -euo pipefail
cd "$(dirname "$0")/.."
TOK=public/ucli-kit/tokens.css
[ -f "$TOK" ] || { echo "check-tokens: $TOK not found" >&2; exit 1; }
bad=0
for v in $(grep -rhoE 'var\(--u-[a-z0-9-]+' src | sed 's/var(//' | sort -u); do
  if ! grep -qE "^[[:space:]]*${v}[[:space:]]*:" "$TOK"; then
    echo "::error::check-tokens: $v is used in src/ but not defined in $TOK"; bad=1
  fi
done
if grep -rnE '(^|[^a-z0-9-])(text|bg|border|ring|fill|stroke|from|to|via|divide|outline|decoration|placeholder)-(ink3|accent|warn)([^a-z0-9-]|$)' src; then
  echo "::error::check-tokens: a removed Tailwind colour class is used"; bad=1
fi
[ "$bad" -eq 0 ] && echo "check-tokens: every var(--u-...) in src/ is defined; no removed colour class"
exit "$bad"
