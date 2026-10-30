_: {
  # Desk-only boot specifics, kept out of modules/core/boot.nix.
  #   nct6775           - Nuvoton sensor chip on the desk motherboard
  #   nvidia_drm.fbdev  - NVIDIA + nvidia-drm framebuffer console (desk GPU)
  boot.kernelModules = [ "nct6775" ];
  boot.kernelParams = [ "nvidia_drm.fbdev=1" ];
}
