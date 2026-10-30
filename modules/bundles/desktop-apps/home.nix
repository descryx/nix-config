{
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkMerge [
    (lib.mkIf osConfig.my.desktopApps.enable {
      home.packages = with pkgs; [
        google-chrome
        gimp
        obsidian
        telegram-desktop
        thunar
        libreoffice
        onlyoffice-desktopeditors
        qbittorrent
        imv
        mpvpaper
        pavucontrol
        localsend
      ];

      programs = {
        mpv.enable = true;
      };
    })

    # Resolve is huge and not needed on the laptop; its own switch so the rest of
    # the bundle stays shared. Gated on the bundle as well.
    (lib.mkIf (osConfig.my.desktopApps.enable && osConfig.my.desktopApps.davinciResolve.enable) {
      home.packages = [ pkgs.davinci-resolve ];
    })
  ];
}
