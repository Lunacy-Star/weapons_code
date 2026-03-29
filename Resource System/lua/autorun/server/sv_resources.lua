function PickUpResourceValidity(ply, slotType, resourceName, amount)
    local resourceLimit = 1000
    local plyResource = GetAllResourcesByType(ply, resourceName)

    if plyResource >= resourceLimit then
        ply:ChatPrint("You've reached your " .. slotType .. " limit!")
        return false
    end

    return true
end
