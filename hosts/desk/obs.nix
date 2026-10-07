{ pkgs, ... }:
{
  # Shared OBS lives in modules/obs/system.nix. This host unlocks the RTX 3060
  # NVENC chip; hosts that don't set `package` keep the shared default.
  programs.obs-studio.package = pkgs.obs-studio.override {
    cudaSupport = true;
  };
}
