include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Spotlight (Persona)"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Heal an ally aside from yourself for 25%, granting them +1 of all Kaja. \n[CHR 4] Restore 25 SP to the target as well."
SWEP.Instructions = ""
SWEP.Category = "Persona Support Skills"

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

SWEP.Slot = 5
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/smti_handgun1_v.mdl"
SWEP.WorldModel = "models/weapons/default/w_357.mdl"

SWEP.UseHands = true

SWEP.SetHoldType = "revolver"

SWEP.DamageAmount = 0
SWEP.MPCost = 45
SWEP.Affinity = "Support"
SWEP.IsHeal = true
SWEP.WeaponType = "Magic Skill"
SWEP.SlotsTaking = 0
SWEP.SlotType = "Equipment"
SWEP.PersonaSkill = true

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

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

            if target == ply then
                ply:ChatPrint("You must target an ally other than yourself.")
                ply:LagCompensation(false)
                return
            end

            local validEffectStatus = HealCheckValidity(ply, target)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()

            local currentHP = target:GetNWInt("TBCHP", 100)

            if currentHP <= 0 then
                local message = "You can't heal a target that's dead."
                ply:ChatPrint(message)
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

            targetEffects["baseDamage"] = 0
            targetEffects["percentHeal"] = 0.25

            local maxHP = target:GetNWInt("TBCMAXHP", 100)
            targetEffects["baseDamage"] = maxHP * targetEffects["percentHeal"]

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

            local kajaList = {"Tarukaja", "Sukukaja", "Rakukaja"}
            local kajaStacksMessage = {}

            for _, kajaBuff in ipairs(kajaList) do
                if targetBuffsTable[kajaBuff] then
                    targetBuffsTable[kajaBuff].stacks =
                        math.min(targetBuffsTable[kajaBuff].stacks + 1, 4)
                else
                    targetBuffsTable[kajaBuff] = {stacks = 1}
                end

                AssignStat(target, kajaBuff, targetBuffsTable[kajaBuff], "buffs")

                table.insert(kajaStacksMessage,
                             targetBuffsTable[kajaBuff].stacks .. " " .. kajaBuff)
            end

            if playerChr >= 4 then
                local currentMP = target:GetNWInt("TBCMP", 100)
                local maxMP = target:GetNWInt("TBCMAXMP", 100)
                target:SetNWInt("TBCMP", math.min(currentMP + 25, maxMP))
            end

            local message = target:Name() .. " received " ..
                                targetEffects["baseDamage"] ..
                                " healing from " .. ply:Name() ..
                                "! They now have " ..
                                table.concat(kajaStacksMessage, ", ") .. "!"

            self:AnnounceMessage(message)

            targetEffects["ply"] = ply
            targetEffects["target"] = target

            HandleStatus(ply, targetEffects["userBuffsTable"], "reactionBuff",
                         "buff", targetEffects)

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --
