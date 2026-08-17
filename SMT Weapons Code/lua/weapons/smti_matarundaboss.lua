include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Matarunda"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "[Boss] [Phase 2: 80% of Max HP or lower]\nTarunda +1 to all enemies."
SWEP.Instructions = ""
SWEP.Category = "SMT Boss Skills"

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

SWEP.DamageAmount = 0
SWEP.PhaseThreshold = 0.8
SWEP.Affinity = "Support"
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

            local currentHP = ply:GetNWInt("TBCHP", 0)
            local maxHP = ply:GetNWInt("TBCMAXHP", 1)
            if currentHP > maxHP * self.PhaseThreshold then
                ply:ChatPrint("Matarunda is not available yet.")
                ply:LagCompensation(false)
                return
            end

            self:AnnounceAbility()

            local fight = TBCWeaponMetatable.OngoingFights[self.FightId]
            if fight then
            else
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

            local playerSide =
                (table.HasValue(fight.Side1, target) and "Side1") or
                    (table.HasValue(fight.Side2, target) and "Side2")

            local playersInFight = {}
            for _, player in ipairs(fight[playerSide]) do
                if IsValid(player) then
                    local memberHP = player:GetNWInt("TBCHP", 100)
                    if memberHP > 0 then
                        table.insert(playersInFight, player)
                    end
                end
            end

            for _, player in ipairs(playersInFight) do
                targetEffects["targetDebuffsTable"] = GetAllStats(player,
                                                                  "debuffs")

                if targetEffects["targetDebuffsTable"]["Tarunda"] then
                    targetEffects["targetDebuffsTable"]["Tarunda"].stacks =
                        math.min(targetEffects["targetDebuffsTable"]["Tarunda"]
                                     .stacks + 1, 4)
                else
                    targetEffects["targetDebuffsTable"]["Tarunda"] = {
                        stacks = 1
                    }
                end

                AssignStat(player, "Tarunda",
                           targetEffects["targetDebuffsTable"]["Tarunda"],
                           "debuffs")

                targetEffects["debuff"] = "Tarunda"

                HandleStatus(player, GetAllStats(player, "buffs"),
                             "reactionDebuff", "debuff", targetEffects)

                local message = player:Name() .. " received Tarunda from " ..
                                    ply:Name() .. "! They now have " ..
                                    targetEffects["targetDebuffsTable"]["Tarunda"]
                                        .stacks .. " Tarunda!"

                self:AnnounceMessage(message)
            end

            self:EndAbility()
        end
    end

    ply:LagCompensation(false)
end --
