-- Generated from template

if CAddonTemplateGameMode == nil then
    CAddonTemplateGameMode = class({})
end

function Precache(context)
    --[[
		Precache things we know we'll use.  Possible file types include (but not limited to):
			PrecacheResource( "model", "*.vmdl", context )
			PrecacheResource( "soundfile", "*.vsndevts", context )
			PrecacheResource( "particle", "*.vpcf", context )
			PrecacheResource( "particle_folder", "particles/folder", context )
	]]
end

require("game_setup")

-- Create the game mode when we activate
function Activate()
    GameRules.AddonTemplate = CAddonTemplateGameMode()
    GameRules.AddonTemplate:InitGameMode()
end

function CAddonTemplateGameMode:InitGameMode()
    print("Template addon is loaded.")
    GameRules:GetGameModeEntity():SetThink("OnThink", self, "GlobalThink", 2)

    GameSetup:init()

    LinkLuaModifier("modifier_bridge_crossing", LUA_MODIFIER_MOTION_NONE)
    LinkLuaModifier("modifier_static_object", LUA_MODIFIER_MOTION_NONE)
    CustomGameEventManager:RegisterListener("PanoramaClickEvent", OnPanoramaClickEvent)
    CustomGameEventManager:RegisterListener("PanoramaClickEventTest", OnPanoramaClickEventTest)
end

-- Evaluate the state of the game
function CAddonTemplateGameMode:OnThink()
    if GameRules:State_Get() == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
        --print( "Template addon script is running." )
    elseif GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
        return nil
    end
    return 1
end

-- ============================== Our custom code - Refactor all below later ============================== --
function OnPanoramaClickEvent(eventSrcIndex, args)
    print("Event received! Event source index: " .. eventSrcIndex)
    local hero = EntIndexToHScript(args["HeroId"])
    local bridgeEnt = EntIndexToHScript(args["BridgeIndex"])
    MoveToPlatform(hero, bridgeEnt)
    -- DoEntFire("moc_test_bridge", "CallScriptFunction", "MoveToPlatform", 0, hero, nil)
end

function OnPanoramaClickEventTest(eventSrcIndex, args)
    local hero = EntIndexToHScript(args["HeroId"])
    local x = args["TargetPointX"];
    local y = args["TargetPointY"];
    local z = args["TargetPointZ"];
    local targetPoint = Vector(x, y, z)

    IssueMoveToTargetPoint(hero, targetPoint)
end

function IssueMoveToTargetPoint(player, targetPoint)
    if (player == nil or targetPoint == nil) then
        return
    end

    local playerPos = player:GetAbsOrigin()
    local distanceToTarget = GridNav:FindPathLength(playerPos, targetPoint)
    local bridgePoints = Entities:FindAllByClassnameWithin("npc_dota_building", playerPos, distanceToTarget)
    local nearbyBridges = {}
    local bridgeEntToMoveThrough = nil

    for _, infoTarget in pairs(bridgePoints) do
        if (infoTarget:GetUnitName() == "npc_dota_bridge_point") then
            local bridge = infoTarget:GetMoveParent()
            nearbyBridges[bridge:entindex()] = bridge
        end
    end

    print("GridNav distance: ", distanceToTarget)

    for _, bridge in pairs(nearbyBridges) do
        -- For now, let's assume that we always have only 2 info target of a bridge
        local linkedInfoTarget = bridge:GetChildren()
        local infoTarget1 = linkedInfoTarget[1]
        local infoTarget2 = linkedInfoTarget[2]
        local infoTarget1Pos = infoTarget1:GetAbsOrigin()
        local infoTarget2Pos = infoTarget2:GetAbsOrigin()

        local distanceBetween = Distance(infoTarget1Pos, infoTarget2Pos)
        local distancePointOneToPlayer = GridNav:FindPathLength(playerPos, infoTarget1Pos)
        local distancePointTwoToPlayer = GridNav:FindPathLength(playerPos, infoTarget2Pos)

        local totalDistance = 0
        if (distancePointOneToPlayer <= distancePointTwoToPlayer) then
            totalDistance = distancePointOneToPlayer + distanceBetween +
                GridNav:FindPathLength(infoTarget2Pos, targetPoint)
        else
            totalDistance = distancePointTwoToPlayer + distanceBetween +
                GridNav:FindPathLength(infoTarget1Pos, targetPoint)
        end

        print("Distance through bridge:", totalDistance)

        if (totalDistance < distanceToTarget) then
            bridgeEntToMoveThrough = bridge
        end
    end

    if (bridgeEntToMoveThrough ~= nil) then
        print("Move through bridge")
        MoveToPlatform(player, bridgeEntToMoveThrough)
        local moveOrder = {
            UnitIndex = player:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = targetPoint,
            Queue = 2
        }
        ExecuteOrderFromTable(moveOrder)
    else
        local moveOrder = {
            UnitIndex = player:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = targetPoint,
        }
        ExecuteOrderFromTable(moveOrder)
    end
end

function MoveToPlatform(player, bridgeEnt)
    -- if the player has the modifier attached, it is on the bridge already
    if (player == nil or player:HasModifier("modifier_bridge_crossing")) then
        return
    end

    local children = bridgeEnt:GetChildren()
    local infoTarget = FindClosestBridgeInfoTarget(player, children)

    print("MoveToPlatform info target: ", infoTarget)
    if (infoTarget == nil) then
        return
    end

    if (infoTarget:GetUnitName() == "npc_dota_bridge_point") then
        local moveOrder = {
            UnitIndex = player:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = infoTarget:GetAbsOrigin(),
            Queue = 0
        }

        local moveBridgeOrder = {
            UnitIndex = player:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = bridgeEnt:GetAbsOrigin(),
            Queue = 1
        }

        ExecuteOrderFromTable(moveOrder)
        ExecuteOrderFromTable(moveBridgeOrder)
    end
end

function FindClosestBridgeInfoTarget(player, children)
    local target = nil
    local playerPosition = player:GetAbsOrigin()

    for _, infoTarget in pairs(children) do
        local infoTargetPos = infoTarget:GetAbsOrigin()
        if (GridNav:CanFindPath(playerPosition, infoTargetPos)) then
            if (target == nil or GridNav:FindPathLength(playerPosition, infoTargetPos) <= GridNav:FindPathLength(playerPosition, target:GetAbsOrigin())) then
                target = infoTarget
            end
        end
    end

    return target
end

function Distance(vector1, vector2)
    local x = vector1.x - vector2.x
    local y = vector1.y - vector2.y
    local z = vector1.z - vector2.z

    return math.sqrt(x * x + y * y + z * z);
end
