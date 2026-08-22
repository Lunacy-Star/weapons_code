include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Hyper Candy"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "A candy containing an unstable amount of mana condensed in its small form. It loses its potency when within large quantities. Ammo Stack = 1. Effect: Can only be used on self. Recovers target's MP by 50% of their Max MP."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Items"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
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

SWEP.DamageAmount = 100
SWEP.Affinity = "Support"
SWEP.IsHeal = true
SWEP.WeaponType = "Curative"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Item"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.PrimarySelfOnly = true
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + TBC_CAST_DELAY)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

    local tmin = Vector(1, 1, 1) * -15
    local tmax = Vector(1, 1, 1) * 15

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
        if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
        timer.Simple(TBC_CAST_DELAY, function()
            if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

        local currentHP = target:GetNWInt("TBCHP", 100)

        if currentHP <= 0 then
            local message =
                "You can't regenerate the MP of a target that's dead."
            ply:ChatPrint(message)
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local targetEffects = {}
        local maxMP = target:GetNWInt("TBCMAXMP", 100)
        local currentMP = target:GetNWInt("TBCMP", 100)

        targetEffects["baseDamage"] = maxMP * 0.50

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        local newMP = math.min(currentMP + targetEffects["baseDamage"], maxMP)

        target:SetNWInt("TBCMP", newMP)

        local message = target:Name() .. " received " ..
                            targetEffects["baseDamage"] .. " MP from " ..
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
                          targetEffects["baseDamage"] .. " MP!"
            ply:ChatPrint(message)
        end
        self:TakePrimaryAmmo(1)

        end)
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
