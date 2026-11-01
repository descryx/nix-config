{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.appearance;
in
{

  config = lib.mkIf cfg.enable {
    fonts.packages = with pkgs; [
      cascadia-code # fav
      fira-code
      geist-font
      monaspace
      inconsolata
      monocraft
      iosevka
    ];
  };
}
