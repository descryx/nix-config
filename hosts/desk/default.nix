{ ... }: {

  my = {
    kdeconnect.enable = true;
    flatpak.enable = true;
    openrgb.enable = true;
  };

  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./nix-settings.nix
    ./obs.nix
    ./boot.nix
  ];
  networking.hostName = "desk";
}
