{ ... }: {

  my.kdeconnect.enable = true;
  opt.flatpak.enable = true;
  opt.openrgb.enable = true;

  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./nix-settings.nix
    ./obs.nix
    ./boot.nix
  ];
  networking.hostName = "desk";
}
