{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.yazi ];

  home.file.".config/yazi".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/yazi/config";
}
