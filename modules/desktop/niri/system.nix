{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.niri;
in
{

  config = lib.mkIf cfg.enable {
    programs.niri.enable = true;
    programs.xwayland.enable = true;

    # niri's X11 bridge; lives and dies with the compositor.
    environment.systemPackages = [ pkgs.xwayland-satellite ];
  };
}
