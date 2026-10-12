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
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/apps/nvim/config";
  };
}
