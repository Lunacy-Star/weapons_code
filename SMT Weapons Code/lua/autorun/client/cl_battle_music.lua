AddCSLuaFile()

-- Turn-based-combat battle/victory music. Fully standalone: does not require
-- the Custom_Zones addon or any custom_zone entity to exist. Shares state
-- with Custom_Zones' ambient area music (if that addon is loaded) through the
-- SMT_MusicState global table, so the two systems can hand off to one
-- another, but neither requires the other to function.

if CLIENT then
    SMT_MusicState = SMT_MusicState or {
        Playing = nil, -- currently playing IGModAudioChannel (battle, victory, or ambient zone track)
        ZoneMusic = nil, -- filepath of the ambient track for the zone the player is currently in, if any
        InFight = false
    }

    CreateClientConVar("area_music_enabled", "1", true, false,
                       "Toggle area music on or off")
    CreateClientConVar("music_volume", "1", true, false,
                       "Adjust the battle music volume between 0 (mute) and 1 (full volume)")
    CreateClientConVar("selected_battle_music", "Random", true, false,
                       "Stores the selected battle music.")
    CreateClientConVar("selected_victory_music", "Random", true, false,
                       "Stores the selected victory music.")

    -- Entries stay commented out until the matching file is dropped into
    -- SMT Sound Content/sound/Music/ under that exact name -- uncomment once added.
    SMT_AvailableBattleMusic = {
        ["Random"] = "Random",
        -- ["Maken X - Washington"] = "Music/Maken X - Washington.ogg",
        ["Maken X - Transylvania"] = "Music/Maken X - Transylvania.ogg",
        ["P1 - A Lone Prayer"] = "Music/P1 - A Lone Prayer.mp3",
        ["P1 - Bloody Destiny"] = "Music/P1 - Bloody Destiny.ogg",
        ["P1 - Normal Battle -P5 Strikers Refined Mix-"] = "Music/P1 - Normal Battle -P5 Strikers Refined Mix-.ogg",
        -- ["P2IS - Battle"] = "Music/P2IS - Battle.ogg",
        ["P3 - Mass Destruction"] = "Music/P3 - Mass Destruction.ogg",
        ["P3R - It's Going Down Now"] = "Music/P3R - It's Going Down Now.ogg",
        -- ["P3R - Mass Destruction -Reload-"] = "Music/P3R - Mass Destruction -Reload-.ogg",
        ["P4 - Reach Out To The Truth -First Battle-"] = "Music/P4 - Reach Out To The Truth -First Battle-.ogg",
        ["P4 - Reach Out To The Truth"] = "Music/P4 - Reach Out To The Truth.ogg",
        ["P4 - Time to Make History -special mix-"] = "Music/P4 - Time to Make History -special mix-.ogg",
        ["P5 - Last Surprise"] = "Music/P5 - Last Surprise.ogg",
        ["P5R - Take Over"] = "Music/P5R - Take Over.ogg",
        ["P5S - Axe to Grind"] = "Music/P5S - Axe to Grind.ogg",
        ["P5S - You Are Stronger -Instrumental-"] = "Music/P5S - You Are Stronger -Instrumental-.ogg",
        ["P5S - You Are Stronger"] = "Music/P5S - You Are Stronger.ogg",
        -- ["SMT Imagine - Battle B"] = "Music/SMT Imagine - Battle B.ogg",
        ["SMT Imagine - Battle New"] = "Music/SMT Imagine - Battle New.ogg",
        -- ["SMT Imagine - Battle"] = "Music/SMT Imagine - Battle.ogg",
        -- ["SMT Strange Journey - Fear of God -25th Anniversary Mix-"] = "Music/SMT Strange Journey - Fear of God -25th Anniversary Mix-.ogg",
        ["SMT Strange Journey - Fear of God"] = "Music/SMT Strange Journey - Fear of God.ogg",
        ["SMT1 - Ginza -25th Anniversary Mix-"] = "Music/SMT1 - Ginza -25th Anniversary Mix-.ogg",
        ["SMT3 - Common Battle -Amala Network-"] = "Music/SMT3 - Common Battle -Amala Network-.ogg",
        -- ["SMT3 - Common Battle Medley"] = "Music/SMT3 - Common Battle Medley.ogg",
        ["SMT3 - Common Battle -The Depths of Amala-"] = "Music/SMT3 - Common Battle -The Depths of Amala-.ogg",
        ["SMT3 - Common Battle"] = "Music/SMT3 - Common Battle.ogg",
        ["SMT4 - Battle-a1"] = "Music/SMT4 - Battle-a1.ogg",
        ["SMT4 - Battle-a2"] = "Music/SMT4 - Battle-a2.ogg",
        ["SMT4 - Battle-c1"] = "Music/SMT4 - Battle-c1.ogg",
        -- ["SMTDx2 - Downloader"] = "Music/SMTDx2 - Downloader.ogg",
        ["SMTDx2 - Normal Battle"] = "Music/SMTDx2 - Normal Battle.ogg",
        ["SMTif - Nemesis -Old Enemy-"] = "Music/SMTif - Nemesis -Old Enemy-.ogg",
        ["Soul Hackers - Common Battle -Hellion Sounds Cover-"] = "Music/Soul Hackers - Common Battle -Hellion Sounds Cover-.ogg",
        ["Soul Hackers - Event Battle 2 -Arranged-"] = "Music/Soul Hackers - Event Battle 2 -Arranged-.ogg",
        ["Soul Hackers - Normal Battle -Arranged-"] = "Music/Soul Hackers - Normal Battle -Arranged-.ogg",
        -- ["Soul Hackers - Normal Battle -MONACA Arrangement-"] = "Music/Soul Hackers - Normal Battle -MONACA Arrangement-.ogg",
        -- ["Soul Hackers 2 - Normal Battle"] = "Music/Soul Hackers 2 - Normal Battle.ogg"
    }

    SMT_AvailableVictoryMusic = {
        ["Random"] = "Random",
        ["P3R - After the Battle"] = "Music/P3R - After the Battle.ogg",
        ["P4 - Results"] = "Music/P4 - Results.ogg",
        ["P5 - Victory"] = "Music/P5 - Victory.ogg",
        -- ["SH2 - Victory"] = "Music/SH2 - Victory.ogg",
        -- ["SMT Imagine - Death -Game Over-"] = "Music/SMT Imagine - Death -Game Over-.ogg",
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

            for title, path in pairs(SMT_AvailableBattleMusic) do
                battleMusicDropdown:AddChoice(title, path)
            end

            battleMusicDropdown.OnSelect =
                function(_, _, value)
                    RunConsoleCommand("selected_battle_music", value)
                    if SMT_MusicState.InFight then PlayBattleMusic() end
                end

            local victoryMusicDropdown =
                panel:ComboBox("Select Victory Music", "selected_victory_music")

            for title, path in pairs(SMT_AvailableVictoryMusic) do
                victoryMusicDropdown:AddChoice(title, path)
            end

            victoryMusicDropdown.OnSelect =
                function(_, _, value)
                    RunConsoleCommand("selected_victory_music", value)
                end

            panel:NumSlider("Music Volume (This also affects Area Music)",
                            "music_volume", 0, 1, 2)
        end)
    end)

    cvars.AddChangeCallback("music_volume", function(_, _, newVolume)
        if IsValid(SMT_MusicState.Playing) then
            SMT_MusicState.Playing:SetVolume(tonumber(newVolume))
        end
    end, "SMT_BattleMusicVolume")

    function PlayBattleMusic()
        local musicPath = GetConVar("selected_battle_music"):GetString() or
                              "Random"

        if musicPath == "Random" or musicPath == "" then
            -- Create a temporary table excluding the "Random" key
            local validChoices = {}
            for key, path in pairs(SMT_AvailableBattleMusic) do
                if key ~= "Random" then
                    table.insert(validChoices, path)
                end
            end
            -- Pick a random music path from the valid choices
            musicPath = validChoices[math.random(1, #validChoices)]
        elseif musicPath then
            musicPath = SMT_AvailableBattleMusic[musicPath]
        end

        if SMT_MusicState.ZoneMusic == ("sound/" .. musicPath) then
            SMT_MusicState.InFight = true
            return
        end
        local volume = GetConVar("music_volume"):GetFloat()
        SMT_MusicState.InFight = true

        if IsValid(SMT_MusicState.Playing) then SMT_MusicState.Playing:Stop() end
        if musicPath and musicPath ~= "" then
            sound.PlayFile("sound/" .. musicPath, "noblock", function(station)
                if IsValid(station) then
                    SMT_MusicState.Playing = station
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
            battlePath = SMT_AvailableBattleMusic[battlePath]
        end

        if SMT_MusicState.ZoneMusic == ("sound/" .. battlePath) then
            SMT_MusicState.InFight = false
            return
        end

        if not GetConVar("area_music_enabled"):GetBool() then
            SMT_MusicState.InFight = false
            return
        end

        local musicPath = GetConVar("selected_victory_music"):GetString() or
                              "Random"

        if musicPath == "Random" or musicPath == "" then
            -- Create a temporary table excluding the "Random" key
            local validChoices = {}
            for key, path in pairs(SMT_AvailableVictoryMusic) do
                if key ~= "Random" then
                    table.insert(validChoices, path)
                end
            end
            -- Pick a random music path from the valid choices
            musicPath = validChoices[math.random(1, #validChoices)]
        elseif musicPath then
            musicPath = SMT_AvailableVictoryMusic[musicPath]
        end

        local volume = GetConVar("music_volume"):GetFloat()

        if IsValid(SMT_MusicState.Playing) then SMT_MusicState.Playing:Stop() end
        if musicPath and musicPath ~= "" then
            sound.PlayFile("sound/" .. musicPath, "noblock", function(station)
                if IsValid(station) then
                    SMT_MusicState.Playing = station
                    station:SetVolume(volume)
                    -- station:EnableLooping(true)
                    station:Play()

                    timer.Create("MusicEndTrigger", 15, 1, function()
                        SMT_MusicState.InFight = false

                        if not SMT_MusicState.ZoneMusic then return end

                        if SMT_MusicState.Playing and
                            SMT_MusicState.Playing:GetFileName() ==
                            "sound/" .. SMT_MusicState.ZoneMusic or
                            SMT_MusicState.ZoneMusic == "" then
                            return
                        end
                        for i = 1, 10 do
                            timer.Simple(i * 0.1, function()
                                if IsValid(SMT_MusicState.Playing) then
                                    SMT_MusicState.Playing:SetVolume(
                                        volume * (1 - i / 10))
                                end
                            end)
                        end
                        -- TERMINATE the old music after fade-out and play that new jam
                        timer.Simple(1, function()
                            if IsValid(SMT_MusicState.Playing) then
                                SMT_MusicState.Playing:Stop()
                            end
                            -- Play the new music with a fade-in effect by increasing the volume gradually
                            sound.PlayFile(SMT_MusicState.ZoneMusic, "noblock",
                                           function(station2)
                                if IsValid(station2) then
                                    SMT_MusicState.Playing = station2
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

                                    SMT_MusicState.ZoneMusic =
                                        station2:GetFileName()
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
            battlePath = SMT_AvailableBattleMusic[battlePath]
        end

        if SMT_MusicState.ZoneMusic == ("sound/" .. battlePath) then
            SMT_MusicState.InFight = false
            return
        end

        if not GetConVar("area_music_enabled"):GetBool() then
            SMT_MusicState.InFight = false
            return
        end

        local musicPath = SMT_MusicState.ZoneMusic
        local volume = GetConVar("music_volume"):GetFloat()
        SMT_MusicState.InFight = false

        if IsValid(SMT_MusicState.Playing) then SMT_MusicState.Playing:Stop() end
        if musicPath and musicPath ~= "" then
            sound.PlayFile(musicPath, "noblock", function(station)
                if IsValid(station) then
                    SMT_MusicState.Playing = station
                    station:SetVolume(volume)
                    station:EnableLooping(true)
                    station:Play()

                    SMT_MusicState.ZoneMusic = station:GetFileName()

                end
            end)
        end
    end
end
