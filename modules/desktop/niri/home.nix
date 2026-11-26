{
  config,
  local,
  inputs,
  pkgs,
  osConfig,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.niri.enable {
    home.packages = [
      inputs.oniri.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.niri-zoom
    ];

    home.file.".config/niri".source =
      config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/desktop/niri/config/niri";

    systemd.user.services.niri-zoomd = {
      Unit = {
        Description = "niri-zoom magnifier daemon";
        # Only niri sets NIRI_SOCKET. Without this, the service also starts in
        # the Umbriel session, where it has no niri socket and would restart in
        # a loop.
        ConditionEnvironment = "NIRI_SOCKET";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.niri-zoom}/bin/niri-zoomd";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
