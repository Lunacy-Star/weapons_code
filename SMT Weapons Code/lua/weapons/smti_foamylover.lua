include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Foamy Lover"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Lisa must have a Nuke-type skill and a Light-type skill to be able to use this ability (Persona skills applicable). Lisa hits all enemies twice, dealing 30 Nuke damage in the first hit and 30 Light damage in the second. The first hit has a chance of applying Charm by (Luck + CHR)%"
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

SWEP.DamageAmount = 30
SWEP.MPCost = 25
SWEP.Tech = 0
SWEP.Affinity = "Dual"
SWEP.Targets = "aoe"
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
    self:SetNextPrimaryFire(CurTime() + TBC_CAST_DELAY)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

    local tmin = Vector(1, 1, 1) * -15
    local tmax = Vector(1, 1, 1) * 15

    self:ShootEffects()
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(-1.5, 0, 0))
    self.BaseClass.ShootEffects(self)

    local nukeFound = false
    local lightFound = false
    for _, weapon in pairs(self.Owner:GetWeapons()) do
        if weapon.Affinity then
            if weapon.Affinity == "Nuke" then nukeFound = true end
            if weapon.Affinity == "Light" then lightFound = true end
        end
    end

    if SERVER then
        if nukeFound and lightFound then
            local target = self.Owner:GetEyeTrace().Entity

            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
                ply:LagCompensation(false)
                return
            end

            local userBuffsTable = GetAllStats(ply, "buffs")
            local userDebuffsTable = GetAllStats(ply, "debuffs")

            if not PlayerCanUseSkills(ply, userBuffsTable, userDebuffsTable) then
                ply:LagCompensation(false)
                return
            end

            local mpCost = self.MPCost

            if not PlayerCanUseMPSkills(ply, mpCost, userBuffsTable,
                                        userDebuffsTable) then
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()
            if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
            timer.Simple(TBC_CAST_DELAY, function()
                if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

            local tech = 0

            local targetedTargets = RollAoETargets(ply, target, self, tech)

            if next(targetedTargets) == nil then
                ply:ChatPrint(ply:Name() .. " hits literally nobody!")
            else
                for _, ent in pairs(targetedTargets) do
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

                    local newHP

                    for i = 1, 2 do

                        if i == 1 then
                            self.Affinity = "Nuke"
                        else
                            self.Affinity = "Light"
                        end

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

                        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))

                        local charmChance = math.ceil(playerLuck + playerChr)

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

                        targetEffects["state"] = 'normal'
                        targetEffects["message"] =
                            target:Name() .. " received " ..
                                targetEffects["baseDamage"] .. " damage."

                        local targetBuffsTable = GetAllStats(target, "buffs")
                        local targetDebuffsTable =
                            GetAllStats(target, "debuffs")

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

                        if i == 1 then
                            if math.random(1, 100) <= charmChance then

                                local debuffsTable = GetAllStats(
                                                         targetEffects["target"],
                                                         "debuffs")

                                debuffsTable["Charm"] = {
                                    stacks = 1,
                                    wearOff = "turnWearOff",
                                    duration = 4
                                }

                                AssignStat(targetEffects["target"], "Charm",
                                           debuffsTable["Charm"], "debuffs")

                                self:AnnounceMessage(
                                    targetEffects["target"]:Name() ..
                                        " is now Charmed!")

                                HandleStatus(targetEffects["ply"],
                                             userBuffsTable, "ailmentReaction",
                                             "Charm", targetEffects)
                            end
                        end

                        targetEffects = HandleDamageMessage(
                                            targetEffects["ply"],
                                            targetEffects["target"],
                                            targetEffects)

                        local currentHP =
                            targetEffects["target"]:GetNWInt("TBCHP", 100)
                        local maxHP = targetEffects["target"]:GetNWInt(
                                          "TBCMAXHP", 100)

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

            
            end)
        else
            ply:ChatPrint(
                "You can't use this skill without a Nuke and Light skill!")
        end
    end
    ply:LagCompensation(false)end --
