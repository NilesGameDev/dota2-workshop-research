modifier_advanced_pathing = class({})
--------------------------------------------------------------------------------

function modifier_advanced_pathing:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_DISABLE_AUTOATTACK
    }

    return funcs
end

function modifier_advanced_pathing:GetDisableAutoAttack()
    return 1
end