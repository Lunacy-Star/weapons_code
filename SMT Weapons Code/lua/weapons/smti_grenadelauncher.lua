include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Grenade Launcher"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "I hope you blow up like Concord. Always deals AOE Fire damage. \n[STR 4] Damage is 40 instead. \n[DEX 4] Technique is 0 instead. \n[CHR 4] +2 Luck."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Ranged Weapons"
SWEP.SpawnMenuIcon = "materials/entities/smti_grenadelauncher.png"

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

SWEP.DamageAmount = 35
SWEP.Tech = -5
SWEP.Affinity = "Gun"
SWEP.Targets = "aoe"
SWEP.WeaponType = "Gun"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

function SWEP:Initialize() self.LuckModified = false end

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
            HandleSkill(ply, target,
                        self.PrintName:gsub("%s+", "_"):gsub("[%(%)]", ""))
        end
    end

    ply:LagCompensation(false)end --

function SWEP:Deploy()
    if SERVER then
        local playerChr = tonumber(self:GetOwner():GetNWInt("TBCCHR", 0))

        if playerChr >= 4 and not self.LuckModified then
            local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
            self.Owner:SetNWInt("TBCLuck", playerLuck + 2)
            self.LuckModified = true
        end
    end
end

function SWEP:Equip(ply)
    if SERVER then
        timer.Create(ply:Name() .. self.PrintName, 0.2, 1, function()
            local playerChr = tonumber(self:GetOwner():GetNWInt("TBCCHR", 0))

            if playerChr >= 4 and not self.LuckModified then
                local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
                self.Owner:SetNWInt("TBCLuck", playerLuck + 2)
                self.LuckModified = true
            elseif playerChr < 4 and self.LuckModified then
                local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
                self.Owner:SetNWInt("TBCLuck", playerLuck - 2)
                self.LuckModified = false
            end
        end)
    end
end

function SWEP:DropFunction()
    if SERVER and IsValid(self.Owner) then
        if self.LuckModified then
            local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
            self.Owner:SetNWInt("TBCLuck", playerLuck - 2)
        end
    end
end
