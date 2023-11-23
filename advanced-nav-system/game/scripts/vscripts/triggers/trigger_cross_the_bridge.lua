local targetActivator = nil

function RegisterBridgeCrossingBehaviour(trigger)
    targetActivator = trigger.activator

    -- fly the npc, accelerate along the z-axis
    targetActivator:AddNewModifier(nil, nil, "modifier_bridge_crossing", {})
end

function UnregisterBridgeCrossingBehaviour(trigger)
    if targetActivator == trigger.activator and targetActivator ~= nil then
        targetActivator:RemoveModifierByName("modifier_bridge_crossing")
        targetActivator = nil
    end
end
