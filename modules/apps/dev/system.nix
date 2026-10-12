{ lib, ... }:
{
  # Covers both modules/apps/dev and modules/apps/dev/python: the python half is
  # the single interpreter owner and is only meaningful alongside dev.
  options.my.dev.enable = lib.mkEnableOption "the dev toolchain";
}
