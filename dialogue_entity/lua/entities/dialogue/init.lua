AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_dialogue_ui.lua")
AddCSLuaFile("cl_storage_ui.lua")
AddCSLuaFile("cl_adminstorage.lua")
AddCSLuaFile("cl_shop_ui.lua")
include("shared.lua")

util.AddNetworkString("DialogueOpen")
util.AddNetworkString("DialogueEdit")
util.AddNetworkString("DialogueSaveToMap")
util.AddNetworkString("DialogueClose")
util.AddNetworkString("DialogueNextNode")
util.AddNetworkString("DialogueRecordChoice")
util.AddNetworkString("DialogueAdminGetChoices")
util.AddNetworkString("DialogueAdminChoicesData")
util.AddNetworkString("DialogueAdminDeleteChoice")
util.AddNetworkString("StorageOpen")
util.AddNetworkString("StorageOpenUI")
util.AddNetworkString("StorageClose")
util.AddNetworkString("StorageData")
util.AddNetworkString("StorageStoreItem")
util.AddNetworkString("StorageTakeItem")
util.AddNetworkString("StorageCurrency")
util.AddNetworkString("StorageSetScope")
util.AddNetworkString("StorageAdminLoad")
util.AddNetworkString("DialogueOpenStorage")
util.AddNetworkString("StorageMoveSlot")
util.AddNetworkString("AdminStorageLoad")
util.AddNetworkString("AdminStorageOpen")
util.AddNetworkString("AdminStorageData")
util.AddNetworkString("AdminStorageAction")
util.AddNetworkString("AdminStorageDeposit")
util.AddNetworkString("AdminStorageCurrency")
util.AddNetworkString("ShopOpen")
util.AddNetworkString("ShopBuy")
util.AddNetworkString("ShopSave")
util.AddNetworkString("ShopSaved")
util.AddNetworkString("DialogueOpenShop")

local DATA_DIR             = "dialogue_entities"
local NPCS_FILE            = DATA_DIR .. "/npcs.json"
local CHOICES_FILE         = DATA_DIR .. "/player_choices.json"
local STORAGE_PLAYER_FILE  = DATA_DIR .. "/storage_player.json"
local STORAGE_GLOBAL_FILE  = DATA_DIR .. "/storage_global.json"
local TOTAL_SLOTS          = 300

local function EnsureDir()
    if not file.IsDir(DATA_DIR, "DATA") then file.CreateDir(DATA_DIR) end
end

local function MapSavePath()
    return DATA_DIR .. "/" .. game.GetMap() .. "_placements.json"
end

local AllNPCs = nil

local function LoadAllNPCs()
    EnsureDir()
    if file.Exists(NPCS_FILE, "DATA") then
        local raw = file.Read(NPCS_FILE, "DATA")
        if raw then
            local t = util.JSONToTable(raw)
            if t then AllNPCs = t return end
        end
    end
    AllNPCs = {}
end

local function SaveAllNPCs()
    EnsureDir()
    if AllNPCs then
        file.Write(NPCS_FILE, util.TableToJSON(AllNPCs, true))
    end
end

local function GetNPCData(uid)
    if not AllNPCs then LoadAllNPCs() end
    return AllNPCs[uid]
end

local function SetNPCData(uid, data)
    if not AllNPCs then LoadAllNPCs() end
    AllNPCs[uid] = data
    SaveAllNPCs()
end

local AllChoices = nil

local function SteamKey(ply)
    return "s_" .. ply:SteamID64()
end

local function LoadAllChoices()
    EnsureDir()
    if file.Exists(CHOICES_FILE, "DATA") then
        local raw = file.Read(CHOICES_FILE, "DATA")
        if raw then
            local t = util.JSONToTable(raw)
            if t then
                local migrated = false
                for k, v in pairs(t) do
                    if type(k) == "number" or (type(k) == "string" and not k:find("^s_")) then
                        local newKey = "s_" .. tostring(k):gsub("%.%d+e%+%d+", function(e)
                            return string.format("%.0f", tonumber(tostring(k)) or 0)
                        end)
                        local numStr = tostring(k):gsub("[^%d]", "")
                        if #numStr >= 15 then
                            local cleanKey = "s_" .. numStr
                            if not t[cleanKey] then
                                t[cleanKey] = v
                            else
                                for choiceID, val in pairs(v) do
                                    t[cleanKey][choiceID] = val
                                end
                            end
                            t[k] = nil
                            migrated = true
                        end
                    end
                end
                AllChoices = t
                if migrated then SaveAllChoices() end
                return
            end
        end
    end
    AllChoices = {}
end

local function SaveAllChoices()
    EnsureDir()
    if AllChoices then
        file.Write(CHOICES_FILE, util.TableToJSON(AllChoices, true))
    end
end

local function GetPlayerChoices(ply)
    if not AllChoices then LoadAllChoices() end
    local key = SteamKey(ply)
    if not AllChoices[key] then AllChoices[key] = {} end
    return AllChoices[key]
end

local function PlayerHasChoice(ply, choiceID)
    return GetPlayerChoices(ply)[choiceID] == true
end

local function RecordChoice(ply, choiceID)
    if not choiceID or choiceID == "" then return end
    GetPlayerChoices(ply)[choiceID] = true
    if ply.DialogueChoices then ply.DialogueChoices[choiceID] = true end
    SaveAllChoices()
end

hook.Add("PlayerAuthed", "DialogueLoadChoices", function(ply, steamID, uniqueID)
    if not AllChoices then LoadAllChoices() end
    ply.DialogueChoices = GetPlayerChoices(ply)
end)

-- ---------------------------------------------------------------
--  Storage persistence
-- ---------------------------------------------------------------
local StoragePlayerData = nil
local StorageGlobalData = nil

local function NormalizeSlotKeys(bucket)
    if not bucket or not bucket.slots then return end
    local old = bucket.slots
    local new = {}
    for k, v in pairs(old) do new[tostring(k)] = v end
    bucket.slots = new
end

local function LoadStorageData()
    EnsureDir()
    if file.Exists(STORAGE_PLAYER_FILE, "DATA") then
        local raw = file.Read(STORAGE_PLAYER_FILE, "DATA")
        if raw then StoragePlayerData = util.JSONToTable(raw) end
    end
    StoragePlayerData = StoragePlayerData or {}

    if file.Exists(STORAGE_GLOBAL_FILE, "DATA") then
        local raw = file.Read(STORAGE_GLOBAL_FILE, "DATA")
        if raw then StorageGlobalData = util.JSONToTable(raw) end
    end
    StorageGlobalData = StorageGlobalData or {}

    for _, entry in pairs(StoragePlayerData) do
        if type(entry) == "table" then
            if entry.player then NormalizeSlotKeys(entry.player) end
            if entry.chars then
                for _, cb in pairs(entry.chars) do NormalizeSlotKeys(cb) end
            end
        end
    end
    for _, bucket in pairs(StorageGlobalData) do
        NormalizeSlotKeys(bucket)
    end
end

local function SaveStorageData()
    EnsureDir()
    file.Write(STORAGE_PLAYER_FILE, util.TableToJSON(StoragePlayerData, true))
    file.Write(STORAGE_GLOBAL_FILE,  util.TableToJSON(StorageGlobalData,  true))
end

local function EnsurePlayerStorage(steamID)
    if not StoragePlayerData then LoadStorageData() end
    if not StoragePlayerData[steamID] then
        StoragePlayerData[steamID] = { player = {slots={}, currency=0}, chars = {} }
    end
    local e = StoragePlayerData[steamID]
    if not e.player then e.player = {slots={}, currency=0} end
    if not e.chars  then e.chars  = {} end
end

local function EnsureCharStorage(steamID, charID)
    EnsurePlayerStorage(steamID)
    local e = StoragePlayerData[steamID]
    if not e.chars[charID] then e.chars[charID] = {slots={}, currency=0} end
end

local function EnsureGlobalStorage(npcUID)
    if not StorageGlobalData then LoadStorageData() end
    if not StorageGlobalData[npcUID] then
        StorageGlobalData[npcUID] = {slots={}, currency=0}
    end
end

local function GetStorageBucket(ply, isGlobal, npcUID, charScope)
    local sid = ply:SteamID()
    if isGlobal then
        EnsureGlobalStorage(npcUID)
        return StorageGlobalData[npcUID]
    end
    EnsurePlayerStorage(sid)
    if charScope then
        local charID = ply:GetNWString("AssignedCharacter", "")
        if charID == "" then return StoragePlayerData[sid].player end
        EnsureCharStorage(sid, charID)
        return StoragePlayerData[sid].chars[charID]
    end
    return StoragePlayerData[sid].player
end

local function GetStorageBucketBySteam(steamID, isGlobal, npcUID, charScope, charID)
    if isGlobal then
        EnsureGlobalStorage(npcUID)
        return StorageGlobalData[npcUID]
    end
    EnsurePlayerStorage(steamID)
    if charScope and charID and charID ~= "" then
        EnsureCharStorage(steamID, charID)
        return StoragePlayerData[steamID].chars[charID]
    end
    return StoragePlayerData[steamID].player
end

local function FindFreeSlot(bucket)
    for i = 1, 300 do
        if not bucket.slots[tostring(i)] then return i end
    end
    return nil
end

-- ---------------------------------------------------------------
--  Minimal public API so other addons (e.g. Loadout Persistence) can
--  place/remove items in a player's personal storage bucket without
--  duplicating this file's save format or save file.
-- ---------------------------------------------------------------
STORAGE = STORAGE or {}

function STORAGE.EnsurePlayerBucket(steamID)
    EnsurePlayerStorage(steamID)
    return StoragePlayerData[steamID].player
end

function STORAGE.FindFreeSlot(bucket)
    return FindFreeSlot(bucket)
end

function STORAGE.Save()
    SaveStorageData()
end

local function CanStoreWeapon(ply, weapon)
    if not IsValid(weapon) then return false end
    if weapon.PersonaSkill then return false end
    local charID = ply:GetNWString("AssignedCharacter", "")
    if charID ~= "" and CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID] then
        local charData = CHARACTERS.List[charID]
        if charData.weapons then
            for _, bw in ipairs(charData.weapons) do
                if bw == weapon:GetClass() then return false end
            end
        end
    end
    local canDrop = hook.Run("TBC_CanDropWeapon", ply, weapon)
    if canDrop == false then return false end
    return true
end

local function CountUsedSlots(ply)
    local eq, it = 0, 0
    for _, w in pairs(ply:GetWeapons()) do
        if w.SlotType and w.SlotsTaking then
            if w.SlotType == "Equipment" then eq = eq + w.SlotsTaking
            elseif w.SlotType == "Item"  then it = it + w.SlotsTaking end
        end
    end
    local buffs = GetAllStats and GetAllStats(ply, "permabuffs")
    if buffs then
        for _, info in pairs(buffs) do
            if info.SlotType and info.SlotsTaking then
                if info.SlotType == "Equipment" then eq = eq + info.SlotsTaking
                elseif info.SlotType == "Item"  then it = it + info.SlotsTaking end
            end
        end
    end
    return eq, it
end

local function HasInventoryRoom(ply, slotType, slotsTaking)
    local maxEq = ply:GetNWInt("TBCEquipmentSlots", 15)
    local maxIt = ply:GetNWInt("TBCItemSlots", 10)
    local eq, it = CountUsedSlots(ply)
    if slotType == "Equipment" then return (eq + slotsTaking) <= maxEq end
    if slotType == "Item"      then return (it + slotsTaking) <= maxIt end
    return true
end

local function GetItemImage(classname)
    local path = "materials/entities/" .. classname .. ".png"
    if file.Exists(path, "GAME") then return path end
    return "materials/entities/what.png"
end

local function SendStorageData(ply, bucket, viewSteam)
    net.Start("StorageData")
    net.WriteString(util.TableToJSON(bucket))
    net.WriteString(viewSteam or "")
    net.Send(ply)
end

local PlayerStorageScope = {}

net.Receive("StorageOpen", function(len, ply)
    if not IsValid(ply) then return end
    local storageKey = net.ReadString()
    local isGlobal   = net.ReadBool()
    local npcUID     = net.ReadString()
    local charScope  = PlayerStorageScope[ply:SteamID()] or false
    local bucket     = GetStorageBucket(ply, isGlobal, npcUID, charScope)
    net.Start("StorageOpenUI")
    net.WriteString(util.TableToJSON(bucket))
    net.WriteString(storageKey)
    net.WriteBool(isGlobal)
    net.WriteString(npcUID)
    net.Send(ply)
end)

net.Receive("StorageClose", function(len, ply)
    SaveStorageData()
end)

net.Receive("StorageSetScope", function(len, ply)
    if not IsValid(ply) then return end
    local charScope = net.ReadBool()
    PlayerStorageScope[ply:SteamID()] = charScope
end)

net.Receive("StorageStoreItem", function(len, ply)
    if not IsValid(ply) then return end
    local storageKey  = net.ReadString()
    local isGlobal    = net.ReadBool()
    local npcUID      = net.ReadString()
    local charScope   = net.ReadBool()
    local classname   = net.ReadString()
    local slotType    = net.ReadString()
    local slotsTaking = net.ReadInt(32)
    local targetSlot  = net.ReadInt(32)
    local itemType    = net.ReadString()
    local buffName    = net.ReadString()
    local buffType    = net.ReadString()
    local buffDataRaw = net.ReadString()

    local bucket = GetStorageBucket(ply, isGlobal, npcUID, charScope)
    local slot
    if targetSlot and targetSlot > 0 and targetSlot <= 300 then
        slot = not bucket.slots[tostring(targetSlot)] and targetSlot or FindFreeSlot(bucket)
    else
        slot = FindFreeSlot(bucket)
    end
    if not slot then ply:ChatPrint("[Storage] Storage is full!") return end

    if itemType == "passive" then
        local bType = buffType ~= "" and buffType or "permabuffs"
        local stats = GetAllStats and GetAllStats(ply, bType)
        if not stats or not stats[buffName] then
            ply:ChatPrint("[Storage] Item not found.")
            return
        end
        -- Store the live stat data (more reliable than the client-sent copy)
        local liveData = stats[buffName]
        local passive  = Passives and Passives[buffName]
        local pdata    = Personas and Personas[buffName]
        bucket.slots[tostring(slot)] = {
            classname   = classname,
            buffName    = buffName,
            buffType    = bType,
            buffData    = liveData,   -- full table (or string for personas)
            slotType    = slotType,
            slotsTaking = slotsTaking,
            image       = GetItemImage(classname),
            name        = (passive and passive.name) or (pdata and pdata.name) or classname,
            itemType    = "passive",
        }
        RemoveStat(ply, buffName, bType)
        -- If this was an equipped persona, unequip it and strip its skills.
        if bType == "personas" and pdata then
            if ply:GetNW2String("selectedPersona", "") == buffName then
                ply:SetNW2String("selectedPersona", "")
            end
            for _, skillClass in pairs(pdata.skills or {}) do
                local wep = ply:GetWeapon(skillClass)
                if IsValid(wep) then wep:Remove() end
            end
        end
    else
        local weapon = ply:GetWeapon(classname)
        if not IsValid(weapon) then ply:ChatPrint("[Storage] Item not found in inventory.") return end
        if not CanStoreWeapon(ply, weapon) then ply:ChatPrint("[Storage] You cannot store this item.") return end
        local wdata = weapons.GetStored(classname)
        bucket.slots[tostring(slot)] = {
            classname   = classname,
            slotType    = slotType,
            slotsTaking = slotsTaking,
            image       = GetItemImage(classname),
            name        = (wdata and wdata.PrintName) or classname,
            itemType    = "swep",
        }
        weapon:Remove()
    end

    SaveStorageData()
    SendStorageData(ply, bucket, nil)
end)

net.Receive("StorageMoveSlot", function(len, ply)
    if not IsValid(ply) then return end
    local storageKey = net.ReadString()
    local isGlobal   = net.ReadBool()
    local npcUID     = net.ReadString()
    local charScope  = net.ReadBool()
    local fromSlot   = net.ReadInt(32)
    local toSlot     = net.ReadInt(32)

    if fromSlot == toSlot then return end
    if fromSlot < 1 or fromSlot > 300 or toSlot < 1 or toSlot > 300 then return end

    local bucket   = GetStorageBucket(ply, isGlobal, npcUID, charScope)
    local fromKey  = tostring(fromSlot)
    local toKey    = tostring(toSlot)
    local fromItem = bucket.slots[fromKey]
    if not fromItem then return end

    local toItem = bucket.slots[toKey]
    bucket.slots[fromKey] = toItem
    bucket.slots[toKey]   = fromItem
    SaveStorageData()
    SendStorageData(ply, bucket, nil)
end)

net.Receive("StorageTakeItem", function(len, ply)
    if not IsValid(ply) then return end
    local storageKey  = net.ReadString()
    local isGlobal    = net.ReadBool()
    local npcUID      = net.ReadString()
    local charScope   = net.ReadBool()
    local slotIdx     = net.ReadInt(32)
    local viewSteam   = net.ReadString()

    local isAdminView = (viewSteam ~= "" and viewSteam ~= ply:SteamID())
    if isAdminView and not ply:IsAdmin() then ply:ChatPrint("[Storage] Admin access required.") return end

    local bucket
    if isAdminView then
        local charID = ""
        if charScope then
            for _, p in ipairs(player.GetAll()) do
                if IsValid(p) and p:SteamID() == viewSteam then charID = p:GetNWString("AssignedCharacter", "") break end
            end
        end
        bucket = GetStorageBucketBySteam(viewSteam, isGlobal, npcUID, charScope, charID)
    else
        bucket = GetStorageBucket(ply, isGlobal, npcUID, charScope)
    end

    local key   = tostring(slotIdx)
    local entry = bucket.slots[key]
    if not entry then ply:ChatPrint("[Storage] Slot is empty.") return end
    if not HasInventoryRoom(ply, entry.slotType, entry.slotsTaking) then ply:ChatPrint("[Storage] Not enough inventory space!") return end

    if entry.itemType == "passive" then
        local bName = entry.buffName or entry.classname
        local bType = entry.buffType or "permabuffs"
        -- Check player doesn't already have it
        local existing = GetAllStats and GetAllStats(ply, bType)
        if existing and existing[bName] then
            ply:ChatPrint("[Storage] You already have this item!")
            return
        end
        -- Restore with the original data table (or name string for personas)
        local restoreVal = entry.buffData or bName
        AssignStat(ply, bName, restoreVal, bType)
    else
        if ply:HasWeapon(entry.classname) then ply:ChatPrint("[Storage] You already have this item!") return end
        ply:Give(entry.classname)
    end

    bucket.slots[key] = nil
    SaveStorageData()
    SendStorageData(ply, bucket, isAdminView and viewSteam or nil)
end)

net.Receive("StorageCurrency", function(len, ply)
    if not IsValid(ply) then return end
    local storageKey = net.ReadString()
    local isGlobal   = net.ReadBool()
    local npcUID     = net.ReadString()
    local charScope  = net.ReadBool()
    local isDeposit  = net.ReadBool()
    local amount     = net.ReadInt(32)
    local viewSteam  = net.ReadString()

    if amount <= 0 then return end

    local isAdminView = (viewSteam ~= "" and viewSteam ~= ply:SteamID())
    if isAdminView and not ply:IsAdmin() then ply:ChatPrint("[Storage] Admin access required.") return end

    local bucket
    if isAdminView then
        local charID = ""
        if charScope then
            for _, p in ipairs(player.GetAll()) do
                if IsValid(p) and p:SteamID() == viewSteam then charID = p:GetNWString("AssignedCharacter", "") break end
            end
        end
        bucket = GetStorageBucketBySteam(viewSteam, isGlobal, npcUID, charScope, charID)
    else
        bucket = GetStorageBucket(ply, isGlobal, npcUID, charScope)
    end

    if not TBC_CURRENCY then ply:ChatPrint("[Storage] Currency system unavailable.") return end
    local sym = TBC_CURRENCY.Config.Symbol or "ћ"

    if isDeposit then
        if not TBC_CURRENCY.HasMoney(ply, amount) then ply:ChatPrint("[Storage] Not enough currency.") return end
        TBC_CURRENCY.TakeMoney(ply, amount)
        bucket.currency = (bucket.currency or 0) + amount
        ply:ChatPrint(string.format("[Storage] Deposited %s%d.", sym, amount))
    else
        local stored = bucket.currency or 0
        if amount > stored then ply:ChatPrint("[Storage] Not enough stored currency.") return end
        bucket.currency = stored - amount
        TBC_CURRENCY.GiveMoney(ply, amount)
        ply:ChatPrint(string.format("[Storage] Withdrew %s%d.", sym, amount))
    end

    SaveStorageData()
    SendStorageData(ply, bucket, isAdminView and viewSteam or nil)
end)

net.Receive("StorageAdminLoad", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then ply:ChatPrint("[Storage] Admin access required.") return end

    local targetSteam = net.ReadString()
    local storageKey  = net.ReadString()
    local isGlobal    = net.ReadBool()
    local npcUID      = net.ReadString()
    local charScope   = net.ReadBool()

    local charID = ""
    if charScope then
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) and p:SteamID() == targetSteam then charID = p:GetNWString("AssignedCharacter", "") break end
        end
    end

    local bucket = GetStorageBucketBySteam(targetSteam, isGlobal, npcUID, charScope, charID)
    SendStorageData(ply, bucket, targetSteam)
end)

-- ---------------------------------------------------------------
--  Collision / NPC entity setup
-- ---------------------------------------------------------------
local BBOX_MINS = Vector(-16, -16,  0)
local BBOX_MAXS = Vector( 16,  16, 72)

local function SetupCollision(ent)
    ent:SetMoveType(MOVETYPE_NONE)
    ent:SetSolid(SOLID_BBOX)
    ent:SetCollisionBounds(BBOX_MINS, BBOX_MAXS)
    ent:SetUnFreezable(true)
end

local function ApplyDialogueData(ent, decoded)
    ent.DialogueData = decoded
    ent:SetNWString("DialogueName",  decoded.name        or "???")
    ent:SetNWString("DialogueDesc",  decoded.description or "")
    ent:SetNWString("DialogueModel", decoded.model       or "")
    ent:SetNWString("DialogueIdle",  decoded.idleAnim    or "")
    ent:SetNWString("DialogueTalk",  decoded.talkAnim    or "")

    if decoded.model and decoded.model ~= "" then
        ent:SetModel(decoded.model)
    end

    timer.Simple(0.05, function()
        if not IsValid(ent) then return end
        local idle = decoded.idleAnim or ""
        if idle ~= "" then ent:ResetSequence(idle) end
    end)
end

local function LoadDialogueData(ent)
    if not AllNPCs then LoadAllNPCs() end
    local uid  = ent:GetNWString("DialogueUID", "")
    local data = uid ~= "" and AllNPCs[uid] or nil

    if data then
        ApplyDialogueData(ent, data)
    else
        local defaults = {
            name        = "Unnamed NPC",
            description = "A mysterious figure.",
            model       = ent:GetModel(),
            idleAnim    = "",
            talkAnim    = "",
            dialogue    = {
                { id = "start", text = "...",
                  options = { { label = "Stop chatting", action = "end" } } }
            }
        }
        ApplyDialogueData(ent, defaults)
        if uid ~= "" then
            AllNPCs[uid] = defaults
            SaveAllNPCs()
        end
    end
end

local function SaveDialogueData(ent)
    if not ent.DialogueData then return end
    local uid = ent:GetNWString("DialogueUID", "")
    if uid == "" then return end
    SetNPCData(uid, ent.DialogueData)
end

local function EvalConditions(conds, ply)
    if not conds or #conds == 0 then return true end
    for _, row in ipairs(conds) do
        local ids    = row.ids    or {}
        local mode   = row.mode   or "any"
        local negate = row.negate or false
        if #ids == 0 then continue end

        local passes
        if mode == "all" then
            passes = true
            for _, id in ipairs(ids) do
                if not PlayerHasChoice(ply, id) then passes = false break end
            end
        else
            passes = false
            for _, id in ipairs(ids) do
                if PlayerHasChoice(ply, id) then passes = true break end
            end
        end

        if negate then passes = not passes end
        if not passes then return false end
    end
    return true
end

local function PickStartNode(data, ply)
    local candidates = {}
    for _, node in ipairs(data.dialogue or {}) do
        if node.isStart then
            if node.singleUse and node.choiceID and node.choiceID ~= ""
               and PlayerHasChoice(ply, node.choiceID) then
            elseif not EvalConditions(node.requiredConditions, ply) then
            else
                table.insert(candidates, node)
            end
        end
    end
    if #candidates > 0 then return candidates[math.random(1, #candidates)] end
    for _, node in ipairs(data.dialogue or {}) do
        if node.id == "start" then return node end
    end
    return data.dialogue and data.dialogue[1] or nil
end

local function SaveMapPlacements()
    EnsureDir()
    local placements = {}
    for _, ent in ipairs(ents.FindByClass("dialogue")) do
        if IsValid(ent) then
            local uid = ent:GetNWString("DialogueUID", "")
            if uid ~= "" then
                local p, a = ent:GetPos(), ent:GetAngles()
                table.insert(placements, {
                    uid   = uid,
                    pos   = { x = p.x, y = p.y, z = p.z },
                    ang   = { p = a.p, y = a.y, r = a.r },
                    model = ent:GetModel(),
                })
            end
        end
    end
    file.Write(MapSavePath(), util.TableToJSON(placements, true))
end

local function LoadMapPlacements()
    EnsureDir()
    local path = MapSavePath()
    if not file.Exists(path, "DATA") then return end
    local raw = file.Read(path, "DATA")
    if not raw then return end
    local placements = util.JSONToTable(raw)
    if not placements then return end

    for _, entry in ipairs(placements) do
        if entry.uid and entry.pos and entry.ang then
            local pos = Vector(entry.pos.x, entry.pos.y, entry.pos.z)
            local ang = Angle(entry.ang.p,  entry.ang.y,  entry.ang.r)
            local uid = entry.uid

            local ent = ents.Create("dialogue")
            if IsValid(ent) then
                ent:SetNWString("DialogueUID", uid)
                ent:SetPos(pos)
                ent:SetAngles(ang)
                if entry.model and entry.model ~= "" then ent:SetModel(entry.model) end
                ent:Spawn()
                ent:Activate()
                ent:SetNWString("DialogueUID", uid)
                timer.Simple(0.2, function()
                    if IsValid(ent) then
                        ent:SetNWString("DialogueUID", uid)
                        LoadDialogueData(ent)
                    end
                end)
            end
        end
    end
end

function ENT:Initialize()
    self:SetModel(self.Model)
    SetupCollision(self)

    if self:GetNWString("DialogueUID", "") == "" then
        local uid = "dlg_" .. tostring(math.random(100000, 999999))
                    .. "_" .. tostring(math.floor(CurTime() * 1000))
        self:SetNWString("DialogueUID", uid)
    end

    self.ActiveTalkers = 0

    timer.Simple(0.1, function()
        if IsValid(self) then LoadDialogueData(self) end
    end)
end

function ENT:Think()
    if not self.DialogueData then self:NextThink(CurTime()) return true end

    local idle    = self:GetNWString("DialogueIdle", "")
    local talk    = self:GetNWString("DialogueTalk",  "")
    local talking = (self.ActiveTalkers or 0) > 0
    local wantSeq = (talking and talk ~= "") and talk or idle

    if wantSeq ~= "" then
        if talking and talk ~= "" then
            if self._restartTalk then
                self._restartTalk = false
                self._lastSeq = wantSeq
                self:ResetSequence(wantSeq)
            elseif wantSeq ~= (self._lastSeq or "") then
                self._lastSeq = wantSeq
                self:ResetSequence(wantSeq)
            end
        elseif wantSeq ~= (self._lastSeq or "") then
            self._lastSeq = wantSeq
            self:ResetSequence(wantSeq)
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local key = "dlg_cooldown_" .. activator:SteamID()
    if self[key] and CurTime() - self[key] < 1 then return end
    self[key] = CurTime()

    if not self.DialogueData then LoadDialogueData(self) end
    activator.DialogueChoices = GetPlayerChoices(activator)

    local startNode = PickStartNode(self.DialogueData, activator)
    if not startNode then
        activator:ChatPrint("[Dialogue] Nothing to say.")
        return
    end

    if startNode.nodeType == "storage" then
        local npcUID   = self:GetNWString("DialogueUID", "")
        local isGlobal = startNode.storageGlobal == true
        net.Start("StorageOpen")
        net.WriteString("local")
        net.WriteBool(isGlobal)
        net.WriteString(npcUID)
        net.Send(activator)
        return
    end

    if startNode.nodeType == "shop" then
        local npcUID = self:GetNWString("DialogueUID", "")
        local data   = GetNPCData(npcUID)
        local shop   = (data and data.shop) or {}
        net.Start("ShopOpen")
        net.WriteString(npcUID)
        net.WriteString(util.TableToJSON(shop))
        net.WriteString(util.TableToJSON(activator.DialogueChoices or {}))
        net.WriteBool(activator:IsAdmin())
        net.Send(activator)
        return
    end

    self.ActiveTalkers = (self.ActiveTalkers or 0) + 1

    net.Start("DialogueOpen")
    net.WriteString(util.TableToJSON(self.DialogueData))
    net.WriteEntity(self)
    net.WriteString(util.TableToJSON(activator.DialogueChoices or {}))
    net.WriteString(startNode.id)
    net.Send(activator)
end

net.Receive("DialogueRecordChoice", function(len, ply)
    if not IsValid(ply) then return end
    local choiceID = net.ReadString()
    if choiceID == "" then return end
    RecordChoice(ply, choiceID)
end)

local function PlayerClosedDialogue(ply, ent)
    if not IsValid(ent) or ent:GetClass() ~= "dialogue" then return end
    ent.ActiveTalkers = math.max(0, (ent.ActiveTalkers or 0) - 1)
    if ent.ActiveTalkers == 0 then
        local idle = ent:GetNWString("DialogueIdle", "")
        if idle ~= "" then
            ent._lastSeq = idle
            ent:ResetSequence(idle)
        end
    end
end

net.Receive("DialogueClose", function(len, ply)
    local ent = net.ReadEntity()
    PlayerClosedDialogue(ply, ent)
end)

net.Receive("DialogueNextNode", function(len, ply)
    local ent = net.ReadEntity()
    if not IsValid(ent) or ent:GetClass() ~= "dialogue" then return end
    ent._restartTalk = true
end)

net.Receive("DialogueOpenStorage", function(len, ply)
    if not IsValid(ply) then return end
    local npcUID    = net.ReadString()
    local isGlobal  = net.ReadBool()
    local charScope = PlayerStorageScope[ply:SteamID()] or false
    local bucket    = GetStorageBucket(ply, isGlobal, npcUID, charScope)
    net.Start("StorageOpenUI")
    net.WriteString(util.TableToJSON(bucket))
    net.WriteString("local")
    net.WriteBool(isGlobal)
    net.WriteString(npcUID)
    net.Send(ply)
end)

net.Receive("DialogueOpenShop", function(len, ply)
    if not IsValid(ply) then return end
    local npcUID = net.ReadString()
    local data   = GetNPCData(npcUID)
    local shop   = (data and data.shop) or {}
    net.Start("ShopOpen")
    net.WriteString(npcUID)
    net.WriteString(util.TableToJSON(shop))
    net.WriteString(util.TableToJSON(ply.DialogueChoices or {}))
    net.WriteBool(ply:IsAdmin())
    net.Send(ply)
end)

net.Receive("DialogueEdit", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then ply:ChatPrint("[Dialogue] Admin access required.") return end

    local ent     = net.ReadEntity()
    local jsonStr = net.ReadString()
    if not IsValid(ent) or ent:GetClass() ~= "dialogue" then return end

    local decoded = util.JSONToTable(jsonStr)
    if not decoded then ply:ChatPrint("[Dialogue] Invalid data.") return end

    local newUID = decoded.customUID
    if newUID and newUID ~= "" then
        local oldUID = ent:GetNWString("DialogueUID", "")
        if newUID ~= oldUID then
            if AllNPCs and oldUID ~= "" then AllNPCs[oldUID] = nil end
            ent:SetNWString("DialogueUID", newUID)
        end
    end
    decoded.customUID = nil

    ApplyDialogueData(ent, decoded)
    SaveDialogueData(ent)
    ply:ChatPrint("[Dialogue] Saved!")
end)

net.Receive("DialogueSaveToMap", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then ply:ChatPrint("[Dialogue] Admin access required.") return end
    SaveMapPlacements()
    ply:ChatPrint("[Dialogue] Map placements saved for " .. game.GetMap() .. "!")
end)

local function BuildChoiceIndex()
    if not AllNPCs then LoadAllNPCs() end
    local conversationIDs = {}
    local choiceIDs       = {}

    for uid, npcData in pairs(AllNPCs) do
        local npcName = npcData.name or uid
        for _, node in ipairs(npcData.dialogue or {}) do
            if node.choiceID and node.choiceID ~= "" then
                conversationIDs[node.choiceID] = npcName
            end
            for _, opt in ipairs(node.options or {}) do
                if opt.choiceID and opt.choiceID ~= "" then
                    choiceIDs[opt.choiceID] = npcName .. " → " .. (opt.label or "?")
                end
            end
        end
    end
    return conversationIDs, choiceIDs
end

net.Receive("DialogueAdminGetChoices", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then return end

    local targetSteam = net.ReadString()
    if not AllChoices then LoadAllChoices() end

    local key     = "s_" .. targetSteam
    local choices = AllChoices[key] or {}
    local convIDs, choiceIDMap = BuildChoiceIndex()

    local entries = {}
    for id, val in pairs(choices) do
        if val == true then
            local entryType, source
            if convIDs[id] then
                entryType = "conversation"; source = convIDs[id]
            elseif choiceIDMap[id] then
                entryType = "choice"; source = choiceIDMap[id]
            else
                entryType = "unknown"; source = ""
            end
            table.insert(entries, { id = id, type = entryType, source = source })
        end
    end

    local order = { conversation = 1, choice = 2, unknown = 3 }
    table.sort(entries, function(a, b)
        local oa, ob = order[a.type] or 9, order[b.type] or 9
        if oa ~= ob then return oa < ob end
        return a.id < b.id
    end)

    net.Start("DialogueAdminChoicesData")
    net.WriteString(targetSteam)
    net.WriteString(util.TableToJSON(entries))
    net.Send(ply)
end)

net.Receive("DialogueAdminDeleteChoice", function(len, ply)
    if not IsValid(ply) then return end
    if not ply:IsAdmin() then return end

    local targetSteam = net.ReadString()
    local choiceID    = net.ReadString()

    if not AllChoices then LoadAllChoices() end
    local key = "s_" .. targetSteam
    if AllChoices[key] and AllChoices[key][choiceID] then
        AllChoices[key][choiceID] = nil
        SaveAllChoices()
        for _, p in ipairs(player.GetAll()) do
            if IsValid(p) and p:SteamID64() == targetSteam then
                if p.DialogueChoices then p.DialogueChoices[choiceID] = nil end
                break
            end
        end
    end

    local entries = {}
    local convIDs, choiceIDMap = BuildChoiceIndex()
    for id, val in pairs(AllChoices[key] or {}) do
        if val == true then
            local entryType = convIDs[id] and "conversation" or (choiceIDMap[id] and "choice" or "unknown")
            local source    = convIDs[id] or choiceIDMap[id] or ""
            table.insert(entries, { id = id, type = entryType, source = source })
        end
    end
    local order = { conversation = 1, choice = 2, unknown = 3 }
    table.sort(entries, function(a, b)
        local oa, ob = order[a.type] or 9, order[b.type] or 9
        if oa ~= ob then return oa < ob end
        return a.id < b.id
    end)

    net.Start("DialogueAdminChoicesData")
    net.WriteString(targetSteam)
    net.WriteString(util.TableToJSON(entries))
    net.Send(ply)
end)

hook.Add("InitPostEntity", "DialogueInit", function()
    LoadAllChoices()
    LoadAllNPCs()
    LoadStorageData()
    timer.Simple(1, LoadMapPlacements)
end)

timer.Create("TBC_StorageAutoSave", 120, 0, function()
    if StoragePlayerData or StorageGlobalData then SaveStorageData() end
end)

-- ---------------------------------------------------------------
--  Admin Storage
-- ---------------------------------------------------------------
local function AdminGetBucket(targetSteam)
    EnsurePlayerStorage(targetSteam)
    return StoragePlayerData[targetSteam].player
end

local function AdminSendData(ply, bucket)
    net.Start("AdminStorageData")
    net.WriteString(util.TableToJSON(bucket))
    net.Send(ply)
end

net.Receive("AdminStorageLoad", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local targetSteam = net.ReadString()

    local targetNick = "Unknown"
    for _, p in ipairs(player.GetAll()) do
        if IsValid(p) and p:SteamID() == targetSteam then targetNick = p:Nick() break end
    end

    local bucket = AdminGetBucket(targetSteam)
    NormalizeSlotKeys(bucket)

    net.Start("AdminStorageOpen")
    net.WriteString(targetSteam)
    net.WriteString(targetNick)
    net.WriteString(util.TableToJSON(bucket))
    net.Send(ply)
end)

net.Receive("AdminStorageAction", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local targetSteam = net.ReadString()
    local action      = net.ReadString()
    local slotIdx     = net.ReadInt(32)

    local bucket = AdminGetBucket(targetSteam)
    local key    = tostring(slotIdx)
    local entry  = bucket.slots and bucket.slots[key]
    if not entry then return end

    if action == "retrieve" then
        if entry.itemType == "passive" then
            local bName = entry.buffName or entry.classname
            local bType = entry.buffType or "permabuffs"
            local existing = GetAllStats and GetAllStats(ply, bType)
            if existing and existing[bName] then ply:ChatPrint("[AdminStorage] You already have this passive.") return end
            local restoreVal = entry.buffData or bName
            AssignStat(ply, bName, restoreVal, bType)
        else
            if ply:HasWeapon(entry.classname) then ply:ChatPrint("[AdminStorage] You already have that item.") return end
            ply:Give(entry.classname)
        end
        bucket.slots[key] = nil

    elseif action == "drop" then
        local wdata = weapons.GetStored(entry.classname)
        local model = (wdata and wdata.WorldModel) or "models/weapons/w_rif_ak47.mdl"
        if not util.IsValidModel(model) or model == "" then model = "models/weapons/w_rif_ak47.mdl" end

        local ent = ents.Create("prop_physics")
        if IsValid(ent) then
            ent:SetModel(model)
            ent.IsTBCDroppedWeapon = true
            ent.WeaponClass        = entry.classname
            ent.StoredClip         = 0
            ent.StoredAmmo         = 0
            ent.SlotsTaking        = entry.slotsTaking or 1
            ent.SlotType           = entry.slotType or "Equipment"
            ent.PrintName          = entry.name or entry.classname
            ent.nodupe             = true
            local tr = util.TraceLine({ start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 80, filter = ply })
            ent:SetPos(tr.HitPos)
            ent:Spawn()
            if TBC_PlaceEntity then
                TBC_PlaceEntity(ent, tr, ply)
            else
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then phys:EnableMotion(true) phys:Wake() end
                ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
                ent:Activate()
            end
        end
        bucket.slots[key] = nil

    elseif action == "delete" then
        bucket.slots[key] = nil
    end

    SaveStorageData()
    NormalizeSlotKeys(bucket)
    AdminSendData(ply, bucket)
end)

net.Receive("AdminStorageDeposit", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local targetSteam = net.ReadString()
    local classname   = net.ReadString()
    local slotType    = net.ReadString()
    local slotsTaking = net.ReadInt(32)
    local targetSlot  = net.ReadInt(32)
    local itemType    = net.ReadString()
    local buffName    = net.ReadString()
    local buffType    = net.ReadString()

    local bucket = AdminGetBucket(targetSteam)
    if not bucket.slots then bucket.slots = {} end

    local slot
    if targetSlot > 0 and targetSlot <= TOTAL_SLOTS and not bucket.slots[tostring(targetSlot)] then
        slot = targetSlot
    else
        slot = FindFreeSlot(bucket)
    end
    if not slot then ply:ChatPrint("[AdminStorage] Target storage is full!") return end

    if itemType == "passive" then
        local bType  = buffType ~= "" and buffType or "permabuffs"
        local stats  = GetAllStats and GetAllStats(ply, bType)
        if not stats or not stats[buffName] then ply:ChatPrint("[AdminStorage] Passive not found.") return end
        local liveData = stats[buffName]
        local passive  = Passives and Passives[buffName]
        local pdata    = Personas and Personas[buffName]
        bucket.slots[tostring(slot)] = {
            classname   = classname,
            buffName    = buffName,
            buffType    = bType,
            buffData    = liveData,
            slotType    = slotType,
            slotsTaking = slotsTaking,
            image       = GetItemImage(classname),
            name        = (passive and passive.name) or (pdata and pdata.name) or classname,
            itemType    = "passive",
        }
        RemoveStat(ply, buffName, bType)
    else
        local weapon = ply:GetWeapon(classname)
        if not IsValid(weapon) then ply:ChatPrint("[AdminStorage] Item not found in your inventory.") return end
        local wdata = weapons.GetStored(classname)
        bucket.slots[tostring(slot)] = {
            classname   = classname,
            slotType    = slotType,
            slotsTaking = slotsTaking,
            image       = GetItemImage(classname),
            name        = (wdata and wdata.PrintName) or classname,
            itemType    = "swep",
        }
        weapon:Remove()
    end

    SaveStorageData()
    NormalizeSlotKeys(bucket)
    AdminSendData(ply, bucket)
end)

net.Receive("AdminStorageCurrency", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local targetSteam = net.ReadString()
    local isDeposit   = net.ReadBool()
    local amount      = net.ReadInt(32)
    if amount <= 0 then return end

    if not TBC_CURRENCY then ply:ChatPrint("[AdminStorage] Currency system unavailable.") return end

    local bucket = AdminGetBucket(targetSteam)
    if not bucket.currency then bucket.currency = 0 end
    local sym = TBC_CURRENCY.Config.Symbol or "ћ"

    if isDeposit then
        if not TBC_CURRENCY.HasMoney(ply, amount) then ply:ChatPrint("[AdminStorage] Not enough currency in your wallet.") return end
        TBC_CURRENCY.TakeMoney(ply, amount)
        bucket.currency = bucket.currency + amount
        ply:ChatPrint(string.format("[AdminStorage] Deposited %s%d into %s's storage.", sym, amount, targetSteam))
    else
        if amount > bucket.currency then ply:ChatPrint("[AdminStorage] Not enough currency in that storage.") return end
        bucket.currency = bucket.currency - amount
        TBC_CURRENCY.GiveMoney(ply, amount)
        ply:ChatPrint(string.format("[AdminStorage] Withdrew %s%d from %s's storage.", sym, amount, targetSteam))
    end

    SaveStorageData()
    NormalizeSlotKeys(bucket)
    AdminSendData(ply, bucket)
end)

-- ---------------------------------------------------------------
--  Shop
-- ---------------------------------------------------------------
net.Receive("ShopSave", function(len, ply)
    if not IsValid(ply) or not ply:IsAdmin() then return end
    local npcUID  = net.ReadString()
    local rawShop = net.ReadString()
    local shopArr = util.JSONToTable(rawShop)
    if not shopArr then ply:ChatPrint("[Shop] Invalid data.") return end

    if not AllNPCs then LoadAllNPCs() end
    if not AllNPCs[npcUID] then AllNPCs[npcUID] = {} end
    AllNPCs[npcUID].shop = shopArr
    SaveAllNPCs()

    net.Start("ShopSaved")
    net.WriteString(npcUID)
    net.WriteString(rawShop)
    net.Send(ply)
    ply:ChatPrint("[Shop] Saved!")
end)

net.Receive("ShopBuy", function(len, ply)
    if not IsValid(ply) then return end
    local npcUID  = net.ReadString()
    local itemIdx = net.ReadInt(32)
    local mode    = net.ReadString()

    if not AllNPCs then LoadAllNPCs() end
    local data = AllNPCs[npcUID]
    if not data or not data.shop then ply:ChatPrint("[Shop] Shop not found.") return end
    local item = data.shop[itemIdx]
    if not item then ply:ChatPrint("[Shop] Item not found.") return end

    local classname = item.classname
    local price     = item.price or 0
    local itemCosts = item.itemCost or {}

    -- Resolve item kind: swep / passive / persona
    local wdata      = weapons.GetStored(classname)
    local passiveName = nil   -- buffName key in Passives table
    local passiveData = nil   -- full data table to AssignStat with
    local personaData = nil

    if wdata then
        -- SWEP
    elseif Passives then
        for bn, p in pairs(Passives) do
            if p.classname == classname then
                passiveName = bn
                -- Build the stat table the same way the entity does
                passiveData = { stacks = 1, SlotsTaking = 1, SlotType = "Equipment", ClassName = classname }
                break
            end
        end
    end
    if not wdata and not passiveName and Personas then
        personaData = Personas[classname]
    end

    if not wdata and not passiveName and not personaData then
        ply:ChatPrint("[Shop] Unknown item.")
        return
    end

    local slotType    = wdata and wdata.SlotType    or (passiveName and "Equipment") or "Persona"
    local slotsTaking = wdata and (wdata.SlotsTaking or 1) or 1
    local itemName    = wdata and wdata.PrintName
                        or (passiveName and Passives[passiveName].name)
                        or (personaData and personaData.name)
                        or classname

    -- Already-have checks per mode
    if mode == "give" then
        if wdata then
            if ply:HasWeapon(classname) then ply:ChatPrint("[Shop] You already have this item.") return end
            -- Slot check
            if slotType and slotsTaking > 0 then
                local maxEq = ply:GetNWInt("TBCEquipmentSlots", 15)
                local maxIt = ply:GetNWInt("TBCItemSlots", 10)
                local eq, it = CountUsedSlots(ply)
                if slotType == "Equipment" and eq + slotsTaking > maxEq then ply:ChatPrint("[Shop] Not enough Equipment slots.") return end
                if slotType == "Item"      and it + slotsTaking > maxIt then ply:ChatPrint("[Shop] Not enough Item slots.") return end
            end
        elseif passiveName then
            local existing = GetAllStats and GetAllStats(ply, "permabuffs")
            if existing and existing[passiveName] then ply:ChatPrint("[Shop] You already have this passive.") return end
        elseif personaData then
            local existing = GetAllStats and GetAllStats(ply, "personas")
            if existing and existing[classname] then ply:ChatPrint("[Shop] You already have this persona.") return end
            local personaCount = 0
            if existing then for _ in pairs(existing) do personaCount = personaCount + 1 end end
            if personaCount >= 3 then ply:ChatPrint("[Shop] You've reached your persona limit.") return end
        end
    end

    if not TBC_CURRENCY then ply:ChatPrint("[Shop] Currency system unavailable.") return end
    if not TBC_CURRENCY.HasMoney(ply, price) then
        ply:ChatPrint("[Shop] Not enough " .. TBC_CURRENCY.Config.Name .. ".")
        return
    end

    -- Item cost checks
    for _, cost in ipairs(itemCosts) do
        if cost.classname and cost.classname ~= "" then
            local costWep   = ply:GetWeapon(cost.classname)
            local inStorage = false
            local sid       = ply:SteamID()
            EnsurePlayerStorage(sid)
            for _, slotItem in pairs(StoragePlayerData[sid].player.slots or {}) do
                if slotItem.classname == cost.classname then inStorage = true break end
            end
            local hasInInventory = IsValid(costWep)
            if not hasInInventory and not inStorage then
                ply:ChatPrint("[Shop] Missing required item: " .. cost.classname)
                return
            end
            if hasInInventory then
                if not CanStoreWeapon(ply, costWep) then
                    ply:ChatPrint("[Shop] Cannot give up " .. cost.classname .. " (not droppable).")
                    return
                end
                costWep:Remove()
            else
                for k, slotItem in pairs(StoragePlayerData[sid].player.slots) do
                    if slotItem.classname == cost.classname then
                        StoragePlayerData[sid].player.slots[k] = nil
                        break
                    end
                end
                SaveStorageData()
            end
        end
    end

    TBC_CURRENCY.TakeMoney(ply, price)

    -- Helper: deliver to storage bucket
    local function DeliverToStorage()
        local sid    = ply:SteamID()
        EnsurePlayerStorage(sid)
        local bucket = StoragePlayerData[sid].player
        local slot   = FindFreeSlot(bucket)
        if not slot then return false end
        bucket.slots[tostring(slot)] = {
            classname   = classname,
            buffName    = passiveName or classname,
            buffType    = passiveName and "permabuffs" or (personaData and "personas" or nil),
            buffData    = passiveData or (personaData and classname) or nil,
            slotType    = slotType,
            slotsTaking = slotsTaking,
            image       = GetItemImage(classname),
            name        = itemName,
            itemType    = wdata and "swep" or "passive",
        }
        SaveStorageData()
        return true
    end

    -- Helper: drop as world entity near NPC
    local function DeliverAsDrop()
        local npcEnt = nil
        for _, e in ipairs(ents.FindByClass("dialogue")) do
            if IsValid(e) and e:GetNWString("DialogueUID", "") == npcUID then npcEnt = e break end
        end
        local dropPos, dropAng
        if IsValid(npcEnt) then
            dropPos = npcEnt:GetPos() + npcEnt:GetForward() * 60 + Vector(0, 0, 5)
            dropAng = Angle(0, npcEnt:GetAngles().y, 0)
        else
            local tr = util.TraceLine({ start = ply:GetShootPos(), endpos = ply:GetShootPos() + ply:GetAimVector() * 80, filter = ply })
            dropPos = tr.HitPos
            dropAng = Angle(0, ply:EyeAngles().y + 180, 0)
        end

        -- For passives/personas, spawn the scripted entity
        local entClass = passiveName and classname or (personaData and classname) or nil
        if entClass then
            local ent = ents.Create(entClass)
            if IsValid(ent) then
                ent:SetPos(dropPos); ent:SetAngles(dropAng); ent:Spawn(); ent:Activate()
            end
            return
        end

        -- SWEP — prop_physics
        local model = wdata.WorldModel or ""
        if not util.IsValidModel(model) or model == "" then model = "models/weapons/w_rif_ak47.mdl" end
        local ent = ents.Create("prop_physics")
        if IsValid(ent) then
            ent:SetModel(model)
            ent.IsTBCDroppedWeapon = true; ent.WeaponClass = classname
            ent.StoredClip = 0; ent.StoredAmmo = 0
            ent.SlotsTaking = slotsTaking; ent.SlotType = slotType
            ent.PrintName = itemName; ent.nodupe = true
            ent:SetPos(dropPos); ent:SetAngles(dropAng); ent:Spawn()
            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then phys:EnableMotion(true) phys:Wake() end
            ent:Activate()
            ent:SetNWString("PrintName", itemName)
        end
    end

    if mode == "give" then
        if wdata then
            ply:Give(classname)
        elseif passiveName then
            AssignStat(ply, passiveName, passiveData, "permabuffs")
        elseif personaData then
            AssignStat(ply, classname, classname, "personas")
        end

    elseif mode == "storage" then
        if not DeliverToStorage() then
            -- Storage full — fall back to give
            if wdata then ply:Give(classname)
            elseif passiveName then AssignStat(ply, passiveName, passiveData, "permabuffs")
            elseif personaData then AssignStat(ply, classname, classname, "personas") end
            ply:ChatPrint("[Shop] Storage full. Item given directly instead.")
        else
            ply:ChatPrint("[Shop] Item sent to storage.")
        end

    elseif mode == "drop" then
        DeliverAsDrop()
    end
end)