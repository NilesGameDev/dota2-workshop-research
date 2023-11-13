if EventNavTest == nil then
    EventNavTest = class({})
end

require("maprepresentationdata.grid_nav_data")
local gridNavData

function EventNavTest:Activate()
    DebugDrawClear()

    gridNavData = GridNavData(Vector(8192, 8192, 0), 64)
    gridNavData:DebugDrawWorldBound()

    gridNavData:CreateGrid()
    gridNavData:CreateOverhangGrid()
    gridNavData:LinkGridBetweenLayers()
    gridNavData:DebugDrawGrid()
end

EventNavTest:Activate()