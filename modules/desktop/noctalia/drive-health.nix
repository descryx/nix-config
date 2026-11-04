{
  config,
  lib,
  pkgs,
  ...
}:
let
  user = "descryx";
  # Absolute path, never "~/...": systemd's file-system options take paths
  # relative to the host root (systemd.exec(5), 262), and `sh <path>` does not
  # tilde-expand its argument either. The upstream NixOS snippet passes an
  # absolute path for the same reason. This is the materialized plugin dir, so
  # the collector follows plugin updates.
  pluginDir = "/home/descryx/.local/state/noctalia/plugins/materialized/community/drive-health";
in
{
  config = lib.mkIf config.my.noctalia.enable {
    environment.systemPackages = [ pkgs.smartmontools ];

    systemd.services.noctalia-drive-health = {
      description = "Collect read-only SMART data for Noctalia Drive Health";
      after = [ "local-fs.target" ];
      path = with pkgs; [
        bash
        coreutils
        util-linux
        smartmontools
      ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/sh ${pluginDir}/scripts/collect_raw.sh --output /run/noctalia-drive-health/raw.json";
        Group = config.users.users.${user}.group;
        RuntimeDirectory = "noctalia-drive-health";
        RuntimeDirectoryMode = "0750";
        RuntimeDirectoryPreserve = "yes";
        UMask = "0027";
        StandardOutput = "null";
        TimeoutStartSec = "60s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateNetwork = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        ProtectClock = true;
        RestrictAddressFamilies = "AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        CapabilityBoundingSet = [
          "CAP_DAC_OVERRIDE"
          "CAP_SYS_ADMIN"
          "CAP_SYS_RAWIO"
        ];
        ReadWritePaths = [ "/run/noctalia-drive-health" ];
        # Redundant with ProtectHome = "read-only", kept to mirror the unit the
        # plugin ships (packaging/noctalia-drive-health.service.in).
        ReadOnlyPaths = [ pluginDir ];
      };
    };

    systemd.timers.noctalia-drive-health = {
      description = "Refresh SMART data for Noctalia";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = "20s";
        OnUnitActiveSec = "15min";
        AccuracySec = "5s";
        Unit = "noctalia-drive-health.service";
      };
    };
  };
}
