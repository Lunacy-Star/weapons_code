if not PlayerResources then PlayerResources = {} end

net.Receive("PlayerResourceUpdate", function()
    local player = net.ReadEntity()
    if not IsValid(player) then return end

    local resourceType = net.ReadString()
    local resourceData = net.ReadUInt(16)

    PlayerResources[player:SteamID()] = PlayerResources[player:SteamID()] or {}
    PlayerResources[player:SteamID()][resourceType] = resourceData
end)

net.Receive("PlayerResourceSync", function()
    local allResources = net.ReadTable()
    PlayerResources = allResources
end)

function GetAllResourcesClient(player, resourceType)
    if not IsValid(player) then return {} end
    if not PlayerResources then return {} end
    local steamID = player:SteamID()
    if not PlayerResources[steamID] then return {} end

    if PlayerResources[steamID][resourceType] then
        return PlayerResources[steamID][resourceType]
    else
        return 0
    end
end

local function ShowEntityInfo()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local trace = {}
    trace.start = ply:EyePos()
    trace.endpos = trace.start + ply:GetAimVector() * 200 -- 200 units range
    trace.filter = ply
    local tr = util.TraceLine(trace)

    if not IsValid(tr.Entity) then return end

    local ent = tr.Entity
    if ent.ShowInfo and tr.Fraction * 200 <= 200 then -- Check proximity
        local name = ent.PrintName or "Unknown"
        local desc = ent.Description or "No description available"

        local x = ScrW() / 2
        local y = ScrH() / 2 + 300

        draw.RoundedBox(8, x - 150, y - 10, 300, 70, Color(0, 0, 0, 200))

        draw.SimpleText(name, "TargetId", x, y, Color(255, 255, 255),
                        TEXT_ALIGN_CENTER)
        draw.SimpleText(desc, "TargetId", x, y + 30, Color(200, 200, 200),
                        TEXT_ALIGN_CENTER)
    end
end

hook.Add("HUDPaint", "ShowEntityInfoHUD", ShowEntityInfo)
