#!/usr/bin/env bash
#
# map - print docs/structure.md as a color-coded table of contents.
#
# The doc is the single source of truth; this only styles it. Directories are
# colored, the `#` descriptions dimmed. Fails loudly if the doc no longer starts
# with the expected code fence, so format drift does not render silently wrong.
#
# Usage:
#   scripts/map.sh [FILE]          # default: docs/structure.md
#   scripts/map.sh --no-color      # force plain output
#   scripts/map.sh --color         # force color (e.g. for `| less -R`)
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"

# --- 1. Parse options and pick the input file ---------------------------------
color=auto
file=""
for arg in "$@"; do
  case "$arg" in
    --color) color=always ;;
    --no-color) color=never ;;
    -h | --help)
      sed -n '2,12p' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    -*) echo "map: unknown option: $arg" >&2; exit 2 ;;
    *) file="$arg" ;;
  esac
done
file="${file:-$repo_root/docs/structure.md}"

# --- 2. Verify the file is the expected single-fenced tree ---------------------
[ -f "$file" ] || { echo "map: no such file: $file" >&2; exit 2; }
if [ "$(head -n 1 "$file")" != '```' ] || [ "$(tail -n 1 "$file")" != '```' ]; then
  echo "map: $file is not a single fenced code block; format changed?" >&2
  exit 1
fi

# --- 3. Decide whether to color ------------------------------------------------
case "$color" in
  always) use_color=1 ;;
  never) use_color=0 ;;
  auto)
    if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
      use_color=1
    else
      use_color=0
    fi
    ;;
esac

# --- 4. Render: drop the fences, color dirs, dim the descriptions --------------
awk -v color="$use_color" '
BEGIN {
  reset = "\033[0m"
  dir   = "\033[1;36m"   # bold cyan   (directories)
  file  = "\033[0;36m"   # cyan        (files + tree glyphs)
  cmt   = "\033[2;37m"   # dim grey    (descriptions)
}
/^```/ { next }
{
  p = index($0, "#")
  if (p > 0) { pre = substr($0, 1, p - 1); desc = substr($0, p) }
  else       { pre = $0; desc = "" }

  if (!color) { print $0; next }

  trimmed = pre
  sub(/[ \t]+$/, "", trimmed)
  if (trimmed ~ /\/$/) printf "%s%s%s", dir, pre, reset
  else                 printf "%s%s%s", file, pre, reset

  if (desc != "") printf "%s%s%s", cmt, desc, reset
  printf "\n"
}
' "$file"
