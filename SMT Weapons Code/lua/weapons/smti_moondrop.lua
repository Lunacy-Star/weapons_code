include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Moondrop"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Deal 20 martial art damage on a single target. Lowers target's Sukukaja by -1. \n[STR 5] HP Cost reduced to 10 HP. \n[DEX 5] Technique 25."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Skills"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = "models/weapons/smti_1hsword1_v.mdl" -- Viewmodel path
SWEP.WorldModel = "models/weapons/w_crowbar.mdl" -- Worldmodel path
SWEP.UseHands = true

SWEP.DamageAmount = 20
SWEP.HPCost = 15
SWEP.Tech = 20
SWEP.Affinity = "Martial Arts"
SWEP.Targets = "single"
SWEP.WeaponType = "Physical Skill"
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
            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
            if playerStr >= 5 then hpCost = 10 end

            hpCost = hpCost +
                         (HandleStatus(ply, userDebuffsTable, "increaseHPCost",
                                       hpCost) -
                             HandleStatus(ply, userBuffsTable, "decreaseHPCost",
                                          hpCost))

            if attackerHP >= hpCost then
                ply:SetNWInt("TBCHP", attackerHP - hpCost)
            else
                ply:ChatPrint("Not enough HP to use this ability.")
                ply:LagCompensation(false)
                return
            end

            local tech = 20
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
            if playerDex >= 5 then tech = 25 end

            if not self:AbilityRollNumber(tech, target) then
                ply:LagCompensation(false)
                return
            end

            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

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

            if targetEffects["targetDebuffsTable"]["Sukunda"] then
                targetEffects["targetDebuffsTable"]["Sukunda"].stacks =
                    math.min(targetEffects["targetDebuffsTable"]["Sukunda"]
                                 .stacks + 1, 4)
            else
                targetEffects["targetDebuffsTable"]["Sukunda"] = {stacks = 1}
            end

            AssignStat(targetEffects["target"], "Sukunda",
                       targetEffects["targetDebuffsTable"]["Sukunda"], "debuffs")

            targetEffects["debuff"] = "Sukunda"

            HandleStatus(targetEffects["target"],
                         targetEffects["targetBuffsTable"], "reactionDebuff",
                         "debuff", targetEffects)

            self:AnnounceMessage(targetEffects["target"]:Name() ..
                                     " received Sukunda from " ..
                                     targetEffects["ply"]:Name() ..
                                     "! They now have " ..
                                     targetEffects["targetDebuffsTable"]["Sukunda"]
                                         .stacks .. " Sukunda!")

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

    ply:LagCompensation(false)
end --
