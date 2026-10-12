{ lib, ... }:
{
  options.my.defaultApps.enable = lib.mkEnableOption "the default apps / mime associations";
}
