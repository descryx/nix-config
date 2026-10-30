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
      monaspace # radon is good, xenon is "1980" like, krypton is futuristic
      inconsolata # this is cool, as in small/minimal glypths
      monocraft # minacreft
    ];
  };
}
