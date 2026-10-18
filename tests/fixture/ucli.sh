#!/bin/bash
# A stand-in for ucli, with the same install contract as the real one at the registry pin:
# `install` goes to ${UCLI_PREFIX:-$HOME/.local}/bin, or updates ${UCLI_LEGACY_BIN} in place
# (with sudo only when that directory is not writable); `--version` prints "ucli <commit>".
UCLI_BUILD_ID="dev"

case "${1:-}" in
  --version)
    printf 'ucli %s\n' "$UCLI_BUILD_ID"
    ;;
  install)
    legacy="${UCLI_LEGACY_BIN:-/usr/local/bin/ucli}"
    sudo_cmd=""
    if [[ -e "$legacy" ]]; then
      dir="$(dirname "$legacy")"
      [[ -w "$dir" ]] || sudo_cmd="sudo"
    else
      dir="${UCLI_PREFIX:-$HOME/.local}/bin"
    fi
    $sudo_cmd mkdir -p "$dir"
    id="$(git -C "$(dirname "$0")" rev-parse HEAD)"
    tmp="$dir/.ucli.new.$$"
    sed "s/^UCLI_BUILD_ID=.*/UCLI_BUILD_ID=\"$id\"/" "$0" | $sudo_cmd tee "$tmp" > /dev/null
    $sudo_cmd chmod +x "$tmp"
    $sudo_cmd mv -f "$tmp" "$dir/ucli"
    echo "ucli installed to $dir."
    ;;
  *)
    echo "usage: ucli --version | install" >&2
    exit 2
    ;;
esac
