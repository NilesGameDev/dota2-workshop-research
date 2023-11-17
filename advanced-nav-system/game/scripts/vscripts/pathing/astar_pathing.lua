if AStarPathing == nil then
    AStarPathing = class({
        constructor = function(self, grid)
            self.grid = grid or self.grid
        end
    })
end

require("apputils.heap")
require("maprepresentationdata.grid_nav_data")

local nodeCostComparer = function (nodeA, nodeB)
    local costCompare = nodeA:GetFCost() - nodeB:GetFCost()
    if costCompare == 0 then
        costCompare = nodeA.hCost - nodeB.hCost
    end

    return -costCompare -- the lower cost the better
end
local equalNodeFunc = function (nodeA, nodeB)
    if nodeA == nil or nodeB == nil then
        return false
    end
    return nodeA.nodeId == nodeB.nodeId
end

local CONST_DIAGONAL_WEIGHT = 14
local CONST_STRAIGHT_WEIGHT = 10

function AStarPathing:FindPath(startPos, targetPos)
    -- First, convert the world position to grid position, navmesh layer is not matter now
    local startNode = self.grid:GetNodeFromWorldPos(startPos)
    local targetNode = self.grid:GetNodeFromWorldPos(targetPos)

    if not startNode.gridTraversable or not targetNode.gridTraversable then
        return nil
    end

    local openList = StandardHeap(nodeCostComparer)
    local closedList = {}
    openList:Add(startNode)

    while openList.itemCount > 0 do
        local currentNode = openList:RemoveFirst()
        closedList[currentNode.nodeId] = currentNode

        if currentNode.nodeId == targetNode.nodeId then
            return self:_RetracePath(startNode, targetNode)
        end

        local nodeNeighbors = self.grid:GetNeighbors(currentNode)
        for _, neighbor in ipairs(nodeNeighbors) do
            -- If the neighbor is traversable and not in the closed list
            if neighbor.gridTraversable and not vlua.contains(closedList, neighbor.nodeId) then
                local movementCostToNeighbor = currentNode.gCost + self:GetGridDistance(currentNode, neighbor)
                if movementCostToNeighbor < neighbor.gCost or not openList:Contains(neighbor, equalNodeFunc) then
                    neighbor.gCost = movementCostToNeighbor -- update to new gCost
                    neighbor.hCost = self:GetGridDistance(neighbor, targetNode)
                    neighbor.parentNode = currentNode

                    if not openList:Contains(neighbor, equalNodeFunc) then
                        openList:Add(neighbor)
                    else
                        -- openList:UpdateItem(neighbor)
                    end
                end
            end
        end
    end
end

function AStarPathing:GetGridDistance(fromNode, toNode)
    local distanceX = math.abs(fromNode.gridPosX - toNode.gridPosX)
    local distanceY = math.abs(fromNode.gridPosY - toNode.gridPosY)

    if distanceX > distanceY then
        return CONST_DIAGONAL_WEIGHT * distanceY + CONST_STRAIGHT_WEIGHT * (distanceX - distanceY)
    end

    return CONST_DIAGONAL_WEIGHT * distanceX + CONST_STRAIGHT_WEIGHT * (distanceY - distanceX)
end

function AStarPathing:_RetracePath(startNode, endNode)
    local path = {}
    local currentNode = endNode

    while currentNode.nodeId ~= startNode.nodeId do
        table.insert(path, currentNode.worldPosition)
        currentNode = currentNode.parentNode
    end

    return vlua.reverse(path)
end
