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
      undershell
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
      ".config/undershell".source = link "undershell";
    };

    systemd.user.services.undershell = {
      Unit = {
        Description = "undershell desktop widgets";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        # systemd must not start it before the compositor has put the Wayland
        # display into the user manager's environment.
        ConditionEnvironment = "WAYLAND_DISPLAY";
        # Deliberate host coupling, kept here on purpose: the unit is installed on
        # both hosts but only starts on the desktop (the t480 doesn't run the
        # widget stack). A host-specific home import would be cleaner but the repo
        # has no mechanism for one yet.
        ConditionHost = "desk";
      };
      Service = {
        ExecStart = "${pkgs.undershell}/bin/undershell";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
