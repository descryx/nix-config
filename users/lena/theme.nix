{
  pkgs,
  ...
}:
let
  win11 = pkgs.callPackage ./theme/win11os-kde.nix { };
  win11-icons = pkgs.callPackage ./theme/win11-icon-theme.nix { };
  kuro = pkgs.callPackage ./theme/kuro-splash.nix { };
  fluent = pkgs.callPackage ./theme/fluent-kde.nix { };
in
{
  home.packages = [ pkgs.bibata-cursors ];

  # Fluent Round Dark is the active global theme, but its look-and-feel
  # defaults are patched in fluent-kde.nix to use the Win11 color scheme and
  # icons, Breeze Plasma style, Bibata cursors and the Kuro OLED splash.
  home.file = {
    ".local/share/color-schemes/Win11OSDark.colors" = {
      source = "${win11}/share/color-schemes/Win11OSDark.colors";
      force = true;
    };
    ".local/share/icons/Win11-black" = {
      source = "${win11-icons}/share/icons/Win11-black";
      force = true;
    };
    ".local/share/icons/Win11-black-dark" = {
      source = "${win11-icons}/share/icons/Win11-black-dark";
      force = true;
    };
    ".local/share/plasma/look-and-feel/a2n.kuro.oled" = {
      source = "${kuro}/share/plasma/look-and-feel/a2n.kuro.oled";
      force = true;
    };
    ".local/share/plasma/look-and-feel/com.github.vinceliuice.Fluent-round-dark" = {
      source = "${fluent}/share/plasma/look-and-feel/com.github.vinceliuice.Fluent-round-dark";
      force = true;
    };
    ".local/share/aurorae/themes/Fluent-round-dark" = {
      source = "${fluent}/share/aurorae/themes/Fluent-round-dark";
      force = true;
    };
  };
}
