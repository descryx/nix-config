{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.my.nextcloudUpload;

  # One-way upload. copy never downloads content and never deletes the
  # destination, so a local delete leaves the cloud copy in place. Only files
  # that are new or newer locally are uploaded.
  upload = pkgs.writeShellApplication {
    name = "nextcloud-upload";
    runtimeInputs = [
      pkgs.rclone
      pkgs.coreutils
    ];
    text = ''
      set -euo pipefail
      config="$HOME/.config/rclone/rclone.conf"

      ${lib.concatMapStringsSep "\n" (folder: ''
        if [ -d "$HOME/${folder}" ]; then
          echo "Uploading ${folder}"
          rclone copy --update --config "$config" --log-level INFO \
            --exclude '~$*' --exclude '.~lock.*' --exclude '*.tmp' \
            "$HOME/${folder}" "${cfg.remote}:${cfg.remoteRoot}/${folder}"
        fi
      '') cfg.folders}
    '';
  };
in
{
  options.my.nextcloudUpload = {
    enable = lib.mkEnableOption "one-way upload to Nextcloud";

    remote = lib.mkOption {
      type = lib.types.str;
      default = "storage-share";
      description = "rclone remote name from ~/.config/rclone/rclone.conf.";
    };

    remoteRoot = lib.mkOption {
      type = lib.types.str;
      default = "Computers";
      description = "Remote folder that holds the per-folder uploads.";
    };

    folders = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Local folders under the home directory to upload.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "15min";
      description = "How often the upload timer runs.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.folders != [ ]) {
    home.packages = [ pkgs.rclone ];

    systemd.user.services.nextcloud-upload = {
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe upload;
      };
    };

    systemd.user.timers.nextcloud-upload = {
      Timer = {
        OnStartupSec = "5min";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
        Unit = "nextcloud-upload.service";
      };

      Install.WantedBy = [ "timers.target" ];
    };
  };
}
