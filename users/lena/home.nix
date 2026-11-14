{ pkgs, inputs, ... }:
let
  # 26.05 ships opencode-desktop 1.15.10. Lena's sessions come from the 2.x app
  # on Windows, so this one package is taken from the unstable input (2.2.6,
  # the version desk runs). It is the only unstable package on this host.
  opencodeDesktop = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system}.opencode-desktop;
in
{
  imports = [
    ../../lib/user-options.nix
    ../../modules/apps/zsh/home.nix
    ../../modules/apps/ghostty/home.nix
    ../../modules/apps/nvim/home.nix
    ../../modules/apps/zen/home.nix
    ../../modules/apps/learnharness/home.nix
    ./plasma.nix
    ./plasma-desktop.nix
    ./theme.nix
    ./default-apps.nix
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

    # Two releases behind the browser on desk, as requested. The upstream flake
    # revision is pinned in flake.nix; this only selects it for this user.
    zen.package = inputs.zen-browser-pinned.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
    telegram-desktop
    localsend
    zoom-us
    haruna
    thunar
    thunar-volman
    ripgrep
    fd
    kdePackages.kcalc
  ];

  # Terminal environment. Plasma's own UI language is set in plasma-localerc.
  home.sessionVariables = {
    LANG = "de_DE.UTF-8";
    LANGUAGE = "de";
  };
}
