{
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf osConfig.my.dev.enable {
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
        prettier
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
    })

    # Godot is the one part of the toolchain a host may not want (it is big, and
    # exporting needs scons next to it). Gated on dev as well, so turning dev off
    # cannot leave Godot behind.
    (lib.mkIf (osConfig.my.dev.enable && osConfig.my.dev.godot.enable) {
      home.packages = with pkgs; [
        godot_4
        scons
      ];

      xdg.dataFile."godot/export_templates".source =
        "${pkgs.godot_4-export-templates-bin}/share/godot/export_templates";
    })
  ];
}
