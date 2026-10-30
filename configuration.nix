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
  # Feature switches. Every switch is declared and defaulted here, so this file
  # is the one place to look an option up. Declarations default to off;
  # `lib.mkDefault true` turns a feature on for both hosts, and a host overrides
  # with a plain `= false`/`= true`.
  # Docs: docs/ARCHITECTURE.md -> Toggles.
  # ---------------------------------------------------------------------------

  options.my = {
    appearance.enable = lib.mkEnableOption "the appearance / theming setup";
    sddm.enable = lib.mkEnableOption "sddm";
    niri.enable = lib.mkEnableOption "niri";
    noctalia.enable = lib.mkEnableOption "noctalia";
    gaming.enable = lib.mkEnableOption "gaming (steam + gamemode)";
    obs.enable = lib.mkEnableOption "OBS Studio";
    storage.enable = lib.mkEnableOption "storage services (tumbler, udisks2, gvfs)";
    syncthing.enable = lib.mkEnableOption "syncthing";
    dev = {
      # Covers modules/apps/dev and modules/apps/dev/python: the python half owns
      # the single interpreter and is only meaningful alongside dev.
      enable = lib.mkEnableOption "the dev toolchain";
      godot.enable = lib.mkEnableOption "Godot 4 with its export templates";
    };
    nvim.enable = lib.mkEnableOption "neovim";
    opencode.enable = lib.mkEnableOption "opencode";
    ghostty.enable = lib.mkEnableOption "ghostty";
    kitty.enable = lib.mkEnableOption "kitty";
    learnharness.enable = lib.mkEnableOption "learnharness";
    zsh.enable = lib.mkEnableOption "zsh";
    zen.enable = lib.mkEnableOption "the Zen browser";
    vesktop.enable = lib.mkEnableOption "vesktop";
    wayscriber.enable = lib.mkEnableOption "wayscriber";
    easyeffects.enable = lib.mkEnableOption "easyeffects";
    btop.enable = lib.mkEnableOption "btop";
    cava.enable = lib.mkEnableOption "cava";
    fastfetch.enable = lib.mkEnableOption "fastfetch";
    yazi.enable = lib.mkEnableOption "yazi";
    defaultApps.enable = lib.mkEnableOption "the default apps / mime associations";
    desktopApps = {
      enable = lib.mkEnableOption "the desktop apps bundle";
      davinciResolve.enable = lib.mkEnableOption "DaVinci Resolve";
    };
    kdeconnect.enable = lib.mkEnableOption "kdeconnect";
    flatpak.enable = lib.mkEnableOption "flatpak";
    minecraft.enable = lib.mkEnableOption "the Minecraft server";
    ollama.enable = lib.mkEnableOption "the Ollama LLM server";
    openrgb.enable = lib.mkEnableOption "OpenRGB";
    tmux.enable = lib.mkEnableOption "tmux";
  };

  # A module that declares options must put everything else under `config`.
  config = {
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
      dev = {
        enable = lib.mkDefault true;
        godot.enable = lib.mkDefault true;
      };
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
      desktopApps = {
        enable = lib.mkDefault true;
        davinciResolve.enable = lib.mkDefault true;
      };

      # Off except where a host turns it on.
      kdeconnect.enable = lib.mkDefault false;

      # Optional features, off unless a host opts in.
      flatpak.enable = lib.mkDefault false;
      minecraft.enable = lib.mkDefault false;
      ollama.enable = lib.mkDefault false;
      openrgb.enable = lib.mkDefault false;
      tmux.enable = lib.mkDefault false;
    };

    system.stateVersion = "26.05"; # Did you read the comment?
  };
}
