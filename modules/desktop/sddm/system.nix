{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.sddm;
  # Keep the configured file's extension so SDDM's image loader picks the right
  # decoder (png or jpg). Both hosts default to bg.png; lena uses a jpg.
  bgName = baseNameOf (toString cfg.wallpaper);
  sddm-astronaut =
    (pkgs.sddm-astronaut.override {
      embeddedTheme = "pixel_sakura_static";
      themeConfig = {
        #################### Background ####################
        Background = "Backgrounds/${bgName}";
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
        ForceLastUser = lib.boolToString cfg.forceLastUser; # auto-fill last logged-in username
        PasswordFocus = "true"; # auto-focus password field
        HideCompletePassword = "true"; # mask password while typing
      };
    }).overrideAttrs
      (oldAttrs: {
        installPhase = oldAttrs.installPhase + ''
                    chmod u+w $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/
                    cp ${cfg.wallpaper} \
                      $out/share/sddm/themes/sddm-astronaut-theme/Backgrounds/${bgName}

                    # The package copies directly from $src, so patch the installed QML.
                    # SDDM's SessionModel NameRole is Qt.UserRole + 4 (SessionModel.h).
                    # Pick the configured session by name and fall back to index 0, which
                    # keeps the Vivobook (Plasma only) working unchanged.
                    substituteInPlace $out/share/sddm/themes/sddm-astronaut-theme/Components/SessionButton.qml \
                      --replace-fail "currentIndex: model.lastIndex" "currentIndex: {
              for (var i = 0; i < sessionModel.count; ++i) {
                  if (sessionModel.data(sessionModel.index(i, 0), Qt.UserRole + 4) === \"${cfg.preselectSession}\")
                      return i;
              }
              return 0;
          }"
                    substituteInPlace $out/share/sddm/themes/sddm-astronaut-theme/Components/Input.qml \
                      --replace-fail "currentIndex: model.lastIndex" "currentIndex: 0"
        '';
      });
in
{

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      sddm-astronaut
    ];
    services.displayManager.sddm = {
      enable = true;
      package = lib.mkDefault pkgs.kdePackages.sddm;
      theme = "sddm-astronaut-theme";
      wayland.enable = true;
      # X11 greeter only: SDDM 0.21's Wayland keyboard backend is a no-op.
      # KWin reads [Keyboard] NumLock from the sddm user's kcminputrc instead,
      # hence the sddm-numlock unit below.
      autoNumlock = true;
      extraPackages = [
        pkgs.kdePackages.qtmultimedia
      ];
    };

    # SDDM 0.21 ignores [General] Numlock on the Wayland greeter. With Plasma
    # the greeter runs KWin, which applies [Keyboard] NumLock from the sddm
    # user's kcminputrc at startup (0 = on, 1 = off, 2 = unchanged). Write that
    # key before the display manager starts; kwriteconfig6 keeps whatever else
    # is in the file. Gated on KDE because a Weston greeter never reads it.
    systemd.services.sddm-numlock = lib.mkIf config.my.kde.enable {
      description = "Enable NumLock in the SDDM greeter (KWin)";
      wantedBy = [ "graphical.target" ];
      before = [ "display-manager.service" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "sddm";
        Group = "sddm";
        ExecStartPre = "${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/sddm/.config";
        ExecStart = "${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file /var/lib/sddm/.config/kcminputrc --group Keyboard --key NumLock 0";
      };
    };
  };
}
