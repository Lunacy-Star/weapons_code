if CLIENT then
    ---------------------------------------------------------------------------------- variables which will be reset after death
    local start = SysTime()
    local goTime = false
    local didfadeout = false
    local didfadein = false
    local finishfadeout = false
    local songplay = false
    local timerfadeout_started = false
    local goTimer_started = false
    local creditsTimer_started = false
    local VinceTimer_started = false
    local GoVince = false
    local GoAwayVince = false
    local traced = false
    local resetAllVariables = true
    local zoomoutspeedOffset = Vector(0,0,5)
    ---------------------------------------------------------------------------------- misc variables
    local BabyBlue = Sound("waltuh/game_over.mp3")
    local moddedragdoll = nil
    local Vince = Material("credits/fk.png")
    ---------------------------------------------------------------------------------- CreatingConsole Variables
    -- ConVar CreateClientConVar( string name, string default, boolean shouldsave = true, boolean userinfo = false, string helptext, number min = nil, number max = nil )
    --local convarfadeoutspeed = CreateClientConVar("waltuh_fadeout_time", 2, true, false, "Changes the time until the screen goes completely black before the zoomout, in seconds (This is not for how long the screen stays blank, for that, see waltuh_time_faded)", 0, 4)
    --local convarfadeinspeed = CreateClientConVar("waltuh_fadein_time", 1.5, true, false, "Changes the time when the screen fades from being no longer black, in seconds (This is not for how long the screen stays blank, for that, see waltuh_time_faded)", 0, 60)
    --local convartimefaded = CreateClientConVar("waltuh_time_faded", 5, true, false, "Changes the amount of time the screen is faded, before the screen unfades and the zoomout begins, in seconds", 0.01, 4)
    --local convarzoomoutwait = CreateClientConVar("waltuh_zoomout_wait", 1, true, false, "Changes the amount of the time, where the camera is facing the player's head, but not zooming out yet, in seconds", 0.01, 500)
    local convarzoomspeed = CreateClientConVar("waltuh_zoomout_speed", 5, true, false, "Changes the zoomout speed, therefore also affecting the total distance travalled upwards (Will have no effect when the addon is trying to prevent clipping through ceilings)", 0.01, 5000)
    local convarzoomouttime = CreateClientConVar("waltuh_zoomout_time", 55, true, false, "Changes the amount time the camera zooms out for, starting from the exact point of death, in seconds", 0.01, 600)
    local convarturnangle = CreateClientConVar("waltuh_turn_angle", 225, true, false, "The total angle, in degrees, the camera will turn)", 0, 360)
    local convarturnspeed = CreateClientConVar("waltuh_turn_speed", 55, true, false, "Changes the speed at which the camera will turn until it reaches it's intended angle, to increase the angle, use waltuh_turn_angle", 0.01, 500)
    local convarIsEnabled = CreateClientConVar("Waltuh_IsEnabled", 1, true, false, "1 if enabled, 0 if disabled", 0, 1)
    local convarSongEnabled = CreateClientConVar("Waltuh_song_IsEnabled", 1, true, false, "1 if enabled, 0 if disabled", 0, 1)
    local convarAllowClipping = CreateClientConVar("Waltuh_allow_clipping", 0, true, false, "1 if clipping is allowed, 0 if it's not", 0, 1)
    ---------------------------------------------------------------------------------- Default values of the convars
    local fadeouttime = 2
    local fadeintime = 1.5
    local zoomouttime = 55
    local zoomoutspeed = Vector(0,0,5)
    local zfix = Vector(0,0,5)
    local timefaded = 5
    local finalangle = Angle(90,0,225)
    local turnspeed = 55
    local IsEnabled = true
    local SongEnabled = true
    ---------------------------------------------------------------------------------- Convars now changed by the player, in console or in the options menu
    /*
    cvars.AddChangeCallback("waltuh_fadeout_time", function(convar_name, value_old, value_new)
        fadeouttime = tonumber(value_new)
        gotimetime = 8 - ( fadeouttime + timefaded)
        print(gotimetime)
    end)

    cvars.AddChangeCallback("waltuh_fadein_time", function(convar_name, value_old, value_new)
        fadeintime = tonumber(value_new)
    end)

    cvars.AddChangeCallback("waltuh_time_faded", function(convar_name, value_old, value_new)
        timefaded = tonumber(value_new)
        gotimetime = 8 -( fadeouttime + timefaded)
    end)
    cvars.AddChangeCallback("waltuh_zoomout_wait", function(convar_name, value_old, value_new)
        gotimetime = tonumber(value_new)
    end
    */

    cvars.AddChangeCallback("waltuh_zoomout_time", function(convar_name, value_old, value_new)
        zoomouttime = tonumber(value_new)
    end)
    cvars.AddChangeCallback("waltuh_zoomout_speed", function(convar_name, value_old, value_new)
        zoomoutspeed = Vector (0,0,tonumber(value_new))
        zfix = Vector (0,0,tonumber(value_new))
    end)
    cvars.AddChangeCallback("waltuh_turn_angle", function(convar_name, value_old, value_new)
        finalangle = Angle(90,0,tonumber(value_new))
    end)
    cvars.AddChangeCallback("waltuh_turn_speed", function(convar_name, value_old, value_new)
        turnspeed = tonumber(value_new)
    end)
    cvars.AddChangeCallback("Waltuh_IsEnabled", function(convar_name, value_old, value_new)
        if value_new == "1" then
            IsEnabled = true
        elseif value_new == "0" then
            IsEnabled = false
        end;
    end)
    cvars.AddChangeCallback("Waltuh_song_IsEnabled", function(convar_name, value_old, value_new)
        if value_new == "1" then
            SongEnabled = true
        elseif value_new == "0" then
            RunConsoleCommand("stopsound")
            SongEnabled = false
        end;
    end)
    cvars.AddChangeCallback("Waltuh_allow_clipping", function(convar_name, value_old, value_new)
        if value_new == "1" then
            AllowClipping = true
        elseif value_new == "0" then
            RunConsoleCommand("stopsound")
            AllowClipping = false
        end;
    end)
    ---------------------------------------------------------------------------------- Console commands

    concommand.Add("Reset_Waltuh_to_Defaults", function()
        --convarfadeoutspeed:Revert()
        --convarfadeinspeed:Revert()
        --convartimefaded:Revert()
        --convarzoomoutwait:Revert()
        convarzoomspeed:Revert()
        convarzoomouttime:Revert()
        convarIsEnabled:Revert()
        convarturnangle:Revert()
        convarturnspeed:Revert()
        convarSongEnabled:Revert()
        convarAllowClipping:Revert()
    end)
    ---------------------------------------------------------------------------------- Variables not directly able to be changed by the player
    local timebeforezoomout = 8
    local initangle = Angle(90,0,0)
    local gotimetime = 1
    local position

    function clearscreen() -- In case the fadeout isn't removed automatically by the game, when the player respawns
        RunConsoleCommand("fadein", 0);
    end;

    function checkragdollexists()
        if IsValid(LocalPlayer():GetRagdollEntity()) then
            if (LocalPlayer():LookupBone("ValveBiped.Bip01_Head1")) then -- check if head bone is valid
                position = LocalPlayer():GetRagdollEntity():GetBonePosition(LocalPlayer():LookupBone("ValveBiped.Bip01_Head1")) + Vector(0,0,10)
            -- the position of the player's head. Initially, I had a system of creating a ragdoll with the pose from breaking bad with the player's playermodel, but I found this was WAY easier; less glitches could happen, you don't have to worry about conflicts in other addons, and in some ways it was just better looking and funnier.
            else
                position = LocalPlayer():GetPos() -- if player doesn't have a valid head bone
            end;
        elseif moddedragdoll != nil then
            position = moddedragdoll:GetBonePosition(moddedragdoll:LookupBone("ValveBiped.Bip01_Head1")) + Vector(0,0,10)
        else
            position = LocalPlayer():GetPos()
        end;
    end;

    function checkclipping()
        if not traced and not AllowClipping then
            local tr = util.TraceLine( {
                start = position,
                endpos = position + zoomoutspeed * zoomouttime,
                mask = MASK_VISIBLE
            } )
            if  tr.HitPos[3] != (position + zoomoutspeed * zoomouttime)[3] then
                zoomoutspeedOffset[3] = zoomoutspeed[3] * (math.abs(math.floor(tr.HitPos[3]) - math.floor(position[3])) / math.floor(zoomoutspeed[3] * zoomouttime))
            end;
            traced = true
        end;
    end;
    ---------------------------------------------------------------------------------- Add the options menu
    hook.Add( "AddToolMenuCategories", "CustomCategory", function()
        spawnmenu.AddToolCategory( "Options", "Waltuh", "#Waltuh" )
    end )
        
    hook.Add( "PopulateToolMenu", "CustomMenuSettings", function()
        spawnmenu.AddToolMenuOption( "Options", "Waltuh", "Waltuh", "#Waltuh Death", "", "", function( panel )

            /*
            panel:NumSlider( "Fadeout Time",
            "waltuh_fadeout_time", 0, 9999)
            panel:ControlHelp("Changes the time until the screen goes completely black before the zoomout, in seconds, setting this to 0 will be an almost immediate black out from death (This is not for how long the screen stays blank, for that, see waltuh_time_faded)")

            panel:NumSlider( "Fadein Time",
            "waltuh_fadein_time", 0, 9999)
            panel:ControlHelp("Changes the time when the screen fades from being no longer black, in seconds (This is not for how long the screen stays blank, for that, see waltuh_time_faded)")
            */

            /*
            panel:NumSlider( "Time Fully Faded",
            "waltuh_time_faded", 0.01, 9999)
            panel:ControlHelp("Changes the amount of time the screen is faded, before the screen unfades and the zoomout begins, in seconds")

            --panel:NumSlider( "Zoomout Wait",
            --"waltuh_zoomout_wait", 0.01, 9999)
            --panel:ControlHelp("Changes the amount of the time, where the camera is facing the player's head, but not zooming out yet, in seconds")
            */

            panel:Help("General Settings")

            panel:CheckBox("Enable Addon","Waltuh_IsEnabled")

            panel:CheckBox("Enable Song","waltuh_song_IsEnabled")

            panel:CheckBox("Allow Clipping Through Ceilings","Waltuh_allow_clipping")

            panel:Help("Warning: The following settings can break the zoomout camera")

            panel:NumSlider( "Zoomout Time",
            "waltuh_zoomout_time", 0.01, 600)
            panel:ControlHelp("Changes the amount time the camera zooms out for, starting from the exact point of death, in seconds")

            panel:NumSlider( "Zoomout Speed",
            "waltuh_zoomout_speed", 0.01, 5000)
            panel:ControlHelp("Changes the zoomout speed, therefore also affecting the total distance travalled upwards (Will have no effect when the addon is trying to prevent clipping through ceilings)")

            panel:NumSlider( "Camera Turn Angle",
            "waltuh_turn_angle", 0.01, 360)
            panel:ControlHelp("The total angle, in degrees, the camera will turn")

            panel:NumSlider( "Camera Turn Speed",
            "waltuh_turn_speed", 0.01, 500)
            panel:ControlHelp("Changes the speed at which the camera will turn until it reaches it's intended angle; lower values are quicker, higher values are slower")

            panel:Button("Reset to defaults","Reset_Waltuh_to_Defaults")
        end )
    end)
    ----------------------------------------------------------------------------------
    hook.Add("CalcView","Waltuh_Death_Camera",
    function(ply, pos, angles, fov)
        if not LocalPlayer():Alive() then
            if IsEnabled then
                resetAllVariables = false;
                -- If statements are to make sure these are only called once
                if not songplay and SongEnabled then
                    surface.PlaySound(BabyBlue)
                    songplay = true
                end;
                if not didfadeout then
                    RunConsoleCommand("fadeout", fadeouttime); -- fadeout console command, pairs with fadein
                    didfadeout = true;
                    start = start + timebeforezoomout; -- Offset for zoomout, so it doesn't skip upwards
                end;
                if not timer.Exists("timerfadeout") and not timerfadeout_started then -- check if timer exists before starting it; we want to have a delay where the player is completely blacked out
                    timer.Create("timerfadeout", (timefaded+fadeouttime), 1, function() -- we're not using a simple timer, as we want to be able to reset the timer if the player respawns
                        finishfadeout = true -- the delay is now over
                    end)
                elseif not timerfadeout_started then -- if it does exist, start the timer
                    timer.Start("timerfadeout");
                    timerfadeout_started = true; -- preventing repeats
                end;

                if finishfadeout then -- the delay/ darkened period is now over
                    if didfadein then -- to prevent repeats while keeping the code clean
                        checkragdollexists() -- Make sure the ragdoll exists, and constantly update the player's ragdoll's position
                        if not timer.Exists("goTimer") and not goTimer_started then -- goTimer is the delay where the camera is frozen, before zooming out; the delay is 1 second in the show
                            timer.Create("goTimer", gotimetime, 1, function() goTime = true end )
                        elseif not goTimer_started then
                            timer.Start("goTimer");
                            goTimer_started = true; -- preventing repeats
                        end;
                        if goTime then -- it's go time, move the camera!
                        
                            if SysTime() - start > zoomouttime then -- once the whole sequence is over then the credits roll
                                RunConsoleCommand("fadeout", 0) -- instant fadeout
                                if not timer.Exists("creditsTimer") and not creditsTimer_started then
                                    timer.Create("creditsTimer", 2, 1, function() GoVince = false end )
                                elseif not creditsTimer_started then
                                    timer.Start("creditsTimer");
                                    creditsTimer_started = true; -- preventing repeats (I see the irony)
                                end;
                                if GoVince then
                                    if not timer.Exists("VinceTimer") and not VinceTimer_started then
                                        timer.Create("VinceTimer", 2, 1, function() GoAwayVince = true end )
                                    elseif not VinceTimer_started then
                                        timer.Start("VinceTimer");
                                        VinceTimer_started = true;
                                    end;
                                end;
                            end
                            cameraPosLerp = LerpVector(SysTime() - start, position, position + zoomoutspeedOffset) -- The juicy bit; LerpVector, to smooth the camera movement between the final zoomout and initial zoomout positions; using a simple timer which goes up in seconds as "SysTime() - start" e.g "50.5 seconds - 50", 0.5 seconds have passed, and is used as the fraction for smoothing
                            cameraAngLerp = LerpAngle((SysTime()-start)/turnspeed, initangle, finalangle) -- Same idea, only slowed by a turning speed (usually 30), due to the LerpAngle using a ratio instead of a fraction.

                        else
                            cameraPosLerp = position -- might as well use the PosLerp 
                            cameraAngLerp = initangle -- and AngLerp as the stationary camera
                            
                        end;
                        local view = { -- used to set the camera's position, angle, fov etc.
                            origin = cameraPosLerp, -- the camera's position, using the lerp
                            angles = cameraAngLerp, -- the camera's angle, using the lerp
                            fov = fov, -- keep fov the same as the player's
                            drawviewer = false -- Probably not needed, but for safe measure
                        };
                        return view; -- send that back to the hook to change the camera
                    else -- to prevent repeats while keeping the code clean; also caching the postion of the player's head
                        RunConsoleCommand("fadein", fadeintime);
                        checkragdollexists()
                        checkclipping()
                        didfadein = true;
                    end;
                end;
            end;
        else
            if not resetAllVariables then -- for performance, it will only do this once after the scene is over; to stop all of the variables being overwritten every single frame
                -- reseting the variables, so that the sequence / if statements, can play again
                if songplay then
                    RunConsoleCommand("stopsound");-- really bad practice, but is the only way to stop surface.PlaySound(), without using other methods of playing sound
                    songplay = false;
                end;

                -- Stop the clocks! This is why the timers can't be simple timers
                if timer.Exists("timerfadeout") then
                    timer.Stop("timerfadeout")
                end

                if timer.Exists("goTimer") then
                    timer.Stop("goTimer")
                end

                if timer.Exists("creditsTimer") then
                    timer.Stop("creditsTimer")
                end

                if timer.Exists("VinceTimer") then
                    timer.Stop("VinceTimer")
                end

                didfadeout = false
                finishfadeout = false
                didfadein = false
                goTime = false
                timerfadeout_started = false
                goTimer_started = false
                creditsTimer_started = false
                VinceTimer_started = false
                GoVince = false
                GoAwayVince = false
                traced = false
                resetAllVariables = true
                zoomoutspeed:Set(zfix)
                zoomoutspeedOffset = zoomoutspeed
                clearscreen()
            end;
            start = SysTime()  -- start, servers as incremental timer from when we started the sequence, must be constantly updated
        end;
    end);

    hook.Add( "HUDShouldDraw", "RemoveRedScreen", function( name ) -- Remove the annoying red hud!
        if ( name == "CHudDamageIndicator" ) then 
           return false 
        end
    end)
    hook.Add( "OnEntityCreated", "ModCompatablility", function( ent ) -- compatablilty for mods like fedhoria
        timer.Simple(0.2, function() --wait to see if local player is dead, sometimes it takes a moment; we're making sure the player is dead, so it doesn't think that a spawned ragdoll with the same model as the player, is the actual player
            -- Also, now check if the ent is valid, as the player could've deleted the prop_ragdoll in the 0.2 seconds
            if IsValid(ent) then
                if ( ent:GetClass() == "prop_ragdoll" ) then
                    if ent:GetModel() == LocalPlayer():GetModel()  and not LocalPlayer():Alive() then
                        moddedragdoll = ent
                    end;
                end
            end
        end)
    end)
    hook.Add( "HUDPaint", "HUDPaint_DrawATexturedBox", function()
        if not LocalPlayer():Alive() and GoVince and not GoAwayVince then
            surface.SetMaterial( Vince )
            surface.SetDrawColor( 255, 255, 255, 255 )
            surface.DrawTexturedRect( 0, 0, ScrW(), ScrH())
        elseif GoAwayVince then
            draw.NoTexture()
        end;
    end )
end;