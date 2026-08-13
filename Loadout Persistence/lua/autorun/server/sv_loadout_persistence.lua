-- Loadout Persistence: moves everything a player owns beyond their current
-- character's freebie loadout into their personal storage (the dialogue_entity
-- addon's STORAGE system) whenever that gear would otherwise be lost --
-- switching characters, disconnecting, or the server shutting down / changing
-- map -- and offers to restore both the character and that stashed gear when
-- they reconnect.
--
-- Depends on globals from "SMT Weapons Code": CHARACTERS, ApplyCharacterToPlayer,
-- AssignStat/RemoveStat/GetAllStats, Personas, Passives.
-- Depends on STORAGE.EnsurePlayerBucket/FindFreeSlot/Save from "dialogue_entity".

if CLIENT then
    return
end

LOADOUTPERSIST = LOADOUTPERSIST or {}
LOADOUTPERSIST.SavePath = "tbc_loadout_data.json"
LOADOUTPERSIST.Data = LOADOUTPERSIST.Data or {}

-- Marker written onto storage entries stashed by a disconnect/shutdown (as
-- opposed to a plain character switch), so an accepted restore pulls back
-- exactly this batch and nothing the player banked manually.
local PENDING_TAG = "loadout_pending_restore"

local dataDirty = false

util.AddNetworkString("LoadoutPersist_Offer")
util.AddNetworkString("LoadoutPersist_Confirm")

-- ============================================================
-- Save file (just a lightweight pointer: which character to offer, and
-- which model -- the actual items live in STORAGE, not here)
-- ============================================================
local function LoadData()
    if not file.Exists(LOADOUTPERSIST.SavePath, "DATA") then
        LOADOUTPERSIST.Data = {}
        return
    end
    local raw = file.Read(LOADOUTPERSIST.SavePath, "DATA")
    if not raw or raw == "" then
        LOADOUTPERSIST.Data = {}
        return
    end
    LOADOUTPERSIST.Data = util.JSONToTable(raw) or {}
end

local function SaveData()
    file.Write(LOADOUTPERSIST.SavePath, util.TableToJSON(LOADOUTPERSIST.Data, true))
    dataDirty = false
end

hook.Add("Initialize", "LoadoutPersist_Init", LoadData)

function LOADOUTPERSIST.HasSavedData(ply)
    if not IsValid(ply) then
        return false
    end
    return LOADOUTPERSIST.Data[ply:SteamID()] ~= nil
end

-- ============================================================
-- Collecting "extras" -- everything owned beyond the character's freebies
-- ============================================================
local function IsBaseWeapon(character, classname)
    if not character or not character.weapons then
        return false
    end
    for _, base in ipairs(character.weapons) do
        if base == classname then
            return true
        end
    end
    return false
end

local function GetItemImage(classname)
    local path = "materials/entities/" .. classname .. ".png"
    if file.Exists(path, "GAME") then
        return path
    end
    return "materials/entities/what.png"
end

-- Returns a list of storage-schema entries for everything ply owns beyond
-- charID's freebie loadout, or nil if there's nothing extra.
local function CollectExtras(ply, charID)
    local character = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID]
    local entries = {}

    for _, weapon in pairs(ply:GetWeapons()) do
        if IsValid(weapon) and not weapon.PersonaSkill and not IsBaseWeapon(character, weapon:GetClass()) then
            local wdata = weapons.Get(weapon:GetClass())
            table.insert(
                entries,
                {
                    classname = weapon:GetClass(),
                    slotType = weapon.SlotType or "Equipment",
                    slotsTaking = weapon.SlotsTaking or 1,
                    image = GetItemImage(weapon:GetClass()),
                    name = (wdata and wdata.PrintName) or weapon:GetClass(),
                    itemType = "swep",
                    clip1 = weapon:Clip1(),
                    clip2 = weapon:Clip2(),
                    ammo = ply:GetAmmoCount(weapon:GetPrimaryAmmoType())
                }
            )
        end
    end

    local charPermaBuffs = (character and character.permaBuffs) or {}
    for name, data in pairs(GetAllStats(ply, "permabuffs")) do
        if charPermaBuffs[name] == nil then
            local passive = Passives and Passives[name]
            table.insert(
                entries,
                {
                    classname = (passive and passive.classname) or name,
                    buffName = name,
                    buffType = "permabuffs",
                    buffData = data,
                    slotType = (type(data) == "table" and data.SlotType) or "Equipment",
                    slotsTaking = (type(data) == "table" and data.SlotsTaking) or 1,
                    image = (passive and passive.image) or GetItemImage(name),
                    name = (passive and passive.name) or name,
                    itemType = "passive"
                }
            )
        end
    end

    local permaPersonas = GetAllStats(ply, "permapersonas")
    for name, data in pairs(GetAllStats(ply, "personas")) do
        if permaPersonas[name] == nil then
            local pdata = Personas and Personas[name]
            table.insert(
                entries,
                {
                    classname = name,
                    buffName = name,
                    buffType = "personas",
                    buffData = data,
                    slotType = "Persona",
                    slotsTaking = 1,
                    image = (pdata and pdata.image) or GetItemImage(name),
                    name = (pdata and pdata.name) or name,
                    itemType = "passive"
                }
            )
        end
    end

    if #entries == 0 then
        return nil
    end
    return entries
end

-- Moves everything ply owns beyond their current character's freebies into
-- their personal storage. Does NOT strip it off the player itself -- callers
-- either wipe it a moment later (character switch) or the entity is about to
-- be destroyed anyway (disconnect/shutdown). Returns true if anything was
-- stashed, false if there was nothing extra (or storage isn't available).
function LOADOUTPERSIST.StashExtras(ply, tag)
    if not IsValid(ply) or not ply:IsPlayer() then
        return false
    end

    local charID = ply:GetNWString("AssignedCharacter", "")
    if charID == "" then
        return false
    end

    local extras = CollectExtras(ply, charID)
    if not extras then
        return false
    end

    if not (STORAGE and STORAGE.EnsurePlayerBucket and STORAGE.FindFreeSlot) then
        return false
    end

    local bucket = STORAGE.EnsurePlayerBucket(ply:SteamID())
    local stashedAny = false

    for _, entry in ipairs(extras) do
        local slot = STORAGE.FindFreeSlot(bucket)
        if not slot then
            break -- storage full; leave the rest where it is rather than deleting it
        end
        entry.loadoutStashTag = tag
        bucket.slots[tostring(slot)] = entry
        stashedAny = true
    end

    if stashedAny then
        STORAGE.Save()
    end

    return stashedAny
end

-- ============================================================
-- Disconnect / shutdown: stash extras (tagged) and remember which character
-- to offer restoring. Only saves a pointer if there was actually something
-- extra to restore -- a player with nothing beyond their base loadout gets
-- nothing saved, since the default character already reproduces that state.
-- ============================================================
local function SaveRestorePointer(ply)
    local steamID = ply:SteamID()
    local stashed = LOADOUTPERSIST.StashExtras(ply, PENDING_TAG)

    if not stashed then
        if LOADOUTPERSIST.Data[steamID] then
            LOADOUTPERSIST.Data[steamID] = nil
            dataDirty = true
        end
        return
    end

    local charID = ply:GetNWString("AssignedCharacter", "")
    LOADOUTPERSIST.Data[steamID] = {
        charID = charID,
        modelPath = ply:GetNWString("SelectedModel_" .. charID, "")
    }
    dataDirty = true
end

hook.Add(
    "PlayerDisconnected",
    "LoadoutPersist_SaveOnDisconnect",
    function(ply)
        SaveRestorePointer(ply)
        if dataDirty then
            SaveData()
        end
    end
)

hook.Add(
    "ShutDown",
    "LoadoutPersist_SaveOnShutDown",
    function()
        for _, ply in ipairs(player.GetAll()) do
            SaveRestorePointer(ply)
        end
        SaveData()
    end
)

-- ============================================================
-- Restore flow
-- ============================================================
local function AssignDefaultCharacter(ply)
    if not IsValid(ply) then
        return
    end
    local defaultChar = TBC_DEFAULT_CHARACTER or "citizen"
    if not (CHARACTERS and CHARACTERS.List and CHARACTERS.List[defaultChar]) then
        return
    end

    ApplyCharacterToPlayer(ply, defaultChar, nil)
    ply:Spawn()

    local character = CHARACTERS.List[defaultChar]
    ply:SetHealth(character.combatHP or 100)
    ply:SetMaxHealth(character.combatHP or 100)
    ply:SetArmor(0)
    ply:SetMaxArmor(0)

    ply:ChatPrint("You have been assigned as " .. character.name .. "!")
end

local function RestoreStorageEntry(ply, entry)
    if entry.itemType == "swep" then
        if not weapons.Get(entry.classname) then
            return false
        end
        local givenWeapon = ply:Give(entry.classname)
        if IsValid(givenWeapon) then
            if entry.clip1 then
                givenWeapon:SetClip1(entry.clip1)
            end
            if entry.clip2 then
                givenWeapon:SetClip2(entry.clip2)
            end
            if entry.ammo and entry.ammo > 0 then
                ply:GiveAmmo(entry.ammo, givenWeapon:GetPrimaryAmmoType())
            end
        end
        return true
    end

    local bName = entry.buffName
    local bType = entry.buffType or "permabuffs"

    if bType == "personas" then
        if not (Personas and Personas[bName]) then
            return false
        end
        AssignStat(ply, bName, entry.buffData, bType)
        ply:SetNW2String("selectedPersona", bName)
        for _, weaponClass in pairs(Personas[bName].skills or {}) do
            ply:Give(weaponClass)
        end
        return true
    end

    AssignStat(ply, bName, entry.buffData, bType)
    return true
end

-- Pulls every storage entry tagged as a pending restore for this player back
-- out and gives it to them. Leaves anything the player banked manually alone.
local function RestorePendingStorage(ply)
    local skipped = {}
    if not (STORAGE and STORAGE.EnsurePlayerBucket) then
        return skipped
    end

    local bucket = STORAGE.EnsurePlayerBucket(ply:SteamID())
    for key, entry in pairs(bucket.slots) do
        if entry.loadoutStashTag == PENDING_TAG then
            if RestoreStorageEntry(ply, entry) then
                bucket.slots[key] = nil
            else
                table.insert(skipped, entry.name or entry.classname or entry.buffName)
                entry.loadoutStashTag = nil -- give up trying to auto-restore it, but keep it banked
            end
        end
    end
    STORAGE.Save()

    return skipped
end

-- Clears the pending-restore tag from this player's storage without taking
-- anything -- used when they decline. The items stay in storage as normal,
-- permanently banked items, retrievable any time via the storage NPC.
local function ClearPendingTag(ply)
    if not (STORAGE and STORAGE.EnsurePlayerBucket) then
        return
    end
    local bucket = STORAGE.EnsurePlayerBucket(ply:SteamID())
    local changed = false
    for _, entry in pairs(bucket.slots) do
        if entry.loadoutStashTag == PENDING_TAG then
            entry.loadoutStashTag = nil
            changed = true
        end
    end
    if changed then
        STORAGE.Save()
    end
end

net.Receive(
    "LoadoutPersist_Confirm",
    function(len, ply)
        if not IsValid(ply) then
            return
        end

        local accepted = net.ReadBool()
        local steamID = ply:SteamID()
        local saved = LOADOUTPERSIST.Data[steamID]

        LOADOUTPERSIST.Data[steamID] = nil
        dataDirty = true
        SaveData()

        if not accepted or not saved then
            ClearPendingTag(ply)
            AssignDefaultCharacter(ply)
            return
        end

        local ok = ApplyCharacterToPlayer(ply, saved.charID, saved.modelPath)
        if not ok then
            ClearPendingTag(ply)
            AssignDefaultCharacter(ply)
            ply:ChatPrint(
                "Your previous character is no longer available. Your items are safely stored -- " ..
                    "you can retrieve them from storage, or an admin may be able to help."
            )
            return
        end

        ply:Spawn()
        local character = CHARACTERS.List[saved.charID]
        ply:SetHealth(character.combatHP or 100)
        ply:SetMaxHealth(character.combatHP or 100)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local skipped = RestorePendingStorage(ply)

        ply:ChatPrint("Your loadout has been restored!")
        if #skipped > 0 then
            ply:ChatPrint("Some items no longer exist and could not be restored: " .. table.concat(skipped, ", "))
        end
    end
)

hook.Add(
    "PlayerInitialSpawn",
    "LoadoutPersist_Offer",
    function(ply)
        timer.Simple(
            0.6,
            function()
                if not IsValid(ply) then
                    return
                end

                if ply:GetNWString("AssignedCharacter", "") ~= "" then
                    return -- something else already assigned a character
                end

                local saved = LOADOUTPERSIST.Data[ply:SteamID()]
                if not saved then
                    return
                end

                local character = CHARACTERS and CHARACTERS.List and CHARACTERS.List[saved.charID]
                if not character then
                    LOADOUTPERSIST.Data[ply:SteamID()] = nil
                    dataDirty = true
                    SaveData()
                    AssignDefaultCharacter(ply)
                    ply:ChatPrint(
                        "Your previous character is no longer available. Your items are safely stored -- " ..
                            "you can retrieve them from storage, or an admin may be able to help."
                    )
                    return
                end

                net.Start("LoadoutPersist_Offer")
                net.WriteString(character.name or saved.charID)
                net.Send(ply)
            end
        )
    end
)
