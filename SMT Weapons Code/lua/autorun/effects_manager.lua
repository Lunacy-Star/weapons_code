function CheckIfValidTBCEntity(entity)
    if not entity:IsValid() then
        return false
    end

    if entity:IsPlayer() then
        return "player"
    end

    if entity.isTBCEntity then
        return "tbcEntity"
    end

    return false
end

function PlayerCheckEngageSWEP(ply)
    local engageWeapon = ply:GetWeapon("smti_engageswep")
    if not IsValid(engageWeapon) then
        ply:ChatPrint("You MUST have the Engage SWEP or else!")
        return false
    end

    return true
end

function PlayerCanUseSkills(ply, buffs, debuffs)
    local targetEffects = {}

    targetEffects["userBuffsTable"] = buffs
    targetEffects["userDebuffsTable"] = debuffs

    local status = HandleStatus(ply, targetEffects["userDebuffsTable"], "canUseSkills", true, targetEffects)

    if not status then
        return false
    end

    return true
end

function PlayerCanUseHPSkills(ply, hpCost, buffs, debuffs)
    local attackerHP = ply:GetNWInt("TBCHP", 100)

    hpCost =
        hpCost +
        (HandleStatus(ply, buffs, "increaseHPCost", hpCost) - HandleStatus(ply, debuffs, "decreaseHPCost", hpCost))

    if attackerHP >= hpCost then
        ply:SetNWInt("TBCHP", attackerHP - hpCost)
    else
        ply:ChatPrint("Not enough HP to use this ability.")
        return false
    end

    return true
end

function PlayerCanUseMPSkills(ply, mpCost, buffs, debuffs)
    local attackerMP = ply:GetNWInt("TBCMP", 100)

    mpCost =
        mpCost +
        (HandleStatus(ply, buffs, "increaseMPCost", mpCost) - HandleStatus(ply, debuffs, "decreaseMPCost", mpCost))

    if attackerMP >= mpCost then
        ply:SetNWInt("TBCMP", attackerMP - mpCost)
    else
        ply:ChatPrint("Not enough MP to use this ability.")
        return false
    end

    return true
end

function RollAoETargets(ply, target, weapon, tech)
    local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
    if fight then
    else
        return
    end

    local playerSide =
        (table.HasValue(fight.Side1, target) and "Side1") or (table.HasValue(fight.Side2, target) and "Side2")

    local playersInFight = {}
    for _, player in ipairs(fight[playerSide]) do
        if CheckIfValidTBCEntity(player) then
            local currentHP = player:GetNWInt("TBCHP", 100)
            if currentHP > 0 then
                -- `target` already got its hit effect from TargetCheckValidity;
                -- this covers the rest of the AoE's side, hit or miss alike.
                if player ~= target and SMTParticles then
                    SMTParticles.TriggerForWeapon(weapon, player)
                end

                if weapon:AbilityRollNumber(tech, player) then
                    table.insert(playersInFight, player)
                end
            end
        end
    end

    return playersInFight
end

function PlayerCheckFight(ply)
    local engageWeapon = ply:GetWeapon("smti_engageswep")

    if not engageWeapon.FightId or not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
        ply:ChatPrint("You are not in a fight!")
        return false
    end

    local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
    if not fight.Started then
        ply:ChatPrint("The fight has not started yet.")
        return false
    else
        if (timer.Exists("TurnEndTimer_" .. ply:UserID())) then
            ply:ChatPrint("Can you wait a little bit? Let it sync in...")
            return false
        end

        local currentActiveSide = fight.ActiveSide
        local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

        if currentTurnPlayer ~= ply then
            -- A master acting through their demon companion may act on the demon's turn
            local controlledDemon = ply.TBCControlledDemon
            if not (IsValid(controlledDemon) and currentTurnPlayer == controlledDemon) then
                ply:ChatPrint("It's not your turn yet.")
                return false
            end
        end

        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            local buffsTable = GetAllStats(ply, "buffs")
            if buffsTable["One_More"] and weapon.WeaponType ~= "Combat Tactic" then
                ply:ChatPrint("You can only use Combat Tactics with One More.")
                return false
            end
        end
    end

    return true
end

function TargetCheckValidity(ply, target, hpValidation)
    local engageWeaponPly = ply:GetWeapon("smti_engageswep")
    if not IsValid(target) then
        return false
    end

    -- Demon companions carry their FightId directly instead of on an engage swep
    if target.isTBCDemon then
        if target.FightId ~= engageWeaponPly.FightId then
            ply:ChatPrint("Target is not in your fight.")
            return false
        end

        if hpValidation and target:GetNWInt("TBCHP", 100) <= 0 then
            ply:ChatPrint("You can't target this individual. They are dead.")
            return false
        end

        if SMTParticles then
            SMTParticles.TriggerForWeapon(ply:GetActiveWeapon(), target)
        end

        return true
    end

    local engageWeapon = target:GetWeapon("smti_engageswep")
    if not IsValid(engageWeapon) then
        ply:ChatPrint("Target does not have an engage swep.")
        return false
    end

    if engageWeapon.FightId ~= engageWeaponPly.FightId then
        ply:ChatPrint("Target is not in your fight.")
        return false
    end

    if hpValidation then
        local currentHP = target:GetNWInt("TBCHP", 100)
        if currentHP <= 0 then
            local message = "You can't target this individual. They are dead."
            ply:ChatPrint(message)
            return false
        end
    end

    if SMTParticles then
        SMTParticles.TriggerForWeapon(ply:GetActiveWeapon(), target)
    end

    return true
end

function HealCheckValidity(ply, target)
    local inAFight = true
    local resultsArray = {["inAFight"] = true, ["validated"] = false}

    local engageWeaponPly = ply:GetWeapon("smti_engageswep")
    if not IsValid(engageWeaponPly) then
        ply:ChatPrint("You MUST have the Engage SWEP or else!")
        return false
    end

    if not engageWeaponPly.FightId or not TBCWeaponMetatable.OngoingFights[engageWeaponPly.FightId] then
        inAFight = false
    end

    if inAFight then
        local fight = TBCWeaponMetatable.OngoingFights[engageWeaponPly.FightId]
        if not fight.Started then
            ply:ChatPrint("The fight has not started yet.")
            return false
        end

        local currentActiveSide = fight.ActiveSide
        local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

        if currentTurnPlayer ~= ply then
            -- A master acting through their demon companion may act on the demon's turn
            local controlledDemon = ply.TBCControlledDemon
            if not (IsValid(controlledDemon) and currentTurnPlayer == controlledDemon) then
                ply:ChatPrint("It's not your turn yet.")
                return false
            end
        end
    end

    -- Demon companions carry their FightId directly instead of on an engage swep
    if target.isTBCDemon then
        if target.FightId ~= engageWeaponPly.FightId then
            ply:ChatPrint("Target is not in your fight.")
            return false
        end

        resultsArray["inAFight"] = inAFight
        resultsArray["validated"] = true

        if SMTParticles then
            SMTParticles.TriggerForWeapon(ply:GetActiveWeapon(), target)
        end

        return resultsArray
    end

    local engageWeapon = target:GetWeapon("smti_engageswep")
    if not IsValid(engageWeapon) then
        ply:ChatPrint("Target does not have an engage swep.")
        return false
    end

    if engageWeapon.FightId ~= engageWeaponPly.FightId then
        ply:ChatPrint("Target is not in your fight.")
        return false
    end

    resultsArray["inAFight"] = inAFight
    resultsArray["validated"] = true

    if SMTParticles then
        SMTParticles.TriggerForWeapon(ply:GetActiveWeapon(), target)
    end

    return resultsArray
end

function PickUpEntityValidity(ply, slotType)
    local EquipmentSlots = ply:GetNWInt("TBCEquipmentSlots", 15)
    local ItemsSlots = ply:GetNWInt("TBCItemSlots", 10)
    local EquipmentSlotsAvailable = 0
    local ItemSlotsAvailable = 0

    for _, plyweapon in pairs(ply:GetWeapons()) do
        if plyweapon.SlotType then
            if plyweapon.SlotType == "Equipment" and plyweapon.SlotsTaking then
                EquipmentSlotsAvailable = EquipmentSlotsAvailable + plyweapon.SlotsTaking
            elseif plyweapon.SlotType == "Item" and plyweapon.SlotsTaking then
                ItemSlotsAvailable = ItemSlotsAvailable + plyweapon.SlotsTaking
            end
        end
    end

    local buffs = GetAllStats(ply, "permabuffs")
    if buffs then
        for ailmentName, ailmentInfo in pairs(buffs) do
            if ailmentInfo.SlotType then
                if ailmentInfo.SlotType == "Equipment" and ailmentInfo.SlotsTaking then
                    EquipmentSlotsAvailable = EquipmentSlotsAvailable + ailmentInfo.SlotsTaking
                elseif ailmentInfo.SlotType == "Item" and ailmentInfo.SlotsTaking then
                    ItemSlotsAvailable = ItemSlotsAvailable + ailmentInfo.SlotsTaking
                end
            end
        end
    end

    if slotType == "Equipment" then
        if EquipmentSlotsAvailable >= EquipmentSlots then
            ply:ChatPrint("You've reached your inventory Equipment limit!")
            return false
        end
    elseif slotType == "Item" then
        if ItemSlotsAvailable >= ItemsSlots then
            ply:ChatPrint("You've reached your inventory Item limit!")
            return false
        end
    end

    return true
end

function HandleRepel(ply, target, effectsTable)
    local repel = util.JSONToTable(target:GetNW2String("repel"))
    local isRepelled = false

    if effectsTable["targetBuffsTable"]["Tetrakarn"] and table.HasValue(Affinities.Physical, effectsTable["Affinity"]) then
        RemoveStat(target, "Tetrakarn", "buffs")
        effectsTable["targetBuffsTable"]["Tetrakarn"] = nil
        isRepelled = true
    end

    if effectsTable["targetBuffsTable"]["Makarakarn"] and table.HasValue(Affinities.Magic, effectsTable["Affinity"]) then
        RemoveStat(target, "Makarakarn", "buffs")
        effectsTable["targetBuffsTable"]["Makarakarn"] = nil
        isRepelled = true
    end

    if
        table.HasValue(repel, effectsTable["Affinity"]) or
            (table.HasValue(repel, "Magic") and table.HasValue(Affinities.Magic, effectsTable["Affinity"])) or
            (table.HasValue(repel, "Physical") and table.HasValue(Affinities.Physical, effectsTable["Affinity"]))
     then
        isRepelled = true
    end

    if isRepelled then
        if SMTDamageNumbers then
            SMTDamageNumbers.Show(target, nil, "repel")
        end

        effectsTable["state"] = "repel"
        effectsTable["target"] = ply
        effectsTable["targetBuffsTable"] = effectsTable["userBuffsTable"]
        effectsTable["targetDebuffsTable"] = effectsTable["userDebuffsTable"]
    end

    return effectsTable
end

function HandleResistances(ply, target, effectsTable)
    local resist = util.JSONToTable(target:GetNW2String("resist"))
    local IsResisted = false

    if HandleStatus(target, effectsTable["targetBuffsTable"], "wallChecks", effectsTable["Affinity"], effectsTable) then
        IsResisted = true
    end

    if HandleStatus(target, effectsTable["targetBuffsTable"], "resistChecks", effectsTable["Affinity"], effectsTable) then
        IsResisted = true
    end

    -- Modify damage based on resistances, weaknesses, and blocks
    if
        table.HasValue(resist, effectsTable["Affinity"]) or
            (table.HasValue(resist, "Magic") and table.HasValue(Affinities.Magic, effectsTable["Affinity"])) or
            (table.HasValue(resist, "Physical") and table.HasValue(Affinities.Physical, effectsTable["Affinity"]))
     then
        IsResisted = true
    end

    if IsResisted then
        local resistModifier = 0.9

        resistModifier =
            resistModifier +
            (HandleStatus(ply, effectsTable["userBuffsTable"], "increaseResistDamage", resistModifier) -
                HandleStatus(ply, effectsTable["userDebuffsTable"], "decreaseResistDamage", resistModifier)) -
            (HandleStatus(
                effectsTable["target"],
                effectsTable["targetDebuffsTable"],
                "increaseResistDamageReceive",
                resistModifier
            ) -
                HandleStatus(
                    effectsTable["target"],
                    effectsTable["targetBuffsTable"],
                    "decreaseResistDamageReceive",
                    resistModifier
                ))

        effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"] * resistModifier)
        if effectsTable["ailmentChance"] then
            effectsTable["ailmentChance"] = effectsTable["ailmentChance"] - 15
        end
        effectsTable["state"] = "resist"
    end

    return effectsTable
end

function HandleWeaknesses(ply, target, effectsTable)
    local weak = util.JSONToTable(target:GetNW2String("weak"))

    if
        table.HasValue(weak, effectsTable["Affinity"]) or
            (table.HasValue(weak, "Magic") and table.HasValue(Affinities["Magic"], effectsTable["Affinity"])) or
            (table.HasValue(weak, "Physical") and table.HasValue(Affinities.Physical, effectsTable["Affinity"]))
     then
        local weakModifier = 1.1

        weakModifier =
            weakModifier +
            (HandleStatus(ply, effectsTable["userBuffsTable"], "increaseWeakDamage", weakModifier) -
                HandleStatus(ply, effectsTable["userDebuffsTable"], "decreaseWeakDamage", weakModifier)) -
            (HandleStatus(
                effectsTable["target"],
                effectsTable["targetDebuffsTable"],
                "increaseWeakDamageReceive",
                weakModifier
            ) -
                HandleStatus(
                    effectsTable["target"],
                    effectsTable["targetBuffsTable"],
                    "decreaseWeakDamageReceive",
                    weakModifier
                ))

        effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"] * weakModifier) -- Increase damage if weakness is found
        if effectsTable["ailmentChance"] then
            effectsTable["ailmentChance"] = effectsTable["ailmentChance"] + 5
        end
        effectsTable["state"] = "weak"
    end

    return effectsTable
end

function HandleBlock(ply, target, effectsTable)
    local block = util.JSONToTable(target:GetNW2String("block"))
    local IsResisted = false

    if HandleStatus(target, effectsTable["targetBuffsTable"], "blockChecks", effectsTable["Affinity"], effectsTable) then
        IsResisted = true
    end

    if
        table.HasValue(block, effectsTable["Affinity"]) or
            (table.HasValue(block, "Magic") and table.HasValue(Affinities.Magic, effectsTable["Affinity"])) or
            (table.HasValue(block, "Physical") and table.HasValue(Affinities.Physical, effectsTable["Affinity"]))
     then
        IsResisted = true
    end

    if IsResisted then
        effectsTable["baseDamage"] = 0
        if effectsTable["ailmentChance"] then
            effectsTable["ailmentChance"] = 0
        end
        effectsTable["state"] = "block"
    end

    return effectsTable
end

function HandleDrain(ply, target, effectsTable)
    local drain = util.JSONToTable(target:GetNW2String("drain"))

    if
        table.HasValue(drain, effectsTable["Affinity"]) or
            (table.HasValue(drain, "Magic") and table.HasValue(Affinities.Magic, effectsTable["Affinity"])) or
            (table.HasValue(drain, "Physical") and table.HasValue(Affinities.Physical, effectsTable["Affinity"]))
     then
        if effectsTable["ailmentChance"] then
            effectsTable["ailmentChance"] = 0
        end
        effectsTable["state"] = "drain"
        effectsTable["message"] =
            target:Name() .. " drained the attack and received " .. effectsTable["baseDamage"] .. " health!"
    end

    return effectsTable
end

function HandleCrit(ply, target, effectsTable)
    if math.random(0, 100) <= effectsTable["critChance"] then
        effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"] * 1.1) -- Increase damage by 10%
        effectsTable["state"] = "crit"
    end

    return effectsTable
end

function HandleBonusDamage(ply, target, effectsTable)
    local weapon = ply:GetActiveWeapon()

    local totalBonusDamage = 0
    for status, properties in pairs(effectsTable["userBuffsTable"]) do
        if properties.type == "bonusCritDamage" then
            local bonusDamageArray = HandleStatus(ply, status, "bonusCritDamage", properties)

            effectsTable["baseDamage"] = math.ceil(bonusDamageArray["Damage"])
            effectsTable["Affinity"] = bonusDamageArray["Affinity"]

            if effectsTable["baseDamage"] > 0 then
                effectsTable = HandleResistances(ply, target, effectsTable)
                effectsTable = HandleWeaknesses(ply, target, effectsTable)
                effectsTable = HandleBlock(ply, target, effectsTable)
                effectsTable = HandleDrain(ply, target, effectsTable)

                effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"])

                effectsTable["baseDamage"] =
                    effectsTable["baseDamage"] +
                    (HandleStatus(
                        target,
                        effectsTable["targetBuffsTable"],
                        "defenseDamage",
                        effectsTable["baseDamage"],
                        effectsTable
                    ) -
                        HandleStatus(
                            target,
                            effectsTable["targetDebuffsTable"],
                            "defenseDecrease",
                            effectsTable["baseDamage"],
                            effectsTable
                        ))

                effectsTable["baseDamage"] = math.ceil(effectsTable["baseDamage"])

                totalBonusDamage = totalBonusDamage + effectsTable["baseDamage"]

                weapon:AnnounceMessage(
                    target:Name() .. " receives " .. effectsTable["baseDamage"] .. " damage due to " .. status .. "!"
                )

                if properties.duration then
                    effectsTable["userBuffsTable"][status].duration =
                        effectsTable["userBuffsTable"][status].duration - 1
                    if properties.duration <= 0 then
                        effectsTable["userBuffsTable"][status] = nil
                        weapon:AnnounceMessage(ply:Name() .. "'s " .. status .. " has worn off!")
                    end

                    AssignStat(ply, status, effectsTable["userBuffsTable"][status], "buffs")
                end
            end
        end
    end
    return totalBonusDamage
end

function HandleDamageMessage(ply, target, effectsTable)
    if effectsTable["state"] == "crit" then
        effectsTable["message"] =
            target:Name() .. " is hit with a critical strike for " .. effectsTable["baseDamage"] .. " damage!"
    elseif effectsTable["state"] == "weak" then
        effectsTable["message"] =
            target:Name() .. "'s weakness is hit and received " .. effectsTable["baseDamage"] .. " damage!"
    elseif effectsTable["state"] == "resist" then
        effectsTable["message"] = target:Name() .. " resisted and received " .. effectsTable["baseDamage"] .. " damage!"
    elseif effectsTable["state"] == "block" then
        effectsTable["baseDamage"] = 0
        effectsTable["message"] = target:Name() .. " blocked and received " .. effectsTable["baseDamage"] .. " damage!"
    elseif effectsTable["state"] == "drain" then
        effectsTable["message"] =
            target:Name() .. " drained the attack and received " .. effectsTable["baseDamage"] .. " health!"
    else
        effectsTable["message"] = target:Name() .. " received " .. effectsTable["baseDamage"] .. " damage!"
    end

    if SMTDamageNumbers then
        if effectsTable["state"] == "block" then
            SMTDamageNumbers.Show(target, nil, "block")
        else
            SMTDamageNumbers.Show(target, effectsTable["baseDamage"], effectsTable["state"])
        end
    end

    HandleStateEffects(ply, target, effectsTable)

    return effectsTable
end

function HandleDeath(ply, target, effectsTable)
    for status, properties in pairs(effectsTable["targetBuffsTable"]) do
        if properties.type == "deathState" then
            local personState = HandleStatus(target, status, "deathState", effectsTable["lifeState"])

            if personState ~= "dead" then
                effectsTable["lifeState"] = personState
            end
        end
    end

    if effectsTable["lifeState"] == "dead" then
        local weapon = ply:GetActiveWeapon()

        local message = target:Name() .. " is dead!"
        weapon:AnnounceMessage(message)

        if SMTDamageNumbers then
            SMTDamageNumbers.Show(target, nil, "dead")
        end

        RemoveAllStats(target, "buffs")
        RemoveAllStats(target, "debuffs")
    end

    return effectsTable
end

function HandleKill(ply, target, effectsTable)
    if effectsTable["lifeState"] == "dead" then
        if target ~= ply then
            for status, properties in pairs(effectsTable["userBuffsTable"]) do
                if properties.type == "kill" then
                    HandleStatus(ply, status, "kill", effectsTable["lifeState"])
                end
            end
        end
    end

    return effectsTable
end

function HandleHealingEffects(ply, target, effectsTable)
    HandleStatus(ply, effectsTable["userBuffsTable"], "reactionHeal", "heal", effectsTable)
    HandleStatus(target, effectsTable["targetBuffsTable"], "reactionHeal", "heal", effectsTable)

    if SMTDamageNumbers then
        SMTDamageNumbers.Show(target, effectsTable["baseDamage"], "heal")
    end

    return effectsTable
end

function HandleRandomAilment(ply, target, effectsTable)
    local ailmentTable = {}
    local weapon = ply:GetActiveWeapon()

    local chanceTime = math.random(1, 10)

    if chanceTime == 1 then
        ailmentTable["Charm"] = {
            stacks = 1,
            wearOff = "turnWearOff",
            duration = 4
        }

        AssignStat(target, "Charm", ailmentTable["Charm"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Charmed!")
    elseif chanceTime == 2 then
        ailmentTable["Mute"] = {
            stacks = 1,
            type = "skillPrevent",
            wearOff = "turnWearOff",
            duration = 4
        }

        AssignStat(target, "Mute", ailmentTable["Mute"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Muted!")
    elseif chanceTime == 3 then
        ailmentTable["Paralysis"] = {
            stacks = 1,
            type = "turnSkipper",
            wearOff = "turnWearOff",
            duration = 3
        }

        AssignStat(target, "Paralysis", ailmentTable["Paralysis"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Paralyzed!")
    elseif chanceTime == 4 then
        ailmentTable["Shock"] = {stacks = 1, type = "turnSkipper", duration = 3}

        AssignStat(target, "Shock", ailmentTable["Shock"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Shocked!")
    elseif chanceTime == 5 then
        ailmentTable["Freeze"] = {
            stacks = 1,
            type = "turnSkipper",
            duration = 3
        }

        AssignStat(target, "Freeze", ailmentTable["Freeze"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Frozen!")
    elseif chanceTime == 6 then
        ailmentTable["Burn"] = {
            stacks = 1,
            type = "turnDamage",
            affinity = "fire",
            duration = 3
        }

        AssignStat(target, "Burn", ailmentTable["Burn"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Burning!")
    elseif chanceTime == 7 then
        ailmentTable["Cursed"] = {stacks = 1, duration = 3}

        AssignStat(target, "Cursed", ailmentTable["Cursed"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Cursed!")
    elseif chanceTime == 8 then
        ailmentTable["Judgement"] = {stacks = 1, duration = 3}

        AssignStat(target, "Judgement", ailmentTable["Judgement"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Judged!")
    elseif chanceTime == 9 then
        ailmentTable["Panic"] = {
            stacks = 1,
            wearOff = "turnWearOff",
            duration = 3
        }

        AssignStat(target, "Judgement", ailmentTable["Panic"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Panicking!")
    elseif chanceTime == 10 then
        ailmentTable["Poison"] = {
            stacks = 1,
            type = "turnDamage",
            affinity = "Almighty",
            wearOff = "turnWearOff",
            duration = 4
        }

        AssignStat(target, "Poison", ailmentTable["Poison"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now Poisoned!")
    end

    return ailmentTable
end

function HandleRandomKaja(ply, target, effectsTable)
    local ailmentTable = {}
    local weapon = ply:GetActiveWeapon()

    local chanceTime = math.random(1, 3)

    if chanceTime == 1 then
        local buffsTable = GetAllStats(target, "buffs")

        if buffsTable["Rakukaja"] then
            buffsTable["Rakukaja"].stacks = math.min(buffsTable["Rakukaja"].stacks + 1, 4)
        else
            buffsTable["Rakukaja"] = {stacks = 1}
        end

        AssignStat(target, "Rakukaja", buffsTable["Rakukaja"], "buffs")

        effectsTable["buff"] = "Rakukaja"

        HandleStatus(target, buffsTable, "reactionBuff", "buff", effectsTable)

        local message =
            target:Name() ..
            " received Rakukaja from " ..
                ply:Name() .. "! They now have " .. buffsTable["Rakukaja"].stacks .. " Rakukaja!"

        weapon:AnnounceMessage(message)
    elseif chanceTime == 2 then
        local buffsTable = GetAllStats(target, "buffs")

        if buffsTable["Sukukaja"] then
            buffsTable["Sukukaja"].stacks = math.min(buffsTable["Sukukaja"].stacks + 1, 4)
        else
            buffsTable["Sukukaja"] = {stacks = 1}
        end

        AssignStat(target, "Sukukaja", buffsTable["Sukukaja"], "buffs")

        effectsTable["buff"] = "Sukukaja"

        HandleStatus(target, buffsTable, "reactionBuff", "buff", effectsTable)

        local message =
            target:Name() ..
            " received Sukukaja from " ..
                ply:Name() .. "! They now have " .. buffsTable["Sukukaja"].stacks .. " Sukukaja!"

        weapon:AnnounceMessage(message)
    elseif chanceTime == 3 then
        local buffsTable = GetAllStats(target, "buffs")

        if buffsTable["Tarukaja"] then
            buffsTable["Tarukaja"].stacks = math.min(buffsTable["Tarukaja"].stacks + 1, 4)
        else
            buffsTable["Tarukaja"] = {stacks = 1}
        end

        AssignStat(target, "Tarukaja", buffsTable["Tarukaja"], "buffs")

        effectsTable["buff"] = "Tarukaja"

        HandleStatus(target, buffsTable, "reactionBuff", "buff", effectsTable)

        local message =
            target:Name() ..
            " received Tarukaja from " ..
                ply:Name() .. "! They now have " .. buffsTable["Tarukaja"].stacks .. " Tarukaja!"

        weapon:AnnounceMessage(message)
    end

    return ailmentTable
end

function HandleInstakill(ply, target, effectsTable)
    local charId = effectsTable["target"]:GetNWString("AssignedCharacter")
    local charData = CHARACTERS.List[charId]
    if charData and charData.type == "Boss" then
        return false
    end

    if effectsTable["targetBuffsTable"]["Tetraja"] then
        RemoveStat(target, "Tetraja", "buffs")
        effectsTable["targetBuffsTable"]["Tetraja"] = nil

        local weapon = target:GetActiveWeapon()

        local message = "Tetraja saves " .. target:Name() .. "!"
        weapon:AnnounceMessage(message)

        return false
    end

    if effectsTable["state"] == "drain" and effectsTable["state"] == "block" and effectsTable["state"] == "resist" then
        return false
    end

    effectsTable["target"]:SetNWInt("TBCHP", 0)

    if SMTDamageNumbers then
        SMTDamageNumbers.Show(effectsTable["target"], nil, "dead")
    end

    self:AnnounceMessage(effectsTable["target"]:Name() .. " is killed instantly!")

    return true
end

function HandleStateEffects(ply, target, effectsTable)
    if effectsTable["targetDebuffsTable"]["Downed"] == nil then
        if effectsTable["state"] == "weak" or effectsTable["state"] == "crit" then
            local downingChance = 100

            downingChance =
                downingChance +
                (HandleStatus(ply, effectsTable["userBuffsTable"], "increaseDownChance", downingChance, effectsTable) -
                    HandleStatus(
                        ply,
                        effectsTable["userDebuffsTable"],
                        "decreaseDownChance",
                        downingChance,
                        effectsTable
                    )) -
                (HandleStatus(
                    target,
                    effectsTable["targetBuffsTable"],
                    "increaseDownDefense",
                    downingChance,
                    effectsTable
                ) -
                    HandleStatus(
                        target,
                        effectsTable["targetDebuffsTable"],
                        "decreaseDownDefense",
                        downingChance,
                        effectsTable
                    ))

            if math.random(1, 100) <= downingChance then
                effectsTable["targetDebuffsTable"]["Downed"] = {
                    stacks = 1,
                    durationCycle = 1
                }

                effectsTable["userBuffsTable"]["One_More"] = {
                    stacks = 1,
                    duration = 1
                }

                AssignStat(target, "Downed", effectsTable["targetDebuffsTable"]["Downed"], "debuffs")

                AssignStat(ply, "One_More", effectsTable["userBuffsTable"]["One_More"], "buffs")

                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) then
                    weapon:AnnounceMessage(target:Name() .. " is down!")
                end
            end
        end
    end

    return effectsTable
end

function HandleGuardReaction(ply, buffs)
    if buffs["Screw_Lance"] then
        if buffs["Rakukaja"] then
            buffs["Rakukaja"].stacks = math.min(buffs["Rakukaja"].stacks + 1, 4)
        else
            buffs["Rakukaja"] = {stacks = 1}
        end

        AssignStat(ply, "Rakukaja", buffs["Rakukaja"], "buffs")
    end

    return buffs
end
