{ pkgs, ... }:
{
  boot = {
    loader = {
      systemd-boot.enable = true;
      systemd-boot.configurationLimit = 10;
      efi.canTouchEfiVariables = true;
      timeout = 5;
    };
    # 2 = upstream default: unprivileged users can't profile the kernel.
    # No local tool needs it relaxed (perf isn't installed; mangohud doesn't use it).
    kernel.sysctl."kernel.perf_event_paranoid" = 2;
    kernelPackages = pkgs.linuxPackages_zen;
    kernelModules = [ "nct6775" ];

    kernelParams = [
      "quiet"
      "nvidia_drm.fbdev=1"
    ];

    plymouth = {
      enable = true;
      theme = "mac-style";
      themePackages = [ pkgs.mac-style-plymouth ];
    };
  };
  zramSwap.enable = true;
}
