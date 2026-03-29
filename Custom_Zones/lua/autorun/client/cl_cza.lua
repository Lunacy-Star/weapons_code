AddCSLuaFile()

if CLIENT then
    surface.CreateFont("LargeTrebuchet", {
        font = "Trebuchet24",
        size = 48,
        weight = 500,
        antialias = true,
        shadow = true
    })

    local musicEnabledConVar = CreateClientConVar("area_music_enabled", "1",
                                                  true, false,
                                                  "Toggle area music on or off")
    local selectedBattleMusicConVar = CreateClientConVar(
                                          "selected_battle_music", "Random",
                                          true, false,
                                          "Stores the selected battle music.")
    local selectedVictoryMusicConVar = CreateClientConVar(
                                           "selected_victory_music", "Random",
                                           true, false,
                                           "Stores the selected victory music.")
    CreateClientConVar("music_volume", "1", true, false,
                       "Adjust the battle music volume between 0 (mute) and 1 (full volume)")

    local musicEnabled = musicEnabledConVar:GetBool()
    local musicPlaying
    local zoneMusic
    local inAFight = false

    cvars.AddChangeCallback("area_music_enabled",
                            function(convar_name, value_old, value_new)
        if value_new == "1" then
            musicEnabled = true
        elseif value_new == "0" then
            if IsValid(musicPlaying) then
                musicPlaying:Stop()
                musicPlaying = nil
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

        if inAFight then return end

        if musicPlaying and musicPlaying:GetFileName() == "sound/" .. musicPath or
            musicPath == "" then return end

        local volume = GetConVar("music_volume"):GetFloat()

        -- Fade out the currently playing music if something else is playing
        if musicPlaying then
            for i = 1, 10 do
                timer.Simple(i * 0.1, function()
                    if IsValid(musicPlaying) then
                        musicPlaying:SetVolume(volume * (1 - i / 10))
                    end
                end)
            end
            -- TERMINATE the old music after fade-out and play that new jam
            timer.Simple(1, function()
                if IsValid(musicPlaying) then musicPlaying:Stop() end
                -- Play the new music with a fade-in effect by increasing the volume gradually
                sound.PlayFile("sound/" .. musicPath, "noblock",
                               function(station)
                    if IsValid(station) then
                        musicPlaying = station
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

                        zoneMusic = station:GetFileName()
                    end
                end)
            end)
        else
            -- If no music is currently playing, play the new music NOW
            sound.PlayFile("sound/" .. musicPath, "noblock", function(station)
                if IsValid(station) then
                    musicPlaying = station
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

                    zoneMusic = station:GetFileName()
                end
            end)
        end
    end)

    hook.Add("PlayerDeath", "ResetOnDeath",
             function(victim, inflictor, attacker) musicPlaying = "" end)

    -- This is extra added exclusively for turn based combat. 

    local AvailableBattleMusic = {
        ["Random"] = "Random",
        ["Maken X - Washington"] = "Music/Maken X - Washington.ogg",
        ["Maken X - Transylvania"] = "Music/Maken X - Transylvania.ogg",
        ["P1 - A Lone Prayer"] = "Music/P1 - A Lone Prayer.ogg",
        ["P1 - Bloody Destiny"] = "Music/P1 - Bloody Destiny.ogg",
        ["P1 - Normal Battle -P5 Strikers Refined Mix-"] = "Music/P1 - Normal Battle -P5 Strikers Refined Mix-.ogg",
        ["P2IS - Battle"] = "Music/P2IS - Battle.ogg",
        ["P3 - Mass Destruction"] = "Music/P3 - Mass Destruction.ogg",
        ["P3R - It's Going Down Now"] = "Music/P3R - It's Going Down Now.ogg",
        ["P3R - Mass Destruction -Reload-"] = "Music/P3R - Mass Destruction -Reload-.ogg",
        ["P4 - Reach Out To The Truth -First Battle-"] = "Music/P4 - Reach Out To The Truth -First Battle-.ogg",
        ["P4 - Reach Out To The Truth"] = "Music/P4 - Reach Out To The Truth.ogg",
        ["P4 - Time to Make History -special mix-"] = "Music/P4 - Time to Make History -special mix-.ogg",
        ["P5 - Last Surprise"] = "Music/P5 - Last Surprise.ogg",
        ["P5R - Take Over"] = "Music/P5R - Take Over.ogg",
        ["P5S - Axe to Grind"] = "Music/P5S - Axe to Grind.ogg",
        ["P5S - You Are Stronger -Instrumental-"] = "Music/P5S - You Are Stronger -Instrumental-.ogg",
        ["P5S - You Are Stronger"] = "Music/P5S - You Are Stronger.ogg",
        ["SMT Imagine - Battle B"] = "Music/SMT Imagine - Battle B.ogg",
        ["SMT Imagine - Battle New"] = "Music/SMT Imagine - Battle New.ogg",
        ["SMT Imagine - Battle"] = "Music/SMT Imagine - Battle.ogg",
        ["SMT Strange Journey - Fear of God -25th Anniversary Mix-"] = "Music/SMT Strange Journey - Fear of God -25th Anniversary Mix-.ogg",
        ["SMT Strange Journey - Fear of God"] = "Music/SMT Strange Journey - Fear of God.ogg",
        ["SMT1 - Ginza -25th Anniversary Mix-"] = "Music/SMT1 - Ginza -25th Anniversary Mix-.ogg",
        ["SMT3 - Common Battle -Amala Network-"] = "Music/SMT3 - Common Battle -Amala Network-.ogg",
        ["SMT3 - Common Battle Medley"] = "Music/SMT3 - Common Battle Medley.ogg",
        ["SMT3 - Common Battle -The Depths of Amala-"] = "Music/SMT3 - Common Battle -The Depths of Amala-.ogg",
        ["SMT3 - Common Battle"] = "Music/SMT3 - Common Battle.ogg",
        ["SMT4 - Battle-a1"] = "Music/SMT4 - Battle-a1.ogg",
        ["SMT4 - Battle-a2"] = "Music/SMT4 - Battle-a2.ogg",
        ["SMT4 - Battle-c1"] = "Music/SMT4 - Battle-c1.ogg",
        ["SMTDx2 - Downloader"] = "Music/SMTDx2 - Downloader.ogg",
        ["SMTDx2 - Normal Battle"] = "Music/SMTDx2 - Normal Battle.ogg",
        ["SMTif - Nemesis -Old Enemy-"] = "Music/SMTif - Nemesis -Old Enemy-.ogg",
        ["Soul Hackers - Common Battle -Hellion Sounds Cover-"] = "Music/Soul Hackers - Common Battle -Hellion Sounds Cover-.ogg",
        ["Soul Hackers - Event Battle 2 -Arranged-"] = "Music/Soul Hackers - Event Battle 2 -Arranged-.ogg",
        ["Soul Hackers - Normal Battle -Arranged-"] = "Music/Soul Hackers - Normal Battle -Arranged-.ogg",
        ["Soul Hackers - Normal Battle -MONACA Arrangement-"] = "Music/Soul Hackers - Normal Battle -MONACA Arrangement-.ogg",
        ["Soul Hackers 2 - Normal Battle"] = "Music/Soul Hackers 2 - Normal Battle.ogg"
    }

    local AvailableVictoryMusic = {
        ["Random"] = "Random",
        ["P3R - After the Battle"] = "Music/P3R - After the Battle.ogg",
        ["P4 - Results"] = "Music/P4 - Results.ogg",
        ["P5 - Victory"] = "Music/P5 - Victory.ogg",
        ["SH2 - Victory"] = "Music/SH2 - Victory.ogg",
        ["SMT Imagine - Death -Game Over-"] = "Music/SMT Imagine - Death -Game Over-.ogg",
        ["SMT3 - Game Over"] = "Music/SMT3 - Game Over.ogg",
        ["SMT3 - Level Up"] = "Music/SMT3 - Level Up.ogg",
        ["SMT3 - What I've Done"] = "Music/SMT3 - What I've Done.mp3",
        ["SMT4 - Battle Over"] = "Music/SMT4 - Battle Over.ogg"
    }

    -- Create the tool menu with the dropdown for music selection
    hook.Add("PopulateToolMenu", "BattleMusicMenu", function()
        spawnmenu.AddToolMenuOption("Options", "Nara Configuration",
                                    "BattleConfig", "Battle Configuration", "",
                                    "", function(panel)

            panel:ClearControls()
            panel:AddControl("Label", {Text = "Configure Battle Settings"})

            local battleMusicDropdown = panel:ComboBox("Select Battle Music",
                                                       "selected_battle_music")

            for title, path in pairs(AvailableBattleMusic) do
                battleMusicDropdown:AddChoice(title, path)
            end

            battleMusicDropdown.OnSelect =
                function(_, _, value)
                    RunConsoleCommand("selected_battle_music", value)
                    if inAFight then PlayBattleMusic() end
                end

            local victoryMusicDropdown =
                panel:ComboBox("Select Victory Music", "selected_victory_music")

            for title, path in pairs(AvailableVictoryMusic) do
                victoryMusicDropdown:AddChoice(title, path)
            end

            victoryMusicDropdown.OnSelect =
                function(_, _, value)
                    RunConsoleCommand("selected_victory_music", value)
                end

            panel:NumSlider("Music Volume (This also affects Area Music)",
                            "music_volume", 0, 1, 2)

            cvars.AddChangeCallback("music_volume", function(_, _, newVolume)
                if IsValid(musicPlaying) then
                    musicPlaying:SetVolume(tonumber(newVolume))
                end
            end)
        end)
    end)

    function PlayBattleMusic()
        local musicPath = GetConVar("selected_battle_music"):GetString() or
                              "Random"

        if musicPath == "Random" or musicPath == "" then
            -- Create a temporary table excluding the "Random" key
            local validChoices = {}
            for key, path in pairs(AvailableBattleMusic) do
                if key ~= "Random" then
                    table.insert(validChoices, path)
                end
            end
            -- Pick a random music path from the valid choices
            musicPath = validChoices[math.random(1, #validChoices)]
        elseif musicPath then
            musicPath = AvailableBattleMusic[musicPath]
        end

        if zoneMusic == ("sound/" .. musicPath) then
            inAFight = true
            return
        end
        local volume = GetConVar("music_volume"):GetFloat()
        inAFight = true

        if IsValid(musicPlaying) then musicPlaying:Stop() end
        if musicPath and musicPath ~= "" then
            sound.PlayFile("sound/" .. musicPath, "noblock", function(station)
                if IsValid(station) then
                    musicPlaying = station
                    station:SetVolume(volume)
                    station:EnableLooping(true)
                    station:Play()
                end
            end)
        end
    end

    function PlayVictoryMusic()
        local battlePath = GetConVar("selected_battle_music"):GetString() or
                               "Random"

        if battlePath and battlePath ~= "Random" or battlePath ~= "" then
            battlePath = AvailableBattleMusic[battlePath]
        end

        if zoneMusic == ("sound/" .. battlePath) then
            inAFight = false
            return
        end

        if not musicEnabled then
            inAFight = false
            return
        end

        local musicPath = GetConVar("selected_victory_music"):GetString() or
                              "Random"

        if musicPath == "Random" or musicPath == "" then
            -- Create a temporary table excluding the "Random" key
            local validChoices = {}
            for key, path in pairs(AvailableVictoryMusic) do
                if key ~= "Random" then
                    table.insert(validChoices, path)
                end
            end
            -- Pick a random music path from the valid choices
            musicPath = validChoices[math.random(1, #validChoices)]
        elseif musicPath then
            musicPath = AvailableVictoryMusic[musicPath]
        end

        local volume = GetConVar("music_volume"):GetFloat()

        if IsValid(musicPlaying) then musicPlaying:Stop() end
        if musicPath and musicPath ~= "" then
            sound.PlayFile("sound/" .. musicPath, "noblock", function(station)
                if IsValid(station) then
                    musicPlaying = station
                    station:SetVolume(volume)
                    -- station:EnableLooping(true)
                    station:Play()

                    timer.Create("MusicEndTrigger", 15, 1, function()
                        inAFight = false

                        if not zoneMusic then return end

                        if musicPlaying and musicPlaying:GetFileName() ==
                            "sound/" .. zoneMusic or zoneMusic == "" then
                            return
                        end
                        for i = 1, 10 do
                            timer.Simple(i * 0.1, function()
                                if IsValid(musicPlaying) then
                                    musicPlaying:SetVolume(volume * (1 - i / 10))
                                end
                            end)
                        end
                        -- TERMINATE the old music after fade-out and play that new jam
                        timer.Simple(1, function()
                            if IsValid(musicPlaying) then
                                musicPlaying:Stop()
                            end
                            -- Play the new music with a fade-in effect by increasing the volume gradually
                            sound.PlayFile(zoneMusic, "noblock",
                                           function(station2)
                                if IsValid(station2) then
                                    musicPlaying = station2
                                    station2:SetVolume(0)
                                    station2:EnableLooping(true)
                                    station2:Play()
                                    -- Fade-in but I lie as it just increases the volume.
                                    for i = 1, 10 do
                                        timer.Simple(i * 0.1, function()
                                            if IsValid(station2) then
                                                station2:SetVolume(
                                                    volume * (i / 10))
                                            end
                                        end)
                                    end

                                    zoneMusic = station2:GetFileName()
                                end
                            end)
                        end)
                    end)

                end
            end)
        end
    end

    function EndFightMusic()
        local battlePath = GetConVar("selected_battle_music"):GetString() or
                               "Random"
        if battlePath and battlePath ~= "Random" or battlePath ~= "" then
            battlePath = AvailableBattleMusic[battlePath]
        end

        if zoneMusic == ("sound/" .. battlePath) then
            inAFight = false
            return
        end

        if not musicEnabled then
            inAFight = false
            return
        end

        local musicPath = zoneMusic
        local volume = GetConVar("music_volume"):GetFloat()
        inAFight = false

        if IsValid(musicPlaying) then musicPlaying:Stop() end
        if musicPath and musicPath ~= "" then
            sound.PlayFile(musicPath, "noblock", function(station)
                if IsValid(station) then
                    musicPlaying = station
                    station:SetVolume(volume)
                    station:EnableLooping(true)
                    station:Play()

                    zoneMusic = station:GetFileName()

                end
            end)
        end
    end

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
