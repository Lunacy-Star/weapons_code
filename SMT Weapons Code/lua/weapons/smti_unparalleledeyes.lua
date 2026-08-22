include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Unparalleled Eyes"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Deal 10 Ice damage to all enemies. If one of the enemies he is targeting has less Sukukaja stacks than Yusuke, this deals 20 damage to that target instead."
SWEP.Instructions = ""
SWEP.Category = "SMT Combat Tactics"

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

SWEP.DamageAmount = 10
SWEP.Affinity = "Ice"
SWEP.Targets = "aoe"
SWEP.WeaponType = "Combat Tactic"
SWEP.SlotsTaking = 0
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

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            ply:LagCompensation(false)
            return
        end

        local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
        if fight then
        else
            return
        end

        local playerSide = (table.HasValue(fight.Side1, target) and "Side1") or
                               (table.HasValue(fight.Side2, target) and "Side2")

        local targetedTargets = {}
        for _, player in ipairs(fight[playerSide]) do
            if CheckIfValidTBCEntity(player) then
                table.insert(targetedTargets, player)
            end
        end

        self:AnnounceAbility()
        if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
        timer.Simple(TBC_CAST_DELAY, function()
            if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

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

                local targetBuffsTable = GetAllStats(target, "buffs")
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                local targetEffects = {}
                targetEffects["baseDamage"] = self.DamageAmount
                targetEffects["Affinity"] = self.Affinity

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
                    target = ply
                end

                local userSukuCount = 0
                if targetEffects["userBuffsTable"]["Sukukaja"] then
                    userSukuCount =
                        targetEffects["userBuffsTable"]["Sukukaja"]["stacks"]
                end
                if targetEffects["userDebuffsTable"]["Sukunda"] then
                    userSukuCount = userSukuCount -
                                        targetEffects["userDebuffsTable"]["Sukunda"]["stacks"]
                end

                local targetSukuCount = 0
                if targetEffects["targetBuffsTable"]["Sukukaja"] then
                    userSukuCount =
                        targetEffects["targetBuffsTable"]["Sukukaja"]["stacks"]
                end
                if targetEffects["targetDebuffsTable"]["Sukunda"] then
                    targetSukuCount = targetSukuCount -
                                          targetEffects["targetDebuffsTable"]["Sukunda"]["stacks"]
                end

                if userSukuCount > targetSukuCount then
                    targetEffects["baseDamage"] =
                        targetEffects["baseDamage"] + 10
                end

                targetEffects = HandleResistances(targetEffects["ply"],
                                                  targetEffects["target"],
                                                  targetEffects)
                targetEffects = HandleWeaknesses(targetEffects["ply"],
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
            end

        end
        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

        self:EndAbility()
        end)
    end

    ply:LagCompensation(false)
end --
