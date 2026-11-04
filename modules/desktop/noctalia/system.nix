{
  lib,
  config,
  ...
}:
let
  cfg = config.my.noctalia;
in
{
  # The collector is a root systemd unit, so it is a NixOS module and cannot
  # live in the loader's auto-imported name. Imported unconditionally on
  # purpose: read config.my.* here and evaluation recurses, so the toggle is
  # applied inside that file instead.
  imports = [ ./drive-health.nix ];

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
  };
}
