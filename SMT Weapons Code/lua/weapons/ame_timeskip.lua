include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Time Skip"
SWEP.Author = "ME"
SWEP.Contact = ""
SWEP.Purpose = "Interrupt the turn of anyone and skip it."
SWEP.Instructions = ""
SWEP.Category = "Ame Support"

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
SWEP.MPCost = 50
SWEP.Affinity = "Support"
SWEP.Rarity = "Exclusive"
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

function SWEP:Initialize() self.CanUseAbility = true end

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

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

    if SERVER then

        local inAFight = true

        local validEffectStatus = HealCheckValidity(ply, target)

        if not validEffectStatus then
            ply:LagCompensation(false)
            return
        end

        inAFight = validEffectStatus["inAFight"]

        self:AnnounceAbility()

        if not self:AbilityRollNumber(0, target) then
            ply:LagCompensation(false)
            return
        end

        local engageWeapon = self.Owner:GetWeapon("smti_engageswep")
        if not IsValid(engageWeapon) then
            ply:ChatPrint("Target does not have an engage swep.")
            ply:LagCompensation(false)
            return
        end

        if engageWeapon.FightId ~= self.FightId then
            ply:ChatPrint("Target is not in your fight.")
            ply:LagCompensation(false)
            return
        end

        self:AnnounceMessage(ply:Name() ..
                                 " manipulates time to skip the current turn!")
        engageWeapon:NextTurn(false)
    end

    ply:LagCompensation(false)

end--
