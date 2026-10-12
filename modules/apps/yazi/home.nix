{
  config,
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.yazi.enable {
    home.packages = [ pkgs.yazi ];

    home.file.".config/yazi".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/yazi/config";
  };
}
