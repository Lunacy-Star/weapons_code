include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Desperation"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "[Hydra] [Desperation: 200 HP or lower]\nRemove all -kunda debuffs. Apply Mind Charge (Boss) to self. Apply +1 Tarukaja to self."
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
SWEP.PhaseThreshold = 200
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

local KundaDebuffs = {"Tarunda", "Rakunda", "Sukunda", "Heal_Dampener", "Lydia"}

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
        if currentHP > self.PhaseThreshold then
            ply:ChatPrint("Desperation is not available yet.")
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

        for _, debuffName in ipairs(KundaDebuffs) do
            if userDebuffsTable[debuffName] then
                RemoveStat(ply, debuffName, "debuffs")
            end
        end

        userBuffsTable["Mind_Charge_Boss"] = {stacks = 1}
        AssignStat(ply, "Mind_Charge_Boss", userBuffsTable["Mind_Charge_Boss"],
                   "buffs")

        if userBuffsTable["Tarukaja"] then
            userBuffsTable["Tarukaja"].stacks =
                math.min(userBuffsTable["Tarukaja"].stacks + 1, 4)
        else
            userBuffsTable["Tarukaja"] = {stacks = 1}
        end
        AssignStat(ply, "Tarukaja", userBuffsTable["Tarukaja"], "buffs")

        self:AnnounceMessage(ply:Name() ..
                                 " enters Desperation! -kunda debuffs cleansed, Mind Charge and Tarukaja gained!")

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
