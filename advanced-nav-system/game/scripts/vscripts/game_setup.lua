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

        GameMode:SetExecuteOrderFilter(Dynamic_Wrap(GameEventManager, "OrderFilter"), GameEventManager)
        self:LinkModifiers()
        self:RegisterCustomEvents()
    else --release build
        --put your rules here
    end

    ListenToGameEvent("npc_spawned", Dynamic_Wrap(GameEventManager, "OnNpcSpawned"), GameEventManager)
end

function GameSetup:LinkModifiers()
    LinkLuaModifier("modifier_bridge_crossing", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_static_object", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_nav_agent_speed", LUA_MODIFIER_MOTION_NONE)
end

function GameSetup:RegisterCustomEvents()
    CustomGameEventManager:RegisterListener("PanoramaClickPlatformEvent", function(...)
        return GameEventManager:OnPanoramaClickPlatformEvent(...)
    end)
    CustomGameEventManager:RegisterListener("PanoramaClickEvent", function(...)
        return GameEventManager:OnPanoramaClickEvent(...)
    end)
end
