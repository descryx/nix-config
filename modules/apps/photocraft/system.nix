{ config, lib, ... }:
{
  config = lib.mkIf config.my.photocraft.enable {
    # The NixOS module (not the home-manager one) is used because only it can
    # link /usr/share/fonts, which Photocraft's text tools look for.
    programs.craftapps = {
      enable = true;
      linkFonts = true;
      apps.photocraft.enable = true;
    };
  };
}
