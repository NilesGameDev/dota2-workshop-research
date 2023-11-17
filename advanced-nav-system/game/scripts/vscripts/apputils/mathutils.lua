mathUtils = {}

function mathUtils.clamp01(value)
    if value < 0 then
        return 0
    end
    if value > 1 then
        return 1
    end

    return value
end

function mathUtils.roundToInt(value)
    if value == 0 then
        return value
    end

    local floor = math.floor(value)
    local diff = value - floor
    if diff <= 0.5 then
        return floor
    end

    return math.ceil(value)
end