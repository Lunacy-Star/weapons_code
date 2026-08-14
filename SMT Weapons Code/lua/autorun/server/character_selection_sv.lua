-- Server-side Character Selection Handler
if CLIENT then
    return
end

TBC_DEFAULT_CHARACTER = "citizen"

-- Add network strings
util.AddNetworkString("SelectCharacter")
util.AddNetworkString("SelectCharacterModel")

function ApplyCharacterToPlayer(ply, charID, modelPath)
    if not IsValid(ply) then
        return false
    end
    if not CHARACTERS or not CHARACTERS.List or not CHARACTERS.List[charID] then
        return false
    end

    -- Switching characters is about to wipe every weapon this player holds,
    -- including any demon-granted move set. Drop demon possession and the
    -- active-demon selection first so nothing stale carries into the new character.
    if DEMONCOMP and DEMONCOMP.ResetPlayerDemonState then
        DEMONCOMP.ResetPlayerDemonState(ply)
    end

    -- Anything the player owns beyond their (about to be replaced) character's
    -- freebie loadout is moved to personal storage before it gets wiped below,
    -- so switching characters never destroys earned gear. Must run before
    -- AssignedCharacter is overwritten, since it reads the OLD character's
    -- base-weapon list to know what counts as "extra".
    if LOADOUTPERSIST and LOADOUTPERSIST.StashExtras then
        LOADOUTPERSIST.StashExtras(ply)
    end

    -- Essence-picked weapons only belong to the character they were picked
    -- for -- clear the tracked set now that the switch is committed, so the
    -- new character starts with nothing marked free until it grants its own.
    ply.TBC_EssenceWeapons = {}

    local character = CHARACTERS.List[charID]

    -- Resolve model
    if not modelPath or modelPath == "" then
        modelPath = character.model[1]
    else
        local validModel = false
        for _, model in ipairs(character.model) do
            if model == modelPath then
                validModel = true
                break
            end
        end
        if not validModel then
            modelPath = character.model[1]
        end
    end

    -- Set the assigned character
    ply:SetNWString("AssignedCharacter", charID)
    ply:SetNWString("SelectedModel_" .. charID, modelPath)

    -- Apply character stats
    ply:SetNWInt("TBCHP", character.combatHP or 100)
    ply:SetNWInt("TBCMAXHP", character.combatHP or 100)
    ply:SetNWInt("TBCMP", character.combatMP or 50)
    ply:SetNWInt("TBCMAXMP", character.combatMP or 100)
    ply:SetNWInt("TBCLuck", character.Luck or 10)
    ply:SetNWInt("TBCTechnique", character.Technique or 20)
    ply:SetNWInt("TBCEquipmentSlots", character.equipmentSlots or 15)
    ply:SetNWInt("TBCItemSlots", character.itemSlots or 10)

    -- Store resistances/weaknesses
    ply:SetNW2String("resist", util.TableToJSON(character.resist or {}))
    ply:SetNW2String("weak", util.TableToJSON(character.weak or {}))
    ply:SetNW2String("block", util.TableToJSON(character.block or {}))
    ply:SetNW2String("drain", util.TableToJSON(character.drain or {}))
    ply:SetNW2String("repel", util.TableToJSON(character.repel or {}))

    -- Reset persona
    ply:SetNW2String("selectedPersona", "")

    -- Clear all stats
    RemoveAllStats(ply, "buffs")
    RemoveAllStats(ply, "debuffs")
    RemoveAllStats(ply, "permabuffs")
    RemoveAllStats(ply, "permadebuffs")
    RemoveAllStats(ply, "personas")
    RemoveAllStats(ply, "permapersonas")

    -- Apply permanent buffs
    if character.permaBuffs then
        for status, properties in pairs(character.permaBuffs) do
            AssignStat(ply, status, properties, "permabuffs")
        end
    end

    -- Apply permanent debuffs
    if character.permaDebuffs then
        for status, properties in pairs(character.permaDebuffs) do
            AssignStat(ply, status, properties, "permadebuffs")
        end
    end

    -- Apply character name color to MTChat
    if character.color then
        local cr = math.Clamp(character.color.r or 120, 0, 255)
        local cg = math.Clamp(character.color.g or 120, 0, 255)
        local cb = math.Clamp(character.color.b or 120, 0, 255)

        ply.MTChat_NameColor = {r = cr, g = cg, b = cb}

        net.Start("mtchat_namecolor_update")
        net.WriteEntity(ply)
        net.WriteUInt(cr, 8)
        net.WriteUInt(cg, 8)
        net.WriteUInt(cb, 8)
        net.Broadcast()
    end

    -- Give character weapons
    if character.weapons then
        ply:StripWeapons()
        for _, weapon in ipairs(character.weapons) do
            ply:Give(weapon)
        end
    end

    -- This character's kilodevil cost may differ from the last one, so keep
    -- the party's stored total (and everyone's synced copy of it) accurate.
    if IsPlayerInAnyParty and RecalculatePartyKilodevil and BroadcastPlayerParty then
        local partyId = IsPlayerInAnyParty(ply)
        if partyId then
            RecalculatePartyKilodevil(partyId)
            BroadcastPlayerParty(ply, partyId)
        end
    end

    return true
end

-- ============================================================
-- Auto-assign default character on first connect
-- ============================================================
hook.Add(
    "PlayerInitialSpawn",
    "TBC_AssignDefaultCharacter",
    function(ply)
        timer.Simple(
            0.5,
            function()
                if not IsValid(ply) then
                    return
                end

                local charID = ply:GetNWString("AssignedCharacter", "")

                if charID == "" and not (LOADOUTPERSIST and LOADOUTPERSIST.HasSavedData(ply)) then
                    local defaultChar = TBC_DEFAULT_CHARACTER or "citizen"

                    if CHARACTERS and CHARACTERS.List and CHARACTERS.List[defaultChar] then
                        ApplyCharacterToPlayer(ply, defaultChar, nil)
                        ply:Spawn()

                        local character = CHARACTERS.List[defaultChar]
                        ply:SetHealth(character.combatHP or 100)
                        ply:SetMaxHealth(character.combatHP or 100)
                        ply:SetArmor(0)
                        ply:SetMaxArmor(0)

                        ply:ChatPrint("You have been assigned as " .. character.name .. "!")
                    end
                end
            end
        )
    end
)

-- ============================================================
-- PlayerLoadout: suppress sandbox defaults, give character weapons
-- ============================================================
hook.Add(
    "PlayerLoadout",
    "TBC_OverrideLoadout",
    function(ply)
        local charID = ply:GetNWString("AssignedCharacter", "")

        if charID ~= "" and CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
            local character = CHARACTERS.List[charID]

            if character.weapons then
                for _, weaponClass in ipairs(character.weapons) do
                    if not ply:HasWeapon(weaponClass) then
                        ply:Give(weaponClass)
                    end
                end
            end

            return true
        end
    end
)

-- ============================================================
-- Handle character selection (with respawn)
-- ============================================================
net.Receive(
    "SelectCharacter",
    function(len, ply)
        local charID = net.ReadString()
        local modelPath = net.ReadString()

        if not CHARACTERS or not CHARACTERS.List or not CHARACTERS.List[charID] then
            ply:ChatPrint("Invalid character selection!")
            return
        end

        local character = CHARACTERS.List[charID]

        local validModel = false
        for _, model in ipairs(character.model) do
            if model == modelPath then
                validModel = true
                break
            end
        end

        if not validModel then
            ply:ChatPrint("Invalid model for this character!")
            return
        end

        ApplyCharacterToPlayer(ply, charID, modelPath)

        ply:Spawn()

        ply:SetHealth(character.combatHP or 100)
        ply:SetMaxHealth(character.combatHP or 100)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        ply:ChatPrint("You are now playing as " .. character.name .. "!")
    end
)

-- ============================================================
-- Handle model selection only (no respawn)
-- ============================================================
net.Receive(
    "SelectCharacterModel",
    function(len, ply)
        local modelPath = net.ReadString()

        local charID = ply:GetNWString("AssignedCharacter", "")

        if charID == "" then
            ply:ChatPrint("You must select a character first!")
            return
        end

        if not CHARACTERS or not CHARACTERS.List or not CHARACTERS.List[charID] then
            ply:ChatPrint("Invalid character!")
            return
        end

        local character = CHARACTERS.List[charID]

        local validModel = false
        for _, model in ipairs(character.model) do
            if model == modelPath then
                validModel = true
                break
            end
        end

        if not validModel then
            ply:ChatPrint("Invalid model for this character!")
            return
        end

        ply:SetNWString("SelectedModel_" .. charID, modelPath)
        ply:SetModel(modelPath)

        local simplemodel = player_manager.TranslateToPlayerModelName(modelPath)
        local info = player_manager.TranslatePlayerHands(simplemodel)
        if info then
            local hands = ply:GetHands()
            if IsValid(hands) then
                hands:SetModel(info.model)
                hands:SetSkin(info.skin)
                hands:SetBodyGroups(info.body)
            end
        end

        ply:ChatPrint("Model changed!")
    end
)

-- ============================================================
-- Prevent sandbox/gamemode from overriding character models
-- ============================================================
hook.Add(
    "PlayerSetModel",
    "PreventCharacterModelOverride",
    function(ply)
        local charID = ply:GetNWString("AssignedCharacter", "")

        if charID ~= "" and CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
            local modelPath = ply:GetNWString("SelectedModel_" .. charID, "")

            if modelPath == "" then
                modelPath = CHARACTERS.List[charID].model[1]
            end

            ply:SetModel(modelPath)
            return true
        end
    end
)

-- ============================================================
-- Restore character model AND stats on every spawn/respawn
-- ============================================================
hook.Add(
    "PlayerSpawn",
    "RestoreCharacterOnSpawn",
    function(ply)
        local charID = ply:GetNWString("AssignedCharacter", "")

        if charID ~= "" and CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
            local character = CHARACTERS.List[charID]
            local modelPath = ply:GetNWString("SelectedModel_" .. charID, "")

            if modelPath == "" then
                modelPath = character.model[1]
            end

            -- Restore model
            ply:SetModel(modelPath)

            -- Restore all combat stats to character defaults
            ply:SetNWInt("TBCHP", character.combatHP or 100)
            ply:SetNWInt("TBCMAXHP", character.combatHP or 100)
            ply:SetNWInt("TBCMP", character.combatMP or 50)
            ply:SetNWInt("TBCMAXMP", character.combatMP or 100)
            ply:SetNWInt("TBCLuck", character.Luck or 10)
            ply:SetNWInt("TBCTechnique", character.Technique or 20)

            -- Restore source engine health/armor
            ply:SetHealth(character.combatHP or 100)
            ply:SetMaxHealth(character.combatHP or 100)
            ply:SetArmor(0)
            ply:SetMaxArmor(0)

            -- Clear temporary combat buffs/debuffs (perma ones persist)
            RemoveAllStats(ply, "buffs")
            RemoveAllStats(ply, "debuffs")

            -- Delayed model set to override sandbox
            timer.Simple(
                0,
                function()
                    if IsValid(ply) then
                        ply:SetModel(modelPath)
                    end
                end
            )
        end
    end
)

-- ============================================================
-- Utility: get a player's current character data
-- ============================================================
function GetPlayerCharacter(ply)
    local charID = ply:GetNWString("AssignedCharacter", "")

    if charID == "" then
        return nil
    end

    if CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
        return CHARACTERS.List[charID], charID
    end

    return nil
end

-- ============================================================
-- Utility: is `key` something ply's current character hands out for free?
-- Covers three cases, none of which may ever be treated as player-owned --
-- not droppable, not storable, not bankable by Loadout Persistence -- since
-- they're re-granted fresh (at an essence cost, for the latter two) every
-- time the player becomes this character, not earned once and kept forever:
--   1. A base loadout weapon (charData.weapons).
--   2. An essence-picked Persona (charData.loadoutItems keys match Personas
--      table keys directly -- no indirection layer -- so pool-membership
--      alone correctly identifies these).
--   3. An essence-picked weapon. These CANNOT be recognized via
--      charData.loadoutItems pool-membership: loadout_menu.lua's
--      OpenLoadoutMenu picks by LoadoutItems[key] and gives
--      LoadoutItems[key].class, so the classname the player actually holds
--      is never equal to the loadoutItems pool key. Instead, loadout_menu.lua
--      tracks exactly which classnames essence granted this character-life in
--      ply.TBC_EssenceWeapons (reset below on every switch).
-- ============================================================
function TBC_IsFreeCharacterItem(ply, key)
    if not IsValid(ply) then
        return false
    end

    local charID = ply:GetNWString("AssignedCharacter", "")
    if CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
        local character = CHARACTERS.List[charID]

        if character.weapons then
            for _, base in ipairs(character.weapons) do
                if base == key then
                    return true
                end
            end
        end

        if character.loadoutItems then
            for _, item in pairs(character.loadoutItems) do
                if item == key then
                    return true
                end
            end
        end
    end

    if ply.TBC_EssenceWeapons and ply.TBC_EssenceWeapons[key] then
        return true
    end

    return false
end
