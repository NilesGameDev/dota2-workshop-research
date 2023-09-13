modifier_bridge_crossing = class({})

function modifier_bridge_crossing:OnCreated(params)

end

function modifier_bridge_crossing:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

--------------------------------------------------------------------------------

function modifier_bridge_crossing:GetOverrideAnimation(params)
    return ACT_DOTA_DISABLED
end

--------------------------------------------------------------------------------

function modifier_bridge_crossing:CheckState()
    local state = {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = false
    }

    return state
end
