{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.obs;
in
{

  config = lib.mkIf cfg.enable {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [ obs-pipewire-audio-capture ];
    };
  };
}
