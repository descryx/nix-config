{
  config,
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.wayscriber.enable {
    home.packages = [ pkgs.wayscriber ];

    home.file.".config/wayscriber".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/wayscriber/config/wayscriber";
  };
}
