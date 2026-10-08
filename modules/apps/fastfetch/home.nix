{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.fastfetch ];

  home.file.".config/fastfetch".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/fastfetch/config/fastfetch";
}
