# Import every module file by name instead of by hand.
#
#   modules/core/*.nix             NixOS modules (flat: one file per concern)
#   modules/<category>/**/system.nix  NixOS modules
#   modules/<category>/**/home.nix    home-manager modules
#
# Anything else under modules/ (package derivations next to their feature,
# config/, assets/) is not a module and is never imported here.
#
# The tradeoff: a module file that is not tracked by git does not exist as far
# as the flake is concerned, and nothing fails - the feature is just silently
# absent. scripts/check-systems.sh guards against that.
{ lib, root }:
let
  files = lib.filesystem.listFilesRecursive root;
  named = n: builtins.filter (f: builtins.baseNameOf f == n) files;
in
{
  system = lib.filesystem.listFilesRecursive (root + "/core") ++ named "system.nix";
  home = named "home.nix";
}
