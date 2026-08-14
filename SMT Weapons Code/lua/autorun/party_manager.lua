if not PlayerParties then PlayerParties = {} end
if not PartyConsecutive then PartyConsecutive = 0 end

-- Player Party variable composition
-- PlayerParties[PartyId] for unique party
-- PlayerParties[PartyId][Members] is a nested array for a list of members. This is not turn order list.
-- PlayerParties[PartyId][Members][SteamId] for party member
-- PlayerParties[PartyId][Order] is an ordered array of SteamIds - this IS the turn order/placement list.
--   The index of a SteamId within Order is that member's placement (1 = first turn).
-- PlayerParties[PartyId][PartyLead] is the SteamId of the current party leader.

-- Party Id is a unique, ever-increasing number (stored as a string table key) that should not
-- be reset until server restart. PartyConsecutive is the next number that will be handed out.

-- PlayerParties[PartyId][TotalKilodevil] is the summed kilodevil cost of all current members'
-- assigned characters. New members may not push this above the smt_party_kilodevil_limit ConVar.
-- Replicated so the client can display "current / limit" in the Party tab. Changing it requires
-- server console/RCON access or an admin using /partylimit - a plain client console command
-- cannot alter a server ConVar remotely.
local PartyKilodevilLimitConVar = CreateConVar(
    "smt_party_kilodevil_limit",
    "500",
    bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED),
    "Maximum total kilodevil a party's members may have combined.",
    1,
    100000
)

function GetPartyKilodevilLimit()
    return PartyKilodevilLimitConVar:GetInt()
end

if SERVER then
    util.AddNetworkString("PlayerPartyUpdate")
    util.AddNetworkString("PlayerPartyRemove")
    util.AddNetworkString("PlayerPartyModify")
    util.AddNetworkString("PlayerPartiesSync")
    util.AddNetworkString("PartyInvitePrompt")
    util.AddNetworkString("PartyInviteResponse")

    -- SteamId -> {partyId, inviterSteamID, inviterName}. Cleared on response or after INVITE_EXPIRE_TIME.
    local PartyPendingInvites = {}
    local INVITE_EXPIRE_TIME = 30
    local MAX_PARTY_NAME_LENGTH = 40

    local function SendPlayerPartiesToPlayer(targetPlayer)
        if not IsValid(targetPlayer) then return end

        net.Start("PlayerPartiesSync")
        net.WriteTable(PlayerParties)
        net.WriteInt(PartyConsecutive, 32)
        net.Send(targetPlayer)
    end

    -- Global (not local) so other files - e.g. character_selection_sv.lua,
    -- which needs to re-broadcast a party after a member's kilodevil changes -
    -- can push an updated snapshot without duplicating this logic.
    function BroadcastPlayerParty(player, partyId)
        if not IsValid(player) then return end

        net.Start("PlayerPartyUpdate")
        net.WriteEntity(player)
        net.WriteString(partyId)
        net.WriteInt(PartyConsecutive, 32)
        net.WriteTable(PlayerParties[partyId])
        net.Broadcast()
    end

    -- A player's kilodevil cost is their assigned character's `kilodevil` field,
    -- defaulting to 100 (the standard human cost) if unset or unassigned.
    function GetPlayerKilodevil(ply)
        if not IsValid(ply) then return 100 end

        local charID = ply:GetNWString("AssignedCharacter", "")
        if charID ~= "" and CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
            return CHARACTERS.List[charID].kilodevil or 100
        end

        return 100
    end

    -- Recomputes and stores a party's total kilodevil from its current members'
    -- assigned characters (never trusted as an incrementally-maintained value,
    -- since a member's cost can change any time they switch characters).
    function RecalculatePartyKilodevil(partyId)
        local party = PlayerParties[partyId]
        if not party then return 0 end

        local total = 0
        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) then
                total = total + GetPlayerKilodevil(memberData)
            end
        end

        party["TotalKilodevil"] = total
        return total
    end

    local function RemovePartyOrderEntry(partyId, steamID)
        local order = PlayerParties[partyId] and PlayerParties[partyId]["Order"]
        if not order then return end

        for i, sid in ipairs(order) do
            if sid == steamID then
                table.remove(order, i)
                return
            end
        end
    end

    function CreateParty(player)
        if not IsValid(player) then return end
        local partyId = tostring(PartyConsecutive)
        PartyConsecutive = PartyConsecutive + 1

        PlayerParties[partyId] = {
            PartyName = player:Nick() .. "'s Party",
            PartyLead = player:SteamID(),
            Members = {},
            Order = {},
            TotalKilodevil = 0
        }

        PlayerParties[partyId]["Members"][player:SteamID()] = player
        table.insert(PlayerParties[partyId]["Order"], player:SteamID())
        PlayerParties[partyId]["TotalKilodevil"] = GetPlayerKilodevil(player)

        BroadcastPlayerParty(player, partyId)
        return partyId
    end

    -- Adding a member is not allowed to push the party's total kilodevil
    -- above smt_party_kilodevil_limit. The capacity check runs before the
    -- player is pulled out of any existing party, so a rejected join never
    -- leaves them stranded without a party.
    function AssignParty(player, partyId)
        if not IsValid(player) then return false end

        local party = PlayerParties[partyId]
        if not party then return false end

        local pastPartyId = IsPlayerInAnyParty(player)
        if pastPartyId == partyId then return true end

        local memberKD = GetPlayerKilodevil(player)
        local currentTotal = RecalculatePartyKilodevil(partyId)
        local limit = GetPartyKilodevilLimit()

        if currentTotal + memberKD > limit then
            player:ChatPrint(
                "You couldn't join " .. (party["PartyName"] or "the party") ..
                " - not enough kilodevil capacity (" .. currentTotal .. "/" .. limit ..
                ", this would need " .. memberKD .. " more)."
            )
            return false
        end

        if pastPartyId then
            RemoveFromParty(player, pastPartyId)
        end

        party["Members"][player:SteamID()] = player
        party["Order"] = party["Order"] or {}
        table.insert(party["Order"], player:SteamID())
        party["TotalKilodevil"] = currentTotal + memberKD

        player:ChatPrint("You joined " .. (party["PartyName"] or "the party") .. "!")
        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) and memberData ~= player then
                memberData:ChatPrint(player:Nick() .. " has joined the party!")
            end
        end

        BroadcastPlayerParty(player, partyId)
        return true
    end

    function RemoveFromParty(player, partyId)
        if not IsValid(player) then return end

        local party = PlayerParties[partyId]
        if not party or not party["Members"][player:SteamID()] then return end

        local steamID = player:SteamID()
        party["Members"][steamID] = nil
        RemovePartyOrderEntry(partyId, steamID)

        player:ChatPrint("You've left the party!")

        -- Nobody left in the party - dissolve it entirely
        if not next(party["Members"]) then
            PlayerParties[partyId] = nil

            net.Start("PlayerPartyRemove")
            net.WriteString(partyId)
            net.Broadcast()
            return
        end

        -- Hand leadership to whoever is now first in the turn order
        if party["PartyLead"] == steamID then
            local newLeadSteamID = party["Order"][1]
            party["PartyLead"] = newLeadSteamID

            local newLead = party["Members"][newLeadSteamID]
            if IsValid(newLead) then
                newLead:ChatPrint("You are now the party leader!")
            end
        end

        RecalculatePartyKilodevil(partyId)

        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) then
                memberData:ChatPrint(player:Nick() .. " has left the party!")
            end
        end

        BroadcastPlayerParty(player, partyId)
    end

    -- Removes targetSteamID from the party. Only the party leader may do this,
    -- and the leader cannot kick themselves (use RemoveFromParty/DisbandParty instead).
    function KickFromParty(player, partyId, targetSteamID)
        if not IsValid(player) then return false end
        local party = PlayerParties[partyId]
        if not party then return false end
        if party["PartyLead"] ~= player:SteamID() then return false end
        if targetSteamID == player:SteamID() then return false end
        if not party["Members"][targetSteamID] then return false end

        local targetPlayer = party["Members"][targetSteamID]
        local targetName = IsValid(targetPlayer) and targetPlayer:Nick() or "A member"

        party["Members"][targetSteamID] = nil
        RemovePartyOrderEntry(partyId, targetSteamID)

        if IsValid(targetPlayer) then
            targetPlayer:ChatPrint("You have been kicked from the party by " .. player:Nick() .. ".")
        end

        RecalculatePartyKilodevil(partyId)

        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) then
                memberData:ChatPrint(targetName .. " was kicked from the party by " .. player:Nick() .. ".")
            end
        end

        BroadcastPlayerParty(player, partyId)
        return true
    end

    -- Hands party leadership to targetSteamID. Only the current leader may do this.
    function SetPartyLeader(player, partyId, targetSteamID)
        if not IsValid(player) then return false end
        local party = PlayerParties[partyId]
        if not party then return false end
        if party["PartyLead"] ~= player:SteamID() then return false end
        if not party["Members"][targetSteamID] then return false end

        party["PartyLead"] = targetSteamID

        local targetPlayer = party["Members"][targetSteamID]
        local targetName = IsValid(targetPlayer) and targetPlayer:Nick() or "A member"

        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) then
                if memberData == targetPlayer then
                    memberData:ChatPrint("You are now the party leader!")
                else
                    memberData:ChatPrint(targetName .. " is now the party leader!")
                end
            end
        end

        BroadcastPlayerParty(player, partyId)
        return true
    end

    -- Moves targetSteamID to newPosition within the turn order. Only the leader may do this.
    function MovePartyMember(player, partyId, targetSteamID, newPosition)
        if not IsValid(player) then return false end
        local party = PlayerParties[partyId]
        if not party then return false end
        if party["PartyLead"] ~= player:SteamID() then return false end
        if not party["Members"][targetSteamID] then return false end

        local order = party["Order"]
        local currentIndex
        for i, sid in ipairs(order) do
            if sid == targetSteamID then
                currentIndex = i
                break
            end
        end
        if not currentIndex then return false end

        newPosition = math.Clamp(math.floor(tonumber(newPosition) or currentIndex), 1, #order)
        if newPosition == currentIndex then return true end

        table.remove(order, currentIndex)
        table.insert(order, newPosition, targetSteamID)

        BroadcastPlayerParty(player, partyId)
        return true
    end

    -- Disbands the whole party. Only the leader may do this.
    function DisbandParty(player, partyId)
        if not IsValid(player) then return false end
        local party = PlayerParties[partyId]
        if not party then return false end
        if party["PartyLead"] ~= player:SteamID() then return false end

        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) and memberData ~= player then
                memberData:ChatPrint(player:Nick() .. " has disbanded the party.")
            end
        end
        player:ChatPrint("You've disbanded the party.")

        PlayerParties[partyId] = nil

        net.Start("PlayerPartyRemove")
        net.WriteString(partyId)
        net.Broadcast()
        return true
    end

    -- Forcibly removes target from whatever party they're currently in,
    -- regardless of who leads it. Intended for admin use only - callers are
    -- responsible for their own permission checks before calling this.
    function AdminRemoveFromParty(admin, target)
        if not IsValid(target) then return false end

        local partyId = IsPlayerInAnyParty(target)
        if not partyId then return false end

        local party = PlayerParties[partyId]
        local steamID = target:SteamID()
        local adminName = IsValid(admin) and admin:Nick() or "an admin"

        party["Members"][steamID] = nil
        RemovePartyOrderEntry(partyId, steamID)

        target:ChatPrint("You have been removed from your party by " .. adminName .. ".")

        if not next(party["Members"]) then
            PlayerParties[partyId] = nil

            net.Start("PlayerPartyRemove")
            net.WriteString(partyId)
            net.Broadcast()
            return true
        end

        if party["PartyLead"] == steamID then
            local newLeadSteamID = party["Order"][1]
            party["PartyLead"] = newLeadSteamID

            local newLead = party["Members"][newLeadSteamID]
            if IsValid(newLead) then
                newLead:ChatPrint("You are now the party leader!")
            end
        end

        RecalculatePartyKilodevil(partyId)

        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) then
                memberData:ChatPrint(target:Nick() .. " was removed from the party by " .. adminName .. ".")
            end
        end

        BroadcastPlayerParty(target, partyId)
        return true
    end

    -- Renames the party. Only the current leader may do this.
    function RenameParty(player, partyId, newName)
        if not IsValid(player) then return false end
        local party = PlayerParties[partyId]
        if not party then return false end
        if party["PartyLead"] ~= player:SteamID() then return false end

        newName = string.Trim(newName or "")
        if newName == "" then return false end
        if #newName > MAX_PARTY_NAME_LENGTH then
            newName = string.sub(newName, 1, MAX_PARTY_NAME_LENGTH)
        end

        party["PartyName"] = newName

        for _, memberData in pairs(party["Members"]) do
            if IsValid(memberData) then
                memberData:ChatPrint(player:Nick() .. " renamed the party to \"" .. newName .. "\".")
            end
        end

        BroadcastPlayerParty(player, partyId)
        return true
    end

    -- Invites target to inviter's party (creating one for the inviter if they aren't in one).
    -- Only the party leader may invite. Returns success, feedbackMessage for the inviter.
    function InvitePlayerToParty(inviter, target)
        if not IsValid(inviter) or not inviter:IsPlayer() then return false end
        if not IsValid(target) or not target:IsPlayer() then
            return false, "That player isn't valid."
        end
        if target == inviter then
            return false, "You can't invite yourself."
        end

        if IsPlayerInAnyParty(target) then
            return false, target:Nick() .. " is already in a party."
        end

        local pending = PartyPendingInvites[target:SteamID()]
        if pending and timer.Exists("PartyInviteExpire_" .. target:SteamID()) then
            return false, target:Nick() .. " already has a pending party invite."
        end

        local partyId = IsPlayerInAnyParty(inviter)
        if not partyId then
            partyId = CreateParty(inviter)
        else
            local party = PlayerParties[partyId]
            if party["PartyLead"] ~= inviter:SteamID() then
                return false, "Only the party leader can invite new members."
            end
        end

        local party = PlayerParties[partyId]

        -- Advisory only - AssignParty re-checks this authoritatively at accept
        -- time, since capacity can change while the invite is pending.
        local memberKD = GetPlayerKilodevil(target)
        local currentTotal = RecalculatePartyKilodevil(partyId)
        local limit = GetPartyKilodevilLimit()
        if currentTotal + memberKD > limit then
            return false, "Inviting " .. target:Nick() .. " would exceed the party's kilodevil limit (" ..
                currentTotal .. "/" .. limit .. ", needs " .. memberKD .. " more)."
        end

        PartyPendingInvites[target:SteamID()] = {
            partyId = partyId,
            inviterSteamID = inviter:SteamID(),
            inviterName = inviter:Nick()
        }

        timer.Create("PartyInviteExpire_" .. target:SteamID(), INVITE_EXPIRE_TIME, 1, function()
            PartyPendingInvites[target:SteamID()] = nil
            if IsValid(target) then
                target:ChatPrint("Your party invite from " .. inviter:Nick() .. " has expired.")
            end
        end)

        net.Start("PartyInvitePrompt")
        net.WriteString(partyId)
        net.WriteString(party["PartyName"] or "a party")
        net.WriteString(inviter:Nick())
        net.Send(target)

        return true, "Invite sent to " .. target:Nick() .. "."
    end

    -- Handles a target player's accept/decline response to their pending invite.
    local function RespondToPartyInvite(target, accepted)
        if not IsValid(target) then return end

        local pending = PartyPendingInvites[target:SteamID()]
        if not pending then
            target:ChatPrint("You don't have a pending party invite.")
            return
        end

        PartyPendingInvites[target:SteamID()] = nil
        timer.Remove("PartyInviteExpire_" .. target:SteamID())

        local inviter = player.GetBySteamID and player.GetBySteamID(pending.inviterSteamID)

        if not accepted then
            target:ChatPrint("You declined the party invite from " .. pending.inviterName .. ".")
            if IsValid(inviter) then
                inviter:ChatPrint(target:Nick() .. " declined your party invite.")
            end
            return
        end

        if not PlayerParties[pending.partyId] then
            target:ChatPrint("That party no longer exists.")
            return
        end

        if IsPlayerInAnyParty(target) then
            target:ChatPrint("You're already in a party.")
            return
        end

        AssignParty(target, pending.partyId)
    end

    net.Receive("PartyInviteResponse", function(len, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end
        local accepted = net.ReadBool()
        RespondToPartyInvite(ply, accepted)
    end)

    function GetAllPartyData(player, partyId)
        if not IsValid(player) then return {} end
        if not PlayerParties then return {} end
        if not PlayerParties[partyId] then return {} end

        return PlayerParties[partyId]
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

    hook.Add("PlayerDisconnected", "RemoveFromPartyOnPlayerDisconnect", function(player)
        local partyId = IsPlayerInAnyParty(player)
        if partyId then
            RemoveFromParty(player, partyId)
        end
    end)

    -- A death that actually came from TBC combat (TBCHP already at 0, e.g. a
    -- team wipe via CheckForTeamDefeat) permanently costs a partied player
    -- their spot: respawning after this is what pays that cost. They keep
    -- whatever chance of being revived exists before they respawn - once
    -- they choose to respawn, that chance and their party membership are
    -- both gone for good.
    hook.Add("PlayerDeath", "TBC_FlagPartyRemovalOnRespawn", function(victim)
        if not IsValid(victim) then return end
        if victim:GetNWInt("TBCHP", 0) > 0 then return end
        if not IsPlayerInAnyParty(victim) then return end

        victim.TBC_PartyRemovalPendingOnRespawn = true
        victim:ChatPrint("You have fallen in battle. Respawning will permanently remove you from your party.")
    end)

    hook.Add("PlayerSpawn", "TBC_ApplyPendingPartyRemoval", function(player)
        if not player.TBC_PartyRemovalPendingOnRespawn then return end
        player.TBC_PartyRemovalPendingOnRespawn = nil

        local partyId = IsPlayerInAnyParty(player)
        if partyId then
            player:ChatPrint("You have respawned and been permanently removed from your party.")
            RemoveFromParty(player, partyId)
        end
    end)
end

if CLIENT then

    net.Receive("PlayerPartyUpdate", function()
        net.ReadEntity() -- the player who triggered this update, informational only
        local partyId = net.ReadString()
        local currentConsecutive = net.ReadInt(32)
        local partyData = net.ReadTable()

        PlayerParties[partyId] = partyData
        PartyConsecutive = currentConsecutive

        hook.Run("TBC_PartyDataUpdated", partyId)
    end)

    net.Receive("PlayerPartyRemove", function()
        local partyId = net.ReadString()
        PlayerParties[partyId] = nil

        hook.Run("TBC_PartyDataUpdated", partyId)
    end)

    net.Receive("PlayerPartiesSync", function()
        local allParties = net.ReadTable()
        PlayerParties = allParties
        local currentConsecutive = net.ReadInt(32)
        PartyConsecutive = currentConsecutive

        hook.Run("TBC_PartyDataUpdated", nil)
    end)

    net.Receive("PartyInvitePrompt", function()
        local partyId = net.ReadString()
        local partyName = net.ReadString()
        local inviterName = net.ReadString()

        local prompt = Derma_Query(
            inviterName .. " has invited you to join \"" .. partyName .. "\".",
            "Party Invite",
            "Accept", function()
                net.Start("PartyInviteResponse")
                net.WriteBool(true)
                net.SendToServer()
            end,
            "Decline", function()
                net.Start("PartyInviteResponse")
                net.WriteBool(false)
                net.SendToServer()
            end
        )

        if IsValid(prompt) then
            timer.Simple(30, function()
                if IsValid(prompt) then prompt:Close() end
            end)
        end
    end)

    function GetAllPartyDataClient(player, partyId)
        if not IsValid(player) then return {} end
        if not PlayerParties then return {} end
        if not PlayerParties[partyId] then return {} end

        return PlayerParties[partyId]
    end

    function IsPlayerInAnyPartyClient(player)
        if not IsValid(player) then return false end
        if not PlayerParties then return false end

        local steamID = player:SteamID()

        for partyId, partyData in pairs(PlayerParties) do
            if partyData["Members"] and partyData["Members"][steamID] then
                return partyId
            end
        end

        return false
    end
end
