{
  config,
  local,
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.nvim.enable {
    home.packages = [ pkgs.neovim ];

    home.file.".config/nvim".source =
      if config.my.dotfiles.live then
        config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/nvim/config"
      else
        ./config;
  };
}
