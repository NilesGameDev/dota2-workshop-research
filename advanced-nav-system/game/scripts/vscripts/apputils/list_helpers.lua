listUtils = {}

function listUtils.remove(arr, obj)
    local foundIndex = listUtils.indexof(arr, obj)
    table.remove(arr, foundIndex)
end

function listUtils.indexof(arr, obj)
    for i = 1, #arr do
        if arr[i] == obj then
            return i
        end
    end
end

function listUtils.contains(arr, compareFunc)
    for _, value in ipairs(arr) do
        if compareFunc(value) then
            return true
        end
    end

    return false
end