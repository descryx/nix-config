{
  lib,
  config,
  ...
}:
let
  cfg = config.my.gaming;
in
{

  config = lib.mkIf cfg.enable {
    programs = {
      steam.enable = true;

      # gamemode: auto-tunes CPU governor & GPU for gaming performance.
      # Use with launch option: gamemoderun %command%
      gamemode = {
        enable = true;
        settings.general.renice = 10;
      };
    };
  };
}
