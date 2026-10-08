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
# Usage:
#   scripts/check-systems.sh
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(dirname "$script_dir")"
cd "$repo_root"

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

exit "$failed"
