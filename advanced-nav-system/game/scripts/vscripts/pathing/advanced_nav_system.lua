if (AdvancedNavSystem == nil) then
    AdvancedNavSystem = class({})
end

require("pathing.astar_pathing")
require("maprepresentationdata.grid_nav_data")

function AdvancedNavSystem:Activate()
    self.grid = GridNavData(Vector(8192, 8192, 0), 64)
    self.aStar = AStarPathing(self.grid)
end
