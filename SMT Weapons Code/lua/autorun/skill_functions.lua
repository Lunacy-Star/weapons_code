SkillProperties = {

    -- Offensive Magic Skills 
    ["Absolute Zero"] = {
        name = "Absolute Zero",
        description = "Maya must have two Ice-Type skills to be able to use this ability (Persona skills applicable). Maya hits all enemies twice, dealing 30 Ice damage in the first hit and 30 Ice damage in the second. The First hit has a (Luck + DEX)% chance to kill any enemy who is frozen.",
        damage = 30,
        cost = 25,
        defaultTech = 15,
        costType = "MP",
        affinity = "Dual",
        weaponType = "Magic Skill",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Agi"] = {
        name = "Agi",
        description = "40 fire damage to a single target. 10% chance to inflict Burn.\n[STR 4] MP Cost reduced to 4 MP.\n[CHR 4] 20% chance to inflict Burn.",
        damage = 40,
        cost = 6,
        defaultTech = 15,
        costType = "MP",
        affinity = "Fire",
        weaponType = "Magic Skill",
        slotSize = 1,
        slotType = "Equipment"
    },

    -- Offensive Magic Skills End

    -- Support Ailment Skills
    ["Acid Breath"] = {
        name = "Acid Breath",
        description = "Rakunda and Sukunda +1 to all enemies.",
        damage = 0,
        cost = 40,
        defaultTech = 0,
        costType = "MP",
        affinity = "Support",
        weaponType = "Magic Skill",
        slotSize = 1,
        slotType = "Equipment"
    },

    -- Support Ailment Skills End

    -- Offensive Items
    ["Agi Stone"] = {
        name = "Agi Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Fire",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Bufu Stone"] = {
        name = "Bufu Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Ice",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Eiha Stone"] = {
        name = "Eiha Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Dark",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Frei Stone"] = {
        name = "Frei Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Nuke",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Kouha Stone"] = {
        name = "Kouha Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Light",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Zan Stone"] = {
        name = "Zan Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Force",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Zio Stone"] = {
        name = "Zio Stone",
        description = "A stone containing compressed magic power of an affinity. Ammo Stack = 3. Deals 30 single-target damage based on the type of affinity in the name of the stone. Has no special effects.",
        damage = 30,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Elec",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    ["Grenade"] = {
        name = "Grenade",
        description = "An explosive projectile with a timed detonator mechanism. Ammo Stack = 5. Effect: Deals 40 physical damage on all targets.",
        damage = 40,
        cost = 0,
        defaultTech = 0,
        costType = "item",
        affinity = "Physical",
        weaponType = "Combat",
        slotSize = 1,
        slotType = "Item"
    },
    -- Offensive Items End

    -- Combat Tactics Support Skills

    ["Accent"] = {
        name = "Accent",
        description = "Debuff self with +1 Tarunda and apply +2 Tarukaja on another ally.",
        damage = 0,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment"
    },
    ["Original Recipe"] = {
        name = "Original Recipe",
        description = "Swap -nda debuffs on self with -kaja buffs.",
        damage = 0,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment"
    },
    ["Quick Focus"] = {
        name = "Quick Focus",
        description = "Gain 1 Lock On stack and recover 15 MP.",
        damage = 0,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment"
    },
    ["Windup"] = {
        name = "Windup",
        description = "Apply Shock with 100% chance on a target or self.",
        damage = 0,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment"
    },
    ["Twilight Shadow"] = {
        name = "Twilight Shadow",
        description = "Heal self for +25 HP and +1 Tarukaja to a targeted ally (Primary Fire), or heal ally for +25 HP and receive +1 Tarukaja for self (Secondary Fire).",
        damage = 25,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment",
        IsHeal = true
    },
    ["Unwavering Support"] = {
        name = "Unwavering Support",
        description = "Heal 12 HP and Tarukaja +1 to any ally or self.",
        damage = 12,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment",
        IsHeal = true
    },
    ["Purple Leaves"] = {
        name = "Purple Leaves",
        description = "Whenever Tomoko deals damage with Ruin attacks or is hit by Ruin attacks, she gains +1 Purple Leaves (Ruin Rush is applicable to this effect). At 4 Leaves, this spell can be cast to heal an ally for 15% of their max HP and grant +2 Tarukaja.",
        damage = 0,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Support",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment",
        IsHeal = true
    },

    -- Combat Tactics Support Skills End

    ["Morning Star"] = {
        name = "Morning Star",
        description = "A primitive weapon with a star-shaped tip. Effect: This weapon cannot deal damage lower than 40.\n[STR 3] This weapon cannot deal damage lower than 45.",
        damage = 50,
        cost = 0,
        defaultTech = 15,
        costType = "none",
        affinity = "Blunt",
        weaponType = "Melee",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["White Six String"] = {
        name = "White Six String",
        description = "A guitar imbued with magic properties. It also has some modifications to make it sturdier against battle damage. Secondary fire deals 35 + DEX single target Force damage with 10 Technique. \n[DEX 5] Secondary fire attack now has a Confusion chance of 5%.",
        damage = 30,
        cost = 0,
        defaultTech = 10,
        costType = "none",
        affinity = "Blunt",
        weaponType = "Melee",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Black Six-String"] = {
        name = "Black Six-String",
        description = "A guitar imbued with magic properties. It also has some modifications to make it sturdier against battle damage. Secondary fire deals 35 + DEX single target Elec damage with 10 Technique. \n[DEX 5] Secondary fire attack now has a Shock chance of 5%.",
        damage = 30,
        cost = 0,
        defaultTech = 10,
        costType = "none",
        affinity = "Blunt",
        weaponType = "Melee",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Electric Guitar Assault"] = {
        name = "Electric Guitar (Assault)",
        description = "Flicking with tooth! Burning in the fire! And beat people with it! That's how guitar is used! Yeeeeeeeeeeeeeeeeah!! Secondary fire deals 30 + DEX single target Elec damage with 15 Technique. The single-target attack has a Shock chance of 5%. If the attack lands, immediately follow up with an unavoidable 10 Elec damage to entire enemy party. \n[DEX 4] Restore 3 MP after this weapon is used.",
        damage = 30,
        cost = 0,
        defaultTech = 15,
        costType = "none",
        affinity = "Blunt",
        weaponType = "Melee",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Buster Bat"] = {
        name = "Buster Bat",
        description = "A pretty tough bat. It's no bludgeon, but it's certainly lighter than one. Automatically enter Guard state after use.",
        damage = 30,
        cost = 0,
        defaultTech = 30,
        costType = "none",
        affinity = "Blunt",
        weaponType = "Melee",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Spiked Bat"] = {
        name = "Spiked Bat",
        description = "Sometimes the simplest things hit the hardest. Bonus Crit Chance 10%. Critical strikes grants +1 Tarukaja.",
        damage = 45,
        cost = 0,
        defaultTech = 10,
        costType = "none",
        affinity = "Blunt",
        weaponType = "Melee",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Grenade Launcher"] = {
        name = "Grenade Launcher",
        description = "I hope you blow up like Concord. Always deals AOE Fire damage. \n[STR 4] Damage is 40 instead. \n[DEX 4] Technique is 0 instead. \n[CHR 4] +2 Luck.",
        damage = 35,
        cost = 0,
        defaultTech = -5,
        costType = "none",
        affinity = "Fire",
        weaponType = "Gun",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Shangri La"] = {
        name = "Shangri-La",
        description = "This handgun acquired its nickname after it was said that one shot could send you to paradise. With its attractive design and ease of use, this prototype is popular with both high-ranking officials and technical engineers. On hit, 10% Charm chance. \n[DEX 4] Technique is 20 instead. \n[CHR 4] User's Ruin attacks deal 5 bonus damage.",
        damage = 45,
        cost = 0,
        defaultTech = 15,
        costType = "none",
        affinity = "Gun",
        weaponType = "Gun",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["The Punisher"] = {
        name = "The Punisher",
        description = "The bullets that fly from the scorching mouth of this gun will crush your enemies without restraint. Reduces user's Max HP by 10. \n[STR 4] 8% chance of inflicting Panic on target. \n[DEX 4] -5 Technique instead.",
        damage = 70,
        cost = 0,
        defaultTech = -10,
        costType = "none",
        affinity = "Gun",
        weaponType = "Gun",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Brave Awaker"] = {
        name = "Brave Awaker",
        description = "Your courage rises mysteriously when you hold the tonfa with the will of protecting others. After attacking with this weapon, select 1 ally or self and remove 1 Rakunda. Automatically enter Guard state after use. \n[STR 6] The user receives +1 Rakukaja after using the weapon.",
        damage = 35,
        cost = 0,
        defaultTech = 20,
        costType = "none",
        affinity = "Martial Arts",
        weaponType = "Martial Arts",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Traditional Parasol"] = {
        name = "Traditional Parasol",
        description = "A parasol adorned with a simple, yet striking pattern. 40% chance to refresh currently active elemental ailments on an enemy upon hit. \n[CHR 4] 50% chance to refresh currently active elemental ailments on an enemy upon hit.",
        damage = 35,
        cost = 0,
        defaultTech = 20,
        costType = "none",
        affinity = "Martial Arts",
        weaponType = "Martial Arts",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Flower Parasol"] = {
        name = "Flower Parasol",
        description = "A parasol adorned with a stream of flowers. Attacking with this weapon removes any and all types of ailments off of target. Based on the number of ailments that was on the target, the ailments detonate and deal bonus damage of (Amount of Ailments x (12 + CHR) ). \n[CHR 4] Dealing 20/40/60+ damage off of the detonation restores 8/12/16 MP.",
        damage = 15,
        cost = 0,
        defaultTech = 20,
        costType = "none",
        affinity = "Martial Arts",
        weaponType = "Martial Arts",
        slotSize = 1,
        slotType = "Equipment"
    },
    ["Majestic Presence"] = {
        name = "Majestic Presence",
        description = "Deal 10 Phys damage to a single target. On Morgana's next turn, Self-Heal for 10% of Morgana's max HP.",
        damage = 10,
        cost = 0,
        defaultTech = 0,
        costType = "none",
        affinity = "Physical",
        weaponType = "Combat Tactic",
        slotSize = 0,
        slotType = "Equipment"
    }
}

local SkillHandlers = {

    -- Offensive Magic Skills 
    Absolute_Zero = function(ply, target, skillWeapon)
        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        local status = HandleStatus(ply, targetEffects["userDebuffsTable"],
                                    "canUseSkills", true, targetEffects)

        if not status then
            ply:LagCompensation(false)
            return
        end

        local iceFound = 0
        for _, weapon in pairs(ply:GetWeapons()) do
            if weapon.Affinity then
                if weapon.Affinity == "Ice" then
                    iceFound = iceFound + 1
                end
            end
        end

        if iceFound >= 2 then
            local mpCost = SkillProperties[skillWeapon.PrintName]["cost"] -- MP cost of the attack
            local attackerMP = ply:GetNWInt("TBCMP", 100)

            mpCost = mpCost +
                         (HandleStatus(ply, userDebuffsTable, "increaseMPCost",
                                       mpCost) -
                             HandleStatus(ply, userBuffsTable, "decreaseMPCost",
                                          mpCost))

            if attackerMP >= mpCost then
                ply:SetNWInt("TBCMP", attackerMP - mpCost)
            else
                ply:ChatPrint("Not enough MP to use this ability.")
                ply:LagCompensation(false)
                return
            end

            skillWeapon:AnnounceAbility()

            local tech = 0

            local targetedTargets = RollAoETargets(ply, target, skillWeapon,
                                                   tech)

            if next(targetedTargets) == nil then
                ply:ChatPrint(ply:Name() .. "... You hit no one?")
            else
                for _, ent in pairs(targetedTargets) do
                    local target = ent

                    local newHP

                    for i = 1, 2 do
                        skillWeapon.Affinity = "Ice"

                        targetEffects["baseDamage"] =
                            SkillProperties[skillWeapon.PrintName]["damage"]
                        targetEffects["Affinity"] = skillWeapon.Affinity

                        local playerLuck = ply:GetNWInt("TBCLuck", 10)

                        playerLuck = playerLuck +
                                         (HandleStatus(ply, userBuffsTable,
                                                       "increaseLuck",
                                                       playerLuck) -
                                             HandleStatus(ply, userDebuffsTable,
                                                          "decreaseLuck",
                                                          playerLuck))

                        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))

                        local killChance = math.ceil(playerLuck + playerDex)

                        local critBonus =
                            (HandleStatus(ply, userBuffsTable,
                                          "increaseCritChance",
                                          targetEffects["baseDamage"]) -
                                HandleStatus(ply, userDebuffsTable,
                                             "decreaseCritChance",
                                             targetEffects["baseDamage"]))

                        targetEffects["critChance"] = math.ceil(
                                                          (playerLuck / 2) +
                                                              critBonus)

                        targetEffects["state"] = 'normal'
                        targetEffects["message"] =
                            target:Name() .. " received " ..
                                targetEffects["baseDamage"] .. " damage."

                        local targetBuffsTable = GetAllStats(target, "buffs")
                        local targetDebuffsTable =
                            GetAllStats(target, "debuffs")

                        targetEffects["ply"] = ply
                        targetEffects["target"] = target

                        targetEffects["userBuffsTable"] = userBuffsTable
                        targetEffects["userDebuffsTable"] = userDebuffsTable
                        targetEffects["targetBuffsTable"] = targetBuffsTable
                        targetEffects["targetDebuffsTable"] = targetDebuffsTable

                        targetEffects["state"] = 'normal'

                        targetEffects = HandleRepel(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        if targetEffects["state"] == 'repel' then
                            skillWeapon:AnnounceMessage(target:Name() ..
                                                            " repeled the attack!")
                        end
                        targetEffects = HandleCrit(targetEffects["ply"],
                                                   targetEffects["target"],
                                                   targetEffects)
                        targetEffects = HandleResistances(targetEffects["ply"],
                                                          targetEffects["target"],
                                                          targetEffects)
                        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                                         targetEffects["target"],
                                                         targetEffects)
                        targetEffects = HandleBlock(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        targetEffects = HandleDrain(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)

                        targetEffects["baseDamage"] =
                            targetEffects["baseDamage"] +
                                (HandleStatus(targetEffects["ply"],
                                              targetEffects["userBuffsTable"],
                                              "damage",
                                              targetEffects["baseDamage"],
                                              targetEffects) -
                                    HandleStatus(targetEffects["ply"],
                                                 targetEffects["userDebuffsTable"],
                                                 "decreaseDamage",
                                                 targetEffects["baseDamage"],
                                                 targetEffects)) -
                                (HandleStatus(targetEffects["target"],
                                              targetEffects["targetBuffsTable"],
                                              "defenseDamage",
                                              targetEffects["baseDamage"],
                                              targetEffects) -
                                    HandleStatus(targetEffects["target"],
                                                 targetEffects["targetDebuffsTable"],
                                                 "defenseDecrease",
                                                 targetEffects["baseDamage"],
                                                 targetEffects))

                        targetEffects["baseDamage"] = math.ceil(
                                                          targetEffects["baseDamage"])

                        if i == 1 then
                            if math.random(1, 100) <= killChance then

                                if targetEffects["targetDebuffsTable"]["Freeze"] then
                                    HandleInstakill(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                                end
                            end
                        end

                        targetEffects = HandleDamageMessage(
                                            targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

                        local currentHP =
                            targetEffects["target"]:GetNWInt("TBCHP", 100)
                        local maxHP = targetEffects["target"]:GetNWInt(
                                          "TBCMAXHP", 100)

                        if targetEffects["state"] == "drain" then
                            newHP = math.min(currentHP +
                                                 targetEffects["baseDamage"],
                                             maxHP)
                        else
                            newHP = currentHP - targetEffects["baseDamage"]
                            HandleStatus(targetEffects["target"], targetEffects,
                                         "damageReaction", false, targetEffects)
                        end

                        targetEffects["target"]:SetNWInt("TBCHP", newHP)
                        skillWeapon:AnnounceMessage(targetEffects["message"])

                    end

                    if newHP <= 0 then
                        targetEffects["target"]:SetNWInt("TBCHP", 0)
                        targetEffects["lifeState"] = "dead"
                        targetEffects = HandleDeath(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        targetEffects = HandleKill(targetEffects["ply"],
                                                   targetEffects["target"],
                                                   targetEffects)

                        skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
                    end

                end
            end
        else
            ply:ChatPrint(
                "You can't use this skill without more 2 or more Ice skills!")
        end
    end,

    Agi = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        local status = HandleStatus(ply, targetEffects["userDebuffsTable"],
                                    "canUseSkills", true, targetEffects)

        if not status then return end

        local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
        local mpCost = SkillProperties[weapon.PrintName]["cost"] -- MP cost of the attack
        local attackerMP = ply:GetNWInt("TBCMP", 100)
        if playerStr >= 4 then mpCost = 4 end

        mpCost = mpCost +
                     (HandleStatus(ply, userDebuffsTable, "increaseMPCost",
                                   mpCost) -
                         HandleStatus(ply, userBuffsTable, "decreaseMPCost",
                                      mpCost))

        if attackerMP >= mpCost then
            ply:SetNWInt("TBCMP", attackerMP - mpCost)
        else
            ply:ChatPrint("Not enough MP to use this ability.")
            return
        end

        if not weapon:AbilityRollNumber(15, target) then return end

        targetEffects["baseDamage"] =
            SkillProperties[weapon.PrintName]["damage"]
        targetEffects["Affinity"] =
            SkillProperties[weapon.PrintName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)

        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        targetEffects["ailmentChance"] = 10
        if playerChr >= 4 then targetEffects["ailmentChance"] = 20 end
        targetEffects["ailmentChance"] =
            math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end

        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects["ailment"] = "Burn"

        targetEffects["ailmentChance"] =
            targetEffects["ailmentChance"] +
                (HandleStatus(targetEffects["ply"], userBuffsTable,
                              "increaseAilmentChance",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["ply"], userDebuffsTable,
                                 "decreaseAilmentChance",
                                 targetEffects["ailmentChance"], targetEffects)) -
                (HandleStatus(targetEffects["target"], targetBuffsTable,
                              "decreaseAilmentReceive",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["target"], targetDebuffsTable,
                                 "increaseAilmentReceive",
                                 targetEffects["ailmentChance"], targetEffects))

        if math.random(1, 100) <= targetEffects["ailmentChance"] then
            local targetDebuffsTable = GetAllStats(targetEffects["target"],
                                                   "debuffs")

            targetDebuffsTable["Burn"] = {
                stacks = 1,
                type = "turnDamage",
                affinity = "Fire",
                duration = 3
            }

            AssignStat(targetEffects["target"], "Burn",
                       targetDebuffsTable["Burn"], "debuffs")

            weapon:AnnounceMessage(targetEffects["target"]:Name() ..
                                       " is now Burning!")
            HandleStatus(targetEffects["ply"], userBuffsTable,
                         "ailmentReaction", "Burn", targetEffects)
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    -- Offensive Magic Skills End

    -- Support Ailment Skills
    Acid_Breath = function(ply, target, skillWeapon)
        local fight = TBCWeaponMetatable.OngoingFights[skillWeapon.FightId]
        if fight then
        else
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        local status = HandleStatus(ply, targetEffects["userDebuffsTable"],
                                    "canUseSkills", true, targetEffects)

        if not status then return end

        local mpCost = SkillProperties[skillWeapon.PrintName]["cost"]
        local attackerMP = ply:GetNWInt("TBCMP", 100)

        mpCost = mpCost +
                     (HandleStatus(ply, userDebuffsTable, "increaseMPCost",
                                   mpCost) -
                         HandleStatus(ply, userBuffsTable, "decreaseMPCost",
                                      mpCost))

        if attackerMP >= mpCost then
            ply:SetNWInt("TBCMP", attackerMP - mpCost)
        else
            ply:ChatPrint("Not enough MP to use this ability.")
            return
        end

        local playerSide = (table.HasValue(fight.Side1, target) and "Side1") or
                               (table.HasValue(fight.Side2, target) and "Side2")

        local playersInFight = {}
        for _, player in ipairs(fight[playerSide]) do
            if IsValid(player) then
                table.insert(playersInFight, player)
            end
        end

        for _, player in ipairs(playersInFight) do
            if IsValid(player) then -- Check if the player is valid
                targetEffects["targetDebuffsTable"] = GetAllStats(player,
                                                                  "debuffs")

                if targetEffects["targetDebuffsTable"]["Rakunda"] then
                    targetEffects["targetDebuffsTable"]["Rakunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Rakunda"]
                                     .stacks + 1, 4)
                else
                    targetEffects["targetDebuffsTable"]["Rakunda"] = {
                        stacks = 1
                    }
                end

                AssignStat(player, "Rakunda",
                           targetEffects["targetDebuffsTable"]["Rakunda"],
                           "debuffs")

                targetEffects["debuff"] = "Rakunda"

                HandleStatus(player, GetAllStats(player, "buffs"),
                             "reactionDebuff", "debuff", targetEffects)

                if targetEffects["targetDebuffsTable"]["Sukunda"] then
                    targetEffects["targetDebuffsTable"]["Sukunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Sukunda"]
                                     .stacks + 1, 4)
                else
                    targetEffects["targetDebuffsTable"]["Sukunda"] = {
                        stacks = 1
                    }
                end

                AssignStat(player, "Sukunda",
                           targetEffects["targetDebuffsTable"]["Sukunda"],
                           "debuffs")

                targetEffects["debuff"] = "Sukunda"

                HandleStatus(player, GetAllStats(player, "buffs"),
                             "reactionDebuff", "debuff", targetEffects)

                local message = player:Name() ..
                                    " received Rakunda and Sukunda from " ..
                                    ply:Name() .. "! They now have " ..
                                    targetEffects["targetDebuffsTable"]["Rakunda"]
                                        .stacks .. " Rakunda and " ..
                                    targetEffects["targetDebuffsTable"]["Sukunda"]
                                        .stacks .. " Sukunda!"

                skillWeapon:AnnounceMessage(message)
            end
        end
    end,

    -- Support Ailment Skills End

    -- Offensive Items

    Agi_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Bufu_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Eiha_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Frei_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Kouha_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Zan_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Zio_Stone = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        if skillWeapon:AbilityRollNumber(tech, target) then

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            targetEffects["baseDamage"] =
                SkillProperties[skillWeapon.PrintName]["damage"]
            targetEffects["Affinity"] =
                SkillProperties[skillWeapon.PrintName]["affinity"]

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                skillWeapon:AnnounceMessage(target:Name() ..
                                                " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            skillWeapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
            end
        end

    end,

    Grenade = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName

        local tech = SkillProperties[weaponName]["defaultTech"]

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetedTargets = RollAoETargets(ply, target, skillWeapon, tech)

        if next(targetedTargets) == nil then
            ply:ChatPrint(ply:Name() .. " hits literally nobody!")
        else
            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            for _, ent in pairs(targetedTargets) do
                local target = ent

                if SERVER and IsValid(target) then

                    local userBuffsTable = GetAllStats(ply, "buffs")
                    local userDebuffsTable = GetAllStats(ply, "debuffs")
                    local targetBuffsTable = GetAllStats(target, "buffs")
                    local targetDebuffsTable = GetAllStats(target, "debuffs")

                    local targetEffects = {}
                    targetEffects["baseDamage"] =
                        SkillProperties[skillWeapon.PrintName]["damage"]
                    targetEffects["Affinity"] =
                        SkillProperties[skillWeapon.PrintName]["affinity"]

                    local playerLuck = ply:GetNWInt("TBCLuck", 10)
                    playerLuck = playerLuck +
                                     (HandleStatus(ply, userBuffsTable,
                                                   "increaseLuck", playerLuck) -
                                         HandleStatus(ply, userDebuffsTable,
                                                      "decreaseLuck", playerLuck))

                    local critBonus = (HandleStatus(ply, userBuffsTable,
                                                    "increaseCritChance",
                                                    targetEffects["baseDamage"]) -
                                          HandleStatus(ply, userDebuffsTable,
                                                       "decreaseCritChance",
                                                       targetEffects["baseDamage"]))

                    targetEffects["critChance"] =
                        math.ceil((playerLuck / 2) + critBonus)

                    targetEffects["ply"] = ply
                    targetEffects["target"] = target

                    targetEffects["userBuffsTable"] = userBuffsTable
                    targetEffects["userDebuffsTable"] = userDebuffsTable
                    targetEffects["targetBuffsTable"] = targetBuffsTable
                    targetEffects["targetDebuffsTable"] = targetDebuffsTable

                    targetEffects["state"] = 'normal'

                    targetEffects = HandleRepel(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)
                    if targetEffects["state"] == 'repel' then
                        skillWeapon:AnnounceMessage(target:Name() ..
                                                        " repeled the attack!")
                    end
                    targetEffects = HandleResistances(targetEffects["ply"],
                                                      targetEffects["target"],
                                                      targetEffects)
                    targetEffects = HandleWeaknesses(targetEffects["ply"],
                                                     targetEffects["target"],
                                                     targetEffects)
                    targetEffects = HandleCrit(targetEffects["ply"],
                                               targetEffects["target"],
                                               targetEffects)
                    targetEffects = HandleBlock(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)
                    targetEffects = HandleDrain(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

                    targetEffects["attacker"] = targetEffects["ply"]
                    targetEffects["target"] = targetEffects["target"]
                    targetEffects["weaponTargets"] = targetedTargets

                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] +
                            (HandleStatus(targetEffects["ply"],
                                          targetEffects["userBuffsTable"],
                                          "damage", targetEffects["baseDamage"],
                                          targetEffects) -
                                HandleStatus(targetEffects["ply"],
                                             targetEffects["userDebuffsTable"],
                                             "decreaseDamage",
                                             targetEffects["baseDamage"],
                                             targetEffects)) -
                            (HandleStatus(targetEffects["target"],
                                          targetEffects["targetBuffsTable"],
                                          "defenseDamage",
                                          targetEffects["baseDamage"],
                                          targetEffects) -
                                HandleStatus(targetEffects["target"],
                                             targetEffects["targetDebuffsTable"],
                                             "defenseDecrease",
                                             targetEffects["baseDamage"],
                                             targetEffects))

                    targetEffects["baseDamage"] = math.ceil(
                                                      targetEffects["baseDamage"])

                    targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                        targetEffects["target"],
                                                        targetEffects)

                    local currentHP = targetEffects["target"]:GetNWInt("TBCHP",
                                                                       100)
                    local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP",
                                                                   100)
                    local newHP

                    if targetEffects["state"] == "drain" then
                        newHP = math.min(
                                    currentHP + targetEffects["baseDamage"],
                                    maxHP)
                    else
                        newHP = currentHP - targetEffects["baseDamage"]
                        HandleStatus(targetEffects["target"], targetEffects,
                                     "damageReaction", false, targetEffects)
                    end

                    targetEffects["target"]:SetNWInt("TBCHP", newHP)

                    skillWeapon:AnnounceMessage(targetEffects["message"])

                    if newHP <= 0 then
                        targetEffects["target"]:SetNWInt("TBCHP", 0)

                        targetEffects["lifeState"] = "dead"
                        targetEffects = HandleDeath(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        targetEffects = HandleKill(targetEffects["ply"],
                                                   targetEffects["target"],
                                                   targetEffects)

                        skillWeapon:CheckForTeamDefeat(skillWeapon.FightId)
                    end
                end
            end
        end
    end,

    -- Offensive Items End

    -- Combat Tactics Support Skills
    Accent = function(ply, target, skillWeapon)
        skillWeapon:AnnounceAbility()
        local weaponName = skillWeapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]",
                                                                       ""):gsub(
                               "-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        if targetBuffsTable["Tarukaja"] then
            targetBuffsTable["Tarukaja"].stacks = math.min(
                                                      targetBuffsTable["Tarukaja"]
                                                          .stacks + 2, 4)
        else
            targetBuffsTable["Tarukaja"] = {stacks = 2}
        end

        AssignStat(target, "Tarukaja", targetBuffsTable["Tarukaja"], "buffs")

        local message = target:Name() .. " received 2 Tarukaja from " ..
                            ply:Name() .. "! They now have " ..
                            targetBuffsTable["Tarukaja"].stacks .. " stacks!"

        skillWeapon:AnnounceMessage(message)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                     "buff", targetEffects)

        targetEffects["buff"] = "Tarukaja"

        HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                     targetEffects)

        if targetEffects["userDebuffsTable"]["Tarunda"] then
            targetEffects["userDebuffsTable"]["Tarunda"].stacks = math.min(
                                                                      targetEffects["userDebuffsTable"]["Tarunda"]
                                                                          .stacks +
                                                                          1, 4)
        else
            targetEffects["userDebuffsTable"]["Tarunda"] = {stacks = 1}
        end

        AssignStat(ply, "Tarunda", targetEffects["userDebuffsTable"]["Tarunda"],
                   "debuffs")

        targetEffects["debuff"] = "Tarunda"

        HandleStatus(ply, GetAllStats(ply, "buffs"), "reactionDebuff", "debuff",
                     targetEffects)

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    Original_Recipe = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local kajaCount = 0
        local ndaCount = 0

        if userBuffsTable["Tarukaja"] then
            kajaCount = userBuffsTable["Tarukaja"].stacks
        end

        if userDebuffsTable["Tarunda"] then
            ndaCount = userDebuffsTable["Tarunda"].stacks
        end

        if kajaCount > 0 then
            userDebuffsTable["Tarunda"] = {stacks = kajaCount}
        else
            RemoveStat(ply, "Tarunda", "debuffs")
        end

        if ndaCount > 0 then
            userBuffsTable["Tarukaja"] = {stacks = ndaCount}

            AssignStat(ply, "Tarukaja", userBuffsTable["Tarukaja"], "buffs")

            targetEffects["buff"] = "Tarukaja"

            HandleStatus(ply, userBuffsTable, "reactionBuff", "buff",
                         targetEffects)
        else
            RemoveStat(ply, "Tarukaja", "buffs")
        end

        kajaCount = 0
        ndaCount = 0

        if userBuffsTable["Rakukaja"] then
            kajaCount = userBuffsTable["Rakukaja"].stacks
        end

        if userDebuffsTable["Rakunda"] then
            ndaCount = userDebuffsTable["Rakunda"].stacks
        end

        if kajaCount > 0 then
            userDebuffsTable["Rakunda"] = {stacks = kajaCount}
        else
            RemoveStat(ply, "Rakunda", "debuffs")
        end

        if ndaCount > 0 then
            userBuffsTable["Rakukaja"] = {stacks = ndaCount}

            AssignStat(ply, "Rakukaja", userBuffsTable["Rakukaja"], "buffs")

            targetEffects["buff"] = "Rakukaja"

            HandleStatus(ply, userBuffsTable, "reactionBuff", "buff",
                         targetEffects)
        else
            RemoveStat(ply, "Rakukaja", "buffs")
        end

        kajaCount = 0
        ndaCount = 0

        if userBuffsTable["Sukukaja"] then
            kajaCount = userBuffsTable["Sukukaja"].stacks
        end

        if userDebuffsTable["Sukunda"] then
            ndaCount = userDebuffsTable["Sukunda"].stacks
        end

        if kajaCount > 0 then
            userDebuffsTable["Sukunda"] = {stacks = kajaCount}
        else
            RemoveStat(ply, "Sukunda", "debuffs")
        end

        if ndaCount > 0 then
            userBuffsTable["Sukukaja"] = {stacks = ndaCount}

            AssignStat(ply, "Sukukaja", userBuffsTable["Sukukaja"], "buffs")

            targetEffects["buff"] = "Sukukaja"

            HandleStatus(ply, userBuffsTable, "reactionBuff", "buff",
                         targetEffects)
        else
            RemoveStat(ply, "Sukukaja", "buffs")
        end

        local message = ply:Name() ..
                            " swapped their -Nda debuffs with -Kaja buffs!"

        weapon:AnnounceMessage(message)

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    -- Combat Tactics Support Skills End

    Sweeper = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]
        if not weaponName:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)

        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Morning_Star = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local tech =
            SkillProperties[weapon.PrintName:gsub("%s+", "_")]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weapon.PrintName:gsub(
                                          "%s+", "_")]["damage"]
        targetEffects["Affinity"] = SkillProperties[weapon.PrintName:gsub("%s+",
                                                                          "_")]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        if not targetEffects["state"] == 'block' and targetEffects["baseDamage"] <=
            45 then
            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))

            if playerStr >= 3 then
                targetEffects["baseDamage"] = 45
            else
                targetEffects["baseDamage"] = 40
            end
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    White_Six_String = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local tech =
            SkillProperties[weapon.PrintName:gsub("%s+", "_")]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["baseDamage"] = SkillProperties[weapon.PrintName:gsub(
                                          "%s+", "_")]["damage"]
        targetEffects["Affinity"] = SkillProperties[weapon.PrintName:gsub("%s+",
                                                                          "_")]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    White_Six_String_S = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local tech =
            SkillProperties[weapon.PrintName:gsub("%s+", "_")]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        targetEffects["baseDamage"] = 35 + playerDex
        targetEffects["Affinity"] = "Force"

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        if playerDex >= 5 then
            targetEffects["ailmentChance"] = 5

            targetEffects["ailmentChance"] =
                math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]
        end

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        if playerDex >= 5 then
            targetEffects["ailment"] = "Confusion"

            targetEffects["ailmentChance"] =
                targetEffects["ailmentChance"] +
                    (HandleStatus(targetEffects["ply"], userBuffsTable,
                                  "increaseAilmentChance",
                                  targetEffects["ailmentChance"], targetEffects) -
                        HandleStatus(targetEffects["ply"], userDebuffsTable,
                                     "decreaseAilmentChance",
                                     targetEffects["ailmentChance"],
                                     targetEffects)) -
                    (HandleStatus(targetEffects["target"], targetBuffsTable,
                                  "decreaseAilmentReceive",
                                  targetEffects["ailmentChance"], targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetDebuffsTable,
                                     "increaseAilmentReceive",
                                     targetEffects["ailmentChance"],
                                     targetEffects))

            if math.random(1, 100) <= targetEffects["ailmentChance"] then

                local targetDebuffsTable =
                    GetAllStats(targetEffects["target"], "debuffs")

                targetDebuffsTable["Confusion"] = {stacks = 1, duration = 3}

                AssignStat(targetEffects["target"], "Confusion",
                           targetDebuffsTable["Confusion"], "debuffs")

                weapon:AnnounceMessage(targetEffects["target"]:Name() ..
                                           " is now Confused!")
                HandleStatus(targetEffects["ply"], userBuffsTable,
                             "ailmentReaction", "Confusion", targetEffects)
            end
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Black_Six_String = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Black_Six_String_S = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        targetEffects["baseDamage"] = 35 + playerDex
        targetEffects["Affinity"] = "Elec"

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        if playerDex >= 5 then
            targetEffects["ailmentChance"] = 5

            targetEffects["ailmentChance"] =
                math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]
        end

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        if playerDex >= 5 then
            targetEffects["ailment"] = "Shock"

            targetEffects["ailmentChance"] =
                targetEffects["ailmentChance"] +
                    (HandleStatus(targetEffects["ply"], userBuffsTable,
                                  "increaseAilmentChance",
                                  targetEffects["ailmentChance"], targetEffects) -
                        HandleStatus(targetEffects["ply"], userDebuffsTable,
                                     "decreaseAilmentChance",
                                     targetEffects["ailmentChance"],
                                     targetEffects)) -
                    (HandleStatus(targetEffects["target"], targetBuffsTable,
                                  "decreaseAilmentReceive",
                                  targetEffects["ailmentChance"], targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetDebuffsTable,
                                     "increaseAilmentReceive",
                                     targetEffects["ailmentChance"],
                                     targetEffects))

            if math.random(1, 100) <= targetEffects["ailmentChance"] then

                local targetDebuffsTable =
                    GetAllStats(targetEffects["target"], "debuffs")

                targetDebuffsTable["Shock"] = {
                    stacks = 1,
                    type = "turnSkipper",
                    duration = 3
                }

                AssignStat(targetEffects["target"], "Shock",
                           targetDebuffsTable["Shock"], "debuffs")

                weapon:AnnounceMessage(targetEffects["target"]:Name() ..
                                           " is now shocked!")
                HandleStatus(targetEffects["ply"], userBuffsTable,
                             "ailmentReaction", "Shock", targetEffects)
            end
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Electric_Guitar_Assault = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local tech = SkillProperties[weapon.PrintName:gsub("%s+", "_"):gsub(
                         "[%(%)]", "")]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then return end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["baseDamage"] = SkillProperties[weapon.PrintName:gsub(
                                          "%s+", "_"):gsub("[%(%)]", "")]["damage"]
        targetEffects["Affinity"] = SkillProperties[weapon.PrintName:gsub("%s+",
                                                                          "_")
                                        :gsub("[%(%)]", "")]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local playerDex = tonumber(targetEffects["ply"]:GetNWInt("TBCDEX", 0))
        if playerDex >= 4 then
            local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0)
            local maxMP = targetEffects["ply"]:GetNWInt("TBCMAXMP", 100)
            targetEffects["ply"]:SetNWInt("TBCMP",
                                          math.min(attackerMP + 3, maxMP))
        end

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Electric_Guitar_Assault_S = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local tech = SkillProperties[weapon.PrintName:gsub("%s+", "_"):gsub(
                         "[%(%)]", "")]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        targetEffects["baseDamage"] = 30 + playerDex
        targetEffects["Affinity"] = "Elec"

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        if playerDex >= 5 then
            targetEffects["ailmentChance"] = 5

            targetEffects["ailmentChance"] =
                math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]
        end

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
            target = ply
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        if playerDex >= 5 then
            targetEffects["ailment"] = "Shock"

            targetEffects["ailmentChance"] =
                targetEffects["ailmentChance"] +
                    (HandleStatus(targetEffects["ply"], userBuffsTable,
                                  "increaseAilmentChance",
                                  targetEffects["ailmentChance"], targetEffects) -
                        HandleStatus(targetEffects["ply"], userDebuffsTable,
                                     "decreaseAilmentChance",
                                     targetEffects["ailmentChance"],
                                     targetEffects)) -
                    (HandleStatus(targetEffects["target"], targetBuffsTable,
                                  "decreaseAilmentReceive",
                                  targetEffects["ailmentChance"], targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetDebuffsTable,
                                     "increaseAilmentReceive",
                                     targetEffects["ailmentChance"],
                                     targetEffects))

            if math.random(1, 100) <= targetEffects["ailmentChance"] then

                local targetDebuffsTable =
                    GetAllStats(targetEffects["target"], "debuffs")

                targetDebuffsTable["Shock"] = {
                    stacks = 1,
                    type = "turnSkipper",
                    duration = 3
                }

                AssignStat(targetEffects["target"], "Shock",
                           targetDebuffsTable["Shock"], "debuffs")

                weapon:AnnounceMessage(targetEffects["target"]:Name() ..
                                           " is now shocked!")
                HandleStatus(targetEffects["ply"], userBuffsTable,
                             "ailmentReaction", "Shock", targetEffects)
            end
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if fight then
        else
            return
        end

        local playerSide =
            (table.HasValue(fight.Side1, targetEffects["target"]) and "Side1") or
                (table.HasValue(fight.Side2, targetEffects["target"]) and
                    "Side2")

        for _, player in ipairs(fight[playerSide]) do

            local targetBuffsTable = GetAllStats(player, "buffs")
            local targetDebuffsTable = GetAllStats(player, "debuffs")

            local targetEffects = {}
            targetEffects["baseDamage"] = 10
            targetEffects["Affinity"] = "Elec"

            local playerLuck = ply:GetNWInt("TBCLuck", 10)
            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = player

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                weapon:AnnounceMessage(player:Name() .. " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["attacker"] = targetEffects["ply"]
            targetEffects["target"] = targetEffects["target"]

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local playerDex = tonumber(
                                  targetEffects["ply"]:GetNWInt("TBCDEX", 0))
            if playerDex >= 4 then
                local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0)
                local maxMP = targetEffects["ply"]:GetNWInt("TBCMAXMP", 100)
                targetEffects["ply"]:SetNWInt("TBCMP",
                                              math.min(attackerMP + 3, maxMP))
            end

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
            else
                newHP = currentHP - targetEffects["baseDamage"]
                HandleStatus(targetEffects["target"], targetEffects,
                             "damageReaction", false, targetEffects)
            end

            targetEffects["target"]:SetNWInt("TBCHP", newHP)

            weapon:AnnounceMessage(targetEffects["message"])

            if newHP <= 0 then
                targetEffects["target"]:SetNWInt("TBCHP", 0)

                targetEffects["lifeState"] = "dead"
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                weapon:CheckForTeamDefeat(weapon.FightId)
            end
        end
    end,

    Buster_Bat = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")

        local tech = SkillProperties[weaponName]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects["userBuffsTable"]["Guard"] = {stacks = 1, duration = 2}

        AssignStat(ply, "Guard", targetEffects["userBuffsTable"]["Guard"],
                   "buffs")

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0) -- attacker's current TBCMP
        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Spiked_Bat = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")

        local tech = SkillProperties[weaponName]["defaultTech"]
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = 10
        critBonus = critBonus +
                        (HandleStatus(ply, userBuffsTable, "increaseCritChance",
                                      targetEffects["baseDamage"]) -
                            HandleStatus(ply, userDebuffsTable,
                                         "decreaseCritChance",
                                         targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        if targetEffects["state"] == "crit" then
            local targetBuffsTable = GetAllStats(targetEffects["ply"], "buffs")

            if targetBuffsTable["Tarukaja"] then
                targetBuffsTable["Tarukaja"].stacks = math.min(
                                                          targetBuffsTable["Tarukaja"]
                                                              .stacks + 1, 4)
            else
                targetBuffsTable["Tarukaja"] = {stacks = 1}
            end

            AssignStat(targetEffects["ply"], "Tarukaja",
                       targetBuffsTable["Tarukaja"], "buffs")

        end

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0) -- attacker's current TBCMP
        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Grenade_Launcher = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")

        local tech = SkillProperties[weaponName]["defaultTech"]
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        if playerDex >= 4 then tech = 0 end

        local targetedTargets = RollAoETargets(ply, target, weapon, tech)

        if next(targetedTargets) == nil then
            ply:ChatPrint(ply:Name() .. " hits literally nobody!")
        else
            for _, ent in pairs(targetedTargets) do
                local target = ent

                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")
                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                local targetEffects = {}
                targetEffects["baseDamage"] =
                    SkillProperties[weaponName]["damage"]
                local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
                if playerStr >= 4 then
                    targetEffects["baseDamage"] = 40
                end

                targetEffects["Affinity"] =
                    SkillProperties[weaponName]["affinity"]

                local playerLuck = ply:GetNWInt("TBCLuck", 10)
                playerLuck = playerLuck +
                                 (HandleStatus(ply, userBuffsTable,
                                               "increaseLuck", playerLuck) -
                                     HandleStatus(ply, userDebuffsTable,
                                                  "decreaseLuck", playerLuck))

                local critBonus = (HandleStatus(ply, userBuffsTable,
                                                "increaseCritChance",
                                                targetEffects["baseDamage"]) -
                                      HandleStatus(ply, userDebuffsTable,
                                                   "decreaseCritChance",
                                                   targetEffects["baseDamage"]))

                targetEffects["critChance"] =
                    math.ceil((playerLuck / 2) + critBonus)

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                targetEffects["userBuffsTable"] = userBuffsTable
                targetEffects["userDebuffsTable"] = userDebuffsTable
                targetEffects["targetBuffsTable"] = targetBuffsTable
                targetEffects["targetDebuffsTable"] = targetDebuffsTable

                targetEffects["state"] = 'normal'

                targetEffects = HandleRepel(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                if targetEffects["state"] == 'repel' then
                    weapon:AnnounceMessage(target:Name() ..
                                               " repeled the attack!")
                end
                targetEffects = HandleResistances(targetEffects["ply"],
                                                  targetEffects["target"],
                                                  targetEffects)
                targetEffects = HandleWeaknesses(targetEffects["ply"],
                                                 targetEffects["target"],
                                                 targetEffects)
                targetEffects = HandleCrit(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)
                targetEffects = HandleBlock(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleDrain(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

                targetEffects["attacker"] = targetEffects["ply"]
                targetEffects["target"] = targetEffects["target"]
                targetEffects["weaponTargets"] = targetedTargets

                targetEffects["baseDamage"] =
                    targetEffects["baseDamage"] +
                        (HandleStatus(targetEffects["ply"],
                                      targetEffects["userBuffsTable"], "damage",
                                      targetEffects["baseDamage"], targetEffects) -
                            HandleStatus(targetEffects["ply"],
                                         targetEffects["userDebuffsTable"],
                                         "decreaseDamage",
                                         targetEffects["baseDamage"],
                                         targetEffects)) -
                        (HandleStatus(targetEffects["target"],
                                      targetEffects["targetBuffsTable"],
                                      "defenseDamage",
                                      targetEffects["baseDamage"], targetEffects) -
                            HandleStatus(targetEffects["target"],
                                         targetEffects["targetDebuffsTable"],
                                         "defenseDecrease",
                                         targetEffects["baseDamage"],
                                         targetEffects))

                targetEffects["baseDamage"] = math.ceil(
                                                  targetEffects["baseDamage"])

                targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)

                local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
                local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
                local newHP

                if targetEffects["state"] == "drain" then
                    newHP = math.min(currentHP + targetEffects["baseDamage"],
                                     maxHP)
                else
                    newHP = currentHP - targetEffects["baseDamage"]
                    HandleStatus(targetEffects["target"], targetEffects,
                                 "damageReaction", false, targetEffects)
                end

                targetEffects["target"]:SetNWInt("TBCHP", newHP)

                weapon:AnnounceMessage(targetEffects["message"])

                if newHP <= 0 then
                    targetEffects["target"]:SetNWInt("TBCHP", 0)

                    targetEffects["lifeState"] = "dead"
                    targetEffects = HandleDeath(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)
                    targetEffects = HandleKill(targetEffects["ply"],
                                               targetEffects["target"],
                                               targetEffects)

                    weapon:CheckForTeamDefeat(weapon.FightId)
                end

            end
        end
    end,

    Shangri_La = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        if playerDex >= 4 then tech = 20 end
        if not weaponName:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)

        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        targetEffects["ailmentChance"] = 10
        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        if playerChr >= 4 then
            targetEffects["ailmentChance"] = targetEffects["ailmentChance"] + 2
        end
        targetEffects["ailmentChance"] =
            math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end

        if playerChr >= 4 then
            for status, properties in pairs(targetEffects["targetDebuffsTable"]) do
                if table.HasValue(Ailments_Statuses["Ailments"], status) then
                    targetEffects["baseDamage"] = 55
                    break
                end
            end
        else
            for status, properties in pairs(targetEffects["targetDebuffsTable"]) do
                if table.HasValue(Ailments_Statuses["Non_Elemental_Ailments"],
                                  status) then
                    targetEffects["baseDamage"] = 55
                    break
                end
            end
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects["ailment"] = "Charm"

        targetEffects["ailmentChance"] =
            targetEffects["ailmentChance"] +
                (HandleStatus(targetEffects["ply"], userBuffsTable,
                              "increaseAilmentChance",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["ply"], userDebuffsTable,
                                 "decreaseAilmentChance",
                                 targetEffects["ailmentChance"], targetEffects)) -
                (HandleStatus(targetEffects["target"],
                              targetEffects["targetBuffsTable"],
                              "decreaseAilmentReceive",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["target"],
                                 targetEffects["targetDebuffsTable"],
                                 "increaseAilmentReceive",
                                 targetEffects["ailmentChance"], targetEffects))

        if math.random(1, 100) <= targetEffects["ailmentChance"] then

            local debuffsTable = GetAllStats(targetEffects["target"], "debuffs")

            debuffsTable["Charm"] = {
                stacks = 1,
                wearOff = "turnWearOff",
                duration = 4
            }

            AssignStat(targetEffects["target"], "Charm", debuffsTable["Charm"],
                       "debuffs")

            self:AnnounceMessage(targetEffects["target"]:Name() ..
                                     " is now Charmed!")

            HandleStatus(targetEffects["ply"], userBuffsTable,
                         "ailmentReaction", "Charm", targetEffects)
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    The_Punisher = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")

        local tech = SkillProperties[weaponName]["defaultTech"]
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        if playerDex >= 4 then tech = -5 end
        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        if playerChr >= 4 then
            targetEffects["ailmentChance"] = 8
            targetEffects["ailmentChance"] =
                math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]
        end

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects["ailment"] = "Panic"

        targetEffects["ailmentChance"] =
            targetEffects["ailmentChance"] +
                (HandleStatus(targetEffects["ply"], userBuffsTable,
                              "increaseAilmentChance",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["ply"], userDebuffsTable,
                                 "decreaseAilmentChance",
                                 targetEffects["ailmentChance"], targetEffects)) -
                (HandleStatus(targetEffects["target"],
                              targetEffects["targetBuffsTable"],
                              "decreaseAilmentReceive",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["target"],
                                 targetEffects["targetDebuffsTable"],
                                 "increaseAilmentReceive",
                                 targetEffects["ailmentChance"], targetEffects))

        if math.random(1, 100) <= targetEffects["ailmentChance"] then

            local targetDebuffsTable = GetAllStats(targetEffects["target"],
                                                   "debuffs")

            targetDebuffsTable["Panic"] = {
                stacks = 1,
                wearOff = "turnWearOff",
                duration = 3
            }

            AssignStat(targetEffects["target"], "Panic",
                       targetDebuffsTable["Panic"], "debuffs")

            self:AnnounceMessage(targetEffects["target"]:Name() ..
                                     " is now Panicking!")

            HandleStatus(targetEffects["ply"], userBuffsTable,
                         "ailmentReaction", "Panic", targetEffects)
        end

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Brave_Awaker = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]

        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects["userBuffsTable"]["Guard"] = {stacks = 1, duration = 2}

        AssignStat(ply, "Guard", targetEffects["userBuffsTable"]["Guard"],
                   "buffs")

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local playerStr = tonumber(targetEffects["ply"]:GetNWInt("TBCSTR", 0))
        if playerStr >= 6 then
            if targetEffects["userBuffsTable"]["Rakukaja"] then
                targetEffects["userBuffsTable"]["Rakukaja"].stacks = math.min(
                                                                         targetEffects["userBuffsTable"]["Rakukaja"]
                                                                             .stacks +
                                                                             1,
                                                                         4)
            else
                targetEffects["userBuffsTable"]["Rakukaja"] = {stacks = 1}
            end

            AssignStat(targetEffects["ply"], "Rakukaja",
                       targetEffects["userBuffsTable"]["Rakukaja"], "buffs")

            ply:ChatPrint("You got 1 Rakukaja!")
        end

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0) -- attacker's current TBCMP
        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        else
            ply:ChatPrint(
                "Select a person to remove Rakunda from. You can select them with secondary fire and pointing at them. If you want to do it on yourself, secondary fire without pointing at someone.")
        end
    end,

    Brave_Awaker_S = function(ply, target, weapon)
        local debuffsTable = GetAllStats(target, "debuffs")

        local message = "... " .. target:Name() ..
                            " doesn't have any Rakunda... so nothing happens!"

        if debuffsTable["Rakunda"] then
            if debuffsTable["Rakunda"].stacks > 1 then
                debuffsTable["Rakunda"].stacks =
                    debuffsTable["Rakunda"].stacks - 1
                AssignStat(target, "Rakunda", debuffsTable["Rakunda"], "buffs")
                message = target:Name() .. " got 1 Rakunda removed by " ..
                              ply:Name() .. "!"
            else
                RemoveStat(target, "Rakunda", "debuffs")
                debuffsTable["Rakunda"] = nil
                message = target:Name() .. " got their Rakunda removed by " ..
                              ply:Name() .. "!"
            end
        end

        weapon:AnnounceMessage(message)
    end,

    Traditional_Parasol = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]

        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)

            local resetChance = 40
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            if playerChr >= 4 then resetChance = 50 end

            if math.random(1, 100) <= resetChance then
                local targetDebuffsTable =
                    GetAllStats(targetEffects["target"], "debuffs")
                local debuffsToRemove = Ailments_Statuses["Elemental_Ailments"]

                for _, debuffName in ipairs(debuffsToRemove) do
                    if targetDebuffsTable[debuffName] then
                        if debuffName == "Shock" then
                            targetDebuffsTable["Shock"] = {
                                stacks = 1,
                                type = "turnSkipper",
                                duration = 3
                            }

                            AssignStat(targetEffects["target"], "Shock",
                                       targetDebuffsTable["Shock"], "debuffs")
                        elseif debuffName == "Freeze" then
                            targetDebuffsTable["Freeze"] = {
                                stacks = 1,
                                type = "turnSkipper",
                                duration = 3
                            }

                            AssignStat(targetEffects["target"], "Freeze",
                                       targetDebuffsTable["Freeze"], "debuffs")
                        elseif debuffName == "Burn" then
                            targetDebuffsTable["Burn"] = {
                                stacks = 1,
                                type = "turnDamage",
                                affinity = "fire",
                                duration = 3
                            }

                            AssignStat(targetEffects["target"], "Burn",
                                       targetDebuffsTable["Burn"], "debuffs")
                        elseif debuffName == "Confusion" then
                            targetDebuffsTable["Confusion"] = {
                                stacks = 1,
                                duration = 3
                            }

                            AssignStat(targetEffects["target"], "Confusion",
                                       targetDebuffsTable["Confusion"],
                                       "debuffs")
                        end
                    end
                end
            end
        end

        local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0) -- attacker's current TBCMP
        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Flower_Parasol = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local tech = SkillProperties[weaponName]["defaultTech"]

        if not weapon:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        local playerLuck = ply:GetNWInt("TBCLuck", 10)
        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end

        local debuffsToExplode = Ailments_Statuses["Ailments"]
        local ailmentsExploded = 0
        for _, debuffName in ipairs(debuffsToExplode) do
            if targetEffects["targetDebuffsTable"][debuffName] then
                RemoveStat(targetEffects["target"], debuffName, "debuffs")
                targetEffects["targetDebuffsTable"][debuffName] = nil
                ailmentsExploded = ailmentsExploded + 1
            end
        end

        if ailmentsExploded then
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            local explosiveDamage = ailmentsExploded * (12 + playerChr)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] + explosiveDamage

            if playerChr >= 4 then
                local mpToRestore = 0
                if explosiveDamage >= 20 then
                    mpToRestore = 8
                elseif explosiveDamage >= 40 then
                    mpToRestore = 12
                elseif explosiveDamage >= 60 then
                    mpToRestore = 16
                end

                if mpToRestore > 0 then
                    local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0)
                    local maxMP = targetEffects["ply"]:GetNWInt("TBCMAXMP", 100)
                    targetEffects["ply"]:SetNWInt("TBCMP", math.min(
                                                      attackerMP + mpToRestore,
                                                      maxMP))

                    ply:ChatPrint("You regenerate " .. mpToRestore .. " MP!")
                end
            end
        end

        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0) -- attacker's current TBCMP
        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end
    end,

    Quick_Focus = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        if userBuffsTable["Lock_On"] then
            if userBuffsTable["Lock_On"].visibility == 0 then
                userBuffsTable["Lock_On"].stacks = math.min(
                                                       userBuffsTable["Lock_On"]
                                                           .stacks + 1, 3)
            else
                userBuffsTable["Lock_On"].visibility = 1
            end
        end

        AssignStat(ply, "Lock_On", userBuffsTable["Lock_On"], "buffs")

        local attackerMP = ply:GetNWInt("TBCMP", 0)
        local maxMP = ply:GetNWInt("TBCMAXMP", 100)
        ply:SetNWInt("TBCMP", math.min(attackerMP + 15, maxMP))

        weapon:AnnounceMessage(ply:Name() ..
                                   " gains 1 Lock On and regenerates 15 MP!")

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    Windup = function(ply, target, weapon)
        weapon:AnnounceAbility()

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local debuffsTable = GetAllStats(target, "debuffs")

        debuffsTable["Shock"] = {stacks = 1, type = "turnSkipper", duration = 3}

        AssignStat(target, "Shock", debuffsTable["Shock"], "debuffs")

        weapon:AnnounceMessage(target:Name() .. " is now shocked!")

        HandleStatus(ply, userBuffsTable, "ailmentReaction", "Shock",
                     targetEffects)

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    Twilight_Shadow = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local currentHP = ply:GetNWInt("TBCHP", 100)

        if currentHP <= 0 then
            local message = "You can't heal a target that's dead."
            ply:ChatPrint(message)
            return
        end

        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]

        targetEffects["ply"] = ply
        targetEffects["target"] = ply

        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = userBuffsTable
        targetEffects["targetDebuffsTable"] = userDebuffsTable

        targetEffects["baseDamage"] = targetEffects["baseDamage"] *
                                          (1 +
                                              ((HandleStatus(ply,
                                                             targetEffects["userBuffsTable"],
                                                             "increaseHeal",
                                                             targetEffects["baseDamage"],
                                                             targetEffects) -
                                                  HandleStatus(ply,
                                                               userDebuffsTable,
                                                               "decreaseHeal",
                                                               targetEffects["baseDamage"],
                                                               targetEffects)) +
                                                  (HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetBuffsTable"],
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                                      HandleStatus(
                                                          targetEffects["target"],
                                                          targetEffects["targetDebuffsTable"],
                                                          "decreaseHealReceive",
                                                          targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (((HandleStatus(ply, userBuffsTable,
                                                          "flatIncreaseHeal",
                                                          targetEffects["baseDamage"]) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "flatDecreaseHeal",
                                                           targetEffects["baseDamage"])) +
                                              (HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetBuffsTable"],
                                                  "flatIncreaseHealReceive",
                                                  targetEffects["baseDamage"]) -
                                                  HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetDebuffsTable"],
                                                      "flatDecreaseHealReceive",
                                                      targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        HandleHealingEffects(ply, targetEffects["target"], targetEffects)

        local newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        targetEffects["target"] = target

        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        if targetBuffsTable["Tarukaja"] then
            targetBuffsTable["Tarukaja"].stacks = math.min(
                                                      targetBuffsTable["Tarukaja"]
                                                          .stacks + 1, 4)
        else
            targetBuffsTable["Tarukaja"] = {stacks = 1}
        end

        AssignStat(target, "Tarukaja", targetBuffsTable["Tarukaja"], "buffs")

        HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                     "buff", targetEffects)

        targetEffects["buff"] = "Tarukaja"

        HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                     targetEffects)

        local message = targetEffects["target"]:Name() ..
                            " received Tarukaja and " ..
                            targetEffects["ply"]:Name() ..
                            " healed themselves for " ..
                            targetEffects["baseDamage"] .. "!"

        weapon:AnnounceMessage(message)

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    Twilight_Shadow_S = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local currentHP = ply:GetNWInt("TBCHP", 100)

        if currentHP <= 0 then
            local message = "You can't heal a target that's dead."
            ply:ChatPrint(message)
            return
        end

        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["baseDamage"] = targetEffects["baseDamage"] *
                                          (1 +
                                              ((HandleStatus(ply,
                                                             targetEffects["userBuffsTable"],
                                                             "increaseHeal",
                                                             targetEffects["baseDamage"],
                                                             targetEffects) -
                                                  HandleStatus(ply,
                                                               userDebuffsTable,
                                                               "decreaseHeal",
                                                               targetEffects["baseDamage"],
                                                               targetEffects)) +
                                                  (HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetBuffsTable"],
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                                      HandleStatus(
                                                          targetEffects["target"],
                                                          targetEffects["targetDebuffsTable"],
                                                          "decreaseHealReceive",
                                                          targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (((HandleStatus(ply, userBuffsTable,
                                                          "flatIncreaseHeal",
                                                          targetEffects["baseDamage"]) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "flatDecreaseHeal",
                                                           targetEffects["baseDamage"])) +
                                              (HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetBuffsTable"],
                                                  "flatIncreaseHealReceive",
                                                  targetEffects["baseDamage"]) -
                                                  HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetDebuffsTable"],
                                                      "flatDecreaseHealReceive",
                                                      targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        HandleHealingEffects(ply, targetEffects["target"], targetEffects)

        local newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        targetEffects["target"] = ply

        targetEffects["targetBuffsTable"] = userBuffsTable
        targetEffects["targetDebuffsTable"] = userDebuffsTable

        if userBuffsTable["Tarukaja"] then
            userBuffsTable["Tarukaja"].stacks = math.min(
                                                    targetBuffsTable["Tarukaja"]
                                                        .stacks + 1, 4)
        else
            userBuffsTable["Tarukaja"] = {stacks = 1}
        end

        AssignStat(target, "Tarukaja", userBuffsTable["Tarukaja"], "buffs")

        HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                     "buff", targetEffects)

        targetEffects["buff"] = "Tarukaja"

        HandleStatus(target, userBuffsTable, "reactionBuff", "buff",
                     targetEffects)

        local message =
            targetEffects["ply"]:Name() .. " received Tarukaja and " ..
                targetEffects["target"]:Name() .. " was healed for " ..
                targetEffects["baseDamage"] .. "!"

        weapon:AnnounceMessage(message)

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    Unwavering_Support = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local currentHP = target:GetNWInt("TBCHP", 100)

        if currentHP <= 0 then
            local message = "You can't heal a target that's dead."
            ply:ChatPrint(message)
            return
        end

        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["baseDamage"] = targetEffects["baseDamage"] *
                                          (1 +
                                              ((HandleStatus(ply,
                                                             targetEffects["userBuffsTable"],
                                                             "increaseHeal",
                                                             targetEffects["baseDamage"],
                                                             targetEffects) -
                                                  HandleStatus(ply,
                                                               userDebuffsTable,
                                                               "decreaseHeal",
                                                               targetEffects["baseDamage"],
                                                               targetEffects)) +
                                                  (HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetBuffsTable"],
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                                      HandleStatus(
                                                          targetEffects["target"],
                                                          targetEffects["targetDebuffsTable"],
                                                          "decreaseHealReceive",
                                                          targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (((HandleStatus(ply, userBuffsTable,
                                                          "flatIncreaseHeal",
                                                          targetEffects["baseDamage"]) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "flatDecreaseHeal",
                                                           targetEffects["baseDamage"])) +
                                              (HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetBuffsTable"],
                                                  "flatIncreaseHealReceive",
                                                  targetEffects["baseDamage"]) -
                                                  HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetDebuffsTable"],
                                                      "flatDecreaseHealReceive",
                                                      targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        HandleHealingEffects(ply, targetEffects["target"], targetEffects)

        local newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        if targetBuffsTable["Tarukaja"] then
            targetBuffsTable["Tarukaja"].stacks = math.min(
                                                      targetBuffsTable["Tarukaja"]
                                                          .stacks + 1, 4)
        else
            targetBuffsTable["Tarukaja"] = {stacks = 1}
        end

        AssignStat(target, "Tarukaja", targetBuffsTable["Tarukaja"], "buffs")

        HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                     "buff", targetEffects)

        targetEffects["buff"] = "Tarukaja"

        HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                     targetEffects)

        local message = targetEffects["target"]:Name() ..
                            " received Tarukaja and healed for " ..
                            targetEffects["baseDamage"] .. " by " ..
                            targetEffects["ply"]:Name() .. "!"

        weapon:AnnounceMessage(message)

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

    end,

    Purple_Leaves = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["Purple_Leaves"] then
            ply:ChatPrint("You cannot use this without Purple Leaves.")
            return
        end

        if targetEffects["userBuffsTable"]["Purple_Leaves"].stacks <= 3 then
            ply:ChatPrint("You don't have enough Purple Leaves!")
            return
        end

        local currentHP = target:GetNWInt("TBCHP", 100)

        if currentHP <= 0 then
            local message = "You can't heal a target that's dead."
            ply:ChatPrint(message)
            return
        end

        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        targetEffects["baseDamage"] = 0.15 * maxHP

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["baseDamage"] = targetEffects["baseDamage"] *
                                          (1 +
                                              ((HandleStatus(ply,
                                                             targetEffects["userBuffsTable"],
                                                             "increaseHeal",
                                                             targetEffects["baseDamage"],
                                                             targetEffects) -
                                                  HandleStatus(ply,
                                                               userDebuffsTable,
                                                               "decreaseHeal",
                                                               targetEffects["baseDamage"],
                                                               targetEffects)) +
                                                  (HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetBuffsTable"],
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                                      HandleStatus(
                                                          targetEffects["target"],
                                                          targetEffects["targetDebuffsTable"],
                                                          "decreaseHealReceive",
                                                          targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (((HandleStatus(ply, userBuffsTable,
                                                          "flatIncreaseHeal",
                                                          targetEffects["baseDamage"]) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "flatDecreaseHeal",
                                                           targetEffects["baseDamage"])) +
                                              (HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetBuffsTable"],
                                                  "flatIncreaseHealReceive",
                                                  targetEffects["baseDamage"]) -
                                                  HandleStatus(
                                                      targetEffects["target"],
                                                      targetEffects["targetDebuffsTable"],
                                                      "flatDecreaseHealReceive",
                                                      targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        HandleHealingEffects(ply, targetEffects["target"], targetEffects)

        local newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        if targetBuffsTable["Tarukaja"] then
            targetBuffsTable["Tarukaja"].stacks = math.min(
                                                      targetBuffsTable["Tarukaja"]
                                                          .stacks + 2, 4)
        else
            targetBuffsTable["Tarukaja"] = {stacks = 2}
        end

        AssignStat(target, "Tarukaja", targetBuffsTable["Tarukaja"], "buffs")

        HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                     "buff", targetEffects)

        targetEffects["buff"] = "Tarukaja"

        HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                     targetEffects)

        local message = targetEffects["target"]:Name() ..
                            " received 2 Tarukaja and healed for " ..
                            targetEffects["baseDamage"] .. " by " ..
                            targetEffects["ply"]:Name() .. "!"

        weapon:AnnounceMessage(message)

        userBuffsTable["Purple_Leaves"].stacks = 1
        userBuffsTable["Purple_Leaves"].visibility = 0

        AssignStat(ply, "Purple_Leaves", userBuffsTable["Purple_Leaves"],
                   "buffs")
    end,

    Majestic_Presence = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        targetEffects["baseDamage"] = SkillProperties[weaponName]["damage"]
        targetEffects["Affinity"] = SkillProperties[weaponName]["affinity"]

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            weapon:AnnounceMessage(target:Name() .. " repeled the attack!")
        end
        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
                                          (HandleStatus(targetEffects["ply"],
                                                        targetEffects["userBuffsTable"],
                                                        "damage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(targetEffects["ply"],
                                                           targetEffects["userDebuffsTable"],
                                                           "decreaseDamage",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) -
                                          (HandleStatus(targetEffects["target"],
                                                        targetEffects["targetBuffsTable"],
                                                        "defenseDamage",
                                                        targetEffects["baseDamage"],
                                                        targetEffects) -
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects = HandleDamageMessage(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

        local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
        local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
        local newHP

        if targetEffects["state"] == "drain" then
            newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
        else
            newHP = currentHP - targetEffects["baseDamage"]
            HandleStatus(targetEffects["target"], targetEffects,
                         "damageReaction", false, targetEffects)
        end

        targetEffects["target"]:SetNWInt("TBCHP", newHP)

        weapon:AnnounceMessage(targetEffects["message"])

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

        userBuffsTable["Majestic_Presence"] = {
            stacks = 1,
            type = "turnRegen",
            duration = 1
        }

        AssignStat(ply, "Majestic_Presence",
                   userBuffsTable["Majestic_Presence"], "buffs")

        if newHP <= 0 then
            targetEffects["target"]:SetNWInt("TBCHP", 0)

            targetEffects["lifeState"] = "dead"
            targetEffects = HandleDeath(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            weapon:CheckForTeamDefeat(weapon.FightId)
        end

    end,

    Pinnacle_of_Magic = function(ply, target, weapon)
        weapon:AnnounceAbility()
        local weaponName = weapon.PrintName:gsub("%s+", "_"):gsub("[%(%)]", "")
                               :gsub("-", "_")

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            return
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if fight then
        else
            return
        end

        local playerSide = (table.HasValue(fight.Side1, ply) and "Side1") or
                               (table.HasValue(fight.Side2, ply) and "Side2")

        local playersInFight = {}
        for _, player in ipairs(fight[playerSide]) do
            if TargetCheckValidity(ply, player) then
                table.insert(playersInFight, player)
            end
        end

        local lastPlayer = ply
        for _, player in ipairs(playersInFight) do
            if IsValid(player) then -- Check if the player is valid
                local buffsTable = GetAllStats(player, "buffs")

                buffsTable["Pinnacle_of_Magic"] = {
                    stacks = 1,
                    duration = 2,
                    caster = ply:UserId()
                }

                AssignStat(player, "Pinnacle_of_Magic",
                           buffsTable["Pinnacle_of_Magic"], "buffs")

                targetEffects["buff"] = "Pinnacle_of_Magic"

                HandleStatus(player, buffsTable, "reactionBuff", "buff",
                             targetEffects)

                local message = player:Name() ..
                                    " received Pinnacle of Magic from " ..
                                    ply:Name() .. "!"

                weapon:AnnounceMessage(message)
            end
        end

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

        weapon:EndAbility()
    end
}

function HandleSkill(ply, target, skillName)
    local result = false
    local handler = SkillHandlers[skillName]
    if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
        not TargetCheckValidity(ply, target, true) then return result end
    local weapon = ply:GetActiveWeapon()

    if handler then result = handler(ply, target, weapon) 
        weapon:EndAbility()
    end
    return result
end
