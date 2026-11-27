{ pkgs, inputs, ... }:
let
  # 26.05 ships opencode-desktop 1.15.10. Lena's sessions come from the 2.x app
  # on Windows, so the app and its CLI come from the unstable input (2.2.6, the
  # version desk runs). They are the only unstable packages on this host.
  unstable = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};
  opencodeDesktop = unstable.opencode-desktop;
  # The desktop package ships no CLI; this is what imports/exports sessions.
  opencodeCli = unstable.opencode;
in
{
  imports = [
    ../../lib/user-options.nix
    ../../modules/apps/zsh/home.nix
    ../../modules/apps/ghostty/home.nix
    ../../modules/apps/nvim/home.nix
    ../../modules/apps/zen/home.nix
    ../../modules/apps/learnharness/home.nix
    ../../modules/services/nextcloud-mount/home.nix
    ../../modules/services/nextcloud-upload/home.nix
    ./plasma.nix
    ./plasma-desktop.nix
    ./theme.nix
    ./default-apps.nix
    ./nextcloud.nix
    ./cheatsheet.nix
  ];

  home = {
    username = "lena";
    homeDirectory = "/home/lena";
    stateVersion = "26.05";
  };

  my = {
    # Store copies instead of live symlinks: lena does not have to read the
    # maintainer's repo, and the configs still update on the next rebuild.
    dotfiles.live = false;

    # KDE gets native window decorations; the owner's niri profile keeps
    # window-decoration = none.
    ghostty.windowDecorations = true;
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  home.packages = with pkgs; [
    libreoffice-qt
    opencodeDesktop
    opencodeCli
    telegram-desktop
    localsend
    zoom-us
    haruna
    thunar
    thunar-volman
    ripgrep
    fd
    kdePackages.kcalc
    kdePackages.skanpage
    kdePackages.parley
    kdePackages.merkuro
    drawy
  ];

  # Terminal environment. Plasma's own UI language is set in plasma-localerc.
  home.sessionVariables = {
    LANG = "de_DE.UTF-8";
    LANGUAGE = "de";
  };
}
