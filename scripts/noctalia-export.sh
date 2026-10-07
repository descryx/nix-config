#!/usr/bin/env bash
#
# noctalia-export — regenerate the tracked Noctalia baseline safely.
#
# `noctalia config export merged` dumps the whole merged runtime config
# (including plugin API keys and anything else the plugins store, e.g. a
# location) straight to stdout. Piping that into a tracked file is how secrets
# and identifying values have leaked into the repo before.
#
# This wrapper exports to a temporary file, strips credential fields, refuses to
# install the result if anything sensitive is still present, and only then
# overwrites the tracked baseline. On failure the tracked file is left untouched.
#
# Usage:
#   scripts/noctalia-export.sh            # export, scrub, check, write
#   scripts/noctalia-export.sh --dry-run  # ...but only show the diff
#   scripts/noctalia-export.sh [FILE]     # use a different output file
#
# Run this instead of `noctalia config export merged > <baseline>`.
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
scrub="$repo_root/scripts/noctalia-scrub.sh"
default_baseline="$repo_root/modules/noctalia/config/noctalia/noctalia-config.toml"

dry_run=0
baseline=""
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=1 ;;
    -h | --help)
      sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*) echo "noctalia-export: unknown option: $arg" >&2; exit 2 ;;
    *) baseline="$arg" ;;
  esac
done
baseline="${baseline:-$default_baseline}"

command -v noctalia >/dev/null 2>&1 || { echo "noctalia-export: 'noctalia' not found on PATH" >&2; exit 2; }
[ -x "$scrub" ] || { echo "noctalia-export: scrub script not executable: $scrub" >&2; exit 2; }

tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

echo "noctalia-export: exporting merged config..."
noctalia config export merged > "$tmp"

[ -s "$tmp" ] || { echo "noctalia-export: export produced an empty file, aborting" >&2; exit 1; }

echo "noctalia-export: stripping credential fields..."
"$scrub" "$tmp"

echo "noctalia-export: checking for leftover sensitive fields..."
if ! "$scrub" --check "$tmp"; then
  echo "noctalia-export: sensitive field(s) still present — the tracked file was NOT changed." >&2
  echo "noctalia-export: remove them (e.g. in the Noctalia UI or per-machine settings.toml) and re-run." >&2
  exit 1
fi

if [ "$dry_run" -eq 1 ]; then
  echo "noctalia-export: dry run, diff against $baseline:"
  diff -u "$baseline" "$tmp" || true
  exit 0
fi

mv "$tmp" "$baseline"
trap - EXIT
echo "noctalia-export: wrote $baseline"
echo "noctalia-export: review with 'git diff' and commit if it looks right."
