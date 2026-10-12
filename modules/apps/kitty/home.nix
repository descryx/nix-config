{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.kitty ];

  home.file.".config/kitty".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/kitty/config/kitty";
}
