if (CAdvancedNavSystem == nil) then
    CAdvancedNavSystem = class({
        _path = nil;
        _pathNodeIndex = 1;
    })
end

require("pathing.astar_pathing")
require("maprepresentationdata.grid_nav_data")

function CAdvancedNavSystem:Activate()
    self.grid = GridNavData(Vector(8192, 8192, 0), 64)
    self.aStar = AStarPathing(self.grid)
    self:_BuildMultiGridMesh()
    self:_AddCustomNavDebugConvars()
    GameRules:GetGameModeEntity():SetExecuteOrderFilter(Dynamic_Wrap(CAdvancedNavSystem, "_OnUnitOrderFilter"), self)
end

function CAdvancedNavSystem:BindUnit(targetUnit)
    if self.navUnit ~= nil and self.navUnit:entindex() ~= targetUnit:entindex() then
        return
    end
    self.navUnit = targetUnit
    self.navUnit:AddNewModifier(nil, nil, "modifier_bridge_crossing", nil)
    self.navUnit:SetThink("OnThinkNavigating", self, "OnThinkNavigating", 0)
end

function CAdvancedNavSystem:OnThinkNavigating()
    if self._path == nil or next(self._path) == nil then
        self._pathNodeIndex = 1;
        return 0.03
    end

    local currentWaypoint = self._path[self._pathNodeIndex]
    if currentWaypoint == nil then
        return 0.03
    end
    if self.navUnit:GetAbsOrigin() == currentWaypoint then
        self._pathNodeIndex = self._pathNodeIndex + 1
        currentWaypoint = self._path[self._pathNodeIndex]
    end
    
    if self.navUnit:GetAbsOrigin() == self._path[#self._path] then
        self._path = nil
    else
        self.navUnit:OnCommandMoveToDirection(currentWaypoint)
    end
    
    return 0.03
end

function CAdvancedNavSystem:SetTargetPoint(targetPosition)
    local startPosition = self.navUnit:GetAbsOrigin()
    self._path = self.aStar:FindPath(startPosition, targetPosition) -- add coroutine with callback? for better perf

    if self._path ~= nil then
        local pathColor = Vector(158, 54, 255)
        for i = 1, #self._path, 1 do
            DebugDrawSphere(GetGroundPosition(self._path[i], nil), pathColor, 0, 8, false, 3)
            if i == 1 then
                DebugDrawLine_vCol(GetGroundPosition(startPosition, nil), GetGroundPosition(self._path[i], nil), pathColor, false, 3)
            else
                DebugDrawLine_vCol(GetGroundPosition(self._path[i - 1], nil), GetGroundPosition(self._path[i], nil), pathColor, false, 3)
            end
        end
    end
end

function CAdvancedNavSystem:_BuildMultiGridMesh()
    DebugDrawClear()
    self.grid:CreateGrid()
    -- self.grid:CreateOverhangGrid()
    -- self.grid:LinkGridBetweenLayers()
    
    -- For debugging
    self.grid:DebugDrawWorldBound()
    self.grid:DebugDrawGrid()
end

function CAdvancedNavSystem:_AddCustomNavDebugConvars()
    -- TODO: implement this functions
    -- RegisterCommand(name, fn, helpString, flags)
end

function CAdvancedNavSystem:_OnUnitOrderFilter(args)
    local unitEntIndex = args["units"]["0"]
    if unitEntIndex ~= self.navUnit:entindex() then
        return true
    end

    local orderType = args["order_type"]
    if orderType == DOTA_UNIT_ORDER_STOP then
        self._path = nil
    end

    return true
end
