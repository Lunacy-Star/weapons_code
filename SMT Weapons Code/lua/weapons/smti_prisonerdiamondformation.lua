include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Prisoner Diamond Formation"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Can be used when a single enemy is alive. The PMC contractor calls out for their party to surround the target. All PMCs can no longer receive -nda debuffs past -2 until the end of battle."
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
SWEP.Affinity = "Support"
SWEP.WeaponType = "Physical Skill"
SWEP.Rarity = "Exclusive"
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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
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

            local playerSide = (table.HasValue(fight.Side1, ply) and "Side1") or
                                   (table.HasValue(fight.Side2, ply) and "Side2")

            local enemySide = ""

            if playerSide == "Side1" then
                enemySide = "Side2"
            else
                enemySide = "Side1"
            end

            local aliveTargets = 0
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    if player:GetNWInt("TBCHP", 100) > 0 then
                        aliveTargets = aliveTargets + 1
                    end
                end
            end

            if aliveTargets > 1 then
                ply:ChatPrint(
                    "You can only use this when there is a single enemy alive.")
                ply:LagCompensation(false)
                return
            end

            local playersInFight = {}
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    if player:GetNWInt("TBCHP", 100) > 0 then
                        table.insert(playersInFight, player)
                    end
                end
            end

            local debuffsToRemove = Ailments_Statuses["Dekunda"]
            local lastPlayer = ply
            for _, player in ipairs(playersInFight) do
                if IsValid(player) then -- Check if the player is valid
                    local buffsTable = GetAllStats(player, "buffs")
                    local debuffsTable = GetAllStats(player, "debuffs")

                    buffsTable["Prisoner_Diamond_Formation"] = {stacks = 1}

                    AssignStat(player, "Prisoner_Diamond_Formation",
                               buffsTable["Prisoner_Diamond_Formation"], "buffs")

                    targetEffects["buff"] = "Prisoner_Diamond_Formation"

                    HandleStatus(player, buffsTable, "reactionBuff", "buff",
                                 targetEffects)

                    local message = player:Name() ..
                                        " is now performing a Prisoner Diamond Formation by order of " ..
                                        ply:Name()

                    self:AnnounceMessage(message)

                    for _, debuffName in ipairs(debuffsToRemove) do
                        if debuffsTable[debuffName] then
                            if debuffsTable[debuffName].stacks >= 2 then
                                debuffsTable[debuffName] = {stacks = 2}
                                AssignStat(player, debuffName,
                                           debuffsTable[debuffName], "debuffs")
                            end
                        end
                    end

                    if ply ~= target then lastPlayer = target end
                end
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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
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

            local playerSide = (table.HasValue(fight.Side1, ply) and "Side1") or
                                   (table.HasValue(fight.Side2, ply) and "Side2")

            local enemySide = ""

            if playerSide == "Side1" then
                enemySide = "Side2"
            else
                enemySide = "Side1"
            end

            local aliveTargets = 0
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    if player:GetNWInt("TBCHP", 100) > 0 then
                        aliveTargets = aliveTargets + 1
                    end
                end
            end

            if aliveTargets > 1 then
                ply:ChatPrint(
                    "You can only use this when there is a single enemy alive.")
                ply:LagCompensation(false)
                return
            end

            local playersInFight = {}
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    if player:GetNWInt("TBCHP", 100) > 0 then
                        table.insert(playersInFight, player)
                    end
                end
            end

            local debuffsToRemove = Ailments_Statuses["Dekunda"]
            local lastPlayer = ply
            for _, player in ipairs(playersInFight) do
                if IsValid(player) then -- Check if the player is valid
                    local buffsTable = GetAllStats(player, "buffs")
                    local debuffsTable = GetAllStats(player, "debuffs")

                    buffsTable["Prisoner_Diamond_Formation"] = {stacks = 1}

                    AssignStat(player, "Prisoner_Diamond_Formation",
                               buffsTable["Prisoner_Diamond_Formation"], "buffs")

                    targetEffects["buff"] = "Prisoner_Diamond_Formation"

                    HandleStatus(player, buffsTable, "reactionBuff", "buff",
                                 targetEffects)

                    local message = player:Name() ..
                                        " is now performing a Prisoner Diamond Formation by order of " ..
                                        ply:Name()

                    self:AnnounceMessage(message)

                    for _, debuffName in ipairs(debuffsToRemove) do
                        if debuffsTable[debuffName] then
                            if debuffsTable[debuffName].stacks >= 2 then
                                debuffsTable[debuffName] = {stacks = 2}
                                AssignStat(player, debuffName,
                                           debuffsTable[debuffName], "debuffs")
                            end
                        end
                    end

                    if ply ~= target then lastPlayer = target end
                end
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
