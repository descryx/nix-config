{
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
    # ^ keep this the plain pkgs.nodejs: modules/apps/opencode/skills.nix also
    #   provides pkgs.nodejs, and home-manager's buildEnv dedups identical store
    #   paths. Switching either to nodejs.withPackages/override would collide.
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

  # clangd reads this as user config when a project has neither a .clangd nor a
  # compile_commands.json. Project config still wins; per-repo .clang-format
  # files are picked up via `Format.Style: file`.
  xdg.configFile."clangd/config.yaml".text = ''
    CompileFlags:
      Add:
        - "-std=c++23"
        - "-Wall"
        - "-Wextra"
    Format:
      Style: file
  '';
}
