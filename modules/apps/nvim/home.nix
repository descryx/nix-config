{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.neovim ];

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/nvim/config";
}
