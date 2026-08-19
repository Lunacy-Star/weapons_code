include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Hero From Junes"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose = "Sukukaja +1 to ally or self."
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
SWEP.Affinity = "Support"
SWEP.WeaponType = "Combat Tactic"
SWEP.SlotsTaking = 0
SWEP.SlotType = "Equipment"

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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
                ply:LagCompensation(false)
                return
            end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            local targetEffects = {}

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            if not targetEffects["userBuffsTable"]["One_More"] then
                ply:ChatPrint("You cannot use Combat Tactics without One More.")
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()

            local targetBuffsTable = GetAllStats(target, "buffs")

            if targetBuffsTable["Sukukaja"] then
                targetBuffsTable["Sukukaja"].stacks = math.min(
                                                          targetBuffsTable["Sukukaja"]
                                                              .stacks + 1, 4)
            else
                targetBuffsTable["Sukukaja"] = {stacks = 1}
            end

            AssignStat(target, "Sukukaja", targetBuffsTable["Sukukaja"], "buffs")

            local message = target:Name() .. " received Sukukaja from " ..
                                ply:Name() .. "! They now have " ..
                                targetBuffsTable["Sukukaja"].stacks ..
                                " stacks!"

            self:AnnounceMessage(message)

            RemoveStat(ply, "One_More", "buffs")
            HandleStatus(ply, userBuffsTable, "comtacReaction", false,
                         targetEffects)

            targetEffects["ply"] = ply
            targetEffects["target"] = target
            targetEffects["buff"] = "Sukukaja"

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)
            HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                         targetEffects)

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 1)

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

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")

        local targetEffects = {}

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            ply:LagCompensation(false)
            return
        end

        local targetBuffsTable = GetAllStats(target, "buffs")

        if targetBuffsTable["Sukukaja"] then
            targetBuffsTable["Sukukaja"].stacks = math.min(
                                                      targetBuffsTable["Sukukaja"]
                                                          .stacks + 1, 4)
        else
            targetBuffsTable["Sukukaja"] = {stacks = 1}
        end

        AssignStat(target, "Sukukaja", targetBuffsTable["Sukukaja"], "buffs")

        local message = target:Name() .. " received " .. self.PrintName ..
                            "! They now have " ..
                            targetBuffsTable["Sukukaja"].stacks .. " stacks!"

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

        targetEffects["buff"] = "Sukukaja"

        HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                     targetEffects)

        self:AnnounceMessage(message)

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
