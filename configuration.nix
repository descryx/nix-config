{ lib, ... }:
let
  # Every module file is imported by name, not from a list: see lib/modules.nix.
  # The two halves are still split (NixOS module / home-manager module), so a
  # feature with both is imported once on each side.
  modules = import ./lib/modules.nix {
    inherit lib;
    root = ./modules;
  };
in
{
  imports = modules.system;

  # ---------------------------------------------------------------------------
  # Feature switches. Every option is listed here by hand so there is a single
  # place to look one up. Options default to off; `lib.mkDefault true` turns a
  # feature on for both hosts, and a host overrides with a plain `= false`/`= true`.
  # Docs: docs/ARCHITECTURE.md -> Toggles.
  # ---------------------------------------------------------------------------

  my = {
    # Core features, on for both hosts.
    appearance.enable = lib.mkDefault true;
    sddm.enable = lib.mkDefault true;
    niri.enable = lib.mkDefault true;
    noctalia.enable = lib.mkDefault true;
    gaming.enable = lib.mkDefault true;
    obs.enable = lib.mkDefault true;
    storage.enable = lib.mkDefault true;
    syncthing.enable = lib.mkDefault true;
    dev.enable = lib.mkDefault true;
    nvim.enable = lib.mkDefault true;
    opencode.enable = lib.mkDefault true;
    ghostty.enable = lib.mkDefault true;
    kitty.enable = lib.mkDefault true;
    learnharness.enable = lib.mkDefault true;
    zsh.enable = lib.mkDefault true;
    zen.enable = lib.mkDefault true;
    vesktop.enable = lib.mkDefault true;
    wayscriber.enable = lib.mkDefault true;
    easyeffects.enable = lib.mkDefault true;
    btop.enable = lib.mkDefault true;
    cava.enable = lib.mkDefault true;
    fastfetch.enable = lib.mkDefault true;
    yazi.enable = lib.mkDefault true;
    defaultApps.enable = lib.mkDefault true;
    desktopApps.enable = lib.mkDefault true;

    # Off except where a host turns it on.
    kdeconnect.enable = lib.mkDefault false;
  };

  # Optional features (opt.*), off unless a host opts in.
  opt = {
    flatpak.enable = lib.mkDefault false;
    minecraft.enable = lib.mkDefault false;
    ollama.enable = lib.mkDefault false;
    openrgb.enable = lib.mkDefault false;
    tmux.enable = lib.mkDefault false;
  };

  system.stateVersion = "26.05"; # Did you read the comment?
}
