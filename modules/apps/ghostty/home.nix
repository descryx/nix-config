{
  config,
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.ghostty.enable {
    home.packages = [ pkgs.ghostty ];

    home.file.".config/ghostty".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/ghostty/config/ghostty";
  };
}
