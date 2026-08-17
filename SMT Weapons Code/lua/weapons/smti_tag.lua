include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Tag"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose = "Skips a turn without actually using one."
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

SWEP.DamageAmount = 0
SWEP.MPCost = 2
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
SWEP.FreeNextTurn = TBCWeaponMetatable.FreeNextTurn

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

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

        self:AnnounceAbility()

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

        self:AnnounceMessage(ply:Name() ..
                                  " uses Tag to skip their turn for free!")

        self:FreeNextTurn()
    end

    ply:LagCompensation(false)
end --
