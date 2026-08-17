-- Attacker damage increase or decrease statuses
local DamageDealerStatusHandlers = {
    Tarukaja = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            if not weapon.WeaponType == "Combat Tactic" then
                return math.ceil((damage) * (1 + 0.1 * properties.stacks))
            end
        end

        return damage
    end,
    -- Inugami's persona-exclusive Tarukaja. Stronger than the universal
    -- Tarukaja (0.2x per stack instead of 0.1x), so it's tracked as its own
    -- buff rather than reusing the shared "Tarukaja" key.
    Tarukaja_Inugami = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            if not weapon.WeaponType == "Combat Tactic" then
                return math.ceil((damage) * (1 + 0.2 * properties.stacks))
            end
        end

        return damage
    end,
    Baton_Pass = function(ply, effectsTable, properties, damage)
        timer.Create(
            "Baton_Pass",
            1,
            1,
            function()
                RemoveStat(ply, "Baton_Pass", "buffs")
            end
        )

        return math.ceil(damage * 1.1)
    end,
    Fire_Boost = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Fire" then
                    return math.ceil((damage) + (10))
                end
            end
        end
        return damage
    end,
    Ice_Boost = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Ice" then
                    return math.ceil((damage) + (10))
                end
            end
        end
        return damage
    end,
    Force_Boost = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Force" then
                    return math.ceil((damage) + (10))
                end
            end
        end
        return damage
    end,
    Elec_Boost = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Elec" then
                    return math.ceil((damage) + (10))
                end
            end
        end
        return damage
    end,
    Nuke_Boost = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Nuke" then
                    return math.ceil((damage) + (10))
                end
            end
        end
        return damage
    end,
    Light_Boost = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Light" then
                    return math.ceil((damage) + (10))
                end
            end
        end
        return damage
    end,
    Sabbath = function(ply, effectsTable, properties, damage)
        if effectsTable["state"] == "weak" or effectsTable["state"] == "crit" then
            return damage + (10 * properties.stacks)
        end

        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            local message = ply:Name() .. " triggers the Sabbath and deals extra damage!"

            weapon:AnnounceMessage(message)
        end

        return damage
    end,
    Mountain_Guardian = function(ply, effectsTable, properties, damage)
        if not IsValid(ply) then
            return damage
        end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then
            return damage
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then
            return damage
        end

        local side
        if table.HasValue(fight.Side1, ply) then
            side = fight.Side1
        elseif table.HasValue(fight.Side2, ply) then
            side = fight.Side2
        end

        if not side then
            return damage
        end

        local teamRakundaCount = 0
        for _, member in ipairs(side) do
            if IsValid(member) then
                local memberDebuffs = GetAllStats(member, "debuffs")
                if memberDebuffs["Rakunda"] then
                    teamRakundaCount = teamRakundaCount + (memberDebuffs["Rakunda"].stacks or 0)
                end
            end
        end

        if teamRakundaCount <= 0 then
            return damage
        end

        local bonus = teamRakundaCount * 1.5

        if weapon.Targets == "aoe" then
            bonus = bonus / 2
        end

        bonus = math.ceil(bonus)

        weapon:AnnounceMessage(ply:Name() .. "'s Mountain Guardian deals " .. bonus .. " bonus Almighty damage!")

        return damage + bonus
    end,
    Pungent_Goo = function(ply, effectsTable, properties, damage)
        local isPhysical =
            effectsTable["Affinity"] == "Physical" or table.HasValue(Affinities.Physical, effectsTable["Affinity"])

        local dealtDamage =
            effectsTable["state"] == "normal" or effectsTable["state"] == "weak" or effectsTable["state"] == "crit"

        if isPhysical and dealtDamage and math.random(1, 100) <= 35 then
            local target = effectsTable["target"]

            if IsValid(target) then
                local targetDebuffsTable = GetAllStats(target, "debuffs")

                if targetDebuffsTable["Sukunda"] then
                    targetDebuffsTable["Sukunda"].stacks = math.min(targetDebuffsTable["Sukunda"].stacks + 1, 4)
                else
                    targetDebuffsTable["Sukunda"] = {stacks = 1}
                end

                AssignStat(target, "Sukunda", targetDebuffsTable["Sukunda"], "debuffs")

                local weapon = ply:GetActiveWeapon()

                if IsValid(weapon) then
                    weapon:AnnounceMessage(target:Name() .. " is inflicted with Sukunda by Pungent Goo!")
                end
            end
        end

        return damage
    end,
    Crippling_Blow = function(ply, effectsTable, properties, damage)
        if effectsTable["state"] == "crit" then
            local target = effectsTable["target"]
            local targetDebuffsTable = effectsTable["targetDebuffsTable"]

            if IsValid(target) and targetDebuffsTable and targetDebuffsTable["Downed"] then
                if math.random(1, 100) <= 25 then
                    target:SetNWInt("TBCHP", 0)

                    local weapon = ply:GetActiveWeapon()
                    if IsValid(weapon) then
                        weapon:AnnounceMessage(
                            target:Name() .. " is instantly killed by Matador's Crippling Blow!"
                        )
                    end
                end
            end
        end

        return damage
    end,
    Fan_of_Demonic_Ice = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Ice" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerChr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                        local MPToRestore = ply:GetNWInt("TBCMP", 10)
                        local maxMP = ply:GetNWInt("TBCMAXMP", 100)

                        local newMP = math.min(MPToRestore + 2, maxMP)
                        ply:SetNWInt("TBCMP", newMP)
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = ply:Name() .. " received " .. HPtoRecover .. " healing from the Fan of Demonic Ice!"

                    if playerChr >= 6 then
                        message = message .. " And also recovers 2 MP!"
                    end

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Iron_Fan_of_the_Empress = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Fire" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerChr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                        local MPToRestore = ply:GetNWInt("TBCMP", 10)
                        local maxMP = ply:GetNWInt("TBCMAXMP", 100)

                        local newMP = math.min(MPToRestore + 2, maxMP)
                        ply:SetNWInt("TBCMP", newMP)
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message =
                        ply:Name() .. " received " .. HPtoRecover .. " healing from the Iron Fan of the Empress!"

                    if playerChr >= 6 then
                        message = message .. " And also recovers 2 MP!"
                    end

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Maxwell = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Elec" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerChr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                        local MPToRestore = ply:GetNWInt("TBCMP", 10)
                        local maxMP = ply:GetNWInt("TBCMAXMP", 100)

                        local newMP = math.min(MPToRestore + 2, maxMP)
                        ply:SetNWInt("TBCMP", newMP)
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = ply:Name() .. " received " .. HPtoRecover .. " healing from the Maxwell!"

                    if playerChr >= 6 then
                        message = message .. " And also recovers 2 MP!"
                    end

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Combat_Dancing_Fan = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Force" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerChr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                        local MPToRestore = ply:GetNWInt("TBCMP", 10)
                        local maxMP = ply:GetNWInt("TBCMAXMP", 100)

                        local newMP = math.min(MPToRestore + 2, maxMP)
                        ply:SetNWInt("TBCMP", newMP)
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = ply:Name() .. " received " .. HPtoRecover .. " healing from the Combat Dancing Fan!"

                    if playerChr >= 6 then
                        message = message .. " And also recovers 2 MP!"
                    end

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Fan_of_Hypnosis = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Ruin" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerChr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                        local MPToRestore = ply:GetNWInt("TBCMP", 10)
                        local maxMP = ply:GetNWInt("TBCMAXMP", 100)

                        local newMP = math.min(MPToRestore + 2, maxMP)
                        ply:SetNWInt("TBCMP", newMP)
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = ply:Name() .. " received " .. HPtoRecover .. " healing from the Fan of Hypnosis!"

                    if playerChr >= 6 then
                        message = message .. " And also recovers 2 MP!"
                    end

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Vajra = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Light" then
                    local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerStr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = ply:Name() .. " received " .. HPtoRecover .. " healing from Vajra!"

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Maras_Vajra = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Dark" then
                    local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
                    local HPtoRecover = 10

                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    if playerStr >= 6 then
                        HPtoRecover = HPtoRecover + 5
                    end

                    local newHP = math.min(HPToHeal + HPtoRecover, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = ply:Name() .. " received " .. HPtoRecover .. " healing from Mara's Vajra!"

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Ruby_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Fire" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Amber_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Elec" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Turquoise_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Ice" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Emerald_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Force" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Opal_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Nuke" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Amethyst_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Ruin" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Pearl_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Light" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Onyx_Grimoire = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if weapon.Affinity and weapon.Affinity == "Dark" then
                    local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
                    if playerChr >= 6 then
                        return math.ceil((damage) + (15))
                    else
                        return math.ceil((damage) + (10))
                    end
                end
            end
        end
        return damage
    end,
    Power_Charge = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if not weapon.WeaponType == "Combat Tactic" then
                    local weaponClass = weapon:GetClass()
                    if weapon.Affinity and table.HasValue(Affinities["Physical"], weapon.Affinity) then
                        timer.Create(
                            "Power_Charge",
                            1,
                            1,
                            function()
                                local userBuffsTable = GetAllStats(ply, "buffs")

                                if userBuffsTable["Power_Charge"] then
                                    RemoveStat(ply, "Power_Charge", "buffs")
                                    userBuffsTable["Power_Charge"] = nil
                                end
                            end
                        )

                        return math.ceil((damage) * (1.25))
                    end
                end
            end
        end
        return damage
    end,
    Power_Charge_Boss = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if not weapon.WeaponType == "Combat Tactic" then
                    if weapon.Affinity and (weapon.Affinity == "Physical" or
                        table.HasValue(Affinities["Physical"], weapon.Affinity)) then
                        timer.Create(
                            "Power_Charge_Boss",
                            1,
                            1,
                            function()
                                local userBuffsTable = GetAllStats(ply, "buffs")

                                if userBuffsTable["Power_Charge_Boss"] then
                                    RemoveStat(ply, "Power_Charge_Boss", "buffs")
                                    userBuffsTable["Power_Charge_Boss"] = nil
                                end
                            end
                        )

                        return math.ceil((damage) * (1.4))
                    end
                end
            end
        end
        return damage
    end,
    Mind_Charge = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if not weapon.WeaponType == "Combat Tactic" then
                    local weaponClass = weapon:GetClass()
                    if weapon.Affinity and table.HasValue(Affinities["Magic"], weapon.Affinity) then
                        timer.Create(
                            "Mind_Charge",
                            1,
                            1,
                            function()
                                local userBuffsTable = GetAllStats(ply, "buffs")

                                if userBuffsTable["Mind_Charge"] then
                                    RemoveStat(ply, "Mind_Charge", "buffs")
                                    userBuffsTable["Mind_Charge"] = nil
                                end
                            end
                        )

                        return math.ceil((damage) * (1.25))
                    end
                end
            end
        end
        return damage
    end,
    Mind_Charge_Boss = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if not weapon.WeaponType == "Combat Tactic" then
                    if weapon.Affinity and table.HasValue(Affinities["Magic"], weapon.Affinity) then
                        timer.Create(
                            "Mind_Charge_Boss",
                            1,
                            1,
                            function()
                                local userBuffsTable = GetAllStats(ply, "buffs")

                                if userBuffsTable["Mind_Charge_Boss"] then
                                    RemoveStat(ply, "Mind_Charge_Boss", "buffs")
                                    userBuffsTable["Mind_Charge_Boss"] = nil
                                end
                            end
                        )

                        return math.ceil((damage) * (1.4))
                    end
                end
            end
        end
        return damage
    end,
    Encore = function(ply, effectsTable, properties, damage)
        local userBuffsTable = GetAllStats(ply, "buffs")
        if userBuffsTable["Tarukaja"] then
            return math.ceil((damage) * (1 + (0.05 * userBuffsTable["Tarukaja"]["stacks"])))
        end
        return damage
    end,
    Cauterizing_Flames = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                if weapon.Affinity and weapon.Affinity == "Fire" then
                    local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
                    if fight then
                    else
                        return
                    end

                    local playerSide =
                        (table.HasValue(fight.Side1, ply) and "Side1") or (table.HasValue(fight.Side2, ply) and "Side2")

                    local playersInFight = {}
                    local lowestHP = ply
                    for _, player in ipairs(fight[playerSide]) do
                        if IsValid(player) then
                            if
                                player:GetNWInt("TBCHP", 0) > 0 and
                                    (lowestHP:GetNWInt("TBCHP", 0) < player:GetNWInt("TBCHP", 0))
                             then
                                lowestHP = player
                            end
                        end
                    end

                    local HPToHeal = lowestHP:GetNWInt("TBCHP", 10)
                    local maxHP = lowestHP:GetNWInt("TBCMAXHP", 100)

                    local targetEffects = {}
                    targetEffects["baseDamage"] = 15
                    targetEffects["percentHeal"] = 0.05

                    targetEffects["ply"] = ply
                    targetEffects["target"] = lowestHP

                    targetEffects["baseDamage"] = math.ceil(maxHP * targetEffects["percentHeal"])

                    local newHP = math.min(HPToHeal + targetEffects["baseDamage"], maxHP)
                    lowestHP:SetNWInt("TBCHP", newHP)

                    local message =
                        lowestHP:Name() ..
                        " received " .. targetEffects["baseDamage"] .. " healing from Cauterizing Flames!"

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return damage
    end,
    Aim_Stance = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            if weapon.WeaponType and (table.HasValue(SWEP_Categories["Ranged_Weapons"], weapon.WeaponType)) then
                local resistsOrOtherwise = false

                local resist = util.JSONToTable(effectsTable["target"]:GetNW2String("resist"))

                if table.HasValue(resist, "Dark") then
                    resistsOrOtherwise = true
                end

                local block = util.JSONToTable(effectsTable["target"]:GetNW2String("block"))

                if table.HasValue(block, "Dark") then
                    resistsOrOtherwise = true
                end

                local drain = util.JSONToTable(effectsTable["target"]:GetNW2String("drain"))

                if table.HasValue(drain, "Dark") then
                    resistsOrOtherwise = true
                end

                local repel = util.JSONToTable(effectsTable["target"]:GetNW2String("repel"))

                if table.HasValue(repel, "Dark") then
                    resistsOrOtherwise = true
                end

                if not resistsOrOtherwise then
                    local targetDebuffsTable = GetAllStats(effectsTable["target"], "debuffs")

                    targetDebuffsTable["Cursed"] = {stacks = 1, duration = 3}

                    AssignStat(effectsTable["target"], "Cursed", targetDebuffsTable["Cursed"], "debuffs")
                end
            end
        end

        return damage
    end,
    Soul_Matrix_Arrow = function(ply, effectsTable, properties, damage)
        if ply then
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
            if playerDex >= 5 then
                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) then
                    local weaponClass = weapon:GetClass()
                    if weapon.Affinity and weapon.Affinity == "Ice" then
                        local HPToHeal = ply:GetNWInt("TBCHP", 10)
                        local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                        local baseDamage = 6

                        local newHP = math.min(HPToHeal + baseDamage, maxHP)
                        ply:SetNWInt("TBCHP", newHP)

                        local message = ply:Name() .. " received " .. baseDamage .. " healing from Soul Matrix!"

                        weapon:AnnounceMessage(message)
                    end
                end
            end
        end
        return damage
    end,
    Soul_Matrix_Milady = function(ply, effectsTable, properties, damage)
        if ply then
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            if playerChr >= 5 then
                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) then
                    local weaponClass = weapon:GetClass()
                    if weapon.Affinity and weapon.Affinity == "Fire" then
                        local HPToHeal = ply:GetNWInt("TBCHP", 10)
                        local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                        local baseDamage = 6

                        local newHP = math.min(HPToHeal + baseDamage, maxHP)
                        ply:SetNWInt("TBCHP", newHP)

                        local message = ply:Name() .. " received " .. baseDamage .. " healing from Soul Matrix!"

                        weapon:AnnounceMessage(message)
                    end
                end
            end
        end
        return damage
    end,
    Soul_Matrix_Saizo = function(ply, effectsTable, properties, damage)
        if ply then
            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
            if playerStr >= 5 then
                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) then
                    local weaponClass = weapon:GetClass()
                    if weapon.Affinity and weapon.Affinity == "Force" then
                        local HPToHeal = ply:GetNWInt("TBCHP", 10)
                        local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                        local baseDamage = 6

                        local newHP = math.min(HPToHeal + baseDamage, maxHP)
                        ply:SetNWInt("TBCHP", newHP)

                        local message = ply:Name() .. " received " .. baseDamage .. " healing from Soul Matrix!"

                        weapon:AnnounceMessage(message)
                    end
                end
            end
        end
        return damage
    end,
    Scoundrel_Eyes = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            local resistsOrOtherwise = false

            local userDebuffsTable = GetAllStats(ply, "debuffs")

            if userDebuffsTable["Sukunda"] then
                if userDebuffsTable["Sukunda"].stacks == 1 then
                    RemoveStat(ply, "Sukunda", "debuffs")

                    weapon:AnnounceMessage(ply:Name() .. "'s Sukunda is dispelled by Scoundrel Eyes!")
                elseif userDebuffsTable["Sukunda"].stacks > 1 then
                    userDebuffsTable["Sukunda"].stacks = userDebuffsTable["Sukunda"].stacks - 1

                    AssignStat(ply, "Sukunda", userDebuffsTable["Sukunda"], "debuffs")

                    weapon:AnnounceMessage(ply:Name() .. "'s Sukunda stacks is decreased by Scoundrel Eyes!")
                end
            end
        end

        return damage
    end,
    Lock_On = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if weapon.weaponType and weapon.weaponType == "Gun" then
                local targetBuffsTable = GetAllStats(ply, "buffs")

                if targetBuffsTable["Lock_On"] then
                    if targetBuffsTable["Lock_On"].visibility == 0 then
                        targetBuffsTable["Lock_On"].stacks = math.min(targetBuffsTable["Lock_On"].stacks + 1, 3)
                    else
                        targetBuffsTable["Lock_On"].visibility = 1
                    end
                end

                AssignStat(ply, "Lock_On", targetBuffsTable["Lock_On"], "buffs")

                ply:ChatPrint("You gain 1 Lock On Stack!")
            end
        end
        return damage
    end,
    Bird_Song = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if effectsTable["state"] ~= "weak" and effectsTable["state"] ~= "crit" then
                local targetDebuffsTable = GetAllStats(effectsTable["target"], "debuffs")

                if targetDebuffsTable["Targeted"] then
                    targetDebuffsTable["Targeted"].stacks = math.min(targetDebuffsTable["Targeted"].stacks + 1, 4)
                else
                    targetDebuffsTable["Targeted"].stacks = 1
                end

                if targetDebuffsTable["Targeted"].stacks >= 4 then
                    RemoveStat(effectsTable["target"], "Targeted", "debuffs")

                    effectsTable["targetDebuffsTable"]["Downed"] = {
                        stacks = 1,
                        durationCycle = 1
                    }

                    effectsTable["userBuffsTable"]["One_More"] = {
                        stacks = 1,
                        duration = 1
                    }

                    AssignStat(
                        effectsTable["target"],
                        "Downed",
                        effectsTable["targetDebuffsTable"]["Downed"],
                        "debuffs"
                    )

                    AssignStat(effectsTable["ply"], "One_More", effectsTable["userBuffsTable"]["One_More"], "buffs")

                    weapon:AnnounceMessage(effectsTable["target"]:Name() .. " is down!")
                    ply:ChatPrint("You've gained One More!")
                else
                    AssignStat(effectsTable["target"], "Targeted", targetDebuffsTable["Targeted"], "debuffs")

                    weapon:AnnounceMessage(effectsTable["target"]:Name() .. " gains a targeting stack!")
                end
            end
        end
        return damage
    end,
    Purple_Leaves = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if weapon.affinity and weapon.affinity == "Ruin" then
                local targetBuffsTable = GetAllStats(ply, "buffs")

                if targetBuffsTable["Purple_Leaves"] then
                    if targetBuffsTable["Purple_Leaves"].visibility == 0 then
                        targetBuffsTable["Purple_Leaves"].stacks =
                            math.min(targetBuffsTable["Purple_Leaves"].stacks + 1, 4)
                    else
                        targetBuffsTable["Purple_Leaves"].visibility = 1
                    end
                end

                AssignStat(ply, "Purple_Leaves", targetBuffsTable["Purple_Leaves"], "buffs")

                ply:ChatPrint("You gain 1 Purple Leave Stack!")
            end
        end
        return damage
    end,
    Omakase = function(ply, effectsTable, properties, damage)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local weaponClass = weapon:GetClass()
                local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
                local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
                if playerStr >= 6 then
                    local HPToHeal = ply:GetNWInt("TBCHP", 10)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                    local newHP = math.min(HPToHeal + 4, maxHP)
                    ply:SetNWInt("TBCHP", newHP)

                    local message = "You received 4 healing from Omakase!"

                    ply:ChatPrint(message)
                elseif playerDex >= 6 then
                    local MPToHeal = ply:GetNWInt("TBCMP", 10)
                    local maxMP = ply:GetNWInt("TBCMAXMP", 100)

                    local newHP = math.min(MPToHeal + 4, maxMP)
                    ply:SetNWInt("TBCMP", newHP)

                    local message = "You received 4 MP from Omakase!"

                    ply:ChatPrint(message)
                end
            end
        end
        return damage
    end
}

local DamageDecreaseStatusHandlers = {
    Tarunda = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            if not weapon.WeaponType == "Combat Tactic" then
                return math.floor((damage) * (1 - 0.1 * properties.stacks))
            end
        end

        return damage
    end,
    -- Hua Po's persona-exclusive Tarunda. Stronger than the universal
    -- Tarunda (0.2x per stack instead of 0.1x), so it's tracked as its own
    -- debuff rather than reusing the shared "Tarunda" key.
    Tarunda_HuaPo = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            if not weapon.WeaponType == "Combat Tactic" then
                return math.floor((damage) * (1 - 0.2 * properties.stacks))
            end
        end

        return damage
    end,
    Panic = function(ply, effectsTable, properties, damage)
        return math.floor((damage) * (1 - 0.2))
    end,
    Rage = function(ply, effectsTable, properties, damage)
        return math.floor((damage) * (1 - 0.25))
    end
}

-- Target damage increase or decrease statuses

local DamageDefenseStatusHandlers = {
    Guard = function(ply, effectsTable, properties, damage)
        return math.floor((damage) * (1 - 0.25))
    end,
    Rakukaja = function(ply, effectsTable, properties, damage)
        return math.floor((damage) * (1 - 0.1 * properties.stacks))
    end,
    Encore = function(ply, effectsTable, properties, damage)
        local userBuffsTable = GetAllStats(ply, "buffs")
        if userBuffsTable["Rakukaja"] then
            return math.ceil((damage) * (1 - 0.05 * userBuffsTable["Rakukaja"]["stacks"]))
        end
        return damage
    end,
    Didnt_Hear_No_Bell = function(ply, effectsTable, properties, damage)
        local casterFound = false
        local userBuffsTable = GetAllStats(ply, "buffs")
        if effectsTable["weaponTargets"] then
            for _, player in pairs(effectsTable["weaponTargets"]) do
                if userBuffsTable["Didnt_Hear_No_Bell"]["caster"] == player:UserID() then
                    casterFound = true
                    break
                end
            end
        else
            if userBuffsTable["Didnt_Hear_No_Bell"]["caster"] == ply then
                casterFound = true
            end
        end

        if not casterFound then
            return math.floor((damage) * (1 - 0.2))
        end
        return damage
    end,
    Gaia_Pact = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if fight then
        else
            return
        end

        local playerSide =
            (table.HasValue(fight.Side1, ply) and "Side1") or (table.HasValue(fight.Side2, ply) and "Side2")

        for _, player in ipairs(fight[playerSide]) do
            if IsValid(player) and (player:UserID() == properties.caster) and (ply:UserID() ~= properties.caster) then
                local currentHP = player:GetNWInt("TBCHP", 100)
                local maxHP = player:GetNWInt("TBCMAXHP", 100)
                local targetCurrentHP = ply:GetNWInt("TBCHP", 100)
                local targetMaxHP = ply:GetNWInt("TBCMAXHP", 100)
                if currentHP >= (maxHP * 0.40) and targetCurrentHP <= (targetMaxHP * 0.30) then
                    return math.floor((damage) * (1 - 0.4))
                end
            end
        end

        return damage
    end,
    Devotion_of_Rebuttal = function(ply, effectsTable, properties, damage)
        local maxHP = ply:GetNWInt("TBCMAXHP", 100)
        local percentHP = maxHP * 0.25
        if damage > percentHP then
            return math.floor(percentHP)
        end

        return math.floor(damage)
    end,
    Purple_Leaves = function(ply, effectsTable, properties, damage)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if weapon.affinity and weapon.affinity == "Ruin" then
                local targetBuffsTable = GetAllStats(ply, "buffs")

                if targetBuffsTable["Purple_Leaves"] then
                    if targetBuffsTable["Purple_Leaves"].visibility == 0 then
                        targetBuffsTable["Purple_Leaves"].stacks =
                            math.min(targetBuffsTable["Purple_Leaves"].stacks + 1, 4)
                    else
                        targetBuffsTable["Purple_Leaves"].visibility = 1
                    end
                end

                AssignStat(ply, "Purple_Leaves", targetBuffsTable["Purple_Leaves"], "buffs")

                ply:ChatPrint("You gain 1 Purple Leave Stack!")
            end
        end
        return damage
    end
}

local DefenseDecreaseStatusHandlers = {
    Rakunda = function(ply, effectsTable, properties, damage)
        return math.ceil((damage) * (1 + 0.1 * properties.stacks))
    end,
    Sleep = function(ply, effectsTable, properties, damage)
        RemoveStat(ply, "Sleep", "debuffs")

        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            weapon:AnnounceMessage(ply:Name() .. " is awoken!")
        end

        return math.ceil((damage) * (1.25))
    end
}

-- Attacker heal increase or decrease statuses

local IncreaseHealStatusHandlers = {
    Baton_Pass = function(ply, heal, properties, targetEffects)
        timer.Create(
            "Baton_Pass",
            1,
            1,
            function()
                RemoveStat(ply, "Baton_Pass", "buffs")
            end
        )
        return (heal) + (0.1)
    end,
    Explosive_Scheme = function(ply, heal, properties, targetEffects)
        local currentHP = ply:GetNWInt("TBCHP", 100)
        local maxHP = ply:GetNWInt("TBCMAXHP", 100)
        if currentHP <= (maxHP * 0.41) then
            return (heal) + (0.2)
        end

        if currentHP > (maxHP * 0.66) then
            if math.random(1, 100) <= 25 then
                local weapon = ply:GetActiveWeapon()
                local ailmentsRemoved = false
                local ailmentsToRemove
                for status, properties in pairs(targetEffects["targetDebuffsTable"]) do
                    if table.HasValue(Ailments_Statuses["Ailments"], status) then
                        ailmentsRemoved = true
                        RemoveStat(targetEffects["target"], status, "debuffs")
                    end
                end

                if ailmentsRemoved then
                    weapon:AnnounceMessage(
                        "Ailments removed from " .. targetEffects["target"]:Name() .. " due to Explosive Scheme!"
                    )
                end
            end
        end

        return heal
    end
}

local DecreaseHealStatusHandlers = {}

local IncreaseHealReceiveStatusHandlers = {
    Heal_Boost = function(ply, heal, properties)
        return (heal) + (0.25)
    end
}

local DecreaseHealReceiveStatusHandlers = {
    Heal_Dampener = function(ply, heal, properties)
        return (heal) + (0.25)
    end
}

local FlatIncreaseHealStatusHandlers = {
    Royal_Scepter_of_Demonic_Blood = function(ply, heal, properties, targetEffects)
        return heal + 20
    end,
    Papillon_Diabolos = function(ply, heal, properties, targetEffects)
        return heal + 20
    end
}

local FlatDecreaseHealStatusHandlers = {}

local FlatIncreaseHealReceiveStatusHandlers = {}

local FlatDecreaseHealReceiveStatusHandlers = {}

-- Technique increase or decrease statuses

local IncreaseTechniqueStatusHandlers = {
    Sukukaja = function(ply, tech, properties)
        if tech > 0 then
            return tech + (10 * properties.stacks)
        else
            return (10 * properties.stacks)
        end
    end,
    Eight_Count = function(ply, tech, properties)
        local currentTech = tech
        local plyHP = ply:GetNWInt("TBCHP", 100)
        local maxHP = ply:GetNWInt("TBCMAXHP", 50)

        if plyHP <= (maxHP * 0.25) then
            return tech + (12)
        end
        return tech
    end,
    Premonition = function(ply, tech, properties)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            local currentTech = tech

            local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
            if not fight then
                return tech
            end

            -- Determine the current active side based on the player calling this function
            local currentActiveSide = fight.ActiveSide

            -- Check if the player is on the active side
            local currentTurnPlayer = fight[currentActiveSide][fight.ActiveMember]

            if currentTurnPlayer ~= ply then
                return tech + (15)
            end
        end

        return tech
    end,
    Aim_Stance = function(ply, tech, properties)
        local weapon = ply:GetActiveWeapon()

        if IsValid(weapon) then
            if weapon.WeaponType and (table.HasValue(SWEP_Categories["Ranged_Weapons"], weapon.WeaponType)) then
                return tech + (15)
            end
        end

        return tech
    end,
    Encore = function(ply, tech, properties)
        local userBuffsTable = GetAllStats(ply, "buffs")
        if userBuffsTable["Sukukaja"] then
            return math.ceil((tech) + (5 * userBuffsTable["Sukukaja"]["stacks"]))
        end
        return tech
    end,
    Soul_Matrix_Milady = function(ply, tech, properties)
        if ply then
            local playerStr = tonumber(ply:GetNWInt("TBCStr", 0))
            if playerStr >= 5 then
                return math.ceil((tech) + (3))
            end
        end
        return tech
    end,
    Soul_Matrix_Saizo = function(ply, tech, properties)
        if ply then
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
            if playerDex >= 5 then
                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) then
                    local weaponClass = weapon:GetClass()
                    if weapon.Affinity and weapon.Affinity == "Force" then
                        return math.ceil((tech) + (5))
                    end
                end
            end
        end
        return tech
    end,
    Mastery_of_Magic = function(ply, tech, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if (weapon.WeaponType and "Magic Skill" == weapon.WeaponType) and not weapon.IsHeal then
                return math.ceil((tech) + (5))
            end
        end
        return tech
    end,
    Pinch_Anchor = function(ply, tech, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
            if not fight then
                return tech
            end

            if not fight.Started then
                return math.ceil((tech) + (15))
            end
        end
        return tech
    end,
    Jump_Kick = function(ply, tech, properties, type)
        local value = tech
        if type == "attacker" then
            local weapon = ply:GetActiveWeapon()
            if IsValid(weapon) then
                if weapon.PrintName == "Jump Kick" then
                    local target = ply:GetEyeTrace().Entity
                    local targetBuffsTable = GetAllStats(target, "buffs")
                    if targetBuffsTable["Sukukaja"] then
                        value = math.ceil((value) + (10 * targetBuffsTable["Sukukaja"]["stacks"]))
                    end
                end
            end
        end
        return value
    end
}

local DecreaseTechniqueStatusHandlers = {
    Sukunda = function(ply, tech, properties)
        if tech > 0 then
            return tech + (10 * properties.stacks)
        else
            return (10 * properties.stacks)
        end
    end,
    Panic = function(ply, tech, properties, type)
        if type == "attacker" then
            return tech + (25)
        end
        return tech
    end,
    Confusion = function(ply, tech, properties, type)
        local value = tech
        if type == "attacker" then
            value = value + (25)
        end

        local userBuffsTable = GetAllStats(ply, "buffs")
        if userBuffsTable["Sukukaja"] then
            value = math.ceil((value) + (5 * userBuffsTable["Sukukaja"]["stacks"]))
        end

        return value
    end
}

-- Luck increase or decrease statuses

local IncreaseLuckStatusHandlers = {
    Shrine_Guardian = function(ply, luck, properties)
        local totalLuck = luck
        if ply then
            for _, weapon in pairs(ply:GetWeapons()) do
                if weapon.WeaponType then
                    if table.HasValue(SWEP_Categories["Melee_Weapons"], weapon.WeaponType) then
                        totalLuck = totalLuck + 3
                    end
                end
            end
        end
        return totalLuck
    end,
    Explosive_Scheme = function(ply, luck, properties)
        local totalLuck = luck
        if ply then
            local currentHP = ply:GetNWInt("TBCHP", 100)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)
            if currentHP <= (maxHP * 0.66) then
                totalLuck = totalLuck + 7
            end
        end
        return totalLuck
    end,
    Ward_Off_Evil = function(ply, luck, properties)
        if not IsValid(ply) then return luck end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then return luck end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then return luck end

        local side
        if table.HasValue(fight.Side1, ply) then
            side = fight.Side1
        elseif table.HasValue(fight.Side2, ply) then
            side = fight.Side2
        end

        if not side then return luck end

        for _, member in ipairs(side) do
            if IsValid(member) and member:GetNWInt("TBCHP", 0) > 0 then
                local charId = member:GetNWString("AssignedCharacter")
                local charData = CHARACTERS.List[charId]
                if charData and charData.variantGroup == "shiki_ouji" then
                    return luck + 4
                end
            end
        end

        return luck
    end
}

local DecreaseLuckStatusHandlers = {
    Soul_Matrix_Milady = function(ply, luck, properties)
        local totalLuck = luck

        if ply then
            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
            if playerStr >= 5 then
                totalLuck = totalLuck - 1
            end
        end
        return totalLuck
    end
}

-- Escape chance increase or decrease statuses

local IncreaseEscapeStatusHandlers = {
    Fast_Retreat = function(ply, chance, properties)
        local totalChance = chance
        if ply then
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))

            if playerChr >= 4 then
                totalChance = totalChance + 25
            else
                totalChance = totalChance + 5
            end
        end
        return totalChance
    end,
    Seven_Sisters_Bag = function(ply, chance, properties)
        local totalChance = chance
        if ply then
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))

            if playerChr >= 4 then
                totalChance = totalChance + 25
            else
                totalChance = totalChance + 5
            end
        end
        return totalChance
    end
}

local DecreaseEscapeStatusHandlers = {}

-- Crit increase or decrease statuses

local IncreaseCritReceiveStatusHandlers = {
    Apt_Pupil = function(ply, crit, properties)
        if crit > 0 then
            return crit + (10)
        else
            return (10)
        end
    end,
    Anchor_Point = function(ply, crit, properties)
        local userBuffsTable = GetAllStats(ply, "buffs")
        local newCrit = crit

        for status, currentProperties in pairs(userBuffsTable) do
            if table.HasValue(Ailments_Statuses["Kaja"], status) then
                newCrit = newCrit + (7 * currentProperties.stacks)
            end
        end

        return newCrit
    end,
    Omagatoki_Critical = function(ply, crit, properties)
        return crit + (100)
    end,
    Lock_On = function(ply, crit, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()
            if IsValid(weapon) then
                if weapon.weaponType and weapon.weaponType == "Gun" then
                    local targetBuffsTable = GetAllStats(ply, "buffs")
                    if targetBuffsTable["Lock_On"] then
                        if targetBuffsTable["Lock_On"].stacks >= 3 then
                            targetBuffsTable["Lock_On"].stacks = 1
                            targetBuffsTable["Lock_On"].visibility = 0

                            AssignStat(ply, "Lock_On", targetBuffsTable["Lock_On"], "buffs")
                            return crit + (100)
                        end
                    end
                end
            end
        end
        return crit
    end
}

local DecreaseCritReceiveStatusHandlers = {
    Decrit = function(ply, crit, properties)
        if crit > 0 then
            return crit + (10)
        else
            return (10)
        end
    end
}

-- Ailment increase or decrease statuses

local IncreaseAilmentChanceStatusHandlers = {
    Charm_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Charm" then
            return chance + 10
        end
        return (chance)
    end,
    Rage_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Rage" then
            return chance + 10
        end
        return (chance)
    end,
    Poison_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Poison" then
            return chance + 10
        end
        return (chance)
    end,
    Mute_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Mute" then
            return chance + 10
        end
        return (chance)
    end,
    Panic_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Panic" then
            return chance + 10
        end
        return (chance)
    end,
    Paralysis_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Paralysis" then
            return chance + 10
        end
        return (chance)
    end,
    Sleep_Boost = function(ply, chance, properties, targetEffects)
        if targetEffects["ailment"] and targetEffects["ailment"] == "Sleep" then
            return chance + 10
        end
        return (chance)
    end,
    Icy_Glare = function(ply, chance, properties, targetEffects)
        local weapon = targetEffects["target"]:GetActiveWeapon()

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if fight then
        else
            return
        end

        local playerSide =
            (table.HasValue(fight.Side1, targetEffects["target"]) and "Side1") or
            (table.HasValue(fight.Side2, targetEffects["target"]) and "Side2")

        for _, player in ipairs(fight[playerSide]) do
            if IsValid(player) then
                local resist = util.JSONToTable(player:GetNW2String("resist"))
                if
                    table.HasValue(resist, "Ruin") or
                        (table.HasValue(resist, "Magic") and table.HasValue(Affinities.Magic, "Ruin"))
                 then
                    return chance + 5
                end
            end
        end
        return (chance)
    end,
    Karukozaka_HS_Bag = function(ply, chance, properties, targetEffects)
        local totalChance = chance
        totalChance = totalChance + 5

        local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
        if playerChr >= 4 then
            totalChance = totalChance + 10
        end

        return totalChance
    end,
    Second_Serving = function(ply, chance, properties, targetEffects)
        local totalChance = chance
        if
            targetEffects["ailment"] and
                table.HasValue(Ailments_Statuses["Elemental_Ailments"], targetEffects["ailment"])
         then
            totalChance = totalChance + 15
        end
        return (totalChance)
    end
}

local DecreaseAilmentChanceStatusHandlers = {}

-- Ailment Receive increase or decrease statuses

local IncreaseAilmentReceiveStatusHandlers = {}

local DecreaseAilmentReceiveStatusHandlers = {
    Shield_Deployment = function(ply, chance, properties, targetEffects)
        return (1000)
    end,
    Succubus_Allure = function(ply, chance, properties, targetEffects)
        local ailment = targetEffects and targetEffects["ailment"]
        if ailment == "Charm" or ailment == "Sleep" then
            return 1000
        end
        return chance
    end
}

-- Bonus Damage for crit statuses

local BonusCritDamageStatusHandlers = {}

-- Death statuses

local DeathStateStatusHandlers = {
    Endure = function(ply, state, properties)
        if ply then
            ply:SetNWInt("TBCHP", 1)

            RemoveStat(ply, "Endure", "buffs")
            RemoveStat(ply, "Endure", "permabuffs")

            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                weapon:AnnounceMessage(ply:Name() .. " endures with 1 HP after a fatal blow!")
            end
        end

        return "alive"
    end
}

-- On Death statuses (fired on the dying entity's own buffs right before they're wiped)

local OnDeathStatusHandlers = {
    Songbird_Obituary = function(ply, effectsTable, properties)
        if not IsValid(ply) then
            return
        end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then
            return
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then
            return
        end

        local side
        if table.HasValue(fight.Side1, ply) then
            side = fight.Side1
        elseif table.HasValue(fight.Side2, ply) then
            side = fight.Side2
        end

        if not side then
            return
        end

        -- Snapshot before touching anything else, since death/cleanup hooks can mutate the side arrays.
        local sideMembers = {}
        for _, member in ipairs(side) do
            table.insert(sideMembers, member)
        end

        local huaPoCount = 0
        for _, member in ipairs(sideMembers) do
            if IsValid(member) then
                local charId = member:GetNWString("AssignedCharacter")
                local charData = CHARACTERS.List[charId]
                if charData and charData.variantGroup == "hua_po" then
                    huaPoCount = huaPoCount + 1
                end
            end
        end

        local rakukajaStacks = (huaPoCount <= 1) and 3 or 1

        for _, member in ipairs(sideMembers) do
            if IsValid(member) and member ~= ply and member:GetNWInt("TBCHP", 0) > 0 then
                local memberBuffs = GetAllStats(member, "buffs")
                local existingRakukaja = memberBuffs["Rakukaja"]
                local currentStacks = (existingRakukaja and existingRakukaja.stacks) or 0
                local newStacks = math.min(currentStacks + rakukajaStacks, 4)

                AssignStat(member, "Rakukaja", {stacks = newStacks}, "buffs")

                for _, ailment in ipairs(Ailments_Statuses.Ailments) do
                    RemoveStat(member, ailment, "debuffs")
                end

                if member:IsPlayer() then
                    member:ChatPrint(
                        "Hua Po's Songbird's Obituary grants you Rakukaja +" ..
                            rakukajaStacks .. " and cures your ailments!"
                    )
                end
            end
        end

        weapon:AnnounceMessage(ply:Name() .. "'s Songbird's Obituary echoes through the party!")

        return true
    end
}

-- Kill statuses

local KillStatusHandlers = {
    Third_Intention = function(ply, state, properties)
        if ply then
            local plyMP = ply:GetNWInt("TBCMP", 0)
            local maxMP = ply:GetNWInt("TBCMAXMP", 50)

            plyMP = math.min(plyMP + 40, maxMP)

            ply:SetNWInt("TBCMP", plyMP)

            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                weapon:AnnounceMessage(ply:Name() .. " recovers 40 SP for killing an enemy!")
            end
        end

        return true
    end,
    Triangle_Drill = function(ply, state, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                if table.HasValue(SWEP_Categories.Skills, weapon.WeaponType) then
                    local plyHP = ply:GetNWInt("TBCHP", 0)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 50)

                    plyHP = math.min(plyHP + 40, maxHP)

                    ply:SetNWInt("TBCHP", plyHP)

                    weapon:AnnounceMessage(ply:Name() .. " recovers 40 HP for killing an enemy!")
                end
            end
        end

        return true
    end,
    Pilfer_Courage = function(ply, state, properties)
        if not IsValid(ply) then return true end

        if math.random(1, 100) > 30 then return true end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then return true end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then return true end

        local enemySide
        if table.HasValue(fight.Side1, ply) then
            enemySide = fight.Side2
        elseif table.HasValue(fight.Side2, ply) then
            enemySide = fight.Side1
        end

        if not enemySide then return true end

        local sideMembers = {}
        for _, member in ipairs(enemySide) do table.insert(sideMembers, member) end

        for _, member in ipairs(sideMembers) do
            if IsValid(member) and member:GetNWInt("TBCHP", 0) > 0 then
                local memberDebuffs = GetAllStats(member, "debuffs")

                memberDebuffs["Panic"] = {stacks = 1, wearOff = "turnWearOff", duration = 3}

                AssignStat(member, "Panic", memberDebuffs["Panic"], "debuffs")
            end
        end

        weapon:AnnounceMessage(ply:Name() .. "'s Pilfer Courage sends the enemy team into a Panic!")

        return true
    end
}

-- Victory Heal statuses

local VictoryStatusHandlers = {
    Healing_Wave = function(ply, state, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local plyHP = ply:GetNWInt("TBCHP", 0)
                local maxHP = ply:GetNWInt("TBCMAXHP", 50)

                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")

                local heal =
                    40 *
                    (1 +
                        ((HandleStatus(ply, userBuffsTable, "increaseHeal", 40) -
                            HandleStatus(ply, userDebuffsTable, "decreaseHeal", 40)) +
                            (HandleStatus(ply, userBuffsTable, "increaseHealReceive", 40) -
                                HandleStatus(ply, userDebuffsTable, "decreaseHealReceive", 40))))

                local heal =
                    40 +
                    ((HandleStatus(ply, userBuffsTable, "flatIncreaseHeal", heal) -
                        HandleStatus(ply, userDebuffsTable, "flatDecreaseHeal", heal)) +
                        (HandleStatus(ply, userBuffsTable, "flatIncreaseHealReceive", heal) -
                            HandleStatus(ply, userDebuffsTable, "flatDecreaseHealReceive", heal)))

                plyHP = math.min(plyHP + heal, maxHP)

                ply:SetNWInt("TBCHP", plyHP)

                ply:ChatPrint("You recover " .. heal .. " HP by Healing Wave!")
            end
        end

        return true
    end
}

-- Reaction Heal statuses

local function EntityQualifiesForIceHoard(ent)
    if not IsValid(ent) then
        return false
    end

    local resist = util.JSONToTable(ent:GetNW2String("resist")) or {}
    local block = util.JSONToTable(ent:GetNW2String("block")) or {}
    local drain = util.JSONToTable(ent:GetNW2String("drain")) or {}
    local repel = util.JSONToTable(ent:GetNW2String("repel")) or {}

    return table.HasValue(resist, "Ice") or table.HasValue(block, "Ice") or table.HasValue(drain, "Ice") or
        table.HasValue(repel, "Ice")
end

local ReactionHealStatusHandlers = {
    Papillon_Heart = function(ply, effectsTable, properties)
        if effectsTable["ply"] ~= effectsTable["target"] then
            local plyHP = effectsTable["ply"]:GetNWInt("TBCHP", 0)
            local maxHP = effectsTable["ply"]:GetNWInt("TBCMAXHP", 50)

            local heal = 10

            plyHP = math.min(plyHP + heal, maxHP)

            effectsTable["ply"]:SetNWInt("TBCHP", plyHP)
            effectsTable["ply"]:ChatPrint("You recover " .. heal .. " HP by Papillon Heart!")
        end

        return true
    end,
    Benevolence = function(ply, effectsTable, properties)
        local plyHP = effectsTable["target"]:GetNWInt("TBCHP", 0)
        local maxHP = effectsTable["target"]:GetNWInt("TBCMAXHP", 50)
        if plyHP >= maxHP then
            local targetBuffsTable = GetAllStats(effectsTable["target"], "buffs")

            if targetBuffsTable["Tarukaja"] then
                targetBuffsTable["Tarukaja"].stacks = math.min(targetBuffsTable["Tarukaja"].stacks + 1, 4)
            else
                targetBuffsTable["Tarukaja"] = {stacks = 1}
            end

            AssignStat(effectsTable["target"], "Tarukaja", targetBuffsTable["Tarukaja"], "buffs")

            local message =
                effectsTable["target"]:Name() ..
                " received Tarukaja from " ..
                    effectsTable["ply"]:Name() ..
                        "! They now have " .. targetBuffsTable["Tarukaja"].stacks .. " stacks!"

            self:AnnounceMessage(message)
        end
        return true
    end,
    Bouncy_Body = function(ply, effectsTable, properties)
        if effectsTable["_bouncyBodyProcessed"] then
            return true
        end
        effectsTable["_bouncyBodyProcessed"] = true

        local target = effectsTable["target"]
        if not IsValid(target) then
            return true
        end

        local buffsTable = GetAllStats(target, "buffs")
        local currentStacks = (buffsTable["Sukukaja"] and buffsTable["Sukukaja"].stacks) or 0
        local newStacks = math.min(currentStacks + 1, 4)

        AssignStat(target, "Sukukaja", {stacks = newStacks}, "buffs")

        local weapon = target:GetActiveWeapon()
        if IsValid(weapon) then
            weapon:AnnounceMessage(target:Name() .. "'s Bouncy Body grants +1 Sukukaja! (" .. newStacks .. " stacks)")
        end

        return true
    end,
    Acid_Body = function(ply, effectsTable, properties)
        if effectsTable["_acidBodyProcessed"] then
            return true
        end
        effectsTable["_acidBodyProcessed"] = true

        local target = effectsTable["target"]
        if not IsValid(target) then
            return true
        end

        local buffsTable = GetAllStats(target, "buffs")
        local currentStacks = (buffsTable["Tarukaja"] and buffsTable["Tarukaja"].stacks) or 0
        local newStacks = math.min(currentStacks + 1, 4)

        AssignStat(target, "Tarukaja", {stacks = newStacks}, "buffs")

        local weapon = target:GetActiveWeapon()
        if IsValid(weapon) then
            weapon:AnnounceMessage(target:Name() .. "'s Acid Body grants +1 Tarukaja! (" .. newStacks .. " stacks)")
        end

        return true
    end,
    Ice_Hoard = function(ply, effectsTable, properties)
        if not IsValid(ply) then
            return true
        end

        local target = effectsTable["target"]
        if not IsValid(target) or target == ply then
            return true
        end

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) then
            return true
        end

        if EntityQualifiesForIceHoard(target) then
            local plyHP = ply:GetNWInt("TBCHP", 0)
            local maxHP = ply:GetNWInt("TBCMAXHP", 50)

            plyHP = math.min(plyHP + 20, maxHP)
            ply:SetNWInt("TBCHP", plyHP)

            weapon:AnnounceMessage(ply:Name() .. "'s Ice Hoard grants +20 HP for healing an Ice-resistant ally!")

            return true
        end

        if not weapon.FightId then
            return true
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then
            return true
        end

        local side
        if table.HasValue(fight.Side1, ply) then
            side = fight.Side1
        elseif table.HasValue(fight.Side2, ply) then
            side = fight.Side2
        end

        if not side then
            return true
        end

        local anyoneElseQualifies = false
        for _, member in ipairs(side) do
            if IsValid(member) and member ~= ply and EntityQualifiesForIceHoard(member) then
                anyoneElseQualifies = true
                break
            end
        end

        if not anyoneElseQualifies then
            local buffsTable = GetAllStats(ply, "buffs")
            local currentStacks = (buffsTable["Sukukaja"] and buffsTable["Sukukaja"].stacks) or 0
            local newStacks = math.min(currentStacks + 1, 4)

            AssignStat(ply, "Sukukaja", {stacks = newStacks}, "buffs")

            weapon:AnnounceMessage(ply:Name() .. "'s Ice Hoard grants +1 Sukukaja! (" .. newStacks .. " stacks)")
        end

        return true
    end
}

-- Reaction Buff statuses

local ReactionBuffStatusHandlers = {
    Soul_Matrix_Arrow = function(ply, effectsTable, properties)
        if effectsTable["ply"] ~= effectsTable["target"] then
            local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
            if playerStr >= 5 then
                if effectsTable["buff"] and effectsTable["buff"] == "Tarukaja" then
                    local weapon = ply:GetActiveWeapon()

                    local plyHP = ply:GetNWInt("TBCHP", 0)
                    local maxHP = ply:GetNWInt("TBCMAXHP", 50)

                    local heal = 6

                    plyHP = math.min(plyHP + heal, maxHP)

                    ply:SetNWInt("TBCHP", plyHP)
                    ply:ChatPrint("You recover " .. heal .. " HP by Soul Matrix!")
                end
            end
        end
        return true
    end,
    Soul_Matrix_Milady = function(ply, effectsTable, properties)
        if effectsTable["ply"] ~= effectsTable["target"] then
            local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
            if playerDex >= 5 then
                if effectsTable["buff"] and effectsTable["buff"] == "Sukukaja" then
                    local weapon = ply:GetActiveWeapon()

                    local userDebuffsTable = GetAllStats(ply, "debuffs")

                    if userDebuffsTable["Sukunda"] then
                        userDebuffsTable["Sukunda"].stacks = math.max(userDebuffsTable["Sukunda"].stacks - 1, 0)
                    else
                        return true
                    end

                    AssignStat(ply, "Sukunda", userDebuffsTable["Sukunda"], "debuffs")

                    local message = ""
                    if userDebuffsTable["Sukunda"] and userDebuffsTable["Sukunda"].stacks > 0 then
                        message = ply:Name() .. " reduced Sukunda due to Soul Matrix!"
                    elseif userDebuffsTable["Sukunda"] and userDebuffsTable["Sukunda"].stacks <= 0 then
                        userDebuffsTable["Sukunda"] = nil

                        message =
                            ply:Name() .. " reduced Sukunda due to Soul Matrix! Sukunda has been completely removed!"

                        RemoveStat(ply, "Sukunda", "debuffs")
                    end

                    weapon:AnnounceMessage(message)
                end
            end
        end
        return true
    end,
    Soul_Matrix_Saizo = function(ply, effectsTable, properties)
        if effectsTable["ply"] ~= effectsTable["target"] then
            local playerChr = tonumber(ply:GetNWInt("TBCCHR", 0))
            if playerChr >= 5 then
                local weapon = effectsTable["ply"]:GetActiveWeapon()

                local userBuffsTable = GetAllStats(ply, "buffs")

                if userBuffsTable["Tarukaja"] then
                    userBuffsTable["Tarukaja"].stacks = math.min(userBuffsTable["Tarukaja"].stacks + 1, 4)
                else
                    userBuffsTable["Tarukaja"] = {stacks = 1}
                end

                AssignStat(ply, "Tarukaja", userBuffsTable["Tarukaja"], "buffs")

                local message = ply:Name() .. " received Tarukaja from Soul Matrix!"

                weapon:AnnounceMessage(message)
            end
        end
        return true
    end
}

-- Reaction Debuff statuses

local ReactionDebuffStatusHandlers = {
    Raging_Temper = function(ply, effectsTable, properties)
        if effectsTable["debuff"] and (effectsTable["debuff"] == "Rakunda" or effectsTable["debuff"] == "Tarunda") then
            local weapon = ply:GetActiveWeapon()

            local userBuffsTable = GetAllStats(ply, "buffs")

            if userBuffsTable["Tarukaja"] then
                userBuffsTable["Tarukaja"].stacks = math.min(userBuffsTable["Tarukaja"].stacks + 1, 4)
            else
                userBuffsTable["Tarukaja"] = {stacks = 1}
            end

            AssignStat(ply, "Tarukaja", userBuffsTable["Tarukaja"], "buffs")

            local message = ply:Name() .. " received Tarukaja due to Raging Temper!"

            weapon:AnnounceMessage(message)
        end

        return true
    end,
    Prisoner_Diamond_Formation = function(ply, effectsTable, properties)
        if
            effectsTable["debuff"] and
                (effectsTable["debuff"] == "Rakunda" or effectsTable["debuff"] == "Tarunda" or
                    effectsTable["debuff"] == "Sukunda")
         then
            if effectsTable["targetDebuffsTable"][effectsTable["debuff"]] then
                if effectsTable["targetDebuffsTable"][effectsTable["debuff"]].stacks >= 2 then
                    effectsTable["targetDebuffsTable"][effectsTable["debuff"]] = {stacks = 2}
                end
            end

            AssignStat(
                ply,
                effectsTable["debuff"],
                effectsTable["targetDebuffsTable"][effectsTable["debuff"]],
                "debuffs"
            )
        end
        return true
    end
}

-- MP Cost increase or decrease

local IncreaseMPCostStatusHandlers = {}

local DecreaseMPCostStatusHandlers = {
    MP_Optimization = function(ply, cost, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if (weapon.WeaponType and "Magic Skill" == weapon.WeaponType) and ("Exclusive" ~= weapon.Rarity) then
                return math.ceil((cost) / (2))
            end
        end
        return 0
    end,
    Mastery_of_Magic = function(ply, cost, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if (weapon.WeaponType and "Magic Skill" == weapon.WeaponType) and not weapon.IsHeal then
                return math.ceil((cost) * (0.1))
            end
        end
        return 0
    end,
    Pinnacle_of_Magic = function(ply, cost, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            if not weapon.IsHeal then
                if (ply:UserID() == properties.caster) then
                    return math.ceil((cost) * (0.5))
                else
                    return math.ceil((cost) * (0.25))
                end
            end
        end
        return 0
    end
}

-- HP Cost increase or decrease

local IncreaseHPCostStatusHandlers = {}

local DecreaseHPCostStatusHandlers = {
    Suppressor = function(ply, cost, properties)
        if ply:GetNWInt("TBCHP", 100) <= (ply:GetNWInt("TBCMAXHP", 100) * 0.30) then
            return (cost)
        else
            return 0
        end
    end
}

-- React to damage statuses

local ReactionDamageStatusHandlers = {
    Soul_Matrix_Arrow = function(ply, effectsTable, properties)
        if ply then
            if tonumber(ply:GetNWInt("TBCCHR", 0)) >= 5 then
                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) and effectsTable["baseDamage"] >= 60 then
                    local userBuffsTable = GetAllStats(ply, "buffs")
                    if userBuffsTable["Rakukaja"] then
                        userBuffsTable["Rakukaja"].stacks = math.min(userBuffsTable["Rakukaja"].stacks + 1, 4)
                    else
                        userBuffsTable["Rakukaja"] = {stacks = 1}
                    end

                    AssignStat(ply, "Rakukaja", userBuffsTable["Rakukaja"], "buffs")

                    local message = ply:Name() .. " received Rakukaja from Soul Matrix!"
                    weapon:AnnounceMessage(message)
                end
            end
        end

        return true
    end,
    Gaia_Pact = function(ply, effectsTable, properties)
        local weapon = ply:GetActiveWeapon()

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if fight then
        else
            return
        end

        local playerSide =
            (table.HasValue(fight.Side1, ply) and "Side1") or (table.HasValue(fight.Side2, ply) and "Side2")

        for _, player in ipairs(fight[playerSide]) do
            if IsValid(player) and (player:UserID() == properties.caster) and (ply:UserID() ~= properties.caster) then
                local currentHP = player:GetNWInt("TBCHP", 100)
                local maxHP = player:GetNWInt("TBCMAXHP", 100)
                local targetCurrentHP = ply:GetNWInt("TBCHP", 100)
                local targetMaxHP = ply:GetNWInt("TBCMAXHP", 100)
                if currentHP >= (maxHP * 0.40) and targetCurrentHP <= (targetMaxHP * 0.30) then
                    local currentHP = player:GetNWInt("TBCHP", 100)
                    local baseDamage = (effectsTable["baseDamage"] / 0.6) - effectsTable["baseDamage"]
                    local newHP = math.ceil(currentHP - baseDamage)

                    player:SetNWInt("TBCHP", newHP)

                    weapon:AnnounceMessage(player:Name() .. " has taken " .. baseDamage .. " damage due to Gaia Pact!")
                    return true
                end
            end
        end
        return true
    end,
    Counter = function(ply, effectsTable, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()
            if IsValid(weapon) then
                local userBuffsTable = GetAllStats(ply, "buffs")
                local userDebuffsTable = GetAllStats(ply, "debuffs")
                local targetBuffsTable = GetAllStats(effectsTable["ply"], "buffs")
                local targetDebuffsTable = GetAllStats(effectsTable["ply"], "debuffs")

                local targetEffects = {}
                targetEffects["baseDamage"] = 40
                targetEffects["Affinity"] = "Physical"

                local playerLuck = ply:GetNWInt("TBCLuck", 10)
                playerLuck =
                    playerLuck +
                    (HandleStatus(ply, userBuffsTable, "increaseLuck", playerLuck) -
                        HandleStatus(ply, userDebuffsTable, "decreaseLuck", playerLuck))

                local critBonus =
                    (HandleStatus(ply, userBuffsTable, "increaseCritChance", targetEffects["baseDamage"]) -
                    HandleStatus(ply, userDebuffsTable, "decreaseCritChance", targetEffects["baseDamage"]))

                targetEffects["critChance"] = math.ceil((playerLuck / 2) + critBonus)

                targetEffects["ply"] = ply
                targetEffects["target"] = effectsTable["ply"]

                targetEffects["userBuffsTable"] = userBuffsTable
                targetEffects["userDebuffsTable"] = userDebuffsTable
                targetEffects["targetBuffsTable"] = targetBuffsTable
                targetEffects["targetDebuffsTable"] = targetDebuffsTable

                targetEffects["state"] = "normal"

                targetEffects = HandleResistances(targetEffects["ply"], targetEffects["target"], targetEffects)
                targetEffects = HandleWeaknesses(targetEffects["ply"], targetEffects["target"], targetEffects)
                targetEffects = HandleCrit(targetEffects["ply"], targetEffects["target"], targetEffects)
                targetEffects = HandleBlock(targetEffects["ply"], targetEffects["target"], targetEffects)
                targetEffects = HandleDrain(targetEffects["ply"], targetEffects["target"], targetEffects)

                local repel = util.JSONToTable(targetEffects["target"]:GetNW2String("repel"))
                local isRepelled = false

                if
                    targetEffects["targetBuffsTable"]["Tetrakarn"] and
                        table.HasValue(Affinities.Physical, targetEffects["Affinity"])
                 then
                    RemoveStat(targetEffects["target"], "Tetrakarn", "buffs")
                    targetEffects["targetBuffsTable"]["Tetrakarn"] = nil
                    isRepelled = true
                end

                if
                    targetEffects["targetBuffsTable"]["Makarakarn"] and
                        table.HasValue(Affinities.Magic, targetEffects["Affinity"])
                 then
                    RemoveStat(targetEffects["target"], "Makarakarn", "buffs")
                    targetEffects["targetBuffsTable"]["Makarakarn"] = nil
                    isRepelled = true
                end

                if
                    table.HasValue(repel, targetEffects["Affinity"]) or
                        (table.HasValue(repel, "Magic") and table.HasValue(Affinities.Magic, targetEffects["Affinity"])) or
                        (table.HasValue(repel, "Physical") and
                            table.HasValue(Affinities.Physical, targetEffects["Affinity"]))
                 then
                    isRepelled = true
                end

                if isRepelled then
                    targetEffects["state"] = "repel"
                    targetEffects["baseDamage"] = 0
                end

                targetEffects["baseDamage"] =
                    targetEffects["baseDamage"] +
                    (HandleStatus(
                        targetEffects["ply"],
                        targetEffects["userBuffsTable"],
                        "damage",
                        targetEffects["baseDamage"],
                        targetEffects
                    ) -
                        HandleStatus(
                            targetEffects["ply"],
                            targetEffects["userDebuffsTable"],
                            "decreaseDamage",
                            targetEffects["baseDamage"],
                            targetEffects
                        )) -
                    (HandleStatus(
                        targetEffects["target"],
                        targetEffects["targetBuffsTable"],
                        "defenseDamage",
                        targetEffects["baseDamage"],
                        targetEffects
                    ) -
                        HandleStatus(
                            targetEffects["target"],
                            targetEffects["targetDebuffsTable"],
                            "defenseDecrease",
                            targetEffects["baseDamage"],
                            targetEffects
                        ))

                targetEffects["baseDamage"] = math.ceil(targetEffects["baseDamage"])

                targetEffects = HandleDamageMessage(targetEffects["ply"], targetEffects["target"], targetEffects)

                if isRepelled then
                    targetEffects["message"] = effectsTable["target"]:Name() .. " negated the attack!"
                end

                local currentHP = targetEffects["target"]:GetNWInt("TBCHP", 100)
                local maxHP = targetEffects["target"]:GetNWInt("TBCMAXHP", 100)
                local newHP

                if targetEffects["state"] == "drain" then
                    newHP = math.min(currentHP + targetEffects["baseDamage"], maxHP)
                else
                    newHP = currentHP - targetEffects["baseDamage"]
                    HandleStatus(targetEffects["target"], targetEffects, "damageReaction", false, targetEffects)
                end

                targetEffects["target"]:SetNWInt("TBCHP", newHP)

                weapon:AnnounceMessage(targetEffects["message"])

                if newHP <= 0 then
                    targetEffects["target"]:SetNWInt("TBCHP", 0)

                    targetEffects["lifeState"] = "dead"
                    targetEffects = HandleDeath(targetEffects["ply"], targetEffects["target"], targetEffects)
                    targetEffects = HandleKill(targetEffects["ply"], targetEffects["target"], targetEffects)
                end
            end
        end

        return true
    end
}

-- Allowed to use Skills statuses

local SkillPreventStatusHandlers = {
    Mute = function(ply, effectsTable, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) and table.HasValue(SWEP_Categories["Skills"], weapon.WeaponType) then
                ply:ChatPrint("You can't use skills due to mute!")

                return false
            end
        end

        return true
    end
}

-- Increase or Decrease Resist damage modifier statuses

local IncreaseResistModifierStatusHandlers = {
    Proud_Presence = function(ply, modifier, properties)
        return modifier + 0.1
    end
}

local DecreaseResistModifierStatusHandlers = {}

-- Increase or Decrease Resist damage receive modifier statuses

local DecreaseResistModifierReceiveStatusHandlers = {}

local IncreaseResistModifierReceiveStatusHandlers = {}

-- Increase or Decrease weak damage receive modifier statuses

local IncreaseWeakModifierStatusHandlers = {
    Proud_Presence = function(ply, modifier, properties)
        return modifier + 0.1
    end
}

local DecreaseWeakModifierStatusHandlers = {}

-- Increase or Decrease weak damage receive modifier statuses

local DecreaseWeakModifierReceiveStatusHandlers = {
    Veil_of_Midnight = function(ply, modifier, properties)
        if ply then
            local currentHP = ply:GetNWInt("TBCHP", 100)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

            if currentHP <= (maxHP * 0.4) then
                return modifier - 0.1
            end
        end

        return modifier
    end
}

local IncreaseWeakModifierReceiveStatusHandlers = {}

-- Positive Ailment reaction statuses

local ReactionAilmentsStatusHandlers = {
    Icy_Glare = function(ply, effectsTable, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()
            local charId = effectsTable["target"]:GetNWString("AssignedCharacter")
            local charData = CHARACTERS.List[charId]
            if charData then
                if charData.type == "Boss" then
                    local currentHP = effectsTable["target"]:GetNWInt("TBCHP", 100)
                    local maxHP = effectsTable["target"]:GetNWInt("TBCMAXHP", 100)

                    local newHP = currentHP - 45

                    effectsTable["target"]:SetNWInt("TBCHP", newHP)

                    weapon:AnnounceMessage(
                        effectsTable["target"]:Name() .. " has taken 45 Almighty damage from Icy Glare!"
                    )
                end
            end
        end

        return false
    end
}

-- Element Wall checks statuses

local WallCheckStatusHandlers = {
    Fire_Wall = function(ply, affinity, effectsTable)
        if affinity == "Fire" then
            RemoveStat(ply, "Fire_Wall", "buffs")
            effectsTable["targetBuffsTable"]["Fire_Wall"] = nil
            return true
        end
        return false
    end,
    Ice_Wall = function(ply, affinity, effectsTable)
        if affinity == "Ice" then
            RemoveStat(ply, "Ice_Wall", "buffs")
            effectsTable["targetBuffsTable"]["Ice_Wall"] = nil
            return true
        end
        return false
    end,
    Elec_Wall = function(ply, affinity, effectsTable)
        if affinity == "Elec" then
            RemoveStat(ply, "Elec_Wall", "buffs")
            effectsTable["targetBuffsTable"]["Elec_Wall"] = nil
            return true
        end
        return false
    end,
    Force_Wall = function(ply, affinity, effectsTable)
        if affinity == "Force" then
            RemoveStat(ply, "Force_Wall", "buffs")
            effectsTable["targetBuffsTable"]["Force_Wall"] = nil
            return true
        end
        return false
    end,
    Nuke_Wall = function(ply, affinity, effectsTable)
        if affinity == "Nuke" then
            RemoveStat(ply, "Nuke_Wall", "buffs")
            effectsTable["targetBuffsTable"]["Nuke_Wall"] = nil
            return true
        end
        return false
    end
}

-- Element Resist checks statuses

local ResistCheckStatusHandlers = {
    Resist_Fire = function(ply, affinity, effectsTable)
        if affinity == "Fire" then
            return true
        end
        return false
    end,
    Resist_Ice = function(ply, affinity, effectsTable)
        if affinity == "Ice" then
            return true
        end
        return false
    end,
    Resist_Elec = function(ply, affinity, effectsTable)
        if affinity == "Elec" then
            return true
        end
        return false
    end,
    Resist_Force = function(ply, affinity, effectsTable)
        if affinity == "Force" then
            return true
        end
        return false
    end,
    Resist_Nuke = function(ply, affinity, effectsTable)
        if affinity == "Nuke" then
            return true
        end
        return false
    end,
    Resist_Dark = function(ply, affinity, effectsTable)
        if affinity == "Dark" then
            return true
        end
        return false
    end
}

-- Element Block checks statuses

local BlockCheckStatusHandlers = {
    Block_Fire = function(ply, affinity, effectsTable)
        if affinity == "Fire" then
            return true
        end
        return false
    end,
    Block_Ice = function(ply, affinity, effectsTable)
        if affinity == "Ice" then
            return true
        end
        return false
    end,
    Block_Elec = function(ply, affinity, effectsTable)
        if affinity == "Elec" then
            return true
        end
        return false
    end,
    Block_Force = function(ply, affinity, effectsTable)
        if affinity == "Force" then
            return true
        end
        return false
    end,
    Block_Nuke = function(ply, affinity, effectsTable)
        if affinity == "Nuke" then
            return true
        end
        return false
    end
}

-- Element Drain checks statuses

local DrainCheckStatusHandlers = {
    Drain_Fire = function(ply, affinity, effectsTable)
        if affinity == "Fire" then
            return true
        end
        return false
    end,
    Drain_Ice = function(ply, affinity, effectsTable)
        if affinity == "Ice" then
            return true
        end
        return false
    end,
    Drain_Elec = function(ply, affinity, effectsTable)
        if affinity == "Elec" then
            return true
        end
        return false
    end,
    Drain_Force = function(ply, affinity, effectsTable)
        if affinity == "Force" then
            return true
        end
        return false
    end,
    Drain_Nuke = function(ply, affinity, effectsTable)
        if affinity == "Nuke" then
            return true
        end
        return false
    end
}

-- Element Repel checks statuses

local RepelCheckStatusHandlers = {
    Repel_Fire = function(ply, affinity, effectsTable)
        if affinity == "Fire" then
            return true
        end
        return false
    end,
    Repel_Ice = function(ply, affinity, effectsTable)
        if affinity == "Ice" then
            return true
        end
        return false
    end,
    Repel_Elec = function(ply, affinity, effectsTable)
        if affinity == "Elec" then
            return true
        end
        return false
    end,
    Repel_Force = function(ply, affinity, effectsTable)
        if affinity == "Force" then
            return true
        end
        return false
    end,
    Repel_Nuke = function(ply, affinity, effectsTable)
        if affinity == "Nuke" then
            return true
        end
        return false
    end
}

-- Element Breaks checks statuses

local BreakCheckStatusHandlers = {
    Fire_Break = function(ply, affinity, effectsTable)
        if affinity == "Fire" then
            RemoveStat(ply, "Fire_Break", "debuffs")
            effectsTable["targetDebuffsTable"]["Fire_Break"] = nil
            return true
        end
        return false
    end,
    Ice_Break = function(ply, affinity, effectsTable)
        if affinity == "Ice" then
            RemoveStat(ply, "Ice_Break", "debuffs")
            effectsTable["targetDebuffsTable"]["Ice_Break"] = nil
            return true
        end
        return false
    end,
    Elec_Break = function(ply, affinity, effectsTable)
        if affinity == "Elec" then
            RemoveStat(ply, "Elec_Break", "debuffs")
            effectsTable["targetDebuffsTable"]["Elec_Break"] = nil
            return true
        end
        return false
    end,
    Force_Break = function(ply, affinity, effectsTable)
        if affinity == "Force" then
            RemoveStat(ply, "Force_Break", "debuffs")
            effectsTable["targetDebuffsTable"]["Force_Break"] = nil
            return true
        end
        return false
    end,
    Nuke_Break = function(ply, affinity, effectsTable)
        if affinity == "Nuke" then
            RemoveStat(ply, "Nuke_Break", "debuffs")
            effectsTable["targetDebuffsTable"]["Nuke_Break"] = nil
            return true
        end
        return false
    end
}

-- Combat Tactics usage check statuses
local ComTacStatusHandlers = {
    Welcome_the_Dawn = function(ply, effectsTable, properties)
        local casterPlayer = Player(properties.caster)

        if IsValid(casterPlayer) and ply:UserID() ~= properties.caster then
            local targetBuffsTable = GetAllStats(casterPlayer, "buffs")

            if targetBuffsTable["Tarukaja"] then
                targetBuffsTable["Tarukaja"].stacks = math.min(targetBuffsTable["Tarukaja"].stacks + 1, 4)
            else
                targetBuffsTable["Tarukaja"] = {stacks = 1}
            end

            AssignStat(casterPlayer, "Tarukaja", targetBuffsTable["Tarukaja"], "buffs")

            ply:ChatPrint("You've gained a Tarukaja Stack!")
        end

        return true
    end
}

local IncreaseDownDefenseStatusHandlers = {
    Veil_of_Sunrise = function(ply, chance, properties, targetEffects)
        local casterPlayer = Player(properties.caster)

        if IsValid(casterPlayer) then
            if ply:UserID() ~= properties.caster then
                return chance + 25
            else
                return chance + 50
            end
        end

        return chance
    end
}

-- Stat Change check statuses
local StatChangeHandlers = {
    Omakase = function(ply, effectsTable, properties)
        local playerStr = tonumber(ply:GetNWInt("TBCSTR", 0))
        local playerDex = tonumber(ply:GetNWInt("TBCDEX", 0))
        local userBuffsTable = GetAllStats(ply, "permabuffs")

        if userBuffsTable["Omakase"].visibility == 0 then
            if playerStr >= 6 then
                local currentHP = ply:GetNWInt("TBCHP", 100)
                local maxHP = ply:GetNWInt("TBCMAXHP", 100)
                if currentHP == maxHP then
                    ply:SetNWInt("TBCHP", maxHP + 20)
                end
                ply:SetNWInt("TBCMAXHP", maxHP + 20)

                userBuffsTable["Omakase"].visibility = 1
                AssignStat(ply, "Omakase", userBuffsTable["Omakase"], "permabuffs")
            elseif playerDex >= 6 then
                local currentMP = ply:GetNWInt("TBCMP", 100)
                local maxMP = ply:GetNWInt("TBCMAXMP", 100)
                if currentMP == maxMP then
                    ply:SetNWInt("TBCHP", maxMP + 30)
                end
                ply:SetNWInt("TBCMAXHP", maxMP + 30)

                userBuffsTable["Omakase"].visibility = 1
                AssignStat(ply, "Omakase", userBuffsTable["Omakase"], "permabuffs")
            end
        elseif userBuffsTable["Omakase"].visibility == 1 then
            if playerStr < 6 then
                local currentHP = ply:GetNWInt("TBCHP", 100)
                local maxHP = ply:GetNWInt("TBCMAXHP", 100)
                if currentHP >= maxHP then
                    ply:SetNWInt("TBCHP", maxHP - 20)
                end
                ply:SetNWInt("TBCMAXHP", maxHP - 20)

                userBuffsTable["Omakase"].visibility = 0
                AssignStat(ply, "Omakase", userBuffsTable["Omakase"], "permabuffs")
            elseif playerDex < 6 then
                local currentMP = ply:GetNWInt("TBCMP", 100)
                local maxMP = ply:GetNWInt("TBCMAXMP", 100)
                if currentMP >= maxMP then
                    ply:SetNWInt("TBCHP", maxMP - 30)
                end
                ply:SetNWInt("TBCMAXHP", maxMP - 30)

                userBuffsTable["Omakase"].visibility = 0
                AssignStat(ply, "Omakase", userBuffsTable["Omakase"], "permabuffs")
            end
        end

        return true
    end
}

function HandleStatus(ply, statusList, statusType, value, effectsTable)
    if statusType == "damage" or statusType == "decreaseDamage" then
        local damage = value
        local effectTable = {}
        effectTable = effectsTable
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "damage" then
                local handler = DamageDealerStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    damage = handler(ply, effectTable, properties, damage)
                end
            elseif statusType == "decreaseDamage" then
                local handler = DamageDecreaseStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    damage = handler(ply, effectTable, properties, damage)
                end
            end
        end

        if statusType == "decreaseDamage" and damage == value then
            return 0
        else
            damage = math.abs(damage - value)
            return math.ceil(damage)
        end
    elseif statusType == "defenseDamage" or statusType == "defenseDecrease" then
        local damage = value
        local effectTable = {}
        effectTable = effectsTable
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            -- Get the handler for this status
            local handler
            if statusType == "defenseDamage" then
                local handler = DamageDefenseStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    damage = handler(ply, effectTable, properties, damage)
                end
            elseif statusType == "defenseDecrease" then
                local handler = DefenseDecreaseStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    damage = handler(ply, effectTable, properties, damage)
                end
            end
        end

        if damage == value then
            return 0
        else
            damage = math.abs(value - damage)
            return math.ceil(damage)
        end
    elseif statusType == "increaseHeal" or statusType == "decreaseHeal" then
        local heal = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseHeal" then
                local handler = IncreaseHealStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    heal = handler(ply, heal, properties, effectsTable)
                end
            elseif statusType == "decreaseHeal" then
                local handler = DecreaseHealStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    heal = handler(ply, heal, properties, effectsTable)
                end
            end
        end

        if statusType == "decreaseHeal" and heal == 0 then
            return 0
        else
            return heal
        end
    elseif statusType == "increaseHealReceive" or statusType == "decreaseHealReceive" then
        local heal = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseHealReceive" then
                local handler = IncreaseHealReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    heal = handler(ply, heal, properties)
                end
            elseif statusType == "decreaseHealReceive" then
                local handler = DecreaseHealReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    heal = handler(ply, heal, properties)
                end
            end
        end
        if statusType == "decreaseHealReceive" and heal == 0 then
            return 0
        else
            return heal
        end
    elseif statusType == "flatIncreaseHeal" or statusType == "flatDecreaseHeal" then
        local heal = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "flatIncreaseHeal" then
                local handler = FlatIncreaseHealStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    heal = handler(ply, heal, properties, effectsTable)
                end
            elseif statusType == "flatDecreaseHeal" then
            -- local handler = DecreaseHealStatusHandlers[status]
            -- -- If a handler was found, call it
            -- if handler then
            --     heal = handler(ply, heal, properties, effectsTable)
            -- end
            end
        end

        if statusType == "flatDecreaseHeal" and heal == 0 then
            return 0
        else
            return heal
        end
    elseif statusType == "flatIncreaseHealReceive" or statusType == "flatDecreaseHealReceive" then
        local heal = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "flatIncreaseHealReceive" then
                -- local handler = IncreaseHealReceiveStatusHandlers[status]
                -- -- If a handler was found, call it
                -- if handler then
                --     heal = handler(ply, heal, properties)
                -- end
            elseif statusType == "flatDecreaseHealReceive" then
            -- local handler = DecreaseHealReceiveStatusHandlers[status]
            -- -- If a handler was found, call it
            -- if handler then
            --     heal = handler(ply, heal, properties)
            -- end
            end
        end
        if statusType == "flatDecreaseHealReceive" and heal == 0 then
            return 0
        else
            return heal
        end
    elseif statusType == "increaseTech" or statusType == "decreaseTech" then
        local tech = 0
        local type = effectsTable
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "increaseTech" then
                local handler = IncreaseTechniqueStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    tech = handler(ply, tech, properties, type)
                end
            elseif statusType == "decreaseTech" then
                local handler = DecreaseTechniqueStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    tech = handler(ply, tech, properties, type)
                end
            end
        end
        if statusType == "decreaseTech" and tech == 0 then
            return 0
        else
            return math.abs(tech)
        end
    elseif statusType == "increaseLuck" or statusType == "decreaseLuck" then
        local luck = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "increaseLuck" then
                local handler = IncreaseLuckStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    luck = handler(ply, luck, properties)
                end
            elseif statusType == "decreaseLuck" then
                local handler = DecreaseLuckStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    luck = handler(ply, luck, properties)
                end
            end
        end

        if statusType == "decreaseLuck" and luck == 0 then
            return 0
        else
            return math.abs(luck)
        end
    elseif statusType == "increaseEscapeChance" or statusType == "decreaseEscapeChance" then
        local chance = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "increaseEscapeChance" then
                local handler = IncreaseEscapeStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    chance = handler(ply, chance, properties)
                end
            elseif statusType == "decreaseEscapeChance" then
                local handler = DecreaseEscapeStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    chance = handler(ply, chance, properties)
                end
            end
        end

        if statusType == "decreaseEscapeChance" and chance == 0 then
            return 0
        else
            return math.abs(chance)
        end
    elseif statusType == "increaseHPCost" or statusType == "decreaseHPCost" then
        local cost = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseHPCost" then
                local handler = IncreaseHPCostStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    cost = handler(ply, value, properties)
                end
            elseif statusType == "decreaseHPCost" then
                local handler = DecreaseHPCostStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    cost = handler(ply, value, properties)
                end
            end
        end

        if cost == 0 then
            return 0
        else
            if statusType == "decreaseHPCost" then
                if cost > value then
                    cost = value
                else
                    cost = math.abs(cost)
                end
            else
                cost = math.abs(cost - value)
            end

            return math.ceil(cost)
        end
    elseif statusType == "increaseMPCost" or statusType == "decreaseMPCost" then
        local cost = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseMPCost" then
                local handler = IncreaseMPCostStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    cost = handler(ply, value, properties)
                end
            elseif statusType == "decreaseMPCost" then
                local handler = DecreaseMPCostStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    cost = handler(ply, value, properties)
                end
            end
        end

        if cost == 0 then
            return 0
        else
            if statusType == "decreaseMPCost" then
                if cost > value then
                    cost = value
                else
                    cost = math.abs(cost)
                end
            else
                cost = math.abs(cost - value)
            end

            return math.ceil(cost)
        end
    elseif statusType == "increaseCritChance" or statusType == "decreaseCritChance" then
        local crit = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseCritChance" then
                local handler = IncreaseCritReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    crit = handler(ply, crit, properties)
                end
            elseif statusType == "decreaseCritChance" then
                local handler = DecreaseCritReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    crit = handler(ply, crit, properties)
                end
            end
        end
        if statusType == "decreaseCritChance" and crit == 0 then
            return 0
        else
            return crit
        end
    elseif statusType == "increaseAilmentChance" or statusType == "decreaseAilmentChance" then
        local ailmentChance = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseAilmentChance" then
                local handler = IncreaseAilmentChanceStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    ailmentChance = handler(ply, ailmentChance, properties, effectsTable)
                end
            elseif statusType == "decreaseAilmentChance" then
                local handler = DecreaseAilmentChanceStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    ailmentChance = handler(ply, ailmentChance, properties, effectsTable)
                end
            end
        end

        if statusType == "decreaseAilmentChance" and ailmentChance == 0 then
            return 0
        else
            return ailmentChance
        end
    elseif statusType == "increaseAilmentReceive" or statusType == "decreaseAilmentReceive" then
        local ailmentChance = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            if statusType == "increaseAilmentReceive" then
                local handler = IncreaseAilmentReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    ailmentChance = handler(ply, ailmentChance, properties, effectsTable)
                end
            elseif statusType == "decreaseAilmentReceive" then
                local handler = DecreaseAilmentReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    ailmentChance = handler(ply, ailmentChance, properties, effectsTable)
                end
            end
        end
        if statusType == "decreaseAilmentChance" and ailmentChance == 0 then
            return 0
        else
            return ailmentChance
        end
    elseif statusType == "bonusCritDamage" then
        local damage = false
        local handler = BonusCritDamageStatusHandlers[statusList]
        -- If a handler was found, call it
        if handler then
            damage = handler(ply, damage, value)
        end
        return damage
    elseif statusType == "increaseResistDamage" or statusType == "decreaseResistDamage" then
        local modifier = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "increaseResistDamage" then
                local handler = IncreaseResistModifierStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            elseif statusType == "decreaseResistDamage" then
                local handler = DecreaseResistModifierStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            end
        end

        if statusType == "decreaseResistDamage" and modifier == 0 then
            return 0
        else
            return modifier
        end
    elseif statusType == "decreaseResistDamageReceive" or statusType == "increaseResistDamageReceive" then
        local modifier = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "decreaseResistDamageReceive" then
                local handler = DecreaseResistModifierReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            elseif statusType == "increaseResistDamageReceive" then
                local handler = IncreaseResistModifierReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            end
        end

        if statusType == "decreaseResistDamageReceive" and modifier == 0 then
            return 0
        else
            return modifier
        end
    elseif statusType == "increaseWeakDamage" or statusType == "decreaseWeakDamage" then
        local modifier = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "increaseWeakDamage" then
                local handler = IncreaseWeakModifierStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            elseif statusType == "decreaseWeakDamage" then
                local handler = DecreaseWeakModifierStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            end
        end

        if statusType == "decreaseWeakDamage" and modifier == 0 then
            return 0
        else
            return modifier
        end
    elseif statusType == "decreaseWeakDamageReceive" or statusType == "increaseWeakDamageReceive" then
        local modifier = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler
            if statusType == "decreaseWeakDamageReceive" then
                local handler = DecreaseWeakModifierReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            elseif statusType == "increaseWeakDamageReceive" then
                local handler = IncreaseWeakModifierReceiveStatusHandlers[status]
                -- If a handler was found, call it
                if handler then
                    modifier = handler(ply, modifier, properties)
                end
            end
        end

        if statusType == "decreaseWeakDamageReceive" and modifier == 0 then
            return 0
        else
            return modifier
        end
    elseif statusType == "deathState" then
        local state = "dead"
        local handler = DeathStateStatusHandlers[statusList]
        -- If a handler was found, call it
        if handler then
            state = handler(ply, state, false)
        end
        return state
    elseif statusType == "onDeath" then
        local state = false
        local handler = OnDeathStatusHandlers[statusList]
        -- If a handler was found, call it
        if handler then
            state = handler(ply, effectsTable, false)
        end
        return state
    elseif statusType == "kill" then
        local state = "killed"
        local handler = KillStatusHandlers[statusList]
        -- If a handler was found, call it
        if handler then
            state = handler(ply, state, false)
        end
        return state
    elseif statusType == "victory" then
        local state = "victorious"
        local handler = VictoryStatusHandlers[statusList]
        -- If a handler was found, call it
        if handler then
            state = handler(ply, state, false)
        end
        return state
    elseif statusType == "reactionHeal" then
        local state = "reactionHeal"
        for status, properties in pairs(statusList) do
            local handler = ReactionHealStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, effectsTable, false)
            end
        end
        return state
    elseif statusType == "reactionBuff" then
        local state = "reactionBuff"
        for status, properties in pairs(statusList) do
            local handler = ReactionBuffStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, effectsTable, false)
            end
        end
        return state
    elseif statusType == "reactionDebuff" then
        local state = "reactionDebuff"
        for status, properties in pairs(statusList) do
            local handler = ReactionDebuffStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, effectsTable, false)
            end
        end
        return state
    elseif statusType == "damageReaction" then
        local state = "damageReaction"
        for status, properties in pairs(effectsTable["targetBuffsTable"]) do
            local handler = ReactionDamageStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, effectsTable, properties)
            end
        end
        for status, properties in pairs(effectsTable["targetDebuffsTable"]) do
            local handler = ReactionDamageStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, effectsTable, properties)
            end
        end
        return state
    elseif statusType == "ailmentReaction" then
        local ailment = value
        for status, properties in pairs(effectsTable["userBuffsTable"]) do
            local handler = ReactionAilmentsStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                ailment = handler(ply, effectsTable, false)
            end
        end
        return ailment
    elseif statusType == "canUseSkills" then
        local state = true
        for status, properties in pairs(statusList) do
            local handler = SkillPreventStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, effectsTable, false)
                if not state then
                    return state
                end
            end
        end
        return state
    elseif statusType == "wallChecks" then
        local state = false
        for status, properties in pairs(statusList) do
            local handler = WallCheckStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, value, effectsTable)
                if state then
                    return state
                end
            end
        end
        return state
    elseif statusType == "resistChecks" then
        local state = false
        for status, properties in pairs(statusList) do
            local handler = ResistCheckStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, value, effectsTable)
                if state then
                    return state
                end
            end
        end
        return state
    elseif statusType == "blockChecks" then
        local state = false
        for status, properties in pairs(statusList) do
            local handler = BlockCheckStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                state = handler(ply, value, effectsTable)
                if state then
                    return state
                end
            end
        end
        return state
    elseif statusType == "comtacReaction" then
        local result = false
        for status, properties in pairs(statusList) do
            local handler = ComTacStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                result = handler(ply, effectsTable, properties)
                if result then
                    return result
                end
            end
        end
        return result
    elseif statusType == "increaseDownDefense" then
        local downChance = 0
        -- Loop through each status in the list
        for status, properties in pairs(statusList) do
            local handler = IncreaseDownDefenseStatusHandlers[status]
            -- If a handler was found, call it
            if handler then
                downChance = handler(ply, downChance, properties, effectsTable)
            end
        end

        if downChance == value then
            return 0
        else
            downChance = math.abs(value - downChance)
            return math.ceil(downChance)
        end
    end
    return value
end
