{ inputs, local, ... }: {
  imports = [
    # Machine foundation (modules/system). Rarely touched.
    ./modules/system/boot.nix
    ./modules/system/networking.nix
    ./modules/system/users.nix
    ./modules/system/nix-settings.nix
    ./modules/system/nh.nix
    ./modules/system/power.nix
    ./modules/system/tools.nix
    ./modules/system/audio.nix

    # Desktop session (modules/desktop).
    ./modules/desktop/appearance/system.nix # + home half: modules/desktop/appearance/home.nix
    ./modules/desktop/sddm/system.nix
    ./modules/desktop/niri/system.nix # + home half: modules/desktop/niri/home.nix

    # Apps and services (modules/apps, modules/services).
    ./modules/apps/gaming/system.nix # + home half: modules/apps/gaming/home.nix
    ./modules/apps/obs/system.nix # host override: hosts/desk/obs.nix
    ./modules/services/storage/system.nix # + home half: modules/services/storage/home.nix
    ./modules/services/kdeconnect/system.nix
    ./modules/services/syncthing/system.nix
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
