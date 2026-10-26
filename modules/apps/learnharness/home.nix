{
  osConfig,
  pkgs,
  lib,
  ...
}:
{
  config = lib.mkIf osConfig.my.learnharness.enable {
    home.packages = [ pkgs.learnharness ];

    # appimageTools.wrapType2 produces a launcher, not desktop assets: without
    # this entry the app never shows up in the launcher or the app grid. The
    # icon is copied out of the AppImage by package.nix.
    xdg.desktopEntries.learnharness = {
      name = "LearnHarness";
      genericName = "Learning agent";
      comment = "Agent harness for learning difficult things";
      exec = "learnharness";
      icon = "${pkgs.learnharness}/share/icons/hicolor/512x512/apps/learnharness.png";
      categories = [ "Education" ];
      terminal = false;
      # Matches the WM_CLASS the Electron shell sets (upstream ships the same).
      settings.StartupWMClass = "learnharness";
    };
  };
}
