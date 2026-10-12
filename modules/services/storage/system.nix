{
  lib,
  config,
  ...
}:
let
  cfg = config.my.storage;
in
{
  options.my.storage.enable = lib.mkEnableOption "storage services (tumbler, udisks2, gvfs)";

  config = lib.mkIf cfg.enable {
    services = {
      tumbler.enable = true;
      udisks2.enable = true;
      gvfs.enable = true;
    };
  };
}
