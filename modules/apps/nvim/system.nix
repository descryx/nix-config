{ lib, ... }:
{
  options.my.nvim.enable = lib.mkEnableOption "neovim";
}
