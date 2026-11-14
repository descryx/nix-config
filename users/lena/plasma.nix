{ pkgs, ... }: {
  programs.plasma = {
    enable = true;

    input.keyboard = {
      layouts = [
        {
          layout = "de";
          displayName = "German";
        }
        {
          layout = "ru";
          displayName = "Russian";
        }
        {
          layout = "us";
          displayName = "English (US)";
        }
      ];
      options = [ "grp:alt_shift_toggle" ];
    };

    workspace = {
      wallpaper = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/DarkestHour/contents/images/2560x1600.jpg";
      lookAndFeel = "com.github.yeyushengfan258.Win11OS-dark";
      iconTheme = "Win11-black-dark";
    };

    # Plasma reads its language from plasma-localerc, not from LANG inherited
    # through the shell. Both keys are needed: Formats for dates/numbers,
    # Translations for the UI strings.
    configFile."plasma-localerc" = {
      Formats.LANG = "de_DE.UTF-8";
      Translations.LANGUAGE = "de";
    };
  };
}
