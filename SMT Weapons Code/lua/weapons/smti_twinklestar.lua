include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Twinkle☆Star"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Restore 10% of Rise's Max MP to all party members including Rise herself. If this restores past a target's Max MP, grant +1 to a Random Kaja buff stack to that target."
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

SWEP.DamageAmount = 0
SWEP.Affinity = "Support"
SWEP.WeaponType = "Combat Tactic"
SWEP.SlotsTaking = 0
SWEP.SlotType = "Equipment"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.PrimarySelfOnly = true
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

    local target = ply
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

        if not targetEffects["userBuffsTable"]["One_More"] then
            ply:ChatPrint("You cannot use Combat Tactics without One More.")
            ply:LagCompensation(false)
            return
        end

        self:AnnounceAbility()
        if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
        timer.Simple(TBC_CAST_DELAY, function()
            if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

        local playerSide = (table.HasValue(fight.Side1, target) and "Side1") or
                               (table.HasValue(fight.Side2, target) and "Side2")

        local playersInFight = {}
        for _, player in ipairs(fight[playerSide]) do
            if IsValid(player) then
                local currentHP = player:GetNWInt("TBCHP", 100)
                if currentHP > 0 then
                    table.insert(playersInFight, player)
                end
            end
        end

        targetEffects["ply"] = ply

        local casterMaxMP = ply:GetNWInt("TBCMP", 100)
        local MPToRecover = casterMaxMP * 0.10

        for _, player in ipairs(playersInFight) do
            if TargetCheckValidity(ply, player) then
                targetEffects["target"] = player

                local currentMP = player:GetNWInt("TBCMP", 100)
                local maxMP = player:GetNWInt("TBCMAXMP", 100)

                local newMP = math.min(currentMP + MPToRecover, maxMP)
                newMP = math.ceil(newMP)
                player:SetNWInt("TBCMP", newMP)
                player:ChatPrint("You recover " .. MPToRecover .. " MP!")

                if (currentMP + MPToRecover) > maxMP then
                    HandleRandomKaja(ply, player, targetEffects)
                end
            end
        end

        RemoveStat(ply, "One_More", "buffs")
        HandleStatus(ply, userBuffsTable, "comtacReaction", false, targetEffects)

        local message = ply:Name() .. " restored some of the MP of the party!"

        self:AnnounceMessage(message)

        self:EndAbility()
        end)
    end

    ply:LagCompensation(false)
end --
