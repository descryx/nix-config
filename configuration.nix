{ inputs, local, ... }: {
  imports = [
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/users.nix
    ./modules/system/nix-settings.nix
    ./modules/system/nh.nix
    ./modules/system/power.nix
    ./modules/system/tools.nix
    ./modules/system/audio.nix

    ./modules/appearance/system.nix
    ./modules/storage/system.nix
    ./modules/sddm/system.nix
    ./modules/niri/system.nix
    ./modules/gaming/system.nix
    ./modules/kdeconnect/system.nix
    ./modules/syncthing/system.nix
    ./modules/obs/system.nix
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
