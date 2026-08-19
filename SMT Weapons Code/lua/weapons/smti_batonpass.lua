include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Baton Pass"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "No MP cost. Requires One More. Passes your turn and One More to the next member in the turn order, granting them Baton Pass. Cannot be used on the last turn of the cycle."
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
SWEP.AnnounceAbility = TBCWeaponMetatable.AnnounceAbility
SWEP.AnnounceMessage = TBCWeaponMetatable.AnnounceMessage
SWEP.AbilityRollNumber = TBCWeaponMetatable.AbilityRollNumber
SWEP.CheckForTeamDefeat = TBCWeaponMetatable.CheckForTeamDefeat
SWEP.EndAbility = TBCWeaponMetatable.EndAbility

local ShootSound = Sound("Weapon_357.single")

-- Self-only: passes One More (and the turn) to the next member in the turn
-- order. Mirrors the /bp and /batonpass chat command in tbc_commands.lua
-- (TBCBatonPass hook), including acting through a controlled demon companion
-- on its turn — keep both in sync if either changes.
function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)

    local ply = self:GetOwner()

    ply:LagCompensation(true)

    local ShootPos = ply:GetShootPos()
    local ShootEnd = ShootPos + ply:GetAimVector() * 250

    self:ShootEffects()
    self:EmitSound(ShootSound)
    self.Owner:ViewPunch(Angle(-1.5, 0, 0))
    self.BaseClass.ShootEffects(self)

    if ply:IsPlayer() then
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
            if not fight then
                ply:LagCompensation(false)
                return
            end

            local currentActiveSide = fight.ActiveSide
            local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

            -- The entity whose One More is being passed: the player, or their
            -- demon companion if they are acting through it on its turn.
            -- PlayerCheckFight already guarantees currentTurnPlayer is one of
            -- these two.
            local actingEntity = ply
            local controlledDemon = ply.TBCControlledDemon
            if IsValid(controlledDemon) and currentTurnPlayer == controlledDemon then
                actingEntity = controlledDemon
            end

            if fight.TurnCounter > 1 then
                local userBuffsTable = GetAllStats(actingEntity, "buffs")
                if userBuffsTable["One_More"] then
                    -- pass to the NEXT member in the turn order, wrapping around
                    local nextMemberIndex = fight.ActiveMember + 1
                    if nextMemberIndex > #fight[fight.ActiveSide] then
                        nextMemberIndex = 1
                    end

                    local nextTurnPlayer =
                        fight[fight.ActiveSide][nextMemberIndex]

                    self:AnnounceMessage(actingEntity:Name() ..
                                             " has passed the baton to " ..
                                             nextTurnPlayer:Name() .. "!")

                    RemoveStat(actingEntity, "One_More", "buffs")

                    local targetBuffsTable =
                        GetAllStats(nextTurnPlayer, "buffs")

                    targetBuffsTable["Baton_Pass"] = {stacks = 1, duration = 1}

                    AssignStat(nextTurnPlayer, "Baton_Pass",
                               targetBuffsTable["Baton_Pass"], "buffs")

                    nextTurnPlayer:ChatPrint("You now have Baton Pass!")

                    self:EndAbility()
                else
                    ply:ChatPrint(
                        "You don't have One More. Therefore, you don't have a baton to pass...")
                    ply:LagCompensation(false)
                    return
                end
            else
                ply:ChatPrint(
                    "This is the last turn in the turn cycle. You cannot baton pass.")
                ply:LagCompensation(false)
                return
            end
        end
    end

    ply:LagCompensation(false)
end --
