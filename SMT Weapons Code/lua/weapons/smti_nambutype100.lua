include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Nambu Type 100"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "A handgun based on the design of that commissioned by the Japan LAW Syndicate. \n[STR 6] Damage: 45. \n[DEX 6] Technique: 25. \n[CHR 6] Bonus Crit Chance: +10%"
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Ranged Weapons"
SWEP.SpawnMenuIcon = "materials/entities/smti_nambutype100.png"

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

SWEP.DamageAmount = 40
SWEP.Tech = 20
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
            if not PlayerCheckEngageSWEP(ply) or not PlayerCheckFight(ply) or
                not TargetCheckValidity(ply, target, true) then
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()
            if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
            timer.Simple(TBC_CAST_DELAY, function()
                if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

            local playerDex = tonumber(self.Owner:GetNWInt("TBCDEX", 0))
            local tech = 20
            if playerDex >= 6 then tech = 25 end

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
            targetEffects["Affinity"] = self.Affinity

            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))

            if playerStr >= 6 then targetEffects["baseDamage"] = 45 end

            local playerLuck = ply:GetNWInt("TBCLuck", 10)

            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
                                 HandleStatus(ply, userDebuffsTable,
                                              "decreaseLuck", playerLuck))

            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            local critBonus = 0
            if playerChr >= 6 then critBonus = critBonus + 10 end

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
