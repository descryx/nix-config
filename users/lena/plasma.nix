_: {
  programs.plasma = {
    enable = true;

    input.keyboard = {
      layouts = [
        {
          layout = "de";
          displayName = "Ger";
        }
        {
          layout = "ru";
          displayName = "Rus";
        }
        {
          layout = "us";
          displayName = "Eng";
        }
      ];
      options = [ "grp:alt_shift_toggle" ];
    };

    workspace = {
      # The image list is deliberately not managed: pick it once in Desktop
      # Settings -> Wallpaper -> Slideshow. Only the plugin and the three-day
      # interval are declarative.
      wallpaperCustomPlugin = {
        plugin = "org.kde.slideshow";
        config.General = {
          SlideInterval = 3 * 24 * 60 * 60;
          FillMode = 2; # preserveAspectCrop
        };
      };
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
