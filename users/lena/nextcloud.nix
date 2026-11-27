{ pkgs, ... }:
{
  my.nextcloudUpload = {
    enable = true;
    remoteRoot = "Computers/Vivobook";
    folders = [ "Documents" ];
  };

  # Thunar and Tumbler need these for video, PDF and WebP thumbnails.
  home.packages = with pkgs; [
    ffmpegthumbnailer
    poppler-utils
    webp-pixbuf-loader
  ];

  # Thunar 4.20 stores this in Xfconf. "always" also thumbnails FUSE mounts.
  xfconf.settings.thunar."misc-thumbnail-mode" = "THUNAR_THUMBNAIL_MODE_ALWAYS";
}
