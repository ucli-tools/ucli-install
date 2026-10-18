#!/bin/sh
# ucli installer.
#
#   curl -fsSL https://install.ucli.tools/install.sh | bash
#
# Reads the commit of ucli that the registry pins, fetches exactly that commit into a
# temporary directory, checks it, installs it, and deletes the temporary directory.
# New installs go to ${UCLI_PREFIX:-$HOME/.local}/bin and never use sudo. An existing
# /usr/local/bin/ucli is updated in place.
#
# Everything is inside main(), which is called on the very last line: a download cut
# short runs nothing.
#
# Environment (all optional; the registry and repo URLs exist for the tests):
#   UCLI_PREFIX            where a new install goes (default ~/.local; the file lands in <prefix>/bin)
#   UCLI_LEGACY_BIN        the old system copy (default /usr/local/bin/ucli)
#   UCLI_REGISTRY_INDEX_URL  the registry index (default: ucli-registry main registry/index.tsv)
#   UCLI_REPO_URL          where ucli is fetched from (default https://github.com/ucli-tools/ucli)

set -eu
if [ -n "${BASH_VERSION:-}" ]; then
    # shellcheck disable=SC3040  # only reached by bash, which has it
    set -o pipefail
fi

UCLI_INSTALLER_WORK=""

cleanup() {
    if [ -n "$UCLI_INSTALLER_WORK" ] && [ -d "$UCLI_INSTALLER_WORK" ]; then
        rm -rf "$UCLI_INSTALLER_WORK"
    fi
}

say()  { printf '%s\n' "$*"; }
step() { printf '%s %s\n' "->" "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

need() {
    command -v "$1" >/dev/null 2>&1 || die "$1 is not installed. $2"
}

# True when $1 is exactly 40 lowercase hex characters.
is_commit() {
    case "$1" in
        *[!0-9a-f]*) return 1 ;;
    esac
    [ "${#1}" -eq 40 ]
}

# Fetch commit-ish $2 of the repository $1 into the new empty directory $3 and check it out
# (detached). Tries a one-commit fetch first, then a full fetch for old gits or servers.
fetch_into() {
    f_url=$1
    f_ref=$2
    f_dir=$3
    git init -q "$f_dir" || die "git init failed in $f_dir"
    git -C "$f_dir" remote add origin "$f_url" || die "git remote add failed"
    if git -C "$f_dir" fetch -q --depth 1 origin "$f_ref" >/dev/null 2>&1 \
        && git -C "$f_dir" checkout -q --detach FETCH_HEAD >/dev/null 2>&1; then
        return 0
    fi
    step "A one-commit fetch was refused; fetching the full history instead."
    git -C "$f_dir" fetch -q origin >/dev/null 2>&1 \
        || die "cannot fetch $f_url. Check your network and try again."
    if is_commit "$f_ref"; then
        git -C "$f_dir" checkout -q --detach "$f_ref" >/dev/null 2>&1 \
            || die "commit $f_ref is not in $f_url."
    else
        git -C "$f_dir" checkout -q --detach "origin/$f_ref" >/dev/null 2>&1 \
            || die "branch $f_ref is not in $f_url."
    fi
}

main() {
    case "$(uname -s 2>/dev/null || echo unknown)" in
        MINGW* | MSYS* | CYGWIN* | Windows_NT)
            die "Windows is not supported directly. Install WSL (https://learn.microsoft.com/windows/wsl/install), open a WSL terminal, and run this installer there."
            ;;
    esac

    need curl "Install curl first (Ubuntu/Debian: sudo apt-get install curl; macOS has it)."
    need git "Install git first (Ubuntu/Debian: sudo apt-get install git; macOS: xcode-select --install; Fedora: sudo dnf install git)."
    need make "Install make first (Ubuntu/Debian: sudo apt-get install build-essential; macOS: xcode-select --install; Fedora: sudo dnf install make)."
    need bash "ucli is a bash script; install bash first."

    repo_url=${UCLI_REPO_URL:-https://github.com/ucli-tools/ucli}
    index_url=${UCLI_REGISTRY_INDEX_URL:-https://raw.githubusercontent.com/ucli-tools/ucli-registry/main/registry/index.tsv}
    legacy=${UCLI_LEGACY_BIN:-/usr/local/bin/ucli}

    # Where it will go.
    if [ -e "$legacy" ]; then
        bindir=$(dirname "$legacy")
        mode=update
    else
        prefix=${UCLI_PREFIX:-}
        if [ -z "$prefix" ]; then
            [ -n "${HOME:-}" ] || die "HOME is not set; set it, or set UCLI_PREFIX to a directory you can write."
            prefix=$HOME/.local
        fi
        bindir=$prefix/bin
        mode=new
        if ! mkdir -p "$bindir" 2>/dev/null || [ ! -w "$bindir" ]; then
            die "$bindir is not writable. Set UCLI_PREFIX to a directory you can write, for example UCLI_PREFIX=\$HOME/.local."
        fi
    fi

    # Which commit.
    pin=""
    if index=$(curl -fsSL "$index_url" 2>/dev/null); then
        pin=$(printf '%s\n' "$index" | awk -F '\t' '$1 == "ucli" { print $3; exit }')
    fi
    ref=main
    if [ -z "$pin" ]; then
        warn "could not read ucli's pin from the registry ($index_url); installing the head of main instead, which is not a pinned commit."
    elif is_commit "$pin"; then
        ref=$pin
    else
        die "the registry pin for ucli is malformed (expected 40 hex characters, got '$pin'). Nothing was installed."
    fi

    UCLI_INSTALLER_WORK=$(mktemp -d "${TMPDIR:-/tmp}/ucli-install.XXXXXX") \
        || die "cannot create a temporary directory"
    trap cleanup EXIT
    trap 'exit 130' INT
    trap 'exit 143' TERM

    if [ "$mode" = update ]; then
        step "Updating the existing ucli in $bindir"
    else
        step "Installing ucli to $bindir"
    fi
    step "Fetching ucli ($ref)"
    src=$UCLI_INSTALLER_WORK/src
    fetch_into "$repo_url" "$ref" "$src"

    head=$(git -C "$src" rev-parse HEAD) || die "cannot read the fetched commit"
    if [ "$ref" != main ] && [ "$head" != "$pin" ]; then
        die "the fetched commit ($head) is not the pinned commit ($pin). Nothing was installed."
    fi
    is_commit "$head" || die "unexpected fetched commit '$head'. Nothing was installed."

    step "Building"
    # The bin directory is put on PATH for this one command so ucli does not repeat the hint.
    (cd "$src" && PATH="$bindir:$PATH" make build) || die "ucli's install step failed."

    [ -x "$bindir/ucli" ] || die "$bindir/ucli is missing after the install."
    ver=$("$bindir/ucli" --version 2>&1) || die "the installed ucli does not run: $ver"
    if [ "$ref" != main ]; then
        case "$ver" in
            *"$pin"*) ;;
            *) die "the installed ucli reports '$ver', not the pinned commit $pin." ;;
        esac
    fi

    cleanup
    UCLI_INSTALLER_WORK=""

    say ""
    say "Installed: $ver"
    say "Location:  $bindir/ucli"
    if [ "$mode" = update ]; then
        say "An existing copy in $bindir was updated in place. To move it to ~/.local/bin (no sudo from then on): ucli install --move"
    fi
    if [ -d "${HOME:-/nonexistent}/.ucli/ucli" ]; then
        say "An older install is still in ~/.ucli/ucli. It is no longer used; you can delete it: rm -rf ~/.ucli/ucli"
    fi
    case ":$PATH:" in
        *":$bindir:"*) ;;
        *)
            shown=$bindir
            case "$bindir" in "${HOME:-/nonexistent}"/*) shown="\$HOME/${bindir#"$HOME"/}" ;; esac
            say ""
            say "$bindir is not on your PATH, so 'ucli' will not be found yet. Add it with one of:"
            # shellcheck disable=SC2016  # $PATH is meant literally: it is the line the user pastes
            printf '  bash:  echo '\''export PATH="%s:$PATH"'\'' >> ~/.bashrc   (macOS: ~/.bash_profile)\n' "$shown"
            # shellcheck disable=SC2016  # as above
            printf '  zsh:   echo '\''export PATH="%s:$PATH"'\'' >> ~/.zshrc\n' "$shown"
            say "  fish:  fish_add_path $shown"
            say "then open a new terminal."
            ;;
    esac
    say ""
    say "Next: ucli help        Docs: https://docs.ucli.tools        Registry: https://registry.ucli.tools"
}

main "$@"
