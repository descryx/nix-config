_: {
  # cava config is Nix-managed; the Noctalia theme is left to Noctalia, which
  # writes it to the real ~/.config/cava/themes/ at runtime (live).
  programs.cava = {
    enable = true;
    settings = {
      general = {
        framerate = 240;
        bars = 0;
        bar_width = 1;
        bar_spacing = 1;
      };
      output.orientation = "bottom";
      color.theme = ''"noctalia"'';
      smoothing.noise_reduction = 67;
      eq = {
        "1" = 1;
        "2" = 1;
        "3" = 2;
        "4" = 3;
        "5" = 3;
        "6" = 3;
        "7" = 3;
      };
    };
  };
}
