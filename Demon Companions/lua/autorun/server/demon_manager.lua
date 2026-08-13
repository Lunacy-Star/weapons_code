-- Demon Companion System - Party management (server)
-- Stores each player's demon party, handles deploy/pocket, persistence,
-- and inserting/removing demons from turn-based fights.

if CLIENT then return end

DEMONCOMP = DEMONCOMP or {}

-- DEMONCOMP.Parties[steamID] = { {charId, guid, hp, mp, ent}, ... }
DEMONCOMP.Parties = DEMONCOMP.Parties or {}

local PDATA_KEY = "DEMONCOMP_Party"

-- ============================================================
-- Party storage + persistence
-- ============================================================
function DEMONCOMP.GetParty(ply)
    if not IsValid(ply) then return {} end
    local sid = ply:SteamID()
    if not DEMONCOMP.Parties[sid] then
        local saved = ply:GetPData(PDATA_KEY, "")
        local list = {}
        if saved ~= "" then
            local decoded = util.JSONToTable(saved)
            if decoded then list = decoded end
        end
        for _, entry in ipairs(list) do entry.ent = nil end
        DEMONCOMP.Parties[sid] = list
    end
    return DEMONCOMP.Parties[sid]
end

function DEMONCOMP.SaveParty(ply)
    if not IsValid(ply) then return end
    local party = DEMONCOMP.GetParty(ply)
    local serializable = {}
    for _, entry in ipairs(party) do
        table.insert(serializable, {
            charId = entry.charId,
            guid = entry.guid,
            hp = entry.hp,
            mp = entry.mp
        })
    end
    ply:SetPData(PDATA_KEY, util.TableToJSON(serializable))
end

function DEMONCOMP.GrantDemon(ply, charId)
    local charData = DEMONCOMP.GetCharData(charId)
    if not charData or charData.type ~= "Demon" then
        return false, charId .. " is not a valid demon character id."
    end

    local party = DEMONCOMP.GetParty(ply)
    if #party >= DEMONCOMP.MaxPartySize then
        return false, "Their demon party is full (" .. DEMONCOMP.MaxPartySize .. " max)."
    end

    local guid = util.CRC(ply:SteamID() .. charId .. tostring(SysTime()) .. tostring(math.random(100000)))
    table.insert(party, {charId = charId, guid = guid, hp = nil, mp = nil, ent = nil})
    DEMONCOMP.SaveParty(ply)

    return true, charData.name
end

function DEMONCOMP.RevokeDemon(ply, index)
    local party = DEMONCOMP.GetParty(ply)
    local entry = party[index]
    if not entry then return false, "No demon in slot " .. index .. "." end

    if IsValid(entry.ent) then entry.ent:Remove() end
    local charData = DEMONCOMP.GetCharData(entry.charId)
    table.remove(party, index)
    DEMONCOMP.SaveParty(ply)

    return true, charData and charData.name or entry.charId
end

-- Deployed demon entities belonging to a player, in party order
function DEMONCOMP.GetDeployedDemons(ply)
    local demons = {}
    for _, entry in ipairs(DEMONCOMP.GetParty(ply)) do
        if IsValid(entry.ent) then table.insert(demons, entry.ent) end
    end
    return demons
end

function DEMONCOMP.FindEntryByDemon(demon)
    local guid = demon:GetNWString("DemonGUID", "")
    for sid, party in pairs(DEMONCOMP.Parties) do
        for _, entry in ipairs(party) do
            if "DEMON_" .. (entry.guid or "") == guid then
                return entry, sid
            end
        end
    end
    return nil
end

-- ============================================================
-- Deploy / pocket
-- ============================================================
local function masterInCombat(ply)
    local engage = ply:GetWeapon("smti_engageswep")
    if IsValid(engage) and engage.FightId and
        TBCWeaponMetatable and TBCWeaponMetatable.OngoingFights and
        TBCWeaponMetatable.OngoingFights[engage.FightId] then
        return true
    end
    return false
end

function DEMONCOMP.Deploy(ply, index)
    local party = DEMONCOMP.GetParty(ply)
    local entry = party[index]
    if not entry then
        return false, "No demon in slot " .. index .. ". Use /demons to list your party."
    end
    if IsValid(entry.ent) then
        return false, "That demon is already deployed."
    end
    if masterInCombat(ply) then
        return false, "You can't deploy a demon in the middle of a fight."
    end

    local charData = DEMONCOMP.GetCharData(entry.charId)
    if not charData then
        return false, "Unknown demon character: " .. tostring(entry.charId)
    end

    -- Spawn in front of the master, snapped to the ground
    local tr = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 90,
        filter = ply
    })
    local spawnPos = tr.HitPos + tr.HitNormal * 4
    local ground = util.TraceLine({
        start = spawnPos,
        endpos = spawnPos - Vector(0, 0, 200),
        filter = ply
    })
    if ground.Hit then spawnPos = ground.HitPos + Vector(0, 0, 2) end

    local demon = ents.Create("smt_demon")
    if not IsValid(demon) then return false, "Failed to create the demon entity." end

    demon:SetPos(spawnPos)
    demon:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
    demon:Spawn()
    demon:Activate()

    if not demon:SetupDemon(ply, entry.charId, entry.guid, entry) then
        return false, "Failed to set up the demon."
    end

    entry.ent = demon

    -- Make sure the master can command it
    if not ply:HasWeapon("smti_demonswep") then
        ply:Give("smti_demonswep")
    end

    return true, charData.name
end

function DEMONCOMP.Pocket(ply, index)
    local party = DEMONCOMP.GetParty(ply)
    local entry = party[index]
    if not entry then return false, "No demon in slot " .. index .. "." end
    if not IsValid(entry.ent) then return false, "That demon is not deployed." end

    if entry.ent.FightId and TBCWeaponMetatable and
        TBCWeaponMetatable.OngoingFights and
        TBCWeaponMetatable.OngoingFights[entry.ent.FightId] then
        return false, "You can't pocket a demon while it's in a fight."
    end

    local charData = DEMONCOMP.GetCharData(entry.charId)
    entry.ent:Remove() -- OnRemove -> HandleDemonRemoved saves hp/mp

    return true, charData and charData.name or entry.charId
end

-- Called from ENT:OnRemove for any reason (pocket, death, disconnect, admin delete)
function DEMONCOMP.HandleDemonRemoved(demon)
    local entry = DEMONCOMP.FindEntryByDemon(demon)
    local master = demon:GetMaster()

    if entry then
        if demon.DiedInBattle then
            entry.hp = 1 -- defeated demons come back barely alive
        else
            entry.hp = math.max(demon:GetNWInt("TBCHP", 0), 0)
        end
        entry.mp = demon:GetNWInt("TBCMP", 0)
        entry.ent = nil
    end

    -- If the master was acting through this demon, give them their weapons back
    if IsValid(master) and master.TBCControlledDemon == demon and DEMONCOMP.EndControl then
        DEMONCOMP.EndControl(master)
    end

    -- Clear the "selected" pointer if it pointed at the demon that just left
    if IsValid(master) and master:GetNWEntity("ActiveDemon", NULL) == demon then
        master:SetNWEntity("ActiveDemon", NULL)
    end

    DEMONCOMP.RemoveDemonFromFight(demon)

    if IsValid(master) then DEMONCOMP.SaveParty(master) end
end

-- ============================================================
-- Fight integration helpers (called from tbc_weapon_metatable.lua)
-- ============================================================

-- Inserts every deployed demon of every player in the fight directly
-- after its master in the side's turn list. Safe to call repeatedly.
function DEMONCOMP.InsertFightDemons(fight, fightId)
    if not fight then return end

    for _, sideName in ipairs({"Side1", "Side2"}) do
        local side = fight[sideName]
        if side then
            local i = 1
            while i <= #side do
                local member = side[i]
                if IsValid(member) and member.IsPlayer and member:IsPlayer() then
                    local insertAt = i
                    for _, demon in ipairs(DEMONCOMP.GetDeployedDemons(member)) do
                        demon.FightId = fightId
                        if not table.HasValue(fight.Side1, demon) and
                            not table.HasValue(fight.Side2, demon) then
                            insertAt = insertAt + 1
                            table.insert(side, insertAt, demon)
                        end
                    end
                end
                i = i + 1
            end
        end
    end
end

-- Same as above but only for one joining player (used by JoinFight)
function DEMONCOMP.InsertFightDemonsForPlayer(fight, fightId, ply)
    if not fight or not IsValid(ply) then return end

    for _, sideName in ipairs({"Side1", "Side2"}) do
        local side = fight[sideName]
        if side then
            for i, member in ipairs(side) do
                if member == ply then
                    local insertAt = i
                    for _, demon in ipairs(DEMONCOMP.GetDeployedDemons(ply)) do
                        demon.FightId = fightId
                        if not table.HasValue(fight.Side1, demon) and
                            not table.HasValue(fight.Side2, demon) then
                            insertAt = insertAt + 1
                            table.insert(side, insertAt, demon)
                        end
                    end
                    return
                end
            end
        end
    end
end

local function removeFromSide(fight, sideName, member)
    local side = fight[sideName]
    if not side then return false end

    for i, m in ipairs(side) do
        if m == member then
            table.remove(side, i)
            -- keep the turn pointer on the same member it was pointing at
            if fight.ActiveSide == sideName then
                if i < fight.ActiveMember then
                    fight.ActiveMember = fight.ActiveMember - 1
                end
                if fight.ActiveMember > #side then
                    fight.ActiveMember = 1
                end
                if fight.ActiveMember < 1 then fight.ActiveMember = 1 end
            end
            return true
        end
    end
    return false
end

-- Removes a demon from whatever fight it is part of
function DEMONCOMP.RemoveDemonFromFight(demon)
    if not TBCWeaponMetatable or not TBCWeaponMetatable.OngoingFights then return end

    for fightId, fight in pairs(TBCWeaponMetatable.OngoingFights) do
        removeFromSide(fight, "Side1", demon)
        removeFromSide(fight, "Side2", demon)
    end

    demon.FightId = nil
end

-- Removes all of a player's demons from a fight (used when the master escapes)
function DEMONCOMP.RemoveMastersDemonsFromFight(fight, ply)
    for _, demon in ipairs(DEMONCOMP.GetDeployedDemons(ply)) do
        removeFromSide(fight, "Side1", demon)
        removeFromSide(fight, "Side2", demon)
        demon.FightId = nil
        RemoveAllStats(demon, "buffs")
        RemoveAllStats(demon, "debuffs")
    end
end

-- ============================================================
-- Cleanup
-- ============================================================
hook.Add("PlayerDisconnected", "DEMONCOMP_Cleanup", function(ply)
    local party = DEMONCOMP.GetParty(ply)
    for _, entry in ipairs(party) do
        if IsValid(entry.ent) then
            entry.ent:Remove()
        end
    end
    DEMONCOMP.SaveParty(ply)
    DEMONCOMP.Parties[ply:SteamID()] = nil
end)

hook.Add("PlayerInitialSpawn", "DEMONCOMP_LoadParty", function(ply)
    timer.Simple(1, function()
        if IsValid(ply) then DEMONCOMP.GetParty(ply) end
    end)
end)

-- ============================================================
-- Chat commands
-- ============================================================
local function findPlayerByName(name)
    name = string.lower(name)
    for _, target in ipairs(player.GetAll()) do
        if string.find(string.lower(target:Nick()), name, 1, true) then
            return target
        end
    end
    return nil
end

hook.Add("PlayerSay", "DEMONCOMP_Commands", function(ply, text)
    local lowered = string.lower(text)
    local args = string.Explode(" ", string.Trim(text))
    local cmd = string.lower(args[1] or "")

    if cmd == "/demons" then
        local party = DEMONCOMP.GetParty(ply)
        if #party == 0 then
            ply:ChatPrint("You have no demons in your party.")
            return ""
        end
        ply:ChatPrint("=== Your Demon Party ===")
        for i, entry in ipairs(party) do
            local charData = DEMONCOMP.GetCharData(entry.charId)
            local name = charData and charData.name or entry.charId
            local status = IsValid(entry.ent) and "DEPLOYED" or "pocketed"
            local hp = IsValid(entry.ent) and entry.ent:GetNWInt("TBCHP", 0) or
                           (entry.hp or (charData and charData.combatHP) or 100)
            local maxHp = charData and charData.combatHP or 100
            ply:ChatPrint(i .. ". " .. name .. " [" .. status .. "] HP: " .. hp .. "/" .. maxHp)
        end
        return ""

    elseif cmd == "/demondeploy" then
        local index = tonumber(args[2] or "1") or 1
        local ok, msg = DEMONCOMP.Deploy(ply, index)
        if ok then
            ply:ChatPrint(msg .. " has been summoned!")
        else
            ply:ChatPrint(msg)
        end
        return ""

    elseif cmd == "/demonpocket" then
        local index = tonumber(args[2] or "")
        if index then
            local ok, msg = DEMONCOMP.Pocket(ply, index)
            if ok then
                ply:ChatPrint(msg .. " returned to your pocket.")
            else
                ply:ChatPrint(msg)
            end
        else
            -- pocket everything deployed
            local party = DEMONCOMP.GetParty(ply)
            local pocketed = 0
            for i, entry in ipairs(party) do
                if IsValid(entry.ent) then
                    local ok = DEMONCOMP.Pocket(ply, i)
                    if ok then pocketed = pocketed + 1 end
                end
            end
            ply:ChatPrint(pocketed > 0 and (pocketed .. " demon(s) returned to your pocket.") or
                              "No demons could be pocketed.")
        end
        return ""

    elseif cmd == "/demongrant" then
        if not ply:IsAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return ""
        end
        if #args < 3 then
            ply:ChatPrint("Usage: /demongrant <player> <demonCharId>")
            return ""
        end
        local target = findPlayerByName(args[2])
        if not target then
            ply:ChatPrint("Player not found!")
            return ""
        end
        local ok, msg = DEMONCOMP.GrantDemon(target, args[3])
        if ok then
            ply:ChatPrint("Granted " .. msg .. " to " .. target:Nick() .. ".")
            target:ChatPrint(msg .. " has joined your demon party! Use /demons to see your party.")
        else
            ply:ChatPrint(msg)
        end
        return ""

    elseif cmd == "/demonrevoke" then
        if not ply:IsAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return ""
        end
        if #args < 3 then
            ply:ChatPrint("Usage: /demonrevoke <player> <slotNumber>")
            return ""
        end
        local target = findPlayerByName(args[2])
        if not target then
            ply:ChatPrint("Player not found!")
            return ""
        end
        local ok, msg = DEMONCOMP.RevokeDemon(target, tonumber(args[3]) or 0)
        if ok then
            ply:ChatPrint("Removed " .. msg .. " from " .. target:Nick() .. "'s party.")
            target:ChatPrint(msg .. " has left your demon party.")
        else
            ply:ChatPrint(msg)
        end
        return ""

    elseif cmd == "/demonlist" then
        if not ply:IsAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return ""
        end
        ply:ChatPrint("=== Available demon character ids ===")
        if CHARACTERS and CHARACTERS.List then
            for charId, charData in SortedPairs(CHARACTERS.List) do
                if charData.type == "Demon" then
                    ply:ChatPrint(charId .. " (" .. (charData.name or "?") .. ")")
                end
            end
        end
        return ""
    end
end)
