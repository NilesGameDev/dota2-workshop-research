if CursorIndicator == nil then
    CursorIndicator = class({})
end

function CursorIndicator:Activate()
    CustomGameEventManager:RegisterListener("PanoramaMouseHoverGridEvent", function(...)
        return CursorIndicator:OnMouseHoverEvent(...)
    end)
end

function CursorIndicator:OnMouseHoverEvent(eventSrcIndex, args)
    local mouseWorldPos = args["MouseWorldPos"]
    if mouseWorldPos == nil then
        return
    end

    -- TODO: move to a better place
    local cellSize = 128;
    local followPos = Vector(mouseWorldPos["0"], mouseWorldPos["1"], mouseWorldPos["2"])
    local gridX = math.floor(followPos.x / cellSize)
    local gridY = math.floor(followPos.y / cellSize)
    local followAbsPos = Vector(gridX * cellSize + 64, gridY * cellSize + 64, 144) 
    thisEntity:SetAbsOrigin(followAbsPos)
end

CursorIndicator:Activate()