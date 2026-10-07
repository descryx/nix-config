{ inputs, local, ... }:
{
  home = {
    inherit (local) username;
    homeDirectory = local.homeDir;
  };

  imports = [
    ./modules/terminals/home.nix
    ./modules/misc-apps/home.nix
    ./modules/yazi/home.nix
    ./modules/nvim/home.nix
    ./modules/easyeffects/home.nix
    ./modules/dev/home.nix
    ./modules/opencode/home.nix
    ./modules/vesktop/home.nix
    ./modules/zen/home.nix
    ./modules/zsh/home.nix
    ./modules/default-apps/home.nix
    ./modules/desktop-apps/home.nix
    ./modules/appearance/home.nix
    ./modules/storage/home.nix
    ./modules/niri/home.nix
    ./modules/noctalia/home.nix
    ./modules/gaming/home.nix
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
