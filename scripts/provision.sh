#!/usr/bin/env bash
#
# provision.sh - bootstrap a new NixOS machine with disko-install.
#
# !!! NOT PRACTICALLY TESTED YET. Treat as a draft and read it before running. !!!
#
# WARNING: this ERASES the target disk.
#
# Run from the cloned repo on the NixOS installer (booted in UEFI mode).
#
# usage: ./scripts/provision.sh <host> <disk-device> [--yes]
#
# Prerequisites:
#   - hosts/<host>/ exists (copy hosts/_template, edit disk-config.nix/hostname)
#   - <host> is listed in flake.nix nixosConfigurations
#   - this repo imports disko.nixosModules.disko (already done)

set -euo pipefail

usage() {
  echo "usage: $0 <host> <disk-device> [--yes]" >&2
  exit 1
}

host="${1:-}"
disk="${2:-}"
assume_yes="${3:-}"

[[ -n "$host" && -n "$disk" ]] || usage

repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo"

hostdir="hosts/${host}"
[[ -d "$hostdir" ]] || {
  echo "error: '$hostdir' does not exist. Copy hosts/_template first." >&2
  exit 1
}
[[ -f "$hostdir/disk-config.nix" ]] || {
  echo "error: '$hostdir/disk-config.nix' is missing." >&2
  exit 1
}

if ! grep -q "\"${host}\"" flake.nix; then
  echo "error: '${host}' is not in flake.nix nixosConfigurations." >&2
  exit 1
fi

# Disko owns fileSystems, so hardware-configuration.nix must be generated with
# --no-filesystems to avoid conflicting definitions.
if [[ ! -f "$hostdir/hardware-configuration.nix" ]]; then
  echo ">> generating $hostdir/hardware-configuration.nix"
  tmp="$(mktemp -d)"
  nixos-generate-config --no-filesystems --root "$tmp"
  cp "$tmp/etc/nixos/hardware-configuration.nix" "$hostdir/hardware-configuration.nix"
  rm -rf "$tmp"
fi

echo
echo "This will ERASE and install NixOS on: ${disk}"
echo "host: ${host}"
lsblk -o NAME,SIZE,TYPE,MODEL "$disk" 2>/dev/null || true
echo

if [[ "$assume_yes" != "--yes" ]]; then
  read -rp "Retype the device path to confirm: " confirm
  [[ "$confirm" == "$disk" ]] || {
    echo "aborted" >&2
    exit 1
  }
fi

exec sudo nix --experimental-features "nix-command flakes" run \
  github:nix-community/disko/latest#disko-install -- \
  --write-efi-boot-entries \
  --flake "${repo}#${host}" \
  --disk main "$disk"
