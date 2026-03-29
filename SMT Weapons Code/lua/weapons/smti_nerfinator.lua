include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Nerfin-ator"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "\n[STR 4] Apply Tarunda 1 on a single target. \n[DEX 4] Apply Sukunda 1 on a single target. \n[CHR 4] Apply Rakunda 1 on a single target."
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
SWEP.MPCost = 22
SWEP.Affinity = "Support"
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"
SWEP.Rarity = "Exclusive"

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

            targetEffects["targetDebuffsTable"] = GetAllStats(target, "debuffs")

            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))

            if playerStr >= 4 then
                if targetEffects["targetDebuffsTable"]["Tarunda"] then
                    targetEffects["targetDebuffsTable"]["Tarunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Tarunda"]
                                     .stacks + 1, 4)
                else
                    targetEffects["targetDebuffsTable"]["Tarunda"] = {
                        stacks = 1
                    }
                end

                local message = target:Name() .. " received Tarunda from " ..
                                    ply:Name() .. "! They now have " ..
                                    targetEffects["targetDebuffsTable"]["Tarunda"]
                                        .stacks .. " stacks!"

                AssignStat(target, "Tarunda",
                           targetEffects["targetDebuffsTable"]["Tarunda"],
                           "debuffs")

                targetEffects["debuff"] = "Tarunda"

                HandleStatus(target, GetAllStats(target, "buffs"),
                             "reactionDebuff", "debuff", targetEffects)

                self:AnnounceMessage(message)
            end

            if playerDex >= 4 then
                if targetEffects["targetDebuffsTable"]["Sukunda"] then
                    targetEffects["targetDebuffsTable"]["Sukunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Sukunda"]
                                     .stacks + 1, 4)
                else
                    targetEffects["targetDebuffsTable"]["Sukunda"] = {
                        stacks = 1
                    }
                end

                local message = target:Name() .. " received Sukunda from " ..
                                    ply:Name() .. "! They now have " ..
                                    targetEffects["targetDebuffsTable"]["Sukunda"]
                                        .stacks .. " stacks!"

                AssignStat(target, "Sukunda",
                           targetEffects["targetDebuffsTable"]["Sukunda"],
                           "debuffs")

                self:AnnounceMessage(message)
            end

            if playerChr >= 4 then
                if targetEffects["targetDebuffsTable"]["Rakunda"] then
                    targetEffects["targetDebuffsTable"]["Rakunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Rakunda"]
                                     .stacks + 1, 4)
                else
                    targetEffects["targetDebuffsTable"]["Rakunda"] = {
                        stacks = 1
                    }
                end

                local message = target:Name() .. " received Rakunda from " ..
                                    ply:Name() .. "! They now have " ..
                                    targetEffects["targetDebuffsTable"]["Rakunda"]
                                        .stacks .. " stacks!"

                AssignStat(target, "Rakunda",
                           targetEffects["targetDebuffsTable"]["Rakunda"],
                           "debuffs")

                targetEffects["debuff"] = "Rakunda"

                HandleStatus(target, GetAllStats(target, "buffs"),
                             "reactionDebuff", "debuff", targetEffects)

                self:AnnounceMessage(message)
            end

            if playerStr < 4 and playerDex < 4 and playerChr < 4 then
                ply:EmitSound("SMTImagine_WeaponsPack/fart.wav", 75, 100, 1,
                              CHAN_AUTO)
                local message = "But nothing happened..."
                self:AnnounceMessage(message)

            end

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

        targetEffects["targetDebuffsTable"] = GetAllStats(target, "debuffs")

        local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))

        if playerStr >= 4 then
            if targetEffects["targetDebuffsTable"]["Tarunda"] then
                targetEffects["targetDebuffsTable"]["Tarunda"].stacks =
                    math.min(targetEffects["targetDebuffsTable"]["Tarunda"]
                                 .stacks + 1, 4)
            else
                targetEffects["targetDebuffsTable"]["Tarunda"] = {stacks = 1}
            end

            local message = target:Name() .. " received Tarunda from " ..
                                ply:Name() .. "! They now have " ..
                                targetEffects["targetDebuffsTable"]["Tarunda"]
                                    .stacks .. " stacks!"

            AssignStat(target, "Tarunda",
                       targetEffects["targetDebuffsTable"]["Tarunda"], "debuffs")

            targetEffects["debuff"] = "Tarunda"

            HandleStatus(target, GetAllStats(target, "buffs"), "reactionDebuff",
                         "debuff", targetEffects)

            self:AnnounceMessage(message)
        end

        if playerDex >= 4 then
            if targetEffects["targetDebuffsTable"]["Sukunda"] then
                targetEffects["targetDebuffsTable"]["Sukunda"].stacks =
                    math.min(targetEffects["targetDebuffsTable"]["Sukunda"]
                                 .stacks + 1, 4)
            else
                targetEffects["targetDebuffsTable"]["Sukunda"] = {stacks = 1}
            end

            local message = target:Name() .. " received Sukunda from " ..
                                ply:Name() .. "! They now have " ..
                                targetEffects["targetDebuffsTable"]["Sukunda"]
                                    .stacks .. " stacks!"

            AssignStat(target, "Sukunda",
                       targetEffects["targetDebuffsTable"]["Sukunda"], "debuffs")

            self:AnnounceMessage(message)
        end

        if playerChr >= 4 then
            if targetEffects["targetDebuffsTable"]["Rakunda"] then
                targetEffects["targetDebuffsTable"]["Rakunda"].stacks =
                    math.min(targetEffects["targetDebuffsTable"]["Rakunda"]
                                 .stacks + 1, 4)
            else
                targetEffects["targetDebuffsTable"]["Rakunda"] = {stacks = 1}
            end

            local message = target:Name() .. " received Rakunda from " ..
                                ply:Name() .. "! They now have " ..
                                targetEffects["targetDebuffsTable"]["Rakunda"]
                                    .stacks .. " stacks!"

            AssignStat(target, "Rakunda",
                       targetEffects["targetDebuffsTable"]["Rakunda"], "debuffs")

            targetEffects["debuff"] = "Rakunda"

            HandleStatus(target, GetAllStats(target, "buffs"), "reactionDebuff",
                         "debuff", targetEffects)

            self:AnnounceMessage(message)
        end

        if playerStr < 4 and playerDex < 4 and playerChr < 4 then
            ply:EmitSound("SMTImagine_WeaponsPack/fart.wav", 75, 100, 1,
                          CHAN_AUTO)
            local message = "But nothing happened..."
            self:AnnounceMessage(message)
        end

        self:EndAbility()
    end

    ply:LagCompensation(false)
end --
