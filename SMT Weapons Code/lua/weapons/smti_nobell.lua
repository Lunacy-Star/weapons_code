include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Didn't Hear No Bell"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "When cast, attacks dealt during the incoming enemy turn cycle deal 20% less damage to Kanji's party if their attacks do not involve Kanji as a target (Affects total damage, not base damage). Kanji is automatically Power Charged at the start of his next turn."
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
SWEP.MPCost = 30
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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) then
                ply:LagCompensation(false)
                return
            end

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if fight then
            else
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

            local userBuffsTable = GetAllStats(ply, "buffs")

            userBuffsTable["Power_Charge"] = {stacks = 1}

            AssignStat(ply, "Power_Charge", userBuffsTable["Power_Charge"],
                       "buffs")

            self:AnnounceMessage(ply:Name() .. " is now Power Charged!")

            local playerSide =
                (table.HasValue(fight.Side1, target) and "Side1") or
                    (table.HasValue(fight.Side2, target) and "Side2")

            local playersInFight = {}
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    local currentHP = player:GetNWInt("TBCHP", 100)
                    if currentHP > 0 then
                        table.insert(playersInFight, player)
                    end
                end
            end

            local lastPlayer = ply
            for _, player in ipairs(playersInFight) do
                local buffsTable = GetAllStats(player, "buffs")

                buffsTable["Didnt_Hear_No_Bell"] = {
                    stacks = 1,
                    caster = ply:UserID(),
                    durationCycle = 1
                }

                AssignStat(player, "Didnt_Hear_No_Bell",
                           buffsTable["Didnt_Hear_No_Bell"], "buffs")

                local message = player:Name() .. " didn't hear no bell from " ..
                                    ply:Name() .. "!"

                self:AnnounceMessage(message)

                if ply ~= player then lastPlayer = target end
            end

            targetEffects["ply"] = ply
            targetEffects["target"] = lastPlayer

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

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

    if ply:IsPlayer() then
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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) then
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if fight then
            else
                return
            end

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

            local userBuffsTable = GetAllStats(ply, "buffs")

            userBuffsTable["Power_Charge"] = {stacks = 1}

            AssignStat(ply, "Power_Charge", userBuffsTable["Power_Charge"],
                       "buffs")

            self:AnnounceMessage(ply:Name() .. " is now Power Charged!")

            local playerSide =
                (table.HasValue(fight.Side1, target) and "Side1") or
                    (table.HasValue(fight.Side2, target) and "Side2")

            local playersInFight = {}
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    local currentHP = player:GetNWInt("TBCHP", 100)
                    if currentHP > 0 then
                        table.insert(playersInFight, player)
                    end
                end
            end

            local lastPlayer = ply
            for _, player in ipairs(playersInFight) do
                local buffsTable = GetAllStats(ply, "buffs")

                buffsTable["Didnt_Hear_No_Bell"] = {
                    stacks = 1,
                    caster = ply:UserID(),
                    durationCycle = 1
                }
                AssignStat(player, "Didnt_Hear_No_Bell",
                           buffsTable["Didnt_Hear_No_Bell"], "buffs")

                local message = player:Name() .. " didn't hear no bell from " ..
                                    ply:Name() .. "!"

                self:AnnounceMessage(message)

                if ply ~= player then lastPlayer = target end
            end

            targetEffects["ply"] = ply
            targetEffects["target"] = lastPlayer

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --
