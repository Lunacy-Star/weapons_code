include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Spear"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "An ordinary spear with a sharp tip. Every Tarukaja on the wielder buffs crit damage by 4%+. \n[STR 6] Crit damage buff 5% instead. \n[DEX 6] Bonus Crit Chance 10% [CHR 6] Damage: 50."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Melee Weapons"
SWEP.SpawnMenuIcon = "materials/entities/smti_spear.png"

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

SWEP.DamageAmount = 45
SWEP.Tech = 18
SWEP.Affinity = "Blade"
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
            if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
            timer.Simple(TBC_CAST_DELAY, function()
                if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

            local tech = 18

            if not self:AbilityRollNumber(tech, target) then
                ply:LagCompensation(false)
                return
            end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")
            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local targetEffects = {}
            targetEffects["baseDamage"] = self.DamageAmount
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            if playerChr >= 6 then targetEffects["baseDamage"] = 50 end
            targetEffects["Affinity"] = self.Affinity

            local playerLuck = ply:GetNWInt("TBCLuck", 10)
            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
            local critBonus = 0
            if playerDex >= 6 then critBonus = critBonus + 10 end

            critBonus = critBonus +
                            (HandleStatus(ply, userBuffsTable,
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
            if targetEffects["state"] == 'crit' and userBuffsTable["Tarukaja"] then
                local playerStr = tonumber(
                                      targetEffects["ply"]:GetNWInt("TBCSTR", 0))
                if playerStr >= 6 then
                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] *
                            (1 + (0.05 * userBuffsTable["Tarukaja"]["stacks"]))
                else
                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] *
                            (1 + (0.04 * userBuffsTable["Tarukaja"]["stacks"]))
                end
            end
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
            end)
        end
    end

    ply:LagCompensation(false)
end --
