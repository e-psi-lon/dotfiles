{
  programs.nixcord = {
    enable = true;
    discord = {
      enable = true;
      vencord.enable = true;
    };
    openASAR.enable = true;
    quickCss = builtins.readFile ../resources/discord/quickCss.css;
    vesktop = {
      enable = true;
      autoscroll.enable = true;
    };

    config = {
      useQuickCss = true;
      notifyAboutUpdates = true;
      themeLinks = [
        "https://discord-themes.com/api/83"
        "https://discord-themes.com/api/67"
        "https://discord-themes.com/api/63"
        "https://discord-themes.com/api/14"
        "https://discord-themes.com/api/58"
        "https://discord-themes.com/api/23"
        "https://raw.githubusercontent.com/DiscordStyles/RadialStatus/deploy/RadialStatus.theme.css"
      ];
      disableMinSize = true;
      plugins = {
        webRichPresence.enable = true;
        betterSessions = {
          enable = true;
          backgroundCheck = true;
        };
        betterUploadButton.enable = true;
        callTimer.enable = true;
        consoleShortcuts.enable = true;
        copyFileContents.enable = true;
        crashHandler.enable = true;
        experiments.enable = true;
        f8Break.enable = true;
        fakeNitro.enable = true;
        fixCodeblockGap.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        gameActivityToggle.enable = true;
        iLoveSpam.enable = true;
        implicitRelationships.enable = true;
        memberCount.enable = true;
        messageLatency.enable = true;
        messageLogger = {
          enable = true;
          ignoreBots = true;
          ignoreSelf = true;
        };
        # moreCommands.enable = true;
        # moreUserTags = {
        #  enable = true;
        # extraConfig = {
        #  WEBHOOK = {
        #    text = "Webhook";
        #    showInChat = true;
        #    showInNotChat = true;
        #  };
        #  OWNER = {
        #    text = "Owner";
        #    showInChat = false;
        #    showInNotChat = true;
        #  };
        #  ADMINISTRATOR = {
        #    text = "Admin";
        #    showInChat = false;
        #    showInNotChat = true;
        #  };
        #  MODERATOR_STAFF = {
        #    text = "Staff";
        #    showInChat = false;
        #    showInNotChat = true;
        #  };
        #  MODERATOR = {
        #    text = "Mod";
        #    showInChat = false;
        #    showInNotChat = true;
        #  };
        #  VOICE_MODERATOR = {
        #    text = "VC Mod";
        #    showInChat = false;
        #    showInNotChat = true;
        #  };
        #  CHAT_MODERATOR = {
        #    text = "Chat Mod";
        #    showInChat = false;
        #    showInNotChat = true;
        #  };
        # };
        # };
        MutualGroupDMs.enable = true;
        CustomRPC.enable = true;
        noDevtoolsWarning.enable = true;
        noOnboardingDelay.enable = true;
        noReplyMention.enable = true;
        noUnblockToJump.enable = true;
        openInApp.enable = true;
        pauseInvitesForever.enable = true;
        pictureInPicture.enable = true;
        PinDMs.enable = true;
        platformIndicators = {
          enable = true;
          messages = false;
        };
        replyTimestamp.enable = true;
        revealAllSpoilers.enable = true;
        reverseImageSearch.enable = true;
        sendTimestamps.enable = true;
        serverInfo.enable = true;
        serverListIndicators = {
          enable = true;
          mode = 3;
        };
        showHiddenChannels = {
          enable = true;
          defaultAllowedUsersAndRolesDropdownState = true;
        };
        showHiddenThings.enable = true;
        showTimeoutDuration.enable = true;
        sortFriendRequests = {
          enable = true;
          showDates = true;
        };
        whoReacted.enable = true;
        summaries.enable = true;
        webContextMenus.enable = true;
        userVoiceShow.enable = true;
        fixSpotifyEmbeds.enable = true;
        fixYoutubeEmbeds.enable = true;
        vencordToolbox.enable = true;
        viewIcons.enable = true;
        viewRaw.enable = true;
        spotifyControls.enable = true;
        spotifyCrack.enable = true;
        spotifyShareCommands.enable = true;
        startupTimings.enable = true;
        stickerPaste.enable = true;
        themeAttributes.enable = true;
        translate = {
          enable = true;
          # service = "deepl"; # TODO: Get API key for DeepL
          # deeplApiKey = "";
          target = "en";
        };
        unlockedAvatarZoom.enable = true;
        unsuppressEmbeds.enable = true;
        fakeProfileThemes.enable = true;
        validReply.enable = true;
        validUser.enable = true;
        voiceChatDoubleClick.enable = true;
        voiceDownload.enable = true;
        voiceMessages.enable = true;
        volumeBooster.enable = true;
        webKeybinds.enable = true;
        webScreenShareFixes.enable = true;
        youtubeAdblock.enable = true;
        disableDeepLinks.enable = true;
        fullSearchContext.enable = true;
        shikiCodeblocks = {
          enable = true;
          theme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/bc5436518111d87ea58eb56d97b3f9bec30e6b83/packages/tm-themes/themes/one-dark-pro.json";
        };
      };
    };
  };
}
