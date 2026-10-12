{ lib, ... }:
{
  options.my.kitty.enable = lib.mkEnableOption "kitty";
}
