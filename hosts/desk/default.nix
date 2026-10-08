{ ... }: {
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./nix-settings.nix
    ./obs.nix

    # ../../modules/optional/ollama/system.nix
    ../../modules/optional/openrgb/system.nix
    # ../../modules/optional/minecraft/system.nix
    ../../modules/optional/flatpak/system.nix
  ];
  networking.hostName = "desk";
}
