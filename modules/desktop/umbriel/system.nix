{
  inputs,
  config,
  lib,
  ...
}:
{
  # The upstream module installs Umbriel, registers its Wayland session, enables
  # xdg-desktop-portal-umbriel and provides the systemd user unit. Umbriel ships
  # its own Xwayland wrapper, so this deliberately does not use
  # xwayland-satellite (that stays in modules/desktop/niri).
  imports = [ inputs.umbriel.nixosModules.default ];

  config = lib.mkIf config.my.umbriel.enable {
    programs.umbriel.enable = true;
  };
}
