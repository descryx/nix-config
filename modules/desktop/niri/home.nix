{
  config,
  local,
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [
    inputs.oniri.packages.${pkgs.stdenv.hostPlatform.system}.default
    pkgs.niri-zoom
  ];

  home.file.".config/niri".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/desktop/niri/config/niri";

  systemd.user.services.niri-zoomd = {
    Unit = {
      Description = "niri-zoom magnifier daemon";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.niri-zoom}/bin/niri-zoomd";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
