include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Andalucia"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "[Matador] [Physical] [Phase 2: 3750 HP or lower]\nDeals 1-4 hits to all foes, each dealing 30 physical damage. The 3rd and 4th hits can critically strike. Cannot use more than once in a turn cycle. Hit count per target is based on Matador's Technique minus the target's Technique: >= 30 (4 Hits), >= 20 (3 Hits), >= 10 (2 Hits), otherwise (1 Hit)."
SWEP.Instructions = ""
SWEP.Category = "SMT Boss Skills"

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

SWEP.DamageAmount = 30
SWEP.PhaseThreshold = 3750
SWEP.Tech = 0
SWEP.Affinity = "Physical"
SWEP.Targets = "aoe"
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

    self:SetNextPrimaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 65

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

    if tr.Hit then
        if SERVER then
            local target = self.Owner:GetEyeTrace().Entity

            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
                ply:LagCompensation(false)
                return
            end

            local currentHP = ply:GetNWInt("TBCHP", 0)
            if currentHP > self.PhaseThreshold then
                ply:ChatPrint("Andalucia is not available yet.")
                ply:LagCompensation(false)
                return
            end

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if not fight then
                ply:LagCompensation(false)
                return
            end

            if ply.AndaluciaLastCycle and ply.AndaluciaLastCycle ==
                fight.CyclesDone then
                ply:ChatPrint(
                    "Andalucia cannot be used more than once in a turn cycle.")
                ply:LagCompensation(false)
                return
            end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            if not PlayerCanUseSkills(ply, userBuffsTable, userDebuffsTable) then
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()

            ply.AndaluciaLastCycle = fight.CyclesDone

            local tech = self.Tech

            local targetedTargets = RollAoETargets(ply, target, self, tech)

            if next(targetedTargets) == nil then
                ply:ChatPrint(ply:Name() .. " hits literally nobody!")
            else
                local matadorTech = ply:GetNWInt("TBCTechnique", 0)

                for _, ent in pairs(targetedTargets) do
                    local target = ent

                    if IsValid(target) then
                        local targetTech = target:GetNWInt("TBCTechnique", 0)
                        local techDiff = matadorTech - targetTech

                        local hitCount = 1
                        if techDiff >= 30 then
                            hitCount = 4
                        elseif techDiff >= 20 then
                            hitCount = 3
                        elseif techDiff >= 10 then
                            hitCount = 2
                        end

                        for hitIndex = 1, hitCount do
                            if not IsValid(target) or
                                target:GetNWInt("TBCHP", 0) <= 0 then
                                break
                            end

                            local dmg = DamageInfo()
                            dmg:SetDamage(0)
                            dmg:SetAttacker(ply)
                            dmg:SetInflictor(self)
                            dmg:SetDamageForce(ply:GetAimVector())
                            dmg:SetDamagePosition(target:GetPos())
                            dmg:SetDamageType(DMG_CLUB)
                            target:DispatchTraceAttack(dmg, ShootPos +
                                                            ply:EyeAngles():Right() *
                                                                -5, ShootEnd)

                            local userBuffsTable = GetAllStats(ply, "buffs")
                            local userDebuffsTable = GetAllStats(ply, "debuffs")
                            local targetBuffsTable = GetAllStats(target, "buffs")
                            local targetDebuffsTable = GetAllStats(target,
                                                                   "debuffs")

                            local targetEffects = {}
                            targetEffects["baseDamage"] = self.DamageAmount
                            targetEffects["Affinity"] = self.Affinity

                            local playerLuck = ply:GetNWInt("TBCLuck", 10)
                            playerLuck = playerLuck +
                                             (HandleStatus(ply, userBuffsTable,
                                                           "increaseLuck",
                                                           playerLuck) -
                                                 HandleStatus(ply,
                                                              userDebuffsTable,
                                                              "decreaseLuck",
                                                              playerLuck))

                            local critBonus = (HandleStatus(ply, userBuffsTable,
                                                            "increaseCritChance",
                                                            targetEffects["baseDamage"]) -
                                                  HandleStatus(ply,
                                                               userDebuffsTable,
                                                               "decreaseCritChance",
                                                               targetEffects["baseDamage"]))

                            -- Only the 3rd and 4th hits are allowed to crit.
                            if hitIndex >= 3 then
                                targetEffects["critChance"] = math.ceil(
                                                                  (playerLuck /
                                                                      2) +
                                                                      critBonus)
                            else
                                targetEffects["critChance"] = 0
                            end

                            targetEffects["ply"] = ply
                            targetEffects["target"] = target

                            targetEffects["userBuffsTable"] = userBuffsTable
                            targetEffects["userDebuffsTable"] = userDebuffsTable
                            targetEffects["targetBuffsTable"] = targetBuffsTable
                            targetEffects["targetDebuffsTable"] =
                                targetDebuffsTable

                            targetEffects["state"] = 'normal'

                            targetEffects = HandleRepel(targetEffects["ply"],
                                                        targetEffects["target"],
                                                        targetEffects)
                            if targetEffects["state"] == 'repel' then
                                self:AnnounceMessage(target:Name() ..
                                                         " repeled the attack!")
                            end
                            targetEffects = HandleResistances(
                                                targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)
                            targetEffects = HandleWeaknesses(
                                                targetEffects["ply"],
                                                targetEffects["target"],
                                                targetEffects)
                            targetEffects = HandleCrit(targetEffects["ply"],
                                                       targetEffects["target"],
                                                       targetEffects)
                            targetEffects = HandleBlock(targetEffects["ply"],
                                                        targetEffects["target"],
                                                        targetEffects)
                            targetEffects = HandleDrain(targetEffects["ply"],
                                                        targetEffects["target"],
                                                        targetEffects)

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

                            local currentTargetHP = targetEffects["target"]:GetNWInt(
                                                        "TBCHP", 100)
                            local maxTargetHP = targetEffects["target"]:GetNWInt(
                                                    "TBCMAXHP", 100)
                            local newHP

                            if targetEffects["state"] == "drain" then
                                newHP = math.min(currentTargetHP +
                                                     targetEffects["baseDamage"],
                                                 maxTargetHP)
                            else
                                newHP = currentTargetHP -
                                            targetEffects["baseDamage"]
                                HandleStatus(targetEffects["target"],
                                             targetEffects, "damageReaction",
                                             false, targetEffects)
                            end

                            targetEffects["target"]:SetNWInt("TBCHP", newHP)

                            self:AnnounceMessage(targetEffects["message"])

                            if newHP <= 0 then
                                targetEffects["target"]:SetNWInt("TBCHP", 0)

                                targetEffects["lifeState"] = "dead"
                                targetEffects = HandleDeath(
                                                    targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                                targetEffects = HandleKill(targetEffects["ply"],
                                                           targetEffects["target"],
                                                           targetEffects)

                                self:CheckForTeamDefeat(self.FightId)
                            end
                        end
                    end
                end
            end

        end
    end
    ply:LagCompensation(false)
end --
