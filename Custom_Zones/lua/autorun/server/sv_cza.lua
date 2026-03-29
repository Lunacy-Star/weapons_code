AddCSLuaFile()

if SERVER then
    util.AddNetworkString("UpdateZoneRadius")
    util.AddNetworkString("PersistZones")
    util.AddNetworkString("UnpersistZones")
    util.AddNetworkString("PlayerZonesSync")
    util.AddNetworkString("RemoveZone")
    util.AddNetworkString("ZoneEntered")
    -- util.AddNetworkString("ZoneExit")

    net.Receive("RemoveZone", function(len, ply)
        local ent = net.ReadEntity()
        if IsValid(ent) and ply:IsAdmin() then ent:Remove() end
    end)

    local function SendZonesToPlayer(targetPlayer, ent)
        if not IsValid(targetPlayer) then return end

        net.Start("PlayerZonesSync")
        net.WriteInt(ent:EntIndex(), 32)
        net.WriteString(ent.CustomTitle)
        net.WriteString(ent.ZoneMusic)
        net.WriteVector(ent.EffectRadius)
        net.Send(targetPlayer)
    end

    hook.Add("PlayerSwitchWeapon", "SyncZonesOnWeaponSwap",
             function(ply, oldWeapon, newWeapon)
        if ply:IsAdmin() then
            if (newWeapon:GetClass() == "weapon_physgun" or newWeapon:GetClass() ==
                "gmod_tool") then

                for _, ent in ipairs(ents.FindByClass("custom_zone")) do
                    if IsValid(ent) then
                        SendZonesToPlayer(ply, ent)
                    end
                end
            end
        end
    end)

    net.Receive("UpdateZoneRadius", function(len, ply)
        local ent = net.ReadEntity()
        local newName = net.ReadString()
        local newMusic = net.ReadString()
        local newRadius = net.ReadVector()

        if IsValid(ent) and ent:GetClass() == "custom_zone" then
            ent.CustomTitle = newName
            ent.ZoneMusic = newMusic
            ent.EffectRadius = newRadius
            ent:CreateTrigger()
            SendZonesToPlayer(ply, ent)
        end
    end)

    local function getSaveFileName()
        local mapName = game.GetMap() -- Get the current map name
        file.CreateDir("zone_data") -- Create the directory if it doesn't exist
        return "zone_data/custom_zones_data_" .. mapName .. ".txt"
    end

    local function SaveCustomZones()
        local fileName = getSaveFileName()
        local data = {}
        for _, ent in ipairs(ents.FindByClass("custom_zone")) do
            if IsValid(ent) then
                table.insert(data, {
                    pos = ent:GetPos(),
                    ang = ent:GetAngles(),
                    radius = ent.EffectRadius,
                    title = ent.CustomTitle,
                    music = ent.ZoneMusic
                })
            end
        end
        file.Write(fileName, util.TableToJSON(data))
    end

    net.Receive("PersistZones", function(len, ply)
        if ply:IsAdmin() then
            SaveCustomZones()
            ply:ChatPrint("All custom zones have been persisted for this map.")
        end
    end)

    net.Receive("UnpersistZones", function(len, ply)
        if not ply:IsAdmin() then return end

        local fileName = getSaveFileName()
        if file.Exists(fileName, "DATA") then file.Delete(fileName) end

        ply:ChatPrint(
            "All custom zones have been unpersisted for this map and will no longer load on restart.")
    end)

    hook.Add("InitPostEntity", "LoadCustomZones", function()
        local fileName = getSaveFileName()
        if file.Exists(fileName, "DATA") then
            local data = util.JSONToTable(file.Read(fileName, "DATA"))
            for _, entData in ipairs(data) do
                local ent = ents.Create("custom_zone")
                if IsValid(ent) then
                    ent:SetPos(entData.pos)
                    ent:SetAngles(entData.ang)
                    ent.EffectRadius = entData.radius
                    ent.CustomTitle = entData.title
                    ent.ZoneMusic = entData.music
                    ent:Spawn()
                    ent:Activate()

                    -- Freeze the entity to prevent it from falling
                    local phys = ent:GetPhysicsObject()
                    if IsValid(phys) then
                        phys:EnableMotion(false)
                    end
                end
            end
        end
    end)
end
