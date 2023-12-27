if (CAdvancedNavSystem == nil) then
    CAdvancedNavSystem = class({
        _targetPos = nil,
        _path = nil,
        _pathLength = 0,
        _pathPosition = 0,
    })
end

require("pathing.astar_pathing")
require("navmeshdata.grid_nav_data")

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
    self.navUnit.moveSpeed = 400 -- Find a better way to assign speed to unit
    self.navUnit:AddNewModifier(nil, nil, "modifier_advanced_pathing", nil)
    self.navUnit:SetThink("OnThinkNavigating", self, "OnThinkNavigating", 0)
end

function CAdvancedNavSystem:OnThinkNavigating() -- return 0.03 to mimic perframe
    local currentPos = self.navUnit:GetAbsOrigin()
    local targetPos = self._targetPos

    if targetPos == nil then
        return GameRules:GetGameFrameTime()
    end

    if VectorDistance(currentPos, targetPos) < 0.1 then
        self.navUnit:FadeGesture(ACT_DOTA_RUN)
        self.navUnit:StartGesture(ACT_DOTA_IDLE)
        return GameRules:GetGameFrameTime()
    end

    if self._path == nil then
        return GameRules:GetGameFrameTime()
    end

    local pathProgress = math.min(
        self._pathLength * self._pathPosition + self.navUnit.moveSpeed * GameRules:GetGameFrameTime(),
        self._pathLength)
    self._pathPosition = pathProgress / self._pathLength

    local segmentsSum = 0
    for i = 1, #self._path, 1 do
        local segmentLength = VectorDistance(self._path[i], self._path[i + 1]) -- TODO: handle null here

        if segmentsSum <= pathProgress and segmentsSum + segmentLength >= pathProgress then
            local rate = (pathProgress - segmentsSum) / segmentLength
            targetPos = LerpVectors(self._path[i], self._path[i + 1], rate)
            targetPos = self:_GetCorrectGroundPosition(targetPos)
            self.navUnit:SetAbsOrigin(targetPos)
            break
        end

        segmentsSum = segmentsSum + segmentLength
    end

    return GameRules:GetGameFrameTime()
end

function CAdvancedNavSystem:SetTargetPoint(targetPosition)
    if targetPosition == self._targetPos then
        return
    end

    local startPosition = self.navUnit:GetAbsOrigin()
    self._pathPosition = 0
    self._pathLength = 0
    self._targetPos = targetPosition
    self._path = self.aStar:FindPath(startPosition, targetPosition) -- add coroutine with callback? for better perf

    if self._path ~= nil then
        self.navUnit:FadeGesture(ACT_DOTA_IDLE)
        self.navUnit:StartGesture(ACT_DOTA_RUN)
        local pathColor = Vector(0, 0, 0)
        for i = 1, #self._path, 1 do
            DebugDrawSphere(self._path[i], pathColor, 0, 8, false, 3)
            DebugDrawText(self._path[i], tostring(self._path[i].z), true, 5)
            if i == 1 then
                DebugDrawLine_vCol(GetGroundPosition(startPosition, nil), self._path[i], pathColor, false, 3)
            else
                self._pathLength = self._pathLength + VectorDistance(self._path[i - 1], self._path[i])
                DebugDrawLine_vCol(self._path[i - 1], self._path[i], pathColor, false, 3)
            end
        end
    end
end

function CAdvancedNavSystem:_BuildMultiGridMesh()
    DebugDrawClear()
    self.grid:CreateBaseGrid()
    self.grid:CreateOverhangGrid()
    self.grid:LinkGridBetweenLayers()

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
        return false
    end

    DeepPrintTable(args)

    return true
end

function CAdvancedNavSystem:_GetCorrectGroundPosition(pos)
    local traceTable =
    {
        startpos = pos,
        endpos = pos + 100 * Vector(0, 0, -1),
        ignore = self.navUnit
    }

    TraceLine(traceTable)

    if traceTable.hit then
        pos.z = math.max(traceTable.pos.z, pos.z)
    end

    return pos
end
