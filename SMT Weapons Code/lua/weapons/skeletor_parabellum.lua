include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "9x19mm Parabellum"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "User one-shots the target unless their name is He-Man, in which the user dies instantly upon even approaching the target named He-Man."
SWEP.Instructions = ""
SWEP.Category = "Skeletor Physical Ranged Weapons"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 5
SWEP.Primary.DefaultClip = 5
SWEP.Primary.Ammo = "pistol"
SWEP.Primary.Automatic = true
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

SWEP.DamageAmount = 999999
SWEP.Affinity = "Gun"
SWEP.Targets = "single"
SWEP.WeaponType = "Gun"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

function SWEP:Initialize()
    self.CanUseAbility = true
    self.LuckModified = false
end

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

        if SERVER and IsValid(target) then

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

            local attackerHP = ply:GetNWInt("TBCHP", 100)
            local hpCost = 6.66

            if attackerHP >= hpCost then
                ply:SetNWInt("TBCHP", attackerHP - hpCost)
            else
                ply:ChatPrint("Not enough HP to use this gun.")
                ply:LagCompensation(false)
                return
            end

            local weaponTech = -25
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))

            if playerDex >= 4 then weaponTech = -30 end

            if self:AbilityRollNumber(weaponTech, tr.Entity) then
                local targetEffects = {}
                local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))

                targetEffects["baseDamage"] = self.DamageAmount
                targetEffects["Affinity"] = self.Affinity

                local playerLuck = ply:GetNWInt("TBCLuck", 10)

                playerLuck = playerLuck +
                                 (HandleStatus(ply, userBuffsTable,
                                               "increaseLuck", playerLuck) -
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
                                            targetEffects["target"],
                                            targetEffects)
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
                                      targetEffects["userBuffsTable"], "damage",
                                      targetEffects["baseDamage"], targetEffects) -
                            HandleStatus(targetEffects["ply"],
                                         targetEffects["userDebuffsTable"],
                                         "decreaseDamage",
                                         targetEffects["baseDamage"],
                                         targetEffects)) -
                        (HandleStatus(targetEffects["target"],
                                      targetEffects["targetBuffsTable"],
                                      "defenseDamage",
                                      targetEffects["baseDamage"], targetEffects) -
                            HandleStatus(targetEffects["target"],
                                         targetEffects["targetDebuffsTable"],
                                         "defenseDecrease",
                                         targetEffects["baseDamage"],
                                         targetEffects))

                targetEffects["baseDamage"] = math.ceil(
                                                  targetEffects["baseDamage"])

                targetEffects = HandleDamageMessage(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)

                local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
                local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
                local newHP

                if targetEffects["state"] == "drain" then
                    newHP = math.min(currentHP + targetEffects["baseDamage"],
                                     maxHP)
                else
                    newHP = currentHP - targetEffects["baseDamage"]
                    HandleStatus(targetEffects["target"], targetEffects,
                                 "damageReaction", false, targetEffects)
                end

                if targetEffects["target"]:Name() == "He Man" then
                    targetEffects["ply"]:SetNWInt("TBCHP", 0)
                    targetEffects["message"] =
                        targetEffects["ply"]:Name() .. " is defeated by He-Man!"
                    self:AnnounceMessage(targetEffects["message"])

                else
                    targetEffects["target"]:SetNWInt("TBCHP", 0)
                    targetEffects["message"] =
                        targetEffects["target"]:Name() .. " is kill"

                    if newHP <= 0 then
                        targetEffects["target"]:SetNWInt("TBCHP", 0)
                        self:AnnounceMessage(targetEffects["message"])

                        targetEffects["lifeState"] = "dead"
                        targetEffects = HandleDeath(targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                        targetEffects = HandleKill(targetEffects["ply"],
                                                   targetEffects["target"],
                                                   targetEffects)

                        self:CheckForTeamDefeat(self.FightId)
                    else
                        self:AnnounceMessage(targetEffects["message"])

                        local totalBonusDamage = 0
                        if targetEffects["state"] == "crit" then
                            totalBonusDamage = HandleBonusDamage(
                                                   targetEffects["ply"],
                                                   targetEffects["target"],
                                                   targetEffects)
                        end

                        if totalBonusDamage > 0 then
                            newHP = newHP - totalBonusDamage
                            targetEffects["target"]:SetNWInt("TBCHP", newHP)
                            HandleStatus(targetEffects["target"], targetEffects,
                                         "damageReaction", false, targetEffects)
                            if newHP <= 0 then
                                targetEffects["target"]:SetNWInt("TBCHP", 0)

                                targetEffects["lifeState"] = "dead"
                                targetEffects = HandleDeath(
                                                    targetEffects["ply"],
                                                    targetEffects["target"],
                                                    targetEffects)
                                targetEffects =
                                    HandleKill(targetEffects["ply"],
                                               targetEffects["target"],
                                               targetEffects)
                            end
                        end
                    end

                end
                self:CheckForTeamDefeat(self.FightId)

                
            end
        end
    end

    ply:LagCompensation(false)
end --

function SWEP:Deploy()
    if SERVER then
        local playerChr = tonumber(self:GetOwner():GetNWInt("TBCCHR", 0))

        if playerChr >= 4 and not self.LuckModified then
            local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
            self.Owner:SetNWInt("TBCLuck", playerLuck - 6)
            self.LuckModified = true
        end
    end
end

function SWEP:Equip(ply)
    if SERVER then
        timer.Create(ply:Name() .. self.PrintName, 0.2, 1, function()
            local playerChr = tonumber(self:GetOwner():GetNWInt("TBCCHR", 0))

            if playerChr >= 4 and not self.LuckModified then
                local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
                self.Owner:SetNWInt("TBCLuck", playerLuck - 6)
                self.LuckModified = true
            elseif playerChr < 4 and self.LuckModified then
                local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
                self.Owner:SetNWInt("TBCLuck", playerLuck + 6)
                self.LuckModified = false
            end
        end)
    end
end

function SWEP:DropFunction()
    if SERVER and IsValid(self.Owner) then
        if self.LuckModified then
            local playerLuck = self.Owner:GetNWInt("TBCLuck", 10)
            self.Owner:SetNWInt("TBCLuck", playerLuck + 6)
        end

    end
end
