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
    -- TODO Make the buff actually do the buff thing.
    Tansu_of_Vengeance = function(ply, damage, properties)
        local weapon = ply:GetActiveWeapon()
        if IsValid(weapon) then
            local fight = TBCWeaponMetatable.OngoingFights[weapon.FightId]
            if fight then
            else
                return false
            end

            local weaponClass = weapon:GetClass()
            local HPToHeal = ply:GetNWInt("TBCHP", 10)
            local maxHP = ply:GetNWInt("TBCMAXHP", 100)

            local baseDamage = 10

            local newHP = math.min(HPToHeal + baseDamage, maxHP)
            ply:SetNWInt("TBCHP", newHP)

            local message = ply:Name() .. " Regenerated " .. baseDamage .. " HP!"

            weapon:AnnounceMessage(message)
        end
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
        local handler = TurnRegenStatusHandlers[status]
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
