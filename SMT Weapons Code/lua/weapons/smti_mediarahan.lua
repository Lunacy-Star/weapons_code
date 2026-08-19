include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Mediarahan"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Heal based on 75% of all allies' max base HP. \n[CHR 6] 100% of HP instead."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Skills"

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

SWEP.DamageAmount = 225
SWEP.MPCost = 110
SWEP.Affinity = "Support"
SWEP.IsHeal = true
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
    self:SetNextPrimaryFire(CurTime() + 1)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

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

    self:ShootEffects()
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(-1.5, 0, 0))
    self.BaseClass.ShootEffects(self)

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

            if inAFight then
                self:AnnounceAbility()

                local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
                if fight then
                else
                    return
                end

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

                local playerSide = (table.HasValue(fight.Side1, target) and
                                       "Side1") or
                                       (table.HasValue(fight.Side2, target) and
                                           "Side2")

                local playersInFight = {}
                for _, player in ipairs(fight[playerSide]) do
                    if IsValid(player) then
                        table.insert(playersInFight, player)
                    end
                end

                local lastPlayer = ply
                for _, target in ipairs(playersInFight) do
                    if IsValid(target) then -- Check if the player is valid
                        local currentHP = target:GetNWInt("TBCHP", 100)
                        if currentHP > 0 then
                            local userBuffsTable = GetAllStats(ply, "buffs")
                            local userDebuffsTable = GetAllStats(ply, "debuffs")
                            local targetBuffsTable =
                                GetAllStats(target, "buffs")
                            local targetDebuffsTable = GetAllStats(target,
                                                                   "debuffs")

                            local playerChr =
                                tonumber(ply:GetNWInt("TBCCHR", 0))

                            local targetEffects = {}
                            targetEffects["baseDamage"] = self.DamageAmount

                            targetEffects["percentHeal"] = 0.75

                            targetEffects["ply"] = ply
                            targetEffects["target"] = target

                            local maxHP = target:GetNWInt("TBCMAXHP", 100)

                            if playerChr >= 4 then
                                targetEffects["baseDamage"] = maxHP
                                targetEffects["percentHeal"] = 1
                            end

                            if maxHP <= 300 then
                                targetEffects["baseDamage"] = maxHP *
                                                                  targetEffects["percentHeal"]
                            end

                            targetEffects["ply"] = ply
                            targetEffects["target"] = target

                            targetEffects["userBuffsTable"] = userBuffsTable
                            targetEffects["userDebuffsTable"] = userDebuffsTable
                            targetEffects["targetBuffsTable"] = targetBuffsTable
                            targetEffects["targetDebuffsTable"] =
                                targetDebuffsTable

                            targetEffects["baseDamage"] =
                                targetEffects["baseDamage"] * (1 +
                                    ((HandleStatus(ply, userBuffsTable,
                                                   "increaseHeal",
                                                   targetEffects["baseDamage"]) -
                                        HandleStatus(ply, userDebuffsTable,
                                                     "decreaseHeal",
                                                     targetEffects["baseDamage"])) +
                                        (HandleStatus(target, targetBuffsTable,
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                            HandleStatus(target,
                                                         targetDebuffsTable,
                                                         "decreaseHealReceive",
                                                         targetEffects["baseDamage"]))))

                            targetEffects["baseDamage"] =
                                targetEffects["baseDamage"] +
                                    (((HandleStatus(ply, userBuffsTable,
                                                    "flatIncreaseHeal",
                                                    targetEffects["baseDamage"]) -
                                        HandleStatus(ply, userDebuffsTable,
                                                     "flatDecreaseHeal",
                                                     targetEffects["baseDamage"])) +
                                        (HandleStatus(target, targetBuffsTable,
                                                      "flatIncreaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                            HandleStatus(target,
                                                         targetDebuffsTable,
                                                         "flatDecreaseHealReceive",
                                                         targetEffects["baseDamage"]))))

                            targetEffects["baseDamage"] = math.ceil(
                                                              targetEffects["baseDamage"])

                            HandleHealingEffects(ply, target, targetEffects)

                            local newHP =
                                math.min(currentHP + targetEffects["baseDamage"],
                                         maxHP)

                            target:SetNWInt("TBCHP", newHP)

                            local message =
                                target:Name() .. " received " ..
                                    targetEffects["baseDamage"] ..
                                    " healing from " .. ply:Name() .. "!"
                            self:AnnounceMessage(message)

                            if ply ~= target then
                                lastPlayer = target
                            end
                        end
                    end
                end

                targetEffects["ply"] = ply
                targetEffects["target"] = lastPlayer

                HandleStatus(ply, targetEffects["userBuffsTable"],
                             "reactionBuff", "buff", targetEffects)

                self:EndAbility()
            else
                local tr = util.TraceLine({
                    start = self.Owner:EyePos(),
                    endpos = self.Owner:EyePos() + self.Owner:GetAimVector() *
                        1000,
                    filter = self.Owner
                })

                local aoeCenter = tr.HitPos

                local playersInArea = ents.FindInSphere(aoeCenter, 100)

                local mpCost = self.MPCost -- MP cost of the attack
                local attackerMP = ply:GetNWInt("TBCMP", 100)

                if attackerMP >= mpCost then
                    ply:SetNWInt("TBCMP", attackerMP - mpCost)
                else
                    ply:ChatPrint("Not enough MP to use this ability.")
                    ply:LagCompensation(false)
                    return
                end

                for _, target in ipairs(playersInArea) do
                    if IsValid(target) and CheckIfValidTBCEntity(target) then -- Check if the player is valid
                        local targetEngageSWEP
                        for _, weapon in ipairs(target:GetWeapons()) do
                            if weapon:GetClass() == "smti_engageswep" then
                                targetEngageSWEP = weapon
                                break
                            end
                        end

                        if targetEngageSWEP.FightId == self.FightId then
                            local currentHP = target:GetNWInt("TBCHP", 100)
                            if currentHP > 0 then
                                local userBuffsTable = GetAllStats(ply, "buffs")
                                local userDebuffsTable = GetAllStats(ply,
                                                                     "debuffs")
                                local targetBuffsTable = GetAllStats(target,
                                                                     "buffs")
                                local targetDebuffsTable = GetAllStats(target,
                                                                       "debuffs")

                                local playerChr =
                                    tonumber(ply:GetNWInt("TBCCHR", 0))

                                local targetEffects = {}
                                targetEffects["baseDamage"] = self.DamageAmount

                                targetEffects["percentHeal"] = 0.75

                                targetEffects["ply"] = ply
                                targetEffects["target"] = target

                                local maxHP = target:GetNWInt("TBCMAXHP", 100)

                                if playerChr >= 4 then
                                    targetEffects["baseDamage"] = maxHP
                                    targetEffects["percentHeal"] = 1
                                end

                                if maxHP <= 300 then
                                    targetEffects["baseDamage"] = maxHP *
                                                                      targetEffects["percentHeal"]
                                end

                                targetEffects["ply"] = ply
                                targetEffects["target"] = target

                                targetEffects["userBuffsTable"] = userBuffsTable
                                targetEffects["userDebuffsTable"] =
                                    userDebuffsTable
                                targetEffects["targetBuffsTable"] =
                                    targetBuffsTable
                                targetEffects["targetDebuffsTable"] =
                                    targetDebuffsTable

                                targetEffects["baseDamage"] =
                                    targetEffects["baseDamage"] * (1 +
                                        ((HandleStatus(ply, userBuffsTable,
                                                       "increaseHeal",
                                                       targetEffects["baseDamage"]) -
                                            HandleStatus(ply, userDebuffsTable,
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

                                targetEffects["baseDamage"] =
                                    targetEffects["baseDamage"] +
                                        (((HandleStatus(ply, userBuffsTable,
                                                        "flatIncreaseHeal",
                                                        targetEffects["baseDamage"]) -
                                            HandleStatus(ply, userDebuffsTable,
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

                                targetEffects["baseDamage"] = math.ceil(
                                                                  targetEffects["baseDamage"])

                                HandleHealingEffects(ply, target, targetEffects)

                                local newHP =
                                    math.min(currentHP +
                                                 targetEffects["baseDamage"],
                                             maxHP)

                                target:SetNWInt("TBCHP", newHP)

                                local message =
                                    target:Name() .. " received " ..
                                        targetEffects["baseDamage"] ..
                                        " healing from " .. ply:Name() .. "!"
                                target:ChatPrint(message)
                                if target ~= ply then
                                    ply:ChatPrint(message)
                                end

                            end
                        end
                    end
                end
            end
        end
    end

    ply:LagCompensation(false)
end --

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

    local tmin = Vector(1, 1, 1) * -10
    local tmax = Vector(1, 1, 1) * 10

    self:ShootEffects()
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(-1.5, 0, 0))
    self.BaseClass.ShootEffects(self)

    if ply:IsPlayer() then
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

            local validEffectStatus = HealCheckValidity(ply, ply)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            inAFight = validEffectStatus["inAFight"]

            if inAFight then
                self:AnnounceAbility()

                local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
                if fight then
                else
                    return
                end

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

                local playerSide = (table.HasValue(fight.Side1, target) and
                                       "Side1") or
                                       (table.HasValue(fight.Side2, target) and
                                           "Side2")

                local playersInFight = {}
                for _, player in ipairs(fight[playerSide]) do
                    if IsValid(player) then
                        table.insert(playersInFight, player)
                    end
                end

                local lastPlayer = ply
                for _, target in ipairs(playersInFight) do
                    if IsValid(target) then -- Check if the player is valid
                        local currentHP = target:GetNWInt("TBCHP", 100)
                        if currentHP > 0 then
                            local userBuffsTable = GetAllStats(ply, "buffs")
                            local userDebuffsTable = GetAllStats(ply, "debuffs")
                            local targetBuffsTable =
                                GetAllStats(target, "buffs")
                            local targetDebuffsTable = GetAllStats(target,
                                                                   "debuffs")

                            local playerChr =
                                tonumber(ply:GetNWInt("TBCCHR", 0))

                            local targetEffects = {}
                            targetEffects["baseDamage"] = self.DamageAmount

                            targetEffects["percentHeal"] = 0.75

                            targetEffects["ply"] = ply
                            targetEffects["target"] = target

                            local maxHP = target:GetNWInt("TBCMAXHP", 100)

                            if playerChr >= 4 then
                                targetEffects["baseDamage"] = maxHP
                                targetEffects["percentHeal"] = 1
                            end

                            if maxHP <= 300 then
                                targetEffects["baseDamage"] = maxHP *
                                                                  targetEffects["percentHeal"]
                            end

                            targetEffects["userBuffsTable"] = userBuffsTable
                            targetEffects["userDebuffsTable"] = userDebuffsTable
                            targetEffects["targetBuffsTable"] = targetBuffsTable
                            targetEffects["targetDebuffsTable"] =
                                targetDebuffsTable

                            targetEffects["baseDamage"] =
                                targetEffects["baseDamage"] * (1 +
                                    ((HandleStatus(ply, userBuffsTable,
                                                   "increaseHeal",
                                                   targetEffects["baseDamage"]) -
                                        HandleStatus(ply, userDebuffsTable,
                                                     "decreaseHeal",
                                                     targetEffects["baseDamage"])) +
                                        (HandleStatus(target, targetBuffsTable,
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                            HandleStatus(target,
                                                         targetDebuffsTable,
                                                         "decreaseHealReceive",
                                                         targetEffects["baseDamage"]))))

                            targetEffects["baseDamage"] =
                                targetEffects["baseDamage"] +
                                    (((HandleStatus(ply, userBuffsTable,
                                                    "flatIncreaseHeal",
                                                    targetEffects["baseDamage"]) -
                                        HandleStatus(ply, userDebuffsTable,
                                                     "flatDecreaseHeal",
                                                     targetEffects["baseDamage"])) +
                                        (HandleStatus(target, targetBuffsTable,
                                                      "flatIncreaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                            HandleStatus(target,
                                                         targetDebuffsTable,
                                                         "flatDecreaseHealReceive",
                                                         targetEffects["baseDamage"]))))

                            targetEffects["baseDamage"] = math.ceil(
                                                              targetEffects["baseDamage"])

                            HandleHealingEffects(ply, target, targetEffects)

                            local newHP =
                                math.min(currentHP + targetEffects["baseDamage"],
                                         maxHP)

                            target:SetNWInt("TBCHP", newHP)

                            local message =
                                target:Name() .. " received " ..
                                    targetEffects["baseDamage"] ..
                                    " healing from " .. ply:Name() .. "!"
                            self:AnnounceMessage(message)

                            if ply ~= target then
                                lastPlayer = target
                            end
                        end
                    end
                end

                targetEffects["ply"] = ply
                targetEffects["target"] = lastPlayer

                HandleStatus(ply, targetEffects["userBuffsTable"],
                             "reactionBuff", "buff", targetEffects)

                self:EndAbility()
            else
                local tr = util.TraceLine({
                    start = self.Owner:EyePos(),
                    endpos = self.Owner:EyePos() + self.Owner:GetAimVector() *
                        1000,
                    filter = self.Owner
                })

                local aoeCenter = self.Owner:GetPos()

                local playersInArea = ents.FindInSphere(aoeCenter, 100)

                local mpCost = self.MPCost -- MP cost of the attack
                local attackerMP = ply:GetNWInt("TBCMP", 100)

                if attackerMP >= mpCost then
                    ply:SetNWInt("TBCMP", attackerMP - mpCost)
                else
                    ply:ChatPrint("Not enough MP to use this ability.")
                    ply:LagCompensation(false)
                    return
                end

                for _, target in ipairs(playersInArea) do
                    if IsValid(target) and CheckIfValidTBCEntity(target) then -- Check if the player is valid
                        local targetEngageSWEP
                        for _, weapon in ipairs(target:GetWeapons()) do
                            if weapon:GetClass() == "smti_engageswep" then
                                targetEngageSWEP = weapon
                                break
                            end
                        end

                        if targetEngageSWEP.FightId == self.FightId then
                            local currentHP = target:GetNWInt("TBCHP", 100)
                            if currentHP > 0 then
                                local userBuffsTable = GetAllStats(ply, "buffs")
                                local userDebuffsTable = GetAllStats(ply,
                                                                     "debuffs")
                                local targetBuffsTable = GetAllStats(target,
                                                                     "buffs")
                                local targetDebuffsTable = GetAllStats(target,
                                                                       "debuffs")

                                local playerChr =
                                    tonumber(ply:GetNWInt("TBCCHR", 0))

                                local targetEffects = {}
                                targetEffects["baseDamage"] = self.DamageAmount

                                targetEffects["percentHeal"] = 0.75

                                targetEffects["ply"] = ply
                                targetEffects["target"] = target

                                local maxHP = target:GetNWInt("TBCMAXHP", 100)

                                if playerChr >= 4 then
                                    targetEffects["baseDamage"] = maxHP
                                    targetEffects["percentHeal"] = 1
                                end

                                if maxHP <= 300 then
                                    targetEffects["baseDamage"] = maxHP *
                                                                      targetEffects["percentHeal"]
                                end

                                targetEffects["userBuffsTable"] = userBuffsTable
                                targetEffects["userDebuffsTable"] =
                                    userDebuffsTable
                                targetEffects["targetBuffsTable"] =
                                    targetBuffsTable
                                targetEffects["targetDebuffsTable"] =
                                    targetDebuffsTable

                                targetEffects["baseDamage"] =
                                    targetEffects["baseDamage"] * (1 +
                                        ((HandleStatus(ply, userBuffsTable,
                                                       "increaseHeal",
                                                       targetEffects["baseDamage"]) -
                                            HandleStatus(ply, userDebuffsTable,
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

                                targetEffects["baseDamage"] =
                                    targetEffects["baseDamage"] +
                                        (((HandleStatus(ply, userBuffsTable,
                                                        "flatIncreaseHeal",
                                                        targetEffects["baseDamage"]) -
                                            HandleStatus(ply, userDebuffsTable,
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

                                targetEffects["baseDamage"] = math.ceil(
                                                                  targetEffects["baseDamage"])

                                HandleHealingEffects(ply, target, targetEffects)

                                local newHP =
                                    math.min(currentHP +
                                                 targetEffects["baseDamage"],
                                             maxHP)

                                target:SetNWInt("TBCHP", newHP)

                                local message =
                                    target:Name() .. " received " ..
                                        targetEffects["baseDamage"] ..
                                        " healing from " .. ply:Name() .. "!"
                                target:ChatPrint(message)
                                if target ~= ply then
                                    ply:ChatPrint(message)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    ply:LagCompensation(false)
end --
