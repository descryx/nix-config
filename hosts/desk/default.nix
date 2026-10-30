{ ... }: {

  my = {
    kdeconnect.enable = true;
    flatpak.enable = true;
    openrgb.enable = true;
  };

  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./obs.nix
    ./boot.nix
  ];
  networking.hostName = "desk";

  # 12 cores but only 15 GiB RAM. `max-jobs = auto` ran 12 builds at once, each
  # allowed all 12 cores, which pushed nix-daemon past 11 GiB and thrashed the
  # box. Bound both dimensions: 4 concurrent derivations, 4 cores each (`cores`
  # is shared, in modules/core/nix-settings.nix). Raise if builds feel slow and
  # memory pressure stays low; lower if it thrashes again.
  nix.settings.max-jobs = 4;
}
