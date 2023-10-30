if (GameSetup == nil) then
    GameSetup = class({})
end

--nil will not force a hero selection
local forceHero = "phantom_assassin"

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
    else --release build
        --put your rules here
    end
end
