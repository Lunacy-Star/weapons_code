include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Ointment"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "An easily applicable and small form of first aid. Ammo Stack = 8. Effect: Heals target for 40 HP."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Items"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 8
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Ammo = "items"
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

SWEP.Slot = 3
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/smti_handgun1_v.mdl"
SWEP.WorldModel = "models/weapons/default/w_357.mdl"

SWEP.UseHands = true

SWEP.SetHoldType = "revolver"

SWEP.DamageAmount = 40
SWEP.Affinity = "Support"
SWEP.IsHeal = true
SWEP.WeaponType = "Curative"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Item"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)

    if (not self:CanPrimaryAttack()) then return end

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

            local validEffectStatus = HealCheckValidity(ply, target)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            inAFight = validEffectStatus["inAFight"]

            self:AnnounceAbility()

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

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            local maxHP = target:GetNWInt("TBCMAXHP", 100)

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
            if inAFight then
                self:AnnounceMessage(message)

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                self:EndAbility()
            else
                message = target:Name() .. " received " ..
                              targetEffects["baseDamage"] .. " healing!"
                ply:ChatPrint(message)
                message = ply:Name() .. " healed you for " ..
                              targetEffects["baseDamage"] .. "!"
                target:ChatPrint(message)
            end
        end
        self:TakePrimaryAmmo(1)
    end

    ply:LagCompensation(false)

    if SERVER then
        local currentAmmo = self:Clip1()
        if currentAmmo <= 0 then self:Remove() end
    end
end --

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

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
        local inAFight = true

        local validEffectStatus = HealCheckValidity(ply, target)

        if not validEffectStatus then
            ply:LagCompensation(false)
            return
        end

        inAFight = validEffectStatus["inAFight"]

        self:AnnounceAbility()

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

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        local maxHP = target:GetNWInt("TBCMAXHP", 100)

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["baseDamage"] = targetEffects["baseDamage"] * (1 +
                                          ((HandleStatus(ply, userBuffsTable,
                                                         "increaseHeal",
                                                         targetEffects["baseDamage"],
                                                         targetEffects) -
                                              HandleStatus(ply,
                                                           userDebuffsTable,
                                                           "decreaseHeal",
                                                           targetEffects["baseDamage"],
                                                           targetEffects)) +
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
                            ply:Name() .. "!"
        if inAFight then
            self:AnnounceMessage(message)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            self:EndAbility()
        else
            message = target:Name() .. " received " ..
                          targetEffects["baseDamage"] .. " healing!"
            ply:ChatPrint(message)
        end
        self:TakePrimaryAmmo(1)
    end

    ply:LagCompensation(false)

    if SERVER then
        local currentAmmo = self:Clip1()
        if currentAmmo <= 0 then self:Remove() end
    end

end --

function SWEP:PickUpFunction(ply, clip)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local ammoType = "items"
    local currentAmmo = self:Clip1()
    local maxAmmo = self.Primary.ClipSize

    local ammoToAdd = math.min(currentAmmo + clip, self.Primary.DefaultClip)
    self:SetClip1(ammoToAdd)
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}

    self.AmmoDisplay.Draw = true

    if self.Primary.ClipSize > 0 then
        self.AmmoDisplay.PrimaryClip = self:Clip1()
        self.AmmoDisplay.PrimaryAmmo = self:Ammo1()
    end
    if self.Secondary.ClipSize > 0 then
        self.AmmoDisplay.SecondaryAmmo = self:Ammo2()
    end

    self.AmmoHere = self.AmmoDisplay.PrimaryClip
    return self.AmmoDisplay
end

function SWEP:ShowAmmo(ply, weapon)
    local weapon = ply:GetWeapon(weapon)
    local currentAmmo = weapon:Clip1()

    return currentAmmo
end
