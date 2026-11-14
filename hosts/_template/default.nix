# New-host template.
#
# Copy this directory to hosts/<new>/ and replace <new> with the real
# hostname (here and in flake.nix nixosConfigurations).
#
# This is a manual-install template: partition the disk, create the label-based
# btrfs subvolumes, generate hardware-configuration.nix on the installed system,
# then run `nixos-install --flake .#<new>`. The step-by-step runbook lives in
# docs/FAMILY.md. There is no disko integration in this repo.
#
# hardware-configuration.nix is generated on the target machine with
# `nixos-generate-config --no-filesystems`; fileSystems are written by hand so
# the repo stays label-based instead of storing disk UUIDs.
{ ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "<new>";
}
