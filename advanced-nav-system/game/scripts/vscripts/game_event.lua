if (GameEventManager == nil) then
    GameEventManager = class({})
end

require("advanced_nav_system")

function GameEventManager:OnPanoramaClickPlatformEvent(eventSrcIndex, args)
    print("Event received! Event source index: " .. eventSrcIndex)
    local hero = EntIndexToHScript(args["HeroId"])
    local bridgeEnt = EntIndexToHScript(args["BridgeIndex"])
    AdvancedNavSystem:MoveToPlatform(hero, bridgeEnt)
end

function GameEventManager:OnPanoramaClickEvent(eventSrcIndex, args)
    local hero = EntIndexToHScript(args["HeroId"])
    local x = args["TargetPointX"];
    local y = args["TargetPointY"];
    local z = args["TargetPointZ"];
    local targetPoint = Vector(x, y, z)

    AdvancedNavSystem:IssueMoveToTargetPoint(hero, targetPoint)
end