{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.ghostty ];

  home.file.".config/ghostty".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/ghostty/config/ghostty";
}
