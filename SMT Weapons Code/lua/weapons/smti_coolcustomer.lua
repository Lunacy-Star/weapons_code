include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Cool Customer"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Cure one ally target or oneself of all ailments. For each ailment cured deal 5 Almighty damage to all enemies."
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

SWEP.DamageAmount = 5
SWEP.Affinity = "Almighty"
SWEP.Targets = "aoe"
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

    if tr.Hit then
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

            local targetEffects = {}

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            if not targetEffects["userBuffsTable"]["One_More"] then
                ply:ChatPrint("You cannot use Combat Tactics without One More.")
                ply:LagCompensation(false)
                return
            end

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if fight then
            else
                return
            end

            local debuffsToRemove = Ailments_Statuses["Ailments"]

            local debuffsTable = GetAllStats(target, "debuffs")
            local debuffsRemoved = 0
            for _, debuffName in ipairs(debuffsToRemove) do
                if debuffsTable[debuffName] then
                    RemoveStat(target, debuffName, "debuffs")
                    debuffsTable[debuffName] = nil
                    debuffsRemoved = debuffsRemoved + 1
                end
            end

            local message = target:Name() .. " had their ailments cured by " ..
                                ply:Name() .. "!"

            self:AnnounceMessage(message)

            if debuffsRemoved > 0 then
                local playerSide = (table.HasValue(fight.Side1, target) and
                                       "Side1") or
                                       (table.HasValue(fight.Side2, target) and
                                           "Side2")

                local opforSide = (playerSide == "Side1") and "Side2" or "Side1"

                local playersInFight = {}
                for _, player in ipairs(fight[opforSide]) do
                    if IsValid(player) then
                        table.insert(playersInFight, player)
                    end
                end

                for _, player in ipairs(playersInFight) do
                    if TargetCheckValidity(ply, player) then -- Check if the player is valid
                        local targetBuffsTable = GetAllStats(player, "buffs")
                        local targetDebuffsTable =
                            GetAllStats(player, "debuffs")

                        local targetEffects = {}
                        targetEffects["baseDamage"] = self.DamageAmount *
                                                          debuffsRemoved
                        targetEffects["Affinity"] = self.Affinity

                        targetEffects["ply"] = ply
                        targetEffects["target"] = player

                        targetEffects["userBuffsTable"] = userBuffsTable
                        targetEffects["userDebuffsTable"] = userDebuffsTable
                        targetEffects["targetBuffsTable"] = targetBuffsTable
                        targetEffects["targetDebuffsTable"] = targetDebuffsTable

                        targetEffects["state"] = 'normal'

                        targetEffects = HandleRepel(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        if targetEffects["state"] == 'repel' then
                            self:AnnounceMessage(player:Name() ..
                                                     " repeled the attack!")
                        end
                        targetEffects = HandleResistances(targetEffects["ply"],
                                                          targetEffects["target"],
                                                          targetEffects)
                        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                                         targetEffects["target"],
                                                         targetEffects)
                        targetEffects = HandleBlock(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        targetEffects = HandleDrain(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)

                        targetEffects["attacker"] = targetEffects["ply"]
                        targetEffects["target"] = targetEffects["target"]

                        targetEffects["baseDamage"] =
                            targetEffects["baseDamage"] +
                                (HandleStatus(targetEffects["ply"],
                                              targetEffects["userBuffsTable"],
                                              "damage",
                                              targetEffects["baseDamage"],
                                              targetEffects) -
                                    HandleStatus(targetEffects["ply"],
                                                 targetEffects["userDebuffsTable"],
                                                 "decreaseDamage",
                                                 targetEffects["baseDamage"],
                                                 targetEffects)) -
                                (HandleStatus(targetEffects["target"],
                                              targetEffects["targetBuffsTable"],
                                              "defenseDamage",
                                              targetEffects["baseDamage"],
                                              targetEffects) -
                                    HandleStatus(targetEffects["target"],
                                                 targetEffects["targetDebuffsTable"],
                                                 "defenseDecrease",
                                                 targetEffects["baseDamage"],
                                                 targetEffects))

                        targetEffects["baseDamage"] = math.ceil(
                                                          targetEffects["baseDamage"])

                        targetEffects = HandleDamageMessage(
                                            targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

                        local currentHP =
                            targetEffects["target"]:GetNWInt("TBCHP", 100)
                        local maxHP = targetEffects["target"]:GetNWInt(
                                          "TBCMAXHP", 100)
                        local newHP

                        if targetEffects["state"] == "drain" then
                            newHP = math.min(currentHP +
                                                 targetEffects["baseDamage"],
                                             maxHP)
                        else
                            newHP = currentHP - targetEffects["baseDamage"]
                            HandleStatus(targetEffects["target"], targetEffects,
                                         "damageReaction", false, targetEffects)
                        end

                        targetEffects["target"]:SetNWInt("TBCHP", newHP)

                        self:AnnounceMessage(targetEffects["message"])

                        if newHP <= 0 then
                            targetEffects["target"]:SetNWInt("TBCHP", 0)

                            targetEffects["lifeState"] = "dead"
                            targetEffects =
                                HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                            targetEffects =
                                HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                            self:CheckForTeamDefeat(self.FightId)
                        end
                    end
                end
            end

            RemoveStat(ply, "One_More", "buffs")
            HandleStatus(ply, userBuffsTable, "comtacReaction", false,
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

            local targetEffects = {}

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            if not targetEffects["userBuffsTable"]["One_More"] then
                ply:ChatPrint("You cannot use Combat Tactics without One More.")
                ply:LagCompensation(false)
                return
            end

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if fight then
            else
                return
            end

            local debuffsToRemove = Ailments_Statuses["Ailments"]

            local debuffsTable = GetAllStats(target, "debuffs")
            local debuffsRemoved = 0
            for _, debuffName in ipairs(debuffsToRemove) do
                if debuffsTable[debuffName] then
                    RemoveStat(target, debuffName, "debuffs")
                    debuffsTable[debuffName] = nil
                    debuffsRemoved = debuffsRemoved + 1
                end
            end

            local message = target:Name() .. " had their ailments cured by " ..
                                ply:Name() .. "!"

            self:AnnounceMessage(message)

            if debuffsRemoved > 0 then
                local playerSide = (table.HasValue(fight.Side1, target) and
                                       "Side1") or
                                       (table.HasValue(fight.Side2, target) and
                                           "Side2")

                local opforSide = (playerSide == "Side1") and "Side2" or "Side1"

                local playersInFight = {}
                for _, player in ipairs(fight[opforSide]) do
                    if IsValid(player) then
                        table.insert(playersInFight, player)
                    end
                end

                for _, player in ipairs(playersInFight) do
                    if TargetCheckValidity(ply, player) then -- Check if the player is valid
                        local targetBuffsTable = GetAllStats(player, "buffs")
                        local targetDebuffsTable =
                            GetAllStats(player, "debuffs")

                        local targetEffects = {}
                        targetEffects["baseDamage"] = self.DamageAmount *
                                                          debuffsRemoved
                        targetEffects["Affinity"] = self.Affinity

                        targetEffects["ply"] = ply
                        targetEffects["target"] = player

                        targetEffects["userBuffsTable"] = userBuffsTable
                        targetEffects["userDebuffsTable"] = userDebuffsTable
                        targetEffects["targetBuffsTable"] = targetBuffsTable
                        targetEffects["targetDebuffsTable"] = targetDebuffsTable

                        targetEffects["state"] = 'normal'

                        targetEffects = HandleRepel(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        if targetEffects["state"] == 'repel' then
                            self:AnnounceMessage(player:Name() ..
                                                     " repeled the attack!")
                        end
                        targetEffects = HandleResistances(targetEffects["ply"],
                                                          targetEffects["target"],
                                                          targetEffects)
                        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                                         targetEffects["target"],
                                                         targetEffects)
                        targetEffects = HandleBlock(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        targetEffects = HandleDrain(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)

                        targetEffects["attacker"] = targetEffects["ply"]
                        targetEffects["target"] = targetEffects["target"]

                        targetEffects["baseDamage"] =
                            targetEffects["baseDamage"] +
                                (HandleStatus(targetEffects["ply"],
                                              targetEffects["userBuffsTable"],
                                              "damage",
                                              targetEffects["baseDamage"],
                                              targetEffects) -
                                    HandleStatus(targetEffects["ply"],
                                                 targetEffects["userDebuffsTable"],
                                                 "decreaseDamage",
                                                 targetEffects["baseDamage"],
                                                 targetEffects)) -
                                (HandleStatus(targetEffects["target"],
                                              targetEffects["targetBuffsTable"],
                                              "defenseDamage",
                                              targetEffects["baseDamage"],
                                              targetEffects) -
                                    HandleStatus(targetEffects["target"],
                                                 targetEffects["targetDebuffsTable"],
                                                 "defenseDecrease",
                                                 targetEffects["baseDamage"],
                                                 targetEffects))

                        targetEffects["baseDamage"] = math.ceil(
                                                          targetEffects["baseDamage"])

                        targetEffects = HandleDamageMessage(
                                            targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

                        local currentHP =
                            targetEffects["target"]:GetNWInt("TBCHP", 100)
                        local maxHP = targetEffects["target"]:GetNWInt(
                                          "TBCMAXHP", 100)
                        local newHP

                        if targetEffects["state"] == "drain" then
                            newHP = math.min(currentHP +
                                                 targetEffects["baseDamage"],
                                             maxHP)
                        else
                            newHP = currentHP - targetEffects["baseDamage"]
                            HandleStatus(targetEffects["target"], targetEffects,
                                         "damageReaction", false, targetEffects)
                        end

                        targetEffects["target"]:SetNWInt("TBCHP", newHP)

                        self:AnnounceMessage(targetEffects["message"])

                        if newHP <= 0 then
                            targetEffects["target"]:SetNWInt("TBCHP", 0)

                            targetEffects["lifeState"] = "dead"
                            targetEffects =
                                HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                            targetEffects =
                                HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                            self:CheckForTeamDefeat(self.FightId)
                        end
                    end
                end
            end
            RemoveStat(ply, "One_More", "buffs")
            HandleStatus(ply, userBuffsTable, "comtacReaction", false,
                         targetEffects)

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --
