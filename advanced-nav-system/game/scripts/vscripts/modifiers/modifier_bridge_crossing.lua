modifier_bridge_crossing = class({})
--------------------------------------------------------------------------------

function modifier_bridge_crossing:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_VISUAL_Z_DELTA,
        MODIFIER_PROPERTY_VISUAL_Z_SPEED_BASE_OVERRIDE
    }

    return funcs
end
