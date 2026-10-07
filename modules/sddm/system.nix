{ pkgs, lib, ... }:
let
  sddm-astronaut =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "pixel_sakura_static";
      themeConfig = {
        #################### Background ####################
        Background = "Backgrounds/bg.png";
        # BackgroundPlaceholder = "";        # shown before video bg loads (video bg only)
        # BackgroundSpeed = "";               # video playback speed, 0.0-10.0
        # PauseBackground = "";                # freeze gif playback if true
        # DimBackground = "0.0";               # 0.0-1.0, darkens background
        # DimBackgroundColor = "#21222C";      # color of the dim overlay
        # CropBackground = "true";             # crop vs fit background image
        # BackgroundHorizontalAlignment = "center"; # left/center/right, needs CropBackground=false
        # BackgroundVerticalAlignment = "center";   # top/center/bottom, needs CropBackground=false

        #################### Text colors ####################
        HeaderTextColor = "#ffffff";
        DateTextColor = "#ff0000";
        TimeTextColor = "#ffffff";
        LoginFieldTextColor = "#ffffff";
        PasswordFieldTextColor = "#ffffff";
        PlaceholderTextColor = "#ff0000"; # "Username"/"Password" hint text
        WarningColor = "#ff66cc"; # e.g. wrong password message
        # HeaderText = "(҂⌣̀_⌣́)"; # optional custom text near clock

        #################### Field / button colors ####################
        LoginFieldBackgroundColor = "#000000";
        PasswordFieldBackgroundColor = "#000000";
        UserIconColor = "#ff0000";
        PasswordIconColor = "#ff0000";
        LoginButtonTextColor = "#ffffff";
        SystemButtonsIconsColor = "#ffffff";
        # FormBackgroundColor = "#21222C";      # form panel background (needs HaveFormBackground=true)
        # BackgroundColor = "#21222C";           # fallback solid color, shows if no image/video bg
        # LoginButtonBackgroundColor = "#3d495b";
        SessionButtonTextColor = "#ffffff"; # the "Session (Niri)" text at bottom
        # VirtualKeyboardButtonTextColor = "#3d495b";

        #################### Dropdown (session selector) ####################
        DropdownTextColor = "#ffffff";
        DropdownSelectedBackgroundColor = "#ff66cc";
        DropdownBackgroundColor = "#000000";

        #################### Highlight / selection state ####################
        # HighlightTextColor = "#bbbbbb";
        # HighlightBackgroundColor = "#3d495b";
        # HighlightBorderColor = "transparent";

        #################### Hover states ####################
        HoverUserIconColor = "#bb0000";
        HoverPasswordIconColor = "#bb0000";
        HoverSystemButtonsIconsColor = "#bb0000";
        HoverSessionButtonTextColor = "#bb0000";
        # HoverVirtualKeyboardButtonTextColor = "#697f90";

        #################### Layout / behavior (not colors) ####################
        Font = "Cascadia Code";
        FontSize = "10";
        Locale = "Europe/Berlin"; # date/time locale, leave blank for default
        # HourFormat = "HH:mm";
        # DateFormat = "dddd d";
        FormPosition = "left"; # left/center/right
        # HaveFormBackground = "false";         # form bg transparent if false
        HideVirtualKeyboard = "true";
        # HideSystemButtons = "true";
        HideLoginButton = "true";
        ForceLastUser = "true"; # auto-fill last logged-in username
        PasswordFocus = "true"; # auto-focus password field
        HideCompletePassword = "true"; # mask password while typing
      };
    }).overrideAttrs
      (oldAttrs: {
        installPhase = oldAttrs.installPhase + ''
          chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
          cp ${../../wallpapers/bg.png} \
            $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/bg.png
        '';
      });
in
{
  environment.systemPackages = [
    sddm-astronaut
  ];
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = "sddm-astronaut-theme";
    wayland.enable = true;
    extraPackages = [
      pkgs.kdePackages.qtmultimedia
    ];
  };
}
