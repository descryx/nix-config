#!/usr/bin/env bash
#
# noctalia-scrub — strip secret fields from the tracked Noctalia config.
#
# The tracked baseline (modules/noctalia/config/noctalia/noctalia-config.toml) must not
# contain secrets. `noctalia config export merged` pulls in the runtime
# settings.toml (which holds plugin API keys), so run this after every export.
#
# Usage:
#   scripts/noctalia-scrub.sh [FILE]           # remove the secret lines in place
#   scripts/noctalia-scrub.sh --check [FILE]   # exit 1 if a non-empty secret is
#                                              # present (no edit)
#
# Default FILE: modules/noctalia/config/noctalia/noctalia-config.toml
#
# Add your own secret field names to `secret_fields` below if the config ever
# carries others (the commented entries are examples). Each entry matches a whole
# line like `name = "..."`. Deleting the line is equivalent to an empty value, so
# the field is removed entirely.
set -euo pipefail

secret_fields=(
  api_key
  password
  # token
  # secret
)

names="${secret_fields[*]}"

check_only=0
file=""
for arg in "$@"; do
  case "$arg" in
    --check) check_only=1 ;;
    -*) echo "noctalia-scrub: unknown option: $arg" >&2; exit 2 ;;
    *) file="$arg" ;;
  esac
done
file="${file:-modules/noctalia/config/noctalia/noctalia-config.toml}"

[ -f "$file" ] || { echo "noctalia-scrub: no such file: $file" >&2; exit 2; }
[ -n "$names" ] || { echo "noctalia-scrub: no secret_fields configured" >&2; exit 2; }

if [ "$check_only" -eq 1 ]; then
  # Fail only when a secret field has a non-empty value (a real leak).
  awk -v names="$names" '
    BEGIN {
      n = split(names, a, " ")
      for (i = 1; i <= n; i++)
        re = re (i > 1 ? "|" : "") "^[[:space:]]*" a[i] "[[:space:]]*=[[:space:]]*\"[^\"]"
    }
    $0 ~ re { printf "  %s:%d: %s\n", FILENAME, NR, $1 > "/dev/stderr"; c++ }
    END { exit (c > 0 ? 1 : 0) }
  ' "$file" || {
    echo "noctalia-scrub: secret value(s) present in $file — run without --check to strip" >&2
    exit 1
  }
  echo "noctalia-scrub: clean ($file)"
  exit 0
fi

# Strip every line that sets a secret field, empty or not.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
before="$(wc -l < "$file")"
awk -v names="$names" '
  BEGIN {
    n = split(names, a, " ")
    for (i = 1; i <= n; i++)
      re = re (i > 1 ? "|" : "") "^[[:space:]]*" a[i] "[[:space:]]*="
  }
  $0 ~ re { next }
  { print }
' "$file" > "$tmp"
after="$(wc -l < "$tmp")"
removed=$((before - after))
if [ "$removed" -gt 0 ]; then
  mv "$tmp" "$file"
  echo "noctalia-scrub: removed $removed secret line(s) from $file"
else
  echo "noctalia-scrub: nothing to remove in $file"
fi
