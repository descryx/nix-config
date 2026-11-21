{
  config,
  osConfig,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Per-user Zen package. The default is the shared flake input, so both users
  # get the same derivation and one build serves every host. A user can still
  # override it with a different package without touching the other user.
  options.my.zen.package = lib.mkOption {
    type = lib.types.package;
    default = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    description = "Zen browser package for this user.";
  };

  config = lib.mkIf osConfig.my.zen.enable {
    home.packages = [ config.my.zen.package ];
  };
}
