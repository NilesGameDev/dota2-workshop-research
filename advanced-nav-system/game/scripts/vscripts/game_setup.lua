if (GameSetup == nil) then
    GameSetup = class({})
end

require("game_event")

--nil will not force a hero selection
local forceHero = "antimage"

function GameSetup:init()
    if IsInToolsMode() then --debug build
        --skip all the starting game mode stages e.g picking screen, showcase, etc
        GameRules:EnableCustomGameSetupAutoLaunch(true)
        GameRules:SetCustomGameSetupAutoLaunchDelay(0)
        GameRules:SetHeroSelectionTime(0)
        GameRules:SetStrategyTime(0)
        GameRules:SetPreGameTime(0)
        GameRules:SetShowcaseTime(0)
        GameRules:SetPostGameTime(0)

        --disable some setting which are annoying then testing
        local GameMode = GameRules:GetGameModeEntity()
        GameMode:SetAnnouncerDisabled(true)
        GameMode:SetKillingSpreeAnnouncerDisabled(true)
        GameMode:SetDaynightCycleDisabled(true)
        GameMode:DisableHudFlip(true)
        GameMode:SetDeathOverlayDisabled(true)
        GameMode:SetWeatherEffectsDisabled(true)

        --disable music events
        GameRules:SetCustomGameAllowHeroPickMusic(false)
        GameRules:SetCustomGameAllowMusicAtGameStart(false)
        GameRules:SetCustomGameAllowBattleMusic(false)

        --multiple players can pick the same hero
        GameRules:SetSameHeroSelectionEnabled(true)

        --force single hero selection (optional)
        if forceHero ~= nil then
            GameMode:SetCustomGameForceHero(forceHero)
        end

        GameMode:SetExecuteOrderFilter(Dynamic_Wrap(GameEventManager, "OnFilterGame"), self)

        --link modifiers
        self:LinkModifiers()

        --register custom events
        self:RegisterCustomEvents()
    else --release build
        --put your rules here
    end

    ListenToGameEvent("npc_spawned", Dynamic_Wrap(GameEventManager, "OnNpcSpawned"), GameEventManager)
    ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(GameEventManager, "OnNpcGoalReached"), GameEventManager)
    ListenToGameEvent("map_location_updated", Dynamic_Wrap(GameEventManager, "OnMapLocationUpdated"), GameEventManager)
    ListenToGameEvent("round_start_post_nav", Dynamic_Wrap(GameEventManager, "OnRoundStartPostNav"), GameEventManager)
    ListenToGameEvent("instructor_server_hint_create", Dynamic_Wrap(GameEventManager, "OnInstructorServerHintCreated"), GameEventManager)
    ListenToGameEvent("server_cvar", Dynamic_Wrap(GameEventManager, "OnServerCvarChanged"), GameEventManager)
    ListenToGameEvent("server_message", Dynamic_Wrap(GameEventManager, "OnServerMessage"), GameEventManager)
    ListenToGameEvent("server_spawn", Dynamic_Wrap(GameEventManager, "OnServerSpawn"), GameEventManager)
    ListenToGameEvent("game_newmap", Dynamic_Wrap(GameEventManager, "OnGameNewMap"), GameEventManager)

    local test = {}
    EntityFramework:CreateEntity("CBaseEntity", test)
    DeepPrintTable(test)
end

function GameSetup:LinkModifiers()
    LinkLuaModifier("modifier_bridge_crossing", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_static_object", LUA_MODIFIER_MOTION_NONE)
end

function GameSetup:RegisterCustomEvents()
    CustomGameEventManager:RegisterListener("PanoramaClickPlatformEvent", function(...)
        return GameEventManager:OnPanoramaClickPlatformEvent(...)
    end)
    CustomGameEventManager:RegisterListener("PanoramaClickEvent", function(...)
        return GameEventManager:OnPanoramaClickEvent(...)
    end)
end
