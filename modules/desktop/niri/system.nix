{ pkgs, ... }:
{
  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # niri's X11 bridge; lives and dies with the compositor.
  environment.systemPackages = [ pkgs.xwayland-satellite ];
}
