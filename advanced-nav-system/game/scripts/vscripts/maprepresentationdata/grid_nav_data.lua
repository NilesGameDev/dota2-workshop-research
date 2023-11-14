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
            self.gridSizeX = math.floor(self.worldSize.x / self.nodeSize)
            self.gridSizeY = math.floor(self.worldSize.y / self.nodeSize)
        end
    })
end

require("maprepresentationdata.generic_node")

function GridNavData:CreateGrid()
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
                    baseLayerGridPosX, baseLayerGridPosY)
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
            DebugDrawSphere(ent:GetAbsOrigin(), Vector(0, 195, 255), 0, self.halfNodeSize, false, 9999)
            DebugDrawSphere(linkEnt:GetAbsOrigin(), Vector(0, 195, 255), 0, self.halfNodeSize, false, 9999)

            local baseLayerNodePos = ent:GetAbsOrigin()
            local overhangLayerNodePos = linkEnt:GetAbsOrigin()
            local baseNode = self:GetNodeFromWorldPos(baseLayerNodePos)
            local overhangNode = self:GetNodeFromWorldPos(overhangLayerNodePos, overhangNode.navmeshLayer)
            
            baseNode.linkedNodes[#baseNode.linkedNodes + 1] = overhangNode
            baseNode.isPortalNode = true
            overhangNode.linkedNodes[#overhangNode.linkedNodes + 1] = baseNode
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
    return Vector(
        GridNav:WorldToGridPosX(worldPos.x) + self.nodeSize, -- We have to convert grid coord from builtin
        GridNav:WorldToGridPosY(worldPos.y) + self.nodeSize, -- position (has negative value) to our grid data
        0
    )
end

function GenericNode:GetNeighbors(node)
    local neighbors = {}
    for x = -1, 1, 1 do
        for y = -1, 1, 1 do
            if x ~= 0 and y ~= 0 then
                local scanX = node.gridPosX + x
                local scanY = node.gridPosY + y

                -- Neighbor in base navmesh
                if scanX >= 0 and scanX < self.gridSizeX and
                    scanY >= 0 and scanY < self.gridSizeY then
                    table.insert(neighbors, self.gridArr[scanX][scanY])
                end

                -- Additional neighbors in overhang layer, if exists
                if node.isPortalNode and #node.linkedNodes > 0 then
                    vlua.extend(neighbors, node.linkedNodes)
                end
            end
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
            DebugDrawCircle(GetGroundPosition(node.worldPosition, nil), boxColor, 0, self.halfNodeSize, false, 9999)
        end
    end

    for i, value in pairs(self.layer1GridArr) do
        for j, node in pairs(value) do
            local boxColor = Vector(198, 27, 245)
            DebugDrawCircle(node.worldPosition, boxColor, 0, self.halfNodeSize, false, 9999)
        end
    end
end
