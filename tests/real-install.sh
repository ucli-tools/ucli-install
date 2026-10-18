#!/bin/bash
# One REAL install: public/install.sh against real GitHub, into the current HOME (a CI runner
# or a scratch HOME). Asserts that `ucli --version` prints the registry's ucli pin.
#   INSTALL_SHELL=sh|bash  which shell runs the installer (default sh)
# shellcheck disable=SC2015  # `test && ok || bad`: ok never fails, so bad runs only when the test fails
set -uo pipefail
here="$(cd "$(dirname "$0")" && pwd)"
installer="$(cd "$here/.." && pwd)/public/install.sh"
shell_bin="$(command -v "${INSTALL_SHELL:-sh}")"
index_url="${UCLI_REGISTRY_INDEX_URL:-https://raw.githubusercontent.com/ucli-tools/ucli-registry/main/registry/index.tsv}"
fails=0
ok()  { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); }

pin="$(curl -fsSL "$index_url" | awk -F '\t' '$1 == "ucli" { print $3; exit }')"
[[ "$pin" =~ ^[0-9a-f]{40}$ ]] || { bad "cannot read a ucli pin from $index_url"; exit 1; }
echo "registry pin: $pin"

shim="$(mktemp -d "${TMPDIR:-/tmp}/sudo-shim.XXXXXX")"
trap 'rm -rf "${shim:?}"' EXIT
printf '#!/bin/sh\necho "sudo $*" >> "%s/calls"\nexit 1\n' "$shim" > "$shim/sudo"; chmod +x "$shim/sudo"
export UCLI_LEGACY_BIN="${UCLI_LEGACY_BIN:-$HOME/.no-system-ucli}"
export PATH="$shim:$PATH"

"$shell_bin" "$installer" || bad "installer failed"
ver="$("$HOME/.local/bin/ucli" --version 2>&1)"; echo "$ver"
[[ "$ver" == "ucli $pin" ]] && ok "ucli --version prints the pinned commit" || bad "ucli --version is '$ver', expected 'ucli $pin'"
[[ ! -e "$shim/calls" ]] && ok "sudo was never called" || bad "sudo was called: $(cat "$shim/calls")"

"$shell_bin" "$installer" || bad "second run failed"
[[ "$("$HOME/.local/bin/ucli" --version 2>&1)" == "ucli $pin" ]] && ok "re-run is idempotent" || bad "re-run changed the version"

[[ $fails -eq 0 ]] && echo "all passed" || echo "$fails FAILED"
exit $((fails > 0))
