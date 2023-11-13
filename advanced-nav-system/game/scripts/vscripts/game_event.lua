if (GameEventManager == nil) then
    GameEventManager = class({})
end

require("advanced_nav_system")

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
        PATTACH_CUSTOMORIGIN, nil,
        hero:GetPlayerOwner())
    ParticleManager:SetParticleControl(cursorFX, 0, targetPoint)
    ParticleManager:ReleaseParticleIndex(cursorFX)

    AdvancedNavSystem:IssueMoveToTargetPoint(hero, targetPoint)
end

function GameEventManager:OnNpcSpawned(event)
    print("OnNpcSpawned")
    DeepPrintTable(event)

    local unit = EntIndexToHScript(event.entindex)
    if unit:GetUnitName() == "npc_dota_nav_agent" then
        return
    end

    local hero = EntIndexToHScript(event.entindex)
    local pathCorner = Entities:FindByName(nil, "test_path_1")
    PlayerResource.hero_index = event.entindex
    PlayerResource.goal_index = pathCorner:entindex()
    PlayerResource.player_id = hero:GetPlayerID()
    hero:SetThink("Init", NavAgent, 0.03)

    DebugDrawCircle(pathCorner:GetAbsOrigin(), Vector(204, 27, 27), 0, 64, true, 99999)
    DebugDrawSphere(Vector(0, 0, 0), Vector(204, 27, 27), 0, 64, true, 99999)
    hero:SetShouldComputeRemainingPathLength(true)
    hero:SetBaseMoveSpeed(10000)
end

function GameEventManager:OrderFilter(event)
    DeepPrintTable(event)
end
