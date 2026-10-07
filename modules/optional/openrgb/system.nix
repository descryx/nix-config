{ pkgs, ... }:
{
  environment.systemPackages = [ pkgs.openrgb-with-all-plugins ];
  services.udev.packages = [ pkgs.openrgb-with-all-plugins ];
  boot.kernelModules = [
    "i2c-dev"
    "i2c-i801"
  ];

  hardware.i2c.enable = true;
}
