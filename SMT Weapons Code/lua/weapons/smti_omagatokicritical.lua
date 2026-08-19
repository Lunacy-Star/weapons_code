include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Omagatoki: Critical"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Nahobino's party gain 100% bonus critical chance in their next turn. Can only be cast once in a battle."
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
SWEP.HPCost = 25
SWEP.Affinity = "Support"
SWEP.Rarity = "Exclusive"
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"
SWEP.CastedInBattle = false

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

function SWEP:Initialize() self.CastedInBattle = false end

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

            if self.CastedInBattle then
                ply:ChatPrint("You can only use this once per battle.")
                ply:LagCompensation(false)
                return
            end

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

            local attackerHP = ply:GetNWInt("TBCHP", 100)
            local hpCost = self.HPCost

            hpCost = hpCost +
                         (HandleStatus(ply, userDebuffsTable, "increaseHPCost",
                                       hpCost) -
                             HandleStatus(ply, userBuffsTable, "decreaseHPCost",
                                          hpCost))

            if attackerHP < hpCost then
                ply:ChatPrint("Not enough HP to use this ability.")
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

            if attackerMP < mpCost then
                ply:ChatPrint("Not enough MP to use this ability.")
                ply:LagCompensation(false)
                return
            end

            ply:SetNWInt("TBCHP", attackerHP - hpCost)
            ply:SetNWInt("TBCMP", attackerMP - mpCost)

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

                buffsTable["Omagatoki_Critical"] = {stacks = 1, duration = 2}

                AssignStat(player, "Omagatoki_Critical",
                           buffsTable["Omagatoki_Critical"], "buffs")

                targetEffects["buff"] = "Omagatoki_Critical"

                HandleStatus(player, buffsTable, "reactionBuff", "buff",
                             targetEffects)

                local message = player:Name() ..
                                    " received Omagatoki: Critical from " ..
                                    ply:Name() .. "!"

                self:AnnounceMessage(message)

                if ply ~= target then lastPlayer = target end
            end

            targetEffects["ply"] = ply
            targetEffects["target"] = lastPlayer

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            self.CastedInBattle = true

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

            if self.CastedInBattle then
                ply:ChatPrint("You can only use this once per battle.")
                ply:LagCompensation(false)
                return
            end

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

            local attackerHP = ply:GetNWInt("TBCHP", 100)
            local hpCost = self.HPCost

            hpCost = hpCost +
                         (HandleStatus(ply, userDebuffsTable, "increaseHPCost",
                                       hpCost) -
                             HandleStatus(ply, userBuffsTable, "decreaseHPCost",
                                          hpCost))

            if attackerHP < hpCost then
                ply:ChatPrint("Not enough HP to use this ability.")
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

            if attackerMP < mpCost then
                ply:ChatPrint("Not enough MP to use this ability.")
                ply:LagCompensation(false)
                return
            end

            ply:SetNWInt("TBCHP", attackerHP - hpCost)
            ply:SetNWInt("TBCMP", attackerMP - mpCost)

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

                buffsTable["Omagatoki_Critical"] = {stacks = 1, duration = 2}

                AssignStat(player, "Omagatoki_Critical",
                           buffsTable["Omagatoki_Critical"], "buffs")

                targetEffects["buff"] = "Omagatoki_Critical"

                HandleStatus(player, buffsTable, "reactionBuff", "buff",
                             targetEffects)

                local message = player:Name() ..
                                    " received Omagatoki: Critical from " ..
                                    ply:Name() .. "!"

                self:AnnounceMessage(message)

                if ply ~= target then lastPlayer = target end
            end

            targetEffects["ply"] = ply
            targetEffects["target"] = lastPlayer

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            self.CastedInBattle = true

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --
