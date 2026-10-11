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

# --- 4. Render: drop the fences, color names, dim the descriptions --------------
# Truecolor (24-bit) on purpose: the standard 16 ANSI colors get remapped by the
# terminal palette, so a monochrome theme (e.g. Ghostty `noctalia`) turns everything
# grey. Truecolor bypasses the palette.
# LC_ALL=C so the multibyte tree glyphs are split by byte offset reliably.
LC_ALL=C awk -v color="$use_color" '
BEGIN {
  esc   = "\033["
  reset = esc "0m"
  glyph = esc "38;2;102;102;102m"    # #666666 tree branches
  cat   = esc "1;38;2;187;0;0m"      # #bb0000 section dirs
  dir   = esc "1;38;2;255;102;204m"  # #ff66cc feature dirs
  file  = esc "38;2;255;255;255m"    # #ffffff files
  cmt   = esc "38;2;102;102;102m"    # #666666 descriptions

  n = split("nix-config docs scripts hosts screenshots wallpapers system desktop apps services bundles optional", tmp, " ")
  for (i = 1; i <= n; i++) cats[tmp[i]] = 1
}
/^```/ { next }
{
  p = index($0, "#")
  if (p > 0) { pre = substr($0, 1, p - 1); desc = substr($0, p) }
  else       { pre = $0; desc = "" }

  if (!color) { print $0; next }

  # Split the tree glyphs from the entry name ("── " is the separator).
  g = index(pre, "── ")
  if (g > 0) { branches = substr(pre, 1, g + 6); body = substr(pre, g + 7) }
  else       { branches = ""; body = pre }

  name = body
  sub(/[ \t]+$/, "", name)
  base = name
  sub(/\/$/, "", base)

  if (base in cats)                 kind = cat
  else if (name ~ /\/$/)            kind = dir
  else if (name ~ /[[:alnum:].]/)   kind = file
  else                              kind = glyph

  if (branches != "") printf "%s%s%s", glyph, branches, reset
  printf "%s%s%s", kind, body, reset
  if (desc != "") printf "%s%s%s", cmt, desc, reset
  printf "\n"
}
' "$file"
