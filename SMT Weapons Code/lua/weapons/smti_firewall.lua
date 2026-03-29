include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Fire Wall"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Changes Fire affinity of an ally to Resist. Only works on allies who do not resist or are weak to Fire and lasts against 1 attack. If used on a target who is inflicted by Fire Break, dispel Fire Break and restore their affinity instead."
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
SWEP.MPCost = 16
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

            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local drain = util.JSONToTable(target:GetNW2String("drain"))
            local block = util.JSONToTable(target:GetNW2String("block"))
            local weak = util.JSONToTable(target:GetNW2String("weak"))
            local resist = util.JSONToTable(target:GetNW2String("resist"))
            local repel = util.JSONToTable(target:GetNW2String("repel"))

            local message = "... But nothing happened!"

            if targetDebuffsTable["Fire_Break"] then
                RemoveStat(target, "Fire_Break", "debuffs")
                targetDebuffsTable["Fire_Break"] = nil
                message = target:Name() .. "'s Fire Break is dispelled!"

            elseif not (table.HasValue(resist, "Fire") or
                (table.HasValue(resist, "Magic") and
                    table.HasValue(Affinities.Magic, "Fire")) or
                (table.HasValue(resist, "Physical") and
                    table.HasValue(Affinities.Physical, "Fire")) or
                table.HasValue(repel, "Fire") or
                (table.HasValue(repel, "Magic") and
                    table.HasValue(Affinities.Magic, "Fire")) or
                (table.HasValue(repel, "Physical") and
                    table.HasValue(Affinities.Physical, "Fire")) or
                table.HasValue(weak, "Fire") or
                (table.HasValue(weak, "Magic") and
                    table.HasValue(Affinities.Magic, "Fire")) or
                (table.HasValue(weak, "Physical") and
                    table.HasValue(Affinities.Physical, "Fire")) or
                table.HasValue(block, "Fire") or
                (table.HasValue(block, "Magic") and
                    table.HasValue(Affinities.Magic, "Fire")) or
                (table.HasValue(block, "Physical") and
                    table.HasValue(Affinities.Physical, "Fire")) or
                table.HasValue(drain, "Fire") or
                (table.HasValue(drain, "Magic") and
                    table.HasValue(Affinities.Magic, "Fire")) or
                (table.HasValue(drain, "Physical") and
                    table.HasValue(Affinities.Physical, "Fire"))) then

                targetBuffsTable["Fire_Wall"] = {stacks = 1}

                AssignStat(target, "Fire_Wall", targetBuffsTable["Fire_Wall"],
                           "buffs")

                message = target:Name() .. " received " .. self.PrintName ..
                              " from " .. ply:Name() .. "!"
            end

            self:AnnounceMessage(message)

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

    local tmin = Vector(1, 1, 1) * -10
    local tmax = Vector(1, 1, 1) * 10

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

        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

        local drain = util.JSONToTable(target:GetNW2String("drain"))
        local block = util.JSONToTable(target:GetNW2String("block"))
        local weak = util.JSONToTable(target:GetNW2String("weak"))
        local resist = util.JSONToTable(target:GetNW2String("resist"))
        local repel = util.JSONToTable(target:GetNW2String("repel"))

        local message = "... But nothing happened!"

        if targetDebuffsTable["Fire_Break"] then
            RemoveStat(target, "Fire_Break", "debuffs")
            targetDebuffsTable["Fire_Break"] = nil
            message = target:Name() .. "'s Fire Break is dispelled!"

        elseif not (table.HasValue(resist, "Fire") or
            (table.HasValue(resist, "Magic") and
                table.HasValue(Affinities.Magic, "Fire")) or
            (table.HasValue(resist, "Physical") and
                table.HasValue(Affinities.Physical, "Fire")) or
            table.HasValue(repel, "Fire") or
            (table.HasValue(repel, "Magic") and
                table.HasValue(Affinities.Magic, "Fire")) or
            (table.HasValue(repel, "Physical") and
                table.HasValue(Affinities.Physical, "Fire")) or
            table.HasValue(weak, "Fire") or
            (table.HasValue(weak, "Magic") and
                table.HasValue(Affinities.Magic, "Fire")) or
            (table.HasValue(weak, "Physical") and
                table.HasValue(Affinities.Physical, "Fire")) or
            table.HasValue(block, "Fire") or
            (table.HasValue(block, "Magic") and
                table.HasValue(Affinities.Magic, "Fire")) or
            (table.HasValue(block, "Physical") and
                table.HasValue(Affinities.Physical, "Fire")) or
            table.HasValue(drain, "Fire") or
            (table.HasValue(drain, "Magic") and
                table.HasValue(Affinities.Magic, "Fire")) or
            (table.HasValue(drain, "Physical") and
                table.HasValue(Affinities.Physical, "Fire"))) then

            targetBuffsTable["Fire_Wall"] = {stacks = 1}

            AssignStat(target, "Fire_Wall", targetBuffsTable["Fire_Wall"],
                       "buffs")

            message = target:Name() .. " received " .. self.PrintName ..
                          " from " .. ply:Name() .. "!"
        end

        self:AnnounceMessage(message)

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
