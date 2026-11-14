{
  config,
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.ghostty;

  # One derived directory (instead of per-file entries) so switching a user
  # between the plain and decorated config replaces a symlink, not files inside
  # the read-only store. Later values win, so the appended setting beats the
  # shared window-decoration = none.
  decorated = pkgs.runCommand "ghostty-config-decorated" { } ''
    mkdir -p $out
    cp -r ${./config/ghostty}/. $out/
    chmod -R u+w $out
    printf '\nwindow-decoration = auto\n' >> $out/config.ghostty
  '';
in
{
  options.my.ghostty.windowDecorations = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = ''
      Prefer native window decorations. Used by the KDE profile; the owner's
      config keeps window-decoration = none.
    '';
  };

  config = lib.mkIf osConfig.my.ghostty.enable {
    home.packages = [ pkgs.ghostty ];

    home.file.".config/ghostty".source =
      if cfg.windowDecorations then
        decorated
      else if config.my.dotfiles.live then
        config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/ghostty/config/ghostty"
      else
        ./config/ghostty;
  };
}
