{
  lib,
  config,
  ...
}:
let
  cfg = config.my.noctalia;
in
{
  options.my.noctalia.enable = lib.mkEnableOption "noctalia";

  config = lib.mkIf cfg.enable {
    # Prebuilt Noctalia packages (the noctalia flake input). Kept in this feature
    # so the base system does not carry another module's substituter: disabling
    # modules/desktop/noctalia removes the cache along with it.
    nix.settings = {
      extra-substituters = [ "https://noctalia.cachix.org" ];
      extra-trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      ];
    };

    # scrcpy (modules/desktop/noctalia/home.nix) connects over its default port
    # range.
    networking.firewall.allowedTCPPortRanges = [
      {
        from = 30000;
        to = 65535;
      }
    ];
  };
}
