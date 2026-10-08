{ pkgs, ... }:
{
  home.packages = with pkgs; [
    udiskie
    # Thumbnail providers used by tumbler / gdk-pixbuf (video, PDF, webp).
    ffmpegthumbnailer
    poppler-utils
    webp-pixbuf-loader
  ];

  services.udiskie = {
    enable = true;
    tray = "auto"; # "always", "auto", or "never"
    settings = {
      program_options = {
        file_manager = "xdg-open";
      };
      notifications = {
        timeout = 3;
      };
    };
  };

  systemd.user.services.udiskie.Unit.After = [ "udisks2.service" ];
}
