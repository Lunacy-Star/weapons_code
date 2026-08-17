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

    -- Namespaced (not just "OpenPersonaDetailWindow") because custom_tab_menu.lua
    -- declares a same-named global for its own, differently-shaped Inventory-tab
    -- persona preview; whichever file loaded last was silently winning and being
    -- called from here with the wrong arguments, crashing on a NULL TabMenu
    -- whenever the F4 inventory menu wasn't already open.
    -- Rows are Dock(TOP) + SetAutoStretchVertical inside a scroll panel (same
    -- approach as custom_tab_menu.lua's OpenPersonaDetailWindow) rather than
    -- manually computing pixel heights via surface.GetTextSize: that estimate
    -- doesn't account for wrapping or embedded "\n"s in weapon Purpose text,
    -- so rows undersized their box and the next row overlapped/clipped it.
    function OpenLoadoutPersonaDetailWindow(frame, itemClass)
        if IsValid(detailFrame) then
            detailFrame:Close()
        end

        local persona = Personas and Personas[itemClass]
        if not persona then
            return
        end

        detailFrame = vgui.Create("DFrame")
        local x, y = frame:GetPos()
        local width, height = frame:GetSize()
        local bgColor = Color(44, 47, 51, 255)

        detailFrame:SetSize(400, height)
        detailFrame:SetPos(x + width + 5, y)
        detailFrame:SetTitle("Item Details")
        detailFrame:MakePopup()
        detailFrame.Paint = function(self, w, h)
            draw.RoundedBox(10, 0, 0, w, h, bgColor)
        end

        local scroll = vgui.Create("DScrollPanel", detailFrame)
        scroll:Dock(FILL)
        scroll:DockMargin(10, 30, 10, 10)

        local function AddRow(text, font, color)
            local lbl = vgui.Create("DLabel", scroll)
            lbl:Dock(TOP)
            lbl:SetText(text)
            lbl:SetFont(font or "Default")
            lbl:SetTextColor(color or Color(220, 220, 220))
            lbl:SetWrap(true)
            lbl:SetAutoStretchVertical(true)
            lbl:DockMargin(0, 0, 0, 5)
            return lbl
        end

        AddRow(persona.name or itemClass, "DermaLarge", Color(255, 255, 255))

        if persona.description and persona.description ~= "" then
            AddRow(persona.description)
        end

        if persona.race then
            AddRow("Race: " .. persona.race)
        end

        if persona.arcana then
            AddRow("Arcana: " .. persona.arcana)
        end

        local function ResistRow(label, tbl)
            if not tbl or #tbl == 0 then
                return
            end
            AddRow(label .. ": " .. table.concat(tbl, ", "))
        end

        ResistRow("Resist", persona.resist)
        ResistRow("Weak", persona.weak)
        ResistRow("Block", persona.block)
        ResistRow("Drain", persona.drain)
        ResistRow("Repel", persona.repel)

        if persona.skills and #persona.skills > 0 then
            AddRow("Skills:", "DermaDefaultBold", Color(200, 200, 200))

            for _, weaponClass in pairs(persona.skills) do
                local weapon = weapons.Get(weaponClass)
                if weapon then
                    local txt =
                        (weapon.PrintName or weaponClass) ..
                        " (" .. (weapon.WeaponType or "?") .. ": " .. (weapon.Affinity or "?") .. ")"
                    if weapon.MPCost then
                        txt = txt .. " (" .. weapon.MPCost .. " SP):"
                    elseif weapon.HPCost then
                        txt = txt .. " (" .. weapon.HPCost .. " HP):"
                    end
                    txt = txt .. " " .. (weapon.Purpose or "")
                    AddRow(txt)
                end
            end
        end

        if persona.passives and next(persona.passives) then
            AddRow("Passives:", "DermaDefaultBold", Color(200, 200, 200))

            for passiveKey, _ in pairs(persona.passives) do
                local passiveData = Passives and Passives[passiveKey]

                local txt
                if passiveData then
                    txt = (passiveData.name or passiveKey) .. " (Passive): " ..
                              (passiveData.description or "")
                else
                    txt = passiveKey .. " (Passive)"
                end

                AddRow(txt)
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
                    OpenLoadoutPersonaDetailWindow(frame, itemClass)
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
                    OpenLoadoutPersonaDetailWindow(frame, itemClass)
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
                OpenLoadoutPersonaDetailWindow(frame, itemClass)
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

    -- One-time cleanup: testing left SavedPersona_citizen / SavedPersona_student_a
    -- PData behind on a couple of accounts, which made PlayerCharacterSetOnSpawn
    -- (below) silently re-grant that old persona forever instead of ever asking
    -- again. Wipes it once per player (tracked by its own PData flag) so the
    -- picker shows up on their very next spawn as either character.
    local STALE_SAVED_PERSONA_KEYS = {"SavedPersona_citizen", "SavedPersona_student_a"}

    hook.Add(
        "PlayerInitialSpawn",
        "TBC_ClearStaleSavedPersonaMigration",
        function(ply)
            if ply:GetPData("TBC_Migration_ClearStalePersona_v1", "") == "1" then
                return
            end

            for _, key in ipairs(STALE_SAVED_PERSONA_KEYS) do
                ply:RemovePData(key)
            end

            ply:SetPData("TBC_Migration_ClearStalePersona_v1", "1")
        end
    )

    -- Weapon classnames essence actually granted this character-life. Essence
    -- items go through LoadoutItems[key].class indirection, so their final
    -- classname can't be recognized just by checking charData.loadoutItems
    -- pool-membership the way base weapons and personas can (personas have no
    -- such indirection). Tracked here so TBC_IsFreeCharacterItem
    -- (character_selection_sv.lua) can tell CanDropWeapon/CanStoreWeapon/
    -- Loadout Persistence "this is free, not player-owned" -- otherwise a
    -- player could drop/bank an essence item once and re-pick a duplicate of
    -- it next time. Reset on every character switch inside ApplyCharacterToPlayer.
    local function MarkEssenceWeapon(ply, itemClass)
        if not IsValid(ply) then
            return
        end
        ply.TBC_EssenceWeapons = ply.TBC_EssenceWeapons or {}
        ply.TBC_EssenceWeapons[itemClass] = true
    end

    hook.Add(
        "PlayerDisconnected",
        "ClearSavedLoadoutOnDisconnect",
        function(ply)
            local charId = ply:GetNWString("AssignedCharacter")
            ply:RemovePData("SavedLoadout_" .. charId)
            ply:RemovePData("SavedPersona_" .. charId)
        end
    )

    -- Death costs a player their Persona outright: it has to be re-earned,
    -- same as if they'd dropped the pickup item. Strips the equipped
    -- persona's skills/passives, wipes persona ownership, and clears the
    -- saved-persona PData so PlayerSpawn's savedPersona branch below doesn't
    -- just hand it straight back on respawn.
    --
    -- Exception: if the player checked "Save Persona" for their current
    -- character, that pick survives death too -- PlayerCharacterSetOnSpawn's
    -- savedPersona branch re-equips it identically on respawn regardless (it
    -- always strips and re-gives all weapons), so there's nothing to strip
    -- here and no PData to clear.
    hook.Add(
        "PlayerDeath",
        "TBC_StripPersonaOnDeath",
        function(victim)
            if not IsValid(victim) then
                return
            end

            local charId = victim:GetNWString("AssignedCharacter")
            if charId and charId ~= "" and victim:GetPData("SavedPersona_" .. charId) then
                return
            end

            local selectedPersona = victim:GetNW2String("selectedPersona", "")
            local personaData = Personas and Personas[selectedPersona]

            if personaData then
                for _, weaponClass in pairs(personaData.skills) do
                    local weapon = victim:GetWeapon(weaponClass)
                    if IsValid(weapon) then
                        weapon:Remove()
                    end
                end

                TBC_RemovePersonaPassives(victim, personaData)
            end

            victim:SetNW2String("selectedPersona", "")

            RemoveAllStats(victim, "personas")
            RemoveAllStats(victim, "permapersonas")

            if charId and charId ~= "" then
                victim:RemovePData("SavedPersona_" .. charId)
            end

            victim:ChatPrint("You have died and lost your Persona.")
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
                        MarkEssenceWeapon(ply, itemClass)
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

                                    local persona = Personas and Personas[itemClass]
                                    TBC_ApplyPersonaPassives(ply, persona)
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
                MarkEssenceWeapon(ply, itemClass)
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

                    TBC_ApplyPersonaPassives(ply, persona)

                    if saveLoadout then
                        local charId = ply:GetNWString("AssignedCharacter")
                        local personaSkills = {}
                        for k, v in pairs(persona.skills) do
                            personaSkills[k] = v
                        end
                        personaSkills["persona"] = selectedItem
                        ply:SetPData("SavedPersona_" .. charId, util.TableToJSON(personaSkills))
                    end
                end
            end
        end
    )
end
