include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Akasha Arts"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Deal 68 martial art damage (all enemies). Having a Martial Art weapon equipped makes this deal 72 damage instead. \n[STR 6] HP Cost reduced to 24 HP [DEX 6] Bonus Crit Chance 10%+."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Skills"

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

SWEP.DamageAmount = 68
SWEP.HPCost = 24
SWEP.Tech = 0
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

if SERVER then util.AddNetworkString("UpdateTargetedPlayers") end

local ShootSound = Sound("Weapon_357.single")

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.4)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 120

    local tmin = Vector(1, 1, 1) * -10
    local tmax = Vector(1, 1, 1) * 10

    self:ShootEffects()
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(-1.5, 0, 0))
    self.BaseClass.ShootEffects(self)

    if SERVER then
        local target = self.Owner:GetEyeTrace().Entity

        if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
            not TargetCheckValidity(ply, target, true) then
            ply:LagCompensation(false)
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
        local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
        if playerStr >= 6 then hpCost = 24 end

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

        self:AnnounceAbility()

        local targetedTargets = RollAoETargets(ply, target, self, 0)

        if next(targetedTargets) == nil then
            ply:ChatPrint(ply:Name() .. " hits literally nobody!")
        else
            for _, ent in pairs(targetedTargets) do
                if CheckIfValidTBCEntity(ent) then
                    local target = ent
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

                    if SERVER and IsValid(target) then

                        local userBuffsTable = GetAllStats(ply, "buffs")
                        local userDebuffsTable = GetAllStats(ply, "debuffs")
                        local targetBuffsTable = GetAllStats(target, "buffs")
                        local targetDebuffsTable =
                            GetAllStats(target, "debuffs")

                        local targetEffects = {}
                        targetEffects["baseDamage"] = self.DamageAmount
                        for _, weapon in pairs(ply:GetWeapons()) do
                            if weapon.WeaponType then
                                if "Martial Arts" == weapon.WeaponType then
                                    targetEffects["baseDamage"] = 72
                                    break
                                end
                            end
                        end

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

                        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
                        if playerDex >= 6 then
                            critBonus = critBonus + 10
                        end

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

                        targetEffects = HandleRepel(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        if targetEffects["state"] == 'repel' then
                            self:AnnounceMessage(target:Name() ..
                                                     " repeled the attack!")
                        end
                        targetEffects = HandleResistances(targetEffects["ply"],
                                                          targetEffects["target"],
                                                          targetEffects)
                        targetEffects = HandleWeaknesses(targetEffects["ply"],
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

        end
    end
    ply:LagCompensation(false)
end --
