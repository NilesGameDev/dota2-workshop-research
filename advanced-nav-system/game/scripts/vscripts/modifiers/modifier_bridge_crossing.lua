modifier_bridge_crossing = class({})
--------------------------------------------------------------------------------

function modifier_bridge_crossing:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
    }

    return funcs
end

function modifier_bridge_crossing:CheckState()
    local state = {
        [MODIFIER_STATE_ALLOW_PATHING_THROUGH_CLIFFS] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = false,
        [MODIFIER_STATE_FORCED_FLYING_VISION] = true
    }

    return state
end
