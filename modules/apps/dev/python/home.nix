{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.local.python;
in
{
  # Single owner of the user's Python interpreter.
  #
  # Two different python derivations cannot both live in `home.packages`: e.g.
  # `python3` and `python3.withPackages [ pygobject3 ]` both ship `bin/python3`,
  # the files differ, and home-manager's profile buildEnv then aborts with a
  # collision. So instead of each feature adding its own interpreter, features
  # add Python packages here and one `withPackages` call builds the union.
  options.local.python.extensions = lib.mkOption {
    type = lib.types.listOf lib.types.package;
    default = [ ];
    description = "Extra Python packages merged into the user's python3 interpreter.";
  };

  config.home.packages = lib.mkIf osConfig.my.dev.enable [
    # `_` ignores the package set argument: extensions are expected to come from
    # the matching `pkgs.python3Packages`, so they already belong to this Python.
    (pkgs.python3.withPackages (_: cfg.extensions))
  ];
}
