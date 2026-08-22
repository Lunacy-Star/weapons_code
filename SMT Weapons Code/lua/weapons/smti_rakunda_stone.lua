include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Rakunda Stone"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "A stone that increases -nda debuff properties of a user. Decreases Rakukaja count by -1. Every Rakunda increases received damage by 0.1x. Minimum Rakukaja count = -4."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Items"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 3
SWEP.Primary.DefaultClip = 3
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

SWEP.DamageAmount = 0
SWEP.Affinity = "Support"
SWEP.WeaponType = "Support"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Item"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.FallsBackToSelf = true
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

    if true then
        local target = (tr.Hit and CheckIfValidTBCEntity(tr.Entity)) and tr.Entity or ply
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

            self:AnnounceAbility()
            if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
            timer.Simple(TBC_CAST_DELAY, function()
                if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            local targetDebuffsTable = GetAllStats(target, "debuffs")
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            if targetEffects["targetDebuffsTable"]["Rakunda"] then
                targetEffects["targetDebuffsTable"]["Rakunda"].stacks =
                    math.min(targetEffects["targetDebuffsTable"]["Rakunda"]
                                 .stacks + 1, 4)
            else
                targetEffects["targetDebuffsTable"]["Rakunda"] = {stacks = 1}
            end

            AssignStat(target, "Rakunda",
                       targetEffects["targetDebuffsTable"]["Rakunda"], "debuffs")

            targetEffects["debuff"] = "Rakunda"

            HandleStatus(target, GetAllStats(target, "buffs"), "reactionDebuff",
                         "debuff", targetEffects)

            local message = target:Name() .. " received Rakunda from " ..
                                ply:Name() .. "! They now have " ..
                                targetEffects["targetDebuffsTable"]["Rakunda"]
                                    .stacks .. " stacks!"

            self:AnnounceMessage(message)

            self:EndAbility()
            end)
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
