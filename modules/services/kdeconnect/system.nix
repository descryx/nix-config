{
  config,
  lib,
  ...
}:
let
  cfg = config.my.kdeconnect;
in
{
  options.my.kdeconnect.enable = lib.mkEnableOption "kdeconnect";
  config = lib.mkIf cfg.enable {
    programs.kdeconnect.enable = true;
  };
}
