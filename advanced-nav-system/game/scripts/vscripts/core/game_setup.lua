if (GameSetup == nil) then
    GameSetup = class({})
end

require("events.game_event")
require("apputils.navmesh_debug")

--nil will not force a hero selection
local forceHero = "antimage"

function GameSetup:init()
    if IsInToolsMode() then --debug build
        --skip all the starting game mode stages e.g picking screen, showcase, etc
        GameRules:EnableCustomGameSetupAutoLaunch(true)
        -- GameRules:SetCustomGameSetupAutoLaunchDelay(0)
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

        self:LinkModifiers()
        self:RegisterCustomEvents()
        self:RegisterListeners()
    else --release build
        --put your rules here
    end
end

function GameSetup:LinkModifiers()
    LinkLuaModifier("modifier_bridge_crossing", "modifiers/modifier_bridge_crossing.lua", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_static_object", "modifiers/modifier_static_object.lua", LUA_MODIFIER_MOTION_NONE)
end

function GameSetup:RegisterCustomEvents()
    ListenToGameEvent("player_spawn", Dynamic_Wrap(GameEventManager, "OnPlayerSpawned"), GameEventManager)
    ListenToGameEvent("npc_spawned", Dynamic_Wrap(GameEventManager, "OnNpcSpawned"), GameEventManager)
end

function GameSetup:RegisterListeners()
    CustomGameEventManager:RegisterListener("PanoramaClickPlatformEvent", function(...)
        return GameEventManager:OnPanoramaClickPlatformEvent(...)
    end)
    CustomGameEventManager:RegisterListener("PanoramaClickEvent", function(...)
        return GameEventManager:OnPanoramaClickEvent(...)
    end)
end