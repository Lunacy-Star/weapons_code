include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Makajama"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "35 ruin damage to a single target. 30% chance to inflict Mute. \n[CHR 4] 35% chance to inflict Mute instead."
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

SWEP.DamageAmount = 35
SWEP.MPCost = 12
SWEP.Tech = 10
SWEP.Affinity = "Ruin"
SWEP.Targets = "single"
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

        if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
            not TargetCheckValidity(ply, target, true) then
            ply:LagCompensation(false)
            return
        end

        self:AnnounceAbility()

        local userBuffsTable = GetAllStats(ply, "buffs")
        local userDebuffsTable = GetAllStats(ply, "debuffs")
        local targetBuffsTable = GetAllStats(target, "buffs")
        local targetDebuffsTable = GetAllStats(target, "debuffs")

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

        local tech = 10

        if not self:AbilityRollNumber(tech, target) then
            ply:LagCompensation(false)
            return
        end

        targetEffects["baseDamage"] = self.DamageAmount
        targetEffects["Affinity"] = self.Affinity

        local playerLuck = ply:GetNWInt("TBCLuck", 10)

        playerLuck = playerLuck +
                         (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                       playerLuck) -
                             HandleStatus(ply, userDebuffsTable, "decreaseLuck",
                                          playerLuck))

        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        targetEffects["ailmentChance"] = 30
        if playerChr >= 4 then targetEffects["ailmentChance"] = 35 end
        targetEffects["ailmentChance"] =
            math.ceil(playerLuck / 2) + targetEffects["ailmentChance"]

        local critBonus = (HandleStatus(ply, userBuffsTable,
                                        "increaseCritChance",
                                        targetEffects["baseDamage"]) -
                              HandleStatus(ply, userDebuffsTable,
                                           "decreaseCritChance",
                                           targetEffects["baseDamage"]))

        targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

        targetEffects["ply"] = ply
        targetEffects["target"] = target

        targetEffects["userBuffsTable"] = userBuffsTable
        targetEffects["userDebuffsTable"] = userDebuffsTable
        targetEffects["targetBuffsTable"] = targetBuffsTable
        targetEffects["targetDebuffsTable"] = targetDebuffsTable

        targetEffects["state"] = 'normal'

        targetEffects = HandleRepel(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        if targetEffects["state"] == 'repel' then
            self:AnnounceMessage(target:Name() .. " repeled the attack!")
        end

        targetEffects = HandleResistances(targetEffects["ply"],
                                          targetEffects["target"], targetEffects)
        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                         targetEffects["target"], targetEffects)
        targetEffects = HandleCrit(targetEffects["ply"],
                                   targetEffects["target"], targetEffects)
        targetEffects = HandleBlock(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)
        targetEffects = HandleDrain(targetEffects["ply"],
                                    targetEffects["target"], targetEffects)

        targetEffects["baseDamage"] = targetEffects["baseDamage"] +
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
                                              HandleStatus(
                                                  targetEffects["target"],
                                                  targetEffects["targetDebuffsTable"],
                                                  "defenseDecrease",
                                                  targetEffects["baseDamage"],
                                                  targetEffects))

        targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

        targetEffects["ailment"] = "Mute"

        targetEffects["ailmentChance"] =
            targetEffects["ailmentChance"] +
                (HandleStatus(targetEffects["ply"], userBuffsTable,
                              "increaseAilmentChance",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["ply"], userDebuffsTable,
                                 "decreaseAilmentChance",
                                 targetEffects["ailmentChance"], targetEffects)) -
                (HandleStatus(targetEffects["target"], targetBuffsTable,
                              "decreaseAilmentReceive",
                              targetEffects["ailmentChance"], targetEffects) -
                    HandleStatus(targetEffects["target"], targetDebuffsTable,
                                 "increaseAilmentReceive",
                                 targetEffects["ailmentChance"], targetEffects))

        if math.random(1, 100) <= targetEffects["ailmentChance"] then

            local targetDebuffsTable = GetAllStats(targetEffects["target"],
                                                   "debuffs")

            targetDebuffsTable["Mute"] = {
                stacks = 1,
                type = "skillPrevent",
                wearOff = "turnWearOff",
                duration = 4
            }

            AssignStat(targetEffects["target"], "Mute",
                       targetDebuffsTable["Mute"], "debuffs")

            self:AnnounceMessage(targetEffects["target"]:Name() ..
                                     " is now Muted!")

            HandleStatus(targetEffects["ply"], userBuffsTable,
                         "ailmentReaction", "Mute", targetEffects)
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
                                        targetEffects["target"], targetEffects)
            targetEffects = HandleKill(targetEffects["ply"],
                                       targetEffects["target"], targetEffects)

            self:CheckForTeamDefeat(self.FightId)
        end

        
    end

    ply:LagCompensation(false)
end --
