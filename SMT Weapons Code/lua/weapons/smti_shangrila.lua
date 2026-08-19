include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Shangri-La"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "This handgun acquired its nickname after it was said that one shot could send you to paradise. With its attractive design and ease of use, this prototype is popular with both high-ranking officials and technical engineers. On hit, 10% Charm chance. \n[DEX 4] Technique is 20 instead. \n[CHR 4] User's Ruin attacks deal 5 bonus damage."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Ranged Weapons"
SWEP.SpawnMenuIcon = "materials/entities/smti_sweeper.png"

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

SWEP.DamageAmount = 45
SWEP.Tech = 15
SWEP.Affinity = "Gun"
SWEP.Targets = "single"
SWEP.WeaponType = "Gun"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"
SWEP.BuffType = "buffs"

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
            HandleSkill(ply, target, self.PrintName:gsub("%s+", "_")
                            :gsub("[%(%)]", ""):gsub("-", "_"))
        end
    end

    ply:LagCompensation(false)
end --
