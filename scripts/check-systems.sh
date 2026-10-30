#!/usr/bin/env bash
#
# check-systems — instantiate both hosts' system derivations without building.
#
# `nix flake check` evaluates the module graph but does not instantiate the
# toplevel, so errors that only appear at derivation time (e.g. a missing path
# literal from a moved file) slip through. This forces instantiation of each
# host's system derivation.
#
# Each host runs in its own `nix eval` process, so peak memory stays at roughly
# one system (~1.5 GiB) instead of accumulating the whole flake evaluation. It
# is deliberately NOT part of `nix flake check`, which is already the heaviest
# command here.
#
# It also refuses module files that git does not track: lib/modules.nix imports
# modules by file name, so an unadded file is silently absent from the build.
#
# Usage:
#   scripts/check-systems.sh
set -euo pipefail

# --- 1. Work from the repo root -----------------------------------------------
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
cd "$repo_root"

# --- 2. Auto-imported modules must be tracked by git --------------------------
# lib/modules.nix imports modules by file name, so a module file that git does
# not know about is silently absent from the build instead of producing a
# missing-import error. Fail loudly here instead.
untracked="$(
  git ls-files --others --exclude-standard -- modules |
    grep -E '(^|/)system\.nix$|(^|/)home\.nix$|^modules/core/[^/]+\.nix$' ||
    true
)"
if [ -n "$untracked" ]; then
  echo "check-systems: untracked module file(s) - git add them or they are not built:" >&2
  echo "$untracked" | sed 's/^/  /' >&2
  exit 1
fi

# --- 3. Force instantiation of every host -------------------------------------
# Keep in sync with nixosConfigurations in flake.nix when hosts are added/removed.
hosts=(desk t480)
failed=0

for host in "${hosts[@]}"; do
  printf 'check-systems: %s ... ' "$host"
  # Capture stderr (e.g. the "Git tree is dirty" warning) and only show it on
  # failure, so success output stays one clean line per host.
  if output="$(nix eval --raw ".#nixosConfigurations.${host}.config.system.build.toplevel.drvPath" 2>&1)"; then
    echo ok
  else
    echo FAILED
    echo "$output"
    failed=1
  fi
done

# --- 4. Any host that failed makes the whole run fail -------------------------
exit "$failed"
