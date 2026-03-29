AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Copper Zone"
ENT.Author = "Nara"
ENT.Category = "Special Entities"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.CustomTitle = "Copper Zone"

if not ENT.EffectRadius then
    ENT.EffectRadius = Vector(100, 100, 100)
end

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetAngles(Angle(0, 0, 0)) -- Initially set angles to 0
    self:Activate()

    self:DrawShadow(false)

    local phys = self:GetPhysicsObject()

    self:CreateTrigger()

    if (IsValid(phys)) then
        phys:EnableGravity(true)
        phys:EnableMotion(false) -- Disable motion so angles don’t change
        phys:Wake()
    end
end

function ENT:CreateTrigger()
    if IsValid(self.Trigger) then
        self.Trigger:Remove()
    end

    if SERVER then
        self.Trigger = ents.Create("zone_trigger")
        self.Trigger:SetParent(self)
        self.Trigger:SetPos(self:GetPos())
        self.Trigger:SetAngles(self:GetAngles())
        self.Trigger.EffectRadius = self.EffectRadius
        self.Trigger.CustomTitle = self.CustomTitle
        self.Trigger:Spawn()

        function self.Trigger:StartTouch(ent)
            if ent:IsPlayer() then
                local charId = ent:GetNWString("AssignedCharacter")
                local charData = CHARACTERS.List[charId]

                if charData.type == "Police" then
                    ent:ChatPrint("You feel pretty confident and safe here.")

                    local targetBuffsTable = GetAllStats(ent, "permabuffs")

                    if targetBuffsTable["Police_Brutality"] then
                        if targetBuffsTable["Police_Brutality"].visibility == 0 then
                            targetBuffsTable["Police_Brutality"].visibility = 1

                            AssignStat(ent, "Police_Brutality", targetBuffsTable["Police_Brutality"], "permabuffs")
                        end
                    end
                end
            end
        end

        function self.Trigger:EndTouch(ent)
            if ent:IsPlayer() then
                local charId = ent:GetNWString("AssignedCharacter")
                local charData = CHARACTERS.List[charId]
                if charData.type == "Police" then
                    ent:ChatPrint("You no longer feel safe...")

                    local targetBuffsTable = GetAllStats(ent, "permabuffs")

                    if targetBuffsTable["Police_Brutality"] then
                        if targetBuffsTable["Police_Brutality"].visibility == 1 then
                            targetBuffsTable["Police_Brutality"].visibility = 0

                            AssignStat(ent, "Police_Brutality", targetBuffsTable["Police_Brutality"], "permabuffs")
                        end
                    end
                end
            end
        end
    end
end

function ENT:Draw()
    local player = LocalPlayer()
    if IsValid(player) then
        if player:Alive() and player:IsAdmin() then
            local weapon = player:GetActiveWeapon()
            if IsValid(weapon) and (weapon:GetClass() == "weapon_physgun" or weapon:GetClass() == "gmod_tool") then
                self:DrawModel()

                -- Use the same bounds as set in PhysicsInitBox
                local min = -self.EffectRadius
                local max = self.EffectRadius

                -- Render the bounds
                render.SetColorMaterial()
                render.DrawWireframeBox(self:GetPos(), Angle(0, 0, 0), min, max, Color(0, 255, 0), false)
            end
        end
    end
end

if SERVER then
    util.AddNetworkString("RequestCopperSync")
    util.AddNetworkString("UpdateCopperRadius")
    util.AddNetworkString("PersistCopperZones")
    util.AddNetworkString("UnpersistCopperZones")
    util.AddNetworkString("UpdateCopperZone")
    util.AddNetworkString("PlayerCopperZonesSync")
    util.AddNetworkString("RemoveCopperZone")

    net.Receive(
        "RemoveCopperZone",
        function(len, ply)
            local ent = net.ReadEntity()
            if IsValid(ent) and ply:IsAdmin() then
                ent:Remove()
            end
        end
    )

    function UpdateCopperZone(ent)
        net.Start("UpdateCopperZone")
        net.WriteInt(ent:EntIndex(), 32)
        net.WriteString(ent.CustomTitle)
        net.WriteVector(ent.EffectRadius)
        net.Broadcast()
    end

    local function SendZonesToPlayer(targetPlayer, ent)
        if not IsValid(targetPlayer) then
            return
        end

        if targetPlayer:IsAdmin() then
            net.Start("PlayerCopperZonesSync")
            net.WriteInt(ent:EntIndex(), 32)
            net.WriteString(ent.CustomTitle)
            net.WriteVector(ent.EffectRadius)
            net.Send(targetPlayer)
        end
    end

    net.Receive(
        "RequestCopperSync",
        function(len, ply)
            for _, ent in ipairs(ents.FindByClass("copper_zone")) do
                print(ent.CustomTitle)
                SendZonesToPlayer(ply, ent)
            end
        end
    )

    hook.Add(
        "PlayerInitialSpawn",
        "SyncZonesOnInitialSpawn",
        function(player)
            if player:IsAdmin() then
                for _, ent in ipairs(ents.FindByClass("copper_zone")) do
                    if IsValid(ent) then
                        SendZonesToPlayer(player, ent)
                    end
                end
            end
        end
    )

    net.Receive(
        "UpdateCopperRadius",
        function(len, ply)
            local ent = net.ReadEntity()
            local newName = net.ReadString()
            local newRadius = net.ReadVector()

            if IsValid(ent) and ent:GetClass() == "copper_zone" then
                ent.CustomTitle = newName
                ent.EffectRadius = newRadius
                ent:CreateTrigger()
                UpdateCopperZone(ent)
            end
        end
    )

    local function getSaveFileName()
        local mapName = game.GetMap() -- Get the current map name
        file.CreateDir("zone_data") -- Create the directory if it doesn't exist
        return "zone_data/copper_zones_data_" .. mapName .. ".txt"
    end

    local function SaveCopperZones()
        local fileName = getSaveFileName()
        local data = {}
        for _, ent in ipairs(ents.FindByClass("copper_zone")) do
            if IsValid(ent) then
                table.insert(
                    data,
                    {
                        pos = ent:GetPos(),
                        ang = ent:GetAngles(),
                        radius = ent.EffectRadius,
                        title = ent.CustomTitle
                    }
                )
            end
        end
        file.Write(fileName, util.TableToJSON(data))
    end

    net.Receive(
        "PersistCopperZones",
        function(len, ply)
            if ply:IsAdmin() then
                SaveCopperZones()
                ply:ChatPrint("All copper zones have been persisted for this map.")
            end
        end
    )

    net.Receive(
        "UnpersistCopperZones",
        function(len, ply)
            if not ply:IsAdmin() then
                return
            end

            local fileName = getSaveFileName()

            if file.Exists(fileName, "DATA") then
                file.Delete(fileName)
            end

            ply:ChatPrint("All copper zones have been unpersisted for this map and will no longer load on restart.")
        end
    )

    hook.Add(
        "InitPostEntity",
        "LoadCopperZones",
        function()
            local fileName = getSaveFileName()
            if file.Exists(fileName, "DATA") then
                local data = util.JSONToTable(file.Read(fileName, "DATA"))
                for _, entData in ipairs(data) do
                    local ent = ents.Create("copper_zone")
                    if IsValid(ent) then
                        ent:SetPos(entData.pos)
                        ent:SetAngles(entData.ang)
                        ent.EffectRadius = entData.radius
                        ent.CustomTitle = entData.title
                        ent:Spawn()
                        ent:Activate()

                        -- Freeze the entity to prevent it from falling
                        local phys = ent:GetPhysicsObject()
                        if IsValid(phys) then
                            phys:EnableMotion(false)
                        end

                        UpdateCopperZone(ent)
                    end
                end
            end
        end
    )
end

if CLIENT then
    properties.Add(
        "set_effect_radius_copper",
        {
            MenuLabel = "Set Zone Properties",
            Order = 1001,
            MenuIcon = "icon16/shape_handles.png",
            Filter = function(self, ent)
                return IsValid(ent) and ent:GetClass() == "copper_zone"
            end,
            Action = function(self, ent)
                if not IsValid(ent) then
                    return
                end

                -- Create a custom frame with text entries for X, Y, and Z
                local frame = vgui.Create("DFrame")
                frame:SetTitle("Zone Properties and Radius (X, Y, Z)")
                frame:SetSize(300, 250)
                frame:Center()
                frame:MakePopup()

                local zoneLabel = frame:Add("DLabel")
                zoneLabel:SetText("Zone Custom Label")
                zoneLabel:Dock(TOP)
                zoneLabel:SetContentAlignment(5)

                local zoneEntry = frame:Add("DTextEntry")
                zoneEntry:Dock(TOP)
                zoneEntry:SetValue(ent.CustomTitle)

                local xLabel = frame:Add("DLabel")
                xLabel:SetText("Zone Radius X")
                xLabel:Dock(TOP)
                xLabel:SetContentAlignment(5)

                local xEntry = frame:Add("DTextEntry")
                xEntry:Dock(TOP)
                xEntry:SetValue(ent.EffectRadius.x)
                xEntry:SetNumeric(true)

                -- Text entry for Y
                local yLabel = frame:Add("DLabel")
                yLabel:SetText("Zone Radius Y")
                yLabel:Dock(TOP)
                yLabel:SetContentAlignment(5)

                local yEntry = frame:Add("DTextEntry")
                yEntry:Dock(TOP)
                yEntry:SetValue(ent.EffectRadius.y)
                yEntry:SetNumeric(true)

                -- Text entry for Z
                local zLabel = frame:Add("DLabel")
                zLabel:SetText("Zone Radius Z")
                zLabel:Dock(TOP)
                zLabel:SetContentAlignment(5)

                local zEntry = frame:Add("DTextEntry")
                zEntry:Dock(TOP)
                zEntry:SetValue(ent.EffectRadius.z)
                zEntry:SetNumeric(true)

                -- Apply button to update the radius
                local applyButton = frame:Add("DButton")
                applyButton:SetText("Apply")
                applyButton:Dock(BOTTOM)

                -- Send updated effect radius to server when "Apply" is clicked
                applyButton.DoClick = function()
                    local newName = zoneEntry:GetValue()
                    local newRadius =
                        Vector(
                        tonumber(xEntry:GetValue()) or ent.EffectRadius.x,
                        tonumber(yEntry:GetValue()) or ent.EffectRadius.y,
                        tonumber(zEntry:GetValue()) or ent.EffectRadius.z
                    )

                    ent.CustomTitle = newName
                    ent.EffectRadius = newRadius
                    net.Start("UpdateCopperRadius")
                    net.WriteEntity(ent)
                    net.WriteString(newName)
                    net.WriteVector(newRadius)
                    net.SendToServer()
                    frame:Close()
                end
            end
        }
    )

    hook.Add(
        "PopulateToolMenu",
        "CopZoneCustomMenu",
        function()
            spawnmenu.AddToolMenuOption(
                "Utilities",
                "Area Controls",
                "CopZoneEntities",
                "Cop Zone Entities",
                "",
                "",
                function(panel)
                    if LocalPlayer():IsAdmin() then
                        panel:ClearControls()
                        panel:AddControl("Label", {Text = "Modify Cop Zone Entities in World"})

                        -- Zone List View
                        local zoneListView = vgui.Create("DListView", panel)
                        zoneListView:SetPos(10, 60)
                        zoneListView:SetSize(280, 200)
                        zoneListView:AddColumn("Zone")
                        zoneListView:SetMultiSelect(false)

                        -- Button to refresh the list
                        local updateButton = vgui.Create("DButton", panel)
                        updateButton:SetPos(10, 270)
                        updateButton:SetSize(280, 20)
                        updateButton:SetText("Update List")

                        local function updateItems()
                            zoneListView:Clear()
                            for _, ent in ipairs(ents.FindByClass("copper_zone")) do
                                if IsValid(ent) then
                                    local line = zoneListView:AddLine(ent.CustomTitle or ("Zone " .. ent:EntIndex()))
                                    line.index = ent:EntIndex()
                                    line.ent = ent
                                end
                            end
                        end

                        updateItems()

                        updateButton.DoClick = function()
                            net.Start("RequestCopperSync")
                            net.SendToServer()
                            updateItems()
                        end

                        local verticalOffset = 300

                        -- Title Input
                        local zoneLabel = vgui.Create("DLabel", panel)
                        zoneLabel:SetPos(10, verticalOffset)
                        zoneLabel:SetSize(280, 20)
                        zoneLabel:SetText("Zone Custom Label")
                        zoneLabel:SetTextColor(Color(0, 0, 0))

                        local zoneEntry = vgui.Create("DTextEntry", panel)
                        zoneEntry:SetPos(10, verticalOffset + 20)
                        zoneEntry:SetSize(280, 20)
                        zoneEntry:SetPlaceholderText("Enter Custom Label")

                        -- X Radius Input
                        local xLabel = vgui.Create("DLabel", panel)
                        xLabel:SetPos(10, verticalOffset + 40)
                        xLabel:SetSize(280, 20)
                        xLabel:SetText("Zone Radius X")
                        xLabel:SetTextColor(Color(0, 0, 0))

                        local xEntry = vgui.Create("DTextEntry", panel)
                        xEntry:SetPos(10, verticalOffset + 60)
                        xEntry:SetSize(280, 20)
                        xEntry:SetNumeric(true)

                        -- Y Radius Input
                        local yLabel = vgui.Create("DLabel", panel)
                        yLabel:SetPos(10, verticalOffset + 80)
                        yLabel:SetSize(280, 20)
                        yLabel:SetText("Zone Radius Y")
                        yLabel:SetTextColor(Color(0, 0, 0))

                        local yEntry = vgui.Create("DTextEntry", panel)
                        yEntry:SetPos(10, verticalOffset + 100)
                        yEntry:SetSize(280, 20)
                        yEntry:SetNumeric(true)

                        -- Z Radius Input
                        local zLabel = vgui.Create("DLabel", panel)
                        zLabel:SetPos(10, verticalOffset + 120)
                        zLabel:SetSize(280, 20)
                        zLabel:SetText("Zone Radius Z")
                        zLabel:SetTextColor(Color(0, 0, 0))

                        local zEntry = vgui.Create("DTextEntry", panel)
                        zEntry:SetPos(10, verticalOffset + 140)
                        zEntry:SetSize(280, 20)
                        zEntry:SetNumeric(true)

                        -- Apply button to update the properties
                        local applyButton = vgui.Create("DButton", panel)
                        applyButton:SetPos(10, verticalOffset + 170)
                        applyButton:SetSize(280, 20)
                        applyButton:SetText("Apply")

                        applyButton.DoClick = function()
                            local selectedLine = zoneListView:GetSelectedLine()
                            if selectedLine then
                                local ent = zoneListView:GetLine(selectedLine).ent
                                if IsValid(ent) then
                                    local newName = zoneEntry:GetValue()
                                    local newRadius =
                                        Vector(
                                        tonumber(xEntry:GetValue()) or 100,
                                        tonumber(yEntry:GetValue()) or 100,
                                        tonumber(zEntry:GetValue()) or 100
                                    )

                                    ent.CustomTitle = newName
                                    ent.EffectRadius = newRadius
                                    net.Start("UpdateCopperRadius")
                                    net.WriteEntity(ent)
                                    net.WriteString(newName)
                                    net.WriteVector(newRadius)
                                    net.SendToServer()
                                end
                            end
                        end

                        -- This fills the entry fields for modification
                        zoneListView.OnRowSelected = function(_, index, row)
                            local ent = row.ent
                            if IsValid(ent) then
                                zoneEntry:SetValue(ent.CustomTitle or "Copper Zone")
                                xEntry:SetValue(ent.EffectRadius.x)
                                yEntry:SetValue(ent.EffectRadius.y)
                                zEntry:SetValue(ent.EffectRadius.z)
                            end
                        end

                        -- Remove button to delete the selected zone
                        local removeButton = vgui.Create("DButton", panel)
                        removeButton:SetPos(10, verticalOffset + 200) -- Adjust position as needed
                        removeButton:SetSize(280, 20)
                        removeButton:SetText("Remove Selected Zone")

                        removeButton.DoClick = function()
                            local selectedLine = zoneListView:GetSelectedLine()
                            if selectedLine then
                                local ent = zoneListView:GetLine(selectedLine).ent
                                if IsValid(ent) then
                                    -- Inform the server to remove the entity
                                    net.Start("RemoveCopperZone")
                                    net.WriteEntity(ent)
                                    net.SendToServer()

                                    zoneListView:RemoveLine(selectedLine)

                                    zoneEntry:SetValue()
                                    xEntry:SetValue(0)
                                    yEntry:SetValue(0)
                                    zEntry:SetValue(0)
                                end
                            end
                        end

                        local persistButton = vgui.Create("DButton", panel)
                        persistButton:SetPos(10, verticalOffset + 230) -- Position it below the Apply button
                        persistButton:SetSize(280, 20)
                        persistButton:SetText("Persist All Zones")

                        persistButton.DoClick = function()
                            net.Start("PersistCopperZones")
                            net.SendToServer()
                        end

                        local unpersistButton = vgui.Create("DButton", panel)
                        unpersistButton:SetPos(10, verticalOffset + 260) -- Position it below the Apply button
                        unpersistButton:SetSize(280, 20)
                        unpersistButton:SetText("Unpersist All Zones")

                        unpersistButton.DoClick = function()
                            net.Start("UnpersistCopperZones")
                            net.SendToServer()
                        end
                    else
                        panel:ClearControls()
                        panel:AddControl(
                            "Label",
                            {
                                Text = "Modify Copper Zone Entities in World... If you were an Admin. Lmao."
                            }
                        )
                    end
                end
            )
        end
    )

    net.Receive(
        "UpdateCopperZone",
        function()
            local index = net.ReadInt(32)
            local newName = net.ReadString()
            local newRadius = net.ReadVector()

            local ent = Entity(index)

            if IsValid(ent) and ent:GetClass() == "copper_zone" then
                ent.CustomTitle = newName
                ent.EffectRadius = newRadius
            end
        end
    )

    net.Receive(
        "PlayerCopperZonesSync",
        function()
            local index = net.ReadInt(32)
            local newName = net.ReadString()
            local newRadius = net.ReadVector()

            timer.Simple(
                2,
                function()
                    local ent = Entity(index)

                    if IsValid(ent) and ent:GetClass() == "copper_zone" then
                        ent.CustomTitle = newName
                        ent.EffectRadius = newRadius
                    end
                end
            )
        end
    )
end

scripted_ents.Register(ENT, "copper_zone")
