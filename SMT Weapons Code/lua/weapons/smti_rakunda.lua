include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Rakunda"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Decreases Rakukaja count by -1. Every Rakunda increases received damage by 0.1x. Minimum Rakukaja count = -4."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Skills"
SWEP.SpawnMenuIcon = "materials/entities/smti_rakunda.png"

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
SWEP.MPCost = 8
SWEP.Affinity = "Support"
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.FallsBackToSelf = true
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + TBC_CAST_DELAY)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

    local tmin = Vector(1, 1, 1) * -15
    local tmax = Vector(1, 1, 1) * 15

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

    if true then
        local target = (tr.Hit and CheckIfValidTBCEntity(tr.Entity)) and tr.Entity or ply
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
            if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
            timer.Simple(TBC_CAST_DELAY, function()
                if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

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

            targetEffects["targetDebuffsTable"] = GetAllStats(target, "debuffs")

            if targetEffects["targetDebuffsTable"]["Rakunda"] then
                targetEffects["targetDebuffsTable"]["Rakunda"].stacks =
                    math.min(targetEffects["targetDebuffsTable"]["Rakunda"]
                                 .stacks + 1, 4)
            else
                targetEffects["targetDebuffsTable"]["Rakunda"] = {stacks = 1}
            end

            AssignStat(target, "Rakunda",
                       targetEffects["targetDebuffsTable"]["Rakunda"], "debuffs")

            targetEffects["debuff"] = "Rakunda"

            HandleStatus(target, GetAllStats(target, "buffs"), "reactionDebuff",
                         "debuff", targetEffects)

            local message =
                target:Name() .. " received Rakunda! They now have " ..
                    targetEffects["targetDebuffsTable"]["Rakunda"].stacks ..
                    " stacks!"

            self:AnnounceMessage(message)

            self:EndAbility()
            end)
        end
    end

    ply:LagCompensation(false)
end --

