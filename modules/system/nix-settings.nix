{
  local,
  ...
}:
{
  nix.settings = {
    auto-optimise-store = true;
    # Build parallelism (`max-jobs`/`cores`) is set per host in
    # hosts/<host>/nix-settings.nix, since it depends on the machine's cores/RAM.
    trusted-users = [
      "root"
      local.username
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://noctalia.cachix.org"
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    extra-trusted-public-keys = [
      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [

  ];
}
