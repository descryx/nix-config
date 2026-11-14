{
  pkgs,
  ...
}:
let
  win11 = pkgs.callPackage ./theme/win11os-kde.nix { };
  win11-icons = pkgs.callPackage ./theme/win11-icon-theme.nix { };
in
{
  # The look-and-feel package, its Plasma style, Aurorae decoration and color
  # scheme, plus the black/dark icon set. The names here are the ones the
  # plasma-manager settings reference.
  home.file = {
    ".local/share/plasma/look-and-feel/com.github.yeyushengfan258.Win11OS-dark" = {
      source = "${win11}/share/plasma/look-and-feel/com.github.yeyushengfan258.Win11OS-dark";
      force = true;
    };
    ".local/share/plasma/desktoptheme/Win11OS-dark" = {
      source = "${win11}/share/plasma/desktoptheme/Win11OS-dark";
      force = true;
    };
    ".local/share/aurorae/themes/Win11OS-dark" = {
      source = "${win11}/share/aurorae/themes/Win11OS-dark";
      force = true;
    };
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
  };
}
