{ config, lib, ... }:
{
  config = lib.mkIf config.my.desktopApps.enable {
    programs.craftapps = {
      enable = true;
      apps.photocraft.enable = true;
    };
  };
}
