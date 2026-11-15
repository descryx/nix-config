{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.kdePim;
in
{
  config = lib.mkIf cfg.enable {
    # akonadi + kdepim-runtime, which contains the Google Calendar resource.
    # System-wide so every user's Akonadi can find the agents.
    programs.kde-pim.enable = true;

    # The Digital Clock loads its calendar plugins from QT_PLUGIN_PATH, so this
    # cannot live in lena's home-manager profile. pimevents is the plugin that
    # surfaces Akonadi calendars in the clock.
    environment.systemPackages = [ pkgs.kdePackages.kdepim-addons ];
  };
}
