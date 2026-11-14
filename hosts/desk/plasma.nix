{ pkgs, lib, ... }:
{
  # Plasma is enabled on desk so lena's session can be tested here. These pins
  # keep descryx's niri session and the existing greeter as they are today.
  services = {
    displayManager.defaultSession = "niri";
    displayManager.sddm = {
      wayland.compositor = "weston";
      settings.General = {
        RememberLastSession = false;
        RememberLastUser = false;
      };
    };
    fwupd.enable = false;
  };
  my.sddm.forceLastUser = false;

  # plasma6 mkDefaults the Noto fonts; keep exactly the owner's current fallback
  # fonts. The option merges lists, so force each key instead of appending.
  fonts.fontconfig.defaultFonts = {
    sansSerif = lib.mkForce [ "DejaVu Sans" ];
    serif = lib.mkForce [ "DejaVu Serif" ];
    monospace = lib.mkForce [ "DejaVu Sans Mono" ];
    emoji = lib.mkForce [ "Noto Color Emoji" ];
  };

  # plasma6 also switches these defaults; pin them back for the shared host.
  programs.gnupg.agent.pinentryPackage = pkgs.pinentry-curses;

  # lena needs the German locale on the shared desk, but the system default and
  # the owner's session must stay en_US.UTF-8.
  i18n.extraLocales = [ "de_DE.UTF-8/UTF-8" ];
}
