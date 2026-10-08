{ local, ... }:

{
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = {
        # Images -> imv
        "image/png" = "imv.desktop";
        "image/jpeg" = "imv.desktop";
        "image/webp" = "imv.desktop";
        "image/gif" = "imv.desktop";
        "image/bmp" = "imv.desktop";

        # Video -> mpv
        "video/mp4" = "mpv.desktop";
        "video/webm" = "mpv.desktop";
        "video/x-matroska" = "mpv.desktop";
        "video/x-msvideo" = "mpv.desktop";

        # Audio -> mpv
        "audio/mpeg" = "mpv.desktop";
        "audio/flac" = "mpv.desktop";
        "audio/ogg" = "mpv.desktop";

        # Browser
        "text/html" = "zen.desktop";
        "x-scheme-handler/http" = "zen.desktop";
        "x-scheme-handler/https" = "zen.desktop";
        "x-scheme-handler/about" = "zen.desktop";
        "x-scheme-handler/unknown" = "zen.desktop";

        "text/plain" = "nvim.desktop"; # Text editor
        "inode/directory" = "thunar.desktop"; # File manager
        "application/pdf" = "libreoffice-draw.desktop"; # PDF

        # Word processor
        "application/msword" = "libreoffice-writer.desktop";
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" =
          "libreoffice-writer.desktop";
        "application/vnd.oasis.opendocument.text" = "libreoffice-writer.desktop";

        # BitTorrent
        "application/x-bittorrent" = "org.qbittorrent.qBittorrent.desktop";
        "x-scheme-handler/magnet" = "org.qbittorrent.qBittorrent.desktop";
      };
    };
    configFile."gtk-3.0/bookmarks".text = ''
      file://${local.homeDir}/Projects Projects
      file://${local.homeDir}/Pictures Pictures
      file://${local.homeDir}/Downloads Downloads
      file://${local.homeDir}/Documents Documents
      file://${local.flakeDir} nix-config
      file:///mnt mnt
    '';
  };
}
