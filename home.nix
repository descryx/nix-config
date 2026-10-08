{ inputs, local, ... }:
{
  home = {
    inherit (local) username;
    homeDirectory = local.homeDir;
  };

  imports = [
    # Desktop session (modules/desktop).
    ./modules/desktop/appearance/home.nix # + system half: modules/desktop/appearance/system.nix
    ./modules/desktop/niri/home.nix # + system half: modules/desktop/niri/system.nix
    ./modules/desktop/noctalia/home.nix

    # Apps (modules/apps).
    ./modules/apps/btop/home.nix
    ./modules/apps/cava/home.nix
    ./modules/apps/dev/home.nix
    ./modules/apps/easyeffects/home.nix
    ./modules/apps/fastfetch/home.nix
    ./modules/apps/gaming/home.nix # + system half: modules/apps/gaming/system.nix
    ./modules/apps/nvim/home.nix
    ./modules/apps/opencode/home.nix
    ./modules/apps/terminals/home.nix
    ./modules/apps/vesktop/home.nix
    ./modules/apps/wayscriber/home.nix
    ./modules/apps/yazi/home.nix
    ./modules/apps/zen/home.nix
    ./modules/apps/zsh/home.nix

    # Services (modules/services).
    ./modules/services/storage/home.nix # + system half: modules/services/storage/system.nix

    # Bundles (modules/bundles).
    ./modules/bundles/default-apps/home.nix
    ./modules/bundles/desktop-apps/home.nix

    # ./modules/optional/tmux/home.nix
  ];

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.stateVersion = "26.05";
}
