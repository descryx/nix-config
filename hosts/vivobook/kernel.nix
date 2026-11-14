{ pkgs, ... }:
{
  # 26.05's default is 6.18 LTS, which has no MT7902 driver. The latest mainline
  # (7.3 today) plus linux-firmware is what gives the Vivobook Wi-Fi/Bluetooth.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;
}
