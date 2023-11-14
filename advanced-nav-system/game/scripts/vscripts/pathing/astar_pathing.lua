if AStarPathing == nil then
    AStarPathing = class({
        grid = GridNavData(),
        constructor = function(grid)
            self.grid = grid or self.grid
        end
    })
end

require("maprepresentationdata.grid_nav_data")

local CONST_DIAGONAL_WEIGHT = 14
local CONST_STRAIGHT_WEIGHT = 10

-- MORE OPTIMIZATIONS COME LATER
function AStarPathing:FindPath(startPos, targetPos)
    -- First, convert the world position to grid position, navmesh layer is not matter now
    local startNode = self.grid:GetNodeFromWorldPos(startPos)
    local targetNode = self.grid:GetNodeFromWorldPos(targetPos)

    local openList = {}
    local closedList = {}
    table.insert(openList, startNode)

    while #openList > 0 do
        local currentNode = openList[1] -- lua table is one-indexed if using table.insert

        -- TODO: optimize this!
        for i = 2, #openList, 1 do
            if openList[i]:GetFCost() < currentNode:GetFCost() or
                openList[i]:GetFCost() == currentNode:GetFCost() and openList[i].hCost < currentNode.hCost then
                currentNode = openList[i]
            end
        end

        listUtils.remove(currentNode)
        table.insert(closedList, currentNode)

        if currentNode == targetNode then
            return self:_RetraceWorldPath(startNode, targetNode)
        end

        local nodeNeighbors = self.grid:GetNeighbors(currentNode)
        for _, neighbor in ipairs(nodeNeighbors) do
            -- TODO: also optimize this!!
            -- If the neighbor is traversable and not in the closed list
            if neighbor.gridTraversable and not listUtils.contains(closedList, function(otherNode)
                    return neighbor.nodeId == otherNode.nodeId
                end)
            then
                local movementCostToNeighbor = currentNode.gCost + self:GetGridDistance(currentNode, neighbor)
                if movementCostToNeighbor < neighbor.gCost or not listUtils.contains(openList, function(otherNode)
                        return neighbor.nodeId == otherNode.nodeId
                    end)
                then
                    neighbor.gCost = movementCostToNeighbor -- update to new gCost
                    neighbor.hCost = self:GetGridDistance(neighbor, targetNode)
                    neighbor.parentNode = currentNode

                    if not listUtils.contains(openList, function(otherNode)
                            return neighbor.nodeId == otherNode.nodeId
                        end)
                    then
                        table.insert(openList, neighbor)
                    end
                end
            end
        end
    end
end

function AStarPathing:GetGridDistance(fromNode, toNode)
    local distanceX = fromNode.gridPosX - toNode.gridPosX
    local distanceY = fromNode.gridPosY - toNode.gridPosY

    if distanceX > distanceY then
        return CONST_DIAGONAL_WEIGHT * distanceY + CONST_STRAIGHT_WEIGHT * (distanceX - distanceY)
    end

    return CONST_DIAGONAL_WEIGHT * distanceX + CONST_STRAIGHT_WEIGHT * (distanceY - distanceX)
end

function AStarPathing:_RetracePath(startNode, endNode)
    local path = {}
    local currentNode = endNode

    while currentNode.nodeId ~= startNode.nodeId do
        table.insert(path, currentNode)
        currentNode = currentNode.parentNode
    end

    return vlua.reverse(path)
end

function AStarPathing:_RetraceWorldPath(startNode, endNode)
    local path = {}
    local currentNode = endNode

    while currentNode.nodeId ~= startNode.nodeId do
        local subTargetPos = Vector(
            GridNav:GridPosToWorldCenterX(currentNode.gridPosX),
            GridNav:GridPosToWorldCenterY(currentNode.gridPosY),
            0
        )
        if currentNode.navmeshLayer == 0 then
            subTargetPos = GetGroundPosition(subTargetPos, nil)
        elseif currentNode.navmeshLayer == 1 then
            subTargetPos.z = 200
        end
        table.insert(path, subTargetPos)
        currentNode = currentNode.parentNode
    end

    return vlua.reverse(path)
end
