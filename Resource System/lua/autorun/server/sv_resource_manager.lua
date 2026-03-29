if not PlayerResources then PlayerResources = {} end

util.AddNetworkString("PlayerResourceUpdate")
util.AddNetworkString("PlayerResourceSync")

local function SendPlayerResourcesToPlayer(targetPlayer)
    if not IsValid(targetPlayer) then return end

    net.Start("PlayerResourceSync")
    net.WriteTable(PlayerResources)
    net.Send(targetPlayer)
end

local function BroadcastPlayerResource(player, resourceType)
    if not IsValid(player) then return end
    local steamID = player:SteamID()

    net.Start("PlayerResourceUpdate")
    net.WriteEntity(player)
    net.WriteString(resourceType)
    net.WriteUInt(PlayerResources[steamID] and
                      PlayerResources[steamID][resourceType] or 0, 16)
    net.Broadcast()
end

function AddResourceToPlayer(player, resourceType, amount)
    if not IsValid(player) then return end

    PlayerResources[player:SteamID()] = PlayerResources[player:SteamID()] or {}
    PlayerResources[player:SteamID()][resourceType] =
        PlayerResources[player:SteamID()][resourceType] or 0
    PlayerResources[player:SteamID()][resourceType] = math.min(
                                                          PlayerResources[player:SteamID()][resourceType] +
                                                              amount, 1000)

    player:ChatPrint("You got " .. amount .. " " .. resourceType .. "!")

    BroadcastPlayerResource(player, resourceType)
end

function RemoveResourceFromPlayer(player, resourceType, amount)
    if not IsValid(player) then return end

    PlayerResources[player:SteamID()] = PlayerResources[player:SteamID()] or {}
    PlayerResources[player:SteamID()][resourceType] =
        PlayerResources[player:SteamID()][resourceType] or 0
    PlayerResources[player:SteamID()][resourceType] =
        PlayerResources[player:SteamID()][resourceType] - amount

    player:ChatPrint("You lost " .. amount .. " " .. resourceType .. "")

    if PlayerResources[player:SteamID()][resourceType] <= 0 then
        RemoveAllResources(player, resourceType)
    else
        BroadcastPlayerResource(player, resourceType)
    end
end

function RemoveAllResources(player, resourceType)
    if not IsValid(player) then return end

    if PlayerResources[player:SteamID()] and
        PlayerResources[player:SteamID()][resourceType] then
        PlayerResources[player:SteamID()][resourceType] = nil

        BroadcastPlayerResource(player, resourceType)
    end
end

function HasAnyResources(player, resourceType)
    if not IsValid(player) then return false end

    local steamID = player:SteamID()
    if PlayerResources[steamID] and
        table.Count(PlayerResources[steamID][resourceType]) > 0 then
        return true
    else
        return false
    end
end

function GetAllResourcesByType(player, resourceType)
    if not IsValid(player) then return 0 end
    if not PlayerResources then return 0 end
    local steamID = player:SteamID()
    if not PlayerResources[steamID] then return 0 end

    if PlayerResources[steamID][resourceType] then
        return PlayerResources[steamID][resourceType]
    else
        return 0
    end
end

function GetAllResourcesByPlayer(player)
    if not IsValid(player) then return {} end
    if not PlayerResources then return {} end
    local steamID = player:SteamID()
    if not PlayerResources[steamID] then return {} end

    if PlayerResources[steamID] then
        return PlayerResources[steamID]
    else
        return {}
    end
end

hook.Add("PlayerInitialSpawn", "SyncPlayerResourcesOnInitialSpawn",
         function(player) SendPlayerResourcesToPlayer(player) end)

if SERVER then
    hook.Add("PlayerSay", "GetPlayerResource", function(ply, text)
        local command = string.lower(text)

        if string.sub(command, 1, 16) == "/plygetresources" then
            -- Hide the command from chat
            local hideCommand = ""

            -- Check if the player is an admin
            if ply:IsAdmin() then
                local args = string.Split(string.sub(text, 17), " ")
                if #args >= 2 then
                    local targetName = string.lower(args[2])
                    local resourceToFind = args[3] or false

                    local playerFound = false -- Flag to check if any player is found

                    for _, target in pairs(player.GetAll()) do
                        if string.find(string.lower(target:Name()), targetName,
                                       1, true) then
                            if resourceToFind then
                                resourceToFind = string.lower(resourceToFind)
                                local resourceAmount =
                                    GetAllResourcesByType(target, resourceToFind)

                                ply:ChatPrint(
                                    target:Name() .. " has: \n" ..
                                        resourceToFind .. ": " .. resourceAmount)
                            else
                                ply:ChatPrint(target:Name() .. " has:")
                                for resource, amount in pairs(
                                                            GetAllResourcesByPlayer(
                                                                target)) do
                                    ply:ChatPrint(resource .. ": " .. amount)
                                end
                            end
                            playerFound = true
                        end
                    end

                    if not playerFound then
                        ply:ChatPrint("Player not found!")
                    end
                else
                    ply:ChatPrint(
                        "Usage: /plyGetResources <name> <resourceToFind>")
                end
            else
                ply:ChatPrint("You do not have permission to use this command.")
            end

            return hideCommand -- Hide the command from the chat
        end
    end)
end
