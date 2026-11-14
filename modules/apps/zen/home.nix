{
  config,
  osConfig,
  pkgs,
  inputs,
  lib,
  ...
}:
{
  # Per-user Zen package. The default is the input the owner uses; a user can
  # override it with a pinned input without changing the other user's browser.
  options.my.zen.package = lib.mkOption {
    type = lib.types.package;
    default = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
    description = "Zen browser package for this user.";
  };

  config = lib.mkIf osConfig.my.zen.enable {
    home.packages = [ config.my.zen.package ];
  };
}
