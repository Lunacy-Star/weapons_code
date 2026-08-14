if CLIENT then
    return
end

game.AddAmmoType({name = "items"})

util.AddNetworkString("RequestInventoryData")
util.AddNetworkString("OpenInventory")
util.AddNetworkString("UpdateInventory")
util.AddNetworkString("DropWeapon")
util.AddNetworkString("DropItems")
util.AddNetworkString("EquipPersona")
util.AddNetworkString("DropPersona")
util.AddNetworkString("ChangeProfession")
util.AddNetworkString("RequestProfessionData")
util.AddNetworkString("SyncProfession")
util.AddNetworkString("PartyInviteRequest")

SMT_PROFESSIONS = {
    "Cooking",
    "Alchemy",
    "Crafting",
    "Genius"
}

local PROFESSIONS_FILE = "smt_player_data.json"
local PlayerData = {}

local function LoadProfessions()
    if file.Exists(PROFESSIONS_FILE, "DATA") then
        local data = file.Read(PROFESSIONS_FILE, "DATA")
        if data then
            PlayerData = util.JSONToTable(data) or {}
            return
        end
    end
    PlayerData = {}
end

local function SaveProfessions()
    local data = util.TableToJSON(PlayerData)
    file.Write(PROFESSIONS_FILE, data)
end

local function GetPlayerData(steamID)
    if not PlayerData[steamID] then
        PlayerData[steamID] = {
            Profession = "Cooking",
            knowledge = {}
        }
    end
    return PlayerData[steamID]
end

local function GetPlayerProfession(steamID)
    local data = GetPlayerData(steamID)
    return data.Profession or "Cooking"
end

local function GetPlayerKnowledge(steamID)
    local data = GetPlayerData(steamID)
    return data.knowledge or {}
end

local function SetPlayerProfession(steamID, profession)
    if not table.HasValue(SMT_PROFESSIONS, profession) then
        return false
    end
    local data = GetPlayerData(steamID)
    print(steamID)
    PrintTable(data)
    data.Profession = profession
    SaveProfessions()
    return true
end

local function AddPlayerKnowledge(steamID, knowledge)
    if not knowledge or knowledge == "" then
        return false
    end
    local data = GetPlayerData(steamID)
    if not table.HasValue(data.knowledge, knowledge) then
        table.insert(data.knowledge, knowledge)
        SaveProfessions()
        return true
    end
    return false
end

function SMT_GetPlayerProfession(identifier)
    if IsValid(identifier) and identifier:IsPlayer() then
        return GetPlayerProfession(identifier:SteamID())
    elseif type(identifier) == "string" then
        return GetPlayerProfession(identifier)
    end
    return "Cooking"
end

function SMT_GetPlayerKnowledge(identifier)
    if IsValid(identifier) and identifier:IsPlayer() then
        return GetPlayerKnowledge(identifier:SteamID())
    elseif type(identifier) == "string" then
        return GetPlayerKnowledge(identifier)
    end
    return {}
end



-- Load professions on startup
LoadProfessions()

-- Player profession cooldowns
local ProfessionChangeCooldown = {}

function TBC_PlaceEntity(ent, tr, ply)
    if not IsValid(ent) then
        return
    end

    local pos = tr.HitPos + tr.HitNormal * 5
    ent:SetPos(pos)
    ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))

    local phys = ent:GetPhysicsObject()
    if IsValid(phys) then
        phys:EnableMotion(true)
        phys:Wake()
    end

    ent:SetNWString("PrintName", ent.PrintName or "Unknown")
    ent:Activate()
end

local function TBC_CreateDroppedWeapon(ply, weapon, amountToDrop)
    if not IsValid(ply) or not IsValid(weapon) then
        return
    end

    local weaponClass = weapon:GetClass()
    local primAmmo = amountToDrop

    local model = weapon:GetModel()
    if model == "models/weapons/v_physcannon.mdl" then
        model = "models/weapons/w_physics.mdl"
    end
    if not util.IsValidModel(model) then
        model = "models/weapons/w_rif_ak47.mdl"
    end

    local ent = ents.Create("prop_physics")
    if not IsValid(ent) then
        return
    end

    ent:SetModel(model)
    ent:SetSkin(weapon:GetSkin() or 0)

    ent.IsTBCDroppedWeapon = true
    ent.WeaponClass = weaponClass
    ent.StoredClip = amountToDrop
    ent.StoredAmmo = primAmmo
    ent.SlotsTaking = weapon.SlotsTaking or 1
    ent.SlotType = weapon.SlotType or "Equipment"
    ent.nodupe = true

    ent.PrintName = weapon.PrintName or weaponClass

    local trace = {}
    trace.start = ply:GetShootPos()
    trace.endpos = trace.start + ply:GetAimVector() * 50
    trace.filter = {ply, weapon, ent}
    local tr = util.TraceLine(trace)

    ent:SetPos(tr.HitPos)
    ent:Spawn()
    TBC_PlaceEntity(ent, tr, ply)

    ply:RemoveAmmo(primAmmo, weapon:GetPrimaryAmmoType())
    ply:RemoveAmmo(ply:GetAmmoCount(weapon:GetSecondaryAmmoType()), weapon:GetSecondaryAmmoType())

    hook.Call("TBC_WeaponDropped", nil, ply, ent, weapon)

    if weapon.DropFunction then
        weapon:DropFunction()
    end

    weapon:TakePrimaryAmmo(amountToDrop)

    local currentAmmo = weapon:Clip1()
    if currentAmmo <= 0 then
        weapon:Remove()
    end
end

concommand.Add(
    "inventory",
    function(ply, cmd, args)
        net.Start("OpenInventory")
        net.Send(ply)
    end
)

net.Receive(
    "RequestProfessionData",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local steamID = player:SteamID()
        local profession = GetPlayerProfession(steamID)

        net.Start("SyncProfession")
        net.WriteString(profession)
        net.Send(player)
    end
)

net.Receive(
    "ChangeProfession",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local steamID = player:SteamID()
        local newProfession = net.ReadString()

        -- Check cooldown
        if ProfessionChangeCooldown[steamID] and CurTime() < ProfessionChangeCooldown[steamID] then
            player:ChatPrint("You can only change professions every 5 seconds.")
            return
        end

        -- Validate profession
        if not table.HasValue(SMT_PROFESSIONS, newProfession) then
            player:ChatPrint("Invalid profession selected.")
            return
        end

        -- Set the profession
        if SetPlayerProfession(steamID, newProfession) then
            ProfessionChangeCooldown[steamID] = CurTime() + 5

            -- Sync back to client
            net.Start("SyncProfession")
            net.WriteString(newProfession)
            net.Send(player)

            player:ChatPrint("Profession changed to: " .. newProfession)

            -- You can hook into this for additional logic
            hook.Call("SMT_ProfessionChanged", nil, player, newProfession)
        end
    end
)

net.Receive(
    "DropWeapon",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local classType = net.ReadString()
        local class = net.ReadString()

        if classType == "swep" then
            local weapon = player:GetWeapon(class)
            if IsValid(weapon) then
                if player:HasWeapon(class) then
                    player:TBC_DropWeapon(weapon)
                end
            end
        elseif classType == "passive" then
            local ent = ents.Create(class)
            local weapon = player:GetActiveWeapon()

            local trace = {}
            trace.start = player:GetShootPos()
            trace.endpos = trace.start + player:GetAimVector() * 50
            trace.filter = {player, weapon, ent}

            local tr = util.TraceLine(trace)

            ent:SetPos(tr.HitPos)
            ent:Spawn()

            TBC_PlaceEntity(ent, tr, player)

            RemoveStat(player, ent.BuffRegistration, ent.BuffType)
        end
    end
)

net.Receive(
    "DropItems",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local amountToDrop = net.ReadInt(32)
        local classType = net.ReadString()
        local class = net.ReadString()

        if classType == "swep" then
            local weapon = player:GetWeapon(class)
            if IsValid(weapon) then
                if player:HasWeapon(class) then
                    if amountToDrop then
                        TBC_CreateDroppedWeapon(player, weapon, amountToDrop)
                    end
                end
            end
        elseif classType == "passive" then
            local ent = ents.Create(class)
            local weapon = player:GetActiveWeapon()

            local trace = {}
            trace.start = player:GetShootPos()
            trace.endpos = trace.start + player:GetAimVector() * 50
            trace.filter = {player, weapon, ent}

            local tr = util.TraceLine(trace)

            ent:SetPos(tr.HitPos)
            ent:Spawn()

            TBC_PlaceEntity(ent, tr, player)

            RemoveStat(player, ent.BuffRegistration, ent.BuffType)
        end
    end
)

-- ============================================================
-- Party management (leader actions triggered from the Party tab)
-- ============================================================
net.Receive(
    "PlayerPartyModify",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local partyId = net.ReadString()
        local action = net.ReadString()
        -- For "rename" this field carries the new party name instead of a SteamID.
        local targetSteamID = net.ReadString()
        local newPosition = net.ReadUInt(16)

        if action == "kick" then
            KickFromParty(player, partyId, targetSteamID)
        elseif action == "promote" then
            SetPartyLeader(player, partyId, targetSteamID)
        elseif action == "move" then
            MovePartyMember(player, partyId, targetSteamID, newPosition)
        elseif action == "disband" then
            DisbandParty(player, partyId)
        elseif action == "rename" then
            RenameParty(player, partyId, targetSteamID)
        end
    end
)

net.Receive(
    "PartyInviteRequest",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local target = net.ReadEntity()

        local success, message = InvitePlayerToParty(player, target)
        if message then
            player:ChatPrint(message)
        end
    end
)

net.Receive(
    "EquipPersona",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local persona = net.ReadString()

        local personaData = Personas[persona]

        if personaData then
            local oldPersona = player:GetNW2String("selectedPersona", "")
            local oldPersonaData = Personas[oldPersona]

            if oldPersonaData then
                for weaponIndex, weaponClass in pairs(oldPersonaData.skills) do
                    local weapon = player:GetWeapon(weaponClass)
                    if IsValid(weapon) then
                        if player:HasWeapon(weaponClass) then
                            weapon:Remove()
                        end
                    end
                end
            end

            for weaponIndex, weaponClass in pairs(personaData.skills) do
                player:Give(weaponClass)
            end

            local playerSWEP = player:GetWeapon("smti_engageswep")

            local fight = TBCWeaponMetatable.OngoingFights[playerSWEP.FightId]
            if fight then
                if IsValid(playerSWEP) then
                    for _, weapon in pairs(player:GetWeapons()) do
                        weapon.FightId = playerSWEP.FightId
                    end

                    playerSWEP:AnnounceMessage(player:Name() .. " switched his persona to " .. personaData.name .. "!")
                end
            end

            player:SetNW2String("selectedPersona", persona)

            AssignStat(player, persona, persona, "personas")
        end
    end
)

net.Receive(
    "DropPersona",
    function(len, player)
        if not IsValid(player) or not player:IsPlayer() then
            return
        end

        local persona = net.ReadString()
        local dropPersona = net.ReadBool()

        local personaData = Personas[persona]

        if personaData then
            for weaponIndex, weaponClass in pairs(personaData.skills) do
                local weapon = player:GetWeapon(weaponClass)
                if IsValid(weapon) then
                    if player:HasWeapon(weaponClass) then
                        weapon:Remove()
                    end
                end
            end
            if player:GetNW2String("selectedPersona", "") == persona then
                player:SetNW2String("selectedPersona", "")
            end

            if dropPersona then
                local ent = ents.Create(persona)
                local weapon = player:GetActiveWeapon()

                local trace = {}
                trace.start = player:GetShootPos()
                trace.endpos = trace.start + player:GetAimVector() * 50
                trace.filter = {player, weapon, ent}

                local tr = util.TraceLine(trace)

                ent:SetPos(tr.HitPos)
                ent:Spawn()

                TBC_PlaceEntity(ent, tr, player)

                RemoveStat(player, persona, "personas")
            end
        end
    end
)

-- ============================================================
-- Give() wrapper
-- ============================================================
local meta = FindMetaTable("Player")
local OriginalGive = meta.Give

function meta:Give(weaponClass, noAmmo)
    self.TBC_AllowPickup = true
    local wep = OriginalGive(self, weaponClass, noAmmo)
    self.TBC_AllowPickup = false
    return wep
end

local function CountUsedSlots(ply)
    local equipmentUsed = 0
    local itemsUsed = 0

    for _, weapon in pairs(ply:GetWeapons()) do
        if weapon.SlotType and weapon.SlotsTaking then
            if weapon.SlotType == "Equipment" then
                equipmentUsed = equipmentUsed + weapon.SlotsTaking
            elseif weapon.SlotType == "Item" then
                itemsUsed = itemsUsed + weapon.SlotsTaking
            end
        end
    end

    local buffs = GetAllStats(ply, "permabuffs")
    if buffs then
        for _, ailmentInfo in pairs(buffs) do
            if ailmentInfo.SlotType and ailmentInfo.SlotsTaking then
                if ailmentInfo.SlotType == "Equipment" then
                    equipmentUsed = equipmentUsed + ailmentInfo.SlotsTaking
                elseif ailmentInfo.SlotType == "Item" then
                    itemsUsed = itemsUsed + ailmentInfo.SlotsTaking
                end
            end
        end
    end

    return equipmentUsed, itemsUsed
end

hook.Add(
    "PlayerCanPickupWeapon",
    "TBC_BlockAutoPickup",
    function(ply, weapon)
        if ply.TBC_AllowPickup then
            return
        end
        return false
    end
)

local TBC_PickupCooldown = {}

hook.Add(
    "PlayerUse",
    "TBC_PickupDroppedWeapon",
    function(ply, ent)
        if not IsValid(ply) or not IsValid(ent) then
            return
        end
        if not ent.IsTBCDroppedWeapon then
            return
        end

        local sid = ply:SteamID()
        if TBC_PickupCooldown[sid] and CurTime() < TBC_PickupCooldown[sid] then
            return false
        end
        TBC_PickupCooldown[sid] = CurTime() + 0.5

        local slotType = ent.SlotType
        local slotsTaking = ent.SlotsTaking or 0

        if slotsTaking > 0 and slotType then
            for _, w in ipairs(ply:GetWeapons()) do
                if w:GetClass() == ent.WeaponClass then
                    ply:ChatPrint("You already have this weapon!")
                    return false
                end
            end
        end

        if slotsTaking and slotsTaking > 0 and slotType then
            local maxEquipment = ply:GetNWInt("TBCEquipmentSlots", 15)
            local maxItems = ply:GetNWInt("TBCItemSlots", 10)
            local equipmentUsed, itemsUsed = CountUsedSlots(ply)

            if slotType == "Equipment" then
                if equipmentUsed + slotsTaking > maxEquipment then
                    ply:ChatPrint("You've reached your inventory Equipment slots!")
                    return false
                end
            elseif slotType == "Item" then
                local alreadyHas = false
                for _, w in ipairs(ply:GetWeapons()) do
                    if w:GetClass() == ent.WeaponClass then
                        alreadyHas = true
                        break
                    end
                end

                if not alreadyHas and itemsUsed + slotsTaking > maxItems then
                    ply:ChatPrint("You've reached your inventory Item slots!")
                    return false
                end
            end
        end

        local givenWeapon = ply:Give(ent.WeaponClass)
        if IsValid(givenWeapon) then
            if ent.StoredClip1 then
                givenWeapon:SetClip1(ent.StoredClip1)
            elseif ent.StoredClip then
                givenWeapon:SetClip1(ent.StoredClip)
            end

            if ent.StoredClip2 then
                givenWeapon:SetClip2(ent.StoredClip2)
            end

            if ent.StoredAmmo and ent.StoredAmmo > 0 then
                ply:GiveAmmo(ent.StoredAmmo, givenWeapon:GetPrimaryAmmoType())
            end
        end

        ent:Remove()
        return false
    end
)

function meta:TBC_DropWeapon(weapon)
    if not IsValid(self) or not IsValid(weapon) then
        return
    end

    local weaponClass = weapon:GetClass()
    local primAmmo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())

    local model = weapon:GetModel()
    if model == "models/weapons/v_physcannon.mdl" then
        model = "models/weapons/w_physics.mdl"
    end
    if not util.IsValidModel(model) then
        model = "models/weapons/w_rif_ak47.mdl"
    end

    local ent = ents.Create("prop_physics")
    if not IsValid(ent) then
        return
    end

    ent:SetModel(model)
    ent:SetSkin(weapon:GetSkin() or 0)

    ent.IsTBCDroppedWeapon = true
    ent.WeaponClass = weaponClass
    ent.StoredClip1 = weapon:Clip1()
    ent.StoredClip2 = weapon:Clip2()
    ent.StoredAmmo = primAmmo
    ent.SlotsTaking = weapon.SlotsTaking or 1
    ent.SlotType = weapon.SlotType or "Equipment"
    ent.nodupe = true

    ent.PrintName = weapon.PrintName or weaponClass

    local trace = {}
    trace.start = self:GetShootPos()
    trace.endpos = trace.start + self:GetAimVector() * 50
    trace.filter = {self, weapon, ent}
    local tr = util.TraceLine(trace)

    ent:SetPos(tr.HitPos)
    ent:Spawn()
    TBC_PlaceEntity(ent, tr, self)

    self:RemoveAmmo(primAmmo, weapon:GetPrimaryAmmoType())
    self:RemoveAmmo(self:GetAmmoCount(weapon:GetSecondaryAmmoType()), weapon:GetSecondaryAmmoType())

    hook.Call("TBC_WeaponDropped", nil, self, ent, weapon)

    if weapon.DropFunction then
        weapon:DropFunction()
    end

    weapon:Remove()
end

local function CanDropWeapon(ply, weapon)
    if not IsValid(weapon) then
        return false, "No valid weapon to drop."
    end

    if weapon:GetModel() == "" then
        return false, "You cannot drop this weapon."
    end

    if weapon.PersonaSkill then
        return false, "You cannot drop a persona skill."
    end

    if TBC_IsFreeCharacterItem and TBC_IsFreeCharacterItem(ply, weapon:GetClass()) then
        return false, "You cannot drop this item."
    end

    local canDrop = hook.Run("TBC_CanDropWeapon", ply, weapon)
    if canDrop == false then
        return false, "You cannot drop this weapon."
    end

    return true
end

hook.Add(
    "PlayerSay",
    "TBC_DropWeaponCommand",
    function(ply, text)
        local cmd = string.lower(text)
        if cmd ~= "/drop" and cmd ~= "/dropweapon" then
            return
        end

        local weapon = ply:GetActiveWeapon()
        local canDrop, reason = CanDropWeapon(ply, weapon)

        if not canDrop then
            ply:ChatPrint(reason)
            return ""
        end

        ply:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)

        timer.Simple(
            1,
            function()
                if not IsValid(ply) or not IsValid(weapon) then
                    return
                end
                if not ply:Alive() then
                    return
                end

                local stillCanDrop = CanDropWeapon(ply, weapon)
                if not stillCanDrop then
                    return
                end

                ply:TBC_DropWeapon(weapon)
            end
        )

        return ""
    end
)
