{ ... }: {

  my = {
    flatpak.enable = true;

    # Not on the laptop: disk space and build time. The toggles exist so the
    # desktop can keep them without a hostname check inside the modules.
    dev.godot.enable = false;
    desktopApps.davinciResolve.enable = false;
  };

  imports = [
    ./hardware-configuration.nix
    ./graphics.nix
    ./batt-tresh.nix
  ];

  networking.hostName = "t480";

  # 4-core laptop: keep build parallelism low so it stays responsive and avoids
  # swapping (`cores` is shared, in modules/core/nix-settings.nix). Raise if it
  # turns out to have headroom (unverified - tune to taste).
  nix.settings.max-jobs = 2;

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
  };
}
