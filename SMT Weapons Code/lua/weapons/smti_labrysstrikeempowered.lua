include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Labrys Strike (Empowered)"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "[Physical] [Phase 3: 1000 HP or lower]\nDeals 1-4 hits to multiple foes, each dealing 50 physical damage. Has Pierce and also negates Repel Phys."
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

SWEP.DamageAmount = 50
SWEP.PhaseThreshold = 1000
SWEP.Tech = 0
SWEP.Affinity = "Physical"
SWEP.Pierce = true
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
                ply:ChatPrint("Labrys Strike (Empowered) is not available yet.")
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

            local tech = self.Tech

            local targetedTargets = RollAoETargets(ply, target, self, tech)

            if next(targetedTargets) == nil then
                ply:ChatPrint(ply:Name() .. " hits literally nobody!")
            else
                local loopIterations = math.random(1, 4)

                for i = 1, loopIterations do
                    local randomIndex = math.random(1, #targetedTargets)
                    local selectedPlayer = targetedTargets[randomIndex]

                    local target = selectedPlayer
                    local dmg = DamageInfo()
                    dmg:SetDamage(0)
                    dmg:SetAttacker(ply)
                    dmg:SetInflictor(self)
                    dmg:SetDamageForce(ply:GetAimVector())
                    dmg:SetDamagePosition(target:GetPos())
                    dmg:SetDamageType(DMG_CLUB)
                    target:DispatchTraceAttack(dmg, ShootPos +
                                                   ply:EyeAngles():Right() * -5,
                                               ShootEnd)

                    if IsValid(target) then

                        local userBuffsTable = GetAllStats(ply, "buffs")
                        local userDebuffsTable = GetAllStats(ply, "debuffs")
                        local targetBuffsTable = GetAllStats(target, "buffs")
                        local targetDebuffsTable =
                            GetAllStats(target, "debuffs")

                        local targetEffects = {}
                        targetEffects["baseDamage"] = self.DamageAmount
                        targetEffects["Affinity"] = self.Affinity

                        local playerLuck = ply:GetNWInt("TBCLuck", 10)
                        playerLuck = playerLuck +
                                         (HandleStatus(ply, userBuffsTable,
                                                       "increaseLuck",
                                                       playerLuck) -
                                             HandleStatus(ply, userDebuffsTable,
                                                          "decreaseLuck",
                                                          playerLuck))

                        local critBonus =
                            (HandleStatus(ply, userBuffsTable,
                                          "increaseCritChance",
                                          targetEffects["baseDamage"]) -
                                HandleStatus(ply, userDebuffsTable,
                                             "decreaseCritChance",
                                             targetEffects["baseDamage"]))

                        targetEffects["critChance"] = math.ceil(
                                                          (playerLuck / 2) +
                                                              critBonus)

                        targetEffects["ply"] = ply
                        targetEffects["target"] = target

                        targetEffects["userBuffsTable"] = userBuffsTable
                        targetEffects["userDebuffsTable"] = userDebuffsTable
                        targetEffects["targetBuffsTable"] = targetBuffsTable
                        targetEffects["targetDebuffsTable"] = targetDebuffsTable

                        targetEffects["state"] = 'normal'

                        -- Pierce: ignores Resist/Block/Drain/Repel entirely (also negates Repel Phys). Weakness/Crit still apply.
                        targetEffects = HandleWeaknesses(targetEffects["ply"],
                                                         targetEffects["target"],
                                                         targetEffects)
                        targetEffects = HandleCrit(targetEffects["ply"],
                                                   targetEffects["target"],
                                                   targetEffects)

                        targetEffects["attacker"] = targetEffects["ply"]
                        targetEffects["target"] = targetEffects["target"]
                        targetEffects["weaponTargets"] = targetedTargets

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
                        local newHP = currentHP - targetEffects["baseDamage"]

                        HandleStatus(targetEffects["target"], targetEffects,
                                     "damageReaction", false, targetEffects)

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

        end
    end
    ply:LagCompensation(false)
end --
