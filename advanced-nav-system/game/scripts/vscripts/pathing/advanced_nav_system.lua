if (CAdvancedNavSystem == nil) then
    CAdvancedNavSystem = class({
        _targetPosition = nil;
    })
end

require("pathing.astar_pathing")
require("maprepresentationdata.grid_nav_data")

function CAdvancedNavSystem:Activate()
    self.grid = GridNavData(Vector(8192, 8192, 0), 64)
    self.aStar = AStarPathing(self.grid)
    self:_BuildMultiGridMesh()
    self:_AddCustomNavDebugConvars()
end

function CAdvancedNavSystem:BindUnit(targetUnit)
    if self.navUnit:entindex() ~= targetUnit:entindex() then
        return
    end
    self.navUnit = targetUnit
    self.navUnit:SetThink(self.OnThinkNavigating)
end

function CAdvancedNavSystem:OnThinkNavigating()
    -- TODO: if there is a stop command, return to execute next frame
    -- if ... then 

    if self._targetPosition == nil then
        return 0.03
    end

    local currentPos = self.navUnit:GetAbsOrigin()
    local distanceToTarget = VectorDistance(currentPos, self._targetPosition)
    
    -- Check if the unit has reached the destination
    if distanceToTarget < 0.6 then
        return 0.03
    end

    local unitPos = self.navUnit:GetAbsOrigin()
    local groundHeight = GetGroundHeight(unitPos, nil)
    unitPos.z = groundHeight
    self.navUnit:SetAbsOrigin(unitPos)
end

function CAdvancedNavSystem:MoveToTargetPoint(targetPosition)
    local startPosition = self.navUnit:GetAbsOrigin()
    local path = self.aStar:FindPath(startPosition, targetPosition)
    for _, pathNode in pairs(path) do
        self.navUnit:OnCommandMoveToDirection(pathNode)
    end
end

function CAdvancedNavSystem:_BuildMultiGridMesh()
    self.grid:CreateGrid()
    self.grid:CreateOverhangGrid()
    self.grid:LinkGridBetweenLayers()
    
    -- For debugging
    DebugDrawClear()
    self.grid:DebugDrawWorldBound()
    self.grid:DebugDrawGrid()
end

function CAdvancedNavSystem:_AddCustomNavDebugConvars()
    -- TODO: implement this functions
    -- RegisterCommand(name, fn, helpString, flags)
end
