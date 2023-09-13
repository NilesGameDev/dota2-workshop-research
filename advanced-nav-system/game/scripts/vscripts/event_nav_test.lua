function MoveToPlatform(trigger)
    local player = trigger.activator

    if (player:HasModifier("modifier_bridge_crossing")) then
        return
    end

    local bridgeEnt = thisEntity
    local children = bridgeEnt:GetChildren()
    local infoTarget = children[1]

    if (infoTarget:GetClassname() == "info_target") then
        local moveOrder = {
            UnitIndex = player:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = infoTarget:GetAbsOrigin(),
            Queue = 0
        }

        local moveBridgeOrder = {
            UnitIndex = player:entindex(),
            OrderType = DOTA_UNIT_ORDER_MOVE_TO_POSITION,
            Position = bridgeEnt:GetAbsOrigin(),
            Queue = 1
        }

        ExecuteOrderFromTable(moveOrder)
        ExecuteOrderFromTable(moveBridgeOrder)
    end
end