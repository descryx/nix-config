{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.cava ];

  home.file.".config/cava".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/cava/config/cava";
}
