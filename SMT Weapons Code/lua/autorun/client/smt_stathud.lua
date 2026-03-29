AddCSLuaFile("smt_stathud")

hook.Add(
    "HUDPaint",
    "DrawMyHUD",
    function()
        local player = LocalPlayer() -- This gets the player object for the client the script is running on.

        -- Get the networked variables.
        local hp = player:GetNWInt("TBCHP", 100) -- 100 is the default value if TBCHP hasn't been set.
        local mp = player:GetNWInt("TBCMP", 100)
        local luck = player:GetNWInt("TBCLuck", 100)
        local technique = player:GetNWInt("TBCTechnique", 100)

        -- Set the position of the text.
        local x = ScrW() * 0.006 -- 10% from the left side of the screen.
        local y = ScrH() * 0.8 -- 90% from the top of the screen (near the bottom).

        -- Draw the text on the screen.
        draw.SimpleText("HP: " .. hp, "TargetID", x, y, Color(255, 255, 255, 255))
        draw.SimpleText("MP: " .. mp, "TargetID", x, y + 20, Color(255, 255, 255, 255)) -- +20 pixels on Y axis for spacing.
        draw.SimpleText("Luck: " .. luck, "TargetID", x, y + 40, Color(255, 255, 255, 255))
        draw.SimpleText("Technique: " .. technique, "TargetID", x, y + 60, Color(255, 255, 255, 255))
    end
)

-- Client-side code
local playersInFight = {}
local enemyInFight = {}
local inAFight = false
local timeLeft = 0

net.Receive(
    "GetFightInfo",
    function(len)
        playersInFight = net.ReadTable()
        enemyInFight = net.ReadTable()
        inAFight = net.ReadBool()
        timeLeft = net.ReadUInt(16)
    end
)

local requestInterval = 1 -- seconds
local nextRequestTime = CurTime() + requestInterval

hook.Add(
    "Think",
    "InfoRequestThink",
    function()
        if CurTime() >= nextRequestTime then
            net.Start("GetFightInfo")
            net.SendToServer()
            nextRequestTime = CurTime() + requestInterval
        end
    end
)

hook.Add(
    "HUDPaint",
    "StatDisplay",
    function()
        local screenWidth, screenHeight = ScrW(), ScrH()
        local ply = LocalPlayer()

        local xPosition = screenWidth * 0.01 -- 5% of the screen width
        local yPosition = screenHeight * 0.03 -- 5% of the screen height
        local yIncrement = screenHeight * 0.07 -- 7% of the screen height

        local engageWeapon = ply:GetWeapon("smti_engageswep")
        if not IsValid(engageWeapon) then
            return
        end
        if IsValid(engageWeapon) then
            local textColor = Color(200, 200, 200)

            if inAFight then
                for i, memberInfo in ipairs(playersInFight) do
                    if IsValid(memberInfo) then
                        local yPos = yPosition + (i - 1) * yIncrement

                        draw.RoundedBox(4, xPosition, yPos, 190, 60, Color(0, 0, 0, 150))

                        -- Draw each member's information
                        draw.SimpleText(memberInfo:Name(), "TargetID", xPosition, yPos, textColor)
                        draw.SimpleText(
                            "HP: " .. memberInfo:GetNWInt("TBCHP", 100) .. "/" .. memberInfo:GetNWInt("TBCMAXHP", 100),
                            "TargetID",
                            xPosition,
                            yPos + 20,
                            textColor
                        )
                        draw.SimpleText(
                            "MP: " .. memberInfo:GetNWInt("TBCMP") .. "/" .. memberInfo:GetNWInt("TBCMAXMP", 100),
                            "TargetID",
                            xPosition,
                            yPos + 35,
                            textColor
                        )

                        -- Draw ailments
                        if PlayerStats and PlayerStats[memberInfo:SteamID()] then
                            local buffs = GetAllStatsClient(memberInfo, "buffs")
                            local debuffs = GetAllStatsClient(memberInfo, "debuffs")

                            if buffs then
                                local ailmentXPos = xPosition + 200
                                local ailmentYPos = yPos + 30
                                for ailmentName, ailmentInfo in pairs(buffs) do
                                    if not (ailmentInfo.visibility == 0) then
                                        local ailmentText =
                                            string.gsub(ailmentName, "_", " ") .. " " .. ailmentInfo.stacks .. "x"

                                        -- Set the font that we're going to measure the size of
                                        surface.SetFont("TargetID")

                                        -- Get the size of the ailmentText
                                        local textWidth, textHeight = surface.GetTextSize(ailmentText)

                                        draw.SimpleText(ailmentText, "TargetID", ailmentXPos, ailmentYPos, textColor)
                                        ailmentXPos = ailmentXPos + textWidth + 5 -- add a small buffer after each ailment
                                    end
                                end
                            end

                            if debuffs then
                                local ailmentXPos = xPosition + 200
                                local ailmentYPos = yPos + 10
                                for ailmentName, ailmentInfo in pairs(debuffs) do
                                    if not (ailmentInfo.visibility == 0) then
                                        local ailmentText =
                                            string.gsub(ailmentName, "_", " ") .. " " .. ailmentInfo.stacks .. "x"

                                        -- Set the font that we're going to measure the size of
                                        surface.SetFont("TargetID")

                                        -- Get the size of the ailmentText
                                        local textWidth, textHeight = surface.GetTextSize(ailmentText)

                                        draw.SimpleText(ailmentText, "TargetID", ailmentXPos, ailmentYPos, textColor)
                                        ailmentXPos = ailmentXPos + textWidth + 5 -- add a small buffer after each ailment
                                    end
                                end
                            end
                        end
                    end
                end

                if timeLeft then
                    local minutes = math.floor(timeLeft / 60)
                    local seconds = math.floor(timeLeft % 60)

                    -- Format the time as MM:SS
                    local timeText = string.format("%02d:%02d", minutes, seconds)

                    -- Set the position and size for the text
                    local font = "TargetID"

                    -- Draw the text on the screen
                    draw.SimpleText(
                        timeText,
                        font,
                        xPosition + 1500,
                        yPosition,
                        Color(255, 255, 255, 255),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER
                    )
                end -- Exit if the timer doesn't exist anymore
            else
                draw.RoundedBox(4, xPosition, yPosition, 190, 60, Color(0, 0, 0, 150))
                draw.SimpleText(ply:Name(), "TargetID", xPosition, yPosition, textColor)
                draw.SimpleText(
                    "HP: " .. ply:GetNWInt("TBCHP") .. "/" .. ply:GetNWInt("TBCMAXHP", 100),
                    "TargetID",
                    xPosition,
                    yPosition + 20,
                    textColor
                )
                draw.SimpleText(
                    "MP: " .. ply:GetNWInt("TBCMP") .. "/" .. ply:GetNWInt("TBCMAXMP", 100),
                    "TargetID",
                    xPosition,
                    yPosition + 35,
                    textColor
                )

                -- Draw ailments
                if PlayerStats and PlayerStats[ply:SteamID()] then
                    local buffs = GetAllStatsClient(ply, "buffs")
                    local debuffs = GetAllStatsClient(ply, "debuffs")

                    local ailmentXPos = xPosition + 200
                    if buffs then
                        for ailmentName, ailmentInfo in pairs(buffs) do
                            if not (ailmentInfo.visibility == 0) then
                                local ailmentText = ailmentName .. " " .. ailmentInfo.stacks .. "x"

                                -- Set the font that we're going to measure the size of
                                surface.SetFont("TargetID")

                                -- Get the size of the ailmentText
                                local textWidth, textHeight = surface.GetTextSize(ailmentText)

                                draw.SimpleText(ailmentText, "TargetID", ailmentXPos, yIncrement, textColor)
                                ailmentXPos = ailmentXPos + textWidth + 5 -- add a small buffer after each ailment
                            end
                        end
                    end

                    if debuffs then
                        local ailmentXPos = xPosition + 200
                        for ailmentName, ailmentInfo in pairs(debuffs) do
                            if not (ailmentInfo.visibility == 0) then
                                local ailmentText = ailmentName .. " " .. ailmentInfo.stacks .. "x"

                                -- Set the font that we're going to measure the size of
                                surface.SetFont("TargetID")

                                -- Get the size of the ailmentText
                                local textWidth, textHeight = surface.GetTextSize(ailmentText)

                                draw.SimpleText(ailmentText, "TargetID", ailmentXPos, yIncrement + 15, textColor)
                                ailmentXPos = ailmentXPos + textWidth + 5 -- add a small buffer after each ailment
                            end
                        end
                    end
                end
            end
        end
    end
)

local allies = Material("materials/icons/allyicon.png")
local enemies = Material("materials/icons/enemyicon.png")

hook.Add(
    "PostPlayerDraw",
    "DrawImagesAbovePlayers",
    function(ply)
        if not IsValid(ply) then
            return
        end -- Check if the player entity is valid

        if inAFight then
            for i, memberInfo in ipairs(playersInFight) do
                if IsValid(memberInfo) then
                    -- Get the player's position and adjust the z-coordinate to move the image above the player's head
                    local pos = memberInfo:GetPos()
                    pos.z = pos.z + 80 -- Image position in height

                    -- rendering properties
                    cam.Start3D2D(pos, Angle(0, EyeAngles().y - 90, 90), 0.1) -- The 0.1 is the scale
                    surface.SetDrawColor(255, 255, 255, 255) -- color and alpha
                    surface.SetMaterial(allies) -- Set the image
                    surface.DrawTexturedRect(-64, -64, 128, 128) -- centered at the player's position
                    cam.End3D2D()
                end
            end

            for i, memberInfo in ipairs(enemyInFight) do
                if IsValid(memberInfo) then
                    -- Get the player's position and adjust the z-coordinate to move the image above the player's head
                    local pos = memberInfo:GetPos()
                    pos.z = pos.z + 80 -- Image position in height

                    -- Set up the rendering properties
                    cam.Start3D2D(pos, Angle(0, EyeAngles().y - 90, 90), 0.1) -- The 0.1 is the scale
                    surface.SetDrawColor(255, 255, 255, 255) -- color and alpha
                    surface.SetMaterial(enemies) -- Set the image
                    surface.DrawTexturedRect(-64, -64, 128, 128) -- centered at the player's position
                    cam.End3D2D()
                end
            end
        end
    end
)

-- Client-side script
hook.Add(
    "HUDPaint",
    "DrawStatsWhenLookingAtPlayer",
    function()
        local localPlayer = LocalPlayer() -- Get the local player
        local trace = localPlayer:GetEyeTrace() -- Get where the player is looking
        local target = trace.Entity -- Get the entity the player is looking at

        -- Check if the entity is a valid player and within a certain distance (e.g., 500 units)
        if IsValid(target) and CheckIfValidTBCEntity(target) and localPlayer:GetPos():Distance(target:GetPos()) < 500 then
            -- Get the target's position and convert it to 2D screen coordinates
            local targetPos = target:GetPos() + Vector(0, 0, 80) -- The Vector offset is to position the text above the player's head
            local screenPos = targetPos:ToScreen()

            -- Get the networked stats
            local tbchp = target:GetNWInt("TBCHP", 100) -- Default value is used if the variable isn't set
            local tbcmp = target:GetNWInt("TBCMP", 50)
            local tbcluck = target:GetNWInt("TBCLuck", 10)
            local tbctechnique = target:GetNWInt("TBCTechnique", 10)

            -- Draw the stats on the screen
            draw.SimpleText(
                "TBCHP: " .. tbchp,
                "TargetID",
                screenPos.x,
                screenPos.y,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "TBCMP: " .. tbcmp,
                "TargetID",
                screenPos.x,
                screenPos.y + 15,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "TBCLuck: " .. tbcluck,
                "TargetID",
                screenPos.x,
                screenPos.y + 30,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "TBCTechnique: " .. tbctechnique,
                "TargetID",
                screenPos.x,
                screenPos.y + 45,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            if tbchp <= 0 then
                draw.SimpleText(
                    "DEAD. GONE. HOW DOES IT FEEL TO BE DEAD?",
                    "TargetID",
                    screenPos.x,
                    screenPos.y + 60,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "Bye bye, you're history, you're through! You're dust.",
                    "Default",
                    screenPos.x,
                    screenPos.y + 75,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "I hope you improve your lousy score.",
                    "Default",
                    screenPos.x,
                    screenPos.y + 90,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "Adios, see you later, bye bye!",
                    "Default",
                    screenPos.x,
                    screenPos.y + 105,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "Try Again...",
                    "Default",
                    screenPos.x,
                    screenPos.y + 120,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            else
                if PlayerStats and PlayerStats[target:SteamID()] then
                    local buffs = GetAllStatsClient(target, "buffs")
                    local debuffs = GetAllStatsClient(target, "debuffs")
                    local isEmpty = true
                    if buffs then
                        local buffText = "Buffs: "
                        for status, properties in pairs(buffs) do
                            isEmpty = false
                            buffText = buffText .. string.gsub(status, "_", " ")
                            if properties.stacks then
                                buffText = buffText .. properties.stacks .. "x "
                            end
                        end

                        if not isEmpty then
                            draw.SimpleText(
                                buffText,
                                "TargetID",
                                screenPos.x,
                                screenPos.y + 60,
                                Color(255, 255, 255, 255),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_CENTER
                            )
                        end
                    end

                    if debuffs then
                        local debuffText = "Debuffs: "
                        isEmpty = true
                        for status, properties in pairs(debuffs) do
                            isEmpty = false
                            debuffText = debuffText .. string.gsub(status, "_", " ")
                            if properties.stacks then
                                debuffText = debuffText .. properties.stacks .. "x "
                            end
                        end

                        if not isEmpty then
                            draw.SimpleText(
                                debuffText,
                                "TargetID",
                                screenPos.x,
                                screenPos.y + 75,
                                Color(255, 255, 255, 255),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_CENTER
                            )
                        end
                    end
                end
            end
        end
    end
)
