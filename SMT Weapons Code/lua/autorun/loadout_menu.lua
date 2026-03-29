include("autorun/buffs_manager.lua")

if CLIENT then
    local detailFrame

    function OpenItemDetailWindow(frame, itemClass)
        if IsValid(detailFrame) then
            detailFrame:Close()
        end

        local item = LoadoutItems and LoadoutItems[itemClass]
        if not item then
            return
        end

        detailFrame = vgui.Create("DFrame")
        local x, y = frame:GetPos()
        local width, _ = frame:GetSize()
        detailFrame:SetSize(300, 200)
        detailFrame:SetPos(x + width + 5, y)
        detailFrame:SetTitle("Item Details")
        detailFrame:MakePopup()

        local nameLabel = vgui.Create("DLabel", detailFrame)
        nameLabel:SetPos(10, 30)
        nameLabel:SetSize(280, 20)
        nameLabel:SetText(item.name or itemClass)

        local descLabel = vgui.Create("DLabel", detailFrame)
        descLabel:SetPos(10, 50)
        descLabel:SetSize(280, 100)
        descLabel:SetWrap(true)
        descLabel:SetText(item.description or "")

        local costLabel = vgui.Create("DLabel", detailFrame)
        costLabel:SetPos(10, 160)
        costLabel:SetSize(280, 20)
        costLabel:SetText("Cost: " .. (item.cost or 0) .. " Essence")
    end

    function OpenLoadoutMenu(charId)
        local bgColor = Color(44, 47, 51, 255)

        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("Loadout Menu")
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, bgColor)
        end

        local charData = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charId]
        if not charData then
            return
        end

        local essence = charData.essence or 0
        local remainingEssence = essence

        local essenceLabel = vgui.Create("DLabel", frame)
        essenceLabel:SetPos(10, 30)
        essenceLabel:SetText("Remaining Essence: " .. remainingEssence)
        essenceLabel:SizeToContents()

        local availableListView = vgui.Create("DListView", frame)
        availableListView:SetPos(10, 60)
        availableListView:SetSize(380, 400)
        availableListView:AddColumn("Item")
        availableListView:AddColumn("Cost")

        local selectedListView = vgui.Create("DListView", frame)
        selectedListView:SetPos(410, 60)
        selectedListView:SetSize(380, 400)
        selectedListView:AddColumn("Item")
        selectedListView:AddColumn("Cost")

        for _, itemClass in pairs(charData.loadoutItems) do
            -- Only add entries that exist in LoadoutItems (not Personas)
            local item = LoadoutItems and LoadoutItems[itemClass]
            if item then
                local line = availableListView:AddLine(item.name, item.cost)
                line.itemClass = item.class
                line.itemId = itemClass
                line.OnCursorEntered = function()
                    OpenItemDetailWindow(frame, itemClass)
                end
                line.OnCursorExited = function()
                    if IsValid(detailFrame) then
                        detailFrame:Close()
                    end
                end
            end
        end

        availableListView.OnRowSelected = function(lst, index, row)
            local itemId = row.itemId
            local item = LoadoutItems and LoadoutItems[itemId]
            if not item then
                return
            end

            local itemCost = item.cost or 0
            if remainingEssence >= itemCost then
                local selectedLine = selectedListView:AddLine(row:GetValue(1), row:GetValue(2))
                selectedLine.itemClass = row.itemClass
                selectedLine.itemId = itemId
                selectedLine.OnCursorEntered = function()
                    OpenItemDetailWindow(frame, itemId)
                end
                selectedLine.OnCursorExited = function()
                    if IsValid(detailFrame) then
                        detailFrame:Close()
                    end
                end

                remainingEssence = remainingEssence - itemCost
                essenceLabel:SetText("Remaining Essence: " .. remainingEssence)
                essenceLabel:SizeToContents()
                availableListView:RemoveLine(index)
            else
                LocalPlayer():ChatPrint("Not enough Essence!")
            end
        end

        selectedListView.OnRowSelected = function(lst, index, row)
            local itemId = row.itemId
            local item = LoadoutItems and LoadoutItems[itemId]
            local itemCost = item and item.cost or 0

            local availableLine = availableListView:AddLine(row:GetValue(1), row:GetValue(2))
            availableLine.itemClass = row.itemClass
            availableLine.itemId = itemId
            availableLine.OnCursorEntered = function()
                OpenItemDetailWindow(frame, itemId)
            end
            availableLine.OnCursorExited = function()
                if IsValid(detailFrame) then
                    detailFrame:Close()
                end
            end

            remainingEssence = remainingEssence + itemCost
            essenceLabel:SetText("Remaining Essence: " .. remainingEssence)
            essenceLabel:SizeToContents()
            selectedListView:RemoveLine(index)
        end

        local saveLoadoutCheckbox = vgui.Create("DCheckBoxLabel", frame)
        saveLoadoutCheckbox:SetPos(10, 480)
        saveLoadoutCheckbox:SetText("Save loadout (It will give you the same items until you switch characters!)")
        saveLoadoutCheckbox:SetValue(0)
        saveLoadoutCheckbox:SizeToContents()

        local buttonWidth = 380
        local buttonHeight = 30
        local frameWidth, frameHeight = frame:GetSize()
        local xPos = (frameWidth - buttonWidth) / 2
        local yPos = frameHeight - buttonHeight - 50

        local confirmButton = vgui.Create("DButton", frame)
        confirmButton:SetPos(xPos, yPos)
        confirmButton:SetSize(buttonWidth, buttonHeight)
        confirmButton:SetText("Confirm Loadout")
        confirmButton:SetTextColor(Color(255, 255, 255))
        confirmButton.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 102, 204))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 76, 153))
            end
        end
        confirmButton.DoClick = function()
            local selectedItems = {}
            for _, row in pairs(selectedListView:GetLines()) do
                table.insert(selectedItems, row.itemClass)
            end
            net.Start("ConfirmLoadout")
            net.WriteTable(selectedItems)
            net.WriteBool(saveLoadoutCheckbox:GetChecked())
            net.SendToServer()

            if IsValid(detailFrame) then
                detailFrame:Close()
            end
            frame:Close()
        end
    end

    function OpenPersonaDetailWindow(frame, itemClass)
        if IsValid(detailFrame) then
            detailFrame:Close()
        end

        local persona = Personas and Personas[itemClass]
        if not persona then
            return
        end

        detailFrame = vgui.Create("DFrame")
        local x, y = frame:GetPos()
        local width, _ = frame:GetSize()
        local bgColor = Color(44, 47, 51, 255)

        detailFrame:SetSize(400, _)
        detailFrame:SetPos(x + width + 5, y)
        detailFrame:SetTitle("Item Details")
        detailFrame:MakePopup()
        detailFrame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, bgColor)
        end

        local startY = 20
        local gap = 5
        local labelFont = "Default"

        local function CalcWrappedTextHeight(text, width, font)
            surface.SetFont(font)
            local _, h = surface.GetTextSize("W")
            local lines = math.ceil(surface.GetTextSize(text) / width)
            return h * lines
        end

        local nameLabel = vgui.Create("DLabel", detailFrame)
        nameLabel:SetFont(labelFont)
        nameLabel:SetPos(10, startY)
        nameLabel:SetSize(280, 20)
        nameLabel:SetText(persona.name or itemClass)

        local nextY = startY + nameLabel:GetTall() + gap

        local descLabel = vgui.Create("DLabel", detailFrame)
        descLabel:SetFont(labelFont)
        descLabel:SetPos(10, nextY)
        local descHeight = CalcWrappedTextHeight(persona.description or "", 280, labelFont)
        descLabel:SetSize(350, descHeight)
        descLabel:SetWrap(true)
        descLabel:SetText(persona.description or "")
        nextY = nextY + descHeight + gap + 10

        if persona.race then
            local lbl = vgui.Create("DLabel", detailFrame)
            lbl:SetFont(labelFont)
            lbl:SetPos(10, nextY)
            local h = CalcWrappedTextHeight(persona.race, 280, labelFont)
            lbl:SetSize(280, h)
            lbl:SetWrap(true)
            lbl:SetText("Race: " .. persona.race)
            nextY = nextY + h + gap
        end

        if persona.arcana then
            local lbl = vgui.Create("DLabel", detailFrame)
            lbl:SetFont(labelFont)
            lbl:SetPos(10, nextY)
            local h = CalcWrappedTextHeight(persona.arcana, 280, labelFont)
            lbl:SetSize(280, h)
            lbl:SetWrap(true)
            lbl:SetText("Arcana: " .. persona.arcana)
            nextY = nextY + h + gap + 10
        end

        local function ResistRow(label, tbl)
            if not tbl or #tbl == 0 then
                return
            end
            local lbl = vgui.Create("DLabel", detailFrame)
            lbl:SetFont(labelFont)
            lbl:SetPos(10, nextY)
            local txt = label .. ": " .. table.concat(tbl, ", ")
            local h = CalcWrappedTextHeight(txt, 280, labelFont)
            lbl:SetSize(280, h)
            lbl:SetText(txt)
            nextY = nextY + h + gap
        end

        ResistRow("Resist", persona.resist)
        ResistRow("Weak", persona.weak)
        ResistRow("Block", persona.block)
        ResistRow("Drain", persona.drain)
        ResistRow("Repel", persona.repel)

        nextY = nextY + gap + 10

        if persona.skills and #persona.skills > 0 then
            for _, weaponClass in pairs(persona.skills) do
                local weapon = weapons.Get(weaponClass)
                if weapon then
                    local lbl = vgui.Create("DLabel", detailFrame)
                    lbl:SetFont(labelFont)
                    lbl:SetPos(10, nextY)
                    local txt =
                        (weapon.PrintName or weaponClass) ..
                        " (" .. (weapon.WeaponType or "?") .. ": " .. (weapon.Affinity or "?") .. ")"
                    if weapon.MPCost then
                        txt = txt .. " (" .. weapon.MPCost .. " SP):"
                    elseif weapon.HPCost then
                        txt = txt .. " (" .. weapon.HPCost .. " HP):"
                    end
                    txt = txt .. " " .. (weapon.Purpose or "")
                    local h = CalcWrappedTextHeight(txt, 280, labelFont)
                    lbl:SetSize(350, h)
                    lbl:SetWrap(true)
                    lbl:SetText(txt)
                    nextY = nextY + h + gap + 10
                end
            end
        end
    end

    function OpenPersonaMenu(charId)
        local bgColor = Color(44, 47, 51, 255)

        local frame = vgui.Create("DFrame")
        frame:SetSize(800, 600)
        frame:Center()
        frame:SetTitle("Loadout Menu")
        frame:MakePopup()
        frame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, bgColor)
        end

        local ply = LocalPlayer()
        local charData = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charId]
        if not charData then
            return
        end

        local remainingEssence = charData.essence or 1

        local availableListView = vgui.Create("DListView", frame)
        availableListView:SetPos(10, 60)
        availableListView:SetSize(380, 400)
        availableListView:AddColumn("Item")

        local selectedListView = vgui.Create("DListView", frame)
        selectedListView:SetPos(410, 60)
        selectedListView:SetSize(380, 400)
        selectedListView:AddColumn("Item")

        for _, itemClass in pairs(charData.loadoutItems) do
            -- Only add entries that exist in Personas (not LoadoutItems)
            local persona = Personas and Personas[itemClass]
            if persona then
                local line = availableListView:AddLine(persona.name or itemClass)
                line.itemClass = itemClass
                line.OnCursorEntered = function()
                    OpenPersonaDetailWindow(frame, itemClass)
                end
                line.OnCursorExited = function()
                    if IsValid(detailFrame) then
                        detailFrame:Close()
                    end
                end
            end
        end

        availableListView.OnRowSelected = function(lst, index, row)
            local itemClass = row.itemClass
            if remainingEssence >= 1 then
                local selectedLine = selectedListView:AddLine(row:GetValue(1))
                selectedLine.itemClass = itemClass
                selectedLine.OnCursorEntered = function()
                    OpenPersonaDetailWindow(frame, itemClass)
                end
                selectedLine.OnCursorExited = function()
                    if IsValid(detailFrame) then
                        detailFrame:Close()
                    end
                end
                remainingEssence = 0
                availableListView:RemoveLine(index)
            else
                ply:ChatPrint("You can only pick one Persona!")
            end
        end

        selectedListView.OnRowSelected = function(lst, index, row)
            local itemClass = row.itemClass
            local availableLine = availableListView:AddLine(row:GetValue(1))
            availableLine.itemClass = itemClass
            availableLine.OnCursorEntered = function()
                OpenPersonaDetailWindow(frame, itemClass)
            end
            availableLine.OnCursorExited = function()
                if IsValid(detailFrame) then
                    detailFrame:Close()
                end
            end
            remainingEssence = 1
            selectedListView:RemoveLine(index)
        end

        local saveLoadoutCheckbox = vgui.Create("DCheckBoxLabel", frame)
        saveLoadoutCheckbox:SetPos(10, 480)
        saveLoadoutCheckbox:SetText(
            "Save Persona (It will give you the same Persona skills until you switch characters!)"
        )
        saveLoadoutCheckbox:SetValue(0)
        saveLoadoutCheckbox:SizeToContents()

        local buttonWidth = 380
        local buttonHeight = 30
        local frameWidth, frameHeight = frame:GetSize()
        local xPos = (frameWidth - buttonWidth) / 2
        local yPos = frameHeight - buttonHeight - 50

        local confirmButton = vgui.Create("DButton", frame)
        confirmButton:SetPos(xPos, yPos)
        confirmButton:SetSize(buttonWidth, buttonHeight)
        confirmButton:SetText("Confirm Persona")
        confirmButton:SetTextColor(Color(255, 255, 255))
        confirmButton.Paint = function(self, w, h)
            if self:IsHovered() then
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 102, 204))
            else
                draw.RoundedBox(4, 0, 0, w, h, Color(0, 76, 153))
            end
        end
        confirmButton.DoClick = function()
            local selectedItem = ""
            for _, row in pairs(selectedListView:GetLines()) do
                selectedItem = row.itemClass
            end
            net.Start("ConfirmPersona")
            net.WriteString(selectedItem)
            net.WriteBool(saveLoadoutCheckbox:GetChecked())
            net.SendToServer()
            if IsValid(detailFrame) then
                detailFrame:Close()
            end
            frame:Close()
        end
    end

    net.Receive(
        "OpenLoadoutMenu",
        function(len)
            local charType = net.ReadString()
            local newChar = net.ReadString()
            if charType == "Demon" then
                OpenLoadoutMenu(newChar)
            else
                OpenPersonaMenu(newChar)
            end
        end
    )
end

if SERVER then
    util.AddNetworkString("OpenLoadoutMenu")
    util.AddNetworkString("ConfirmLoadout")
    util.AddNetworkString("ConfirmPersona")
    util.AddNetworkString("SaveLoadout")

    hook.Add(
        "PlayerDisconnected",
        "ClearSavedLoadoutOnDisconnect",
        function(ply)
            local charId = ply:GetNWString("AssignedCharacter")
            ply:RemovePData("SavedLoadout_" .. charId)
            ply:RemovePData("SavedPersona_" .. charId)
        end
    )

    hook.Add(
        "PlayerSpawn",
        "PlayerCharacterSetOnSpawn",
        function(ply)
            local charId = ply:GetNWString("AssignedCharacter")
            if not (CHARACTERS and CHARACTERS.List[charId]) then
                return
            end

            local charData = CHARACTERS.List[charId]

            if charData.weapons then
                ply:StripWeapons()
                for _, weapon in ipairs(charData.weapons) do
                    ply:Give(weapon)
                end
            end

            if charData.loadoutItems then
                local savedLoadout = ply:GetPData("SavedLoadout_" .. charId)
                local savedPersona = ply:GetPData("SavedPersona_" .. charId)

                if savedLoadout then
                    local items = util.JSONToTable(savedLoadout)
                    for _, itemClass in pairs(items) do
                        ply:Give(itemClass)
                    end
                elseif savedPersona then
                    local items = util.JSONToTable(savedPersona)
                    for k, itemClass in pairs(items) do
                        if k ~= "persona" then
                            ply:Give(itemClass)
                        else
                            timer.Create(
                                "givePersonas",
                                1,
                                1,
                                function()
                                    AssignStat(ply, itemClass, itemClass, "personas")
                                    AssignStat(ply, itemClass, itemClass, "permapersonas")
                                    ply:SetNW2String("selectedPersona", itemClass)
                                end
                            )
                        end
                    end
                else
                    local charType = charData.type or ""
                    net.Start("OpenLoadoutMenu")
                    net.WriteString(charType)
                    net.WriteString(charId)
                    net.Send(ply)
                end
            end
        end
    )

    net.Receive(
        "ConfirmLoadout",
        function(len, ply)
            local selectedItems = net.ReadTable()
            local saveLoadout = net.ReadBool()
            if saveLoadout then
                local charId = ply:GetNWString("AssignedCharacter")
                ply:SetPData("SavedLoadout_" .. charId, util.TableToJSON(selectedItems))
            end
            for _, itemClass in pairs(selectedItems) do
                ply:Give(itemClass)
            end
        end
    )

    net.Receive(
        "ConfirmPersona",
        function(len, ply)
            local selectedItem = net.ReadString()
            local saveLoadout = net.ReadBool()

            if selectedItem ~= "" then
                ply:SetNW2String("selectedPersona", selectedItem)
                AssignStat(ply, selectedItem, selectedItem, "personas")
                AssignStat(ply, selectedItem, selectedItem, "permapersonas")

                local persona = Personas and Personas[selectedItem]
                if persona and persona.skills then
                    for _, weaponClass in pairs(persona.skills) do
                        ply:Give(weaponClass)
                    end

                    if saveLoadout then
                        local charId = ply:GetNWString("AssignedCharacter")
                        local personaSkills = {}
                        for k, v in pairs(persona.skills) do
                            personaSkills[k] = v
                        end
                        personaSkills["persona"] = selectedItem
                        ply:SetPData("SavedPersona_" .. charId, util.TableToJSON(persona.skills))
                    end
                end
            end
        end
    )
end
