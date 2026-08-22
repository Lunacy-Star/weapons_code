include("autorun/tbc_weapon_metatable.lua")

if SERVER then
    util.AddNetworkString("UpdateStatHP") -- Stat updater
    util.AddNetworkString("UpdateStatMP") -- Stat updater
    util.AddNetworkString("UpdateStatLuck") -- Stat updater
    util.AddNetworkString("UpdateStatTechnique") -- Stat updater
    util.AddNetworkString("UpdateStatSTRDEXCHR")
    util.AddNetworkString("StatHandlerUse")
    
    hook.Add("PlayerInitialSpawn", "SetInitialDefaultStats", function(ply)
        ply:SetNWInt("TBCHP", 100)
        ply:SetNWInt("TBCMP", 50)
        ply:SetNWInt("TBCLuck", 10)
        ply:SetNWInt("TBCTechnique", 10)
        -- Load values from PData, or use 0 as a default if no value is saved
        ply:SetNWInt("TBCSTR", ply:GetPData("TBCSTR", 0))
        ply:SetNWInt("TBCDEX", ply:GetPData("TBCDEX", 0))
        ply:SetNWInt("TBCCHR", ply:GetPData("TBCCHR", 0))
    end)

    hook.Add("PlayerSpawn", "SetDefaultStats", function(ply)
        if not ply:GetNWInt("TBCHP") then ply:SetNWInt("TBCHP", 100) end -- replace 100 with your desired default value
        if not ply:GetNWInt("TBCMP") then ply:SetNWInt("TBCMP", 50) end -- replace 50 with your desired default value
        if not ply:GetNWInt("TBCLuck") then ply:SetNWInt("TBCLuck", 10) end -- replace 10 with your desired default value
        if not ply:GetNWInt("TBCTechnique") then
            ply:SetNWInt("TBCTechnique", 10)
        end -- replace 10 with your desired default value

        -- This will set the values if they haven't been set yet. If they have, it leaves them as they are.
    end)

    --[[ use these to update stats
	net.Receive("UpdateStatHP", function(len, ply) -- 'ply' is the player who sent the message
		local newHP = net.ReadInt(32)
		ply:SetNWInt("TBCHP", newHP)
	end)

	net.Receive("UpdateStatMP", function(len, ply) -- 'ply' is the player who sent the message
		local newMP = net.ReadInt(32)
		ply:SetNWInt("TBCMP", newMP)
	end)

	net.Receive("UpdateStatLuck", function(len, ply) -- 'ply' is the player who sent the message
		local newLuck = net.ReadInt(32)
		ply:SetNWInt("TBCLuck", newLuck)
	end)

	net.Receive("UpdateStatTechnique", function(len, ply) -- 'ply' is the player who sent the message
		local newTech = net.ReadInt(32)
		ply:SetNWInt("TBCTechnique", newTech)
	end)
]] --

    -- Chat Command to Open Stats Menu
    hook.Add("PlayerSay", "StatsCommand", function(ply, text, team)
        if string.lower(text) == "/stats" then
            ply:ConCommand("smtstats_menu")
            return ""
        end
    end)

    net.Receive("UpdateStatSTRDEXCHR", function(len, ply)
        local stat = net.ReadString()
        local amount = net.ReadInt(16)
        local current = ply:GetNWInt(stat, 0) + amount
        local clampedValue = math.Clamp(current, 0, 10) -- Assuming a max value of 10

        -- Set the networked value
        ply:SetNWInt(stat, clampedValue)

        -- Save the new value to PData
        ply:SetPData(stat, clampedValue)

        local userBuffsTable = GetAllStats(ply, "permabuffs")

        HandleStatus(ply, userBuffsTable, "statChange", false, false)
    end)

    util.AddNetworkString("GetFightInfo")

    net.Receive("GetFightInfo", function(len, ply)
        local engageWeapon = ply:GetWeapon("smti_engageswep")
        if not IsValid(engageWeapon) then
            net.Start("GetFightInfo")
            net.WriteTable({})
            net.WriteTable({})
            net.WriteBool(false)
            net.WriteUInt(0, 16)
            net.WriteEntity(NULL)
            net.Send(ply)
            return
        end

        local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
        if not fight then
            net.Start("GetFightInfo")
            net.WriteTable({})
            net.WriteTable({})
            net.WriteBool(false)
            net.WriteUInt(0, 16)
            net.WriteEntity(NULL)
            net.Send(ply)
            return
        end

        local playerSide = (table.HasValue(fight.Side1, ply) and "Side1") or
                               (table.HasValue(fight.Side2, ply) and "Side2")

        local playersInFight = {}
        for _, player in ipairs(fight[playerSide]) do
            if IsValid(player) then
                table.insert(playersInFight, player)
            end
        end

        local enemy = "Side2"
        if playerSide == "Side2" then enemy = "Side1" end

        local enemyInFight = {}
        for _, player in ipairs(fight[enemy]) do
            if IsValid(player) then
                table.insert(enemyInFight, player)
            end
        end

        local turnTime = 0

        if timer.Exists(engageWeapon.FightId) then
            turnTime = timer.TimeLeft(engageWeapon.FightId) -- Get the remaining time in seconds
        end -- Exit if the timer doesn't exist

        local currentTurnPlayer = fight.ActiveSide and fight[fight.ActiveSide] and
                                       fight[fight.ActiveSide][fight.ActiveMember]

        net.Start("GetFightInfo")
        net.WriteTable(playersInFight)
        net.WriteTable(enemyInFight)
        net.WriteBool(true)
        net.WriteUInt(turnTime, 16)
        net.WriteEntity(IsValid(currentTurnPlayer) and currentTurnPlayer or NULL)
        net.Send(ply)
    end)
end

if CLIENT then
    -- Define a custom font
    surface.CreateFont("StatFont", {
        size = 20,
        weight = 500,
        color = Color(110, 110, 110) -- Darker color
    })

    -- Define a function to open the stats menu
    net.Receive("StatHandlerUse", function()
        -- Create the main frame
        local frame = vgui.Create("DFrame")
        frame:SetSize(300, 200)
        frame:SetTitle("Stats Menu")
        frame:Center()
        frame:MakePopup()

        -- Create a label to display the remaining points
        local remainingPointsLabel = vgui.Create("DLabel", frame)
        remainingPointsLabel:SetPos(104, 30)
        remainingPointsLabel:SizeToContents()

        local labels = {}

        -- Create a table to map long stat names to short stat names
        local statNameMapping = {TBCSTR = "STR", TBCDEX = "DEX", TBCCHR = "CHR"}

        -- Define a function to update the remaining points label
        local function updateLabelsAndRemainingPoints()
            -- Update each label
            for stat, label in pairs(labels) do
                label:SetText(statNameMapping[stat] .. ": " ..
                                  LocalPlayer():GetNWInt(stat, 0))
            end
            -- Update the remaining points label
            local currentTotal = LocalPlayer():GetNWInt("TBCSTR", 0) +
                                     LocalPlayer():GetNWInt("TBCDEX", 0) +
                                     LocalPlayer():GetNWInt("TBCCHR", 0)
            local remainingPoints = 10 - currentTotal
            remainingPointsLabel:SetText("Remaining Points: " .. remainingPoints)
            remainingPointsLabel:SizeToContents() -- Resize the label to fit the new text
        end

        updateLabelsAndRemainingPoints()

        -- Define a function to update a stat
        local function updateStat(stat, amount)
            -- Get the current values of TBCSTR, TBCDEX, and TBCCHR
            local currentSTR = LocalPlayer():GetNWInt("TBCSTR", 0)
            local currentDEX = LocalPlayer():GetNWInt("TBCDEX", 0)
            local currentCHR = LocalPlayer():GetNWInt("TBCCHR", 0)

            -- Calculate the new total
            local newTotal = currentSTR + currentDEX + currentCHR + amount

            -- Only proceed if the new total is less than or equal to 10
            if newTotal <= 10 then
                -- Update the UI immediately without waiting for the server
                LocalPlayer():SetNWInt(stat,
                                       LocalPlayer():GetNWInt(stat, 0) + amount)
                updateLabelsAndRemainingPoints()

                -- Send the update to the server
                net.Start("UpdateStatSTRDEXCHR")
                net.WriteString(stat)
                net.WriteInt(amount, 16)
                net.SendToServer()
            else
                -- Optional: Notify the player that they cannot exceed a total of 10
                LocalPlayer():ChatPrint("Total stats cannot exceed 10!")
            end
        end

        -- Create rows for each stat
        for i, stat in ipairs({"TBCSTR", "TBCDEX", "TBCCHR"}) do
            local panel = vgui.Create("DPanel", frame)
            panel:SetSize(290, 45)
            panel:SetPos(5, 50 + (i - 1) * 50)

            local minus = vgui.Create("DButton", panel)
            minus:SetText("-")
            minus:SetSize(20, 20)
            minus:SetPos(10, 10)

            -- Create the label and add it to the labels table
            local label = vgui.Create("DLabel", panel)
            label:SetText(statNameMapping[stat] .. ": " ..
                              LocalPlayer():GetNWInt(stat, 0))
            label:SetFont("StatFont") -- Set the custom font
            label:SetPos(115, 10)
            label:SizeToContents()
            label:SetColor(Color(50, 50, 50)) -- Set the text color to a darker color
            labels[stat] = label -- Add the label to the labels table

            -- Define the updateLabel function here, after the label variable is defined
            local function updateLabel()
                label:SetText(statNameMapping[stat] .. ": " ..
                                  LocalPlayer():GetNWInt(stat, 0))
            end

            minus.DoClick = function()
                updateStat(stat, -1)
                updateLabelsAndRemainingPoints()
            end

            local plus = vgui.Create("DButton", panel)
            plus:SetText("+")
            plus:SetSize(20, 20)
            plus:SetPos(260, 10)
            plus.DoClick = function()
                updateStat(stat, 1)
                updateLabelsAndRemainingPoints()
            end
        end

    end)

    -- Network message to update a stat
    net.Receive("UpdateStatSTRDEXCHR", function(len)
        local stat = net.ReadString()
        local amount = net.ReadInt(16)
        LocalPlayer():SetNWInt(stat, LocalPlayer():GetNWInt(stat, 0) + amount)
        -- Update the UI to reflect the new stat values
        if frame and IsValid(frame) then -- Check if the frame still exists
            for i, panel in ipairs(frame:GetChildren()) do -- Loop through each child panel of the frame
                for j, element in ipairs(panel:GetChildren()) do -- Loop through each element in the panel
                    if element:GetClassName() == "DLabel" then -- Check if the element is a DLabel
                        local stat = element:GetText():match("^(%w+):") -- Extract the stat name from the label text
                        if stat and statMapping[stat] then -- Check if the stat name is valid
                            element:SetText(stat .. ": " ..
                                                LocalPlayer():GetNWInt(
                                                    statMapping[stat], 0)) -- Update the label text
                        end
                    end
                end
            end
            updateLabelsAndRemainingPoints() -- Update the remaining points label
        end
    end)

end
