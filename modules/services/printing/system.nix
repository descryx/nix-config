{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.printing;
in
{
  config = lib.mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.gutenprint ];
    };

    # sane-pixma is part of sane-backends and covers the TS5000 series over USB.
    hardware.sane.enable = true;
  };
}
