{
  osConfig,
  pkgs,
  lib,
  local,
  ...
}:
let
  cfg = osConfig.my.nextcloudMount;
  mountPoint = "${local.homeDir}/StorageShare";
  rcloneConfig = "${local.homeDir}/.config/rclone/rclone.conf";
in
{
  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.rclone ];

    # Read-only on demand. Reads go straight to WebDAV; nothing is uploaded or
    # modified, so this cannot repeat the OpenVFS mtime bug. The remote name,
    # URL, username and app password live in ~/.config/rclone/rclone.conf, not
    # in this repo.
    systemd.user.services.nextcloud-mount = {
      Unit = {
        Description = "Read-only on-demand mount of the Nextcloud account";
        After = [ "network-online.target" ];
        # Keep retrying if the network is not up yet; do not give up after the
        # default 5 starts in 10 s.
        StartLimitIntervalSec = 0;
      };

      Service = {
        Type = "notify";
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p ${mountPoint}";
        ExecStart = lib.concatStringsSep " " [
          (lib.getExe pkgs.rclone)
          "mount"
          "--read-only"
          "--config=${rcloneConfig}"
          "--dir-cache-time=5m"
          "--poll-interval=0"
          "--timeout=1m"
          "--contimeout=30s"
          "--umask=022"
          "--log-level=INFO"
          "storage-share:"
          mountPoint
        ];
        Restart = "on-failure";
        RestartSec = "15s";
        SuccessExitStatus = "143";
        # rclone needs the setuid fusermount3 from /run/wrappers.
        Environment = [
          "PATH=/run/wrappers/bin:${
            lib.makeBinPath [
              pkgs.fuse3
              pkgs.coreutils
            ]
          }:/run/current-system/sw/bin"
        ];
      };

      Install.WantedBy = [ "default.target" ];
    };

    xdg.configFile."gtk-3.0/bookmarks".text = lib.mkAfter ''
      file://${mountPoint} Storage Share
    '';
  };
}
