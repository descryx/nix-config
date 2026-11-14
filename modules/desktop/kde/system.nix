{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.kde;
in
{
  config = lib.mkIf cfg.enable {
    services.desktopManager.plasma6.enable = true;

    # plasma6 turns these on with mkDefault; a daily-driver desktop does not need
    # a screen reader or the KMail/Kontact stack.
    services.orca.enable = false;

    programs = {
      xwayland.enable = true;
      kde-pim.enable = false;

      # KDE's GTK bridge and Thunar use dconf for GTK settings.
      dconf.enable = true;
    };

    # lena uses Thunar; do not pull Dolphin into the Plasma closure.
    #
    # Electron and Firefox-derived apps should use Wayland in a Plasma session.
    environment = {
      plasma6.excludePackages = with pkgs.kdePackages; [ dolphin ];

      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = "1";
      };

      # lena's desktop wallpaper comes from this package. Install it explicitly
      # so the path cannot be garbage-collected while it is only referenced as a
      # string in her home-manager config.
      systemPackages = [ pkgs.kdePackages.plasma-workspace-wallpapers ];
    };

    # The SDDM theme asks for Cascadia Code; do not depend on another feature
    # having installed it.
    fonts.packages = [ pkgs.cascadia-code ];

    assertions = [
      {
        assertion = config.services.displayManager.sddm.enable;
        message = "my.kde.enable needs my.sddm.enable (or another display manager).";
      }
    ];
  };
}
