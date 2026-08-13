if not PlayerResources then
    PlayerResources = {}
end

util.AddNetworkString("PlayerResourceUpdate")
util.AddNetworkString("PlayerResourceSync")

-- ============================================================
-- Persistence
-- ============================================================
local SAVE_FILE = "resource_players.json"
local SAVE_INTERVAL = 120 -- Auto-save every 2 minutes

local function SavePlayerResources()
    local encoded = util.TableToJSON(PlayerResources, true)
    if encoded then
        file.Write(SAVE_FILE, encoded)
    end
end

local function LoadPlayerResources()
    if not file.Exists(SAVE_FILE, "DATA") then
        return
    end

    local raw = file.Read(SAVE_FILE, "DATA")
    if not raw or raw == "" then
        return
    end

    local decoded = util.JSONToTable(raw)
    if decoded then
        PlayerResources = decoded
        print("[ResourceManager] Loaded player resources from " .. SAVE_FILE)
    else
        print("[ResourceManager] WARNING: Failed to parse " .. SAVE_FILE)
    end
end

-- Load immediately on startup
LoadPlayerResources()

-- Periodic auto-save
timer.Create(
    "ResourceManager_AutoSave",
    SAVE_INTERVAL,
    0,
    function()
        SavePlayerResources()
    end
)

-- Save on player disconnect so nothing is lost mid-session
hook.Add(
    "PlayerDisconnected",
    "ResourceManager_SaveOnDisconnect",
    function()
        SavePlayerResources()
    end
)

-- ============================================================
-- Network helpers
-- ============================================================
local function SendPlayerResourcesToPlayer(targetPlayer)
    if not IsValid(targetPlayer) then
        return
    end

    net.Start("PlayerResourceSync")
    net.WriteTable(PlayerResources)
    net.Send(targetPlayer)
end

local function BroadcastPlayerResource(player, resourceType)
    if not IsValid(player) then
        return
    end
    local steamID = player:SteamID()

    net.Start("PlayerResourceUpdate")
    net.WriteEntity(player)
    net.WriteString(resourceType)
    net.WriteUInt(PlayerResources[steamID] and PlayerResources[steamID][resourceType] or 0, 16)
    net.Broadcast()
end

-- ============================================================
-- Public API
-- ============================================================
function AddResourceToPlayer(player, resourceType, amount)
    if not IsValid(player) then
        return
    end

    local sid = player:SteamID()
    PlayerResources[sid] = PlayerResources[sid] or {}
    PlayerResources[sid][resourceType] = PlayerResources[sid][resourceType] or 0
    PlayerResources[sid][resourceType] = math.min(PlayerResources[sid][resourceType] + amount, 1000)

    player:ChatPrint("You got " .. amount .. " " .. resourceType .. "!")

    BroadcastPlayerResource(player, resourceType)
    SavePlayerResources()
end

function RemoveResourceFromPlayer(player, resourceType, amount)
    if not IsValid(player) then
        return
    end

    local sid = player:SteamID()
    PlayerResources[sid] = PlayerResources[sid] or {}
    PlayerResources[sid][resourceType] = PlayerResources[sid][resourceType] or 0

    local newAmount = PlayerResources[sid][resourceType] - amount

    if newAmount <= 0 then
        -- Clean removal: nil out the key rather than storing a zero/negative
        RemoveAllResources(player, resourceType)
    else
        PlayerResources[sid][resourceType] = newAmount
        player:ChatPrint("You lost " .. amount .. " " .. resourceType .. ".")
        BroadcastPlayerResource(player, resourceType)
        SavePlayerResources()
    end
end

function RemoveAllResources(player, resourceType)
    if not IsValid(player) then
        return
    end

    local sid = player:SteamID()
    if PlayerResources[sid] and PlayerResources[sid][resourceType] then
        PlayerResources[sid][resourceType] = nil
        player:ChatPrint("You lost all your " .. resourceType .. ".")
        BroadcastPlayerResource(player, resourceType)
        SavePlayerResources()
    end
end

-- Returns true if the player has at least 1 of the given resource type.
-- (Previously this incorrectly called table.Count on a number value.)
function HasAnyResources(player, resourceType)
    if not IsValid(player) then
        return false
    end

    local sid = player:SteamID()
    if PlayerResources[sid] and PlayerResources[sid][resourceType] and PlayerResources[sid][resourceType] > 0 then
        return true
    end

    return false
end

-- Returns the amount of a specific resource the player holds (0 if none).
function GetAllResourcesByType(player, resourceType)
    if not IsValid(player) then
        return 0
    end
    if not PlayerResources then
        return 0
    end

    local sid = player:SteamID()
    if not PlayerResources[sid] then
        return 0
    end

    return PlayerResources[sid][resourceType] or 0
end

-- Returns the full resource table for the player (empty table if none).
function GetAllResourcesByPlayer(player)
    if not IsValid(player) then
        return {}
    end
    if not PlayerResources then
        return {}
    end

    local sid = player:SteamID()
    return PlayerResources[sid] or {}
end

-- ============================================================
-- Hooks
-- ============================================================
hook.Add(
    "PlayerInitialSpawn",
    "SyncPlayerResourcesOnInitialSpawn",
    function(player)
        SendPlayerResourcesToPlayer(player)
    end
)

-- ============================================================
-- Admin command: /plyGetResources <name> [resource]
-- ============================================================
if SERVER then
    hook.Add(
        "PlayerSay",
        "GetPlayerResource",
        function(ply, text)
            local command = string.lower(text)

            if string.sub(command, 1, 16) ~= "/plygetresources" then
                return
            end

            -- Hide from chat
            local hideCommand = ""

            if not ply:IsAdmin() then
                ply:ChatPrint("You do not have permission to use this command.")
                return hideCommand
            end

            local args = string.Split(string.sub(text, 17), " ")
            -- string.Split on a leading space produces an empty first token; skip it
            while args[1] == "" do
                table.remove(args, 1)
            end

            if #args < 1 then
                ply:ChatPrint("Usage: /plyGetResources <name> [resourceToFind]")
                return hideCommand
            end

            local targetName = string.lower(args[1])
            local resourceToFind = args[2] and string.lower(args[2]) or false
            local playerFound = false

            for _, target in pairs(player.GetAll()) do
                if string.find(string.lower(target:Name()), targetName, 1, true) then
                    playerFound = true

                    if resourceToFind then
                        local amount = GetAllResourcesByType(target, resourceToFind)
                        ply:ChatPrint(target:Name() .. " has:\n" .. resourceToFind .. ": " .. amount)
                    else
                        local resources = GetAllResourcesByPlayer(target)
                        if table.Count(resources) == 0 then
                            ply:ChatPrint(target:Name() .. " has no resources.")
                        else
                            ply:ChatPrint(target:Name() .. " has:")
                            for resource, amount in pairs(resources) do
                                ply:ChatPrint("  " .. resource .. ": " .. amount)
                            end
                        end
                    end
                end
            end

            if not playerFound then
                ply:ChatPrint("Player not found!")
            end

            return hideCommand
        end
    )
end
