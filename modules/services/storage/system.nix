{
  lib,
  config,
  ...
}:
let
  cfg = config.my.storage;
in
{

  config = lib.mkIf cfg.enable {
    services = {
      tumbler.enable = true;
      udisks2.enable = true;
      gvfs.enable = true;
    };
  };
}
