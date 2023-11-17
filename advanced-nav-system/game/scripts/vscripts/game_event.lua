if (GameEventManager == nil) then
    GameEventManager = class({})
end

require("pathing.advanced_nav_system")

function GameEventManager:OnPanoramaClickPlatformEvent(eventSrcIndex, args)
    print("Event received! Event source index: " .. eventSrcIndex)
    local hero = EntIndexToHScript(args["HeroId"])
    local bridgeEnt = EntIndexToHScript(args["BridgeIndex"])
    AdvancedNavSystem:MoveToPlatform(hero, bridgeEnt)
end

function GameEventManager:OnPanoramaClickEvent(eventSrcIndex, args)
    local hero = EntIndexToHScript(args["HeroId"])
    local targetPointRaw = args["TargetPoint"]
    local x = targetPointRaw["0"];
    local y = targetPointRaw["1"];
    local z = targetPointRaw["2"];
    local targetPoint = Vector(x, y, z)

    local cursorFX = ParticleManager:CreateParticleForPlayer("particles/ui_mouseactions/clicked_occlusion_rings.vpcf",
        PATTACH_CUSTOMORIGIN, nil, hero:GetPlayerOwner())
    ParticleManager:SetParticleControl(cursorFX, 0, targetPoint)
    ParticleManager:ReleaseParticleIndex(cursorFX)

    GameRules.AdvancedNavSystem:SetTargetPoint(targetPoint)
end

function GameEventManager:OnNpcSpawned(event)
    local hero = EntIndexToHScript(event.entindex)
    PlayerResource.playerId = hero:GetPlayerID()
    GameRules.AdvancedNavSystem:BindUnit(hero)
end

function GameEventManager:OrderFilter(event)
    DeepPrintTable(event)
end
