include("autorun/tbc_weapon_metatable.lua")

SWEP.PrintName = "Chakra Powder"
SWEP.Author = "Nara"
SWEP.Contact = ""
SWEP.Purpose =
    "Scattering this powder recovers the mana of users within its range. Ammo Stack = 2. Effect: Recovers party's MP by 40."
SWEP.Instructions = ""
SWEP.Category = "SMT Support Items"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Primary.ClipSize = 2
SWEP.Primary.DefaultClip = 2
SWEP.Primary.Ammo = "items"
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

SWEP.Slot = 3
SWEP.SlotPos = 2
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/smti_handgun1_v.mdl"
SWEP.WorldModel = "models/weapons/default/w_357.mdl"

SWEP.UseHands = true

SWEP.SetHoldType = "revolver"

SWEP.DamageAmount = 40
SWEP.Affinity = "Support"
SWEP.WeaponType = "Curative"
SWEP.SlotsTaking = 1
SWEP.SlotType = "Item"

setmetatable(SWEP, TBCWeaponMetatable)
SWEP.FallsBackToSelf = true
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

    if true then
        local target = (tr.Hit and CheckIfValidTBCEntity(tr.Entity)) and tr.Entity or ply
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
            local inAFight = true

            local validEffectStatus = HealCheckValidity(ply, ply)

            if not validEffectStatus then
                ply:LagCompensation(false)
                return
            end

            inAFight = validEffectStatus["inAFight"]

            if inAFight then
                self:AnnounceAbility()
                if not IsValid(self) or not IsValid(ply) or not TBCWeaponMetatable.OngoingFights[self.FightId] then return end
                timer.Simple(TBC_CAST_DELAY, function()
                    if SMTParticles then SMTParticles.TriggerForWeapon(self, target) end

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

                local playerSide = (table.HasValue(fight.Side1, target) and
                                       "Side1") or
                                       (table.HasValue(fight.Side2, target) and
                                           "Side2")

                local playersInFight = {}
                for _, player in ipairs(fight[playerSide]) do
                    if IsValid(player) then
                        table.insert(playersInFight, player)
                    end
                end

                local lastPlayer = ply
                for _, target in ipairs(playersInFight) do
                    if IsValid(target) then -- Check if the player is valid
                        local currentHP = target:GetNWInt("TBCHP", 100)
                        if currentHP > 0 then
                            local targetBuffsTable =
                                GetAllStats(target, "buffs")
                            local targetDebuffsTable = GetAllStats(target,
                                                                   "debuffs")

                            local targetEffects = {}
                            targetEffects["baseDamage"] = self.DamageAmount

                            targetEffects["ply"] = ply
                            targetEffects["target"] = target

                            targetEffects["userBuffsTable"] = userBuffsTable
                            targetEffects["userDebuffsTable"] = userDebuffsTable
                            targetEffects["targetBuffsTable"] = targetBuffsTable
                            targetEffects["targetDebuffsTable"] =
                                targetDebuffsTable

                            targetEffects["baseDamage"] = math.ceil(
                                                              targetEffects["baseDamage"])

                            HandleHealingEffects(ply, target, targetEffects)

                            local maxMP = target:GetNWInt("TBCMAXMP", 100)
                            local currentMP = target:GetNWInt("TBCMP", 100)

                            local newMP =
                                math.min(currentMP + targetEffects["baseDamage"],
                                         maxMP)

                            target:SetNWInt("TBCMP", newMP)

                            local message =
                                target:Name() .. " received " ..
                                    targetEffects["baseDamage"] .. " MP from " ..
                                    ply:Name() .. "!"
                            self:AnnounceMessage(message)
                        end
                    end
                end

                self:EndAbility()
                end)
            else
                local tr = util.TraceLine({
                    start = self.Owner:EyePos(),
                    endpos = self.Owner:EyePos() + self.Owner:GetAimVector() *
                        1000,
                    filter = self.Owner
                })

                local aoeCenter = tr.HitPos

                local playersInArea = ents.FindInSphere(aoeCenter, 100)

                for _, target in ipairs(playersInArea) do
                    if IsValid(target) and CheckIfValidTBCEntity(target) then -- Check if the player is valid
                        local targetEngageSWEP
                        for _, weapon in ipairs(target:GetWeapons()) do
                            if weapon:GetClass() == "smti_engageswep" then
                                targetEngageSWEP = weapon
                                break
                            end
                        end

                        if targetEngageSWEP.FightId == self.FightId then
                            local currentHP = target:GetNWInt("TBCHP", 100)
                            if currentHP > 0 then
                                local userBuffsTable = GetAllStats(ply, "buffs")
                                local userDebuffsTable = GetAllStats(ply,
                                                                     "debuffs")
                                local targetBuffsTable = GetAllStats(target,
                                                                     "buffs")
                                local targetDebuffsTable = GetAllStats(target,
                                                                       "debuffs")

                                local targetEffects = {}
                                targetEffects["baseDamage"] = self.DamageAmount

                                targetEffects["ply"] = ply
                                targetEffects["target"] = target

                                targetEffects["userBuffsTable"] = userBuffsTable
                                targetEffects["userDebuffsTable"] =
                                    userDebuffsTable
                                targetEffects["targetBuffsTable"] =
                                    targetBuffsTable
                                targetEffects["targetDebuffsTable"] =
                                    targetDebuffsTable

                                targetEffects["baseDamage"] = math.ceil(
                                                                  targetEffects["baseDamage"])

                                HandleHealingEffects(ply, target, targetEffects)

                                local maxMP = target:GetNWInt("TBCMAXMP", 100)
                                local currentMP = target:GetNWInt("TBCMP", 100)

                                local newMP =
                                    math.min(currentMP +
                                                 targetEffects["baseDamage"],
                                             maxMP)

                                target:SetNWInt("TBCMP", newMP)

                                local message =
                                    target:Name() .. " received " ..
                                        targetEffects["baseDamage"] ..
                                        " MP from " .. ply:Name() .. "!"
                                target:ChatPrint(message)
                                if target ~= ply then
                                    ply:ChatPrint(message)
                                end

                            end
                        end
                    end
                end
            end
        end
        self:TakePrimaryAmmo(1)
    end

    ply:LagCompensation(false)

    if SERVER then
        local currentAmmo = self:Clip1()
        if currentAmmo <= 0 then self:Remove() end
    end
end --

function SWEP:PickUpFunction(ply, clip)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    local ammoType = "items"
    local currentAmmo = self:Clip1()
    local maxAmmo = self.Primary.ClipSize

    local ammoToAdd = math.min(currentAmmo + clip, self.Primary.DefaultClip)
    self:SetClip1(ammoToAdd)
end

function SWEP:CustomAmmoDisplay()
    self.AmmoDisplay = self.AmmoDisplay or {}

    self.AmmoDisplay.Draw = true

    if self.Primary.ClipSize > 0 then
        self.AmmoDisplay.PrimaryClip = self:Clip1()
        self.AmmoDisplay.PrimaryAmmo = self:Ammo1()
    end
    if self.Secondary.ClipSize > 0 then
        self.AmmoDisplay.SecondaryAmmo = self:Ammo2()
    end

    self.AmmoHere = self.AmmoDisplay.PrimaryClip
    return self.AmmoDisplay
end

function SWEP:ShowAmmo(ply, weapon)
    local weapon = ply:GetWeapon(weapon)
    local currentAmmo = weapon:Clip1()

    return currentAmmo
end
