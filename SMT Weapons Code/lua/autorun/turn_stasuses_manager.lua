local function TriggerBouncyBody(ply)
    local buffsTable = GetAllStats(ply, "buffs")
    if not buffsTable["Bouncy_Body"] then
        return
    end

    local currentStacks = (buffsTable["Sukukaja"] and buffsTable["Sukukaja"].stacks) or 0
    local newStacks = math.min(currentStacks + 1, 4)

    AssignStat(ply, "Sukukaja", {stacks = newStacks}, "buffs")

    local weapon = ply:GetActiveWeapon()
    if IsValid(weapon) then
        weapon:AnnounceMessage(ply:Name() .. "'s Bouncy Body grants +1 Sukukaja! (" .. newStacks .. " stacks)")
    end
end

local function TriggerAcidBody(ply)
    local buffsTable = GetAllStats(ply, "buffs")
    if not buffsTable["Acid_Body"] then
        return
    end

    local currentStacks = (buffsTable["Tarukaja"] and buffsTable["Tarukaja"].stacks) or 0
    local newStacks = math.min(currentStacks + 1, 4)

    AssignStat(ply, "Tarukaja", {stacks = newStacks}, "buffs")

    local weapon = ply:GetActiveWeapon()
    if IsValid(weapon) then
        weapon:AnnounceMessage(ply:Name() .. "'s Acid Body grants +1 Tarukaja! (" .. newStacks .. " stacks)")
    end
end

local TurnDamageStatusHandlers = {
    Burn = function(ply, damage, properties)
        return 10
    end,
    Poison = function(ply, damage, properties)
        return 20
    end
}

local TurnRegenStatusHandlers = {
    Regenerate = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            local HPToHeal = ply:GetNWInt("TBCHP", 10)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

            local baseDamage = 10

            local newHP = math.min(HPToHeal + baseDamage, maxHP)
            ply:SetNWInt("TBCHP", newHP)

            local message = ply:Name() .. " Regenerated " .. baseDamage .. " HP!"

            weapon:AnnounceMessage(message)

            TriggerBouncyBody(ply)
            TriggerAcidBody(ply)
        end
    end,
    Invigorate = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            local MPToHeal = ply:GetNWInt("TBCMP", 10)
            local maxMP = ply:GetNWInt("TBCMAXMP", 100)

            local baseDamage = 5

            local newMP = math.min(MPToHeal + baseDamage, maxMP)
            ply:SetNWInt("TBCMP", newMP)

            local message = ply:Name() .. " Regenerated " .. baseDamage .. " MP!"

            weapon:AnnounceMessage(message)

            TriggerBouncyBody(ply)
            TriggerAcidBody(ply)
        end
    end,
    Auto_Repair = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            local HPToHeal = ply:GetNWInt("TBCHP", 10)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

            local baseDamage = 25

            local newHP = math.min(HPToHeal + baseDamage, maxHP)
            ply:SetNWInt("TBCHP", newHP)

            local message = ply:Name() .. " received " .. baseDamage .. " healing from Auto-Repair!"

            weapon:AnnounceMessage(message)

            TriggerBouncyBody(ply)
            TriggerAcidBody(ply)
        end
    end,
    Lydia = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            local HPToHeal = ply:GetNWInt("TBCHP", 10)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

            local baseDamage = maxHP * 0.1

            local newHP = math.min(HPToHeal + baseDamage, maxHP)
            ply:SetNWInt("TBCHP", newHP)

            local message = ply:Name() .. " Regenerated " .. baseDamage .. " HP!"

            weapon:AnnounceMessage(message)
        end
    end,
    Majestic_Presence = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local weaponClass = weapon:GetClass()
            local HPToHeal = ply:GetNWInt("TBCHP", 10)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

            local baseDamage = maxHP * 0.1

            local newHP = math.min(HPToHeal + baseDamage, maxHP)
            ply:SetNWInt("TBCHP", newHP)

            local message = ply:Name() .. " Regenerated " .. baseDamage .. " HP!"

            weapon:AnnounceMessage(message)
        end
    end,
    Welcome_the_Dawn = function(ply, damage, properties)
        local targetBuffsTable = GetAllStats(ply, "buffs")
        if targetBuffsTable["Tarukaja"] then
            if targetBuffsTable["Tarukaja"].stacks >= 3 then
                local weapon = ply:GetActiveWeapon()
                if IsValid(weapon) then
                    local casterMaxHP = ply:GetNWInt("TBCMAXHP", 100)

                    local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
                    if fight then
                    else
                        return
                    end

                    local playerSide =
                        (table.HasValue(fight.Side1, ply) and "Side1") or (table.HasValue(fight.Side2, ply) and "Side2")

                    for _, player in ipairs(fight[playerSide]) do
                        local HPToHeal = ply:GetNWInt("TBCHP", 10)
                        local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                        local baseDamage = (maxHP * 0.04)

                        local newHP = math.min(HPToHeal + baseDamage, maxHP)
                        ply:SetNWInt("TBCHP", newHP)

                        local message = ply:Name() .. " Regenerated " .. baseDamage .. " HP!"

                        weapon:AnnounceMessage(message)
                    end
                end
            end
        end
    end
}

local TurnSkipStatusHandlers = {
    Shock = function(ply, damage, properties)
        local targetBuffsTable = GetAllStats(ply, "buffs")
        if targetBuffsTable["Closing_Pitch"] then
            local weapon = ply:GetActiveWeapon()
            if IsValid(weapon) then
                local HPToHeal = ply:GetNWInt("TBCHP", 10)
                local maxHP = ply:GetNWInt("TBCMAXHP", 100)

                local baseDamage = 15

                local newHP = math.min(HPToHeal + baseDamage, maxHP)
                ply:SetNWInt("TBCHP", newHP)

                if targetBuffsTable["Sukukaja"] then
                    targetBuffsTable["Sukukaja"].stacks = math.min(targetBuffsTable["Sukukaja"].stacks + 1, 4)
                else
                    targetBuffsTable["Sukukaja"] = {stacks = 1}
                end

                AssignStat(ply, "Sukukaja", targetBuffsTable["Sukukaja"], "buffs")

                local message =
                    ply:Name() .. " Regenerated " .. baseDamage .. " HP and gained Sukukaja! Their Shock? Gone..."

                weapon:AnnounceMessage(message)
            end
            return 0
        end

        return 50
    end,
    Freeze = function(ply, damage, properties)
        return 50
    end,
    Paralysis = function(ply, damage, properties)
        return 50
    end,
    Sleep = function(ply, damage, properties)
        if ply then
            local weapon = ply:GetActiveWeapon()

            if IsValid(weapon) then
                local charId = ply:GetNWString("AssignedCharacter")
                local charData = CHARACTERS.List[charId]
                if charData then
                    if charData.type ~= "Boss" then
                        local plyHP = ply:GetNWInt("TBCHP", 0)
                        local maxHP = ply:GetNWInt("TBCMAXHP", 50)
                        local plyMP = ply:GetNWInt("TBCMP", 0)
                        local maxMP = ply:GetNWInt("TBCMAXMP", 50)

                        plyHP = math.min(plyHP + 20, maxHP)
                        plyMP = math.min(plyMP + 10, maxMP)

                        ply:SetNWInt("TBCHP", plyHP)
                        ply:SetNWInt("TBCMP", plyMP)

                        weapon:AnnounceMessage(ply:Name() .. " recovers 20 HP and 10 MP!")
                    end
                end
            end
        end

        return 100
    end
}

local TurnMiscStatusHandlers = {
    Tansu_of_Vengeance = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then
            return false
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then
            return false
        end

        local side
        if table.HasValue(fight.Side1, ply) then
            side = fight.Side1
        elseif table.HasValue(fight.Side2, ply) then
            side = fight.Side2
        end

        if not side then
            return false
        end

        local totalAllies = 0
        local deadAllies = 0

        for _, member in ipairs(side) do
            if IsValid(member) and member ~= ply then
                totalAllies = totalAllies + 1
                if member:GetNWInt("TBCHP", 0) <= 0 then
                    deadAllies = deadAllies + 1
                end
            end
        end

        local tarukajaGain

        if totalAllies == 0 then
            -- Inugami started the fight alone: flat +1 Tarukaja every turn.
            tarukajaGain = 1
        elseif deadAllies > 0 then
            tarukajaGain = math.min(deadAllies, 4)
        else
            tarukajaGain = 0
        end

        if tarukajaGain > 0 then
            local buffsTable = GetAllStats(ply, "buffs")
            local currentStacks = (buffsTable["Tarukaja"] and buffsTable["Tarukaja"].stacks) or 0
            local newStacks = math.min(currentStacks + tarukajaGain, 4)

            AssignStat(ply, "Tarukaja", {stacks = newStacks}, "buffs")

            weapon:AnnounceMessage(
                ply:Name() ..
                    "'s Tansu of Vengeance grants +" .. tarukajaGain .. " Tarukaja! (" .. newStacks .. " stacks)"
            )
        end

        if totalAllies > 0 and (deadAllies >= 4 or deadAllies >= totalAllies) then
            local debuffsTable = GetAllStats(ply, "debuffs")
            if debuffsTable["Tarunda"] then
                RemoveStat(ply, "Tarunda", "debuffs")
                weapon:AnnounceMessage(ply:Name() .. " is cleansed of Tarunda by Tansu of Vengeance!")
            end
        end

        return true
    end,
    Succubus_Allure = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then
            return false
        end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then
            return false
        end

        local afflictedCount = 0
        for _, sideKey in ipairs({"Side1", "Side2"}) do
            for _, member in ipairs(fight[sideKey]) do
                if IsValid(member) then
                    local memberDebuffs = GetAllStats(member, "debuffs")
                    if memberDebuffs["Charm"] or memberDebuffs["Sleep"] then
                        afflictedCount = afflictedCount + 1
                    end
                end
            end
        end

        if afflictedCount <= 0 then
            return true
        end

        local healHP = afflictedCount * 5
        local healMP = afflictedCount * 10

        local currentHP = ply:GetNWInt("TBCHP", 100)
        local maxHP = ply:GetNWInt("TBCMAXHP", 100)
        ply:SetNWInt("TBCHP", math.min(currentHP + healHP, maxHP))

        local currentMP = ply:GetNWInt("TBCMP", 100)
        local maxMP = ply:GetNWInt("TBCMAXMP", 100)
        ply:SetNWInt("TBCMP", math.min(currentMP + healMP, maxMP))

        weapon:AnnounceMessage(
            ply:Name() .. "'s Succubus Allure regenerates " .. healHP .. " HP and " .. healMP .. " MP!"
        )

        return true
    end,
    Minotaur_Cleanse = function(ply, damage, properties)
        local currentHP = ply:GetNWInt("TBCHP", 0)
        if currentHP > 1000 then
            return false
        end

        if ply.MinotaurCleansed then
            return false
        end
        ply.MinotaurCleansed = true

        RemoveAllStats(ply, "debuffs")

        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            weapon:AnnounceMessage(ply:Name() .. " enters Phase 3 and removes every debuff applied to him!")
        end

        return true
    end,
    Hydra_Cleanse = function(ply, damage, properties)
        local currentHP = ply:GetNWInt("TBCHP", 0)
        local maxHP = ply:GetNWInt("TBCMAXHP", 1)
        if currentHP > maxHP * 0.4 then
            return false
        end

        if ply.HydraCleansed then
            return false
        end
        ply.HydraCleansed = true

        RemoveAllStats(ply, "debuffs")

        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            weapon:AnnounceMessage(ply:Name() .. " enters Phase 3 and removes every debuff applied to itself!")
        end

        return true
    end,
    Matador_PhaseDekaja = function(ply, damage, properties)
        local currentHP = ply:GetNWInt("TBCHP", 0)
        if currentHP > 1500 then return false end

        if ply.MatadorPhaseDekajaCast then return false end
        ply.MatadorPhaseDekajaCast = true

        local weapon = ply:GetActiveWeapon()
        if not IsValid(weapon) or not weapon.FightId then return false end

        local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
        if not fight then return false end

        local enemySide
        if table.HasValue(fight.Side1, ply) then
            enemySide = fight.Side2
        elseif table.HasValue(fight.Side2, ply) then
            enemySide = fight.Side1
        end

        if not enemySide then return false end

        local sideMembers = {}
        for _, member in ipairs(enemySide) do table.insert(sideMembers, member) end

        local buffsToRemove = Ailments_Statuses["Dekaja"]

        for _, member in ipairs(sideMembers) do
            if IsValid(member) and member:GetNWInt("TBCHP", 0) > 0 then
                local buffsTable = GetAllStats(member, "buffs")

                for _, buffName in ipairs(buffsToRemove) do
                    if buffsTable[buffName] then
                        RemoveStat(member, buffName, "buffs")
                        buffsTable[buffName] = nil
                    end
                end
            end
        end

        weapon:AnnounceMessage(ply:Name() .. " enters Phase 3 and casts Dekaja on the enemy team!")

        return true
    end
}

function HandleTurnStatus(ply, status, statusType, properties)
    if statusType == "turnDamage" then
        local damage = 0
        -- Loop through each status in the list
        local handler = TurnDamageStatusHandlers[status]
        -- If a handler was found, call it
        if handler then
            damage = handler(ply, damage, properties)
        end

        return math.ceil(damage)
    elseif statusType == "turnRegen" then
        local damage = 0
        -- Loop through each status in the list
        local handler = TurnRegenStatusHandlers[status]
        -- If a handler was found, call it
        if handler then
            damage = handler(ply, damage, properties)
        end
    elseif statusType == "turnMisc" then
        local state = false
        -- Loop through each status in the list
        local handler = TurnMiscStatusHandlers[status]
        -- If a handler was found, call it
        if handler then
            state = handler(ply, state, properties)
        end
    elseif statusType == "turnSkipper" then
        local skipped = 0
        -- Loop through each status in the list
        local handler = TurnSkipStatusHandlers[status]
        -- If a handler was found, call it
        if handler then
            skipped = handler(ply, skipped, properties)
        end
        return skipped
    end
    return 0
end
