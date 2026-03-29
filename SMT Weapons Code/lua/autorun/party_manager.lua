if not PlayerParties then PlayerParties = {} end
if not PartyConsecutive then PartyConsecutive = 0 end

-- Player Party variable composition
-- PlayerParties[PartyId] for unique party
-- PlayerParties[PartyId][Members] is a nested array for a list of members. This is not turn order list.
-- PlayerParties[PartyId][Members][SteamId] for party member

-- Party Id is just a unique number that should not be reset until server restart.
-- The PartyConsecutives is the current number that will be given to a new party when it is formed.

if SERVER then
    util.AddNetworkString("PlayerPartyUpdate")
    util.AddNetworkString("PlayerPartyRemove")
    util.AddNetworkString("PlayerPartyModify")
    util.AddNetworkString("PlayerPartiesSync")

    local function SendPlayerPartiesToPlayer(targetPlayer)
        if not IsValid(targetPlayer) then return end

        net.Start("PlayerPartiesSync")
        net.WriteTable(PlayerParties)
        net.WriteInt(PartyConsecutive, 32)
        net.Send(targetPlayer)
    end

    local function BroadcastPlayerParty(player, partyId)
        if not IsValid(player) then return end
        local steamID = player:SteamID()

        net.Start("PlayerPartyUpdate")
        net.WriteEntity(player)
        net.WriteString(partyId)
        net.WriteInt(PartyConsecutive, 32)
        net.WriteTable(PlayerParties[partyId])
        net.Broadcast()
    end

    function CreateParty(player)
        if not IsValid(player) then return end
        local partyId = PartyConsecutive
        PartyConsecutive = PartyConsecutive + 1

        PlayerParties[partyId] = {
            PartyName = player:Nick() .. "'s Party",
            PartyLead = player:SteamID(),
            Members = {}
        }

        PlayerParties[partyId]["Members"][player:SteamID()] = player

        PrintTable(PlayerParties)

        BroadcastPlayerParty(player, partyId)
    end

    function AssignParty(player, partyId)
        if not IsValid(player) then return end
        if IsPlayerInAnyParty(player) then
            local pastPartyId = IsPlayerInAnyParty(player)
            RemoveFromParty(player, pastPartyId)
        end

        PlayerParties[partyId] = PlayerParties[partyId] or {}
        PlayerParties[partyId]["Members"][player:SteamID()] = player

        BroadcastPlayerParty(player, partyId)
    end

    function RemoveFromParty(player, partyId)
        if not IsValid(player) then return end

        if PlayerParties[partyId] and
            PlayerParties[partyId]["Members"][player:SteamID()] then
            PlayerParties[partyId]["Members"][player:SteamID()] = nil
            player:ChatPrint("You've left the party!")
            for memberId, memberData in pairs(PlayerParties[partyId]["Members"]) do
                if IsValid(memberData) then
                    if PlayerParties[partyId]["PartyLead"] == player:SteamID() then
                        PlayerParties[partyId]["PartyLead"] = memberId
                        memberData:ChatPrint("You are now the party leader!")
                    end
                    memberData:ChatPrint(player:Nick() .. " has left the party!")
                end
            end

            BroadcastPlayerParty(player, partyId)
        end
    end

    function GetAllPartyData(player, partyId)
        if not IsValid(player) then return {} end
        if not PlayerParties then return {} end
        if not PlayerParties[partyId] then return {} end

        if PlayerParties[partyId] then
            return PlayerParties[partyId]
        else
            return {}
        end
    end

    function IsPlayerInAnyParty(player)
        if not IsValid(player) then return false end

        local steamID = player:SteamID()

        for partyId, partyData in pairs(PlayerParties) do
            if partyData["Members"] and partyData["Members"][steamID] then
                return partyId
            end
        end

        return false
    end

    hook.Add("PlayerInitialSpawn", "SyncPlayerPartiesOnInitialSpawn",
             function(player) SendPlayerPartiesToPlayer(player) end)
end

if CLIENT then

    net.Receive("PlayerPartyUpdate", function()
        local player = net.ReadEntity()
        if not IsValid(player) then return end

        local partyId = net.ReadString()
        local currentConsecutive = net.ReadInt(32)
        local partyData = net.ReadTable()

        PlayerParties[partyId] = PlayerParties[partyId] or {}
        PlayerParties[partyId] = partyData
        PartyConsecutive = currentConsecutive
    end)

    net.Receive("PlayerPartiesSync", function()
        local allParties = net.ReadTable()
        PlayerParties = allParties
        local currentConsecutive = net.ReadInt(32)
        PartyConsecutive = currentConsecutive
    end)

    function GetAllPartyDataClient(player, partyId)
        if not IsValid(player) then return {} end
        if not PlayerParties then return {} end
        if not PlayerParties[partyId] then return {} end

        if PlayerParties[partyId] then
            return PlayerParties[partyId]
        else
            return {}
        end
    end
end
