include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Kamui Miracle"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Teddie casts a support skill while targeting an enemy. There is a chance for one of the following to happen: 2 Tarukaja, 2 Rakunda on targeted enemy. 2 Tarunda, 2 Rakukaja on self. 40 HP healed for Teddie's team, 15 HP healed for enemy team. 45 HP healed for Teddie's team, excluding Teddie himself. Heal Dampener on targeted enemy. Remove 50 HP from self. Teddie gains 1 Tarukaja and 2 Sukukaja. Remove 100 HP on targeted enemy."
SWEP.Instructions = ""
SWEP.Category = "SMT Magic Skills"

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
SWEP.MPCost = 35
SWEP.Tech = 0
SWEP.Affinity = "Support"
SWEP.Targets = "single"
SWEP.WeaponType = "Magic Skill"
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

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if fight then
            else
                return
            end

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable

            local chanceTime = math.random(1, 7)

            if chanceTime == 1 then
                local targetBuffsTable = GetAllStats(target, "buffs")
                targetEffects["targetDebuffsTable"] = GetAllStats(target,
                                                                  "debuffs")

                if targetBuffsTable["Tarukaja"] then
                    targetBuffsTable["Tarukaja"].stacks = math.min(
                                                              targetBuffsTable["Tarukaja"]
                                                                  .stacks + 2, 4)
                else
                    targetBuffsTable["Tarukaja"] = {stacks = 2}
                end

                if targetEffects["targetDebuffsTable"]["Rakunda"] then
                    targetEffects["targetDebuffsTable"]["Rakunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Rakunda"]
                                     .stacks + 2, 4)
                else
                    targetEffects["targetDebuffsTable"]["Rakunda"] = {
                        stacks = 2
                    }
                end

                AssignStat(target, "Tarukaja", targetBuffsTable["Tarukaja"],
                           "buffs")
                AssignStat(target, "Rakunda",
                           targetEffects["targetDebuffsTable"]["Rakunda"],
                           "debuffs")

                targetEffects["buff"] = "Tarukaja"

                HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                             targetEffects)

                targetEffects["debuff"] = "Rakunda"

                HandleStatus(target, targetBuffsTable, "reactionDebuff",
                             "debuff", targetEffects)

                local message = target:Name() ..
                                    " received 2 Tarukaja and 2 Rakunda from " ..
                                    ply:Name() .. " and now has " ..
                                    targetBuffsTable["Tarukaja"].stacks ..
                                    " Tarukaja stacks and " ..
                                    targetEffects["targetDebuffsTable"]["Rakunda"]
                                        .stacks .. " Rakunda stacks!"

                self:AnnounceMessage(message)

            elseif chanceTime == 2 then
                targetEffects["targetDebuffsTable"] = userDebuffsTable

                if userBuffsTable["Rakukaja"] then
                    userBuffsTable["Rakukaja"].stacks = math.min(
                                                            userBuffsTable["Rakukaja"]
                                                                .stacks + 2, 4)
                else
                    userBuffsTable["Rakukaja"] = {stacks = 2}
                end

                if targetEffects["targetDebuffsTable"]["Tarunda"] then
                    targetEffects["targetDebuffsTable"]["Tarunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Tarunda"]
                                     .stacks + 2, 4)
                else
                    targetEffects["targetDebuffsTable"]["Tarunda"] = {
                        stacks = 2
                    }
                end

                AssignStat(ply, "Rakukaja", userBuffsTable["Rakukaja"], "buffs")
                AssignStat(ply, "Tarunda",
                           targetEffects["targetDebuffsTable"]["Tarunda"],
                           "debuffs")

                targetEffects["debuff"] = "Tarunda"

                HandleStatus(ply, userBuffsTable, "reactionDebuff", "debuff",
                             targetEffects)

                local message = ply:Name() ..
                                    " received 2 Tarunda and 2 Rakukaja and now has " ..
                                    userBuffsTable["Rakukaja"].stacks ..
                                    " Rakukaja stacks and " ..
                                    targetEffects["targetDebuffsTable"]["Tarunda"]
                                        .stacks .. " Tarunda stacks!"

                self:AnnounceMessage(message)

            elseif chanceTime == 3 then
                local playerSide =
                    (table.HasValue(fight.Side1, ply) and "Side1") or
                        (table.HasValue(fight.Side2, ply) and "Side2")

                local playersInFight = {}
                for _, player in ipairs(fight[playerSide]) do
                    if IsValid(player) then
                        local currentHP = player:GetNWInt("TBCHP", 100)
                        if currentHP > 0 then
                            local baseDamage = 40
                            local maxHP = ply:GetNWInt("TBCMAXHP", 100)
                            local newHP =
                                math.min(currentHP + baseDamage, maxHP)

                            player:SetNWInt("TBCHP", newHP)

                            local message =
                                player:Name() .. " received " .. baseDamage ..
                                    " healing from " .. ply:Name() .. "!"

                            self:AnnounceMessage(message)

                        end
                    end
                end

                local playerSide = (table.HasValue(fight.Side1, target) and
                                       "Side1") or
                                       (table.HasValue(fight.Side2, target) and
                                           "Side2")

                local playersInFight = {}
                for _, player in ipairs(fight[playerSide]) do
                    if IsValid(player) then
                        local currentHP = player:GetNWInt("TBCHP", 100)
                        if currentHP > 0 then
                            local targetBuffsTable =
                                GetAllStats(player, "buffs")
                            local targetDebuffsTable = GetAllStats(player,
                                                                   "debuffs")

                            targetEffects["userBuffsTable"] = userBuffsTable
                            targetEffects["userDebuffsTable"] = userDebuffsTable
                            targetEffects["targetBuffsTable"] = targetBuffsTable
                            targetEffects["targetDebuffsTable"] =
                                targetDebuffsTable

                            targetEffects["baseDamage"] = 15

                            targetEffects["baseDamage"] =
                                targetEffects["baseDamage"] * (1 +
                                    ((HandleStatus(ply, userBuffsTable,
                                                   "increaseHeal",
                                                   targetEffects["baseDamage"],
                                                   targetEffects) -
                                        HandleStatus(ply, userDebuffsTable,
                                                     "decreaseHeal",
                                                     targetEffects["baseDamage"],
                                                     targetEffects)) +
                                        (HandleStatus(target, targetBuffsTable,
                                                      "increaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                            HandleStatus(target,
                                                         targetDebuffsTable,
                                                         "decreaseHealReceive",
                                                         targetEffects["baseDamage"]))))

                            targetEffects["baseDamage"] =
                                targetEffects["baseDamage"] +
                                    (((HandleStatus(ply, userBuffsTable,
                                                    "flatIncreaseHeal",
                                                    targetEffects["baseDamage"]) -
                                        HandleStatus(ply, userDebuffsTable,
                                                     "flatDecreaseHeal",
                                                     targetEffects["baseDamage"])) +
                                        (HandleStatus(target, targetBuffsTable,
                                                      "flatIncreaseHealReceive",
                                                      targetEffects["baseDamage"]) -
                                            HandleStatus(target,
                                                         targetDebuffsTable,
                                                         "flatDecreaseHealReceive",
                                                         targetEffects["baseDamage"]))))

                            targetEffects["baseDamage"] = math.ceil(
                                                              targetEffects["baseDamage"])

                            HandleHealingEffects(ply, player, targetEffects)

                            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                            local newHP =
                                math.min(currentHP + targetEffects["baseDamage"],
                                         maxHP)

                            player:SetNWInt("TBCHP", newHP)

                            local message =
                                player:Name() .. " received " ..
                                    targetEffects["baseDamage"] ..
                                    " healing from " .. ply:Name() .. "!"

                            self:AnnounceMessage(message)

                        end
                    end
                end

            elseif chanceTime == 4 then
                local playerSide =
                    (table.HasValue(fight.Side1, ply) and "Side1") or
                        (table.HasValue(fight.Side2, ply) and "Side2")

                local playersInFight = {}
                if #fight[playerSide] > 1 then

                    for _, player in ipairs(fight[playerSide]) do
                        if IsValid(player) and player ~= ply then
                            local currentHP = target:GetNWInt("TBCHP", 100)
                            if currentHP > 0 then

                                local baseDamage = 45

                                local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                                local newHP =
                                    math.min(currentHP + baseDamage, maxHP)

                                player:SetNWInt("TBCHP", newHP)

                                local message =
                                    player:Name() .. " received " .. baseDamage ..
                                        " healing from " .. ply:Name() .. "!"

                                self:AnnounceMessage(message)

                            end
                        end
                    end
                else
                    self:AnnounceMessage(ply:Name() .. " heals nobody!")
                end

            elseif chanceTime == 5 then
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                targetDebuffsTable["Heal_Dampener"] = {stacks = 1}

                AssignStat(target, "Heal_Dampener",
                           targetDebuffsTable["Heal_Dampener"], "debuffs")

                local message =
                    target:Name() .. " received Heal Dampener from " ..
                        ply:Name() .. "!"

                self:AnnounceMessage(message)

            elseif chanceTime == 6 then
                if userBuffsTable["Tarukaja"] then
                    userBuffsTable["Tarukaja"].stacks = math.min(
                                                            userBuffsTable["Tarukaja"]
                                                                .stacks + 1, 4)
                else
                    userBuffsTable["Tarukaja"] = {stacks = 1}
                end

                if userBuffsTable["Sukukaja"] then
                    userBuffsTable["Sukukaja"].stacks = math.min(
                                                            userBuffsTable["Sukukaja"]
                                                                .stacks + 2, 4)
                else
                    userBuffsTable["Sukukaja"] = {stacks = 1}
                end

                AssignStat(ply, "Tarukaja", userBuffsTable["Tarukaja"], "buffs")
                AssignStat(ply, "Sukukaja", userBuffsTable["Sukukaja"], "buffs")

                local resist = util.JSONToTable(ply:GetNW2String("resist"))
                local block = util.JSONToTable(ply:GetNW2String("block"))
                local drain = util.JSONToTable(ply:GetNW2String("drain"))
                local repel = util.JSONToTable(ply:GetNW2String("repel"))
                local baseDamage = 50

                if table.HasValue(resist, "Almighty") or
                    table.HasValue(block, "Almighty") or
                    table.HasValue(drain, "Almighty") or
                    table.HasValue(repel, "Almighty") then
                    baseDamage = 0
                end

                local currentHP = ply:GetNWInt("TBCHP", 100)
                local maxHP = ply:GetNWInt("TBCMAXHP", 100)
                local newHP

                newHP = currentHP - baseDamage

                ply:SetNWInt("TBCHP", newHP)

                local message = ply:Name() .. " received " .. baseDamage ..
                                    " damage, 1 Tarukaja and 2 Sukukaja and now has " ..
                                    userBuffsTable["Tarukaja"].stacks ..
                                    " Tarukaja stacks and " ..
                                    userBuffsTable["Sukukaja"].stacks ..
                                    " Sukukaja stacks!"

                self:AnnounceMessage(message)

                targetEffects["targetBuffsTable"] = userBuffsTable
                targetEffects["targetDebuffsTable"] = userDebuffsTable

                HandleStatus(ply, targetEffects, "damageReaction", false,
                             targetEffects)

                if newHP <= 0 then
                    ply:SetNWInt("TBCHP", 0)
                    self:AnnounceMessage(ply:Name() .. " is dead!")

                    targetEffects["lifeState"] = "dead"
                    targetEffects = HandleDeath(ply, ply, targetEffects)

                    self:CheckForTeamDefeat(self.FightId)
                else
                    self:CheckForTeamDefeat(self.FightId)
                end
            elseif chanceTime == 7 then
                local resist = util.JSONToTable(target:GetNW2String("resist"))
                local block = util.JSONToTable(target:GetNW2String("block"))
                local drain = util.JSONToTable(target:GetNW2String("drain"))
                local repel = util.JSONToTable(target:GetNW2String("repel"))
                local baseDamage = 100

                if table.HasValue(resist, "Almighty") or
                    table.HasValue(block, "Almighty") or
                    table.HasValue(drain, "Almighty") or
                    table.HasValue(repel, "Almighty") then
                    baseDamage = 0
                end

                local currentHP = target:GetNWInt("TBCHP", 100)
                local maxHP = target:GetNWInt("TBCMAXHP", 100)
                local newHP

                newHP = currentHP - baseDamage

                target:SetNWInt("TBCHP", newHP)

                local message = target:Name() .. " received " .. baseDamage ..
                                    " damage from " .. ply:Name() .. "!"

                self:AnnounceMessage(message)

                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                targetEffects["targetBuffsTable"] = targetBuffsTable
                targetEffects["targetDebuffsTable"] = targetDebuffsTable

                HandleStatus(target, targetEffects, "damageReaction", false,
                             targetEffects)

                if newHP <= 0 then
                    target:SetNWInt("TBCHP", 0)
                    self:AnnounceMessage(target:Name() .. " is dead!")

                    targetEffects["lifeState"] = "dead"
                    targetEffects = HandleDeath(ply, target, targetEffects)
                    targetEffects = HandleKill(ply, target, targetEffects)

                    self:CheckForTeamDefeat(self.FightId)
                else
                    self:CheckForTeamDefeat(self.FightId)
                end
            end

            self:EndAbility()
            end)
        end
    end

    ply:LagCompensation(false)
end --
