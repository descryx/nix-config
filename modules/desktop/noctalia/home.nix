{
  config,
  local,
  inputs,
  osConfig,
  pkgs,
  lib,
  ...
}:
let
  link =
    path:
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/desktop/noctalia/config/${path}";
in
{
  config = lib.mkIf osConfig.my.noctalia.enable {
    home.packages = with pkgs; [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      cliphist

      ### Noctalia & Script dependencies ###
      # Screen Toolkit #
      slurp
      grim
      hyprpicker
      tesseract
      zbar
      jq
      ffmpeg
      bc
      wl-screenrec
      wf-recorder
      satty
      swappy
      translate-shell
      wl-mirror # screen mirror
      nix-search-tv # nix search
      scrcpy
      android-tools
      sshfs
      glib

      libnotify

      playerctl
      wlrctl
      localsend-controller
      zenity

      # -------------------------------------------
    ];

    home.file = {
      ".config/noctalia".source = link "noctalia";
    };
  };
}
