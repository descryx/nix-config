#!/usr/bin/env bash
#
# noctalia-scrub — keep secrets and leaked identifiers out of the tracked
# Noctalia config.
#
# The tracked baseline (modules/desktop/noctalia/config/noctalia/noctalia-config.toml)
# must not contain secrets. `noctalia config export merged` pulls in the runtime
# settings.toml (which holds plugin API keys), so run this after every export.
#
# Usage:
#   scripts/noctalia-scrub.sh [FILE]           # remove credential lines in place
#   scripts/noctalia-scrub.sh --check [FILE]   # no edit; exit non-zero when a
#                                              # credential value or a sensitive
#                                              # field is present
#
# Default FILE: modules/desktop/noctalia/config/noctalia/noctalia-config.toml
#
# Two field lists:
#   - secret_fields   are DELETED, because they are never functional config.
#   - location_fields are only REPORTED, never deleted: a latitude/longitude
#     line can be functional config, so it is surfaced for a human to review
#     instead of being silently removed. Only non-empty values are matched.
#
# Add names to either list below if the config ever carries others.
set -euo pipefail

secret_fields=(
  api_key
  password
  token
  secret
  refresh_token
  client_secret
)

location_fields=(
  latitude
  longitude
)

secrets="${secret_fields[*]}"
locations="${location_fields[*]}"

check_only=0
file=""
for arg in "$@"; do
  case "$arg" in
    --check) check_only=1 ;;
    -*) echo "noctalia-scrub: unknown option: $arg" >&2; exit 2 ;;
    *) file="$arg" ;;
  esac
done
file="${file:-modules/desktop/noctalia/config/noctalia/noctalia-config.toml}"

[ -f "$file" ] || { echo "noctalia-scrub: no such file: $file" >&2; exit 2; }
[ -n "$secrets" ] || { echo "noctalia-scrub: no secret_fields configured" >&2; exit 2; }

# Report (without editing) every non-empty sensitive field. Prints the whole
# line so the value is visible; returns 1 if anything matched.
report_locations() {
  awk -v names="$locations" '
    BEGIN {
      n = split(names, a, " ")
      for (i = 1; i <= n; i++)
        re = re (i > 1 ? "|" : "") "^[[:space:]]*" a[i] "[[:space:]]*=[[:space:]]*\"[^\"]"
    }
    $0 ~ re { printf "  %s:%d: %s\n", FILENAME, NR, $0 > "/dev/stderr"; c++ }
    END { exit (c > 0 ? 1 : 0) }
  ' "$file"
}

if [ "$check_only" -eq 1 ]; then
  status=0

  # Fail when a credential field has a non-empty value (a real leak). Print only
  # the field name, never the value.
  awk -v names="$secrets" '
    BEGIN {
      n = split(names, a, " ")
      for (i = 1; i <= n; i++)
        re = re (i > 1 ? "|" : "") "^[[:space:]]*" a[i] "[[:space:]]*=[[:space:]]*\"[^\"]"
    }
    $0 ~ re { printf "  %s:%d: %s\n", FILENAME, NR, $1 > "/dev/stderr"; c++ }
    END { exit (c > 0 ? 1 : 0) }
  ' "$file" || {
    echo "noctalia-scrub: secret value(s) present in $file — run without --check to strip" >&2
    status=1
  }

  if ! report_locations; then
    echo "noctalia-scrub: sensitive field(s) above are present in $file (reported, not removed — review manually)" >&2
    status=1
  fi

  if [ "$status" -eq 0 ]; then
    echo "noctalia-scrub: clean ($file)"
  fi
  exit "$status"
fi

# Strip every line that sets a credential field, empty or not. Sensitive fields
# outside `secret_fields` are intentionally left untouched.
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT
before="$(wc -l < "$file")"
awk -v names="$secrets" '
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

# Report (never remove) sensitive fields that were left in place.
if ! report_locations; then
  echo "noctalia-scrub: sensitive field(s) above left in place (review manually)" >&2
fi
