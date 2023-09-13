function CastRay(trigger)
    local playerEnt = trigger.activator
    local startVector = playerEnt:GetOrigin() + Vector(0, 0, 32)
    local traceTable =
    {
        startpos = startVector,

        -- Traces from the player position 1000 units in front of the player
        endpos = startVector + RotatePosition(Vector(0, 0, 0), playerEnt:GetAngles(), Vector(1000, 0, 0)),
        ent = Entities:FindByName(nil, "my_rax"),
        mins = Vector(-100, -100, -10),
        maxs = Vector(100, 100, 10)
    }

    TraceCollideable(traceTable)

    if traceTable.hit
    then
        DebugDrawLine(traceTable.startpos, traceTable.pos, 0, 255, 0, false, 1)
        DebugDrawLine(traceTable.pos, traceTable.pos + traceTable.normal * 10, 0, 0, 255, false, 1)

        DebugDrawLine(traceTable.startpos, traceTable.pos, 0, 255, 0, false, 1)
        DebugDrawLine(traceTable.pos, traceTable.pos + traceTable.normal * 10, 0, 0, 255, false, 1)
    else
        DebugDrawLine(traceTable.startpos, traceTable.endpos, 255, 0, 0, false, 1)
    end
end
