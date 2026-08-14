-- ================================================================
-- CLIENT
-- ================================================================

local PANEL = {}
local TabMenu = nil

-- ----------------------------------------------------------------
--  Profession System (Client)
-- ----------------------------------------------------------------
local ClientPlayerProfession = "Cooking"
local ProfessionChangeTime = 0
local ProfessionCombo = nil

SMT_PROFESSIONS = {
    "Cooking",
    "Alchemy",
    "Crafting",
    "Genius"
}

net.Receive(
    "SyncProfession",
    function()
        ClientPlayerProfession = net.ReadString()
        if IsValid(ProfessionCombo) then
            ProfessionCombo:SetValue(ClientPlayerProfession)
        end
    end
)

function GetClientProfession()
    return ClientPlayerProfession
end

function SMT_GetPlayerProfession()
    return ClientPlayerProfession
end

function SetClientProfession(profession)
    net.Start("ChangeProfession")
    net.WriteString(profession)
    net.SendToServer()
end

-- ----------------------------------------------------------------
--  Inventory helpers (shared client-side state)
-- ----------------------------------------------------------------
local InventoryTable = {["Equipment"] = {}, ["Items"] = {}}
local detailFrame -- floating item detail window

function CheckIfWeaponJob(ply, itemClass, itemType)
    if IsValid(ply) then
        local charId = ply:GetNWString("AssignedCharacter")
        local charData = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charId]
        if not charData then
            return true
        end

        if itemType == "weapon" then
            for _, weapon in pairs(charData.weapons or {}) do
                if weapon == itemClass then
                    return false
                end
            end
        end

        if itemType == "passive" then
            if charData.permaBuffs then
                for ailmentName, ailmentInfo in pairs(charData.permaBuffs) do
                    if ailmentInfo.ClassName then
                        if ailmentInfo.ClassName == itemClass then
                            return false
                        end
                    end
                end
            end
        end
    end

    return true
end

function OpenItemDescriptionWindow(anchorFrame, itemClass)
    if IsValid(detailFrame) then
        detailFrame:Close()
    end

    detailFrame = vgui.Create("DFrame")

    local mx, my = TabMenu:GetPos()
    local mw, mh = TabMenu:GetSize()
    local bgColor = Color(44, 47, 51, 255)

    detailFrame:SetSize(400, mh)
    detailFrame:SetPos(mx + mw + 5, my)
    detailFrame:SetTitle("Item Details")
    detailFrame:MakePopup()
    detailFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, bgColor)
    end

    local scroll = vgui.Create("DScrollPanel", detailFrame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 30, 10, 10)

    -- Name
    local nameLabel = vgui.Create("DLabel", scroll)
    nameLabel:Dock(TOP)
    nameLabel:SetText(itemClass.name or "Unknown")
    nameLabel:SetFont("DermaLarge")
    nameLabel:SetTextColor(Color(255, 255, 255))
    nameLabel:DockMargin(0, 0, 0, 10)
    nameLabel:SetAutoStretchVertical(true)
    nameLabel:SetWrap(true)

    -- Separator
    local separator = vgui.Create("DPanel", scroll)
    separator:Dock(TOP)
    separator:SetTall(2)
    separator:DockMargin(0, 5, 0, 10)
    separator.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 200))
    end

    -- Description
    if itemClass.description and itemClass.description ~= "" then
        local descHeader = vgui.Create("DLabel", scroll)
        descHeader:Dock(TOP)
        descHeader:SetText("Description:")
        descHeader:SetFont("DermaDefaultBold")
        descHeader:SetTextColor(Color(200, 200, 200))
        descHeader:DockMargin(0, 0, 0, 5)

        local descLabel = vgui.Create("DLabel", scroll)
        descLabel:Dock(TOP)
        descLabel:SetText(itemClass.description)
        descLabel:SetTextColor(Color(220, 220, 220))
        descLabel:SetFont("DermaDefault")
        descLabel:SetAutoStretchVertical(true)
        descLabel:SetWrap(true)
        descLabel:DockMargin(0, 0, 0, 20)
    end
end

function OpenPersonaDetailWindow(anchorFrame, persona)
    if IsValid(detailFrame) then
        detailFrame:Close()
    end

    local personaData = Personas and Personas[persona]
    if not personaData then return end

    detailFrame = vgui.Create("DFrame")

    local mx, my = TabMenu:GetPos()
    local mw, mh = TabMenu:GetSize()
    local bgColor = Color(44, 47, 51, 255)

    detailFrame:SetSize(400, mh)
    detailFrame:SetPos(mx + mw + 5, my)
    detailFrame:SetTitle("Persona Details")
    detailFrame:MakePopup()
    detailFrame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, bgColor)
    end

    local scroll = vgui.Create("DScrollPanel", detailFrame)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 30, 10, 10)

    -- Name
    local nameLabel = vgui.Create("DLabel", scroll)
    nameLabel:Dock(TOP)
    nameLabel:SetText(personaData.name or persona)
    nameLabel:SetFont("DermaLarge")
    nameLabel:SetTextColor(Color(255, 255, 255))
    nameLabel:DockMargin(0, 0, 0, 10)
    nameLabel:SetAutoStretchVertical(true)
    nameLabel:SetWrap(true)

    -- Separator
    local separator = vgui.Create("DPanel", scroll)
    separator:Dock(TOP)
    separator:SetTall(2)
    separator:DockMargin(0, 5, 0, 10)
    separator.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 200))
    end

    -- Description
    if personaData.description and personaData.description ~= "" then
        local descHeader = vgui.Create("DLabel", scroll)
        descHeader:Dock(TOP)
        descHeader:SetText("Description:")
        descHeader:SetFont("DermaDefaultBold")
        descHeader:SetTextColor(Color(200, 200, 200))
        descHeader:DockMargin(0, 0, 0, 5)

        local descLabel = vgui.Create("DLabel", scroll)
        descLabel:Dock(TOP)
        descLabel:SetText(personaData.description)
        descLabel:SetTextColor(Color(220, 220, 220))
        descLabel:SetFont("DermaDefault")
        descLabel:SetAutoStretchVertical(true)
        descLabel:SetWrap(true)
        descLabel:DockMargin(0, 0, 0, 20)
    end

    -- Skills
    if personaData.skills and #personaData.skills > 0 then
        local skillsHeader = vgui.Create("DLabel", scroll)
        skillsHeader:Dock(TOP)
        skillsHeader:SetText("Skills:")
        skillsHeader:SetFont("DermaDefaultBold")
        skillsHeader:SetTextColor(Color(200, 200, 200))
        skillsHeader:DockMargin(0, 0, 0, 5)

        for _, skillClass in ipairs(personaData.skills) do
            local wepData = weapons and weapons.Get and weapons.Get(skillClass)

            local skillPanel = vgui.Create("DPanel", scroll)
            skillPanel:Dock(TOP)
            skillPanel:DockMargin(5, 2, 5, 2)
            skillPanel.Paint = function() end

            local skillText = ""
            if wepData then
                local wname    = wepData.PrintName or skillClass
                local typeInfo = ""
                if wepData.WeaponType then
                    typeInfo = " (" .. wepData.WeaponType .. ")"
                    if wepData.MPCost and wepData.MPCost > 0 then typeInfo = typeInfo .. " (" .. wepData.MPCost .. " MP)" end
                    if wepData.HPCost and wepData.HPCost > 0 then typeInfo = typeInfo .. " (" .. wepData.HPCost .. " HP)" end
                    if wepData.Tech   and wepData.Tech   > 0 then typeInfo = typeInfo .. " (" .. wepData.Tech   .. " Technique)" end
                end
                skillText = wname .. typeInfo
                if wepData.Purpose and wepData.Purpose ~= "" then
                    skillText = skillText .. "\n" .. wepData.Purpose
                end
            else
                skillText = skillClass
            end

            local skillLabel = vgui.Create("DLabel", skillPanel)
            skillLabel:Dock(FILL)
            skillLabel:SetText(skillText)
            skillLabel:SetTextColor(Color(220, 220, 220))
            skillLabel:SetFont("DermaDefault")
            skillLabel:SetWrap(true)
            skillLabel:SetAutoStretchVertical(true)
            skillLabel:DockMargin(5, 5, 5, 5)

            local lines = 1
            for _ in string.gmatch(skillText, "\n") do lines = lines + 1 end
            skillPanel:SetTall((draw.GetFontHeight("DermaDefault") * lines) + 20)
        end
    end
end

-- ================================================================
--  HUD: entity name above crosshair
-- ================================================================
hook.Add(
    "HUDPaint",
    "TBC_ShowEntityInfoHUD",
    function()
        local ply = LocalPlayer()
        if not IsValid(ply) then
            return
        end

        local tr =
            util.TraceLine(
            {
                start = ply:EyePos(),
                endpos = ply:EyePos() + ply:GetAimVector() * 200,
                filter = ply
            }
        )

        if not IsValid(tr.Entity) then
            return
        end

        local ent = tr.Entity
        local name = ent:GetNWString("PrintName", false)
        if name then
            local x = ScrW() / 2
            local y = ScrH() / 2 + 60

            draw.SimpleText(name, "TargetID", x + 1, y + 1, Color(0, 0, 0, 180), TEXT_ALIGN_CENTER)
            draw.SimpleText(name, "TargetID", x, y, Color(255, 255, 255), TEXT_ALIGN_CENTER)
        end
    end
)

-- ================================================================
--  Tab Menu Panel
-- ================================================================
function PANEL:Init()
    self:SetSize(1300, 800)
    self:SetPos(ScrW() * 0.05, (ScrH() - 800) / 2)
    self:SetTitle("Menu")
    self:SetVisible(false)
    self:SetDraggable(true)
    self:ShowCloseButton(true)
    self:MakePopup()

    self.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(40, 40, 40, 240))
    end

    self.Sidebar = vgui.Create("DPanel", self)
    self.Sidebar:Dock(LEFT)
    self.Sidebar:SetWide(150)
    self.Sidebar:DockMargin(5, 5, 5, 5)
    self.Sidebar.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
    end

    self.Content = vgui.Create("DPanel", self)
    self.Content:Dock(FILL)
    self.Content:DockMargin(0, 5, 5, 5)
    self.Content.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
    end

    self.Tabs = {}
    self.ActiveTab = nil

    self:AddTab("Player",     "icon16/user_suit.png")
    self:AddTab("Party",      "icon16/group_key.png")
    self:AddTab("Inventory",  "icon16/briefcase.png")
    self:AddTab("Characters", "icon16/group.png")
    self:AddTab("Scoreboard", "icon16/user.png")
    self:AddTab("Settings",   "icon16/cog.png")

    if self.Tabs[1] then
        self:SelectTab(self.Tabs[1])
    end

    -- Request profession data from server
    net.Start("RequestProfessionData")
    net.SendToServer()
end

function PANEL:AddTab(name, icon)
    local btn = vgui.Create("DButton", self.Sidebar)
    btn:Dock(TOP)
    btn:SetTall(40)
    btn:DockMargin(5, 5, 5, 0)
    btn:SetText("")
    btn.TabName = name
    btn.Icon = Material(icon or "icon16/page.png")

    btn.Paint = function(s, w, h)
        local bgColor = Color(60, 60, 60, 255)
        if s:IsHovered() then
            bgColor = Color(70, 70, 70, 255)
        end
        if s == self.ActiveTab then
            bgColor = Color(80, 120, 180, 255)
        end
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        surface.SetDrawColor(255, 255, 255, 255)
        surface.SetMaterial(s.Icon)
        surface.DrawTexturedRect(8, 12, 16, 16)
        draw.SimpleText(s.TabName, "DermaDefault", 30, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    btn.DoClick = function(s)
        self:SelectTab(s)
    end
    table.insert(self.Tabs, btn)
    return btn
end

function PANEL:SelectTab(tab)
    if self.ActiveTab == tab then
        return
    end
    self.ActiveTab = tab

    -- Close any open detail window when switching tabs
    if IsValid(detailFrame) then
        detailFrame:Close()
    end

    if IsValid(self.Content) then
        self.Content:Clear()
    end

    if tab.TabName == "Player" then
        self:LoadPlayerContent()
    elseif tab.TabName == "Party" then
        self:LoadPartyContent()
    elseif tab.TabName == "Characters" then
        self:LoadCharactersContent()
    elseif tab.TabName == "Inventory" then
        self:LoadInventoryContent()
    elseif tab.TabName == "Scoreboard" then
        self:LoadScoreboardContent()
    elseif tab.TabName == "Settings" then
        self:LoadSettingsContent()
    end
end

-- ----------------------------------------------------------------
--  Player tab
-- ----------------------------------------------------------------
function PANEL:LoadPlayerContent()
    local ply = LocalPlayer()

    local scroll = vgui.Create("DScrollPanel", self.Content)
    scroll:Dock(FILL)
    scroll:DockMargin(20, 20, 20, 20)

    local function SectionHeader(text)
        local lbl = vgui.Create("DLabel", scroll)
        lbl:Dock(TOP)
        lbl:SetText(text)
        lbl:SetFont("DermaDefaultBold")
        lbl:SetTextColor(Color(180, 180, 180))
        lbl:DockMargin(0, 14, 0, 4)
        lbl:SetAutoStretchVertical(true)
    end

    local KEY_W = 160
    local function DataRow(key, value, valueColor)
        local row = vgui.Create("DPanel", scroll)
        row:Dock(TOP)
        row:SetTall(26)
        row:DockMargin(0, 2, 0, 2)
        local cv = tostring(value or "")
        local cc = valueColor or Color(230, 230, 230)
        row.Paint = function(s, w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(45, 45, 45, 200))
            draw.SimpleText(key, "DermaDefault", 10, h / 2, Color(160, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(cv, "DermaDefault", KEY_W + 20, h / 2, cc, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end
        function row:SetValue(v, c)
            cv = tostring(v or "")
            if c then cc = c end
        end
        return row
    end

    SectionHeader("Identity")
    DataRow("Username", ply:Nick(), Color(255, 255, 255))
    DataRow("Steam ID", ply:SteamID(), Color(180, 200, 255))

    -- ================================================================
    --  Profession Selection
    -- ================================================================
    SectionHeader("Profession")
    
    local professionPanel = vgui.Create("DPanel", scroll)
    professionPanel:Dock(TOP)
    professionPanel:SetTall(40)
    professionPanel:DockMargin(0, 2, 0, 2)
    professionPanel.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(45, 45, 45, 200))
    end

    local profLabel = vgui.Create("DLabel", professionPanel)
    profLabel:Dock(LEFT)
    profLabel:SetText("Current Profession:")
    profLabel:SetFont("DermaDefault")
    profLabel:SetTextColor(Color(160, 160, 160))
    profLabel:SetWide(KEY_W)
    profLabel:DockMargin(10, 0, 0, 0)

    local profCombo = vgui.Create("DComboBox", professionPanel)
    profCombo:Dock(FILL)
    profCombo:DockMargin(10, 5, 10, 5)

    -- Add profession options
    if SMT_PROFESSIONS then
        for _, prof in ipairs(SMT_PROFESSIONS) do
            profCombo:AddChoice(prof)
        end
    end

    ProfessionCombo = profCombo
    local currentProfession = GetClientProfession()
    profCombo:SetValue(currentProfession)

    -- Track when the combo box value changes
    local lastComboValue = currentProfession
    profCombo.OnSelect = function(self, index, value)
        if value ~= lastComboValue then
            local currentTime = CurTime()
            if currentTime < ProfessionChangeTime then
                local remainingTime = math.ceil(ProfessionChangeTime - currentTime)
                ply:ChatPrint("You can change professions again in " .. remainingTime .. " seconds.")
                profCombo:SetValue(lastComboValue)
                return
            end

            lastComboValue = value
            ProfessionChangeTime = currentTime + 5
            SetClientProfession(value)
        end
    end

    local hasCharSystem = CHARACTERS ~= nil and CHARACTERS.List ~= nil
    if hasCharSystem then
        SectionHeader("Character")
        local charID = ply:GetNWString("AssignedCharacter", "")
        local charData = charID ~= "" and CHARACTERS.List[charID] or nil

        if charData then
            local charColor =
                charData.color and Color(charData.color.r, charData.color.g, charData.color.b) or Color(230, 230, 230)
            DataRow("Character", charData.name, charColor)
            DataRow("Category", charData.category or "?")
            DataRow("Type", charData.type or "?")
        else
            DataRow("Character", "None assigned", Color(150, 150, 150))
        end

        if TBC_CURRENCY then
            local cfg = TBC_CURRENCY.LocalConfig or {}
            local sym = cfg.Symbol or "ћ"
            local cname = cfg.Name or "Macca"
            local bal = TBC_CURRENCY.LocalBalance or 0
            local balStr = TBC_CURRENCY.FormatBalance and TBC_CURRENCY.FormatBalance(bal) or (sym .. tostring(bal))
            local balRow = DataRow(cname, balStr, Color(255, 215, 0))

            local hookKey = "PlayerTab_Bal_" .. tostring(self)
            hook.Add(
                "TBC_CurrencyBalanceUpdated",
                hookKey,
                function(newBal)
                    if not IsValid(balRow) then
                        hook.Remove("TBC_CurrencyBalanceUpdated", hookKey)
                        return
                    end
                    local newStr =
                        TBC_CURRENCY.FormatBalance and TBC_CURRENCY.FormatBalance(newBal) or (sym .. tostring(newBal))
                    balRow:SetValue(newStr, Color(255, 215, 0))
                end
            )

            local origRemove = self.OnRemove
            self.OnRemove = function(s)
                hook.Remove("TBC_CurrencyBalanceUpdated", hookKey)
                if origRemove then origRemove(s) end
            end
        end
    elseif TBC_CURRENCY then
        SectionHeader("Wallet")
        local cfg = TBC_CURRENCY.LocalConfig or {}
        local sym = cfg.Symbol or "ћ"
        local cname = cfg.Name or "Macca"
        local bal = TBC_CURRENCY.LocalBalance or 0
        local balStr = TBC_CURRENCY.FormatBalance and TBC_CURRENCY.FormatBalance(bal) or (sym .. tostring(bal))
        local balRow = DataRow(cname, balStr, Color(255, 215, 0))

        local hookKey = "PlayerTab_Bal_" .. tostring(self)
        hook.Add(
            "TBC_CurrencyBalanceUpdated",
            hookKey,
            function(newBal)
                if not IsValid(balRow) then
                    hook.Remove("TBC_CurrencyBalanceUpdated", hookKey)
                    return
                end
                local newStr =
                    TBC_CURRENCY.FormatBalance and TBC_CURRENCY.FormatBalance(newBal) or (sym .. tostring(newBal))
                balRow:SetValue(newStr, Color(255, 215, 0))
            end
        )

        local origRemove = self.OnRemove
        self.OnRemove = function(s)
            hook.Remove("TBC_CurrencyBalanceUpdated", hookKey)
            if origRemove then origRemove(s) end
        end
    end

    local hasCharSystem2 = CHARACTERS ~= nil and CHARACTERS.List ~= nil
    local charID2 = hasCharSystem2 and ply:GetNWString("AssignedCharacter", "") or ""
    local charData2 = (charID2 ~= "" and CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID2]) or nil

    local function nwOrBase(nwKey, baseVal)
        local v = ply:GetNWInt(nwKey, -1)
        if v ~= -1 then return v end
        return baseVal or 0
    end

    SectionHeader("Stats")

    local maxHP = nwOrBase("TBCMAXHP", charData2 and charData2.combatHP or 0)
    local maxMP = nwOrBase("TBCMAXMP", charData2 and charData2.combatMP or 0)
    local curHP = nwOrBase("TBCHP", maxHP)
    local curMP = nwOrBase("TBCMP", maxMP)
    local lck   = nwOrBase("TBCLuck", charData2 and charData2.Luck or 0)
    local tec   = nwOrBase("TBCTechnique", charData2 and charData2.Technique or 0)
    local eqs   = nwOrBase("TBCEquipmentSlots", charData2 and charData2.equipmentSlots or 0)
    local its   = nwOrBase("TBCItemSlots", charData2 and charData2.itemSlots or 0)

    if maxHP > 0 then DataRow("HP",              curHP .. " / " .. maxHP, Color(100, 220, 100)) end
    if maxMP > 0 then DataRow("MP",              curMP .. " / " .. maxMP, Color(100, 160, 255)) end
    if lck   > 0 then DataRow("Luck",            lck,                     Color(230, 200, 100)) end
    if tec   > 0 then DataRow("Technique",       tec,                     Color(180, 140, 220)) end
    if eqs   > 0 then DataRow("Equipment Slots", eqs) end
    if its   > 0 then DataRow("Item Slots",      its) end

    if GetAllStatsClient then
        local effectTypes = {
            {label = "Buffs",     statType = "buffs",        col = Color(100, 220, 100)},
            {label = "Debuffs",   statType = "debuffs",      col = Color(220, 100, 100)},
            {label = "Passives",  statType = "permabuffs",   col = Color(150, 255, 150)},
            {label = "Ailments",  statType = "permadebuffs", col = Color(255, 150, 150)}
        }

        local hasAny = false
        for _, et in ipairs(effectTypes) do
            local entries = GetAllStatsClient(ply, et.statType)
            if entries and table.Count(entries) > 0 then
                hasAny = true
                break
            end
        end

        if hasAny then
            SectionHeader("Active Effects")

            local lineH = draw.GetFontHeight("DermaDefault")

            for _, et in ipairs(effectTypes) do
                local entries = GetAllStatsClient(ply, et.statType)
                if entries and table.Count(entries) > 0 then
                    local names = {}
                    for k, _ in pairs(entries) do
                        table.insert(names, k)
                    end
                    table.sort(names)

                    local rowCount = math.ceil(#names / 3)
                    local row = vgui.Create("DPanel", scroll)
                    row:Dock(TOP)
                    row:DockMargin(0, 2, 0, 2)
                    row:SetTall(math.max(26, lineH * rowCount + 10))

                    local label = et.label
                    local col = et.col
                    row.Paint = function(s, w, h)
                        draw.RoundedBox(3, 0, 0, w, h, Color(45, 45, 45, 200))
                        draw.SimpleText(label, "DermaDefault", 10, 5 + lineH / 2, Color(160, 160, 160), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        local colW = (w - KEY_W - 30) / 3
                        for i, name in ipairs(names) do
                            local ci = (i - 1) % 3
                            local ri = math.floor((i - 1) / 3)
                            draw.SimpleText(name, "DermaDefault", KEY_W + 20 + ci * colW, 5 + ri * lineH, col, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        end
                    end
                end
            end
        end
    end
end

-- ----------------------------------------------------------------
--  Party tab
-- ----------------------------------------------------------------
function PANEL:LoadPartyContent()
    local ply = LocalPlayer()

    local container = vgui.Create("DPanel", self.Content)
    container:Dock(FILL)
    container:DockMargin(20, 20, 20, 20)
    container.Paint = function() end

    -- Sends a leader-only action (kick/promote/move/disband) to the server.
    local function SendPartyAction(partyId, action, targetSteamID, newPosition)
        net.Start("PlayerPartyModify")
        net.WriteString(partyId)
        net.WriteString(action)
        net.WriteString(targetSteamID or "")
        net.WriteUInt(newPosition or 0, 16)
        net.SendToServer()
    end

    -- Opens a player picker used to send a party invite. existingMembers (if given) is the
    -- current party's Members table, used to hide players who are already in the party.
    local function OpenInvitePicker(existingMembers)
        local menu = DermaMenu()
        local any = false

        for _, target in ipairs(player.GetAll()) do
            if IsValid(target) and target ~= ply then
                local alreadyMember = existingMembers and existingMembers[target:SteamID()]
                if not alreadyMember then
                    any = true
                    menu:AddOption(target:Nick(), function()
                        net.Start("PartyInviteRequest")
                        net.WriteEntity(target)
                        net.SendToServer()
                    end)
                end
            end
        end

        if not any then
            local opt = menu:AddOption("No players available", function() end)
            opt:SetEnabled(false)
        end

        menu:Open()
    end

    local function BuildUI()
        if not IsValid(container) then return end
        container:Clear()

        local partyId = IsPlayerInAnyPartyClient and IsPlayerInAnyPartyClient(ply)
        local partyData = partyId and GetAllPartyDataClient(ply, partyId) or nil

        if not partyData or not partyData.Members then
            local header = vgui.Create("DLabel", container)
            header:Dock(TOP)
            header:SetFont("DermaLarge")
            header:SetTextColor(Color(255, 255, 255))
            header:SetContentAlignment(5)
            header:DockMargin(0, 0, 0, 10)
            header:SetAutoStretchVertical(true)
            header:SetText("Party")

            local info = vgui.Create("DLabel", container)
            info:Dock(TOP)
            info:SetText("You are not currently in a party.")
            info:SetTextColor(Color(180, 180, 180))
            info:DockMargin(0, 0, 0, 15)
            info:SetAutoStretchVertical(true)

            local createBtn = vgui.Create("DButton", container)
            createBtn:Dock(TOP)
            createBtn:SetTall(36)
            createBtn:SetWide(180)
            createBtn:SetContentAlignment(5)
            createBtn:SetText("Create Party")
            createBtn.Paint = function(s, w, h)
                local bg = Color(80, 180, 120, 255)
                if s:IsHovered() then bg = Color(100, 200, 140, 255) end
                draw.RoundedBox(6, 0, 0, w, h, bg)
            end
            createBtn.DoClick = function()
                RunConsoleCommand("partycreate")
            end

            local inviteBtn = vgui.Create("DButton", container)
            inviteBtn:Dock(TOP)
            inviteBtn:SetTall(36)
            inviteBtn:SetWide(180)
            inviteBtn:DockMargin(0, 8, 0, 0)
            inviteBtn:SetContentAlignment(5)
            inviteBtn:SetText("Invite Player")
            inviteBtn.Paint = function(s, w, h)
                local bg = Color(80, 120, 180, 255)
                if s:IsHovered() then bg = Color(100, 140, 200, 255) end
                draw.RoundedBox(6, 0, 0, w, h, bg)
            end
            inviteBtn.DoClick = function()
                OpenInvitePicker(nil)
            end

            return
        end

        local isLeader = partyData.PartyLead == ply:SteamID()
        local order = partyData.Order or {}
        local partyName = partyData.PartyName or "Party"

        if isLeader then
            local header = vgui.Create("DButton", container)
            header:Dock(TOP)
            header:SetTall(28)
            header:DockMargin(0, 0, 0, 10)
            header:SetText("")
            header:SetCursor("hand")
            header:SetTooltip("Click to rename your party")
            header.Paint = function(s, w, h)
                draw.SimpleText(partyName, "DermaLarge", w / 2, h / 2, Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            header.DoClick = function()
                Derma_StringRequest(
                    "Rename Party",
                    "Enter a new party name:",
                    partyName,
                    function(newName)
                        SendPartyAction(partyId, "rename", newName)
                    end,
                    function() end,
                    "Rename",
                    "Cancel"
                )
            end
        else
            local header = vgui.Create("DLabel", container)
            header:Dock(TOP)
            header:SetFont("DermaLarge")
            header:SetTextColor(Color(255, 255, 255))
            header:SetContentAlignment(5)
            header:DockMargin(0, 0, 0, 10)
            header:SetText(partyName)
        end

        local kdLimit = GetPartyKilodevilLimit and GetPartyKilodevilLimit() or 500
        local kdTotal = partyData.TotalKilodevil or 0

        local kdLabel = vgui.Create("DLabel", container)
        kdLabel:Dock(TOP)
        kdLabel:SetFont("DermaDefault")
        kdLabel:SetContentAlignment(5)
        kdLabel:DockMargin(0, 0, 0, 10)
        kdLabel:SetText("Kilodevil: " .. kdTotal .. " / " .. kdLimit)
        kdLabel:SetTextColor(kdTotal > kdLimit and Color(220, 100, 100) or Color(160, 160, 160))

        local scroll = vgui.Create("DScrollPanel", container)
        scroll:Dock(FILL)
        scroll:DockMargin(0, 0, 0, 10)

        local ROW_H = 60

        for placement, steamID in ipairs(order) do
            local member = partyData.Members[steamID]
            local isSelf = IsValid(member) and member == ply

            local row = vgui.Create("DPanel", scroll)
            row:Dock(TOP)
            row:SetTall(ROW_H)
            row:DockMargin(0, 3, 0, 3)
            row.Paint = function(s, w, h)
                local bg = isSelf and Color(55, 65, 80, 220) or Color(45, 45, 45, 200)
                draw.RoundedBox(4, 0, 0, w, h, bg)
            end

            local placementLbl = vgui.Create("DLabel", row)
            placementLbl:Dock(LEFT)
            placementLbl:SetWide(36)
            placementLbl:SetText("#" .. placement)
            placementLbl:SetFont("DermaDefaultBold")
            placementLbl:SetTextColor(Color(180, 180, 180))
            placementLbl:SetContentAlignment(5)

            if isLeader then
                local gearBtn = vgui.Create("DButton", row)
                gearBtn:Dock(RIGHT)
                gearBtn:SetWide(ROW_H)
                gearBtn:DockMargin(4, 4, 4, 4)
                gearBtn:SetText("")

                local gearIcon = Material("icon16/cog.png")
                gearBtn.Paint = function(s, w, h)
                    local bg = Color(60, 60, 60, 255)
                    if s:IsHovered() then bg = Color(80, 80, 80, 255) end
                    draw.RoundedBox(4, 0, 0, w, h, bg)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(gearIcon)
                    surface.DrawTexturedRect(w / 2 - 8, h / 2 - 8, 16, 16)
                end

                gearBtn.DoClick = function()
                    local menu = DermaMenu()

                    local moveMenu = menu:AddSubMenu("Move To Placement")
                    moveMenu:SetDeleteSelf(true)
                    for pos = 1, #order do
                        if pos ~= placement then
                            moveMenu:AddOption("Placement #" .. pos, function()
                                SendPartyAction(partyId, "move", steamID, pos)
                            end)
                        end
                    end

                    if not isSelf then
                        menu:AddOption("Make Party Leader", function()
                            SendPartyAction(partyId, "promote", steamID)
                        end)

                        menu:AddOption("Kick From Party", function()
                            SendPartyAction(partyId, "kick", steamID)
                        end)
                    end

                    menu:Open()
                end
            end

            if IsValid(member) then
                local avatarWrap = vgui.Create("DPanel", row)
                avatarWrap:Dock(LEFT)
                avatarWrap:SetWide(ROW_H)
                avatarWrap.Paint = function() end

                local avatar = vgui.Create("AvatarImage", avatarWrap)
                avatar:SetSize(ROW_H - 8, ROW_H - 8)
                avatar:SetPos(4, 4)
                avatar:SetPlayer(member, 64)

                local modelWrap = vgui.Create("DPanel", row)
                modelWrap:Dock(LEFT)
                modelWrap:SetWide(ROW_H)
                modelWrap.Paint = function() end

                local modelIcon = vgui.Create("SpawnIcon", modelWrap)
                modelIcon:SetSize(ROW_H - 8, ROW_H - 8)
                modelIcon:SetPos(4, 4)
                modelIcon:SetModel(member:GetModel() or "models/player/group01/male_01.mdl")
                modelIcon:SetMouseInputEnabled(false)
                modelIcon:SetKeyboardInputEnabled(false)
                modelIcon:SetTooltip(false)

                local nameLbl = vgui.Create("DLabel", row)
                nameLbl:Dock(FILL)
                nameLbl:DockMargin(10, 0, 5, 0)
                local nameText = member:Nick()
                if partyData.PartyLead == steamID then
                    nameText = nameText .. "  (Leader)"
                end
                nameLbl:SetText(nameText)
                nameLbl:SetFont("DermaDefaultBold")
                nameLbl:SetTextColor(partyData.PartyLead == steamID and Color(255, 215, 0) or Color(230, 230, 230))
                nameLbl:SetContentAlignment(4)
            else
                local nameLbl = vgui.Create("DLabel", row)
                nameLbl:Dock(FILL)
                nameLbl:DockMargin(10, 0, 5, 0)
                nameLbl:SetText("Unknown / Offline")
                nameLbl:SetFont("DermaDefault")
                nameLbl:SetTextColor(Color(140, 140, 140))
                nameLbl:SetContentAlignment(4)
            end
        end

        local footer = vgui.Create("DPanel", container)
        footer:Dock(BOTTOM)
        footer:SetTall(46)
        footer:DockMargin(0, 10, 0, 0)
        footer.Paint = function() end

        if isLeader then
            local inviteBtn = vgui.Create("DButton", footer)
            inviteBtn:Dock(LEFT)
            inviteBtn:SetWide(140)
            inviteBtn:SetText("Invite Player")
            inviteBtn.Paint = function(s, w, h)
                local bg = Color(70, 110, 170, 255)
                if s:IsHovered() then bg = Color(90, 130, 190, 255) end
                draw.RoundedBox(6, 0, 0, w, h, bg)
            end
            inviteBtn.DoClick = function()
                OpenInvitePicker(partyData.Members)
            end

            local disbandBtn = vgui.Create("DButton", footer)
            disbandBtn:Dock(RIGHT)
            disbandBtn:SetWide(160)
            disbandBtn:SetText("Disband Party")
            disbandBtn.Paint = function(s, w, h)
                local bg = Color(180, 70, 70, 255)
                if s:IsHovered() then bg = Color(200, 90, 90, 255) end
                draw.RoundedBox(6, 0, 0, w, h, bg)
            end
            disbandBtn.DoClick = function()
                Derma_Query(
                    "Are you sure you want to disband the party?",
                    "Disband Party",
                    "Yes", function() SendPartyAction(partyId, "disband") end,
                    "No", function() end
                )
            end
        else
            local leaveBtn = vgui.Create("DButton", footer)
            leaveBtn:Dock(RIGHT)
            leaveBtn:SetWide(140)
            leaveBtn:SetText("Leave Party")
            leaveBtn.Paint = function(s, w, h)
                local bg = Color(120, 60, 60, 255)
                if s:IsHovered() then bg = Color(140, 80, 80, 255) end
                draw.RoundedBox(6, 0, 0, w, h, bg)
            end
            leaveBtn.DoClick = function()
                RunConsoleCommand("partyleave")
            end
        end
    end

    -- Keep the tab live as party data changes (created/joined/kicked/reordered/disbanded)
    local hookKey = "TabMenu_PartyRefresh_" .. tostring(self)
    hook.Add("TBC_PartyDataUpdated", hookKey, BuildUI)

    local origRemove = self.OnRemove
    self.OnRemove = function(s)
        hook.Remove("TBC_PartyDataUpdated", hookKey)
        if origRemove then origRemove(s) end
    end

    BuildUI()
end

-- ----------------------------------------------------------------
--  Inventory tab
-- ----------------------------------------------------------------
function PANEL:LoadInventoryContent()
    local bgColor     = Color(44, 47, 51, 255)
    local headerColor = Color(60, 63, 68, 255)

    -- Sub-tab sheet
    local sheet = vgui.Create("DPropertySheet", self.Content)
    sheet:Dock(FILL)
    sheet:DockMargin(5, 5, 5, 5)
    sheet.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
    end

    sheet.OnActiveTabChanged = function(s, oldTab, newTab)
        if IsValid(detailFrame) then
            detailFrame:Close()
        end
    end

    local origRemove = self.OnRemove
    self.OnRemove = function(s)
        if IsValid(detailFrame) then
            detailFrame:Close()
        end
        if origRemove then origRemove(s) end
    end

    local equipmentPanel = vgui.Create("DPanel", sheet)
    local itemsPanel     = vgui.Create("DPanel", sheet)
    local personasPanel  = vgui.Create("DPanel", sheet)
    local resourcesPanel = vgui.Create("DPanel", sheet)   -- NEW

    sheet:AddSheet("Equipment", equipmentPanel, "icon16/gun.png")
    sheet:AddSheet("Items",     itemsPanel,     "icon16/gun.png")
    sheet:AddSheet("Personas",  personasPanel,  "icon16/user_suit.png")
    sheet:AddSheet("Resources", resourcesPanel, "icon16/box.png")  -- NEW

    -- Shared grid painter
    local function GridPaint(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, bgColor)
    end

    -- DGrid sizes itself to fit its items (PerformLayout calls SetWide/SetTall
    -- based on item count -- see lua/vgui/dgrid.lua), which fights Dock(FILL):
    -- with few items the grid collapses to a small box instead of filling the
    -- tab. The working pattern elsewhere in this codebase (dialogue_entity's
    -- cl_storage_ui.lua) is to dock a DScrollPanel FILL and let the DGrid
    -- self-size inside it, uncontested.
    local function MakeGridTab(panel)
        panel.Paint = function(s, w, h) draw.RoundedBox(6, 0, 0, w, h, bgColor) end

        local scroll = vgui.Create("DScrollPanel", panel)
        scroll:Dock(FILL)

        local grid = vgui.Create("DGrid", scroll)
        grid:SetCols(10)
        grid:SetColWide(64)
        grid:SetRowHeight(64)
        grid:SetWide(10 * 64)
        grid.Paint = GridPaint

        return grid
    end

    -- ---- Equipment ----
    local equipmentGrid = MakeGridTab(equipmentPanel)

    -- ---- Items ----
    local itemGrid = MakeGridTab(itemsPanel)

    -- ---- Personas ----
    local personasGrid = MakeGridTab(personasPanel)

    -- ---- Resources ---- (NEW)
    resourcesPanel.Paint = function(s, w, h) draw.RoundedBox(6, 0, 0, w, h, bgColor) end

    local ROW_H     = 36
    local BAR_MAX_W = 300   -- width that represents a full stack (1000)
    local CAP       = 1000

    -- Header strip
    local headerStrip = vgui.Create("DPanel", resourcesPanel)
    headerStrip:Dock(TOP)
    headerStrip:SetTall(32)
    headerStrip:DockMargin(10, 8, 10, 0)
    headerStrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, headerColor)
        draw.SimpleText("Resource",  "DermaDefaultBold", 10,          h / 2, Color(180, 180, 180), TEXT_ALIGN_LEFT,   TEXT_ALIGN_CENTER)
        draw.SimpleText("Amount",    "DermaDefaultBold", w - 230,     h / 2, Color(180, 180, 180), TEXT_ALIGN_LEFT,   TEXT_ALIGN_CENTER)
        draw.SimpleText("Capacity",  "DermaDefaultBold", w - 150,     h / 2, Color(180, 180, 180), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local scroll = vgui.Create("DScrollPanel", resourcesPanel)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 6, 10, 10)

    -- Populates (or re-populates) the scroll panel with the current resources.
    local function RefreshResources()
        scroll:Clear()

        local ply       = LocalPlayer()
        local resources = GetAllResourcesByPlayerClient and GetAllResourcesByPlayerClient(ply) or {}
        local sorted    = {}

        for resType, amount in pairs(resources) do
            table.insert(sorted, {resType = resType, amount = amount})
        end

        -- Alphabetical order for stable display
        table.sort(sorted, function(a, b) return a.resType < b.resType end)

        if #sorted == 0 then
            local emptyLabel = vgui.Create("DLabel", scroll)
            emptyLabel:Dock(TOP)
            emptyLabel:SetTall(40)
            emptyLabel:SetText("You have no resources.")
            emptyLabel:SetFont("DermaDefault")
            emptyLabel:SetTextColor(Color(150, 150, 150))
            emptyLabel:SetContentAlignment(5)
            return
        end

        for _, entry in ipairs(sorted) do
            local resType = entry.resType
            local amount  = entry.amount

            -- Capitalise first letter for display
            local displayName = string.upper(string.sub(resType, 1, 1)) ..
                                string.sub(resType, 2)

            local fraction = math.Clamp(amount / CAP, 0, 1)

            -- Colour the bar: green at low fill, shifting to amber at 75 %+, red at cap
            local function BarColor(frac)
                if frac >= 1 then
                    return Color(220, 60, 60, 255)
                elseif frac >= 0.75 then
                    return Color(220, 160, 40, 255)
                else
                    return Color(60, 180, 80, 255)
                end
            end

            local row = vgui.Create("DPanel", scroll)
            row:Dock(TOP)
            row:SetTall(ROW_H)
            row:DockMargin(0, 2, 0, 2)

            -- Capture values for the Paint closure
            local capturedAmount   = amount
            local capturedFraction = fraction
            local capturedName     = displayName

            row.Paint = function(s, w, h)
                -- Row background, alternating shades
                draw.RoundedBox(4, 0, 0, w, h, Color(50, 53, 58, 220))

                -- Resource name
                draw.SimpleText(capturedName, "DermaDefault",
                    10, h / 2,
                    Color(220, 220, 220), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Numeric amount + cap
                local amtStr = tostring(capturedAmount) .. " / " .. tostring(CAP)
                draw.SimpleText(amtStr, "DermaDefault",
                    w - 230, h / 2,
                    Color(200, 200, 200), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                -- Bar background
                local barX = w - 155
                local barY = (h - 14) / 2
                draw.RoundedBox(3, barX,     barY, BAR_MAX_W, 14, Color(30, 30, 30, 200))

                -- Bar fill
                local fillW = math.max(0, math.floor(BAR_MAX_W * capturedFraction))
                if fillW > 0 then
                    draw.RoundedBox(3, barX, barY, fillW, 14, BarColor(capturedFraction))
                end
            end
        end
    end

    -- Initial population
    RefreshResources()

    -- Re-populate whenever a resource update comes in so the tab stays live
    -- (net.Receive already fires globally; we hook the HUDPaint tick while
    --  this panel is visible as a lightweight poll — avoids a global hook leak)
    local lastPoll  = 0
    local POLL_RATE = 2  -- seconds between polls while the tab is open

    resourcesPanel.Think = function(s)
        if not s:IsVisible() then return end
        if CurTime() - lastPoll < POLL_RATE then return end
        lastPoll = CurTime()
        RefreshResources()
    end

    -- ----------------------------------------------------------------
    -- Reference to the Content panel so detail window can anchor to it
    -- ----------------------------------------------------------------
    local anchorPanel = self.Content

    -- ----------------------------------------------------------------
    --  updateEquippedItems
    -- ----------------------------------------------------------------
    local function updateEquippedItems()
        local ply = LocalPlayer()
        equipmentGrid:Clear()
        local localEquip = {}

        for _, weapon in pairs(ply:GetWeapons()) do
            if weapon.SlotType == "Equipment" then
                localEquip[weapon:GetClass()] = {name = weapon:GetClass(), type = "swep"}
            end
        end

        local buffs = GetAllStatsClient(ply, "permabuffs")
        if buffs then
            for ailmentName, ailmentInfo in pairs(buffs) do
                if ailmentInfo.SlotType == "Equipment" then
                    localEquip[ailmentName] = {name = ailmentName, type = "passive"}
                end
            end
        end

        for equipment, properties in pairs(localEquip) do
            local weaponData  = false
            local passiveData = false

            if properties.type == "swep" then
                weaponData = weapons and weapons.Get and weapons.Get(equipment)
            elseif properties.type == "passive" then
                passiveData = Passives and Passives[equipment]
            end

            local equipmentData = {}

            if weaponData then
                equipmentData.name        = weaponData.PrintName
                equipmentData.description = weaponData.Purpose
                local iconPath = "materials/entities/" .. equipment .. ".png"
                if not file.Exists(iconPath, "GAME") then iconPath = "materials/entities/what.png" end
                equipmentData.image     = iconPath
                equipmentData.classname = equipment
                equipmentData.droppable = not weaponData.PersonaSkill and CheckIfWeaponJob(ply, equipment, "weapon")
            elseif passiveData then
                equipmentData.name        = passiveData.name
                equipmentData.description = passiveData.description
                equipmentData.image       = passiveData.image or "materials/entities/what.png"
                equipmentData.classname   = passiveData.classname
                equipmentData.droppable   = not passiveData.PersonaSkill and CheckIfWeaponJob(ply, passiveData.classname, "passive")
            end

            if equipmentData.name then
                local btn = vgui.Create("DImageButton")
                btn:SetSize(64, 64)
                btn:SetImage(equipmentData.image)
                btn:SetTooltip(equipmentData.name)

                btn.DoClick = function()
                    OpenItemDescriptionWindow(anchorPanel, equipmentData)
                end

                btn.DoRightClick = function()
                    local menu = DermaMenu()
                    menu:AddOption("Drop", function()
                        if equipmentData.droppable then
                            net.Start("DropWeapon")
                            net.WriteString(properties.type)
                            net.WriteString(equipmentData.classname)
                            net.SendToServer()
                            equipmentGrid:RemoveItem(btn)
                        else
                            ply:ChatPrint("You cannot drop this weapon!")
                        end
                    end)
                    menu:Open()
                end

                equipmentGrid:AddItem(btn)
            end
        end
    end

    -- ----------------------------------------------------------------
    --  updateItems
    -- ----------------------------------------------------------------
    local function updateItems()
        local ply = LocalPlayer()
        itemGrid:Clear()
        local localItems = {}

        for _, weapon in pairs(ply:GetWeapons()) do
            if weapon.SlotType == "Item" then
                localItems[weapon:GetClass()] = {name = weapon:GetClass(), type = "swep"}
            end
        end

        local buffs = GetAllStatsClient(ply, "permabuffs")
        if buffs then
            for ailmentName, ailmentInfo in pairs(buffs) do
                if ailmentInfo.SlotType == "Item" then
                    localItems[ailmentName] = {name = ailmentName, type = "passive"}
                end
            end
        end

        for item, properties in pairs(localItems) do
            local weaponData  = false
            local passiveData = false

            if properties.type == "swep" then
                weaponData = weapons and weapons.Get and weapons.Get(item)
            elseif properties.type == "passive" then
                passiveData = Passives and Passives[item]
            end

            local itemData = {}

            if weaponData then
                local ammoStr = weaponData.ShowAmmo and weaponData:ShowAmmo(ply, item) or "?"
                itemData.name            = weaponData.PrintName
                itemData.description     = (weaponData.Purpose or "") .. " Remaining: " .. ammoStr
                local iconPath = "materials/entities/" .. item .. ".png"
                if not file.Exists(iconPath, "GAME") then iconPath = "materials/entities/what.png" end
                itemData.image           = iconPath
                itemData.classname       = item
                itemData.droppable       = not weaponData.PersonaSkill and CheckIfWeaponJob(ply, item, "weapon")
                itemData.RemainingAmount = ammoStr
            elseif passiveData then
                itemData.name        = passiveData.name
                itemData.description = passiveData.description
                itemData.image       = passiveData.image or "materials/entities/what.png"
                itemData.classname   = passiveData.classname
                itemData.droppable   = not passiveData.PersonaSkill and CheckIfWeaponJob(ply, passiveData.classname, "passive")
            end

            if itemData.name then
                local btn = vgui.Create("DImageButton")
                btn:SetSize(64, 64)
                btn:SetImage(itemData.image)
                btn:SetTooltip(itemData.name)

                btn.DoClick = function()
                    OpenItemDescriptionWindow(anchorPanel, itemData)
                end

                btn.DoRightClick = function()
                    local menu = DermaMenu()

                    if itemData.RemainingAmount then
                        local dropMenu = menu:AddSubMenu("Drop")
                        dropMenu:SetDeleteSelf(true)
                        for i = 1, itemData.RemainingAmount do
                            dropMenu:AddOption(tostring(i), function()
                                net.Start("DropItems")
                                net.WriteInt(i, 32)
                                net.WriteString(properties.type)
                                net.WriteString(itemData.classname)
                                net.SendToServer()
                                if i == itemData.RemainingAmount then
                                    itemGrid:RemoveItem(btn)
                                end
                            end)
                        end
                    else
                        menu:AddOption("Drop", function()
                            if itemData.droppable then
                                net.Start("DropWeapon")
                                net.WriteString(properties.type)
                                net.WriteString(itemData.classname)
                                net.SendToServer()
                                itemGrid:RemoveItem(btn)
                            else
                                ply:ChatPrint("You cannot drop this item!")
                            end
                        end)
                    end

                    menu:Open()
                end

                itemGrid:AddItem(btn)
            end
        end
    end

    -- ----------------------------------------------------------------
    --  updatePersonaItems
    -- ----------------------------------------------------------------
    local function updatePersonaItems()
        local ply = LocalPlayer()
        personasGrid:Clear()

        local personas = GetAllStatsClient and GetAllStatsClient(ply, "personas")
        if not personas then return end

        local permapersonas = GetAllStatsClient and GetAllStatsClient(ply, "permapersonas")

        for personaName, _ in pairs(personas) do
            local personaData = Personas and Personas[personaName]
            if personaData then
                local personaDroppable = true
                if permapersonas and permapersonas[personaName] then
                    personaDroppable = false
                end

                local btn = vgui.Create("DImageButton")
                btn:SetSize(64, 64)
                btn:SetImage(personaData.image)
                btn:SetTooltip(personaData.name)

                if personaName == ply:GetNW2String("selectedPersona", "") then
                    btn.PaintOver = function(s, w, h)
                        surface.SetDrawColor(Color(0, 0, 255))
                        surface.DrawOutlinedRect(0, 0, w, h)
                    end
                end

                btn.DoClick = function()
                    OpenPersonaDetailWindow(anchorPanel, personaName)
                end

                btn.DoRightClick = function()
                    local menu = DermaMenu()

                    if ply:GetNW2String("selectedPersona", "") == personaName then
                        menu:AddOption("Unequip", function()
                            net.Start("DropPersona")
                            net.WriteString(personaName)
                            net.WriteBool(false)
                            net.SendToServer()
                            timer.Create("TBC_InvRefresh", 0.1, 1, function()
                                updatePersonaItems()
                                updateEquippedItems()
                            end)
                        end)
                    else
                        menu:AddOption("Equip", function()
                            net.Start("EquipPersona")
                            net.WriteString(personaName)
                            net.SendToServer()
                            timer.Create("TBC_InvRefresh", 0.1, 1, function()
                                updatePersonaItems()
                                updateEquippedItems()
                            end)
                        end)
                    end

                    if personaDroppable then
                        menu:AddOption("Drop", function()
                            net.Start("DropPersona")
                            net.WriteString(personaName)
                            net.WriteBool(true)
                            net.SendToServer()
                            timer.Create("TBC_InvRefresh", 0.1, 1, function()
                                updatePersonaItems()
                                updateEquippedItems()
                            end)
                        end)
                    end

                    menu:Open()
                end

                personasGrid:AddItem(btn)
            end
        end
    end

    -- Initial population
    updateEquippedItems()
    updateItems()
    updatePersonaItems()
end

-- ----------------------------------------------------------------
--  Scoreboard tab
-- ----------------------------------------------------------------
function PANEL:LoadScoreboardContent()
    local label = vgui.Create("DLabel", self.Content)
    label:Dock(TOP)
    label:SetText("Scoreboard")
    label:SetFont("DermaLarge")
    label:SetTextColor(Color(255, 255, 255))
    label:DockMargin(10, 10, 10, 10)

    local scroll = vgui.Create("DScrollPanel", self.Content)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)

    local info = vgui.Create("DLabel", scroll)
    info:Dock(TOP)
    info:SetText("Scoreboard content will go here...")
    info:SetTextColor(Color(200, 200, 200))
    info:DockMargin(5, 5, 5, 5)
end

-- ----------------------------------------------------------------
--  Characters tab
-- ----------------------------------------------------------------
function PANEL:LoadCharactersContent()
    self.CharacterList = vgui.Create("DPanel", self.Content)
    self.CharacterList:Dock(LEFT)
    self.CharacterList:SetWide(500)
    self.CharacterList:DockMargin(5, 5, 5, 5)
    self.CharacterList.Paint = function(s, w, h) end

    local searchBar = vgui.Create("DTextEntry", self.CharacterList)
    searchBar:Dock(TOP)
    searchBar:SetTall(30)
    searchBar:DockMargin(5, 5, 5, 5)
    searchBar:SetPlaceholderText("Search...")

    local scroll = vgui.Create("DScrollPanel", self.CharacterList)
    scroll:Dock(FILL)
    scroll:DockMargin(5, 0, 5, 5)

    if CHARACTERS and CHARACTERS.Categories then
        for _, category in ipairs(CHARACTERS.Categories) do
            self:CreateCategoryPanel(scroll, category)
        end
    end

    self.CharacterDetail = vgui.Create("DPanel", self.Content)
    self.CharacterDetail:Dock(FILL)
    self.CharacterDetail:DockMargin(0, 5, 5, 5)
    self.CharacterDetail.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(60, 60, 60, 200))
    end

    local placeholder = vgui.Create("DLabel", self.CharacterDetail)
    placeholder:Dock(FILL)
    placeholder:SetText("Select a character to view details")
    placeholder:SetTextColor(Color(150, 150, 150))
    placeholder:SetContentAlignment(5)
    placeholder:SetFont("DermaLarge")
end

function PANEL:CreateCategoryPanel(parent, category)
    local categoryPanel = vgui.Create("DCollapsibleCategory", parent)
    categoryPanel:Dock(TOP)
    categoryPanel:DockMargin(0, 5, 0, 0)
    categoryPanel:SetExpanded(false)
    categoryPanel:SetLabel("")

    local content = vgui.Create("DPanel", categoryPanel)
    content:Dock(FILL)
    content:DockMargin(2, 2, 2, 2)
    content.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 70, 200))
    end

    categoryPanel:SetContents(content)

    local header = categoryPanel.Header
    header:SetTall(35)
    header.Paint = function(s, w, h)
        local bgColor = category.color or Color(100, 100, 100, 255)
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        local arrow = categoryPanel:GetExpanded() and "▼" or "►"
        draw.SimpleText(arrow, "DermaDefault", 10, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(category.name, "DermaDefault", 25, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    local hasCharacters = false
    if CHARACTERS and CHARACTERS.List then
        -- Characters that share a variantGroup (e.g. student_a/student_b) get a single
        -- tile that opens a variant comparison screen instead of being listed as fully
        -- separate characters.
        local groups = {}
        local groupOrder = {}
        local standalone = {}

        for charID, char in pairs(CHARACTERS.List) do
            if char.category == category.name then
                if char.variantGroup then
                    if not groups[char.variantGroup] then
                        groups[char.variantGroup] = {}
                        table.insert(groupOrder, char.variantGroup)
                    end
                    table.insert(groups[char.variantGroup], {charID = charID, char = char})
                else
                    table.insert(standalone, {charID = charID, char = char})
                end
            end
        end

        for _, entry in ipairs(standalone) do
            self:CreateCharacterButton(content, entry.char, entry.charID)
            hasCharacters = true
        end

        for _, groupKey in ipairs(groupOrder) do
            local variants = groups[groupKey]
            if #variants == 1 then
                self:CreateCharacterButton(content, variants[1].char, variants[1].charID)
            else
                table.sort(variants, function(a, b)
                    return (a.char.variantLabel or a.charID) < (b.char.variantLabel or b.charID)
                end)
                local groupName = variants[1].char.variantGroupName or variants[1].char.name
                self:CreateVariantGroupButton(content, groupName, variants)
            end
            hasCharacters = true
        end
    end

    if not hasCharacters then
        local emptyLabel = vgui.Create("DLabel", content)
        emptyLabel:Dock(TOP)
        emptyLabel:SetText("No characters available")
        emptyLabel:SetTextColor(Color(150, 150, 150))
        emptyLabel:SetContentAlignment(5)
        emptyLabel:DockMargin(5, 10, 5, 10)
    end

    return categoryPanel
end

function PANEL:CreateCharacterButton(parent, character, charID)
    local charButton = vgui.Create("DButton", parent)
    charButton:Dock(TOP)
    charButton:SetTall(70)
    charButton:DockMargin(5, 5, 5, 0)
    charButton:SetText("")

    local modelPath = character.model[1] or "models/player/group01/male_01.mdl"

    charButton.Paint = function(s, w, h)
        local bgColor = Color(80, 80, 80, 200)
        if s:IsHovered() then bgColor = Color(100, 100, 100, 200) end
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        draw.SimpleText(character.name, "DermaDefault", 75, h / 2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    charButton.DoClick = function()
        self:ShowCharacterDetails(character, charID)
    end

    local iconPanel = vgui.Create("SpawnIcon", charButton)
    iconPanel:SetPos(5, 5)
    iconPanel:SetSize(60, 60)
    iconPanel:SetModel(modelPath)
    iconPanel:SetMouseInputEnabled(false)
    iconPanel:SetKeyboardInputEnabled(false)
    iconPanel:SetTooltip(false)

    return charButton
end

-- ----------------------------------------------------------------
--  Variant group tile: shared entry point for characters that come
--  in multiple variants (e.g. Student A/B, Jack Frost A/B).
-- ----------------------------------------------------------------
function PANEL:CreateVariantGroupButton(parent, groupName, variants)
    local charButton = vgui.Create("DButton", parent)
    charButton:Dock(TOP)
    charButton:SetTall(70)
    charButton:DockMargin(5, 5, 5, 0)
    charButton:SetText("")

    local modelPath = (variants[1].char.model and variants[1].char.model[1]) or "models/player/group01/male_01.mdl"

    charButton.Paint = function(s, w, h)
        local bgColor = Color(80, 80, 80, 200)
        if s:IsHovered() then bgColor = Color(100, 100, 100, 200) end
        draw.RoundedBox(4, 0, 0, w, h, bgColor)
        draw.SimpleText(groupName, "DermaDefault", 75, h / 2 - 8, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        draw.SimpleText(#variants .. " Variants", "DermaDefault", 75, h / 2 + 10, Color(180, 180, 180), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    charButton.DoClick = function()
        self:ShowVariantGroup(groupName, variants)
    end

    local iconPanel = vgui.Create("SpawnIcon", charButton)
    iconPanel:SetPos(5, 5)
    iconPanel:SetSize(60, 60)
    iconPanel:SetModel(modelPath)
    iconPanel:SetMouseInputEnabled(false)
    iconPanel:SetKeyboardInputEnabled(false)
    iconPanel:SetTooltip(false)

    return charButton
end

-- ----------------------------------------------------------------
--  Variant screen: shows one variant's full description and stats at a
--  time, with back/forward arrows to cycle between them. Variants share
--  one model list, so the model viewer + selector sit once at the bottom.
--  Picking "Select Character" applies whichever variant is on screen;
--  the existing loadout/persona menu then opens automatically on
--  respawn exactly as it always has.
-- ----------------------------------------------------------------
function PANEL:ShowVariantGroup(groupName, variants, startIndex, selectedModel)
    if not IsValid(self.CharacterDetail) then return end
    self.CharacterDetail:Clear()

    local ply = LocalPlayer()

    local index = startIndex
    if not index then
        index = 1
        local assigned = ply:GetNWString("AssignedCharacter", "")
        for i, entry in ipairs(variants) do
            if entry.charID == assigned then
                index = i
                break
            end
        end
    end
    if index < 1 then index = #variants end
    if index > #variants then index = 1 end

    local entry = variants[index]
    local character, charID = entry.char, entry.charID

    local currentModel = selectedModel
    if not currentModel and ply:GetNWString("AssignedCharacter", "") == charID then
        currentModel = ply:GetModel()
    end
    local validModel = false
    if character.model then
        for _, m in ipairs(character.model) do
            if m == currentModel then
                validModel = true
                break
            end
        end
    end
    if not validModel then
        currentModel = (character.model and character.model[1]) or "models/player/group01/male_01.mdl"
    end

    -- ---- Header: back arrow / variant title / forward arrow ----
    local headerRow = vgui.Create("DPanel", self.CharacterDetail)
    headerRow:Dock(TOP)
    headerRow:SetTall(40)
    headerRow:DockMargin(10, 10, 10, 0)
    headerRow.Paint = function() end

    local backBtn = vgui.Create("DButton", headerRow)
    backBtn:Dock(LEFT)
    backBtn:SetWide(40)
    backBtn:SetText("<")
    backBtn:SetFont("DermaLarge")
    backBtn:SetEnabled(#variants > 1)
    backBtn.DoClick = function()
        self:ShowVariantGroup(groupName, variants, index - 1, currentModel)
    end

    local nextBtn = vgui.Create("DButton", headerRow)
    nextBtn:Dock(RIGHT)
    nextBtn:SetWide(40)
    nextBtn:SetText(">")
    nextBtn:SetFont("DermaLarge")
    nextBtn:SetEnabled(#variants > 1)
    nextBtn.DoClick = function()
        self:ShowVariantGroup(groupName, variants, index + 1, currentModel)
    end

    local titleLabel = vgui.Create("DLabel", headerRow)
    titleLabel:Dock(FILL)
    local titleText = groupName
    if character.variantLabel then
        titleText = titleText .. " - " .. character.variantLabel
    end
    if #variants > 1 then
        titleText = titleText .. "  (" .. index .. "/" .. #variants .. ")"
    end
    titleLabel:SetText(titleText)
    titleLabel:SetFont("DermaLarge")
    titleLabel:SetTextColor(Color(255, 255, 255))
    titleLabel:SetContentAlignment(5)

    -- ---- Body: description/stats/etc, then the shared model section ----
    local scroll = vgui.Create("DScrollPanel", self.CharacterDetail)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    local separator = vgui.Create("DPanel", scroll)
    separator:Dock(TOP)
    separator:SetTall(2)
    separator:DockMargin(0, 0, 0, 8)
    separator.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 200))
    end

    local function SectionHeader(text)
        local lbl = vgui.Create("DLabel", scroll)
        lbl:Dock(TOP)
        lbl:SetText(text)
        lbl:SetFont("DermaDefaultBold")
        lbl:SetTextColor(Color(200, 200, 200))
        lbl:DockMargin(0, 0, 0, 4)
        return lbl
    end

    local function SectionBody(text)
        local lbl = vgui.Create("DLabel", scroll)
        lbl:Dock(TOP)
        lbl:SetText(text)
        lbl:SetTextColor(Color(220, 220, 220))
        lbl:SetAutoStretchVertical(true)
        lbl:SetWrap(true)
        lbl:DockMargin(0, 0, 0, 12)
        return lbl
    end

    SectionHeader("Description:")
    SectionBody(character.description or "No description available.")

    local stats = {}
    if character.combatHP      and character.combatHP      > 0 then table.insert(stats, "HP: "              .. character.combatHP)      end
    if character.combatMP      and character.combatMP      > 0 then table.insert(stats, "MP: "              .. character.combatMP)      end
    if character.Luck          and character.Luck          > 0 then table.insert(stats, "Luck: "            .. character.Luck)          end
    if character.Technique     and character.Technique     > 0 then table.insert(stats, "Technique: "       .. character.Technique)     end
    if character.essence       and character.essence       > 0 then table.insert(stats, "Essence: "         .. character.essence)       end
    if character.kilodevil     and character.kilodevil     > 0 then table.insert(stats, "Kilodevil: "       .. character.kilodevil)     end
    if character.equipmentSlots and character.equipmentSlots > 0 then table.insert(stats, "Equipment Slots: " .. character.equipmentSlots) end
    if character.itemSlots     and character.itemSlots     > 0 then table.insert(stats, "Item Slots: "      .. character.itemSlots)     end
    if character.turns         and character.turns         > 0 then table.insert(stats, "Turns: "           .. character.turns)         end

    if #stats > 0 then
        SectionHeader("Stats:")
        SectionBody(table.concat(stats, "\n"))
    end

    local hasResistInfo =
        (character.resist and #character.resist > 0) or
        (character.weak   and #character.weak   > 0) or
        (character.block  and #character.block  > 0) or
        (character.drain  and #character.drain  > 0) or
        (character.repel  and #character.repel  > 0)

    if hasResistInfo then
        local resistInfo = {}
        if character.weak   and #character.weak   > 0 then table.insert(resistInfo, "Weak: "   .. table.concat(character.weak,   ", ")) end
        if character.resist and #character.resist > 0 then table.insert(resistInfo, "Resist: " .. table.concat(character.resist, ", ")) end
        if character.block  and #character.block  > 0 then table.insert(resistInfo, "Block: "  .. table.concat(character.block,  ", ")) end
        if character.drain  and #character.drain  > 0 then table.insert(resistInfo, "Drain: "  .. table.concat(character.drain,  ", ")) end
        if character.repel  and #character.repel  > 0 then table.insert(resistInfo, "Repel: "  .. table.concat(character.repel,  ", ")) end

        SectionHeader("Resistances & Weaknesses:")
        SectionBody(table.concat(resistInfo, "\n"))
    end

    if character.weapons and #character.weapons > 0 then
        local weaponNames = {}
        for _, weaponClass in ipairs(character.weapons) do
            local wepData     = weapons and weapons.Get and weapons.Get(weaponClass)
            local passiveData = not wepData and Passives and Passives[weaponClass]
            if type(passiveData) ~= "table" then passiveData = nil end

            if passiveData then
                table.insert(weaponNames, passiveData.name .. " (Passive)")
            elseif wepData then
                table.insert(weaponNames, wepData.PrintName or weaponClass)
            else
                table.insert(weaponNames, weaponClass)
            end
        end
        SectionHeader("Weapons & Skills:")
        SectionBody(table.concat(weaponNames, "\n"))
    end

    if character.loadoutItems and #character.loadoutItems > 0 then
        local loadoutNames = {}
        for _, itemClass in ipairs(character.loadoutItems) do
            local n = itemClass
            if LoadoutItems and LoadoutItems[itemClass] then
                n = LoadoutItems[itemClass].name
            elseif Personas and Personas[itemClass] then
                n = Personas[itemClass].name
            end
            if n then table.insert(loadoutNames, n) end
        end
        SectionHeader("Loadout Items:")
        SectionBody(table.concat(loadoutNames, "\n"))
    end

    if character.permaBuffs and table.Count(character.permaBuffs) > 0 then
        local names = {}
        for buffName, _ in pairs(character.permaBuffs) do table.insert(names, buffName) end
        SectionHeader("Permanent Passives:")
        SectionBody(table.concat(names, "\n"))
    end

    -- ---- Shared model viewer + selector (same for every variant) ----
    if character.model and #character.model > 0 then
        local spacer = vgui.Create("DPanel", scroll)
        spacer:Dock(TOP)
        spacer:SetTall(10)
        spacer.Paint = function() end

        local modelHeader = vgui.Create("DLabel", scroll)
        modelHeader:Dock(TOP)
        modelHeader:SetText("Character Model:")
        modelHeader:SetFont("DermaDefaultBold")
        modelHeader:SetTextColor(Color(200, 200, 200))
        modelHeader:DockMargin(0, 0, 0, 5)

        local modelViewerPanel = vgui.Create("DPanel", scroll)
        modelViewerPanel:Dock(TOP)
        modelViewerPanel:SetTall(400)
        modelViewerPanel:DockMargin(5, 5, 5, 5)
        modelViewerPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
        end

        local modelViewer = vgui.Create("DModelPanel", modelViewerPanel)
        modelViewer:Dock(FILL)
        modelViewer:SetModel(currentModel)
        modelViewer:SetFOV(90)
        modelViewer:SetCamPos(Vector(50, 0, 50))
        modelViewer:SetLookAt(Vector(0, 0, 40))
        function modelViewer:LayoutEntity(ent)
            ent:SetSequence(ent:LookupSequence("idle_all_01") or 0)
            self:RunAnimation()
        end

        local selectorLabel = vgui.Create("DLabel", scroll)
        selectorLabel:Dock(TOP)
        selectorLabel:SetText("Available Models:")
        selectorLabel:SetFont("DermaDefaultBold")
        selectorLabel:SetTextColor(Color(200, 200, 200))
        selectorLabel:DockMargin(0, 10, 0, 5)

        local selectorPanel = vgui.Create("DPanel", scroll)
        selectorPanel:Dock(TOP)
        selectorPanel:SetTall(70)
        selectorPanel:DockMargin(5, 5, 5, 5)
        selectorPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
        end

        local iconLayout = vgui.Create("DHorizontalScroller", selectorPanel)
        iconLayout:Dock(FILL)
        iconLayout:DockMargin(5, 5, 5, 5)

        local selectedIcon = nil
        local updateButtonFunc = nil

        for _, mdlPath in ipairs(character.model) do
            local iconButton = vgui.Create("SpawnIcon")
            iconButton:SetSize(60, 60)
            iconButton:SetModel(mdlPath)
            iconButton:SetTooltip(mdlPath)

            if mdlPath == currentModel then
                selectedIcon = iconButton
                iconButton.PaintOver = function(self, w, h)
                    surface.SetDrawColor(Color(80, 120, 180, 255))
                    surface.DrawOutlinedRect(0, 0, w, h, 3)
                end
            end

            iconButton.DoClick = function()
                modelViewer:SetModel(mdlPath)
                local ent = modelViewer:GetEntity()
                if IsValid(ent) then
                    ent:SetSequence(ent:LookupSequence("idle_all_01") or 0)
                end
                if IsValid(selectedIcon) then
                    selectedIcon.PaintOver = nil
                end
                selectedIcon = iconButton
                iconButton.PaintOver = function(self, w, h)
                    surface.SetDrawColor(Color(80, 120, 180, 255))
                    surface.DrawOutlinedRect(0, 0, w, h, 3)
                end
                currentModel = mdlPath
                if updateButtonFunc then
                    updateButtonFunc(mdlPath)
                end
            end

            iconLayout:AddPanel(iconButton)
        end

        local buttonPanel = vgui.Create("DPanel", scroll)
        buttonPanel:Dock(TOP)
        buttonPanel:SetTall(60)
        buttonPanel:DockMargin(5, 15, 5, 10)
        buttonPanel.Paint = function() end

        local selectButton = vgui.Create("DButton", buttonPanel)
        selectButton:Dock(FILL)
        selectButton:DockMargin(50, 5, 50, 5)
        selectButton:SetFont("DermaLarge")

        local function UpdateButtonState()
            local assignedCharacter = ply:GetNWString("AssignedCharacter", "")
            local plyModel = ply:GetModel()

            if assignedCharacter == charID then
                if plyModel ~= currentModel then
                    selectButton:SetEnabled(true)
                    selectButton:SetText("Select Model")
                    selectButton.Paint = function(s, w, h)
                        local bgColor = Color(80, 120, 180, 255)
                        if s:IsHovered() then bgColor = Color(100, 140, 200, 255) end
                        draw.RoundedBox(6, 0, 0, w, h, bgColor)
                    end
                else
                    selectButton:SetEnabled(false)
                    selectButton:SetText("Current Character")
                    selectButton.Paint = function(s, w, h)
                        draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60, 255))
                    end
                end
            else
                selectButton:SetEnabled(true)
                selectButton:SetText("Select Character")
                selectButton.Paint = function(s, w, h)
                    local bgColor = Color(80, 180, 120, 255)
                    if s:IsHovered() then bgColor = Color(100, 200, 140, 255) end
                    draw.RoundedBox(6, 0, 0, w, h, bgColor)
                end
            end
        end

        updateButtonFunc = function()
            UpdateButtonState()
        end

        UpdateButtonState()

        selectButton.DoClick = function()
            local assignedCharacter = ply:GetNWString("AssignedCharacter", "")

            if assignedCharacter == charID then
                net.Start("SelectCharacterModel")
                net.WriteString(currentModel)
                net.SendToServer()
            else
                net.Start("SelectCharacter")
                net.WriteString(charID)
                net.WriteString(currentModel)
                net.SendToServer()
            end

            if IsValid(self) then self:Remove() end
        end
    end
end

function PANEL:ShowCharacterDetails(character, charID)
    if not IsValid(self.CharacterDetail) then return end
    self.CharacterDetail:Clear()

    local scroll = vgui.Create("DScrollPanel", self.CharacterDetail)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    local nameLabel = vgui.Create("DLabel", scroll)
    nameLabel:Dock(TOP)
    nameLabel:SetText(character.name)
    nameLabel:SetFont("DermaLarge")
    nameLabel:SetTextColor(Color(255, 255, 255))
    nameLabel:DockMargin(0, 0, 0, 10)
    nameLabel:SetAutoStretchVertical(true)
    nameLabel:SetWrap(true)

    local separator = vgui.Create("DPanel", scroll)
    separator:Dock(TOP)
    separator:SetTall(2)
    separator:DockMargin(0, 5, 0, 10)
    separator.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 200))
    end

    local descHeader = vgui.Create("DLabel", scroll)
    descHeader:Dock(TOP)
    descHeader:SetText("Description:")
    descHeader:SetFont("DermaDefaultBold")
    descHeader:SetTextColor(Color(200, 200, 200))
    descHeader:DockMargin(0, 0, 0, 5)

    local descLabel = vgui.Create("DLabel", scroll)
    descLabel:Dock(TOP)
    descLabel:SetText(character.description or "No description available.")
    descLabel:SetTextColor(Color(220, 220, 220))
    descLabel:SetAutoStretchVertical(true)
    descLabel:SetWrap(true)
    descLabel:DockMargin(0, 0, 0, 20)

    local statsHeader = vgui.Create("DLabel", scroll)
    statsHeader:Dock(TOP)
    statsHeader:SetText("Stats:")
    statsHeader:SetFont("DermaDefaultBold")
    statsHeader:SetTextColor(Color(200, 200, 200))
    statsHeader:DockMargin(0, 0, 0, 5)

    local stats = {}
    if character.combatHP    and character.combatHP    > 0 then table.insert(stats, "HP: "              .. character.combatHP)    end
    if character.combatMP    and character.combatMP    > 0 then table.insert(stats, "MP: "              .. character.combatMP)    end
    if character.Luck        and character.Luck        > 0 then table.insert(stats, "Luck: "            .. character.Luck)        end
    if character.Technique   and character.Technique   > 0 then table.insert(stats, "Technique: "       .. character.Technique)   end
    if character.essence     and character.essence     > 0 then table.insert(stats, "Essence: "         .. character.essence)     end
    if character.kilodevil   and character.kilodevil   > 0 then table.insert(stats, "Kilodevil: "       .. character.kilodevil)   end
    if character.equipmentSlots and character.equipmentSlots > 0 then table.insert(stats, "Equipment Slots: " .. character.equipmentSlots) end
    if character.itemSlots   and character.itemSlots   > 0 then table.insert(stats, "Item Slots: "      .. character.itemSlots)   end
    if character.turns       and character.turns       > 0 then table.insert(stats, "Turns: "           .. character.turns)       end

    if #stats > 0 then
        local statsLabel = vgui.Create("DLabel", scroll)
        statsLabel:Dock(TOP)
        statsLabel:SetText(table.concat(stats, "\n"))
        statsLabel:SetTextColor(Color(220, 220, 220))
        statsLabel:SetAutoStretchVertical(true)
        statsLabel:SetWrap(true)
        statsLabel:DockMargin(0, 0, 0, 20)
    end

    local hasResistInfo =
        (character.resist and #character.resist > 0) or
        (character.weak   and #character.weak   > 0) or
        (character.block  and #character.block  > 0) or
        (character.drain  and #character.drain  > 0) or
        (character.repel  and #character.repel  > 0)

    if hasResistInfo then
        local resistHeader = vgui.Create("DLabel", scroll)
        resistHeader:Dock(TOP)
        resistHeader:SetText("Resistances & Weaknesses:")
        resistHeader:SetFont("DermaDefaultBold")
        resistHeader:SetTextColor(Color(200, 200, 200))
        resistHeader:DockMargin(0, 0, 0, 5)

        local resistInfo = {}
        if character.weak   and #character.weak   > 0 then table.insert(resistInfo, "Weak: "   .. table.concat(character.weak,   ", ")) end
        if character.resist and #character.resist > 0 then table.insert(resistInfo, "Resist: " .. table.concat(character.resist, ", ")) end
        if character.block  and #character.block  > 0 then table.insert(resistInfo, "Block: "  .. table.concat(character.block,  ", ")) end
        if character.drain  and #character.drain  > 0 then table.insert(resistInfo, "Drain: "  .. table.concat(character.drain,  ", ")) end
        if character.repel  and #character.repel  > 0 then table.insert(resistInfo, "Repel: "  .. table.concat(character.repel,  ", ")) end

        local resistLabel = vgui.Create("DLabel", scroll)
        resistLabel:Dock(TOP)
        resistLabel:SetText(table.concat(resistInfo, "\n"))
        resistLabel:SetTextColor(Color(220, 220, 220))
        resistLabel:SetAutoStretchVertical(true)
        resistLabel:SetWrap(true)
        resistLabel:DockMargin(0, 0, 0, 20)
    end

    if character.weapons and #character.weapons > 0 then
        local weaponsHeader = vgui.Create("DLabel", scroll)
        weaponsHeader:Dock(TOP)
        weaponsHeader:SetText("Weapons & Skills:")
        weaponsHeader:SetFont("DermaDefaultBold")
        weaponsHeader:SetTextColor(Color(200, 200, 200))
        weaponsHeader:DockMargin(0, 0, 0, 5)

        for _, weaponClass in ipairs(character.weapons) do
            local wepData     = weapons and weapons.Get and weapons.Get(weaponClass)
            local passiveData = not wepData and Passives and Passives[weaponClass]
            if type(passiveData) ~= "table" then passiveData = nil end
            local isPassive   = passiveData ~= nil

            if wepData or passiveData then
                local weaponPanel = vgui.Create("DPanel", scroll)
                weaponPanel:Dock(TOP)
                weaponPanel:DockMargin(5, 2, 5, 2)
                weaponPanel.Paint = function() end

                local weaponText = ""
                if isPassive then
                    weaponText = passiveData.name .. " (Passive)"
                    if passiveData.description then
                        weaponText = weaponText .. "\n" .. passiveData.description
                    end
                elseif wepData then
                    local wname    = wepData.PrintName or weaponClass
                    local typeInfo = ""
                    if wepData.WeaponType then
                        typeInfo = "(" .. (wepData.WeaponType or "Unknown") .. ")"
                        if wepData.MPCost and wepData.MPCost > 0 then typeInfo = typeInfo .. " (" .. wepData.MPCost .. " MP)" end
                        if wepData.HPCost and wepData.HPCost > 0 then typeInfo = typeInfo .. " (" .. wepData.HPCost .. " HP)" end
                        if wepData.Tech   and wepData.Tech   > 0 then typeInfo = typeInfo .. " (" .. wepData.Tech   .. " Technique)" end
                    end
                    weaponText = wname .. " " .. typeInfo
                    if wepData.Purpose and wepData.Purpose ~= "" then
                        weaponText = weaponText .. "\n" .. wepData.Purpose
                    end
                end

                local weaponLabel = vgui.Create("DLabel", weaponPanel)
                weaponLabel:Dock(FILL)
                weaponLabel:SetText(weaponText)
                weaponLabel:SetTextColor(Color(220, 220, 220))
                weaponLabel:SetWrap(true)
                weaponLabel:SetAutoStretchVertical(true)
                weaponLabel:DockMargin(5, 5, 5, 5)

                local lines = 1
                for _ in string.gmatch(weaponText, "\n") do lines = lines + 1 end
                weaponPanel:SetTall((draw.GetFontHeight(weaponLabel:GetFont()) * lines) + 20)
            else
                local weaponPanel = vgui.Create("DPanel", scroll)
                weaponPanel:Dock(TOP)
                weaponPanel:DockMargin(5, 2, 5, 2)
                weaponPanel.Paint = function() end

                local weaponLabel = vgui.Create("DLabel", weaponPanel)
                weaponLabel:Dock(FILL)
                weaponLabel:SetText(weaponClass)
                weaponLabel:SetTextColor(Color(220, 220, 220))
                weaponLabel:SetAutoStretchVertical(true)
                weaponLabel:SetWrap(true)
                weaponLabel:DockMargin(5, 5, 5, 5)

                weaponPanel:SizeToChildren(false, true)
                weaponPanel:SetTall(weaponPanel:GetTall() + 10)
            end
        end

        local spacer = vgui.Create("DPanel", scroll)
        spacer:Dock(TOP)
        spacer:SetTall(10)
        spacer.Paint = function() end
    end

    if character.loadoutItems and #character.loadoutItems > 0 then
        local loadoutHeader = vgui.Create("DLabel", scroll)
        loadoutHeader:Dock(TOP)
        loadoutHeader:SetText("Loadout Items:")
        loadoutHeader:SetFont("DermaDefaultBold")
        loadoutHeader:SetTextColor(Color(200, 200, 200))
        loadoutHeader:DockMargin(0, 0, 0, 5)

        local loadoutItemsArray = {}
        for _, itemClass in ipairs(character.loadoutItems) do
            local n = itemClass
            if LoadoutItems and LoadoutItems[itemClass] then
                n = LoadoutItems[itemClass].name
            elseif Personas and Personas[itemClass] then
                n = Personas[itemClass].name
            end
            if n then table.insert(loadoutItemsArray, n) end
        end

        local itemPanel = vgui.Create("DPanel", scroll)
        itemPanel:Dock(TOP)
        itemPanel:DockMargin(5, 2, 5, 2)
        itemPanel.Paint = function() end

        local itemLabel = vgui.Create("DLabel", itemPanel)
        itemLabel:Dock(FILL)
        itemLabel:SetText(table.concat(loadoutItemsArray, "\n"))
        itemLabel:SetTextColor(Color(220, 220, 220))
        itemLabel:SetAutoStretchVertical(true)
        itemLabel:SetWrap(true)
        itemLabel:DockMargin(5, 5, 5, 5)

        local lines = 1
        for _ in string.gmatch(table.concat(loadoutItemsArray, "\n"), "\n") do lines = lines + 1 end
        itemPanel:SetTall((draw.GetFontHeight(itemLabel:GetFont()) * lines) + 20)

        local spacer = vgui.Create("DPanel", scroll)
        spacer:Dock(TOP)
        spacer:SetTall(10)
        spacer.Paint = function() end
    end

    local function RenderBuffSection(header, buffs)
        if not buffs or table.Count(buffs) == 0 then return end

        local hdr = vgui.Create("DLabel", scroll)
        hdr:Dock(TOP)
        hdr:SetText(header)
        hdr:SetFont("DermaDefaultBold")
        hdr:SetTextColor(Color(200, 200, 200))
        hdr:DockMargin(0, 0, 0, 5)

        for buffName, buffData in pairs(buffs) do
            local passiveData = Passives and Passives[buffName]
            if type(passiveData) ~= "table" then passiveData = nil end

            local panel = vgui.Create("DPanel", scroll)
            panel:Dock(TOP)
            panel:DockMargin(5, 2, 5, 2)
            panel.Paint = function() end

            local txt = ""
            if passiveData then
                txt = passiveData.name .. " (Passive)"
                if passiveData.description then txt = txt .. "\n" .. passiveData.description end
            else
                txt = buffName
                if buffData.stacks and buffData.stacks > 1 then txt = txt .. " (x" .. buffData.stacks .. ")" end
                if buffData.type    then txt = txt .. "\nType: " .. buffData.type end
                if buffData.targets then txt = txt .. " | Targets: " .. buffData.targets end
            end

            local lbl = vgui.Create("DLabel", panel)
            lbl:Dock(FILL)
            lbl:SetText(txt)
            lbl:SetTextColor(Color(220, 220, 220))
            lbl:SetAutoStretchVertical(true)
            lbl:SetWrap(true)
            lbl:DockMargin(5, 5, 5, 5)

            local lines = 1
            for _ in string.gmatch(txt, "\n") do lines = lines + 1 end
            panel:SetTall((draw.GetFontHeight(lbl:GetFont()) * lines) + 20)
        end

        local spacer = vgui.Create("DPanel", scroll)
        spacer:Dock(TOP)
        spacer:SetTall(10)
        spacer.Paint = function() end
    end

    RenderBuffSection("Permanent Passives:", character.permaBuffs)
    RenderBuffSection("Permanent Negative Passives:", character.permaDebuffs)

    if character.model and #character.model > 0 then
        local spacer = vgui.Create("DPanel", scroll)
        spacer:Dock(TOP)
        spacer:SetTall(20)
        spacer.Paint = function() end

        local modelHeader = vgui.Create("DLabel", scroll)
        modelHeader:Dock(TOP)
        modelHeader:SetText("Character Model:")
        modelHeader:SetFont("DermaDefaultBold")
        modelHeader:SetTextColor(Color(200, 200, 200))
        modelHeader:DockMargin(0, 0, 0, 5)

        local modelViewerPanel = vgui.Create("DPanel", scroll)
        modelViewerPanel:Dock(TOP)
        modelViewerPanel:SetTall(400)
        modelViewerPanel:DockMargin(5, 5, 5, 5)
        modelViewerPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(40, 40, 40, 200))
        end

        local modelViewer = vgui.Create("DModelPanel", modelViewerPanel)
        modelViewer:Dock(FILL)
        modelViewer:SetModel(character.model[1] or "models/player/group01/male_01.mdl")
        modelViewer:SetFOV(90)
        modelViewer:SetCamPos(Vector(50, 0, 50))
        modelViewer:SetLookAt(Vector(0, 0, 40))
        function modelViewer:LayoutEntity(ent)
            ent:SetSequence(ent:LookupSequence("idle_all_01") or 0)
            self:RunAnimation()
        end

        local selectorLabel = vgui.Create("DLabel", scroll)
        selectorLabel:Dock(TOP)
        selectorLabel:SetText("Available Models:")
        selectorLabel:SetFont("DermaDefaultBold")
        selectorLabel:SetTextColor(Color(200, 200, 200))
        selectorLabel:DockMargin(0, 10, 0, 5)

        local selectorPanel = vgui.Create("DPanel", scroll)
        selectorPanel:Dock(TOP)
        selectorPanel:SetTall(70)
        selectorPanel:DockMargin(5, 5, 5, 5)
        selectorPanel.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(50, 50, 50, 200))
        end

        local iconLayout = vgui.Create("DHorizontalScroller", selectorPanel)
        iconLayout:Dock(FILL)
        iconLayout:DockMargin(5, 5, 5, 5)

        local selectedIcon    = nil
        local updateButtonFunc = nil

        for i, mdlPath in ipairs(character.model) do
            local iconButton = vgui.Create("SpawnIcon")
            iconButton:SetSize(60, 60)
            iconButton:SetModel(mdlPath)
            iconButton:SetTooltip(mdlPath)

            if i == 1 then
                selectedIcon = iconButton
                iconButton.PaintOver = function(self, w, h)
                    surface.SetDrawColor(Color(80, 120, 180, 255))
                    surface.DrawOutlinedRect(0, 0, w, h, 3)
                end
            end

            iconButton.DoClick = function()
                modelViewer:SetModel(mdlPath)
                local ent = modelViewer:GetEntity()
                if IsValid(ent) then
                    ent:SetSequence(ent:LookupSequence("idle_all_01") or 0)
                end
                if IsValid(selectedIcon) then
                    selectedIcon.PaintOver = nil
                end
                selectedIcon = iconButton
                iconButton.PaintOver = function(self, w, h)
                    surface.SetDrawColor(Color(80, 120, 180, 255))
                    surface.DrawOutlinedRect(0, 0, w, h, 3)
                end
                if updateButtonFunc then
                    updateButtonFunc(mdlPath)
                end
            end

            iconLayout:AddPanel(iconButton)
        end

        self.CharacterDetail.UpdateModelSelection = function(func)
            updateButtonFunc = func
        end
    end

    local buttonPanel = vgui.Create("DPanel", scroll)
    buttonPanel:Dock(TOP)
    buttonPanel:SetTall(60)
    buttonPanel:DockMargin(5, 15, 5, 10)
    buttonPanel.Paint = function() end

    local selectButton = vgui.Create("DButton", buttonPanel)
    selectButton:Dock(FILL)
    selectButton:DockMargin(50, 5, 50, 5)
    selectButton:SetFont("DermaLarge")

    local currentlySelectedModel = character.model[1] or "models/player/group01/male_01.mdl"

    local function UpdateButtonState()
        local ply = LocalPlayer()
        local assignedCharacter = ply:GetNWString("AssignedCharacter", "")
        local currentModel = ply:GetModel()

        if assignedCharacter == charID then
            if currentModel ~= currentlySelectedModel then
                selectButton:SetEnabled(true)
                selectButton:SetText("Select Model")
                selectButton.Paint = function(s, w, h)
                    local bgColor = Color(80, 120, 180, 255)
                    if s:IsHovered() then bgColor = Color(100, 140, 200, 255) end
                    draw.RoundedBox(6, 0, 0, w, h, bgColor)
                end
            else
                selectButton:SetEnabled(false)
                selectButton:SetText("Current Character")
                selectButton.Paint = function(s, w, h)
                    draw.RoundedBox(6, 0, 0, w, h, Color(60, 60, 60, 255))
                end
            end
        else
            selectButton:SetEnabled(true)
            selectButton:SetText("Select Character")
            selectButton.Paint = function(s, w, h)
                local bgColor = Color(80, 180, 120, 255)
                if s:IsHovered() then bgColor = Color(100, 200, 140, 255) end
                draw.RoundedBox(6, 0, 0, w, h, bgColor)
            end
        end
    end

    selectButton.UpdateSelectedModel = function(mdlPath)
        currentlySelectedModel = mdlPath
        UpdateButtonState()
    end

    UpdateButtonState()

    selectButton.DoClick = function()
        local ply = LocalPlayer()
        local assignedCharacter = ply:GetNWString("AssignedCharacter", "")

        if assignedCharacter == charID then
            net.Start("SelectCharacterModel")
            net.WriteString(currentlySelectedModel)
            net.SendToServer()
            timer.Simple(0.1, function()
                if IsValid(selectButton) then UpdateButtonState() end
            end)
            if IsValid(self) then self:Remove() end
        else
            net.Start("SelectCharacter")
            net.WriteString(charID)
            net.WriteString(currentlySelectedModel)
            net.SendToServer()
            if IsValid(self) then self:Remove() end
        end
    end

    if character.model and #character.model > 0 then
        if self.CharacterDetail.UpdateModelSelection then
            self.CharacterDetail.UpdateModelSelection(selectButton.UpdateSelectedModel)
        end
    end
end

-- ----------------------------------------------------------------
--  Settings tab
-- ----------------------------------------------------------------
function PANEL:LoadSettingsContent()
    local label = vgui.Create("DLabel", self.Content)
    label:Dock(TOP)
    label:SetText("Settings")
    label:SetFont("DermaLarge")
    label:SetTextColor(Color(255, 255, 255))
    label:DockMargin(10, 10, 10, 10)

    local info = vgui.Create("DLabel", self.Content)
    info:Dock(TOP)
    info:SetText("Settings options will go here...")
    info:SetTextColor(Color(200, 200, 200))
    info:DockMargin(10, 0, 10, 10)
end

vgui.Register("CustomTabMenu", PANEL, "DFrame")

-- ================================================================
--  F2 toggle
-- ================================================================
hook.Add(
    "PlayerButtonDown",
    "OpenCustomTabMenuF4",
    function(ply, button)
        if ply ~= LocalPlayer() then return end
        if not IsFirstTimePredicted() then return end

        if button == KEY_F4 then
            if not IsValid(TabMenu) then
                TabMenu = vgui.Create("CustomTabMenu")
            end

            if TabMenu:IsVisible() then
                TabMenu:SetVisible(false)
                -- Close floating detail window when hiding the menu
                if IsValid(detailFrame) then
                    detailFrame:Close()
                end
            else
                net.Start("RequestProfessionData")
                net.SendToServer()
                TabMenu:SetVisible(true)
                TabMenu:MakePopup()
            end
        end
    end
)

net.Receive(
    "OpenInventory",
    function()
        if not IsValid(TabMenu) then
            TabMenu = vgui.Create("CustomTabMenu")
        end
        net.Start("RequestProfessionData")
        net.SendToServer()
        TabMenu:SetVisible(true)
        TabMenu:MakePopup()

        -- Jump to the Inventory tab
        for _, tab in ipairs(TabMenu.Tabs) do
            if tab.TabName == "Inventory" then
                TabMenu:SelectTab(tab)
                break
            end
        end
    end
)