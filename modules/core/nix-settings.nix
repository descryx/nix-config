{
  local,
  ...
}:
{
  nix.settings = {
    auto-optimise-store = true;
    # `cores` is the same on both machines, so it lives here. `max-jobs` is the
    # per-host cap and lives in hosts/<host>/default.nix.
    cores = 4;
    trusted-users = [
      "root"
      local.username
    ];
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [

  ];
}
