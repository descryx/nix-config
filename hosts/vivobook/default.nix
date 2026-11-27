{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./kernel.nix
    ./printing.nix
    ../../users/lena/system.nix
  ];

  networking = {
    hostName = "vivobook";
    firewall.allowedTCPPorts = [ 3389 ];
  };

  my = {
    # lena's daily environment.
    zsh.enable = true;
    nvim.enable = true;
    ghostty.enable = true;
    zen.enable = true;
    learnharness.enable = true;
    kde.enable = true;
    kdePim.enable = true;
    photocraft.enable = true;
    printing.enable = true;
    storage.enable = true;
    nextcloudMount.enable = true;
    sddm.enable = true;

    # Owner-only / developer / optional features.
    appearance.enable = false;
    niri.enable = false;
    noctalia.enable = false;
    umbriel.enable = false;
    gaming.enable = false;
    obs.enable = false;
    dev.enable = false;
    dev.godot.enable = false;
    desktopApps.enable = false;
    defaultApps.enable = false;
    opencode.enable = false;
    kitty.enable = false;
    vesktop.enable = false;
    wayscriber.enable = false;
    easyeffects.enable = false;
    btop.enable = false;
    cava.enable = false;
    fastfetch.enable = false;
    yazi.enable = false;
    syncthing.enable = false;
    kdeconnect.enable = false;
    flatpak.enable = false;
    minecraft.enable = false;
    ollama.enable = false;
    openrgb.enable = false;
    tmux.enable = false;

    sddm.wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/DarkestHour/contents/images/2560x1600.jpg";
  };

  # Thunar 4.20 keeps its settings in Xfconf, including the thumbnail mode.
  programs.xfconf.enable = true;

  services = {
    displayManager = {
      # Only Plasma exists here; niri, noctalia and umbriel are off.
      defaultSession = "plasma";

      # The SDDM theme preselects Umbriel by name and falls back to index 0
      # when it is absent. Hide the maintenance account so lena is the only
      # entry and the fallback default; descryx remains available over SSH.
      hiddenUsers = [
        "nobody"
        "descryx"
      ];
    };

    xserver.xkb = {
      layout = "de,ru,us";
      model = "pc105";
      options = "grp:alt_shift_toggle";
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowGroups = [ "wheel" ];
      };
    };
  };

  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  boot.loader.systemd-boot.configurationLimit = 5;
  programs.nh.clean.extraArgs = "--keep 5";

  # 6 cores / 16 GB; keep the laptop responsive while building.
  nix.settings.max-jobs = 2;

  # Data USB (exFAT/NTFS) and the Windows backup drive.
  boot.supportedFilesystems = [
    "ntfs"
    "exfat"
  ];

  users.users.descryx.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGfUDJME1dmYwWrlaX+pIQgp23oX/m9aezWSvFKZhBZu"
  ];

  # VM-only test settings; they do not affect the installed host.
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 4096;
      cores = 4;
      diskSize = 20 * 1024;
    };
    services.displayManager.autoLogin = {
      enable = true;
      user = "lena";
    };
  };
}
