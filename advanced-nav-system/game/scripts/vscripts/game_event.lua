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

    AdvancedNavSystem:IssueMoveToTargetPoint(hero, targetPoint)
end

function GameEventManager:OnMapLocationUpdated(event)
    print("OnMapLocationUpdated")
end

function GameEventManager:OnRoundStartPostNav(event)
    print("RoundStartPostNav")
end

function GameEventManager:OnNpcSpawned(event)
    print("OnNpcSpawned")
    DeepPrintTable(event)

    local hero = EntIndexToHScript(event.entindex)
    print(hero:GetSequence())
    local pathCorner = Entities:FindByName(nil, "test_path_1")

    PlayerResource.hero_index = event.entindex
    PlayerResource.goal_index = pathCorner:entindex()

    DebugDrawCircle(pathCorner:GetAbsOrigin(), Vector(204, 27, 27), 0, 64, true, 99999)
    DebugDrawSphere(Vector(0, 0, 0), Vector(204, 27, 27), 0, 64, true, 99999)
    hero:SetShouldComputeRemainingPathLength(true)
    -- hero:SetThink("DelaySetGoal", self, 10)
    -- hero:SetThink("ThinkerPrintDistanceToGoal", self, 0)
end

function GameEventManager:OnNpcGoalReached(event)
    print("OnNpcGoalReached")
    DeepPrintTable(event)
end

-- Remove the below functions as they are test-only
function GameEventManager:DelaySetGoal()
    local hero = EntIndexToHScript(PlayerResource.hero_index)
    local pathCorner = EntIndexToHScript(PlayerResource.goal_index)
    hero:SetInitialGoalEntity(pathCorner)

    return nil
end

function GameEventManager:ThinkerPrintDistanceToGoal()
    local hero = EntIndexToHScript(PlayerResource.hero_index)
    local pathCorner = EntIndexToHScript(PlayerResource.goal_index)

    print("Distance to Goal: ", GridNav:FindPathLength(hero:GetAbsOrigin(), pathCorner:GetAbsOrigin()))
    print(hero:GetRemainingPathLength())
    return 0.5
end

function GameEventManager:OnServerSpawn(event)
    print("OnServerSpawn")
    DeepPrintTable(event)
end

function GameEventManager:OnServerCvarChanged(event)
    print("OnServerCvarChanged")
    DeepPrintTable(event)
end

function GameEventManager:OnServerMessage(event)
    print("OnServerMessage")
    print(event)
end

function GameEventManager:OnInstructorServerHintCreated(event)
    print("OnInstructorServerHintCreated")
    print(event)
end

function GameEventManager:OnGameNewMap(event)
    print("OnGameNewMap")
end

function GameEventManager:OnFilterGame(event)
    -- print("OnFilterGame")
    -- DeepPrintTable(event)
    -- local hero = EntIndexToHScript(event.units["0"])
    -- print(hero:GetRemainingPathLength())
    return true
end