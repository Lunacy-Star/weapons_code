include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Power Charge"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "[Boss] [Support] (1 MP)\nMultiplies next turn's physical attack values by 1.4x. Cannot stack."
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
SWEP.MPCost = 1
SWEP.PhaseThreshold = 1500
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
    self:SetNextPrimaryFire(CurTime() + 0.4)

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
        if currentHP > self.PhaseThreshold then
            ply:ChatPrint("Power Charge is not available yet.")
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

        local mpCost = self.MPCost
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

        self:AnnounceAbility()

        userBuffsTable["Power_Charge_Boss"] = {stacks = 1}

        AssignStat(ply, "Power_Charge_Boss", userBuffsTable["Power_Charge_Boss"],
                   "buffs")

        self:AnnounceMessage(ply:Name() ..
                                 " charges power into their next physical attack!")

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
