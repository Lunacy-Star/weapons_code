include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Quick Rakukaja"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose = "Gain Rakukaja +1 for self."
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
SWEP.WeaponType = "Combat Tactic"
SWEP.SlotsTaking = 0
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.PrimarySelfOnly = true
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

function SWEP:Initialize() self.CanUseAbility = true end

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + TBC_CAST_DELAY)

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

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        if not userBuffsTable["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            ply:LagCompensation(false)
            return
        end

        self:AnnounceAbility()
        if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
        timer.Simple(TBC_CAST_DELAY, function()
            if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

        if userBuffsTable["Rakukaja"] then
            userBuffsTable["Rakukaja"].stacks = math.min(
                                                     userBuffsTable["Rakukaja"]
                                                         .stacks + 1, 4)
        else
            userBuffsTable["Rakukaja"] = {stacks = 1}
        end

        AssignStat(ply, "Rakukaja", userBuffsTable["Rakukaja"], "buffs")

        local message = ply:Name() .. " received Rakukaja! They now have " ..
                            userBuffsTable["Rakukaja"].stacks .. " stacks!"

        self:AnnounceMessage(message)

        local targetEffects = {}
        targetEffects["ply"] = ply
        targetEffects["target"] = ply

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false,
                     targetEffects)

        self:EndAbility()
        end)
    end

    ply:LagCompensation(false)
end --
