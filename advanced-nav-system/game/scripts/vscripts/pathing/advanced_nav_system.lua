if (CAdvancedNavSystem == nil) then
    CAdvancedNavSystem = class({
        _targetPos = nil;
        _path = nil;
        _pathLength = 0;
        _pathPosition = 0;
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

function CAdvancedNavSystem:OnThinkNavigating() -- return 0.03 to mimic perframe
    local currentPos = self.navUnit:GetAbsOrigin()
    local targetPos = self._targetPos

    if targetPos == nil then
        return 0.03
    end

    if VectorDistance(currentPos, targetPos) < 0.4 then
        return 0.03
    end

    local pathProgress = math.min(self._pathLength * self._pathPosition + 400 * GameRules:GetGameFrameTime(), self._pathLength)
    self._pathPosition = pathProgress / self._pathLength

    local segmentsSum = 0
    for i = 1, #self._path, 1 do
        local segmentLength = VectorDistance(self._path[i], self._path[i + 1])
        
        if segmentsSum <= pathProgress and segmentsSum + segmentLength >= pathProgress then
            local rate = (pathProgress - segmentsSum) / segmentLength
            targetPos = LerpVectors(self._path[i], self._path[i + 1], rate)
            self.navUnit:SetAbsOrigin(GetGroundPosition(targetPos, nil))
            break
        end

        segmentsSum = segmentsSum + segmentLength
    end
    
    return 0.03
end

function CAdvancedNavSystem:SetTargetPoint(targetPosition)
    if targetPosition == self._targetPos then
        return
    end

    local startPosition = self.navUnit:GetAbsOrigin()
    self._pathPosition = 0
    self._pathLength = 0
    self._path = self.aStar:FindPath(startPosition, targetPosition) -- add coroutine with callback? for better perf
    self._targetPos = targetPosition

    if self._path ~= nil then
        local pathColor = Vector(158, 54, 255)
        for i = 1, #self._path, 1 do
            DebugDrawSphere(GetGroundPosition(self._path[i], nil), pathColor, 0, 8, false, 3)
            if i == 1 then
                DebugDrawLine_vCol(GetGroundPosition(startPosition, nil), GetGroundPosition(self._path[i], nil), pathColor, false, 3)
            else
                self._pathLength = self._pathLength + VectorDistance(self._path[i - 1], self._path[i])
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
