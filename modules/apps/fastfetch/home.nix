{
  config,
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.fastfetch.enable {
    home.packages = [ pkgs.fastfetch ];

    home.file.".config/fastfetch".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/fastfetch/config/fastfetch";
  };
}
