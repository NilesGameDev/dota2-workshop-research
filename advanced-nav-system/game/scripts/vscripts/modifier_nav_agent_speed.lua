modifier_nav_agent_speed = class({})

function modifier_nav_agent_speed:DeclareFunctions()
    local funcs = {
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MIN,
        MODIFIER_PROPERTY_MOVESPEED_ABSOLUTE_MAX,
        MODIFIER_PROPERTY_MOVESPEED_LIMIT,
        MODIFIER_PROPERTY_DISABLE_TURNING,
        MODIFIER_PROPERTY_TURN_RATE_OVERRIDE
    }

    return funcs
end

function modifier_nav_agent_speed:CheckState()
    local state = {
        [MODIFIER_STATE_NO_UNIT_COLLISION] = true,
        [MODIFIER_STATE_ROOTED] = true
    }

    return state
end

function modifier_nav_agent_speed:GetModifierMoveSpeed_Absolute()
    return 0
end

function modifier_nav_agent_speed:GetModifierMoveSpeed_AbsoluteMax()
    return 0
end

function modifier_nav_agent_speed:GetModifierMoveSpeed_AbsoluteMin()
    return 0
end

function modifier_nav_agent_speed:GetModifierMoveSpeed_Limit()
    return 0
end

function modifier_nav_agent_speed:GetModifierDisableTurning()
    return 1
end

function modifier_nav_agent_speed:GetModifierTurnRate_Override()
   return 0
end