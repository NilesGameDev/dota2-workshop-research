local targetActivator = nil

function RegisterBridgeCrossingBehaviour(trigger)
    targetActivator = trigger.activator

    -- fly the npc, accelerate along the z-axis
    print("Starting to make the npc fly!!")
    targetActivator:SetThink(ThinkFlyEntity)
    targetActivator:AddNewModifier(nil, nil, "modifier_bridge_crossing", {})
    -- targetActivator:SetMoveCapability(DOTA_UNIT_CAP_MOVE_FLY)
end

function UnregisterBridgeCrossingBehaviour(trigger)
    if targetActivator == trigger.activator then
        -- targetActivator:SetMoveCapability(DOTA_UNIT_CAP_MOVE_GROUND)
        targetActivator:RemoveModifierByName("modifier_bridge_crossing")
        targetActivator = nil
    end
end

function ThinkFlyEntity()
    if targetActivator == nil then
        return
    end

    local currentPos = targetActivator:GetOrigin()
    targetActivator:SetOrigin(Vector(currentPos.x, currentPos.y, 450)) -- Perhaps find a way to extract the bridge height to add to unit z-axis

    return 0.03 -- approximate per frame call
end