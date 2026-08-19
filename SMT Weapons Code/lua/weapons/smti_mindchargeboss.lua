include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Mind Charge"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "[Boss] [Support] [Phase 3: 40% of Max HP or lower]\nMultiplies next turn's magical attack values by 1.4x. Cannot stack."
SWEP.Instructions = ""
SWEP.Category = "SMT Boss Skills"

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
SWEP.PhaseThreshold = 0.4
SWEP.Affinity = "Support"
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

    self:ShootEffects()
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(-1.5, 0, 0))
    self.BaseClass.ShootEffects(self)

    if SERVER and IsValid(ply) then
        if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) then
            ply:LagCompensation(false)
            return
        end

        local currentHP = ply:GetNWInt("TBCHP", 0)
        local maxHP = ply:GetNWInt("TBCMAXHP", 1)
        if currentHP > maxHP * self.PhaseThreshold then
            ply:ChatPrint("Mind Charge is not available yet.")
            ply:LagCompensation(false)
            return
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local status = HandleStatus(ply, userDebuffsTable, "canUseSkills",
                                    true, {})

        if not status then
            ply:LagCompensation(false)
            return
        end

        self:AnnounceAbility()

        userBuffsTable["Mind_Charge_Boss"] = {stacks = 1}

        AssignStat(ply, "Mind_Charge_Boss", userBuffsTable["Mind_Charge_Boss"],
                   "buffs")

        self:AnnounceMessage(ply:Name() ..
                                 " charges power into their next magical attack!")

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
