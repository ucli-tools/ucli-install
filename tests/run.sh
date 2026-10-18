#!/bin/bash
# Tests for public/install.sh. No network: ucli is a local fixture repository, the registry
# is a local file, and `sudo` is a shim that records every call (none is expected).
#
#   tests/run.sh                        run with `sh` (what a user without bash would use)
#   INSTALL_SHELL=bash tests/run.sh     run with bash
#   UCLI_TEST_ROOT=<dir> tests/run.sh   keep the sandbox under <dir> (default: a mktemp dir)
#
# Bash 3.2 safe (macOS).
# shellcheck disable=SC2317  # helpers are called through check()
set -u

here="$(cd "$(dirname "$0")" && pwd)"
installer="$(cd "$here/.." && pwd)/public/install.sh"
shell_bin="$(command -v "${INSTALL_SHELL:-sh}")" || { echo "no such shell: ${INSTALL_SHELL:-sh}"; exit 2; }

if [ -n "${UCLI_TEST_ROOT:-}" ]; then
  mkdir -p "$UCLI_TEST_ROOT"
  root="$(cd "$UCLI_TEST_ROOT" && pwd)/run.$$"
  mkdir -p "$root"
else
  root="$(mktemp -d "${TMPDIR:-/tmp}/ucli-install-test.XXXXXX")"
fi
trap 'rm -rf "${root:?}"' EXIT
fails=0
n=0

ok()  { printf 'ok   %s\n' "$1"; }
bad() { printf 'FAIL %s\n' "$1"; fails=$((fails + 1)); }
check() { # check <description> <command...>
  local d="$1"; shift
  if "$@"; then ok "$d"; else bad "$d"; fi
}
contains() { case "$1" in *"$2"*) return 0 ;; esac; return 1; }
lacks() { case "$1" in *"$2"*) return 1 ;; esac; return 0; }

# ---- fixtures -------------------------------------------------------------------------
fixture="$root/ucli-fixture"
git init -q "$fixture"
git -C "$fixture" symbolic-ref HEAD refs/heads/main
cp "$here/fixture/ucli.sh" "$here/fixture/Makefile" "$fixture/"
git -C "$fixture" config user.email t@example.invalid
git -C "$fixture" config user.name t
git -C "$fixture" config uploadpack.allowAnySHA1InWant true
git -C "$fixture" add -A
git -C "$fixture" commit -q -m fixture
pin="$(git -C "$fixture" rev-parse HEAD)"

index="$root/index.tsv"
printf 'name\trepo\tcommit\tkind\nucli\tgithub.com/x/ucli\t%s\tcli\ngits\tgithub.com/x/gits\t%s\tcli\n' "$pin" "$pin" > "$index"

stubs="$root/stubs"       # sudo shim, first on PATH
mkdir -p "$stubs"
calls="$root/calls.log"
printf '#!/bin/sh\necho "sudo $*" >> "%s"\nexit 1\n' "$calls" > "$stubs/sudo"
chmod +x "$stubs/sudo"

# run_install <home> [VAR=value ...]: runs the installer in a fresh process; sets $out and $rc.
run_install() {
  local home="$1"; shift
  mkdir -p "$home" "$home/tmp"
  out="$(env -i HOME="$home" PATH="${TEST_PATH:-$stubs:$home/.local/bin:/usr/bin:/bin:/usr/local/bin}" TMPDIR="$home/tmp" \
    UCLI_REGISTRY_INDEX_URL="file://$index" UCLI_REPO_URL="$fixture" UCLI_LEGACY_BIN="$home/no-system-ucli" \
    "$@" "$shell_bin" "$installer" 2>&1)"
  rc=$?
}
new_home() { n=$((n + 1)); h="$root/home$n"; }
no_sudo() { [ ! -s "$calls" ]; }
tmp_clean() { [ -z "$(ls -A "$1/tmp" 2>/dev/null)" ]; }
: > "$calls"

# ---- 1. fresh install into ~/.local/bin, sudo never called -----------------------------------
echo "== fresh install"
new_home; run_install "$h"
check "exit 0" [ $rc -eq 0 ]
check "ucli is in ~/.local/bin" [ -x "$h/.local/bin/ucli" ]
check "ucli --version is the pinned commit" [ "$("$h/.local/bin/ucli" --version)" = "ucli $pin" ]
check "sudo was never called" no_sudo
check "the temporary clone is deleted" tmp_clean "$h"
check "output says where it went" contains "$out" "$h/.local/bin"

# ---- 2. existing system copy is updated in place ---------------------------------------------
echo "== existing system install"
new_home; mkdir -p "$h/sys/bin"
printf '#!/bin/bash\necho "ucli old"\n' > "$h/sys/bin/ucli"; chmod +x "$h/sys/bin/ucli"
run_install "$h" UCLI_LEGACY_BIN="$h/sys/bin/ucli"
check "exit 0" [ $rc -eq 0 ]
check "the system copy is now the pinned commit" [ "$("$h/sys/bin/ucli" --version)" = "ucli $pin" ]
check "nothing appeared in ~/.local/bin" [ ! -e "$h/.local/bin/ucli" ]
check "sudo was never called (directory writable)" no_sudo
check "output mentions the opt-in move" contains "$out" "ucli install --move"

# ---- 3. PATH hint ------------------------------------------------------------------------------
echo "== PATH hint"
new_home; TEST_PATH="$stubs:/usr/bin:/bin" run_install "$h"
check "hint printed when ~/.local/bin is not on PATH" contains "$out" "fish_add_path"
check "hint names bash and zsh too" contains "$out" ".zshrc"
new_home; run_install "$h"
check "no hint when ~/.local/bin is on PATH" lacks "$out" "fish_add_path"

# ---- 4. idempotent re-run ----------------------------------------------------------------------
echo "== re-run"
new_home; run_install "$h"; first="$(cat "$h/.local/bin/ucli")"
run_install "$h"
check "second run exits 0" [ $rc -eq 0 ]
check "same file after the second run" [ "$(cat "$h/.local/bin/ucli")" = "$first" ]
check "still the pinned commit" [ "$("$h/.local/bin/ucli" --version)" = "ucli $pin" ]
check "no stray files in ~/.local/bin" [ "$(ls -A "$h/.local/bin")" = "ucli" ]
check "sudo was never called" no_sudo

# ---- 5. a truncated script does nothing -------------------------------------------------------
echo "== truncated script"
for tool in curl git make; do # shims that record any call, so a stray run is caught
  printf '#!/bin/sh\necho "%s $*" >> "%s"\nexit 99\n' "$tool" "$calls" > "$stubs/$tool"; chmod +x "$stubs/$tool"
done
total="$(wc -l < "$installer" | tr -d ' ')"
new_home; mkdir -p "$h/tmp"
trunc_bad=0; cuts=0
touched() { [ -s "$calls" ] || [ -n "$(find "$h" -mindepth 1 -maxdepth 1 ! -name tmp)" ] || ! tmp_clean "$h"; }
i=1
while [ "$i" -lt "$total" ]; do
  : > "$calls"
  head -n "$i" "$installer" | env -i HOME="$h" PATH="$stubs:/usr/bin:/bin" TMPDIR="$h/tmp" "$shell_bin" >/dev/null 2>&1
  if touched; then trunc_bad=$((trunc_bad + 1)); echo "   line cut $i ran something"; fi
  cuts=$((cuts + 1)); i=$((i + 1))
done
size="$(wc -c < "$installer" | tr -d ' ')"
for frac in 10 25 50 75 90 99; do
  : > "$calls"
  head -c $((size * frac / 100)) "$installer" | env -i HOME="$h" PATH="$stubs:/usr/bin:/bin" TMPDIR="$h/tmp" "$shell_bin" >/dev/null 2>&1
  if touched; then trunc_bad=$((trunc_bad + 1)); echo "   byte cut $frac% ran something"; fi
  cuts=$((cuts + 1))
done
check "$cuts truncation points ran nothing" [ $trunc_bad -eq 0 ]
for tool in curl git make; do rm -f "${stubs:?}/$tool"; done
: > "$calls"
check "main is the last line" [ "$(tail -n 1 "$installer")" = 'main "$@"' ]

# ---- 6. registry unreachable: main with a warning -----------------------------------------------
echo "== registry unreachable"
new_home; run_install "$h" UCLI_REGISTRY_INDEX_URL="file://$root/does-not-exist.tsv"
check "exit 0" [ $rc -eq 0 ]
check "warning names the fallback to main" contains "$out" "warning: could not read ucli's pin"
check "installed anyway" [ -x "$h/.local/bin/ucli" ]
check "it is the head of main" [ "$("$h/.local/bin/ucli" --version)" = "ucli $pin" ]

# ---- 7. a malformed pin is refused ----------------------------------------------------------------
echo "== bad pin"
upper="$(printf '%s' "$pin" | tr 'a-f' 'A-F')"
for badpin in zzzz "${pin%?}" "${pin}a" "$upper" "main"; do
  printf 'ucli\tgithub.com/x/ucli\t%s\tcli\n' "$badpin" > "$root/bad.tsv"
  new_home; run_install "$h" UCLI_REGISTRY_INDEX_URL="file://$root/bad.tsv"
  check "refused: '$badpin'" [ $rc -ne 0 ]
  check "  says malformed" contains "$out" "malformed"
  check "  installs nothing" [ ! -e "$h/.local/bin/ucli" ]
done

# ---- 8. HEAD must match the pin --------------------------------------------------------------------
echo "== HEAD mismatch"
mkdir -p "$root/lyingbin"
real_git="$(command -v git)"
printf '#!/bin/sh\ncase "$*" in *"rev-parse HEAD"*) echo aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa;; *) exec "%s" "$@";; esac\n' "$real_git" > "$root/lyingbin/git"
chmod +x "$root/lyingbin/git"
new_home; TEST_PATH="$root/lyingbin:$stubs:/usr/bin:/bin" run_install "$h"
check "refused" [ $rc -ne 0 ]
check "says the commit is not the pin" contains "$out" "is not the pinned commit"
check "nothing installed" [ ! -e "$h/.local/bin/ucli" ]
printf 'ucli\tgithub.com/x/ucli\t%s\tcli\n' "0123456789abcdef0123456789abcdef01234567" > "$root/missing.tsv"
new_home; run_install "$h" UCLI_REGISTRY_INDEX_URL="file://$root/missing.tsv"
check "a pin that is not in the repository is refused" [ $rc -ne 0 ]
check "  nothing installed" [ ! -e "$h/.local/bin/ucli" ]

# ---- 9. missing curl, git or make ----------------------------------------------------------------------
echo "== missing prerequisites"
for missing in curl git make; do
  nb="$root/path-no-$missing"; mkdir -p "$nb"
  for t in uname dirname awk mktemp rm cat head tr sed bash env curl git make mkdir ls; do
    p="$(command -v "$t" 2>/dev/null)" || continue
    [ "$t" = "$missing" ] || ln -sf "$p" "$nb/$t"
  done
  new_home; TEST_PATH="$nb" run_install "$h"
  check "no $missing: fails" [ $rc -ne 0 ]
  check "  says $missing is not installed" contains "$out" "$missing is not installed"
  check "  installs nothing" [ ! -e "$h/.local/bin/ucli" ]
done

# ---- 10. prefix not writable ---------------------------------------------------------------------------------
echo "== prefix not writable"
new_home; mkdir -p "$h"; : > "$h/afile"
run_install "$h" UCLI_PREFIX="$h/afile"
check "fails" [ $rc -ne 0 ]
check "says the prefix is not writable" contains "$out" "is not writable"

# ---- 11. Windows -----------------------------------------------------------------------------------------------
echo "== Windows"
mkdir -p "$root/winbin"; printf '#!/bin/sh\necho MINGW64_NT-10.0-19045\n' > "$root/winbin/uname"; chmod +x "$root/winbin/uname"
new_home; TEST_PATH="$root/winbin:$stubs:/usr/bin:/bin" run_install "$h"
check "fails" [ $rc -ne 0 ]
check "prints the WSL note" contains "$out" "WSL"
check "installs nothing" [ ! -e "$h/.local/bin/ucli" ]

echo
if [ $fails -eq 0 ]; then echo "all passed"; else echo "$fails FAILED"; fi
exit $((fails > 0))
