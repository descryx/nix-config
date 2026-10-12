{
  pkgs,
  config,
  lib,
  ...
}:
{
  # Shared OBS lives in modules/apps/obs/system.nix. This host unlocks the RTX 3060
  # NVENC chip; hosts that don't set `package` keep the shared default.
  config = lib.mkIf config.my.obs.enable {
    programs.obs-studio.package = pkgs.obs-studio.override {
      cudaSupport = true;
    };
  };
}
