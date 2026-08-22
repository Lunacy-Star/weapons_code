include("autorun/tbc_weapon_metatable.lua")
-- shared.lua

SWEP.PrintName = "Engage SWEP"
SWEP.Author = "Nara"
SWEP.Instructions = "Left-click to engage, Right-click to check combat status."
SWEP.Category = "Custom"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Weight = 5

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Slot = 0
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.InCombat = false -- Boolean variable to track combat status
SWEP.EngagedWith = nil -- Player this SWEP's owner is engaged with

setmetatable(SWEP, TBCWeaponMetatable) -- Ensure the Engage SWEP inherits from TBCWeaponMetatable
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.AilmentCheck = TBCWeaponMetatable.AilmentCheck
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility
SWEP.StartFight = TBCWeaponMetatable.StartFight
SWEP.JoinFight = TBCWeaponMetatable.JoinFight
SWEP.EndFight = TBCWeaponMetatable.EndFight
SWEP.NextTurn = TBCWeaponMetatable.NextTurn
SWEP.Escape = TBCWeaponMetatable.Escape
SWEP.Negotiation = TBCWeaponMetatable.Negotiation

function SWEP:Initialize()
    self:SetHoldType("melee")
    self.InCombat = false
    self.Allies = {} -- Table to keep track of allies
    self.Enemy = nil -- Reference to the enemy player
end

function SWEP:PrimaryAttack()

    self:SetNextPrimaryFire(CurTime() + TBC_CAST_DELAY) -- Adjust cooldown as necessary

    if CLIENT then return end

    local ply = self:GetOwner()

    -- Check if the attacking player is already InCombat
    if self.InCombat then
        ply:ChatPrint("You are already in a fight.")
        return
    end

    if ply:GetNWInt("TBCHP", 0) <= 0 then
        ply:ChatPrint("You can't engage someone while dead.")
        return
    end

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250 -- Adjust range as necessary

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

    if tr.Hit and CheckIfValidTBCEntity(tr.Entity) then
        local target = tr.Entity

        if target:IsPlayer() then
            local plyParty = IsPlayerInAnyParty(ply)
            if plyParty and plyParty == IsPlayerInAnyParty(target) then
                ply:ChatPrint("You can't engage a member of your own party.")
                ply:LagCompensation(false)
                return
            end
        end

        local hasEngageSWEP = false
        local targetEngageSWEP
        for _, weapon in ipairs(target:GetWeapons()) do
            if weapon:GetClass() == "smti_engageswep" then
                hasEngageSWEP = true
                targetEngageSWEP = weapon
                break
            end
        end

        -- Check if the target player is already InCombat
        if hasEngageSWEP and targetEngageSWEP.InCombat then
            ply:ChatPrint(target:Nick() .. " is already in a fight.")
            ply:LagCompensation(false)
            return
        end

        if target:GetNWInt("TBCHP", 0) <= 0 then
            ply:ChatPrint("You can't engage someone who's dead.")
            ply:LagCompensation(false)
            return
        end

        if hasEngageSWEP then
            self.InCombat = true -- engager is in combat
            local targetEngageSWEP = target:GetWeapon("smti_engageswep") -- get enemy as well
            targetEngageSWEP.InCombat = true -- engaged is in combat
            self:StartFight(target) -- Delegate starting the fight to TBCWeaponMetatable
            local msg = ply:Nick() .. " has engaged " .. target:Nick()
            for _, player in ipairs(player.GetAll()) do
                player:ChatPrint(msg)
            end
        end
    end

    ply:LagCompensation(false)

end--

function SWEP:SecondaryAttack()

    if CLIENT then return end

    local ply = self:GetOwner()
    ply:LagCompensation(true)

    -- Check if the attacking player is already InCombat
    if self.InCombat then
        ply:ChatPrint(
            "You cannot switch sides once you've engaged or joined a fight.")
        ply:LagCompensation(false)
        return
    end

    if ply:GetNWInt("TBCHP", 0) <= 0 then
        ply:ChatPrint("You can't engage someone while dead.")
        ply:LagCompensation(false)
        return
    end

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

    local tr = util.TraceLine({
        start = ShootPos,
        endpos = ShootEnd,
        filter = ply,
        mask = MASK_SHOT_HULL
    })

    if tr.Hit and CheckIfValidTBCEntity(tr.Entity) then
        local target = tr.Entity
        local targetEngageSWEP = target:GetWeapon("smti_engageswep")
        if targetEngageSWEP and targetEngageSWEP.InCombat then
            local fight =
                TBCWeaponMetatable.OngoingFights[targetEngageSWEP.FightId]

            if fight and fight.Started then
                ply:ChatPrint("This fight has already started, you can't join.")
                ply:LagCompensation(false)
                return
            end

            local sideToJoin =
                (table.HasValue(fight.Side1, target) and "Side1") or
                    (table.HasValue(fight.Side2, target) and "Side2")

            self.FightId = targetEngageSWEP.FightId
            self:JoinFight(sideToJoin) -- Delegate joining the fight to TBCWeaponMetatable
            self.InCombat = true -- Set InCombat flag to true for players joining the fight
            local msg = ply:Nick() .. " has joined the fight with " ..
                            target:Nick()
            for _, player in ipairs(player.GetAll()) do
                player:ChatPrint(msg)
            end
        end
    end

    ply:LagCompensation(false)

end--
