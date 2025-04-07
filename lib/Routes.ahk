class Routes {
    static applicationRoleConnectionMetadata(applicationId) => "/applications/" . applicationId . "/role-connections/metadata"
    static guildAutoModerationRules(guildId) => "/guilds/" . guildId . "/auto-moderation/rules"
    static guildAutoModerationRule(guildId, ruleId) => "/guilds/" . guildId . "/auto-moderation/rules/" . ruleId
    static guildAuditLog(guildId) => "/guilds/" . guildId . "/audit-logs"
    static channel(channelId) => "/channels/" . channelId
    static channelMessages(channelId) => "/channels/" . channelId . "/messages"
    static channelMessage(channelId, messageId) => "/channels/" . channelId . "/messages/" . messageId
    static channelMessageCrosspost(channelId, messageId) => "/channels/" . channelId . "/messages/" . messageId . "/crosspost"
    static channelMessageOwnReaction(channelId, messageId, emoji) => "/channels/" . channelId . "/messages/" . messageId . "/reactions/" . emoji . "/@me"
    static channelMessageUserReaction(channelId, messageId, emoji, userId) => "/channels/" . channelId . "/messages/" . messageId . "/reactions/" . emoji . "/" . userId
    static channelMessageReaction(channelId, messageId, emoji) => "/channels/" . channelId . "/messages/" . messageId . "/reactions/" . emoji
    static channelMessageAllReactions(channelId, messageId) => "/channels/" . channelId . "/messages/" . messageId . "/reactions"
    static channelBulkDelete(channelId) => "/channels/" . channelId . "/messages/bulk-delete"
    static channelPermission(channelId, overwriteId) => "/channels/" . channelId . "/permissions/" . overwriteId
    static channelInvites(channelId) => "/channels/" . channelId . "/invites"
    static channelFollowers(channelId) => "/channels/" . channelId . "/followers"
    static channelTyping(channelId) => "/channels/" . channelId . "/typing"
    static channelPins(channelId) => "/channels/" . channelId . "/pins"
    static channelPin(channelId, messageId) => "/channels/" . channelId . "/pins/" . messageId
    static channelRecipient(channelId, userId) => "/channels/" . channelId . "/recipients/" . userId
    static guildEmojis(guildId) => "/guilds/" . guildId . "/emojis"
    static guildEmoji(guildId, emojiId) => "/guilds/" . guildId . "/emojis/" . emojiId
    static guilds() => "/guilds"
    static guild(guildId) => "/guilds/" . guildId
    static guildPreview(guildId) => "/guilds/" . guildId . "/preview"
    static guildChannels(guildId) => "/guilds/" . guildId . "/channels"
    static guildMember(guildId, userId := "@me") => "/guilds/" . guildId . "/members/" . userId
    static guildMembers(guildId) => "/guilds/" . guildId . "/members"
    static guildMembersSearch(guildId) => "/guilds/" . guildId . "/members/search"
    static guildCurrentMemberNickname(guildId) => "/guilds/" . guildId . "/members/@me/nick"
    static guildMemberRole(guildId, memberId, roleId) => "/guilds/" . guildId . "/members/" . memberId . "/roles/" . roleId
    static guildMFA(guildId) => "/guilds/" . guildId . "/mfa"
    static guildBans(guildId) => "/guilds/" . guildId . "/bans"
    static guildBan(guildId, userId) => "/guilds/" . guildId . "/bans/" . userId
    static guildRoles(guildId) => "/guilds/" . guildId . "/roles"
    static guildRole(guildId, roleId) => "/guilds/" . guildId . "/roles/" . roleId
    static guildPrune(guildId) => "/guilds/" . guildId . "/prune"
    static guildVoiceRegions(guildId) => "/guilds/" . guildId . "/regions"
    static guildInvites(guildId) => "/guilds/" . guildId . "/invites"
    static guildIntegrations(guildId) => "/guilds/" . guildId . "/integrations"
    static guildIntegration(guildId, integrationId) => "/guilds/" . guildId . "/integrations/" . integrationId
    static guildWidgetSettings(guildId) => "/guilds/" . guildId . "/widget"
    static guildWidgetJSON(guildId) => "/guilds/" . guildId . "/widget.json"
    static guildVanityUrl(guildId) => "/guilds/" . guildId . "/vanity-url"
    static guildWidgetImage(guildId) => "/guilds/" . guildId . "/widget.png"
    static invite(code) => "/invites/" . code
    static template(code) => "/guilds/templates/" . code
    static guildTemplates(guildId) => "/guilds/" . guildId . "/templates"
    static guildTemplate(guildId, code) => "/guilds/" . guildId . "/templates/" . code
    static pollAnswerVoters(channelId, messageId, answerId) => "/channels/" . channelId . "/polls/" . messageId . "/answers/" . answerId
    static expirePoll(channelId, messageId) => "/channels/" . channelId . "/polls/" . messageId . "/expire"
    static threads(parentId, messageId := "") {
        if (messageId)
            return "/channels/" . parentId . "/messages/" . messageId . "/threads"
        return "/channels/" . parentId . "/threads"
    }
    static guildActiveThreads(guildId) => "/guilds/" . guildId . "/threads/active"
    static channelThreads(channelId, archivedStatus) => "/channels/" . channelId . "/threads/archived/" . archivedStatus
    static channelJoinedArchivedThreads(channelId) => "/channels/" . channelId . "/users/@me/threads/archived/private"
    static threadMembers(threadId, userId := "") {
        if (userId)
            return "/channels/" . threadId . "/thread-members/" . userId
        return "/channels/" . threadId . "/thread-members"
    }
    static user(userId := "@me") => "/users/" . userId
    static userApplicationRoleConnection(applicationId) => "/users/@me/applications/" . applicationId . "/role-connection"
    static userGuilds() => "/users/@me/guilds"
    static userGuildMember(guildId) => "/users/@me/guilds/" . guildId . "/member"
    static userGuild(guildId) => "/users/@me/guilds/" . guildId
    static userChannels() => "/users/@me/channels"
    static userConnections() => "/users/@me/connections"
    static voiceRegions() => "/voice/regions"
    static channelWebhooks(channelId) => "/channels/" . channelId . "/webhooks"
    static guildWebhooks(guildId) => "/guilds/" . guildId . "/webhooks"
    static webhook(webhookId, webhookToken := "") {
        if (webhookToken)
            return "/webhooks/" . webhookId . "/" . webhookToken
        return "/webhooks/" . webhookId
    }
    static webhookMessage(webhookId, webhookToken, messageId := "@original") => "/webhooks/" . webhookId . "/" . webhookToken . "/messages/" . messageId
    static webhookPlatform(webhookId, webhookToken, platform) => "/webhooks/" . webhookId . "/" . webhookToken . "/" . platform
    static gateway() => "/gateway"
    static gatewayBot() => "/gateway/bot"
    static oauth2CurrentApplication() => "/oauth2/applications/@me"
    static oauth2CurrentAuthorization() => "/oauth2/@me"
    static oauth2Authorization() => "/oauth2/authorize"
    static oauth2TokenExchange() => "/oauth2/token"
    static oauth2TokenRevocation() => "/oauth2/token/revoke"
    static applicationCommands(applicationId) => "/applications/" . applicationId . "/commands"
    static applicationCommand(applicationId, commandId) => "/applications/" . applicationId . "/commands/" . commandId
    static applicationGuildCommands(applicationId, guildId) => "/applications/" . applicationId . "/guilds/" . guildId . "/commands"
    static applicationGuildCommand(applicationId, guildId, commandId) => "/applications/" . applicationId . "/guilds/" . guildId . "/commands/" . commandId
    static interactionCallback(interactionId, interactionToken) => "/interactions/" . interactionId . "/" . interactionToken . "/callback"
    static guildMemberVerification(guildId) => "/guilds/" . guildId . "/member-verification"
    static guildVoiceState(guildId, userId := "@me") => "/guilds/" . guildId . "/voice-states/" . userId
    static guildApplicationCommandsPermissions(applicationId, guildId) => "/applications/" . applicationId . "/guilds/" . guildId . "/commands/permissions"
    static applicationCommandPermissions(applicationId, guildId, commandId) => "/applications/" . applicationId . "/guilds/" . guildId . "/commands/" . commandId . "/permissions"
    static guildWelcomeScreen(guildId) => "/guilds/" . guildId . "/welcome-screen"
    static stageInstances() => "/stage-instances"
    static stageInstance(channelId) => "/stage-instances/" . channelId
    static sticker(stickerId) => "/stickers/" . stickerId
    static stickerPacks() => "/sticker-packs"
    static stickerPack(packId) => "/sticker-packs/" . packId
    static nitroStickerPacks() => "/sticker-packs"
    static guildStickers(guildId) => "/guilds/" . guildId . "/stickers"
    static guildSticker(guildId, stickerId) => "/guilds/" . guildId . "/stickers/" . stickerId
    static guildScheduledEvents(guildId) => "/guilds/" . guildId . "/scheduled-events"
    static guildScheduledEvent(guildId, guildScheduledEventId) => "/guilds/" . guildId . "/scheduled-events/" . guildScheduledEventId
    static guildScheduledEventUsers(guildId, guildScheduledEventId) => "/guilds/" . guildId . "/scheduled-events/" . guildScheduledEventId . "/users"
    static guildOnboarding(guildId) => "/guilds/" . guildId . "/onboarding"
    static guildIncidentActions(guildId) => "/guilds/" . guildId . "/incident-actions"
    static currentApplication() => "/applications/@me"
    static entitlements(applicationId) => "/applications/" . applicationId . "/entitlements"
    static entitlement(applicationId, entitlementId) => "/applications/" . applicationId . "/entitlements/" . entitlementId
    static skus(applicationId) => "/applications/" . applicationId . "/skus"
    static guildBulkBan(guildId) => "/guilds/" . guildId . "/bulk-ban"
    static consumeEntitlement(applicationId, entitlementId) => "/applications/" . applicationId . "/entitlements/" . entitlementId . "/consume"
    static applicationEmojis(applicationId) => "/applications/" . applicationId . "/emojis"
    static applicationEmoji(applicationId, emojiId) => "/applications/" . applicationId . "/emojis/" . emojiId
    static skuSubscriptions(skuId) => "/skus/" . skuId . "/subscriptions"
    static skuSubscription(skuId, subscriptionId) => "/skus/" . skuId . "/subscriptions/" . subscriptionId
    static sendSoundboardSound(channelId) => "/channels/" . channelId . "/send-soundboard-sound"
    static soundboardDefaultSounds() => "/soundboard-default-sounds"
    static guildSoundboardSounds(guildId) => "/guilds/" . guildId . "/soundboard-sounds"
    static guildSoundboardSound(guildId, soundId) => "/guilds/" . guildId . "/soundboard-sounds/" . soundId
}