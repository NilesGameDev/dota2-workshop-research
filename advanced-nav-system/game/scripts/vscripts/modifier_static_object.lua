modifier_static_object = class({})
--------------------------------------------------------------------------------

function modifier_static_object:CheckState()
    local state = {
        [MODIFIER_STATE_INVULNERABLE] = true,
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true
    }

    return state
end
