{ pkgs, ... }:
{
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
    davinci-resolve
  ];

  programs.mpv.enable = true;
}
