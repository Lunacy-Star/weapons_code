AddCSLuaFile()

if CLIENT then
    surface.CreateFont("LargeTrebuchet", {
        font = "Trebuchet24",
        size = 48,
        weight = 500,
        antialias = true,
        shadow = true
    })

    -- Shared with SMT Weapons Code's battle/victory music (cl_battle_music.lua) so the
    -- two systems can hand off to one another. Neither addon requires the other to load.
    SMT_MusicState = SMT_MusicState or {
        Playing = nil,
        ZoneMusic = nil,
        InFight = false
    }

    local musicEnabledConVar = CreateClientConVar("area_music_enabled", "1",
                                                  true, false,
                                                  "Toggle area music on or off")
    CreateClientConVar("music_volume", "1", true, false,
                       "Adjust the battle music volume between 0 (mute) and 1 (full volume)")

    local musicEnabled = musicEnabledConVar:GetBool()

    cvars.AddChangeCallback("area_music_enabled",
                            function(convar_name, value_old, value_new)
        if value_new == "1" then
            musicEnabled = true
        elseif value_new == "0" then
            if IsValid(SMT_MusicState.Playing) then
                SMT_MusicState.Playing:Stop()
                SMT_MusicState.Playing = nil
            end
            musicEnabled = false
        end
    end)

    properties.Add("set_effect_radius", {
        MenuLabel = "Set Zone Properties",
        Order = 1001,
        MenuIcon = "icon16/shape_handles.png",

        Filter = function(self, ent)
            return IsValid(ent) and ent:GetClass() == "custom_zone" or
                       ent:GetClass() == "death_zone"
        end,

        Action = function(self, ent)
            if not IsValid(ent) then return end

            -- Create a custom frame with text entries for X, Y, and Z
            local frame = vgui.Create("DFrame")
            frame:SetTitle("Zone Properties and Radius (X, Y, Z)")
            frame:SetSize(300, 300)
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

            local musicLabel = frame:Add("DLabel")
            musicLabel:SetText("Set Zone Music")
            musicLabel:Dock(TOP)
            musicLabel:SetContentAlignment(5)

            local musicEntry = frame:Add("DTextEntry")
            musicEntry:Dock(TOP)
            musicEntry:SetValue(ent.ZoneMusic)

            local musicButton = frame:Add("DButton")
            musicButton:SetText("Find Music")
            musicButton:Dock(TOP)

            -- This is all taken directly from the documentation in the gmod facepunch wiki honestly. All for DFileBrowser.
            musicButton.DoClick = function()
                local frame = vgui.Create("DFrame")
                frame:SetSize(500, 500) -- Set the size of the frame
                frame:SetSizable(true) -- Allow the frame to be resizable
                frame:Center() -- Center the frame on the screen
                frame:MakePopup() -- Make the frame appear in front of other windows and accept user input
                frame:SetTitle("Select a sound:") -- Set the title of the frame

                -- Create a file browser inside the frame
                local browser = vgui.Create("DFileBrowser", frame)
                browser:Dock(FILL) -- Make the browser fill the entire frame
                -- Set the path that the browser should start in. "GAME" is a special path that refers to the game's root directory.
                browser:SetPath("GAME")
                -- Set the base folder to start searching to 'sound' (contains every sound from every addon/game)
                browser:SetBaseFolder("sound")
                browser:SetOpen(true) -- Show the folder as already open when the browser is created
                browser:SetFileTypes("*.wav *.mp3 *.ogg") -- Filter the file types that the browser should only display

                local s = nil -- Initialize a local var to hold the preview sound

                -- Define what should happen when a file is double-clicked in the browser
                browser.OnDoubleClick = function(panel, path)
                    if (s ~= nil) then s:Stop() end -- If a sound is currently playing, stop it
                    -- Select the sound and set it as the value of our ConVar, remove the "sound/" part from the path
                    path = string.Replace(path, "sound/", "")
                    musicEntry:SetText(path)
                    frame:Close() -- Close the frame
                end

                -- Define what should happen when a file is clicked in the browser
                browser.OnSelect = function(panel, path)
                    if (s ~= nil) then s:Stop() end -- If a sound is currently playing, stop it
                    s = CreateSound(LocalPlayer(),
                                    string.Replace(path, "sound/", "")) -- Create and play a new sound from the selected file
                    s:Play()
                end
            end

            -- Apply button to update the radius
            local applyButton = frame:Add("DButton")
            applyButton:SetText("Apply")
            applyButton:Dock(BOTTOM)

            -- Send updated effect radius to server when "Apply" is clicked
            applyButton.DoClick = function()
                local newName = zoneEntry:GetValue()
                local newMusic = musicEntry:GetValue()
                local newRadius = Vector(
                                      tonumber(xEntry:GetValue()) or
                                          ent.EffectRadius.x, tonumber(
                                          yEntry:GetValue()) or
                                          ent.EffectRadius.y, tonumber(
                                          zEntry:GetValue()) or
                                          ent.EffectRadius.z)

                ent.CustomTitle = newName
                ent.ZoneMusic = newMusic
                ent.EffectRadius = newRadius
                net.Start("UpdateZoneRadius")
                net.WriteEntity(ent)
                net.WriteString(newName)
                net.WriteString(newMusic)
                net.WriteVector(newRadius)
                net.SendToServer()
                frame:Close()
            end
        end
    })

    hook.Add("PopulateToolMenu", "ZoneCustomMenu", function()
        spawnmenu.AddToolMenuOption("Utilities", "Area Controls",
                                    "ZoneEntities", "Zone Entities", "", "",
                                    function(panel)
            if LocalPlayer():IsAdmin() then

                panel:ClearControls()
                panel:AddControl("Label",
                                 {Text = "Modify Zones Entities in World"})

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
                    for _, ent in ipairs(ents.FindByClass("custom_zone")) do
                        if IsValid(ent) then
                            local line =
                                zoneListView:AddLine(ent.CustomTitle or
                                                         ("Zone " ..
                                                             ent:EntIndex()))
                            line.index = ent:EntIndex()
                            line.ent = ent
                        end
                    end
                end

                updateItems()

                updateButton.DoClick = function() updateItems() end

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

                local musicLabel = vgui.Create("DLabel", panel)
                musicLabel:SetPos(10, verticalOffset + 160)
                musicLabel:SetText("Set Zone Music")
                musicLabel:SetSize(280, 20)

                local musicEntry = vgui.Create("DTextEntry", panel)
                musicEntry:SetPos(10, verticalOffset + 180)
                musicEntry:SetSize(280, 20)

                local musicButton = vgui.Create("DButton", panel)
                musicButton:SetPos(10, verticalOffset + 200)
                musicButton:SetText("Find Music")
                musicButton:SetSize(280, 20)

                -- This is all taken directly from the documentation in the gmod facepunch wiki honestly. All for DFileBrowser.
                musicButton.DoClick = function()
                    local frame = vgui.Create("DFrame")
                    frame:SetSize(500, 500) -- Set the size of the frame
                    frame:SetSizable(true) -- Allow the frame to be resizable
                    frame:Center() -- Center the frame on the screen
                    frame:MakePopup() -- Make the frame appear in front of other windows and accept user input
                    frame:SetTitle("Select a sound:") -- Set the title of the frame

                    -- Create a file browser inside the frame
                    local browser = vgui.Create("DFileBrowser", frame)
                    browser:Dock(FILL) -- Make the browser fill the entire frame
                    -- Set the path that the browser should start in. "GAME" is a special path that refers to the game's root directory.
                    browser:SetPath("GAME")
                    -- Set the base folder to start searching to 'sound' (contains every sound from every addon/game)
                    browser:SetBaseFolder("sound")
                    browser:SetOpen(true) -- Show the folder as already open when the browser is created
                    browser:SetFileTypes("*.wav *.mp3 *.ogg") -- Filter the file types that the browser should only display

                    local s = nil -- Initialize a local var to hold the preview sound

                    -- Define what should happen when a file is double-clicked in the browser
                    browser.OnDoubleClick =
                        function(panel, path)
                            if (s ~= nil) then
                                s:Stop()
                            end -- If a sound is currently playing, stop it
                            -- Select the sound and set it as the value of our ConVar, remove the "sound/" part from the path
                            path = string.Replace(path, "sound/", "")
                            musicEntry:SetText(path)
                            frame:Close() -- Close the frame
                        end

                    -- Define what should happen when a file is clicked in the browser
                    browser.OnSelect = function(panel, path)
                        if (s ~= nil) then s:Stop() end -- If a sound is currently playing, stop it
                        s = CreateSound(LocalPlayer(),
                                        string.Replace(path, "sound/", "")) -- Create and play a new sound from the selected file
                        s:Play()
                    end
                end

                -- Apply button to update the properties
                local applyButton = vgui.Create("DButton", panel)
                applyButton:SetPos(10, verticalOffset + 230)
                applyButton:SetSize(280, 20)
                applyButton:SetText("Apply")

                applyButton.DoClick = function()
                    local selectedLine = zoneListView:GetSelectedLine()
                    if selectedLine then
                        local ent = zoneListView:GetLine(selectedLine).ent
                        if IsValid(ent) then
                            local newName = zoneEntry:GetValue()
                            local newMusic = musicEntry:GetValue()
                            local newRadius = Vector(
                                                  tonumber(xEntry:GetValue()) or
                                                      100, tonumber(
                                                      yEntry:GetValue()) or 100,
                                                  tonumber(zEntry:GetValue()) or
                                                      100)

                            ent.CustomTitle = newName
                            ent.ZoneMusic = newMusic
                            ent.EffectRadius = newRadius
                            net.Start("UpdateZoneRadius")
                            net.WriteEntity(ent)
                            net.WriteString(newName)
                            net.WriteString(newMusic)
                            net.WriteVector(newRadius)
                            net.SendToServer()
                        end
                    end
                end

                -- This fills the entry fields for modification
                zoneListView.OnRowSelected =
                    function(_, index, row)
                        local ent = row.ent
                        if IsValid(ent) then
                            zoneEntry:SetValue(ent.CustomTitle or "Custom Zone")
                            xEntry:SetValue(ent.EffectRadius.x)
                            yEntry:SetValue(ent.EffectRadius.y)
                            zEntry:SetValue(ent.EffectRadius.z)
                            musicEntry:SetValue(ent.ZoneMusic)
                        end
                    end

                -- Remove button to delete the selected zone
                local removeButton = vgui.Create("DButton", panel)
                removeButton:SetPos(10, verticalOffset + 260) -- Adjust position as needed
                removeButton:SetSize(280, 20)
                removeButton:SetText("Remove Selected Zone")

                removeButton.DoClick = function()
                    local selectedLine = zoneListView:GetSelectedLine()
                    if selectedLine then
                        local ent = zoneListView:GetLine(selectedLine).ent
                        if IsValid(ent) then
                            -- Inform the server to remove the entity
                            net.Start("RemoveZone")
                            net.WriteEntity(ent)
                            net.SendToServer()

                            zoneListView:RemoveLine(selectedLine)

                            zoneEntry:SetValue()
                            xEntry:SetValue(0)
                            yEntry:SetValue(0)
                            zEntry:SetValue(0)
                            musicEntry:SetValue(0)
                        end
                    end
                end

                local persistButton = vgui.Create("DButton", panel)
                persistButton:SetPos(10, verticalOffset + 290) -- Position it below the Apply button
                persistButton:SetSize(280, 20)
                persistButton:SetText("Persist All Zones")

                persistButton.DoClick = function()
                    net.Start("PersistZones")
                    net.SendToServer()
                end

                local unpersistButton = vgui.Create("DButton", panel)
                unpersistButton:SetPos(10, verticalOffset + 310) -- Position it below the Apply button
                unpersistButton:SetSize(280, 20)
                unpersistButton:SetText("Unpersist All Zones")

                unpersistButton.DoClick = function()
                    net.Start("UnpersistZones")
                    net.SendToServer()
                end

            else
                panel:ClearControls()
                panel:AddControl("Label", {
                    Text = "Modify Custom Zone Entities in World... If you were an Admin. Lmao."
                })
            end

        end)

    end)

    net.Receive("PlayerZonesSync", function()
        local index = net.ReadInt(32)
        local newName = net.ReadString()
        local newMusic = net.ReadString()
        local newRadius = net.ReadVector()

        timer.Simple(2, function()
            local ent = Entity(index)

            if IsValid(ent) and ent:GetClass() == "custom_zone" then
                ent.CustomTitle = newName
                ent.ZoneMusic = newMusic
                ent.EffectRadius = newRadius
            end
        end)
    end)

    net.Receive("ZoneEntered", function()
        local title = net.ReadString()
        local musicPath = net.ReadString()
        local fadeDuration = 10
        local fadeInDuration = 3
        local textAlpha = 0

        hook.Remove("HUDPaint", "DrawZoneTitle")

        -- Stop any existing timers related to the title
        timer.Remove("TextFadeIn")
        timer.Remove("TextFadeOut")
        timer.Remove("FadeDuration")

        timer.Create("TextFadeIn", 0.05, fadeDuration / 0.05, function()
            if textAlpha < 255 then textAlpha = textAlpha + 5 end
        end)

        hook.Add("HUDPaint", "DrawZoneTitle", function()
            draw.SimpleText(title, "LargeTrebuchet", ScrW() / 2,
                            (ScrH() / 2) - 250, Color(255, 255, 255, textAlpha),
                            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end)

        timer.Create("FadeDuration", 0.05, fadeDuration / 0.05, function()
            timer.Create("TextFadeOut", 0.05, fadeInDuration / 0.05, function()
                if textAlpha > 50 then
                    textAlpha = textAlpha - 15 -- Decrease text opacity gradually
                else
                    -- Remove the text once fully faded out
                    hook.Remove("HUDPaint", "DrawZoneTitle")
                end
            end)
        end)

        if not musicEnabled then return end

        if SMT_MusicState.InFight then return end

        if SMT_MusicState.Playing and
            SMT_MusicState.Playing:GetFileName() == "sound/" .. musicPath or
            musicPath == "" then return end

        local volume = GetConVar("music_volume"):GetFloat()

        -- Fade out the currently playing music if something else is playing
        if SMT_MusicState.Playing then
            for i = 1, 10 do
                timer.Simple(i * 0.1, function()
                    if IsValid(SMT_MusicState.Playing) then
                        SMT_MusicState.Playing:SetVolume(volume * (1 - i / 10))
                    end
                end)
            end
            -- TERMINATE the old music after fade-out and play that new jam
            timer.Simple(1, function()
                if IsValid(SMT_MusicState.Playing) then
                    SMT_MusicState.Playing:Stop()
                end
                -- Play the new music with a fade-in effect by increasing the volume gradually
                sound.PlayFile("sound/" .. musicPath, "noblock",
                               function(station)
                    if IsValid(station) then
                        SMT_MusicState.Playing = station
                        station:SetVolume(0)
                        station:EnableLooping(true)
                        station:Play()
                        -- Fade-in but I lie as it just increases the volume.
                        for i = 1, 10 do
                            timer.Simple(i * 0.1, function()
                                if IsValid(station) then
                                    station:SetVolume(volume * (i / 10))
                                end
                            end)
                        end

                        SMT_MusicState.ZoneMusic = station:GetFileName()
                    end
                end)
            end)
        else
            -- If no music is currently playing, play the new music NOW
            sound.PlayFile("sound/" .. musicPath, "noblock", function(station)
                if IsValid(station) then
                    SMT_MusicState.Playing = station
                    station:SetVolume(0)
                    station:EnableLooping(true)
                    station:Play()
                    -- Fade-in but I lie as it just increases the volume.
                    for i = 1, 10 do
                        timer.Simple(i * 0.1, function()
                            if IsValid(station) then
                                station:SetVolume(volume * (i / 10))
                            end
                        end)
                    end

                    SMT_MusicState.ZoneMusic = station:GetFileName()
                end
            end)
        end
    end)

    hook.Add("PlayerDeath", "ResetOnDeath",
             function(victim, inflictor, attacker)
        SMT_MusicState.Playing = ""
    end)

    concommand.Add("getMeter", function(ply)
        -- Get the player's position
        local playerPos = ply:GetPos()

        -- Perform a trace to get the position of the object the player is looking at
        local trace = ply:GetEyeTrace()

        -- Get the hit position from the trace
        local hitPos = trace.HitPos

        -- Calculate the distance between the player's position and the hit position
        local distance = playerPos:Distance(hitPos)

        -- Convert the distance from source units to meters
        -- Source units: 1 unit = 0.01905 meters
        local distanceInMeters = distance * 0.01905

        -- Print the result in the console
        print(string.format("Distance: %.2f meters", distanceInMeters))
    end)

end
