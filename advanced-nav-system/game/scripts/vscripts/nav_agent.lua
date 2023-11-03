if NavAgent == nil then
    NavAgent = class({})
end

local nextGoalIndex = -1
local isGoalFinished = false
local goalPaths = {}

function NavAgent:Init()
    self:CreateAgentUnit()
    ListenToGameEvent("dota_npc_goal_reached", Dynamic_Wrap(self, "OnNavAgentGoalReached"), self)
end

function NavAgent:CreateAgentUnit()
    -- TODO: refactor this by passing hero index rather than getting from PlayerResource
    local currentHeroEntIndex = PlayerResource.hero_index
    local heroEnt = EntIndexToHScript(currentHeroEntIndex)
    local heroGroundPos = GetGroundPosition(heroEnt:GetAbsOrigin(), nil)
    self.heroEnt = heroEnt

    CreateUnitByNameAsync("npc_dota_nav_agent", heroGroundPos, true, heroEnt, heroEnt, heroEnt:GetTeamNumber(),
        function(agent)
            self.agentEnt = agent
            self.agentEntIndex = self.agentEnt:entindex()
            self.totalPathLength = 0
            self.goalIndex = nil
            self.currentPathLength = 0

            self.agentEnt:AddNewModifier(nil, nil, "modifier_nav_agent_speed", {})
            self.agentEnt:SetShouldComputeRemainingPathLength(true)
            self.agentEnt:SetThink("ThinkUpdate", self, 0)

            self:CancelCurrentGoalCalc()
        end
    )
end

function NavAgent:ThinkUpdate()
    self:NavAgentJumpToNextGoal()
    self:CalculateNewPathLength()

    return 0.03
end

function NavAgent:SumPathLength()
    self.totalPathLength = self.totalPathLength + self.agentEnt:GetRemainingPathLength()
    print(self.totalPathLength)
    return nil
end

function NavAgent:GetAgentPathLength()
    return self.totalPathLength
end

function NavAgent:CalculateNewPathLength()
    local agentPathLength = self.agentEnt:GetRemainingPathLength()
    if self.currentPathLength == agentPathLength then
        return
    end

    self.currentPathLength = agentPathLength
    print("Agent current path length:", self.currentPathLength)
end

function NavAgent:NavAgentJumpToNextGoal()
    if self.goalIndex == nextGoalIndex then
        return
    end

    self.goalIndex = nextGoalIndex
    self:SumPathLength()

    local nextGoal = EntIndexToHScript(nextGoalIndex)
    if nextGoal ~= nil then
        self.agentEnt:SetAbsOrigin(nextGoal:GetAbsOrigin())
    end
end

function NavAgent:CancelCurrentGoalCalc()
    self.totalPathLength = 0
    goalPaths = {}
    nextGoalIndex = -1
    
    local hero = EntIndexToHScript(PlayerResource.hero_index)
    if hero ~= nil then
        self.agentEnt:SetAbsOrigin(GetGroundPosition(hero:GetAbsOrigin(), nil))
    end
end

function NavAgent:MoveToTargetPoint(targetPoint, heroPos)
    local gridnavPathWaypointsArr = {}
    local normalGridNavLength
    local pathCornerWayPointsArr = {}
    local pathCornersLength
    local navAgent = self.agentEnt
    self:CancelCurrentGoalCalc()

    navAgent:MoveToPosition(targetPoint)
    navAgent:MoveToPosition(targetPoint)
    print(navAgent:GetRemainingPathLength())
    -- while navAgent:GetRemainingPathLength() == 0 do
    --     if navAgent:GetRemainingPathLength() ~= 0 then
    --         break
    --     end
    -- end
    -- normalGridNavLength = navAgent:GetRemainingPathLength()
    -- gridnavPathWaypointsArr[#gridnavPathWaypointsArr + 1] = targetPoint

    -- local nearestPathCorner = Entities:FindByClassnameNearest("path_corner", playerPos, normalGridNavLength)
    -- if nearestPathCorner == nil then
    --     return gridnavPathWaypointsArr
    -- end

    -- isGoalFinished = false
    -- navAgent:SetAbsOrigin(heroPos)
    -- navAgent:SetInitialGoalEntity(nearestPathCorner)
    -- while navAgent:GetRemainingPathLength() == 0 do
    --     if navAgent:GetRemainingPathLength() ~= 0 then
    --         break
    --     end
    -- end
    -- self:SumPathLength()
    -- navAgent:SetAbsOrigin(nearestPathCorner:GetAbsOrigin())
    -- while not isGoalFinished do
    --     if isGoalFinished then
    --         break
    --     end
    -- end
    -- navAgent:MoveToPosition(targetPoint)
    -- while navAgent:GetRemainingPathLength() == 0 do
    --     if navAgent:GetRemainingPathLength() ~= 0 then
    --         break
    --     end
    -- end
    -- self:SumPathLength()

    -- pathCornersLength = self:GetAgentPathLength()
    -- for i=1,#goalPaths do
    --     pathCornerWayPointsArr[#pathCornerWayPointsArr+1] = goalPaths[i]
    -- end

    -- if (pathCornersLength < normalGridNavLength) then
    --     return pathCornerWayPointsArr
    -- end

    -- return gridnavPathWaypointsArr
end


-- Event Listener Functions
function NavAgent:OnNavAgentGoalReached(event)
    print("OnNavAgentGoalReached")
    DeepPrintTable(event)

    local pathCorner = EntIndexToHScript(event.goal_entindex)
    local npcIdx = event.npc_entindex
    local nextGoalIdx = event.next_goal_entindex
    goalPaths[#goalPaths+1] = pathCorner:GetAbsOrigin()

    if self.agentEntIndex ~= npcIdx or nextGoalIdx == -1 then
        nextGoalIndex = nextGoalIdx
        isGoalFinished = true
        return
    end

    nextGoalIndex = nextGoalIdx
end
