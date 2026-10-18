#!/usr/bin/env bash
# Checks the ucli-kit copy in this repo.
#  1. Fails this script (the deploy workflow step is continue-on-error, so it never blocks a deploy): SHA256SUMS matches the files in this repo's own kit folder.
#  2. Warning only (non-canonical repos): VERSION and SHA256SUMS against the canonical kit in
#     ucli-website on main. A difference or a network failure prints a ::warning:: and exits 0.
# To change the kit: change it in ucli-website first, then copy it to the other repos.
set -euo pipefail

cd "$(dirname "$0")/.."
KIT=""
for d in public/ucli-kit docs/ucli-kit; do [ -d "$d" ] && KIT="$d" && break; done
[ -n "$KIT" ] || { echo "check-kit: no ucli-kit folder found" >&2; exit 1; }

if ! (cd "$KIT" && sha256sum --quiet -c SHA256SUMS); then
  echo "::error::ucli-kit does not match SHA256SUMS (a hand edit or a bad copy)"
  exit 1
fi
echo "ucli-kit: $(wc -l < "$KIT/SHA256SUMS") files match SHA256SUMS (version $(cat "$KIT/VERSION"))"

origin="$(git config --get remote.origin.url 2>/dev/null || true)"
case "$origin" in
  *ucli-website*) exit 0 ;;   # canonical copy: nothing upstream to compare with
esac

UP="https://raw.githubusercontent.com/ucli-tools/ucli-website/main/public/ucli-kit"
behind=""
for f in VERSION SHA256SUMS; do
  if ! remote="$(curl -fsSL --max-time 15 "$UP/$f" 2>/dev/null)"; then
    echo "::warning::could not compare ucli-kit with ucli-website (network); skipped"
    exit 0
  fi
  [ "$remote" = "$(cat "$KIT/$f")" ] || behind=1
done
[ -z "$behind" ] || echo "::warning::kit is behind ucli-website (VERSION or SHA256SUMS differ); copy it from ucli-website/public/ucli-kit"
exit 0
