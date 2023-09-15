function IssueMoveToTargetPoint(trigger, targetPoint)
    if (trigger == nil or targetPoint == nil) then
        return
    end

    local player = trigger.activator
    local playerPos = player:GetAbsOrigin()
    local distanceToTarget = GridNav:FindPathLength(playerPos, targetPoint)
    local infoTargetBridgeTable = Entities:FindAllByClassnameWithin("info_target", playerPos, distanceToTarget)
    local linkedBridgeTable = {}
    local advancedMoveThroughBridgeEnt = nil

    for _, infoTarget in pairs(infoTargetBridgeTable) do
        local bridge = infoTarget:GetMoveParent()
        linkedBridgeTable[bridge:entindex()] = bridge
    end

    for _, bridge in pairs(linkedBridgeTable) do
        -- For now, let's assume that we always have only 2 info target of a bridge
        local linkedInfoTarget = bridge:GetChildren()
        local infoTarget1 = linkedInfoTarget[1]
        local infoTarget2 = linkedInfoTarget[2]

        local distanceBetween = Distance(infoTarget1, infoTarget2)
        local distancePointOneToPlayer = GridNav:FindPathLength(playerPos, infoTarget1:GetAbsOrigin())
        local distancePointTwoToPlayer = GridNav:FindPathLength(playerPos, infoTarget2:GetAbsOrigin())

        local totalDistance = 0
        if (distancePointOneToPlayer <= distancePointTwoToPlayer) then
            totalDistance = distancePointOneToPlayer + distanceBetween +
            GridNav:FindPathLength(infoTarget2:GetAbsOrigin(), targetPoint)
        else
            totalDistance = distancePointTwoToPlayer + distanceBetween +
            GridNav:FindPathLength(infoTarget1:GetAbsOrigin(), targetPoint)
        end

        if (totalDistance < distanceToTarget) then
            advancedMoveThroughBridgeEnt = bridge
        end
    end

    if (advancedMoveThroughBridgeEnt ~= nil) then
        MoveToPlatform(trigger)
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

function MoveToPlatform(trigger)
    local player = trigger.activator

    -- if the player has the modifier attached, it is on the bridge already
    if (player == nil or player:HasModifier("modifier_bridge_crossing")) then
        return
    end

    local bridgeEnt = thisEntity
    local children = bridgeEnt:GetChildren()
    local infoTarget = FindClosestBridgeInfoTarget(player, children)

    if (infoTarget == nil) then
        return
    end

    if (infoTarget:GetClassname() == "info_target") then
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
