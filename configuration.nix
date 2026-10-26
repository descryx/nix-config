{ lib, ... }: {
  imports = [
    # Machine foundation (modules/system). Rarely touched.
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/users.nix
    ./modules/system/nix-settings.nix
    ./modules/system/nh.nix
    ./modules/system/power.nix
    ./modules/system/tools.nix
    ./modules/system/audio.nix

    # Desktop session (modules/desktop).
    ./modules/desktop/appearance/system.nix # + home half: modules/desktop/appearance/home.nix
    ./modules/desktop/sddm/system.nix
    ./modules/desktop/niri/system.nix # + home half: modules/desktop/niri/home.nix
    ./modules/desktop/noctalia/system.nix # + home half: modules/desktop/noctalia/home.nix

    # Apps (modules/apps).
    ./modules/apps/btop/system.nix # + home half: modules/apps/btop/home.nix
    ./modules/apps/cava/system.nix # + home half: modules/apps/cava/home.nix
    ./modules/apps/dev/system.nix # + home halves: modules/apps/dev{,/python}/home.nix
    ./modules/apps/easyeffects/system.nix # + home half: modules/apps/easyeffects/home.nix
    ./modules/apps/fastfetch/system.nix # + home half: modules/apps/fastfetch/home.nix
    ./modules/apps/gaming/system.nix # + home half: modules/apps/gaming/home.nix
    ./modules/apps/ghostty/system.nix # + home half: modules/apps/ghostty/home.nix
    ./modules/apps/kitty/system.nix # + home half: modules/apps/kitty/home.nix
    ./modules/apps/learnharness/system.nix # + home half: modules/apps/learnharness/home.nix
    ./modules/apps/nvim/system.nix # + home half: modules/apps/nvim/home.nix
    ./modules/apps/obs/system.nix # host override: hosts/desk/obs.nix
    ./modules/apps/opencode/system.nix # + home half: modules/apps/opencode/home.nix
    ./modules/apps/vesktop/system.nix # + home half: modules/apps/vesktop/home.nix
    ./modules/apps/wayscriber/system.nix # + home half: modules/apps/wayscriber/home.nix
    ./modules/apps/yazi/system.nix # + home half: modules/apps/yazi/home.nix
    ./modules/apps/zen/system.nix # + home half: modules/apps/zen/home.nix
    ./modules/apps/zsh/system.nix # + home half: modules/apps/zsh/home.nix

    # Services (modules/services).
    ./modules/services/kdeconnect/system.nix
    ./modules/services/storage/system.nix # + home half: modules/services/storage/home.nix
    ./modules/services/syncthing/system.nix

    # Bundles (modules/bundles).
    ./modules/bundles/default-apps/system.nix # + home half: modules/bundles/default-apps/home.nix
    ./modules/bundles/desktop-apps/system.nix # + home half: modules/bundles/desktop-apps/home.nix

    # Optional features (modules/optional). Imported always so their `opt.*`
    # options exist for every host; toggled per host in hosts/<host>/default.nix.
    ./modules/optional/flatpak/system.nix
    ./modules/optional/minecraft/system.nix
    ./modules/optional/ollama/system.nix
    ./modules/optional/openrgb/system.nix
    ./modules/optional/tmux/system.nix
  ];

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
