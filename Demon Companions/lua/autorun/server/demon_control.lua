-- Demon Companion System - Demon control (server)
-- Lets a master act through a deployed demon: their weapons are swapped for
-- the demon's own move set, and while one of those weapons attacks, every
-- stat/buff/debuff read or write that targets the master is transparently
-- redirected to the demon. Damage aimed AT the master is untouched because
-- redirection only applies to the entity currently attacking.

if CLIENT then return end

DEMONCOMP = DEMONCOMP or {}

-- Weapons the player always keeps, in and out of demon control
local KEEP_WEAPONS = {
    smti_engageswep = true, -- holds FightId / InCombat state, must never be stripped
    smti_demonswep = true -- needed to switch back
}

-- While a demon-granted weapon is attacking this is {ply = ..., demon = ...}
DEMONCOMP.AttackCtx = nil

-- DEMONCOMP.ControlData[ply] = {demon, storedWeapons, demonWeapons}
DEMONCOMP.ControlData = DEMONCOMP.ControlData or {}

-- ============================================================
-- Stat redirection
-- ============================================================
local REDIRECT_NWINT = {
    TBCHP = true, TBCMAXHP = true, TBCMP = true, TBCMAXMP = true,
    TBCLuck = true, TBCTechnique = true, TBCSTR = true, TBCDEX = true,
    TBCCHR = true
}

local REDIRECT_NW2STRING = {
    resist = true, weak = true, block = true, drain = true, repel = true
}

local function ctxRedirect(ent)
    local ctx = DEMONCOMP.AttackCtx
    if ctx and ent == ctx.ply and IsValid(ctx.demon) then
        return ctx.demon
    end
    return ent
end

local redirectsInstalled = false

local function InstallRedirects()
    if redirectsInstalled then return end
    -- buffs_manager.lua must have loaded first
    if not GetAllStats or not AssignStat then return end
    redirectsInstalled = true

    -- Buff/debuff table access (GetAllStats & friends key by SteamID)
    local origGetAllStats = GetAllStats
    function GetAllStats(ent, statType)
        return origGetAllStats(ctxRedirect(ent), statType)
    end

    local origAssignStat = AssignStat
    function AssignStat(ent, buffName, buffData, statType)
        return origAssignStat(ctxRedirect(ent), buffName, buffData, statType)
    end

    local origRemoveStat = RemoveStat
    function RemoveStat(ent, buffName, statType)
        return origRemoveStat(ctxRedirect(ent), buffName, statType)
    end

    local origRemoveAllStats = RemoveAllStats
    function RemoveAllStats(ent, statType)
        return origRemoveAllStats(ctxRedirect(ent), statType)
    end

    local origModifyStat = ModifyStat
    function ModifyStat(ent, buffName, newStatData, statType)
        return origModifyStat(ctxRedirect(ent), buffName, newStatData, statType)
    end

    if HasAnyStats then
        local origHasAnyStats = HasAnyStats
        function HasAnyStats(ent, statType)
            return origHasAnyStats(ctxRedirect(ent), statType)
        end
    end

    -- Networked stats (combat HP/MP, luck, technique, attribute points)
    local ENTITY = FindMetaTable("Entity")

    local origGetNWInt = ENTITY.GetNWInt
    function ENTITY:GetNWInt(key, fallback)
        local ctx = DEMONCOMP.AttackCtx
        if ctx and self == ctx.ply and REDIRECT_NWINT[key] and IsValid(ctx.demon) then
            return origGetNWInt(ctx.demon, key, fallback)
        end
        return origGetNWInt(self, key, fallback)
    end

    local origSetNWInt = ENTITY.SetNWInt
    function ENTITY:SetNWInt(key, value)
        local ctx = DEMONCOMP.AttackCtx
        if ctx and self == ctx.ply and REDIRECT_NWINT[key] and IsValid(ctx.demon) then
            return origSetNWInt(ctx.demon, key, value)
        end
        return origSetNWInt(self, key, value)
    end

    -- Affinities (resist/weak/block/drain/repel) for repel-back handling
    local origGetNW2String = ENTITY.GetNW2String
    function ENTITY:GetNW2String(key, fallback)
        local ctx = DEMONCOMP.AttackCtx
        if ctx and self == ctx.ply and REDIRECT_NW2STRING[key] and IsValid(ctx.demon) then
            return origGetNW2String(ctx.demon, key, fallback)
        end
        return origGetNW2String(self, key, fallback)
    end

    -- Character id (some skills scale off the attacker's character data)
    local origGetNWString = ENTITY.GetNWString
    function ENTITY:GetNWString(key, fallback)
        local ctx = DEMONCOMP.AttackCtx
        if ctx and self == ctx.ply and key == "AssignedCharacter" and IsValid(ctx.demon) then
            return origGetNWString(ctx.demon, key, fallback)
        end
        return origGetNWString(self, key, fallback)
    end

    -- Battle messages should carry the demon's name while it acts
    local PLAYER = FindMetaTable("Player")

    local origNick = PLAYER.Nick
    function PLAYER:Nick()
        local ctx = DEMONCOMP.AttackCtx
        if ctx and self == ctx.ply and IsValid(ctx.demon) then
            return ctx.demon:GetNWString("DemonName", origNick(self))
        end
        return origNick(self)
    end

    local origName = PLAYER.Name
    function PLAYER:Name()
        local ctx = DEMONCOMP.AttackCtx
        if ctx and self == ctx.ply and IsValid(ctx.demon) then
            return ctx.demon:GetNWString("DemonName", origName(self))
        end
        return origName(self)
    end

    print("[Demon Companions] Stat redirection installed.")
end

hook.Add("InitPostEntity", "DEMONCOMP_InstallRedirects", InstallRedirects)
-- lua refresh / late load: the stat functions already exist, install now
InstallRedirects()

-- ============================================================
-- Weapon wrapping
-- ============================================================
local function wrapAttack(wep, methodName, ply, demon)
    local original = wep[methodName]
    if not original then return end

    wep[methodName] = function(self, ...)
        if CLIENT then return original(self, ...) end

        -- Only redirect while the master still controls this demon
        if not IsValid(demon) or ply.TBCControlledDemon ~= demon then
            return original(self, ...)
        end

        DEMONCOMP.AttackCtx = {ply = ply, demon = demon}
        local results = {pcall(original, self, ...)}
        DEMONCOMP.AttackCtx = nil

        local ok = table.remove(results, 1)
        if not ok then
            ErrorNoHalt("[Demon Companions] " .. tostring(results[1]) .. "\n")
            return
        end

        if methodName == "PrimaryAttack" and IsValid(demon) and demon.DoAttackAnim then
            demon:DoAttackAnim()
        end

        return unpack(results)
    end
end

-- ============================================================
-- Switching control
-- ============================================================
function DEMONCOMP.IsControlling(ply)
    return DEMONCOMP.ControlData[ply] ~= nil
end

function DEMONCOMP.StartControl(ply, demon)
    if not IsValid(ply) or not IsValid(demon) then return false, "Invalid demon." end
    if DEMONCOMP.ControlData[ply] then return false, "You are already acting through a demon." end
    if demon:GetMaster() ~= ply then return false, "That demon does not answer to you." end
    if demon:GetNWInt("TBCHP", 0) <= 0 then return false, "That demon is down and cannot act." end

    local charData = DEMONCOMP.GetCharData(demon.CharId or demon:GetNWString("DemonCharId", ""))
    if not charData then return false, "Unknown demon character data." end

    local engage = ply:GetWeapon("smti_engageswep")

    -- Remember and remove the master's own equipment
    local stored = {}
    for _, wep in pairs(ply:GetWeapons()) do
        local class = wep:GetClass()
        if not KEEP_WEAPONS[class] then
            table.insert(stored, class)
        end
    end
    for _, class in ipairs(stored) do
        ply:StripWeapon(class)
    end

    -- Hand over the demon's move set
    local given = {}
    for _, class in ipairs(charData.weapons or {}) do
        if not KEEP_WEAPONS[class] and not ply:HasWeapon(class) then
            local wep = ply:Give(class)
            if IsValid(wep) then
                table.insert(given, class)
                wrapAttack(wep, "PrimaryAttack", ply, demon)
                wrapAttack(wep, "SecondaryAttack", ply, demon)
                if IsValid(engage) and engage.FightId then
                    wep.FightId = engage.FightId
                end
            end
        end
    end

    DEMONCOMP.ControlData[ply] = {
        demon = demon,
        storedWeapons = stored,
        demonWeapons = given
    }

    ply.TBCControlledDemon = demon
    ply:SetNWBool("DemonControlling", true)
    ply:SetNWEntity("ControlledDemon", demon)

    ply:ChatPrint("You are now acting through " .. demon:Name() ..
        ". Your attacks use its weapons and stats. Press RELOAD with the Demon Commander to switch back.")

    return true
end

-- skipRestore is used when the player's whole loadout is about to be (or
-- was just) wiped out from under us by something else - death/respawn or a
-- character switch. In that case we must NOT hand back the "stored"
-- pre-control weapons, because those classes belonged to whatever character
-- the player WAS playing; the respawn/character-apply flow is about to give
-- (or already gave) the correct weapons for what they are playing now.
function DEMONCOMP.EndControl(ply, skipRestore)
    local data = DEMONCOMP.ControlData[ply]
    if not data then return false, "You are not acting through a demon." end

    DEMONCOMP.ControlData[ply] = nil

    if not IsValid(ply) then return true end

    ply.TBCControlledDemon = nil
    ply:SetNWBool("DemonControlling", false)
    ply:SetNWEntity("ControlledDemon", NULL)

    if skipRestore then
        -- Defensive cleanup only - strip any demon weapons that might still
        -- be lingering, but don't touch the player's current loadout.
        for _, class in ipairs(data.demonWeapons) do
            if ply:HasWeapon(class) then
                ply:StripWeapon(class)
            end
        end
        return true
    end

    local engage = ply:GetWeapon("smti_engageswep")

    -- Take the demon's move set away
    for _, class in ipairs(data.demonWeapons) do
        ply:StripWeapon(class)
    end

    -- Return the master's own equipment
    for _, class in ipairs(data.storedWeapons) do
        if not ply:HasWeapon(class) then
            local wep = ply:Give(class)
            if IsValid(wep) and IsValid(engage) and engage.FightId then
                wep.FightId = engage.FightId
            end
        end
    end

    if ply:HasWeapon("smti_demonswep") then
        ply:SelectWeapon("smti_demonswep")
    end

    ply:ChatPrint("You are acting as yourself again.")

    return true
end

function DEMONCOMP.ToggleControl(ply, demon)
    if DEMONCOMP.ControlData[ply] then
        return DEMONCOMP.EndControl(ply)
    end
    return DEMONCOMP.StartControl(ply, demon)
end

-- Drops demon possession and the active-demon selection. Called whenever
-- the player's identity/loadout is about to reset from under the demon
-- system (death, character switch) so nothing stale carries over.
function DEMONCOMP.ResetPlayerDemonState(ply)
    if not IsValid(ply) then return end

    if DEMONCOMP.ControlData[ply] then
        DEMONCOMP.EndControl(ply, true)
    end

    ply:SetNWEntity("ActiveDemon", NULL)
end

-- Safety: clear control + selection state on death/disconnect
hook.Add("PlayerDeath", "DEMONCOMP_EndControlOnDeath", function(victim)
    DEMONCOMP.ResetPlayerDemonState(victim)
end)

hook.Add("PlayerDisconnected", "DEMONCOMP_EndControlOnLeave", function(ply)
    DEMONCOMP.ControlData[ply] = nil
end)
