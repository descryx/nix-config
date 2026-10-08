{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.btop ];

  home.file.".config/btop".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/btop/config/btop";
}
