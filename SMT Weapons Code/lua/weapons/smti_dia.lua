include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Dia"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Heal based on 20% of target's max base HP. Heal 60 HP instead if Max Base HP <= 300. \n[CHR 4] Heal 25% of max base HP or 75 HP instead."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Skills"

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

SWEP.DamageAmount = 60
SWEP.MPCost = 10
SWEP.Affinity = "Support"
SWEP.IsHeal = true
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.FallsBackToSelf = true
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

    if true then
        local target = (tr.Hit and CheckIfValidTBCEntity(tr.Entity)) and tr.Entity or ply
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

            local inAFight = true

            local validEffectStatus = HealCheckValidity(ply, target)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            inAFight = validEffectStatus["inAFight"]

            self:AnnounceAbility()
            if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
            timer.Simple(TBC_CAST_DELAY, function()
                if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

            local currentHP = target:GetNWInt("TBCHP", 100)

            if currentHP <= 0 then
                local message = "You can't heal a target that's dead."
                ply:ChatPrint(message)
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

            local targetBuffsTable = GetAllStats(target, "buffs")
            local targetDebuffsTable = GetAllStats(target, "debuffs")

            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))

            local targetEffects = {}
            targetEffects["baseDamage"] = self.DamageAmount

            targetEffects["percentHeal"] = 0.20

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            if playerChr >= 4 then
                targetEffects["baseDamage"] = 75
                targetEffects["percentHeal"] = 0.25
            end

            local maxHP = target:GetNWInt("TBCMAXHP", 100)

            if maxHP <= 300 then
                targetEffects["baseDamage"] = maxHP *
                                                  targetEffects["percentHeal"]
            end

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            targetEffects["userBuffsTable"] = userBuffsTable
            targetEffects["userDebuffsTable"] = userDebuffsTable
            targetEffects["targetBuffsTable"] = targetBuffsTable
            targetEffects["targetDebuffsTable"] = targetDebuffsTable

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] * (1 +
                    ((HandleStatus(ply, userBuffsTable, "increaseHeal",
                                   targetEffects["baseDamage"], targetEffects) -
                        HandleStatus(ply, userDebuffsTable, "decreaseHeal",
                                     targetEffects["baseDamage"], targetEffects)) +
                        (HandleStatus(target, targetBuffsTable,
                                      "increaseHealReceive",
                                      targetEffects["baseDamage"]) -
                            HandleStatus(target, targetDebuffsTable,
                                         "decreaseHealReceive",
                                         targetEffects["baseDamage"]))))

            targetEffects["baseDamage"] =
                targetEffects["baseDamage"] +
                    (((HandleStatus(ply, userBuffsTable, "flatIncreaseHeal",
                                    targetEffects["baseDamage"]) -
                        HandleStatus(ply, userDebuffsTable, "flatDecreaseHeal",
                                     targetEffects["baseDamage"])) +
                        (HandleStatus(target, targetBuffsTable,
                                      "flatIncreaseHealReceive",
                                      targetEffects["baseDamage"]) -
                            HandleStatus(target, targetDebuffsTable,
                                         "flatDecreaseHealReceive",
                                         targetEffects["baseDamage"]))))

            targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

            HandleHealingEffects(ply, target, targetEffects)

            local newHP = math.min(currentHP + targetEffects["baseDamage"],
                                   maxHP)

            target:SetNWInt("TBCHP", newHP)

            local message = target:Name() .. " received " ..
                                targetEffects["baseDamage"] .. " healing from " ..
                                ply:Name() .. "!"
            if inAFight then
                self:AnnounceMessage(message)

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                HandleStatus(ply, targetEffects["userBuffsTable"],
                             "reactionBuff", "buff", targetEffects)

                self:EndAbility()
            else
                message = target:Name() .. " received " ..
                              targetEffects["baseDamage"] .. " healing!"
                ply:ChatPrint(message)
                message = ply:Name() .. " healed you for " ..
                              targetEffects["baseDamage"] .. "!"
                target:ChatPrint(message)
            end
            end)
        end
    end

    ply:LagCompensation(false)
end --

