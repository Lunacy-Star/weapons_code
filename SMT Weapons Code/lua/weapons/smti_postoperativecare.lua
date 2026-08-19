include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Postoperative Care"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Cast +1 Rakukaja on self or an ally. If the target's HP is under 50% of their own max base HP, they are healed for 10% of Marian's Max HP."
SWEP.Instructions = ""
SWEP.Category = "SMT Combat Tactics"

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

SWEP.DamageAmount = 0
SWEP.Affinity = "Support"
SWEP.IsHeal = true
SWEP.WeaponType = "Combat Tactic"
SWEP.SlotsTaking = 0
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

function SWEP:Initialize() self.CanUseAbility = true end

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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
                ply:LagCompensation(false)
                return
            end

            local currentHP = target:GetNWInt("TBCHP", 100)
            local maxHP = target:GetNWInt("TBCMAXHP", 100)

            if currentHP <= 0 then
                local message = "You can't use this on a target that's dead."
                ply:ChatPrint(message)
                ply:LagCompensation(false)
                return
            end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            if targetBuffsTable["Rakukaja"] then
                targetBuffsTable["Rakukaja"].stacks = math.min(
                                                          targetBuffsTable["Rakukaja"]
                                                              .stacks + 1, 4)
            else
                targetBuffsTable["Rakukaja"] = {stacks = 1}
            end

            AssignStat(target, "Rakukaja", targetBuffsTable["Rakukaja"], "buffs")

            local message = target:Name() ..
                                " received Rakukaja! They now have " ..
                                targetBuffsTable["Rakukaja"].stacks ..
                                " stacks!"
            self:AnnounceMessage(message)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            if currentHP <= (maxHP * 0.5) then
                local plyHP = ply:GetNWInt("TBCMAXHP", 100)

                targetEffects["percentHeal"] = 0.1

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                targetEffects["baseDamage"] = plyHP *
                                                  targetEffects["percentHeal"]

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                targetEffects["userBuffsTable"] = userBuffsTable
                targetEffects["userDebuffsTable"] = userDebuffsTable
                targetEffects["targetBuffsTable"] = targetBuffsTable
                targetEffects["targetDebuffsTable"] = targetDebuffsTable

                targetEffects["baseDamage"] =
                    targetEffects["baseDamage"] * (1 +
                        ((HandleStatus(ply, userBuffsTable, "increaseHeal",
                                       targetEffects["baseDamage"],
                                       targetEffects) -
                            HandleStatus(ply, userDebuffsTable, "decreaseHeal",
                                         targetEffects["baseDamage"],
                                         targetEffects)) +
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
                                    " healing from " .. ply:Name() .. "!"
                self:AnnounceMessage(message)

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                HandleStatus(ply, targetEffects["userBuffsTable"],
                             "reactionBuff", "buff", targetEffects)
            end

            RemoveStat(ply, "One_More", "buffs")
            HandleStatus(ply, userBuffsTable, "comtacReaction", false,
                         targetEffects)

            self:EndAbility()
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
        if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
            not TargetCheckValidity(ply, target, true) then
            ply:LagCompensation(false)
            return
        end

        local currentHP = target:GetNWInt("TBCHP", 100)
        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        if currentHP <= 0 then
            local message = "You can't use this on a target that's dead."
            ply:ChatPrint(message)
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if targetBuffsTable["Rakukaja"] then
            targetBuffsTable["Rakukaja"].stacks = math.min(
                                                      targetBuffsTable["Rakukaja"]
                                                          .stacks + 1, 4)
        else
            targetBuffsTable["Rakukaja"] = {stacks = 1}
        end

        AssignStat(target, "Rakukaja", targetBuffsTable["Rakukaja"], "buffs")

        local message = target:Name() .. " received Rakukaja! They now have " ..
                            targetBuffsTable["Rakukaja"].stacks .. " stacks!"
        self:AnnounceMessage(message)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                     "buff", targetEffects)

        if currentHP <= (maxHP * 0.5) then
            local plyHP = ply:GetNWInt("TBCMAXHP", 100)

            targetEffects["percentHeal"] = 0.1

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["baseDamage"] = plyHP * targetEffects["percentHeal"]

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] * (1 +
                    ((HandleStatus(ply, userBuffsTable, "increaseHeal",
                                   targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(ply, userDebuffsTable, "decreaseHeal",
                                     targetEffects["baseDamage"], targetEffects)) +
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
                        HandleStatus(ply, userDebuffsTable, "flatDecreaseHeal",
                                     targetEffects["baseDamage"])) +
                        (HandleStatus(target, targetBuffsTable,
                                      "flatIncreaseHealReceive",
                                      targetEffects["baseDamage"]) -
                            HandleStatus(target, targetDebuffsTable,
                                         "flatDecreaseHealReceive",
                                         targetEffects["baseDamage"]))))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            HandleHealingEffects(ply, target, targetEffects)

            local newHP = math.min(currentHP + targetEffects["baseDamage"],
                                   maxHP)

            target:SetNWInt("TBCHP", newHP)

            local message = target:Name() .. " received " ..
                                targetEffects["baseDamage"] .. " healing from " ..
                                ply:Name() .. "!"
            self:AnnounceMessage(message)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)
        end

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
