require("apputils.mathutils")
require("navmeshdata.generic_node")

if GridNavData == nil then
    GridNavData = class({
        worldSize = Vector(2048, 2048, 0), -- we only care about x,y as it representing width, height
        nodeSize = 64,
        gridArr = {},
        layer1GridArr = {},
        constructor = function(self, worldSize, nodeSize)
            self.worldSize = worldSize or self.worldSize
            self.nodeSize = nodeSize or self.nodeSize
            self.halfNodeSize = self.nodeSize / 2
            self.gridSizeX = mathUtils.roundToInt(self.worldSize.x / self.nodeSize)
            self.gridSizeY = mathUtils.roundToInt(self.worldSize.y / self.nodeSize)
        end
    })
end

function GridNavData:CreateBaseGrid()
    local defaultWorldZ = 128
    local worldBottomLeft = Vector(-self.worldSize.x / 2, -self.worldSize.y / 2, defaultWorldZ)

    for x = 0, self.gridSizeX - 1, 1 do
        self.gridArr[x] = {}
        for y = 0, self.gridSizeY - 1, 1 do
            local nodePoint = worldBottomLeft +
                Vector(x * self.nodeSize + self.halfNodeSize, y * self.nodeSize + self.halfNodeSize)
            local traversable = GridNav:IsTraversable(nodePoint)
            self.gridArr[x][y] = GenericNode(nodePoint, traversable, x, y)
        end
    end
end

function GridNavData:CreateOverhangGrid()
    -- Assume that we only have one additional navmesh layer with ID = 1
    -- In the future there will be many layers, each with different z-position
    -- With layer 0 is the base layer (Created using built-in GridNav)
    local overhangEnts = Entities:FindAllByName("navmesh_overhang_1")
    local layerNum = 1
    for _, ent in pairs(overhangEnts) do
        local overhangPos = ent:GetAbsOrigin()
        local overhangBoundMins = ent:GetBoundingMins()
        local overhangBoundMaxs = ent:GetBoundingMaxs()
        local overhangWidth = overhangBoundMaxs.x - overhangBoundMins.x
        local overhangHeight = overhangBoundMaxs.y - overhangBoundMins.y
        local overhangGridSizeX = math.floor(overhangWidth / self.nodeSize)
        local overhangGridSizeY = math.floor(overhangHeight / self.nodeSize)
        local overhangBottomLeft = Vector(overhangPos.x - overhangBoundMaxs.x, overhangPos.y - overhangBoundMaxs.y,
            overhangPos.z)

        for x = 0, overhangGridSizeX - 1, 1 do
            for y = 0, overhangGridSizeY - 1, 1 do
                local nodePoint = overhangBottomLeft +
                    Vector(x * self.nodeSize + self.halfNodeSize, y * self.nodeSize + self.halfNodeSize)
                local traversable = true -- Assume that the overhang grids are all traversable
                local baseLayerGridPosX = GridNav:WorldToGridPosX(nodePoint.x) + self.nodeSize
                local baseLayerGridPosY = GridNav:WorldToGridPosY(nodePoint.y) + self.nodeSize

                if self.layer1GridArr[baseLayerGridPosX] == nil then
                    self.layer1GridArr[baseLayerGridPosX] = {}
                end

                self.layer1GridArr[baseLayerGridPosX][baseLayerGridPosY] = GenericNode(nodePoint, traversable,
                    baseLayerGridPosX, baseLayerGridPosY, layerNum)
            end
        end
    end
end

-- For now we only link between base and an unique overhang layer
function GridNavData:LinkGridBetweenLayers()
    local bridgingEnts = Entities:FindAllByName("navmesh_overhang_1_*")

    for _, ent in pairs(bridgingEnts) do
        local entName = ent:GetName()
        if not string.find(entName, "link") then
            local linkEnt = ent:GetMoveParent()
            local baseLayerNodePos = ent:GetAbsOrigin()
            local overhangLayerNodePos = linkEnt:GetAbsOrigin()
            local baseNode = self:GetNodeFromWorldPos(baseLayerNodePos)
            local overhangNode = self:GetNodeFromWorldPos(overhangLayerNodePos, 1)

            table.insert(baseNode.linkedNodes, overhangNode)
            baseNode.isPortalNode = true
            table.insert(overhangNode.linkedNodes, baseNode)
            overhangNode.isPortalNode = true
        end
    end
end

function GridNavData:GetNodeFromWorldPos(worldPos, layer)
    local gridPos = self:WorldPositionToGrid(worldPos)

    if layer == 1 then
        return self.layer1GridArr[gridPos.x][gridPos.y]
    end
    return self.gridArr[gridPos.x][gridPos.y]
end

function GridNavData:WorldPositionToGrid(worldPos)
    local ratioX = (worldPos.x + self.worldSize.x / 2) / self.worldSize.x
    local ratioY = (worldPos.y + self.worldSize.y / 2) / self.worldSize.y
    ratioX = mathUtils.clamp01(ratioX)
    ratioY = mathUtils.clamp01(ratioY)

    return Vector(
        mathUtils.roundToInt((self.gridSizeX - 1) * ratioX),
        mathUtils.roundToInt((self.gridSizeY - 1) * ratioY),
        0
    )
end

function GridNavData:GetNeighbors(node)
    local neighbors = {}
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            if x == 0 and y == 0 then
                goto continue
            end

            local scanX = node.gridPosX + x
            local scanY = node.gridPosY + y

            if scanX >= 0 and scanX < self.gridSizeX and
                scanY >= 0 and scanY < self.gridSizeY then
                -- Neighbor if the node is in base navmesh
                if node.navmeshLayer == 0 then
                    table.insert(neighbors, self.gridArr[scanX][scanY])
                -- Neighbor if the node is in overhang navmesh
                elseif node.navmeshLayer == 1 and
                    self.layer1GridArr[scanX] ~= nil and
                    self.layer1GridArr[scanX][scanY] ~= nil then
                    table.insert(neighbors, self.layer1GridArr[scanX][scanY])
                end
            end

            -- Additional neighbors in overhang layer, if exists
            if node.isPortalNode and #node.linkedNodes > 0 then
                vlua.extend(neighbors, node.linkedNodes)
            end
            ::continue::
        end
    end

    return neighbors
end

function GridNavData:DebugDrawWorldBound()
    local halfWidth = self.worldSize.x / 2
    local halfHeight = self.worldSize.y / 2
    local zThick = 16
    local minBounds = Vector(-halfWidth, -halfHeight, -zThick)
    local maxBounds = Vector(halfWidth, halfHeight, zThick)

    DebugDrawBox(Vector(0, 0, 128), minBounds, maxBounds, 252, 3, 132, 0, 9999)
end

function GridNavData:DebugDrawGrid()
    for i, value in pairs(self.gridArr) do
        for j, node in pairs(value) do
            local boxColor = node.gridTraversable and Vector(66, 245, 72) or Vector(247, 64, 47)
            local rectSize = self.halfNodeSize - 7
            local groundPos = GetGroundPosition(node.worldPosition, nil)
            local bottomPos = Vector(groundPos.x - rectSize, groundPos.y - rectSize, groundPos.z)
            local topPos = Vector(groundPos.x + rectSize, groundPos.y + rectSize, groundPos.z)
            DebugDrawLine_vCol(bottomPos, bottomPos + rectSize * 2 * Vector(1, 0, 0), boxColor, false, 9999)
            DebugDrawLine_vCol(bottomPos, bottomPos + rectSize * 2 * Vector(0, 1, 0), boxColor, false, 9999)
            DebugDrawLine_vCol(topPos, topPos + rectSize * 2 * Vector(-1, 0, 0), boxColor, false, 9999)
            DebugDrawLine_vCol(topPos, topPos + rectSize * 2 * Vector(0, -1, 0), boxColor, false, 9999)

            if node.isPortalNode then
                DebugDrawSphere(groundPos, Vector(0, 195, 255), 0, self.halfNodeSize, false, 9999)
            end
        end
    end

    for _, value in pairs(self.layer1GridArr) do
        for _, node in pairs(value) do
            local boxColor = Vector(198, 27, 245)
            DebugDrawCircle(node.worldPosition, boxColor, 0, self.halfNodeSize, false, 9999)

            if node.isPortalNode then
                DebugDrawSphere(node.worldPosition, Vector(0, 195, 255), 0, self.halfNodeSize, false, 9999)
            end
        end
    end
end

function GridNavData:LineOfSight(nodeA, nodeB)
    local x1 = nodeA.gridPosX
    local x2 = nodeB.gridPosX
    local y1 = nodeA.gridPosY
    local y2 = nodeB.gridPosY

    local deltaX = x2 - x1
    local deltaY = y2 - y1

    local temp = 0

    local signX = 1
    local signY = 1
    local offsetX = 0
    local offsetY = 0

    if deltaY < 0 then
        deltaY = -deltaY
        signY = -1
        offsetY = -1
    end
    if deltaX < 0 then
        deltaX = -deltaX
        signX = -1
        offsetX = -1
    end

    if deltaX >= deltaY then
        while x1 ~= x2 do
            temp = temp + deltaY
            if temp >= deltaX then
                if self:_IsBlocked(x1 + offsetX, y1 + offsetY) then
                    return false
                end
                y1 = y1 + signY
                temp = temp - deltaX
            end
            if temp ~= 0 and self:_IsBlocked(x1 + offsetX, y1 + offsetY) then
                return false
            end
            if deltaY == 0 and self:_IsBlocked(x1 + offsetX, y1) and self:_IsBlocked(x1 + offsetX, y1 - 1) then
                return false
            end

            x1 = x1 + signX
        end
    else
        while y1 ~= y2 do
            temp = temp + deltaX
            if temp >= deltaY then
                if self:_IsBlocked(x1 + offsetX, y1 + offsetX) then
                    return false
                end
                x1 = x1 + signX
                temp = temp - deltaY
            end
            if temp ~= 0 and self:_IsBlocked(x1 + offsetX, y1 + offsetY) then
                return false
            end
            if deltaX == 0 and self:_IsBlocked(x1, y1 + offsetY) and self:_IsBlocked(x1 - 1, y1 + offsetY) then
                return false
            end

            y1 = y1 + signY
        end
    end

    return true
end

function GridNavData:_IsBlocked(x, y)
    if x >= self.worldSize.x or y >= self.worldSize.y then
        return true
    end
    if x < 0 or y < 0 then
        return true
    end

    return self.gridArr[x][y].gridTraversable
end
