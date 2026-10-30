{ ... }: {

  my.flatpak.enable = true;

  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./nix-settings.nix
    ./batt-tresh.nix
  ];

  networking.hostName = "t480";

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
