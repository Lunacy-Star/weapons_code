if not PlayerStats then PlayerStats = {} end

if SERVER then
    util.AddNetworkString("PlayerStatUpdate")
    util.AddNetworkString("PlayerStatRemove")
    util.AddNetworkString("PlayerStatModify")
    util.AddNetworkString("PlayerStatSync")

    local function SendPlayerStatsToPlayer(targetPlayer)
        if not IsValid(targetPlayer) then return end

        net.Start("PlayerStatSync")
        net.WriteTable(PlayerStats)
        net.Send(targetPlayer)
    end

    local function BroadcastPlayerStat(player, statType)
        if not IsValid(player) then return end
        local steamID = player:SteamID()

        net.Start("PlayerStatUpdate")
        net.WriteEntity(player)
        net.WriteString(statType)
        net.WriteTable(
            PlayerStats[steamID] and PlayerStats[steamID][statType] or {})
        net.Broadcast()
    end

    function AssignStat(player, buffName, buffData, statType)
        if not IsValid(player) then return end

        PlayerStats[player:SteamID()] = PlayerStats[player:SteamID()] or {}
        PlayerStats[player:SteamID()][statType] =
            PlayerStats[player:SteamID()][statType] or {}
        PlayerStats[player:SteamID()][statType][buffName] = buffData

        BroadcastPlayerStat(player, statType)

        if SMTDamageNumbers and (statType == "buffs" or statType == "debuffs") then
            local stacks = (istable(buffData) and buffData.stacks) or 1
            SMTDamageNumbers.Show(player, stacks, statType == "buffs" and "buff" or "debuff", buffName)
        end
    end

    function RemoveStat(player, buffName, statType)
        if not IsValid(player) then return end

        if PlayerStats[player:SteamID()] then
            if PlayerStats[player:SteamID()][statType] then
                if PlayerStats[player:SteamID()][statType][buffName] then
                    PlayerStats[player:SteamID()][statType][buffName] = nil
                    BroadcastPlayerStat(player, statType)
                end
            end
        end
    end

    function RemoveAllStats(player, statType)
        if not IsValid(player) then return end

        if PlayerStats[player:SteamID()] and
            PlayerStats[player:SteamID()][statType] then
            PlayerStats[player:SteamID()][statType] = nil

            BroadcastPlayerStat(player, statType)

        end
    end

    function ModifyStat(player, buffName, newStatData, statType)
        if not IsValid(player) then return end

        if PlayerStats[player:SteamID()] and
            PlayerStats[player:SteamID()][statType][buffName] then
            PlayerStats[player:SteamID()][statType][buffName] = newStatData

            BroadcastPlayerStat(player, statType)

        end
    end

    function HasAnyStats(player, statType)
        if not IsValid(player) then return false end

        local steamID = player:SteamID()
        if PlayerStats[steamID] and table.Count(PlayerStats[steamID][statType]) >
            0 then
            return true
        else
            return false
        end
    end

    function GetAllStats(player, statType)
        if not IsValid(player) then return {} end
        if not PlayerStats then return {} end
        local steamID = player:SteamID()
        if not PlayerStats[steamID] then return {} end

        if PlayerStats[steamID][statType] then
            return PlayerStats[steamID][statType]
        else
            return {}
        end
    end

    -- Hook into PlayerInitialSpawn
    hook.Add("PlayerInitialSpawn", "SyncPlayerStatsOnInitialSpawn",
             function(player) SendPlayerStatsToPlayer(player) end)

    -- Applies the one-time Max HP/MP increase for stat-boost passives (Life
    -- Bonus, Mana Bonus, ...). Data-driven off maxHPBonus/maxMPBonus on the
    -- buff's own properties table so it works identically whether the buff
    -- arrived via essence pickup (smti_lifebonus/smti_manabonus :Use()) or
    -- as a character-innate permaBuff (ApplyCharacterToPlayer / smt_demon).
    function ApplyStatBoostBuff(target, properties)
        if not IsValid(target) or not properties then return end

        if properties.maxHPBonus then
            local currentHP = target:GetNWInt("TBCHP", 100)
            local maxHP = target:GetNWInt("TBCMAXHP", 100)

            if currentHP >= maxHP then
                target:SetNWInt("TBCHP", maxHP + properties.maxHPBonus)
            end

            target:SetNWInt("TBCMAXHP", maxHP + properties.maxHPBonus)
        end

        if properties.maxMPBonus then
            local currentMP = target:GetNWInt("TBCMP", 100)
            local maxMP = target:GetNWInt("TBCMAXMP", 100)

            if currentMP >= maxMP then
                target:SetNWInt("TBCMP", maxMP + properties.maxMPBonus)
            end

            target:SetNWInt("TBCMAXMP", maxMP + properties.maxMPBonus)
        end
    end
end

if CLIENT then

    net.Receive("PlayerStatUpdate", function()
        local player = net.ReadEntity()
        if not IsValid(player) then return end

        local statType = net.ReadString()
        local statData = net.ReadTable()

        PlayerStats[player:SteamID()] = PlayerStats[player:SteamID()] or {}
        PlayerStats[player:SteamID()][statType] = statData
    end)

    net.Receive("PlayerStatRemove", function()
        local player = net.ReadEntity()
        local buffName = net.ReadString()
    end)

    net.Receive("PlayerStatModify", function()
        local player = net.ReadEntity()
        local buffName = net.ReadString()
        local newStatData = net.ReadTable()
    end)

    net.Receive("PlayerStatSync", function()
        local allStats = net.ReadTable()
        PlayerStats = allStats
    end)

    function GetAllStatsClient(player, statType)
        if not IsValid(player) then return {} end
        if not PlayerStats then return {} end
        local steamID = player:SteamID()
        if not PlayerStats[steamID] then return {} end

        if PlayerStats[steamID][statType] then
            return PlayerStats[steamID][statType]
        else
            return {}
        end
    end
end
