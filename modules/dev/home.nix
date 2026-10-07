{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    wget
    gh
    lazygit
    stow
    ripgrep
    fd
    clang-tools
    nodejs
    python3
    unzip
    cargo
    fzf
    wl-clipboard
    imagemagick
    tree-sitter
    glow
  ];

  programs.git = {
    enable = true;
    settings.user = {
      name = local.username;
      email = local.gitEmail;
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    enableZshIntegration = true;
  };

  home.file.".config/clangd".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/dev/config/clangd";
}
