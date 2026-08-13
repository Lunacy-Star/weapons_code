if not PlayerResources then
    PlayerResources = {}
end

-- ============================================================
-- Net receivers
-- ============================================================

-- Incremental update for a single resource type on a single player
net.Receive(
    "PlayerResourceUpdate",
    function()
        local player = net.ReadEntity()
        if not IsValid(player) then
            return
        end

        local resourceType = net.ReadString()
        local resourceData = net.ReadUInt(16)

        PlayerResources[player:SteamID()] = PlayerResources[player:SteamID()] or {}

        if resourceData == 0 then
            -- Server signalled zero: remove the key to keep the table clean
            PlayerResources[player:SteamID()][resourceType] = nil
        else
            PlayerResources[player:SteamID()][resourceType] = resourceData
        end
    end
)

-- Full sync on initial spawn (and any forced re-sync)
net.Receive(
    "PlayerResourceSync",
    function()
        local allResources = net.ReadTable()
        PlayerResources = allResources
    end
)

-- ============================================================
-- Client query helpers
-- ============================================================

-- Returns the amount of a specific resource for a player (0 if none).
function GetAllResourcesClient(player, resourceType)
    if not IsValid(player) then
        return 0
    end
    if not PlayerResources then
        return 0
    end

    local steamID = player:SteamID()
    if not PlayerResources[steamID] then
        return 0
    end

    return PlayerResources[steamID][resourceType] or 0
end

-- Returns the full { [resourceType] = amount } table for a player.
function GetAllResourcesByPlayerClient(player)
    if not IsValid(player) then
        return {}
    end
    if not PlayerResources then
        return {}
    end

    local steamID = player:SteamID()
    return PlayerResources[steamID] or {}
end

local function GetLocalProfession()
    local ply = LocalPlayer()
    if not IsValid(ply) then
        return ""
    end

    if SMT_GetPlayerProfession and type(SMT_GetPlayerProfession) == "function" then
        return SMT_GetPlayerProfession(ply)
    end

    return ply:GetNWString("Profession", "")
end

-- ============================================================
-- Entity info HUD (show name + description when aiming at a node)
-- ============================================================
local function ShowEntityInfo()
    local ply = LocalPlayer()
    if not IsValid(ply) then
        return
    end

    local tr =
        util.TraceLine(
        {
            start = ply:EyePos(),
            endpos = ply:EyePos() + ply:GetAimVector() * 200,
            filter = ply
        }
    )

    if not IsValid(tr.Entity) then
        return
    end

    local ent = tr.Entity
    if not ent.ShowInfo then
        return
    end
    if tr.Fraction * 200 > 200 then
        return
    end

    local name = ent.PrintName or "Unknown"
    local desc = ent.Description or "No description available"

    local x = ScrW() / 2
    local y = ScrH() / 2 + 300
    local hintY = y + 55

    draw.RoundedBox(8, x - 150, y - 10, 300, 88, Color(0, 0, 0, 200))
    draw.SimpleText(name, "TargetId", x, y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
    draw.SimpleText(desc, "TargetId", x, y + 30, Color(200, 200, 200), TEXT_ALIGN_CENTER)

    if ent.RequiredProfession then
        local profession = GetLocalProfession()
        local canUse = profession == ent.RequiredProfession or profession == "Genius"
        local hint = canUse and "Press E to interact." or "You cannot interact with this."
        local hintColor = canUse and Color(130, 255, 130) or Color(255, 120, 120)

        draw.SimpleText(hint, "DermaDefault", x, hintY, hintColor, TEXT_ALIGN_CENTER)
    end
end

hook.Add("HUDPaint", "ShowEntityInfoHUD", ShowEntityInfo)
