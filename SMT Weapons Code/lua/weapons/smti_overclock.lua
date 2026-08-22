include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Overclock (Soul Hack)"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Revives a party member, healing them with 30% of their HP. The revived party member immediately gains 1 Tarukaja, 1 Sukukaja, and 1 Rakukaja."
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
SWEP.MPCost = 135
SWEP.Affinity = "Support"
SWEP.IsHeal = true
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

            local inAFight = true

            local validEffectStatus = HealCheckValidity(ply, target)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            inAFight = validEffectStatus["inAFight"]

            local currentHP = target:GetNWInt("TBCHP", 100)
            if currentHP > 0 then
                local message = "You can't revive a target that's alive."
                ply:ChatPrint(message)
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

            local baseDamage = 0
            local maxHP = target:GetNWInt("TBCMAXHP", 100)

            baseDamage = maxHP * 0.30

            baseDamage = baseDamage *
                             (1 +
                                 (HandleStatus(ply, userBuffsTable,
                                               "increaseHeal", baseDamage) -
                                     HandleStatus(ply, userDebuffsTable,
                                                  "decreaseHeal", baseDamage)))

            baseDamage = baseDamage +
                             ((HandleStatus(ply, userBuffsTable,
                                            "flatIncreaseHeal", baseDamage) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "flatDecreaseHeal", baseDamage)))

            baseDamage = math.ceil(baseDamage)

            local newHP = math.min(currentHP + baseDamage, maxHP)

            target:SetNWInt("TBCHP", newHP)

            local message = target:Name() .. " revived with " .. baseDamage ..
                                " of healing, 1 Tarukaja, 1 Sukukaja, and 1 Rakukaja!"
            if inAFight then
                self:AnnounceMessage(message)

                targetEffects["ply"] = ply
                targetEffects["target"] = target

                local targetBuffsTable = GetAllStats(target, "buffs")

                targetBuffsTable["Tarukaja"] = {stacks = 1}
                targetEffects["buff"] = "Tarukaja"
                AssignStat(target, "Tarukaja", targetBuffsTable["Tarukaja"],
                           "buffs")
                HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                             targetEffects)
                targetBuffsTable["Sukukaja"] = {stacks = 1}
                AssignStat(target, "Sukukaja", targetBuffsTable["Sukukaja"],
                           "buffs")
                targetEffects["buff"] = "Sukukaja"
                HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                             targetEffects)
                targetBuffsTable["Rakukaja"] = {stacks = 1}
                AssignStat(target, "Rakukaja", targetBuffsTable["Rakukaja"],
                           "buffs")
                targetEffects["buff"] = "Rakukaja"
                HandleStatus(target, targetBuffsTable, "reactionBuff", "buff",
                             targetEffects)

                HandleStatus(ply, targetEffects["userBuffsTable"],
                             "reactionBuff", "buff", targetEffects)

                self:EndAbility()
            else
                ply:ChatPrint(target:Name() .. " revived with " .. baseDamage ..
                                  " of healing!")
                target:ChatPrint(ply:Name() .. " revived you with " ..
                                     baseDamage .. " of healing!")
            end
            end)
        end
    end

    ply:LagCompensation(false)
end --
