if (AdvancedNavSystem == nil) then
    AdvancedNavSystem = class({})
end

function AdvancedNavSystem:IssueMoveToTargetPoint(player, targetPoint)
    if (player == nil or targetPoint == nil) then
        return
    end
    
    targetPoint = SnapPosition(targetPoint)
    local playerPos = SnapPosition(player:GetAbsOrigin())
    local distanceToTarget = GridNav:FindPathLength(playerPos, targetPoint)
    print("GridNav distance: ", distanceToTarget)
    print("GridNav traversible: ", GridNav:IsTraversable(targetPoint))
    print("GridNav can find path: ", GridNav:CanFindPath(playerPos, targetPoint))
    print("GridNav remaining path: ", player:GetRemainingPathLength())
    

    -- TODO: We should improve this below code to find nearest travel distance, not nearest point
    -- local nearestPathCorner = Entities:FindByClassnameNearest("path_corner", playerPos, distanceToTarget)
    -- if (nearestPathCorner == nil) then
    --     player:MoveToPosition(targetPoint)
    --     return
    -- end

    -- local linkedPathCorner = self:FindLinkedPathCorner(nearestPathCorner)
    -- if (linkedPathCorner == nil) then
    --     player:MoveToPosition(targetPoint)
    --     return
    -- end

    -- local nearestPos = nearestPathCorner:GetAbsOrigin()
    -- local linkedPos = linkedPathCorner:GetAbsOrigin()
    -- local distanceOfTwoPoints = Distance(nearestPos, linkedPos)
    -- local totalPathDistance = GridNav:FindPathLength(playerPos, nearestPos)
    --     + GridNav:FindPathLength(linkedPos, targetPoint)
    --     + distanceOfTwoPoints
    -- local testPathDistance = GridNav:FindPathLength(playerPos, linkedPos)
    --     + GridNav:FindPathLength(nearestPos, targetPoint)
    --     + distanceOfTwoPoints

    -- print("Nearest pos", nearestPos)
    -- print("Linked pos", linkedPos)
    -- print("Distance from player to nearest: ", GridNav:FindPathLength(playerPos, nearestPos))
    -- print("Distance of two points", distanceOfTwoPoints)
    -- print("Distance from linked to target: ", GridNav:FindPathLength(linkedPos, targetPoint))
    -- print("Total distance", totalPathDistance)
    -- print("Total test distance (reversed)", testPathDistance)
    -- if (totalPathDistance < distanceToTarget) then
    --     -- TODO: find a way to stop all queued action before executing the below orders
    --     ExecuteOrderFromTable({
    --         UnitIndex = player:entindex(),
    --         OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    --         Position = nearestPos,
    --         Queue = 0
    --     })
    --     ExecuteOrderFromTable({
    --         UnitIndex = player:entindex(),
    --         OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    --         Position = linkedPos,
    --         Queue = 1
    --     })
    --     ExecuteOrderFromTable({
    --         UnitIndex = player:entindex(),
    --         OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
    --         Position = targetPoint,
    --         Queue = 2
    --     })
    -- else
    --     player:MoveToPosition(targetPoint)
    -- end
end

function AdvancedNavSystem:MoveToPlatform(player, bridgeEnt)
    -- if the player has the modifier attached, it is on the bridge already
    if (player == nil or player:HasModifier("modifier_bridge_crossing")) then
        return
    end

    local children = bridgeEnt:GetChildren()
    local infoTarget = self:FindClosestBridgeInfoTarget(player, children)

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

function AdvancedNavSystem:FindClosestBridgeInfoTarget(player, children)
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

function AdvancedNavSystem:FindLinkedPathCorner(pathCorner)
    -- local nextTargetId = pathCorner:Attribute_GetIntValue("NextStopTargetId", 0)
    -- if (nextTargetId == 0) then
    --     return nil
    -- end

    -- local nextTargetName = "path" .. tostring(nextTargetId)
    return Entities:FindByTarget(nil, pathCorner:GetName())
end

-- Refactor below function to different file?
function Distance(vector1, vector2)
    local x = vector1.x - vector2.x
    local y = vector1.y - vector2.y
    local z = vector1.z - vector2.z

    return math.sqrt(x * x + y * y + z * z);
end

function SnapPosition(position)
    local gridPosX = GridNav:WorldToGridPosX(position.x)
    local gridPosY = GridNav:WorldToGridPosY(position.y)
    local newX = GridNav:GridPosToWorldCenterX(gridPosX)
    local newY = GridNav:GridPosToWorldCenterY(gridPosY)

    return Vector(newX, newY, position.Z)
end
