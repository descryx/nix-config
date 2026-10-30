{ lib, local, ... }:
let
  # Every home-manager module file is imported by name: see lib/modules.nix.
  modules = import ./lib/modules.nix {
    inherit lib;
    root = ./modules;
  };
in
{
  home = {
    inherit (local) username;
    homeDirectory = local.homeDir;
  };

  imports = modules.home;

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.stateVersion = "26.05";
}
