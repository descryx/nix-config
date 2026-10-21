{ config, lib, ... }:
{
  options.my.desktopApps.enable = lib.mkEnableOption "the desktop apps bundle";
  config = lib.mkIf config.my.desktopApps.enable {
    programs.craftapps = {
      enable = true;
      apps.photocraft.enable = true;
    };
  };
}
