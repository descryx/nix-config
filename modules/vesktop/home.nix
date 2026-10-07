{
  config,
  local,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.vesktop ];

  xdg.configFile."vesktop/settings/settings.json" = {
    text = builtins.toJSON {
      autoUpdate = true;
      autoUpdateNotification = true;
      useQuickCss = true;
      themeLinks = [ ];
      eagerPatches = false;
      enabledThemes = [
        "mytheme.theme.css"
        "RadialStatus.theme.css"
        "modern-indicators.theme.css"
        "amoled-cord.theme.css"
      ];
      enableReactDevtools = false;
      frameless = true;
      transparent = true;
      winCtrlQ = false;
      disableMinSize = false;
      winNativeTitleBar = false;

      plugins = {
        ChatInputButtonAPI = {
          enabled = true;
        };
        CommandsAPI = {
          enabled = true;
        };
        DynamicImageModalAPI = {
          enabled = true;
        };
        MemberListDecoratorsAPI = {
          enabled = true;
        };
        MessageAccessoriesAPI = {
          enabled = true;
        };
        MessageDecorationsAPI = {
          enabled = true;
        };
        MessageEventsAPI = {
          enabled = true;
        };
        MessagePopoverAPI = {
          enabled = true;
        };
        UserSettingsAPI = {
          enabled = true;
        };
        AnonymiseFileNames = {
          enabled = true;
          anonymiseByDefault = true;
          method = 0;
          randomisedLength = 7;
        };
        BetterFolders = {
          enabled = true;
          sidebar = false;
          sidebarAnim = false;
          closeAllFolders = false;
          closeAllHomeButton = false;
          closeOthers = false;
          forceOpen = false;
          keepIcons = false;
          showFolderIcon = 1;
        };
        BetterSettings = {
          enabled = true;
          disableFade = true;
          organizeMenu = true;
          eagerLoad = true;
        };
        BiggerStreamPreview = {
          enabled = true;
        };
        CallTimer = {
          enabled = true;
          format = "stopwatch";
        };
        CharacterCounter = {
          enabled = true;
          colorEffects = true;
        };
        ClientTheme = {
          enabled = true;
          color = "000000";
        };
        CopyUserURLs = {
          enabled = true;
        };
        CrashHandler = {
          enabled = true;
          attemptToPreventCrashes = true;
          attemptToNavigateToHome = false;
        };
        DisableCallIdle = {
          enabled = true;
        };
        FakeNitro = {
          enabled = true;
          enableStickerBypass = true;
          enableStreamQualityBypass = true;
          enableEmojiBypass = true;
          transformEmojis = true;
          transformStickers = true;
          transformCompoundSentence = false;
          emojiSize = 48;
          stickerSize = 160;
          useHyperLinks = true;
          hyperLinkText = "{{NAME}}";
          disableEmbedPermissionCheck = true;
        };
        FakeProfileThemes = {
          enabled = true;
          nitroFirst = true;
        };
        FavoriteEmojiFirst = {
          enabled = true;
        };
        FavoriteGifSearch = {
          enabled = true;
          searchOption = "hostandpath";
        };
        FixImagesQuality = {
          enabled = true;
          originalImagesInChat = true;
        };
        FriendInvites = {
          enabled = true;
        };
        FriendsSince = {
          enabled = true;
        };
        ImageFilename = {
          enabled = true;
          showFullUrl = false;
        };
        ImageZoom = {
          enabled = true;
          saveZoomValues = true;
          invertScroll = true;
          nearestNeighbour = false;
          square = true;
          zoom = 1.6363636363636362;
          size = 235.06493506493507;
          zoomSpeed = 5;
        };
        LoadingQuotes = {
          enabled = true;
          replaceEvents = true;
          enablePluginPresetQuotes = false;
          enableDiscordPresetQuotes = false;
          additionalQuotes = "aaaaaa help";
          additionalQuotesDelimiter = "|";
        };
        MemberCount = {
          enabled = true;
          memberList = true;
          toolTip = true;
          voiceActivity = true;
        };
        MentionAvatars = {
          enabled = true;
          showAtSymbol = true;
        };
        MoreQuickReactions = {
          enabled = true;
          reactionCount = 5;
        };
        MutualGroupDMs = {
          enabled = true;
        };
        NotificationVolume = {
          enabled = true;
          notificationVolume = 25.27075812274368;
        };
        PermissionFreeWill = {
          enabled = true;
          lockout = true;
          onboarding = true;
        };
        petpet = {
          enabled = true;
        };
        PlatformIndicators = {
          enabled = true;
          list = true;
          badges = true;
          messages = true;
          colorMobileIndicator = true;
        };
        PreviewMessage = {
          enabled = true;
        };
        QuickMention = {
          enabled = true;
        };
        ShowHiddenChannels = {
          enabled = true;
          showMode = 0;
          hideUnreads = true;
          defaultAllowedUsersAndRolesDropdownState = true;
        };
        ShowHiddenThings = {
          enabled = true;
          showTimeouts = true;
          showInvitesPaused = true;
          showModView = true;
        };
        ShowMeYourName = {
          enabled = true;
          mode = "nick-user";
          friendNicknames = "dms";
          displayNames = false;
          inReplies = false;
        };
        SilentMessageToggle = {
          enabled = true;
          persistState = false;
          autoDisable = true;
        };
        SilentTyping = {
          enabled = true;
          isEnabled = true;
          showIcon = false;
          contextMenu = true;
        };
        SpotifyCrack = {
          enabled = true;
          noSpotifyAutoPause = true;
          keepSpotifyActivityOnIdle = false;
        };
        StartupTimings = {
          enabled = true;
        };
        TypingTweaks = {
          enabled = true;
          showAvatars = true;
          showRoleColors = true;
          alternativeFormatting = true;
        };
        UnlockedAvatarZoom = {
          enabled = true;
        };
        USRBG = {
          enabled = true;
          voiceBackground = true;
          nitroFirst = true;
        };
        VencordToolbox = {
          enabled = true;
          showPluginMenu = true;
        };
        ViewIcons = {
          enabled = true;
          format = "png";
          imgSize = "4096";
        };
        VoiceDownload = {
          enabled = true;
        };
        VoiceMessages = {
          enabled = true;
          noiseSuppression = true;
          echoCancellation = true;
        };
        VolumeBooster = {
          enabled = true;
          multiplier = 2;
        };
        WhoReacted = {
          enabled = true;
        };
        YoutubeAdblock = {
          enabled = true;
        };
        BadgeAPI = {
          enabled = true;
        };
        NoTrack = {
          enabled = true;
          disableAnalytics = true;
        };
        Settings = {
          enabled = true;
          settingsLocation = "aboveNitro";
          includeVencordInfoWhenCopying = true;
        };
        SupportHelper = {
          enabled = true;
        };
        WebKeybinds = {
          enabled = true;
        };
        WebScreenShareFixes = {
          enabled = true;
        };
        ConcatenatedComponentExtractor = {
          enabled = true;
        };
        DisableDeepLinks = {
          enabled = true;
        };
        WebContextMenus = {
          enabled = true;
        };
      };

      uiElements = {
        chatBarButtons = { };
        messagePopoverButtons = { };
      };

      notifications = {
        timeout = 5000;
        position = "bottom-right";
        useNative = "not-focused";
        logLimit = 50;
      };

      cloud = {
        authenticated = false;
        url = "https://api.vencord.dev/";
        settingsSync = false;
        settingsSyncVersion = 1779387730340;
      };
    };
    force = true;
  };

  home.file.".config/vesktop/themes".source =
    config.lib.file.mkOutOfStoreSymlink "${local.flakeDir}/modules/vesktop/config/themes";
}
