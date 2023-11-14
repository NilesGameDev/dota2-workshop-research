if NavMeshDebug == nil then
    NavMeshDebug = class({})
end

function NavMeshDebug:OnMouseMoveEvent(eventSrcIndex, args)
    local mousePosRaw = args["MouseWorldPosition"]
    if mousePosRaw == nil then
        return
    end

    local mousePos = Vector(mousePosRaw["0"], mousePosRaw["1"], mousePosRaw["2"])
    self:SendNavMeshDataToUI(mousePos)
end

function NavMeshDebug:SendNavMeshDataToUI(mousePos)
    local gridPosX = GridNav:WorldToGridPosX(mousePos.x)
    local gridPosY = GridNav:WorldToGridPosX(mousePos.y)

    if PlayerResource.player_id == nil then
        return
    end
    local playerEnt = PlayerResource:GetPlayer(PlayerResource.player_id)
    local gridPos = {
        ["x"] = gridPosX,
        ["y"] = gridPosY
    }

    CustomGameEventManager:Send_ServerToPlayer(playerEnt, "GridNavData", {data = gridPos})
end

CustomGameEventManager:RegisterListener("PanoramaMouseMoveEvent", function (...)
    return NavMeshDebug:OnMouseMoveEvent(...)
end)