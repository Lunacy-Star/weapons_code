include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Comet Sweeper"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "A witch's broom said to fly faster than a comet and be able to sweep up even the shards of the stars. Increases Max MP by 30. Pressing secondary with this weapon unholstered lets the wielder fly for a moment while unholstered."
SWEP.Instructions = ""
SWEP.Category = "SMT Physical Melee Weapons"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"

SWEP.ViewModel = "models/weapons/smti_2hsword1_v.mdl" -- Viewmodel path
SWEP.WorldModel = "models/weapons/w_crowbar.mdl" -- Worldmodel path
SWEP.UseHands = true

SWEP.DamageAmount = 30
SWEP.Tech = 10
SWEP.Affinity = "Blunt"
SWEP.Targets = "single"
SWEP.WeaponType = "Melee"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Equipment"

SWEP.FlightPower = 800

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

            local tech = 10

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

            local playerLuck = ply:GetNWInt("TBCLuck", 10)
            playerLuck = playerLuck +
                             (HandleStatus(ply, userBuffsTable, "increaseLuck",
                                           playerLuck) -
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

            local attackerMP = targetEffects["ply"]:GetNWInt("TBCMP", 0) -- attacker's current TBCMP
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

    ply:LagCompensation(false)end --

function SWEP:SecondaryAttack()
    local ply = self.Owner
    if (ply:IsOnGround()) then
        self.Owner:SetVelocity(self.Owner:GetAimVector() * self.FlightPower)
        self:SetNextSecondaryFire(CurTime() + 5)
    end
end

function SWEP:Think()
    local ply = self.Owner

    if not (ply:IsOnGround()) then
        local vel = ply:GetVelocity()
        if vel.z < -10 then
            vel.x = 0
            vel.y = 0
            vel.z = -vel.z * 3 * 1 / 100
            ply:SetVelocity(vel)
        end
    end
end

function SWEP:Equip(ply)
    if SERVER then
        timer.Create(ply:Name() .. self.PrintName, 0.2, 1, function()
            local currentMP = ply:GetNWInt("TBCMP", 100)
            local maxMP = ply:GetNWInt("TBCMAXMP", 100)
            if currentMP >= maxMP then
                ply:SetNWInt("TBCMP", maxMP + 30)
            end
            ply:SetNWInt("TBCMAXMP", maxMP + 30)
        end)
    end
end

function SWEP:DropFunction()
    if SERVER and IsValid(self.Owner) then
        local currentMP = self.Owner:GetNWInt("TBCMP", 100)
        local maxMP = self.Owner:GetNWInt("TBCMAXMP", 100)
        if currentMP >= maxMP then
            self.Owner:SetNWInt("TBCMP", maxMP - 30)
        end
        self.Owner:SetNWInt("TBCMAXMP", maxMP - 30)
    end
end
