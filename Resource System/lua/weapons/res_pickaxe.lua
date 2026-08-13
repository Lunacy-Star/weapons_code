SWEP.PrintName = "Pick Axe"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose = "Mine something."
SWEP.Instructions = ""
SWEP.Category = "Resource Weapons"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Weight = 1
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false

SWEP.Slot = 1
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = "models/weapons/smti_1hsword1_v.mdl" -- Viewmodel path
SWEP.WorldModel = "models/weapons/w_crowbar.mdl" -- Worldmodel path
SWEP.UseHands = true

SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

function SWEP:Initialize()
    self:SetHoldType("melee")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 65

    local tmin = Vector(1, 1, 1) * -10
    local tmax = Vector(1, 1, 1) * 10

    local tr =
        util.TraceHull(
        {
            start = ShootPos,
            endpos = ShootEnd,
            filter = ply,
            mask = MASK_SHOT_HULL,
            mins = tmin,
            maxs = tmax
        }
    )

    if not IsValid(tr.Entity) then
        tr =
            util.TraceLine(
            {
                start = ShootPos,
                endpos = ShootEnd,
                filter = ply,
                mask = MASK_SHOT_HULL
            }
        )
    end

    if tr.Hit then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        ply:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound("Weapon_Crowbar.Melee_Hit")
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        ply:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound("Weapon_Crowbar.Single")
    end

    if tr.Hit then
        local target = tr.Entity
        local dmg = DamageInfo()
        dmg:SetDamage(5)
        dmg:SetAttacker(ply)
        dmg:SetInflictor(self)
        dmg:SetDamageForce(ply:GetAimVector())
        dmg:SetDamagePosition(target:GetPos())
        dmg:SetDamageType(DMG_CLUB)
        target:DispatchTraceAttack(dmg, ShootPos + ply:EyeAngles():Right() * -5, ShootEnd)
    end

    ply:LagCompensation(false)
end
