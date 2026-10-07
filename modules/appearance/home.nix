{ pkgs, ... }:

let
  yamis = pkgs.yamis-icon-theme;
  # Must match the directory name produced by the derivation, which must in turn
  # match `Name` in index.theme.
  iconThemeName = "yet-another-monochrome-icon-set";
in
{
  gtk = {
    enable = true;
    cursorTheme = {
      name = "Bibata-Original-Classic";
      size = 16;
      package = pkgs.bibata-cursors;
    };
    font = {
      name = "Cascadia Code";
      size = 10;
    };
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    # The derivation rewrites YAMIS' Inherits to hicolor alone, so icons YAMIS does
    # not ship resolve to a placeholder instead of a coloured icon from some other
    # theme clashing with the monochrome set.
    iconTheme = {
      name = iconThemeName;
      package = yamis;
    };
  };

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    x11.enable = true;
    name = "Bibata-Original-Classic";
    size = 16;
    package = pkgs.bibata-cursors;
  };
}
