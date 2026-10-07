{ pkgs, ... }:
{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      intel-compute-runtime
    ];
  };
}
