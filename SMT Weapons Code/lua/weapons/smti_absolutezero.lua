include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Absolute Zero"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Maya must have two Ice-Type skills to be able to use this ability (Persona skills applicable). Maya hits all enemies twice, dealing 30 Ice damage in the first hit and 30 Ice damage in the second. The First hit has a (Luck + DEX)% chance to kill any enemy who is frozen."
SWEP.Instructions = ""
SWEP.Category = "SMT Magic Skills"
SWEP.SpawnMenuIcon = "materials/entities/smti_absolutezero.png"

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

SWEP.DamageAmount = 30
SWEP.MPCost = 25
SWEP.Affinity = "Dual"
SWEP.Targets = "aoe"
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

if SERVER then util.AddNetworkString("UpdateTargetedPlayers") end

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)

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

    if SERVER then
        local target = self.Owner:GetEyeTrace().Entity

        HandleSkill(ply, target, self.PrintName:gsub("%s+", "_")
                        :gsub("[%(%)]", ""):gsub("-", "_"))
    end

    ply:LagCompensation(false)end -- 
