include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Watson Concoction"
SWEP.Author = "ME"
SWEP.Contact = ""
SWEP.Purpose =
    "Heal based on 47% of target's max base HP. \n[STR 4] Can deal damage to opposing party now with 11 Technique. Deals 25% of target's max base HP with a 10% chance of applying Paralysis and Charm. \n[CHR 4] Applies a random Kaja on friendly target. Applies a random Kunda on enemy target. \n[DEX 4] 10% Crit chance. Can now Crit."
SWEP.Instructions = ""
SWEP.Category = "Ame Weapons"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Automatic = false
SWEP.Primary.Recoil = 100
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0
SWEP.Primary.Cone = 0
SWEP.Primary.Delay = 0.2

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false

SWEP.Weight = 7
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/smti_handgun1_v.mdl"
SWEP.WorldModel = "models/weapons/default/w_357.mdl"

SWEP.UseHands = true

SWEP.SetHoldType = "revolver"

SWEP.DamageAmount = 141
SWEP.MPCost = 37
SWEP.Affinity = "Support"
SWEP.IsHeal = true
SWEP.Rarity = "Exclusive"
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

    local tmin = Vector(1, 1, 1) * -10
    local tmax = Vector(1, 1, 1) * 10

    local tr = util.TraceHull({
        start = ShootPos,
        endpos = ShootEnd,
        filter = ply,
        mask = MASK_SHOT_HULL,
        mins = tmin,
        maxs = tmax
    })

    if not IsValid(tr.Entity) then
        tr = util.TraceLine({
            start = ShootPos,
            endpos = ShootEnd,
            filter = ply,
            mask = MASK_SHOT_HULL
        })
    end

    if tr.Hit and CheckIfValidTBCEntity(tr.Entity) then
        local target = tr.Entity
        local dmg = DamageInfo()
        dmg:SetDamage(0)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(self)
        dmg:SetDamageForce(ply:GetAimVector())
        dmg:SetDamagePosition(target:GetPos())
        dmg:SetDamageType(DMG_CLUB)
        target:DispatchTraceAttack(dmg, ShootPos + ply:EyeAngles():Right() * -5,
                                   ShootEnd)

        if SERVER and IsValid(target) then
            local inAFight = true

            local validEffectStatus = HealCheckValidity(ply, ply)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            inAFight = validEffectStatus["inAFight"]

            self:AnnounceAbility()

            local engageWeapon = target:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint("Target does not have an engage swep.")
                ply:LagCompensation(false)
                return
            end

            if engageWeapon.FightId ~= self.FightId then
                ply:ChatPrint("Target is not in your fight.")
                ply:LagCompensation(false)
                return
            end

            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))

            local playerSide
            local targetSide
            if inAFight then
                local fight =
                    TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]

                playerSide = (table.HasValue(fight.Side1, ply) and "Side1") or
                                 (table.HasValue(fight.Side2, ply) and "Side2")
                targetSide =
                    (table.HasValue(fight.Side1, target) and "Side1") or
                        (table.HasValue(fight.Side2, target) and "Side2")
            end

            if playerStr >= 4 and (inAFight and targetSide ~= playerSide) then
                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")
                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                local hpCost = 20 -- HP cost of the attack

                local attackerHP = ply:GetNWInt("TBCHP", 0)

                if attackerHP >= hpCost then
                    ply:SetNWInt("TBCHP", attackerHP - hpCost)
                else
                    ply:ChatPrint("Not enough HP to use this ability.")
                    return
                end

                local targetEffects = {}
                local maxHP = target:GetNWInt("TBCMAXHP", 100)
                targetEffects["Affinity"] = "Pierce"
                targetEffects["percentHeal"] = 0.22
                targetEffects["baseDamage"] = maxHP *
                                                  targetEffects["percentHeal"]

                local playerLuck = ply:GetNWInt("TBCLuck", 10)

                playerLuck = playerLuck +
                                 (HandleStatus(ply, userBuffsTable,
                                               "increaseLuck", playerLuck) -
                                     HandleStatus(ply, userDebuffsTable,
                                                  "decreaseLuck", playerLuck))

                targetEffects["ailmentChance"] = 10
                targetEffects["ailmentChance"] =
                    math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]

                local critBonus = 10 +
                                      (HandleStatus(ply, userBuffsTable,
                                                    "increaseCritChance",
                                                    targetEffects["baseDamage"]) -
                                          HandleStatus(ply, userDebuffsTable,
                                                       "decreaseCritChance",
                                                       targetEffects["baseDamage"]))

                targetEffects["critChance"] =
                    math.ceil((playerLuck / 2) + critBonus)

                targetEffects["state"] = 'normal'
                targetEffects["message"] =
                    target:Name() .. " received " .. targetEffects["baseDamage"] ..
                        " damage."

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                targetEffects["userBuffsTable"] = userBuffsTable
                targetEffects["userDebuffsTable"] = userDebuffsTable
                targetEffects["targetBuffsTable"] = targetBuffsTable
                targetEffects["targetDebuffsTable"] = targetDebuffsTable

                targetEffects = HandleCrit(ply, target, targetEffects)

                targetEffects["baseDamage"] =
                    targetEffects["baseDamage"] +
                        (HandleStatus(ply, targetEffects["userBuffsTable"],
                                      "damage", targetEffects["baseDamage"],
                                      targetEffects) -
                            HandleStatus(ply, targetEffects["userDebuffsTable"],
                                         "decreaseDamage",
                                         targetEffects["baseDamage"],
                                         targetEffects)) -
                        (HandleStatus(target, targetEffects["targetBuffsTable"],
                                      "defenseDamage",
                                      targetEffects["baseDamage"], targetEffects) -
                            HandleStatus(target,
                                         targetEffects["targetDebuffsTable"],
                                         "defenseDecrease",
                                         targetEffects["baseDamage"],
                                         targetEffects))

                targetEffects["baseDamage"] = math.ceil(
                                                  targetEffects["baseDamage"])

                targetEffects["ailmentChance"] =
                    targetEffects["ailmentChance"] +
                        (HandleStatus(ply, userBuffsTable,
                                      "increaseAilmentChance",
                                      targetEffects["ailmentChance"],
                                      targetEffects) -
                            HandleStatus(ply, userDebuffsTable,
                                         "decreaseAilmentChance",
                                         targetEffects["ailmentChance"],
                                         targetEffects)) -
                        (HandleStatus(target, targetBuffsTable,
                                      "decreaseAilmentReceive",
                                      targetEffects["ailmentChance"],
                                      targetEffects) -
                            HandleStatus(target, targetDebuffsTable,
                                         "increaseAilmentReceive",
                                         targetEffects["ailmentChance"],
                                         targetEffects))

                if math.random(1, 100) <= targetEffects["ailmentChance"] then
                    local targetDebuffsTable = GetAllStats(target, "debuffs")

                    targetDebuffsTable["Paralysis"] = {
                        stacks = 1,
                        type = "turnSkipper",
                        wearOff = "turnWearOff",
                        duration = 3
                    }

                    targetDebuffsTable["Charm"] = {
                        stacks = 1,
                        wearOff = "turnWearOff",
                        duration = 4
                    }

                    AssignStat(target, "Charm", targetDebuffsTable["Charm"],
                               "debuffs")

                    self:AnnounceMessage(target:Name() ..
                                             " is now Paralysed AND Charmed!")

                    HandleStatus(ply, userBuffsTable, "ailmentReaction",
                                 "Charm", targetEffects)
                end

                if playerChr >= 4 then
                    local targetDebuffsTable = GetAllStats(target, "debuffs")

                    -- Pick a random index in the array
                    local randomIndex = math.random(#Ailments_Statuses["Nda"])

                    -- Access the element at that index
                    local randomElement = Ailments_Statuses["Nda"][randomIndex]

                    if targetDebuffsTable[randomElement] then
                        targetDebuffsTable[randomElement].stacks = math.min(
                                                                       targetDebuffsTable[randomElement]
                                                                           .stacks +
                                                                           1, 4)
                    else
                        targetDebuffsTable[randomElement] = {stacks = 1}
                    end

                    AssignStat(target, randomElement,
                               targetDebuffsTable[randomElement], "debuffs")

                    self:AnnounceMessage(
                        target:Name() .. " has received " .. randomElement ..
                            " from " .. ply:Name() .. "!")
                end

                targetEffects = HandleDamageMessage(ply, target, targetEffects)

                local currentHP = target:GetNWInt("TBCHP", 100)
                local newHP

                if targetEffects["state"] == "drain" then
                    newHP = math.min(currentHP + targetEffects["baseDamage"],
                                     maxHP)
                else
                    newHP = currentHP - targetEffects["baseDamage"]
                    HandleStatus(target, targetEffects, "damageReaction", false,
                                 targetEffects)
                end

                target:SetNWInt("TBCHP", newHP)

                self:AnnounceMessage(targetEffects["message"])

                if newHP <= 0 then
                    targetEffects["target"]:SetNWInt("TBCHP", 0)

                    targetEffects["lifeState"] = "dead"
                    targetEffects = HandleDeath(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)
                    targetEffects = HandleKill(targetEffects["ply"],
                                               targetEffects["target"],
                                               targetEffects)

                    self:CheckForTeamDefeat(self.FightId)
                end
            else
                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")

                local targetEffects = {}

                targetEffects["userBuffsTable"] = userBuffsTable
                targetEffects["userDebuffsTable"] = userDebuffsTable

                local status = HandleStatus(ply,
                                            targetEffects["userDebuffsTable"],
                                            "canUseSkills", true, targetEffects)

                if not status then
                    ply:LagCompensation(false)
                    return
                end

                local mpCost = self.MPCost -- MP cost of the attack
                local attackerMP = ply:GetNWInt("TBCMP", 100)

                mpCost = mpCost +
                             (HandleStatus(ply, userDebuffsTable,
                                           "increaseMPCost", mpCost) -
                                 HandleStatus(ply, userBuffsTable,
                                              "decreaseMPCost", mpCost))

                if attackerMP >= mpCost then
                    ply:SetNWInt("TBCMP", attackerMP - mpCost)
                else
                    ply:ChatPrint("Not enough MP to use this ability.")
                    ply:LagCompensation(false)
                    return
                end

                local currentHP = target:GetNWInt("TBCHP", 100)

                if currentHP <= 0 then
                    local message = "You can't heal a target that's dead."
                    ply:ChatPrint(message)
                    return
                end

                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")
                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                local targetEffects = {}
                targetEffects["baseDamage"] = self.DamageAmount

                targetEffects["percentHeal"] = 0.47

                targetEffects["ply"] = ply
                targetEffects["target"] = target
                local playerLuck = ply:GetNWInt("TBCLuck", 10)

                local maxHP = target:GetNWInt("TBCMAXHP", 100)

                targetEffects["baseDamage"] = maxHP *
                                                  targetEffects["percentHeal"]

                targetEffects["ailmentChance"] = 10
                targetEffects["ailmentChance"] =
                    math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]

                if playerDex >= 4 then
                    playerLuck = playerLuck +
                                     (HandleStatus(ply, userBuffsTable,
                                                   "increaseLuck", playerLuck) -
                                         HandleStatus(ply, userDebuffsTable,
                                                      "decreaseLuck", playerLuck))

                    local critBonus = 10 +
                                          (HandleStatus(ply, userBuffsTable,
                                                        "increaseCritChance",
                                                        targetEffects["baseDamage"]) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "decreaseCritChance",
                                                           targetEffects["baseDamage"]))

                    targetEffects["critChance"] =
                        math.ceil((playerLuck / 2) + critBonus)

                    targetEffects = HandleCrit(ply, target, targetEffects)
                end

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                targetEffects["userBuffsTable"] = userBuffsTable
                targetEffects["userDebuffsTable"] = userDebuffsTable
                targetEffects["targetBuffsTable"] = targetBuffsTable
                targetEffects["targetDebuffsTable"] = targetDebuffsTable

                targetEffects["baseDamage"] =
                    targetEffects["baseDamage"] * (1 +
                        ((HandleStatus(ply, userBuffsTable, "increaseHeal",
                                       targetEffects["baseDamage"]) -
                            HandleStatus(ply, userDebuffsTable, "decreaseHeal",
                                         targetEffects["baseDamage"])) +
                            (HandleStatus(target, targetBuffsTable,
                                          "increaseHealReceive",
                                          targetEffects["baseDamage"]) -
                                HandleStatus(target, targetDebuffsTable,
                                             "decreaseHealReceive",
                                             targetEffects["baseDamage"]))))

                targetEffects["baseDamage"] =
                    targetEffects["baseDamage"] +
                        (((HandleStatus(ply, userBuffsTable, "flatIncreaseHeal",
                                        targetEffects["baseDamage"]) -
                            HandleStatus(ply, userDebuffsTable,
                                         "flatDecreaseHeal",
                                         targetEffects["baseDamage"])) +
                            (HandleStatus(target, targetBuffsTable,
                                          "flatIncreaseHealReceive",
                                          targetEffects["baseDamage"]) -
                                HandleStatus(target, targetDebuffsTable,
                                             "flatDecreaseHealReceive",
                                             targetEffects["baseDamage"]))))

                targetEffects["baseDamage"] = math.ceil(
                                                  targetEffects["baseDamage"])

                HandleHealingEffects(ply, target, targetEffects)

                local newHP = math.min(currentHP + targetEffects["baseDamage"],
                                       maxHP)

                target:SetNWInt("TBCHP", newHP)

                local message = target:Name() .. " received " ..
                                    targetEffects["baseDamage"] ..
                                    " healing from " .. ply:Name()

                if playerChr >= 4 and inAFight then
                    local targetBuffsTable = GetAllStats(target, "buffs")

                    -- Pick a random index in the array
                    local randomIndex = math.random(#Ailments_Statuses["Kaja"])

                    -- Access the element at that index
                    local randomElement = Ailments_Statuses["Kaja"][randomIndex]

                    if targetBuffsTable[randomElement] then
                        targetBuffsTable[randomElement].stacks = math.min(
                                                                     targetBuffsTable[randomElement]
                                                                         .stacks +
                                                                         1, 4)
                    else
                        targetBuffsTable[randomElement] = {stacks = 1}
                    end

                    AssignStat(target, randomElement,
                               targetBuffsTable[randomElement], "buffs")

                    self:AnnounceMessage(
                        target:Name() .. " has received " .. randomElement ..
                            " from " .. ply:Name() .. "!")
                end

                if inAFight then
                    self:AnnounceMessage(message)

                    targetEffects["ply"] = ply
                    targetEffects["target"] = target

                    HandleStatus(ply, targetEffects["userBuffsTable"],
                                 "reactionBuff", "buff", targetEffects)
                else
                    message = target:Name() .. " received " ..
                                  targetEffects["baseDamage"] .. " healing."
                    ply:ChatPrint(message)
                    message = ply:Name() .. " healed you for " ..
                                  targetEffects["baseDamage"] .. "."
                    target:ChatPrint(message)
                end
            end

            self:ShootEffects()
            self:EmitSound(ShootSound)
            self.Owner:ViewPunch(Angle(-1.5, 0, 0))
            self.BaseClass.ShootEffects(self)

        end
    end

    ply:LagCompensation(false)
end --

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

    local tmin = Vector(1, 1, 1) * -10
    local tmax = Vector(1, 1, 1) * 10

    local target = ply
    local dmg = DamageInfo()
    dmg:SetDamage(0)
    dmg:SetAttacker(ply)
    dmg:SetInflictor(self)
    dmg:SetDamageForce(ply:GetAimVector())
    dmg:SetDamagePosition(target:GetPos())
    dmg:SetDamageType(DMG_CLUB)
    target:DispatchTraceAttack(dmg, ShootPos + ply:EyeAngles():Right() * -5,
                               ShootEnd)

    if SERVER and IsValid(target) then

        local inAFight = true

        local validEffectStatus = HealCheckValidity(ply, target)

        if not validEffectStatus then
            ply:LagCompensation(false)
            return
        end

        inAFight = validEffectStatus["inAFight"]

        self:AnnounceAbility()

        local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))

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

        local mpCost = self.MPCost -- MP cost of the attack
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

        local currentHP = target:GetNWInt("TBCHP", 100)

        if currentHP <= 0 then
            local message = "You can't heal a target that's dead."
            ply:ChatPrint(message)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        targetEffects["baseDamage"] = self.DamageAmount

        targetEffects["percentHeal"] = 0.47

        targetEffects["ply"] = ply
        targetEffects["target"] = target
        local playerLuck = ply:GetNWInt("TBCLuck", 10)

        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        targetEffects["baseDamage"] = maxHP * targetEffects["percentHeal"]

        targetEffects["ailmentChance"] = 10
        targetEffects["ailmentChance"] =
            math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]

        if playerDex >= 4 then
            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = 10 +
                                  (HandleStatus(ply, userBuffsTable,
                                                "increaseCritChance",
                                                targetEffects["baseDamage"]) -
                                      HandleStatus(ply, userDebuffsTable,
                                                   "decreaseCritChance",
                                                   targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects = HandleCrit(ply, target, targetEffects)
        end

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["baseDamage"] = targetEffects["baseDamage"] * (1 +
                                          ((HandleStatus(ply, userBuffsTable,
                                                         "increaseHeal",
                                                         targetEffects["baseDamage"]) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "decreaseHeal",
                                                           targetEffects["baseDamage"])) +
                                              (HandleStatus(target,
                                                            targetBuffsTable,
                                                            "increaseHealReceive",
                                                            targetEffects["baseDamage"]) -
                                                  HandleStatus(target,
                                                               targetDebuffsTable,
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
                                              (HandleStatus(target,
                                                            targetBuffsTable,
                                                            "flatIncreaseHealReceive",
                                                            targetEffects["baseDamage"]) -
                                                  HandleStatus(target,
                                                               targetDebuffsTable,
                                                               "flatDecreaseHealReceive",
                                                               targetEffects["baseDamage"]))))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        HandleHealingEffects(ply, target, targetEffects)

        local newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)

        target:SetNWInt("TBCHP", newHP)

        local message = target:Name() .. " received " ..
                            targetEffects["baseDamage"] .. " healing from " ..
                            ply:Name()

        if playerChr >= 4 and inAFight then
            local targetBuffsTable = GetAllStats(target, "buffs")

            -- Pick a random index in the array
            local randomIndex = math.random(#Ailments_Statuses["Kaja"])

            -- Access the element at that index
            local randomElement = Ailments_Statuses["Kaja"][randomIndex]

            if targetBuffsTable[randomElement] then
                targetBuffsTable[randomElement].stacks = math.min(
                                                             targetBuffsTable[randomElement]
                                                                 .stacks + 1, 4)
            else
                targetBuffsTable[randomElement] = {stacks = 1}
            end

            AssignStat(target, randomElement, targetBuffsTable[randomElement],
                       "buffs")

            self:AnnounceMessage(target:Name() .. " has received " ..
                                     randomElement .. " from " .. ply:Name() ..
                                     "!")
        end

        if inAFight then
            self:AnnounceMessage(message)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            
        else
            message = target:Name() .. " received " ..
                          targetEffects["baseDamage"] .. " healing."
            ply:ChatPrint(message)
            message = ply:Name() .. " healed you for " ..
                          targetEffects["baseDamage"] .. "."
            target:ChatPrint(message)
        end

        self:ShootEffects()
        self:EmitSound(ShootSound)
        self.Owner:ViewPunch(Angle(-1.5, 0, 0))
        self.BaseClass.ShootEffects(self)

    end

    ply:LagCompensation(false)
end --

function SWEP:Think()
    if not self:GetOwner():KeyDown(IN_RELOAD) then
        self.CanUseAbility = true -- Reset flag when reload key is released
    end
end
