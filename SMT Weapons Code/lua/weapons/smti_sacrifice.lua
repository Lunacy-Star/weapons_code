include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Sacrifice"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Can only be used after the first turn cycle has passed and current HP is less than 50%. User blows up on the enemies, reducing all opponent's MP by 60. User dies permanently for the fight and can no longer participate in it."
SWEP.Instructions = ""
SWEP.Category = "SMT Almighty Skills"

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
SWEP.HPCost = 9999
SWEP.Tech = 0
SWEP.Affinity = "Almighty"
SWEP.Targets = "aoe"
SWEP.WeaponType = "Almighty Skill"
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

        local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
        if fight then
        else
            ply:LagCompensation(false)
            return
        end

        if fight.CyclesDone < 1 then
            ply:ChatPrint("It's not your time yet.")
            ply:LagCompensation(false)
            return
        end

        local attackerHP = ply:GetNWInt("TBCHP", 100)
        local maxHP = ply:GetNWInt("TBCMAXHP", 100)

        if attackerHP <= (maxHP / 2) then
            ply:SetNWInt("TBCHP", 0)
        else
            ply:ChatPrint("It's not your time yet.")
            ply:LagCompensation(false)
            return
        end

        self:AnnounceAbility()

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

                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")
                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                local targetEffects = {}
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

                targetEffects["attacker"] = targetEffects["ply"]
                targetEffects["target"] = targetEffects["target"]
                targetEffects["weaponTargets"] = targetedTargets

                targetEffects["baseDamage"] = math.ceil(
                                                  targetEffects["baseDamage"])

                local currentMP = targetEffects["target"]:GetNWInt("TBCMP", 100)
                local newMP

                newMP = currentMP - targetEffects["baseDamage"]

                if newMP <= 0 then newMP = 0 end

                targetEffects["target"]:SetNWInt("TBCMP", newMP)

                targetEffects["message"] =
                    targetEffects["target"]:Name() .. " has lost " ..
                        targetEffects["baseDamage"] .. " MP!"

                self:AnnounceMessage(targetEffects["message"])
            end
        end

        ply:Kill()
        self:CheckForTeamDefeat(self.FightId)
    end

    ply:LagCompensation(false)
end --
