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
      # The Fluent look-and-feel is patched in theme/fluent-kde.nix to use the
      # Win11 color scheme/icons, Breeze style, Bibata cursor and Kuro splash.
      # Applying it as a whole keeps the global theme coherent and avoids the
      # look-and-feel resetting individual components.
      lookAndFeel = "com.github.vinceliuice.Fluent-round-dark";

      # The image list is deliberately not managed: pick it once in Desktop
      # Settings -> Wallpaper -> Slideshow. Only the plugin and the interval are
      # declarative.
      wallpaperCustomPlugin = {
        plugin = "org.kde.slideshow";
        config.General = {
          SlideInterval = 24 * 60 * 60;
          FillMode = 2; # preserveAspectCrop
        };
      };
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
