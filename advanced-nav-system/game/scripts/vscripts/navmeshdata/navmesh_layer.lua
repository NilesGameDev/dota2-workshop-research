if NavMeshLayer == nil then
    NavMeshLayer = class({
        gridData = {};
        zPos = 0;

        constructor = function (gridData, zPos)
            self.gridData = gridData or self.gridData
            self.zPos = zPos or self.zPos
        end
    })
end