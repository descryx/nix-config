{
  networking.networkmanager.enable = true;

  # scrcpy
  networking.firewall.allowedTCPPortRanges = [
    {
      from = 30000;
      to = 65535;
    }
  ];
}
