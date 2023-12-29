local incrNodeId = 0

if GenericNode == nil then
    GenericNode = class({
        worldPosition = Vector(0, 0, 0);
        gridTraversable = false;
        linkedNodes = {};
        isPortalNode = false;
        parentNode = nil;
        
        gridPosX = 0;
        gridPosY = 0;
        navmeshLayer = 0;

        gCost = 0;
        hCost = 0;

        constructor = function (self, worldPosition, gridTraversable, gridPosX, gridPosY, navmeshLayer)
            self.worldPosition = worldPosition or self.worldPosition
            self.gridTraversable = gridTraversable or self.gridTraversable
            self.gridPosX = gridPosX or self.gridPosX
            self.gridPosY = gridPosY or self.gridPosY
            self.navmeshLayer = navmeshLayer or self.navmeshLayer
            self.gCost = 0
            self.hCost = 0
            self.parentNode = nil
            self.linkedNodes = {}
            self.nodeId = incrNodeId
            incrNodeId = incrNodeId + 1
        end
    })

end

function GenericNode:GetFCost()
    return self.gCost + self.hCost;
end
