include("autorun/stasuses_manager.lua")
include("autorun/turn_stasuses_manager.lua")
include("autorun/affinitiesailments.lua")
include("autorun/effects_manager.lua")
include("autorun/buffs_manager.lua")
include("autorun/skill_functions.lua")
include("autorun/client/cl_cza.lua")

TBCWeaponMetatable = TBCWeaponMetatable or {}
TBCWeaponMetatable.OngoingFights = TBCWeaponMetatable.OngoingFights or {}

local victoryMessageSent = {}

function TBCWeaponMetatable:AnnounceAbility()
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if fight then
        local playerSide =
            (table.HasValue(fight.Side1, self.Owner) and "Side1") or
            (table.HasValue(fight.Side2, self.Owner) and "Side2")
    else
        return
    end

    local playersInFight = {}
    for _, player in ipairs(fight.Side1) do
        -- Demons don't get their own chat line; their master already
        -- receives this message directly as a fight member in their own right.
        if IsValid(player) and player:IsPlayer() then
            table.insert(playersInFight, player)
        end
    end
    for _, player in ipairs(fight.Side2) do
        if IsValid(player) and player:IsPlayer() then
            table.insert(playersInFight, player)
        end
    end

    -- Send chat message only to players involved in the fight
    for _, player in ipairs(playersInFight) do
        if IsValid(player) then -- Check if the player is valid
            player:ChatPrint(self.Owner:Nick() .. " used " .. self.PrintName .. "!")
        end
    end
end

function TBCWeaponMetatable:AnnounceMessage(message)
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if fight then
        local playerSide =
            (table.HasValue(fight.Side1, self.Owner) and "Side1") or
            (table.HasValue(fight.Side2, self.Owner) and "Side2")
    else
        print("Fight not found") -- Debug line
        return
    end

    local playersInFight = {}
    for _, player in ipairs(fight.Side1) do
        -- Demons don't get their own chat line; their master already
        -- receives this message directly as a fight member in their own right.
        if IsValid(player) and player:IsPlayer() then
            table.insert(playersInFight, player)
        end
    end
    for _, player in ipairs(fight.Side2) do
        if IsValid(player) and player:IsPlayer() then
            table.insert(playersInFight, player)
        end
    end

    -- Send chat message only to players involved in the fight
    for _, player in ipairs(playersInFight) do
        if IsValid(player) then -- Check if the player is valid
            player:ChatPrint(message)
        end
    end
end

function TBCWeaponMetatable:AbilityRollNumber(weaponTechnique, target)
    if self.IsHeal then
        return true
    end
    local ply = self:GetOwner()
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if SERVER then -- Add this line
        if ply:IsPlayer() then
            if target and CheckIfValidTBCEntity(target) then
                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")
                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                local attackerTech = ply:GetNWInt("TBCTechnique", 40)
                local targetTech = target:GetNWInt("TBCTechnique", 40)

                local bonusAttackerTech =
                    attackerTech +
                    (HandleStatus(ply, userBuffsTable, "increaseTech", attackerTech, "attacker") -
                        HandleStatus(ply, userDebuffsTable, "decreaseTech", attackerTech, "attacker"))

                local bonusDefenderTech =
                    targetTech +
                    (HandleStatus(target, targetBuffsTable, "increaseTech", targetTech, "defender") -
                        HandleStatus(target, targetDebuffsTable, "decreaseTech", targetTech, "defender"))

                local hitChance =
                    attackerTech + (attackerTech - targetTech) + (bonusAttackerTech - bonusDefenderTech) +
                    weaponTechnique

                local roll = math.random(100)
                local result = roll <= hitChance and true or false

                if not result and SMTDamageNumbers then
                    SMTDamageNumbers.Show(target, nil, "miss")
                end

                if fight then
                    local playersInFight = {}
                    for _, player in ipairs(fight.Side1) do
                        table.insert(playersInFight, player)
                    end
                    for _, player in ipairs(fight.Side2) do
                        table.insert(playersInFight, player)
                    end

                    local message =
                        "Missed! " ..
                        self.Owner:Nick() ..
                            " rolled a " ..
                                roll ..
                                    " to use " ..
                                        self.PrintName .. " on " .. target:Nick() .. ". (" .. hitChance .. "%)"
                    if result then
                        message =
                            "Success! " ..
                            self.Owner:Nick() ..
                                " rolled a " ..
                                    roll ..
                                        " to use " ..
                                            self.PrintName .. " on " .. target:Nick() .. ". (" .. hitChance .. "%)"
                    end

                    self:AnnounceMessage(message)

                    self:EndAbility()
                end

                return result
            end
        end
    end
end

function TBCWeaponMetatable:Negotiation()
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if not fight then
        self.Owner:ChatPrint("Fight not found.")
        return
    end

    -- Determine the current active side based on the player calling this function
    local currentActiveSide = fight.ActiveSide

    -- Check if the player is on the active side
    local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

    if currentTurnPlayer ~= self.Owner then
        if SERVER and self.Owner then
            self.Owner:ChatPrint("It's not your turn.") -- Notify the player it's not their turn
        end
        return -- Exit the function as it's not the player's turn
    end

    if fight[currentActiveSide].State and fight[currentActiveSide].State == "Negotiation" then
        fight[currentActiveSide].State = nil
        self:AnnounceMessage(currentTurnPlayer:Name() .. " has ended negotiations!")

        self:NextTurn(false)
    else
        if timer.Exists(self.FightId) then
            timer.Remove(self.FightId)
        end

        fight[currentActiveSide].State = "Negotiation"
        self:AnnounceMessage(currentTurnPlayer:Name() .. " has started negotiations!")
    end
end

function TBCWeaponMetatable:AilmentCheck(player, turnType)
    local isTurnSkipped = false

    local userBuffsTable = GetAllStats(player, "buffs")
    local userDebuffsTable = GetAllStats(player, "debuffs")

    for status, properties in pairs(userBuffsTable) do
        if properties.durationCycle and turnType == "cycle" then
            userBuffsTable[status].durationCycle = userBuffsTable[status].durationCycle - 1
            if properties.durationCycle <= 0 then
                userBuffsTable[status] = nil
                self:AnnounceMessage(player:Name() .. "'s " .. status .. " has worn off!")
            end

            AssignStat(player, status, userBuffsTable[status], "buffs")
        end
        if properties.type == "turnRegen" then
            HandleTurnStatus(player, status, "turnRegen", properties)
        end
        if properties.type == "turnMisc" then
            HandleTurnStatus(player, status, "turnMisc", properties)
        end
        if properties.duration then
            userBuffsTable[status].duration = userBuffsTable[status].duration - 1
            if properties.duration <= 0 then
                userBuffsTable[status] = nil
                self:AnnounceMessage(player:Name() .. "'s " .. status .. " has worn off!")
            end

            AssignStat(player, status, userBuffsTable[status], "buffs")
        end
    end

    for status, properties in pairs(userDebuffsTable) do
        if properties.type == "turnDamage" then
            local playerTurnDamage = HandleTurnStatus(player, status, "turnDamage", properties)
            local effectsTable = {}

            effectsTable["baseDamage"] = math.ceil(playerTurnDamage)

            if effectsTable["baseDamage"] > 0 then
                local resist = util.JSONToTable(player:GetNW2String("resist"))
                local weak = util.JSONToTable(player:GetNW2String("weak"))
                local block = util.JSONToTable(player:GetNW2String("block"))
                local drain = util.JSONToTable(player:GetNW2String("drain"))

                -- Modify damage based on resistances, weaknesses, and blocks
                if table.HasValue(resist, self.Affinity) then
                    effectsTable["baseDamage"] = effectsTable["baseDamage"] * 0.9 -- Decrease damage if resistance is found
                end
                if table.HasValue(resist, "magic") then
                    if table.HasValue(Affinities.Magic, self.Affinity) then
                        effectsTable["baseDamage"] = effectsTable["baseDamage"] * 0.9
                    end
                end

                if table.HasValue(weak, self.Affinity) then
                    effectsTable["baseDamage"] = effectsTable["baseDamage"] * 1.1 -- Increase damage if weakness is found
                end
                if table.HasValue(weak, "magic") then
                    if table.HasValue(Affinities["Magic"], self.Affinity) then
                        effectsTable["baseDamage"] = effectsTable["baseDamage"] * 1.1 -- Increase damage if weakness is found
                    end
                end

                if table.HasValue(block, self.Affinity) then
                    effectsTable["baseDamage"] = 0 -- Set damage to 0 if attack is blocked
                end
                if table.HasValue(block, "magic") then
                    if table.HasValue(Affinities.Magic, self.Affinity) then
                        effectsTable["baseDamage"] = 0 -- Set damage to 0 if attack is blocked
                    end
                end

                effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"])

                effectsTable["baseDamage"] =
                    effectsTable["baseDamage"] +
                    (HandleStatus(player, userBuffsTable, "defenseDamage", effectsTable["baseDamage"], effectsTable) -
                        HandleStatus(
                            player,
                            userDebuffsTable,
                            "defenseDecrease",
                            effectsTable["baseDamage"],
                            effectsTable
                        ))

                effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"])

                local currentHP = player:GetNWInt("TBCHP", 100)
                local newHP = currentHP - effectsTable["baseDamage"]
                player:SetNWInt("TBCHP", newHP)

                self:AnnounceMessage(
                    player:Name() .. " receives " .. effectsTable["baseDamage"] .. " damage due to " .. status .. "!"
                )

                if newHP <= 0 then
                    player:SetNWInt("TBCHP", 0)
                    local message = player:Name() .. " is dead!"
                    self:AnnounceMessage(message)
                end

                if properties.duration then
                    userDebuffsTable[status].duration = userDebuffsTable[status].duration - 1
                    if properties.duration <= 0 then
                        userDebuffsTable[status] = nil
                        self:AnnounceMessage(player:Name() .. "'s " .. status .. " has worn off!")
                    end

                    AssignStat(player, status, userDebuffsTable[status], "debuffs")
                end

                self:CheckForTeamDefeat(self.FightId)
            end
        end
        if properties.type == "turnSkipper" then
            local playerTurnSkipChance = HandleTurnStatus(player, status, "turnSkipper", properties)

            local playerLuck = player:GetNWInt("TBCLuck", 10)
            playerLuck =
                playerLuck +
                (HandleStatus(player, userBuffsTable, "increaseLuck", playerLuck) -
                    HandleStatus(player, userDebuffsTable, "decreaseLuck", playerLuck))

            local skippedChance = playerTurnSkipChance - math.floor(playerLuck / 2)

            if properties.duration then
                userDebuffsTable[status].duration = userDebuffsTable[status].duration - 1
                if properties.duration <= 0 then
                    userDebuffsTable[status] = nil
                end

                AssignStat(player, status, userDebuffsTable[status], "debuffs")
            end

            if math.random(1, 100) >= skippedChance then
                local charId = player:GetNWString("AssignedCharacter")
                local charData = CHARACTERS.List[charId]
                if charData.type == "Boss" then
                    local currentHP = player:GetNWInt("TBCHP", 100)
                    local newHP = currentHP - 15
                    player:SetNWInt("TBCHP", newHP)

                    self:AnnounceMessage(player:Name() .. " receives " .. 15 .. " damage due to " .. status .. "!")

                    if newHP <= 0 then
                        player:SetNWInt("TBCHP", 0)
                        local message = player:Name() .. " is dead!"
                        self:AnnounceMessage(message)
                    end

                    self:CheckForTeamDefeat(self.FightId)
                else
                    self:AnnounceMessage(player:Name() .. " has their turn skipped due to " .. status)

                    if userDebuffsTable[status] == nil then
                        self:AnnounceMessage(player:Name() .. "'s " .. status .. " has worn off!")
                    end
                    self:NextTurn(true)
                end
            elseif userDebuffsTable[status] == nil then
                self:AnnounceMessage(player:Name() .. "'s " .. status .. " has worn off!")
            end
        end

        if properties.wearOff == "turnWearOff" then
            local playerLuck = player:GetNWInt("TBCLuck", 10)
            playerLuck =
                playerLuck +
                (HandleStatus(player, userBuffsTable, "increaseLuck", playerLuck) -
                    HandleStatus(player, userDebuffsTable, "decreaseLuck", playerLuck))

            local ailmentChance = math.ceil(playerLuck / 2) + 50

            if math.random(1, 100) <= ailmentChance then
                userDebuffsTable[status] = nil
                self:AnnounceMessage(player:Name() .. " has broken through " .. status .. "!")

                AssignStat(player, status, userDebuffsTable[status], "debuffs")
            end
        end

        if properties.type ~= "turnDamage" and properties.type ~= "turnSkipper" then
            if properties.duration and userDebuffsTable[status] then
                userDebuffsTable[status].duration = userDebuffsTable[status].duration - 1
                if properties.duration <= 0 then
                    userDebuffsTable[status] = nil
                    self:AnnounceMessage(player:Name() .. "'s " .. status .. " has worn off!")
                end

                AssignStat(player, status, userDebuffsTable[status], "debuffs")
            end
        end
    end

    if isTurnSkipped then
        self:NextTurn(false)
    end
end

-- ============================================================
-- Party <-> Fight integration
-- ============================================================
if SERVER then
    local PARTY_ENGAGE_RADIUS = 1000
    local PARTY_SYNC_INTERVAL = 0.5

    local function CanPullIntoFight(ply)
        if not IsValid(ply) or not ply:IsPlayer() then
            return false
        end
        if ply:GetNWInt("TBCHP", 0) <= 0 then
            return false
        end
        local sw = ply:GetWeapon("smti_engageswep")
        return IsValid(sw) and not sw.InCombat
    end

    -- Inserts newMember into list so that, among members who are part of
    -- partyOrder, relative placement follows the party's turn order.
    -- Members not tracked in partyOrder are left exactly where they are.
    local function InsertRespectingPartyOrder(list, newMember, partyOrder)
        local newIdx
        for i, sid in ipairs(partyOrder) do
            if sid == newMember:SteamID() then
                newIdx = i
                break
            end
        end

        if not newIdx then
            table.insert(list, newMember)
            return
        end

        for i, member in ipairs(list) do
            if IsValid(member) and member:IsPlayer() then
                local memberIdx
                for j, sid in ipairs(partyOrder) do
                    if sid == member:SteamID() then
                        memberIdx = j
                        break
                    end
                end

                if memberIdx and memberIdx > newIdx then
                    table.insert(list, i, newMember)
                    return
                end
            end
        end

        table.insert(list, newMember)
    end

    -- Pulls in-range, eligible party members of each side's anchor (the
    -- original engager/target) into that side, preserving the party's turn
    -- order. Safe to call repeatedly - already-seated members are skipped.
    function TBC_SyncPartyMembersIntoFight(fightId)
        local fight = TBCWeaponMetatable.OngoingFights[fightId]
        if not fight then
            return
        end

        for _, side in ipairs({"Side1", "Side2"}) do
            local anchor = fight[side][1]
            if IsValid(anchor) and anchor:IsPlayer() then
                local partyId = IsPlayerInAnyParty(anchor)
                local party = partyId and PlayerParties[partyId]

                if party and party.Order then
                    local anchorPos = anchor:GetPos()

                    for _, steamID in ipairs(party.Order) do
                        local member = party.Members[steamID]

                        if member ~= anchor and CanPullIntoFight(member) and
                            not table.HasValue(fight.Side1, member) and
                            not table.HasValue(fight.Side2, member) and
                            member:GetPos():DistToSqr(anchorPos) <= (PARTY_ENGAGE_RADIUS * PARTY_ENGAGE_RADIUS) then

                            InsertRespectingPartyOrder(fight[side], member, party.Order)

                            for _, weapon in pairs(member:GetWeapons()) do
                                weapon.FightId = fightId
                            end

                            local memberSWEP = member:GetWeapon("smti_engageswep")
                            if IsValid(memberSWEP) then
                                memberSWEP.InCombat = true
                            end

                            if DEMONCOMP and DEMONCOMP.InsertFightDemonsForPlayer then
                                DEMONCOMP.InsertFightDemonsForPlayer(fight, fightId, member)
                            end

                            local anchorSWEP = anchor:GetWeapon("smti_engageswep")
                            if IsValid(anchorSWEP) then
                                anchorSWEP:AnnounceMessage(member:Nick() .. " has joined the battle!")
                            end
                        end
                    end
                end
            end
        end
    end

    -- Starts the repeating scan that pulls late-arriving party members in
    -- while the fight is still in its preparation window. Cancels itself
    -- once the fight actually starts (or disappears).
    function TBC_StartPartySyncWindow(fightId)
        local timerName = fightId .. "_PartySync"

        timer.Create(timerName, PARTY_SYNC_INTERVAL, 0, function()
            local fight = TBCWeaponMetatable.OngoingFights[fightId]
            if not fight or fight.Started then
                timer.Remove(timerName)
                return
            end

            TBC_SyncPartyMembersIntoFight(fightId)
        end)
    end

    -- Called when a player without a party manually joins an existing fight
    -- side. If a current member of that side already has a party, the
    -- joiner is added to it. Otherwise, if the side has other members, a
    -- new party is formed around them so the group is tracked going forward.
    function TBC_EnsurePartyForSideJoin(fight, side, joiningPlayer)
        if not IsValid(joiningPlayer) or IsPlayerInAnyParty(joiningPlayer) then
            return
        end

        local anchorWithParty, fallbackAnchor
        for _, member in ipairs(fight[side]) do
            if member ~= joiningPlayer and IsValid(member) and member:IsPlayer() then
                fallbackAnchor = fallbackAnchor or member
                if IsPlayerInAnyParty(member) then
                    anchorWithParty = member
                    break
                end
            end
        end

        if anchorWithParty then
            AssignParty(joiningPlayer, IsPlayerInAnyParty(anchorWithParty))
        elseif fallbackAnchor then
            local partyId = CreateParty(fallbackAnchor)
            AssignParty(joiningPlayer, partyId)
        end
    end
end

function TBCWeaponMetatable:StartFight(target)
    local fightId = self.Owner:UserID() .. "_" .. target:UserID()
    self.FightId = fightId
    target:GetWeapon("smti_engageswep").FightId = fightId

    TBCWeaponMetatable.OngoingFights[fightId] = {
        Side1 = {self.Owner},
        Side2 = {target},
        CyclesDone = 0,
        TurnCounter = 0,
        ActiveMember = 1,
        ActiveSide = "Side1", -- Initially set to Side1; change as appropriate
        Started = false, -- Indicate that the fight has not started
        EndRequests = {}, -- Key to track players who have requested to end the fight
        AFKRequests = {} -- Initialize the AFKRequests table
    }

    -- Propagate the FightId to all weapons of the players
    for _, weapon in pairs(self.Owner:GetWeapons()) do
        weapon.FightId = fightId
    end
    for _, weapon in pairs(target:GetWeapons()) do
        weapon.FightId = fightId
    end

    victoryMessageSent[fightId] = false

    -- Pull in any of the engager's/target's party members already nearby,
    -- then keep scanning for late arrivals until the fight actually starts.
    if SERVER then
        TBC_SyncPartyMembersIntoFight(fightId)
        TBC_StartPartySyncWindow(fightId)
    end

    -- Create the timer
    timer.Create(
        fightId,
        5,
        1,
        function()
            -- Check if the fight still exists
            local fight = TBCWeaponMetatable.OngoingFights[fightId]
            if not fight then
                return -- Exit the function
            end

            -- Check if both players are still alive and valid
            if not IsValid(self.Owner) or not IsValid(target) then
                TBCWeaponMetatable:EndFight(fightId) -- End the fight properly
                return -- Exit the function
            end

            if fight then
                -- Deployed demon companions join the fight right after their master,
                -- so they get their own turn in the cycle (charData.turns each).
                if DEMONCOMP and DEMONCOMP.InsertFightDemons then
                    DEMONCOMP.InsertFightDemons(fight, fightId)
                end

                local attackerTech = 0
                local targetTech = 0

                for _, player in ipairs(fight.Side1) do
                    local userBuffsTable = GetAllStats(player, "permabuffs")

                    local playerTech = player:GetNWInt("TBCTechnique", 40)

                    attackerTech =
                        attackerTech + (playerTech + HandleStatus(player, userBuffsTable, "increaseTech", playerTech))
                end
                for _, player in ipairs(fight.Side2) do
                    local userBuffsTable = GetAllStats(player, "permabuffs")

                    local playerTech = player:GetNWInt("TBCTechnique", 40)

                    targetTech =
                        targetTech + (playerTech + HandleStatus(player, userBuffsTable, "increaseTech", playerTech))
                end

                local attackerChancePercent = attackerTech + (attackerTech - targetTech)

                -- Determine which side is going first and set the ActiveSide and TurnCounter accordingly
                if math.random(100) <= attackerChancePercent then
                    fight.ActiveSide = "Side1"
                    local turnsCounter = 0
                    -- Reset TurnCounter based on the number of players on the new active side
                    for _, player in ipairs(fight.Side1) do
                        local charId = player:GetNWString("AssignedCharacter")
                        local charData = CHARACTERS.List[charId]
                        turnsCounter = turnsCounter + charData.turns
                    end

                    fight.TurnCounter = turnsCounter
                else
                    fight.ActiveSide = "Side2"
                    local turnsCounter = 0
                    -- Reset TurnCounter based on the number of players on the new active side
                    for _, player in ipairs(fight.Side2) do
                        local charId = player:GetNWString("AssignedCharacter")
                        local charData = CHARACTERS.List[charId]
                        turnsCounter = turnsCounter + charData.turns
                    end

                    fight.TurnCounter = turnsCounter
                end

                -- Announce which side is going first
                local firstPlayer = (fight.ActiveSide == "Side1") and self.Owner:Nick() or target:Nick()

                local currentTurnPlayer = fight[fight.ActiveSide][fight.ActiveMember]

                self:AnnounceMessage(
                    firstPlayer .. "'s side is going first. It's " .. currentTurnPlayer:Name() .. "'s turn!"
                )

                for _, player in ipairs(fight.Side1) do
                    if IsValid(player) then -- Check if the player is valid
                        local permaBuffs = GetAllStats(player, "permabuffs")
                        if permaBuffs then
                            for status, properties in pairs(permaBuffs) do
                                AssignStat(player, status, properties, "buffs")

                                if properties.targets and properties.targets == "party" then
                                    for _, playerToBuff in ipairs(fight.Side1) do
                                        if IsValid(playerToBuff) and playerToBuff ~= player then -- Check if the player is valid
                                            AssignStat(playerToBuff, status, properties, "buffs")
                                        end
                                    end
                                end
                            end
                        end

                        local permaDebuffs = GetAllStats(player, "permadebuffs")
                        if permaDebuffs then
                            for status, properties in pairs(permaDebuffs) do
                                AssignStat(player, status, properties, "debuffs")

                                if properties.targets and properties.targets == "party" then
                                    for _, playerToDebuff in ipairs(fight.Side1) do
                                        if IsValid(playerToDebuff) and playerToDebuff ~= player then -- Check if the player is valid
                                            AssignStat(playerToDebuff, status, properties, "debuffs")
                                        end
                                    end
                                end
                            end
                        end

                        for _, weapon in pairs(player:GetWeapons()) do
                            if weapon.BuffType then
                                if weapon.BuffType == "both" then
                                    AssignStat(player, weapon.BuffName, weapon.BuffStructure, "buffs")
                                    AssignStat(player, weapon.BuffName, weapon.BuffStructure, "debuffs")
                                else
                                    AssignStat(player, weapon.BuffName, weapon.BuffStructure, weapon.BuffType)
                                end
                            end
                        end

                        player:EmitSound("common/stuck1.wav")

                        if player:IsPlayer() then
                            net.Start("PlayBattleMusic")
                            net.WriteEntity(player)
                            net.Send(player)
                        end
                    end
                end

                for _, player in ipairs(fight.Side2) do
                    if IsValid(player) then -- Check if the player is valid
                        local permaBuffs = GetAllStats(player, "permabuffs")
                        if permaBuffs then
                            for status, properties in pairs(permaBuffs) do
                                AssignStat(player, status, properties, "buffs")

                                if properties.targets and properties.targets == "party" then
                                    for _, playerToBuff in ipairs(fight.Side2) do
                                        if IsValid(playerToBuff) and playerToBuff ~= player then -- Check if the player is valid
                                            AssignStat(playerToBuff, status, properties, "buffs")
                                        end
                                    end
                                end
                            end
                        end

                        local permaDebuffs = GetAllStats(player, "permadebuffs")
                        if permaDebuffs then
                            for status, properties in pairs(permaDebuffs) do
                                AssignStat(player, status, properties, "debuffs")

                                if properties.targets and properties.targets == "party" then
                                    for _, playerToDebuff in ipairs(fight.Side2) do
                                        if IsValid(playerToDebuff) and playerToDebuff ~= player then -- Check if the player is valid
                                            AssignStat(playerToDebuff, status, properties, "debuffs")
                                        end
                                    end
                                end
                            end
                        end

                        for _, weapon in pairs(player:GetWeapons()) do
                            if weapon.BuffType then
                                if weapon.BuffType == "both" then
                                    AssignStat(player, weapon.BuffName, weapon.BuffStructure, "buffs")
                                    AssignStat(player, weapon.BuffName, weapon.BuffStructure, "debuffs")
                                else
                                    AssignStat(player, weapon.BuffName, weapon.BuffStructure, weapon.BuffType)
                                end
                            end
                        end

                        player:EmitSound("common/stuck1.wav")

                        if player:IsPlayer() then
                            net.Start("PlayBattleMusic")
                            net.WriteEntity(player)
                            net.Send(player)
                        end
                    end
                end
            end
            fight.Started = true -- Set the fight as started after the timer

            timer.Create(
                fightId,
                180,
                0,
                function()
                    self:AnnounceMessage("Time's up! Skipping turn.")
                    self:NextTurn(true)
                end
            )
        end
    )
end

function TBCWeaponMetatable:JoinFight(side)
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if fight then
        if SERVER then
            TBC_EnsurePartyForSideJoin(fight, side, self.Owner)
        end

        table.insert(fight[side], self.Owner)

        -- Propagate the FightId to all weapons of the player
        for _, weapon in pairs(self.Owner:GetWeapons()) do
            weapon.FightId = self.FightId
        end

        -- The joiner's deployed demon companions enter right after them
        if DEMONCOMP and DEMONCOMP.InsertFightDemonsForPlayer then
            DEMONCOMP.InsertFightDemonsForPlayer(fight, self.FightId, self.Owner)
        end
    end
end

function TBCWeaponMetatable:NextTurn(timerSkip)
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if not fight then
        self.Owner:ChatPrint("Fight not found.")
        return
    end

    -- Determine the current active side based on the player
    local currentActiveSide = fight.ActiveSide

    -- Check if the player is on the active side
    local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

    if currentTurnPlayer ~= self.Owner and not timerSkip then
        if SERVER and self.Owner then
            self.Owner:ChatPrint("It's not your turn.")
        end
    -- return
    end

    if timer.Exists(self.FightId) then
        timer.Start(self.FightId)
    else
        timer.Create(
            self.FightId,
            180,
            0,
            function()
                self:AnnounceMessage("Time's up! Skipping turn.")
                self:NextTurn(true)
                fight.AFKRequests = {}
            end
        )
    end

    if fight.TurnCounter > 0 then
        if SERVER then
            local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

            RemoveStat(currentTurnPlayer, "One_More", "buffs")
            RemoveStat(currentTurnPlayer, "Baton_Pass", "buffs")
        end

        fight.TurnCounter = fight.TurnCounter - 1
        fight.ActiveMember = fight.ActiveMember + 1

        if fight.ActiveMember > #fight[currentActiveSide] then
            fight.ActiveMember = 1
        end
        if SERVER and fight.TurnCounter > 0 then
            local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

            self:AnnounceMessage("It's " .. currentTurnPlayer:Name() .. "'s turn!")

            self:AilmentCheck(currentTurnPlayer, "turn")
            fight.AFKRequests = {}
        end
    end

    for _, player in ipairs(fight.Side1) do
        if IsValid(player) then
            player:EmitSound("common/stuck1.wav")
        end
    end

    for _, player in ipairs(fight.Side2) do
        if IsValid(player) then
            player:EmitSound("common/stuck1.wav")
        end
    end

    -- If TurnCounter reaches zero, swap sides and reset the TurnCounter for the new side
    if fight.TurnCounter <= 0 then
        -- Determine the new active side
        local newActiveSide = (currentActiveSide == "Side1") and "Side2" or "Side1"

        -- Update the currentActiveSide for the next turn
        fight.ActiveSide = newActiveSide

        local turnsCounter = 0
        for _, player in ipairs(fight[fight.ActiveSide]) do
            local charId = player:GetNWString("AssignedCharacter")
            local charData = CHARACTERS.List[charId]
            turnsCounter = turnsCounter + charData.turns

            RemoveStat(player, "Downed", "debuffs")
        end

        fight.CyclesDone = fight.CyclesDone + 0.5
        fight.TurnCounter = turnsCounter

        local currentTurnPlayer = fight[fight.ActiveSide][fight.ActiveMember]
        if SERVER then -- Check if it's the server side and the player exists
            self:AnnounceMessage("Switching sides! It's " .. currentTurnPlayer:Name() .. "'s turn!") -- Notify the player it's their turn

            local isTurnSkipped = false

            self:AilmentCheck(currentTurnPlayer, "cycle")
            fight.AFKRequests = {} -- Clear the AFKRequests table if no action was taken.
        end
    end
end

function TBCWeaponMetatable:EndFight()
    TBCWeaponMetatable.OngoingFights[self.FightId] = nil
    self.FightId = nil
end

function TBCWeaponMetatable:ClearFightId(player)
    -- this handles clearing the fightid from player weapons
    if not IsValid(player) then
        return
    end -- Ensure the player is valid

    -- Demon companions store their FightId on the entity itself
    if player.isTBCDemon then
        player.FightId = nil
    end

    for _, weapon in pairs(player:GetWeapons()) do
        if weapon.FightId then
            weapon.FightId = nil -- Clear the FightId
        end

        if weapon.CastedInBattle then
            weapon.CastedInBattle = false
        end
    end

    local buffsTable = GetAllStats(player, "buffs")

    for status, properties in pairs(buffsTable) do
        if properties.targets and properties.type == "victory" then
            HandleStatus(player, status, "victory", properties)
        end
    end

    RemoveAllStats(player, "buffs")
    RemoveAllStats(player, "debuffs")
end

function TBCWeaponMetatable:CheckForTeamDefeat(fightId)
    local fight = TBCWeaponMetatable.OngoingFights[fightId]
    if not fight then
        return
    end -- Exit if the fight does not exist

    -- Check each side to see if all players have TBCHP <= 0
    local allDeadSide1 = true
    local allDeadSide2 = true

    for _, player in ipairs(fight.Side1) do
        if player:GetNWInt("TBCHP", 0) > 0 then
            allDeadSide1 = false
            break -- If one player is alive, no need to check others
        end
    end

    for _, player in ipairs(fight.Side2) do
        if player:GetNWInt("TBCHP", 0) > 0 then
            allDeadSide2 = false
            break -- If one player is alive, no need to check others
        end
    end

    -- Check if all players on either side have disconnected
    local allGoneSide1 = #fight.Side1 == 0
    local allGoneSide2 = #fight.Side2 == 0

    -- Snapshot both sides before killing anyone: Kill()/death hooks remove
    -- members from the live arrays while we iterate, which skips members
    local side1Members = {}
    for _, member in ipairs(fight.Side1) do
        table.insert(side1Members, member)
    end
    local side2Members = {}
    for _, member in ipairs(fight.Side2) do
        table.insert(side2Members, member)
    end

    -- If all players on a side are "dead", trigger their gmod death
    if allDeadSide1 or allGoneSide1 then
        for _, player in ipairs(side1Members) do
            if IsValid(player) then player:Kill() end
        end
    elseif allDeadSide2 or allGoneSide2 then
        for _, player in ipairs(side2Members) do
            if IsValid(player) then player:Kill() end
        end
    end

    if (allDeadSide1 or allDeadSide2) or (allGoneSide1 or allGoneSide2) then
        for _, player in ipairs(side1Members) do
            if IsValid(player) then
                local playerSWEP = player:GetWeapon("smti_engageswep")
                if IsValid(playerSWEP) then
                    playerSWEP.InCombat = false
                    playerSWEP.Enemy = nil
                    playerSWEP.Allies = {}
                end

                TBCWeaponMetatable:ClearFightId(player)
            end
        end

        for _, player in ipairs(side2Members) do
            if IsValid(player) then
                local playerSWEP = player:GetWeapon("smti_engageswep")
                if IsValid(playerSWEP) then
                    playerSWEP.InCombat = false
                    playerSWEP.Enemy = nil
                    playerSWEP.Allies = {}
                end

                TBCWeaponMetatable:ClearFightId(player)
            end
        end

        -- Check if the victory message has already been sent for this fight
        if not victoryMessageSent[fightId] and victoryMessageSent[fightId] ~= nil then
            if allDeadSide1 then
                for _, player in ipairs(side2Members) do
                    if IsValid(player) and player:IsPlayer() then
                        player:ChatPrint("You have won the fight!")
                        net.Start("PlayVictoryMusic")
                        net.WriteEntity(player)
                        net.Send(player)
                    end
                end
            elseif allDeadSide2 then
                for _, player in ipairs(side1Members) do
                    if IsValid(player) and player:IsPlayer() then
                        player:ChatPrint("You have won the fight!")
                        net.Start("PlayVictoryMusic")
                        net.WriteEntity(player)
                        net.Send(player)
                    end
                end
            end
            -- Mark the victory message as sent for this fight
            victoryMessageSent[fightId] = true
        end

        timer.Remove(fightId)

        -- End the fight
        TBCWeaponMetatable.OngoingFights[fightId] = nil
    end
end

function TBCWeaponMetatable:Escape()
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if not fight then
        self.Owner:ChatPrint("Fight not found.")
        return
    end

    -- Determine the current active side based on the player calling this function
    local currentActiveSide = fight.ActiveSide

    -- Check if the player is on the active side
    local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

    if currentTurnPlayer ~= self.Owner then
        if SERVER and self.Owner then
            self.Owner:ChatPrint("It's not your turn.") -- Notify the player it's not their turn
        end
        return -- Exit the function as it's not the player's turn
    end

    local sides = {fight.Side1, fight.Side2} -- Create a table containing Side1 and Side2
    for _, players in ipairs(sides) do -- Iterate over Side1 and Side2
        for i, player in ipairs(players) do
            local charId = player:GetNWString("AssignedCharacter")
            local charData = CHARACTERS.List[charId]
            if charData then
                if charData.type == "Boss" then
                    self.Owner:ChatPrint("You can't escape if a Boss is in the fight!")
                    self:AnnounceMessage(self.Owner:Name() .. " tried to escape and failed!")
                    self:NextTurn(false)
                end
            end
        end
    end

    local ply = self.Owner

    local userBuffsTable = GetAllStats(ply, "buffs")
    local userDebuffsTable = GetAllStats(ply, "debuffs")

    local playerLuck = ply:GetNWInt("TBCLuck", 10)
    playerLuck =
        playerLuck +
        (HandleStatus(ply, userBuffsTable, "increaseLuck", playerLuck) -
            HandleStatus(ply, userDebuffsTable, "decreaseLuck", playerLuck))

    local escapeBonus = 0
    escapeBonus =
        (HandleStatus(ply, userBuffsTable, "increaseEscapeChance", escapeBonus) -
        HandleStatus(ply, userDebuffsTable, "decreaseEscapeChance", escapeBonus))

    local escapeChance = 20 + math.ceil(playerLuck / 2) + escapeBonus

    if math.random(1, 100) <= escapeChance then
        for _, players in ipairs(sides) do -- Iterate over Side1 and Side2
            for i, player in ipairs(players) do
                if player == ply then
                    table.remove(players, i)

                    -- The escapee's demon companions flee with them
                    if DEMONCOMP and DEMONCOMP.RemoveMastersDemonsFromFight then
                        DEMONCOMP.RemoveMastersDemonsFromFight(fight, ply)
                    end

                    self:AnnounceMessage(ply:Name() .. " has escaped the fight!")
                    ply:ChatPrint("You've successfully escaped the fight!")

                    local playerSWEP = player:GetWeapon("smti_engageswep")
                    if IsValid(playerSWEP) then
                        playerSWEP.InCombat = false
                        playerSWEP.Enemy = nil
                        playerSWEP.Allies = {}
                    end

                    self:CheckForTeamDefeat(self.FightId)
                    TBCWeaponMetatable:ClearFightId(player)

                    net.Start("PlayEndFightMusic")
                    net.WriteEntity(player)
                    net.Send(player)
                    break
                end
            end
        end
    else
        self:AnnounceMessage(self.Owner:Name() .. " tried to escape and failed!")
        self:NextTurn(false)
    end
end

-- For the /endfight command
function TBCWeaponMetatable:CheckEndFight()
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if not fight then
        return
    end

    local FightId = self.FightId

    local allRequestedEnd = true
    for _, player in ipairs(fight.Side1) do
        -- demon companions don't vote
        if not player.isTBCDemon and not fight.EndRequests[player:UserID()] then
            allRequestedEnd = false
            break
        end
    end
    for _, player in ipairs(fight.Side2) do
        if not player.isTBCDemon and not fight.EndRequests[player:UserID()] then
            allRequestedEnd = false
            break
        end
    end

    if allRequestedEnd then
        self:AnnounceMessage("Both sides have agreed to end the fight. It's a draw!")

        for _, player in ipairs(fight.Side1) do
            local playerSWEP = player:GetWeapon("smti_engageswep")
            if IsValid(playerSWEP) then
                playerSWEP.InCombat = false
                playerSWEP.Enemy = nil
                playerSWEP.Allies = {}
            end

            TBCWeaponMetatable:ClearFightId(player)

            if player:IsPlayer() then
                net.Start("PlayEndFightMusic")
                net.WriteEntity(player)
                net.Send(player)
            end
        end

        for _, player in ipairs(fight.Side2) do
            local playerSWEP = player:GetWeapon("smti_engageswep")
            if IsValid(playerSWEP) then
                playerSWEP.InCombat = false
                playerSWEP.Enemy = nil
                playerSWEP.Allies = {}
            end

            TBCWeaponMetatable:ClearFightId(player)

            if player:IsPlayer() then
                net.Start("PlayEndFightMusic")
                net.WriteEntity(player)
                net.Send(player)
            end
        end

        timer.Remove(FightId)

        -- End the fight
        TBCWeaponMetatable.OngoingFights[FightId] = nil
    end
end

-- Method to check if all players except the active player have voted to skip due to AFK
function TBCWeaponMetatable:CheckAFK()
    local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
    if not fight then
        return
    end

    local currentTurnPlayer = fight[fight.ActiveSide][fight.ActiveMember]
    local allVotedAFK = true
    local activeSidePlayers = fight[fight.ActiveSide]

    -- Loop through only the players on the same side as the active player
    for _, player in ipairs(activeSidePlayers) do
        -- demon companions don't vote
        if player ~= currentTurnPlayer and not player.isTBCDemon and
            not fight.AFKRequests[player:UserID()] then
            allVotedAFK = false
            break
        end
    end

    if allVotedAFK then
        self:AnnounceMessage("All players have voted to skip " .. currentTurnPlayer:Nick() .. "'s turn due to AFK.")
        self:NextTurn(true) -- Skip the active player's turn
    end
end

function TBCWeaponMetatable:EndAbility()
    local ply = self.Owner
    local timerName = "TurnEndTimer_" .. ply:UserID()

    -- Check if the timer already exists before creating a new one in case of AoE rolling
    if not timer.Exists(timerName) then
        timer.Create(
            timerName,
            1,
            1,
            function()
                local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
                if not fight then
                    return
                end

                local buffsTable = GetAllStats(ply, "buffs")

                local hasOneMore = buffsTable["One_More"] ~= nil

                -- If the player is acting through a demon companion, One More
                -- lands on the demon instead - honor it as well
                if not hasOneMore and IsValid(ply.TBCControlledDemon) then
                    local demonBuffs = GetAllStats(ply.TBCControlledDemon, "buffs")
                    hasOneMore = demonBuffs["One_More"] ~= nil
                end

                if not hasOneMore then
                    self:AnnounceMessage(ply:Name() .. "'s turn has ended!")
                    RunConsoleCommand("useturn")
                else
                    self:AnnounceMessage(ply:Name() .. " gains One More!")
                end
            end
        )
    end
end

-- Hook to reset InCombat variable when a player dies
hook.Add(
    "PlayerDeath",
    "ResetInCombatOnDeath",
    function(victim, inflictor, attacker)
        local deceasedSWEP = victim:GetWeapon("smti_engageswep")
        if not IsValid(deceasedSWEP) then
            return
        end -- Exit if the victim does not have the Engage SWEP

        local fight = TBCWeaponMetatable.OngoingFights[deceasedSWEP.FightId]
        if not fight then
            return
        end -- Exit if the fight does not exist

        victim:ChatPrint("You have lost the battle.")

        -- Remove the deceased player from their side
        local sides = {fight.Side1, fight.Side2} -- Create a table containing Side1 and Side2
        for _, players in ipairs(sides) do -- Iterate over Side1 and Side2
            for i, player in ipairs(players) do
                if player == victim then
                    table.remove(players, i)
                    break
                end
            end
        end

        deceasedSWEP:CheckForTeamDefeat(deceasedSWEP.FightId)

        -- Reset combat status and references for the deceased player
        deceasedSWEP.InCombat = false
        deceasedSWEP.Enemy = nil
        deceasedSWEP.Allies = {}

        -- Clear the FightId for the deceased player's weapons
        TBCWeaponMetatable:ClearFightId(victim)

        net.Start("PlayEndFightMusic")
        net.WriteEntity(victim)
        net.Send(victim)
    end
)

hook.Add(
    "PlayerDisconnected",
    "HandlePlayerDisconnection",
    function(leavingPlayer)
        local playerSWEP = leavingPlayer:GetWeapon("smti_engageswep")
        if not IsValid(playerSWEP) then
            return
        end -- Exit if the disconnecting player does not have the Engage SWEP

        local fight = TBCWeaponMetatable.OngoingFights[playerSWEP.FightId]
        if not fight then
            return
        end -- Exit if the fight does not exist

        -- Remove the disconnecting player from their side
        local sides = {fight.Side1, fight.Side2}
        for _, players in ipairs(sides) do
            for i, player in ipairs(players) do
                if player == leavingPlayer then
                    table.remove(players, i)
                    break
                end
            end
        end

        playerSWEP:CheckForTeamDefeat(playerSWEP.FightId)
    end
)

if SERVER then
    util.AddNetworkString("ClearTargetedPlayers")
    util.AddNetworkString("PlayBattleMusic")
    util.AddNetworkString("PlayVictoryMusic")
    util.AddNetworkString("PlayEndFightMusic")

    hook.Add(
        "PlayerSwitchWeapon",
        "AssigningFightID",
        function(ply, oldWeapon, newWeapon)
            if not newWeapon.FightId and oldWeapon.FightId then
                newWeapon.FightId = oldWeapon.FightId
            end
        end
    )
end

if CLIENT then
    local targetedPlayers = {}

    net.Receive(
        "UpdateTargetedPlayers",
        function(len)
            targetedPlayers = net.ReadTable()
        end
    )

    net.Receive(
        "ClearTargetedPlayers",
        function(len)
            targetedPlayers = {} -- Clear the table
        end
    )

    hook.Add(
        "PlayerSwitchWeapon",
        "ClearTable",
        function(ply, oldWeapon, newWeapon)
            targetedPlayers = {} -- Clear the table
        end
    )

    hook.Add(
        "PostDrawTranslucentRenderables",
        "DrawTargetIndicators",
        function()
            for _, ent in pairs(targetedPlayers) do
                if IsValid(ent) then
                    local pos = ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z + 10) -- Position above the player's head
                    local ang = EyeAngles()
                    ang:RotateAroundAxis(ang:Forward(), 90)
                    ang:RotateAroundAxis(ang:Right(), 90)

                    cam.Start3D2D(pos, ang, 0.5)
                    draw.SimpleTextOutlined(
                        "Targeted",
                        "Default",
                        0,
                        0,
                        Color(255, 0, 0),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        1,
                        Color(0, 0, 0)
                    )
                    cam.End3D2D()
                end
            end
        end
    )

    net.Receive(
        "PlayBattleMusic",
        function(len)
            local player = net.ReadEntity()
            if not IsValid(player) then
                return
            end

            PlayBattleMusic()
        end
    )

    net.Receive(
        "PlayVictoryMusic",
        function(len)
            local player = net.ReadEntity()
            if not IsValid(player) then
                return
            end

            PlayVictoryMusic()
        end
    )

    net.Receive(
        "PlayEndFightMusic",
        function(len)
            local player = net.ReadEntity()
            if not IsValid(player) then
                return
            end

            EndFightMusic()
        end
    )
end
