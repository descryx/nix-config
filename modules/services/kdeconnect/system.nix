{
  config,
  lib,
  ...
}:
let
  cfg = config.my.kdeconnect;
in
{
  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}
