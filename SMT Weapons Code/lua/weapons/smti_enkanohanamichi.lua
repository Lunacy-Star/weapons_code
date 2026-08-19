include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Enka no Hanamichi"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "A microphone made exclusively for the most famous enka ballard singers of the past. Both practical and cool. Depending on the highest allocatable stat on the wielder, Enka no Hanamichi's properties change. If all stat values are the same, none of the effects trigger. \n[STR] Deals 40 Fire damage with 10 Technique, damage +3 for every -kaja. \n[DEX] Deals 35 Ice damage with 10 Technique and a 25% chance of inflicting Freeze. \n[CHR] Deals 30 random affinity damage with 30 Technique."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Melee Weapons"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = "models/weapons/smti_2hsword1_v.mdl" -- Viewmodel path
SWEP.WorldModel = "models/weapons/w_crowbar.mdl" -- Worldmodel path
SWEP.UseHands = true

SWEP.DamageAmount = 1
SWEP.Tech = 1
SWEP.Affinity = "Blunt"
SWEP.Targets = "single"
SWEP.WeaponType = "Melee"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

function SWEP:Initialize() self:SetHoldType("melee") end

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

    if tr.Hit then
        self:SendWeaponAnim(ACT_VM_HITCENTER)
        ply:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound("Weapon_Crowbar.Melee_Hit")
    else
        self:SendWeaponAnim(ACT_VM_MISSCENTER)
        ply:SetAnimation(PLAYER_ATTACK1)
        self:EmitSound("Weapon_Crowbar.Single")
    end

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

            local tech = 1

            local playerStr = tonumber(self.Owner:GetNWInt("TBCSTR", 0))
            local playerDex = tonumber(self.Owner:GetNWInt("TBCDEX", 0))
            local playerChr = tonumber(self.Owner:GetNWInt("TBCCHR", 0))

            if playerStr > 0 or playerDex > 0 or playerChr > 0 then
                if playerStr > playerDex and playerStr > playerChr then
                    tech = 10
                elseif playerDex > playerStr and playerDex > playerChr then
                    tech = 10
                elseif playerChr > playerStr and playerChr > playerDex then
                    tech = 30
                end
            end

            if not self:AbilityRollNumber(tech, target) then
                ply:LagCompensation(false)
                return
            end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            self.DamageAmount = 1
            self.Affinity = "Blunt"
            local micState = "none"

            if playerStr > 0 and playerDex > 0 and playerChr > 0 then
                if playerStr > playerDex and playerStr > playerChr then
                    self.DamageAmount = 40
                    self.Affinity = "Fire"
                    micState = "str"
                elseif playerDex > playerStr and playerDex > playerChr then
                    self.DamageAmount = 35
                    self.Affinity = "Ice"
                    micState = "dex"
                elseif playerChr > playerStr and playerChr > playerDex then
                    self.DamageAmount = 30
                    local randomIndex =
                        math.random(#Affinities["AllAffinities"])
                    local randomAffinity =
                        Affinities["AllAffinities"][randomIndex]
                    self.Affinity = randomAffinity
                    micState = "chr"
                end
            end

            local targetEffects = {}
            targetEffects["baseDamage"] = self.DamageAmount
            targetEffects["Affinity"] = self.Affinity

            local playerLuck = ply:GetNWInt("TBCLuck", 10)
            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local critBonus = (HandleStatus(ply, userBuffsTable,
                                            "increaseCritChance",
                                            targetEffects["baseDamage"]) -
                                  HandleStatus(ply, userDebuffsTable,
                                               "decreaseCritChance",
                                               targetEffects["baseDamage"]))

            targetEffects["critChance"] =
                math.ceil((playerLuck / 2) + critBonus)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            if micState == "str" and
                (userBuffsTable["Tarukaja"] or userBuffsTable["Rakukaja"] or
                    userBuffsTable["Sukukaja"]) then
                if userBuffsTable["Tarukaja"] then
                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] +
                            (3 * userBuffsTable["Tarukaja"]["stacks"])
                end
                if userBuffsTable["Rakukaja"] then
                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] +
                            (3 * userBuffsTable["Rakukaja"]["stacks"])
                end
                if userBuffsTable["Sukukaja"] then
                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] +
                            (3 * userBuffsTable["Sukukaja"]["stacks"])
                end
            end

            if micState == "dex" then
                targetEffects["ailmentChance"] = 25
                targetEffects["ailmentChance"] =
                    math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]
            end

            targetEffects["state"] = 'normal'

            targetEffects = HandleRepel(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            if targetEffects["state"] == 'repel' then
                self:AnnounceMessage(target:Name() .. " repeled the attack!")
            end
            targetEffects = HandleResistances(targetEffects["ply"],
                                              targetEffects["target"],
                                              targetEffects)
            targetEffects = HandleWeaknesses(targetEffects["ply"],
                                             targetEffects["target"],
                                             targetEffects)
            targetEffects = HandleCrit(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)
            targetEffects = HandleBlock(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleDrain(targetEffects["ply"],
                                        targetEffects["target"], targetEffects)

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (HandleStatus(targetEffects["ply"],
                                  targetEffects["userBuffsTable"], "damage",
                                  targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(targetEffects["ply"],
                                     targetEffects["userDebuffsTable"],
                                     "decreaseDamage",
                                     targetEffects["baseDamage"], targetEffects)) -
                    (HandleStatus(targetEffects["target"],
                                  targetEffects["targetBuffsTable"],
                                  "defenseDamage", targetEffects["baseDamage"],
                                  targetEffects) -
                        HandleStatus(targetEffects["target"],
                                     targetEffects["targetDebuffsTable"],
                                     "defenseDecrease",
                                     targetEffects["baseDamage"], targetEffects))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            if micState == "dex" then
                targetEffects["ailment"] = "Freeze"

                targetEffects["ailmentChance"] =
                    targetEffects["ailmentChance"] +
                        (HandleStatus(targetEffects["ply"], userBuffsTable,
                                      "increaseAilmentChance",
                                      targetEffects["ailmentChance"],
                                      targetEffects) -
                            HandleStatus(targetEffects["ply"], userDebuffsTable,
                                         "decreaseAilmentChance",
                                         targetEffects["ailmentChance"],
                                         targetEffects)) -
                        (HandleStatus(targetEffects["target"], targetBuffsTable,
                                      "decreaseAilmentReceive",
                                      targetEffects["ailmentChance"],
                                      targetEffects) -
                            HandleStatus(targetEffects["target"],
                                         targetDebuffsTable,
                                         "increaseAilmentReceive",
                                         targetEffects["ailmentChance"],
                                         targetEffects))

                if math.random(1, 100) <= targetEffects["ailmentChance"] then

                    local targetDebuffsTable = GetAllStats(
                                                   targetEffects["target"],
                                                   "debuffs")

                    targetDebuffsTable["Freeze"] = {
                        stacks = 1,
                        type = "turnSkipper",
                        duration = 3
                    }

                    AssignStat(targetEffects["target"], "Freeze",
                               targetDebuffsTable["Freeze"], "debuffs")

                    self:AnnounceMessage(
                        targetEffects["target"]:Name() .. " is now Frozen!")

                    HandleStatus(targetEffects["ply"], userBuffsTable,
                                 "ailmentReaction", "Freeze", targetEffects)
                end
            end

            targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)

            local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
            local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
            local newHP

            if targetEffects["state"] == "drain" then
                newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
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
                targetEffects = HandleDeath(targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)
                targetEffects = HandleKill(targetEffects["ply"],
                                           targetEffects["target"],
                                           targetEffects)

                self:CheckForTeamDefeat(self.FightId)
            end

            
        end
    end

    ply:LagCompensation(false)end --
