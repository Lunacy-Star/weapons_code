-- Dialogue box (typewriter display + options) and editor panel.

if SERVER then return end

include("cl_storage_ui.lua")

-- ================================================================
--  Shared style constants  (matching the tab menu aesthetic)
-- ================================================================
local COL = {
    bg          = Color(40,  40,  40,  245),
    bgLight     = Color(50,  50,  50,  230),
    bgMid       = Color(45,  45,  45,  220),
    panel       = Color(60,  60,  60,  200),
    accent      = Color(80,  120, 180, 255),
    accentHover = Color(100, 140, 200, 255),
    green       = Color(80,  180, 120, 255),
    greenHover  = Color(100, 200, 140, 255),
    danger      = Color(180, 70,  70,  255),
    dangerHover = Color(200, 90,  90,  255),
    textMain    = Color(255, 255, 255, 255),
    textSub     = Color(200, 200, 200, 255),
    textMuted   = Color(160, 160, 160, 255),
    border      = Color(100, 100, 100, 180),
    gold        = Color(255, 215, 0,   255),
}

-- ================================================================
--  Dialogue box
-- ================================================================

-- Current dialogue session state.
local dlgState = {
    open           = false,
    entity         = NULL,
    data           = nil,
    nodeID         = "start",
    panel          = nil,
    optPanel       = nil,
    typeTimer      = nil,
    fullText       = "",
    displayedChars = 0,
    textDone       = false,
    playerChoices  = {},    -- { choiceID = true } sent by server at open time
    startNodeID    = "start",
}

local CHARS_PER_TICK = 2   -- typewriter speed (characters per Think tick)
local TICK_RATE      = 0.03 -- seconds between typewriter ticks

-- Find a node by id inside data.dialogue.
local function FindNode(data, id)
    if not data or not data.dialogue then return nil end
    for _, node in ipairs(data.dialogue) do
        if node.id == id then return node end
    end
    return nil
end

-- Measure how tall the text block will be at a given wrap width.
local function MeasureWrappedHeight(text, font, wrapW)
    surface.SetFont(font)
    local lineH = draw.GetFontHeight(font)
    local lines = 0
    local words = {}
    for w in (text .. " "):gmatch("(.-) ") do table.insert(words, w) end
    local lineW = 0
    for _, word in ipairs(words) do
        local ww = surface.GetTextSize(word .. " ")
        if lineW + ww > wrapW and lineW > 0 then
            lines = lines + 1
            lineW = ww
        else
            lineW = lineW + ww
        end
    end
    lines = lines + 1
    for _ in text:gmatch("\n") do lines = lines + 1 end
    return lines * lineH
end

local function CloseDialogue()
    dlgState.open = false
    if IsValid(dlgState.panel) then dlgState.panel:Remove() end
    dlgState.panel    = nil
    dlgState.optPanel = nil
    if dlgState.typeTimer then timer.Remove(dlgState.typeTimer) end
    dlgState.typeTimer = nil
    if IsValid(dlgState.entity) then
        net.Start("DialogueClose")
        net.WriteEntity(dlgState.entity)
        net.SendToServer()
    end
    dlgState.entity       = NULL
    dlgState.data         = nil
    dlgState.playerChoices = {}
end

-- Shared helper: make a styled button inside a parent panel.
local function MakeOptionButton(parent, label, color, hoverColor, clickFn)
    local btn = vgui.Create("DButton", parent)
    btn:Dock(TOP)
    btn:SetTall(38)
    btn:DockMargin(0, 0, 0, 5)
    btn:SetText("")
    local hov = false
    btn.Paint = function(s, w, h)
        local bg = hov and hoverColor or color
        draw.RoundedBox(5, 0, 0, w, h, bg)
        draw.SimpleText(label, "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    btn.OnCursorEntered = function() hov = true  end
    btn.OnCursorExited  = function() hov = false end
    btn.DoClick = clickFn
    return btn
end

-- Navigate to a new node: update typewriter state and rebuild options when done.
local NavigateToNode  -- forward declaration

local function StartTypewriter(optPanel, node)
    dlgState.fullText       = node.text or ""
    dlgState.displayedChars = 0
    dlgState.textDone       = false
    optPanel:Clear()

    -- Tell the server a new node has started so it restarts the talk animation.
    if IsValid(dlgState.entity) then
        net.Start("DialogueNextNode")
        net.WriteEntity(dlgState.entity)
        net.SendToServer()
    end

    if dlgState.typeTimer then timer.Remove(dlgState.typeTimer) end
    local timerKey = "DialogueTypewriter_" .. tostring(dlgState.panel)
    dlgState.typeTimer = timerKey

    timer.Create(timerKey, TICK_RATE, 0, function()
        if not IsValid(dlgState.panel) or not dlgState.open then
            timer.Remove(timerKey)
            return
        end
        if dlgState.displayedChars < #dlgState.fullText then
            dlgState.displayedChars = math.min(
                dlgState.displayedChars + CHARS_PER_TICK,
                #dlgState.fullText
            )
        else
            timer.Remove(timerKey)
            dlgState.textDone = true
            PopulateOptions(optPanel, node)
        end
    end)
end

-- Build the option buttons beneath the text box.
function PopulateOptions(optPanel, node)
    optPanel:Clear()

    -- Helper: record a choice to the server and update local cache.
    local function RecordChoice(choiceID)
        if not choiceID or choiceID == "" then return end
        dlgState.playerChoices[choiceID] = true
        net.Start("DialogueRecordChoice")
        net.WriteString(choiceID)
        net.SendToServer()
    end

    -- Helper: handle end-of-conversation, recording singleUse node if needed.
    local function HandleEnd()
        local curNode = FindNode(dlgState.data, dlgState.nodeID)
        if curNode and curNode.singleUse and curNode.choiceID and curNode.choiceID ~= "" then
            RecordChoice(curNode.choiceID)
        end
        CloseDialogue()
    end

    -- Check if the player meets an option's conditions.
    -- requiresConditions = [ {ids=["id1","id2"], mode="any"|"all"}, ... ]
    -- All rows must pass (AND). Within a row, mode applies to its ids.
    local function MeetsRequirements(obj)
        local conds = obj.requiresConditions
        if not conds or #conds == 0 then
            local single = obj.requiresChoice
            if single and single ~= "" then
                return dlgState.playerChoices[single] == true
            end
            return true
        end
        for _, row in ipairs(conds) do
            local ids    = row.ids    or {}
            local mode   = row.mode   or "any"
            local negate = row.negate or false
            if #ids == 0 then continue end

            local passes
            if mode == "all" then
                passes = true
                for _, id in ipairs(ids) do
                    if not dlgState.playerChoices[id] then passes = false break end
                end
            else  -- any
                passes = false
                for _, id in ipairs(ids) do
                    if dlgState.playerChoices[id] then passes = true break end
                end
            end

            if negate then passes = not passes end
            if not passes then return false end
        end
        return true
    end

    -- Non-"end" options first, filtered by requirements.
    for _, opt in ipairs(node.options or {}) do
        local lbl = opt.label or "Continue"
        local act = opt.action or "end"
        if act == "storage" then
            if MeetsRequirements(opt) then
                MakeOptionButton(optPanel, lbl, COL.accent, COL.accentHover, function()
                    if opt.important and opt.choiceID and opt.choiceID ~= "" then
                        RecordChoice(opt.choiceID)
                    end
                    local npcUID   = IsValid(dlgState.entity) and dlgState.entity:GetNWString("DialogueUID", "") or ""
                    local isGlobal = opt.storageGlobal == true
                    CloseDialogue()
                    net.Start("DialogueOpenStorage")
                    net.WriteString(npcUID)
                    net.WriteBool(isGlobal)
                    net.SendToServer()
                end)
            end
        elseif act == "shop" then
            if MeetsRequirements(opt) then
                MakeOptionButton(optPanel, lbl, COL.accent, COL.accentHover, function()
                    if opt.important and opt.choiceID and opt.choiceID ~= "" then
                        RecordChoice(opt.choiceID)
                    end
                    local npcUID = IsValid(dlgState.entity) and dlgState.entity:GetNWString("DialogueUID", "") or ""
                    CloseDialogue()
                    net.Start("DialogueOpenShop")
                    net.WriteString(npcUID)
                    net.SendToServer()
                end)
            end
        elseif act ~= "end" then
            if not MeetsRequirements(opt) then continue end
            local targetID = (act == "next") and (node.nextID or "end") or act
            MakeOptionButton(optPanel, lbl, COL.accent, COL.accentHover, function()
                if opt.important and opt.choiceID and opt.choiceID ~= "" then
                    RecordChoice(opt.choiceID)
                end
                if targetID == "end" or not FindNode(dlgState.data, targetID) then
                    HandleEnd()
                else
                    local nextNode = FindNode(dlgState.data, targetID)
                    if nextNode then
                        -- If the destination node is a storage or shop node, intercept.
                        if nextNode.nodeType == "storage" then
                            local npcUID   = IsValid(dlgState.entity) and dlgState.entity:GetNWString("DialogueUID", "") or ""
                            local isGlobal = nextNode.storageGlobal == true
                            CloseDialogue()
                            net.Start("DialogueOpenStorage")
                            net.WriteString(npcUID)
                            net.WriteBool(isGlobal)
                            net.SendToServer()
                        elseif nextNode.nodeType == "shop" then
                            local npcUID = IsValid(dlgState.entity) and dlgState.entity:GetNWString("DialogueUID", "") or ""
                            CloseDialogue()
                            net.Start("DialogueOpenShop")
                            net.WriteString(npcUID)
                            net.SendToServer()
                        else
                            dlgState.nodeID = targetID
                            StartTypewriter(optPanel, nextNode)
                        end
                    end
                end
            end)
        end
    end

    -- End options — ALL of them rendered (no break), each filtered by requirements.
    local hasAnyEnd = false
    for _, opt in ipairs(node.options or {}) do
        if opt.action == "end" then
            if MeetsRequirements(opt) then
                hasAnyEnd = true
                MakeOptionButton(optPanel, opt.label or "Stop chatting", COL.danger, COL.dangerHover, function()
                    if opt.important and opt.choiceID and opt.choiceID ~= "" then
                        RecordChoice(opt.choiceID)
                    end
                    HandleEnd()
                end)
            end
        end
    end

    -- Fallback "Stop chatting" if no end options exist at all.
    if not hasAnyEnd then
        MakeOptionButton(optPanel, "Stop chatting", COL.danger, COL.dangerHover, HandleEnd)
    end
end

-- Open the dialogue box for the player.
local function OpenDialogueBox(data, ent)
    if IsValid(dlgState.panel) then dlgState.panel:Remove() end

    dlgState.open     = true
    dlgState.entity   = ent
    dlgState.data     = data
    dlgState.nodeID   = dlgState.startNodeID or "start"
    dlgState.optPanel = nil

    local startNode = FindNode(data, dlgState.nodeID)
    if not startNode then CloseDialogue() return end

    -- ---- Layout constants ----
    local SW      = ScrW()
    local SH      = ScrH()
    local PAD     = 14
    local FONT    = "DermaDefault"
    local PANEL_W = 660
    local WRAP_W  = PANEL_W - PAD * 2 - 20
    local LH      = draw.GetFontHeight(FONT)
    local BTN_H   = 38
    local BTN_GAP = 5

    -- Scan ALL nodes to find worst-case text height and option count,
    -- so the panel never resizes when navigating between nodes.
    local maxTextH    = LH * 4
    local maxOptCount = 1
    for _, node in ipairs(data.dialogue or {}) do
        local th = MeasureWrappedHeight(node.text or "", FONT, WRAP_W)
        if th > maxTextH then maxTextH = th end
        local hasStop = false
        for _, o in ipairs(node.options or {}) do
            if o.action == "end" then hasStop = true end
        end
        local oc = #(node.options or {}) + (hasStop and 0 or 1)
        if oc > maxOptCount then maxOptCount = oc end
    end

    local TEXT_AREA_H = maxTextH + PAD * 2
    local OPT_AREA_H  = maxOptCount * (BTN_H + BTN_GAP) + PAD
    local NAME_BAR_H  = 30
    local DIVIDER_H   = 2
    local PANEL_H     = math.min(
        PAD + NAME_BAR_H + PAD + DIVIDER_H + PAD + TEXT_AREA_H + PAD + OPT_AREA_H + PAD,
        SH - 80
    )

    -- ---- Frame ----
    local frame = vgui.Create("DPanel")
    frame:SetSize(PANEL_W, PANEL_H)
    frame:SetPos(SW / 2 - PANEL_W / 2, SH - PANEL_H - 50)
    frame:MakePopup()
    frame:SetKeyboardInputEnabled(false)
    frame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        surface.SetDrawColor(COL.accent.r, COL.accent.g, COL.accent.b, 150)
        surface.DrawOutlinedRect(1, 1, w - 2, h - 2, 1)
    end
    dlgState.panel = frame

    -- ---- Name bar ----
    local nameBar = vgui.Create("DPanel", frame)
    nameBar:Dock(TOP)
    nameBar:SetTall(NAME_BAR_H)
    nameBar:DockMargin(PAD, PAD, PAD, 0)
    nameBar.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
        draw.SimpleText(data.name or "???", "DermaDefaultBold", 12, h / 2, COL.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    -- X close button (always visible, right side of name bar).
    local closeW = 30
    local xBtn = vgui.Create("DButton", nameBar)
    xBtn:SetSize(closeW, 22)
    xBtn:SetPos(PANEL_W - PAD * 2 - closeW - 2, 4)
    xBtn:SetText("")
    local xHov = false
    xBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, xHov and COL.dangerHover or COL.danger)
        draw.SimpleText("✕", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    xBtn.OnCursorEntered = function() xHov = true  end
    xBtn.OnCursorExited  = function() xHov = false end
    xBtn.DoClick = CloseDialogue

    -- Admin buttons inside name bar.
    if LocalPlayer():IsAdmin() then
        local editBtn = vgui.Create("DButton", nameBar)
        editBtn:SetSize(110, 22)
        editBtn:SetPos(PANEL_W - PAD * 2 - closeW - 6 - 110, 4)
        editBtn:SetText("")
        local eHov = false
        editBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, eHov and COL.accentHover or COL.accent)
            draw.SimpleText("Edit Dialogue", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        editBtn.OnCursorEntered = function() eHov = true  end
        editBtn.OnCursorExited  = function() eHov = false end
        editBtn.DoClick = function()
            CloseDialogue()
            OpenDialogueEditor(ent)
        end

        local choicesBtn = vgui.Create("DButton", nameBar)
        choicesBtn:SetSize(110, 22)
        choicesBtn:SetPos(PANEL_W - PAD * 2 - closeW - 6 - 110 - 6 - 110, 4)
        choicesBtn:SetText("")
        local cHov = false
        choicesBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, cHov and Color(160, 120, 50, 255) or Color(140, 100, 40, 255))
            draw.SimpleText("Choices Menu", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        choicesBtn.OnCursorEntered = function() cHov = true  end
        choicesBtn.OnCursorExited  = function() cHov = false end
        choicesBtn.DoClick = function()
            OpenAdminChoicesMenu()
        end
    end

    -- ---- Divider ----
    local divider = vgui.Create("DPanel", frame)
    divider:Dock(TOP)
    divider:SetTall(DIVIDER_H)
    divider:DockMargin(PAD, PAD * 0.5, PAD, 0)
    divider.Paint = function(s, w, h)
        surface.SetDrawColor(COL.accent.r, COL.accent.g, COL.accent.b, 55)
        surface.DrawRect(0, 0, w, h)
    end

    -- ---- Text area ----
    local textPanel = vgui.Create("DPanel", frame)
    textPanel:Dock(TOP)
    textPanel:SetTall(TEXT_AREA_H)
    textPanel:DockMargin(PAD, PAD, PAD, 0)
    textPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
        local shown = dlgState.fullText:sub(1, dlgState.displayedChars)
        surface.SetFont(FONT)
        local x, y = 12, 10
        for _, line in ipairs(shown:Split("\n")) do
            local words2, lineW, lineWords = {}, 0, {}
            for w2 in (line .. " "):gmatch("(.-) ") do table.insert(words2, w2) end
            for _, word in ipairs(words2) do
                local ww = surface.GetTextSize(word .. " ")
                if lineW + ww > WRAP_W and lineW > 0 then
                    draw.SimpleText(table.concat(lineWords, " "), FONT, x, y, COL.textSub, TEXT_ALIGN_LEFT)
                    y = y + LH
                    lineWords, lineW = {word}, ww
                else
                    table.insert(lineWords, word)
                    lineW = lineW + ww
                end
            end
            if #lineWords > 0 then
                draw.SimpleText(table.concat(lineWords, " "), FONT, x, y, COL.textSub, TEXT_ALIGN_LEFT)
            end
            y = y + LH
        end
        if not dlgState.textDone then
            draw.SimpleText("[ click to skip ]", FONT, w - 10, h - 6, COL.textMuted, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM)
        end
    end
    -- Skip typewriter on click — safe because optPanel is on dlgState by the time any click fires.
    textPanel:SetMouseInputEnabled(true)
    textPanel.OnMousePressed = function()
        if not dlgState.textDone and IsValid(dlgState.optPanel) then
            dlgState.displayedChars = #dlgState.fullText
            dlgState.textDone = true
            if dlgState.typeTimer then timer.Remove(dlgState.typeTimer) end
            local curNode = FindNode(dlgState.data, dlgState.nodeID) or startNode
            PopulateOptions(dlgState.optPanel, curNode)
        end
    end

    -- ---- Options area ----
    local optOuter = vgui.Create("DPanel", frame)
    optOuter:Dock(FILL)
    optOuter:DockMargin(PAD, PAD, PAD, PAD)
    optOuter.Paint = function() end

    local optPanel = vgui.Create("DScrollPanel", optOuter)
    optPanel:Dock(FILL)
    local sb = optPanel:GetVBar()
    sb:SetWide(4)
    sb.Paint         = function(s, w, h) draw.RoundedBox(2, 0, 0, w, h, Color(30, 30, 30, 120)) end
    sb.btnUp.Paint   = function() end
    sb.btnDown.Paint = function() end
    sb.btnGrip.Paint = function(s, w, h) draw.RoundedBox(2, 0, 0, w, h, COL.accent) end

    -- Store on state so every closure (skip handler, typewriter callback) can reach it.
    dlgState.optPanel = optPanel

    StartTypewriter(optPanel, startNode)
end

-- ================================================================
--  Receive dialogue data from server  (registered once at bottom)
-- ================================================================

-- ================================================================
--  Editor
-- ================================================================

--[[
    Data model:
    {
        name        = "NPC Name",
        description = "Short desc shown on HUD",
        dialogue    = {
            {
                id      = "start",      -- unique id, "start" is always entry point
                text    = "Hello!",
                nextID  = nil,          -- only used by "next" action options
                options = {
                    { label = "Continue",       action = "next" },
                    { label = "Branch A",       action = "branchA" },
                    { label = "Stop chatting",  action = "end" },
                }
            },
            {
                id      = "branchA",
                text    = "You chose branch A.",
                options = {
                    { label = "Stop chatting", action = "end" }
                }
            },
        }
    }
--]]

function OpenDialogueEditor(ent)
    if not IsValid(ent) then return end

    -- Close any open dialogue first.
    CloseDialogue()

    -- Fetch current data from entity (via NW) or use blank template.
    -- We send a net message to get full data; for now we read what the server
    -- already pushed via DialogueOpen (admin can also open it by using the entity).
    -- Editors load a snapshot each time they open.

    local rawData = ent.CachedDialogueData
    if not rawData then
        rawData = {
            name        = ent:GetNWString("DialogueName", "Unnamed NPC"),
            description = ent:GetNWString("DialogueDesc",  ""),
            dialogue    = {
                {
                    id      = "start",
                    text    = "",
                    options = {
                        { label = "Stop chatting", action = "end" }
                    }
                }
            }
        }
    end

    -- -------------------------------------------------------
    --  Outer frame
    -- -------------------------------------------------------
    local W, H = 900, 700
    local frame = vgui.Create("DFrame")
    frame:SetSize(W, H)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, 30, COL.bgMid)
        draw.SimpleText("Modify Dialogue Entity", "DermaDefaultBold", 10, 15, COL.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COL.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    -- Close button.
    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(60, 22)
    closeBtn:SetPos(W - 68, 4)
    closeBtn:SetText("Close")
    closeBtn.Paint = function(s, w, h)
        local bg = s:IsHovered() and COL.dangerHover or COL.danger
        draw.RoundedBox(4, 0, 0, w, h, bg)
        draw.SimpleText("Close", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() frame:Remove() end

    local PAD = 10

    -- -------------------------------------------------------
    --  Top meta row: Custom ID, Name, Description, Model, Animations
    -- -------------------------------------------------------
    local metaPanel = vgui.Create("DPanel", frame)
    metaPanel:SetPos(PAD, 35)
    metaPanel:SetSize(W - PAD * 2, 180)
    metaPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
    end

    local function MakeLabel(parent, text, x, y)
        local l = vgui.Create("DLabel", parent)
        l:SetPos(x, y)
        l:SetText(text)
        l:SetTextColor(COL.textMuted)
        l:SizeToContents()
        return l
    end

    local function MakeEntry(parent, placeholder, x, y, w, h)
        local e = vgui.Create("DTextEntry", parent)
        e:SetPos(x, y)
        e:SetSize(w, h or 24)
        e:SetPlaceholderText(placeholder)
        e:SetTextColor(COL.textMain)
        e.Paint = function(s, sw, sh)
            draw.RoundedBox(3, 0, 0, sw, sh, Color(30, 30, 30, 220))
            s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
        end
        return e
    end

    -- Row 0: Custom ID (optional — overrides the auto-generated UID)
    MakeLabel(metaPanel, "Custom ID:", 10, 8)
    local customIDEntry = MakeEntry(metaPanel, "leave blank to keep auto-generated ID", 84, 6, 500, 24)
    customIDEntry:SetText(ent:GetNWString("DialogueUID", ""))

    local currentUIDHint = vgui.Create("DLabel", metaPanel)
    currentUIDHint:SetPos(590, 8)
    currentUIDHint:SetText("Current: " .. ent:GetNWString("DialogueUID", "?"))
    currentUIDHint:SetTextColor(COL.textMuted)
    currentUIDHint:SizeToContents()

    -- Row 1: Name
    MakeLabel(metaPanel, "NPC Name:", 10, 40)
    local nameEntry = MakeEntry(metaPanel, "NPC Name", 84, 38, 300, 24)
    nameEntry:SetText(rawData.name or "")

    -- Row 2: Description
    MakeLabel(metaPanel, "Description:", 10, 72)
    local descEntry = MakeEntry(metaPanel, "Short HUD description", 84, 70, 680, 24)
    descEntry:SetText(rawData.description or "")

    -- Row 3: Model path + preview
    MakeLabel(metaPanel, "Model path:", 10, 104)
    local modelEntry = MakeEntry(metaPanel, "models/kleiner.mdl", 84, 102, 560, 24)
    modelEntry:SetText(rawData.model or ent:GetModel() or "")

    local previewBtn = vgui.Create("DButton", metaPanel)
    previewBtn:SetPos(652, 102)
    previewBtn:SetSize(110, 24)
    previewBtn:SetText("")
    previewBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("Preview Model", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- -------------------------------------------------------
    --  Row 4: Idle anim | Talk anim
    --  Combos are created once, then repopulated via RebuildAnimCombos
    --  whenever the model path changes.
    -- -------------------------------------------------------
    MakeLabel(metaPanel, "Idle anim:", 10,  146)
    MakeLabel(metaPanel, "Talk anim:", 494, 146)

    local idleCombo = vgui.Create("DComboBox", metaPanel)
    idleCombo:SetPos(80, 142)
    idleCombo:SetSize(340, 24)
    idleCombo:SetTextColor(COL.textMain)
    idleCombo.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(30, 30, 30, 220))
        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
    end

    local talkCombo = vgui.Create("DComboBox", metaPanel)
    talkCombo:SetPos(564, 142)
    talkCombo:SetSize(190, 24)
    talkCombo:SetTextColor(COL.textMain)
    talkCombo.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(30, 30, 30, 220))
        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
    end

    -- Populates both combos from a model's sequence list.
    -- Tries to preserve current selection if the same name exists in the new list.
    local function RebuildAnimCombos(mdlPath, keepIdle, keepTalk)
        -- Build sequence list from a temporary clientside model entity.
        local seqList = { "(none)" }
        local tempEnt = ClientsideModel(mdlPath, RENDERGROUP_OTHER)
        if IsValid(tempEnt) then
            local rawSeqs = tempEnt:GetSequenceList()
            for i = 0, #rawSeqs do
                if rawSeqs[i] then table.insert(seqList, rawSeqs[i]) end
            end
            tempEnt:Remove()
        end
        table.sort(seqList, function(a, b)
            if a == "(none)" then return true end
            if b == "(none)" then return false end
            return a < b
        end)

        idleCombo:Clear()
        talkCombo:Clear()
        for _, name in ipairs(seqList) do
            idleCombo:AddChoice(name)
            talkCombo:AddChoice(name)
        end

        -- Restore previous selection if it still exists, otherwise reset to (none).
        local function restoreCombo(combo, want)
            if want and want ~= "" then
                for _, v in ipairs(seqList) do
                    if v == want then combo:SetValue(want) return end
                end
            end
            combo:SetValue("(none)")
        end
        restoreCombo(idleCombo, keepIdle)
        restoreCombo(talkCombo, keepTalk)
    end

    -- Initial population from current entity model.
    RebuildAnimCombos(
        rawData.model or ent:GetModel() or "",
        rawData.idleAnim or "",
        rawData.talkAnim or ""
    )

    -- Repopulate when the admin types a new model path.
    -- Use a small debounce so we don't thrash on every keypress.
    local rebuildTimer = "DlgEditorRebuild_" .. tostring(frame)
    modelEntry.OnChange = function(s)
        timer.Remove(rebuildTimer)
        timer.Create(rebuildTimer, 0.6, 1, function()
            if not IsValid(idleCombo) or not IsValid(talkCombo) then return end
            local path = s:GetText()
            if path == "" then return end
            RebuildAnimCombos(path, idleCombo:GetValue(), talkCombo:GetValue())
        end)
    end

    -- ▶ Test buttons for each combo.
    local function MakeTestBtn(parent, x, y, getAnimFn)
        local btn = vgui.Create("DButton", parent)
        btn:SetPos(x, y)
        btn:SetSize(60, 24)
        btn:SetText("")
        btn.Paint = function(s, w, h)
            draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
            draw.SimpleText("▶ Test", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        btn.DoClick = function()
            local animName = getAnimFn()
            if animName == "(none)" or animName == "" then return end
            local mdlPath = modelEntry:GetText()
            if mdlPath == "" then return end

            -- Capture animName in a local so LayoutEntity can't read a stale combo.
            local capturedAnim = animName

            local pf = vgui.Create("DFrame")
            pf:SetSize(240, 300)
            pf:SetTitle("Anim: " .. capturedAnim)
            pf:Center()
            pf:MakePopup()
            pf.Paint = function(s, w, h)
                draw.RoundedBox(6, 0, 0, w, h, COL.bg)
                draw.RoundedBox(6, 0, 0, w, 24, COL.bgMid)
            end
            local mv = vgui.Create("DModelPanel", pf)
            mv:Dock(FILL)
            mv:DockMargin(4, 28, 4, 4)
            mv:SetModel(mdlPath)
            mv:SetFOV(60)
            mv:SetCamPos(Vector(60, 0, 60))
            mv:SetLookAt(Vector(0, 0, 40))
            -- capturedAnim is a plain string — no panel references, can never be NULL.
            function mv:LayoutEntity(e)
                local seq = e:LookupSequence(capturedAnim)
                if seq and seq >= 0 then e:ResetSequence(seq) end
                self:RunAnimation()
            end
        end
        return btn
    end

    MakeTestBtn(metaPanel, 428, 142, function() return IsValid(idleCombo) and idleCombo:GetValue() or "" end)
    MakeTestBtn(metaPanel, 760, 142, function() return IsValid(talkCombo) and talkCombo:GetValue() or "" end)

    -- Preview Model button (defined above, wired here so it reads idleCombo safely).
    previewBtn.DoClick = function()
        local mdlPath = modelEntry:GetText()
        if mdlPath == "" then return end
        local capturedIdle = (IsValid(idleCombo) and idleCombo:GetValue() or "")

        local pf = vgui.Create("DFrame")
        pf:SetSize(240, 280)
        pf:SetTitle("Model Preview")
        pf:Center()
        pf:MakePopup()
        pf.Paint = function(s, w, h)
            draw.RoundedBox(6, 0, 0, w, h, COL.bg)
            draw.RoundedBox(6, 0, 0, w, 24, COL.bgMid)
        end
        local mv = vgui.Create("DModelPanel", pf)
        mv:Dock(FILL)
        mv:DockMargin(4, 28, 4, 4)
        mv:SetModel(mdlPath)
        mv:SetFOV(60)
        mv:SetCamPos(Vector(60, 0, 60))
        mv:SetLookAt(Vector(0, 0, 40))
        function mv:LayoutEntity(e)
            local seq = (capturedIdle ~= "" and capturedIdle ~= "(none)")
                        and e:LookupSequence(capturedIdle) or 0
            if seq and seq >= 0 then e:ResetSequence(seq) end
            self:RunAnimation()
        end
    end

    -- -------------------------------------------------------
    --  Left column: node list
    -- -------------------------------------------------------
    local LEFT_W = 200
    local contentY = 225
    local contentH = H - contentY - 50

    local nodeListPanel = vgui.Create("DPanel", frame)
    nodeListPanel:SetPos(PAD, contentY)
    nodeListPanel:SetSize(LEFT_W, contentH)
    nodeListPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
    end

    local nodeLabel = vgui.Create("DLabel", nodeListPanel)
    nodeLabel:SetPos(8, 6)
    nodeLabel:SetText("Dialogue Nodes")
    nodeLabel:SetTextColor(COL.textMuted)
    nodeLabel:SizeToContents()

    local nodeScroll = vgui.Create("DScrollPanel", nodeListPanel)
    nodeScroll:SetPos(4, 26)
    nodeScroll:SetSize(LEFT_W - 8, contentH - 60)

    local addNodeBtn = vgui.Create("DButton", nodeListPanel)
    addNodeBtn:SetPos(4, contentH - 30)
    addNodeBtn:SetSize(LEFT_W - 8, 24)
    addNodeBtn:SetText("")
    addNodeBtn.Paint = function(s, w, h)
        local bg = s:IsHovered() and COL.greenHover or COL.green
        draw.RoundedBox(4, 0, 0, w, h, bg)
        draw.SimpleText("+ Add Node", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    -- -------------------------------------------------------
    --  Right column: node editor
    -- -------------------------------------------------------
    local RIGHT_X = PAD + LEFT_W + PAD
    local RIGHT_W = W - RIGHT_X - PAD

    local nodeEditorPanel = vgui.Create("DPanel", frame)
    nodeEditorPanel:SetPos(RIGHT_X, contentY)
    nodeEditorPanel:SetSize(RIGHT_W, contentH)
    nodeEditorPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
    end

    -- -------------------------------------------------------
    --  Working copy of dialogue nodes (array, in-memory).
    -- -------------------------------------------------------
    --  Helper: migrate old requiresChoices/requiresMode flat fields
    --  into the new array-of-condition-rows format.
    -- -------------------------------------------------------
    local function MigrateConditions(o)
        -- Nodes save as "requiredConditions", options save as "requiresConditions".
        -- Check both so either works here.
        local existing = o.requiredConditions or o.requiresConditions
        if existing and #existing > 0 then
            return existing
        end
        -- Legacy: flat requiresChoices array + requiresMode
        local reqs = o.requiresChoices or {}
        if #reqs == 0 and o.requiresChoice and o.requiresChoice ~= "" then
            reqs = { o.requiresChoice }
        end
        if #reqs > 0 then
            return { { ids = reqs, mode = o.requiresMode or "any", negate = false } }
        end
        return {}
    end

    local nodes = {}
    for _, n in ipairs(rawData.dialogue or {}) do
        local opts = {}
        for _, o in ipairs(n.options or {}) do
            table.insert(opts, {
                label               = o.label,
                action              = o.action,
                important           = o.important or false,
                choiceID            = o.choiceID  or "",
                storageGlobal       = o.storageGlobal or false,
                requiresConditions  = MigrateConditions(o),
            })
        end
        table.insert(nodes, {
            id                  = n.id,
            text                = n.text,
            nextID              = n.nextID,
            isStart             = n.isStart   or false,
            singleUse           = n.singleUse or false,
            choiceID            = n.choiceID  or "",
            nodeType            = n.nodeType  or nil,
            storageGlobal       = n.storageGlobal or false,
            requiredConditions  = MigrateConditions(n),
            options             = opts,
        })
    end
    if #nodes == 0 then
        nodes = {{
            id = "start", text = "", isStart = false, singleUse = false,
            choiceID = "", requiredConditions = {},
            options = {{ label = "Stop chatting", action = "end",
                         important = false, choiceID = "", requiresConditions = {} }}
        }}
    end

    local selectedNode = nil  -- currently editing node (table ref)
    local nodeBtns     = {}   -- list of DButton panels in nodeScroll

    -- Forward declarations.
    local RebuildNodeList, LoadNodeEditor

    -- -------------------------------------------------------
    --  Node list builder
    -- -------------------------------------------------------
    RebuildNodeList = function(selectID)
        nodeScroll:Clear()
        nodeBtns = {}

        for i, node in ipairs(nodes) do
            local nb = vgui.Create("DButton", nodeScroll)
            nb:Dock(TOP)
            nb:SetTall(30)
            nb:DockMargin(0, 2, 0, 0)
            nb:SetText("")
            local isSelected = (selectedNode and selectedNode.id == node.id) or (selectID == node.id)
            if selectID and node.id == selectID then
                selectedNode = node
            end
            nb._node   = node
            nb._sel    = isSelected
            nb.Paint = function(s, w, h)
                local bg = s._sel and COL.accent or (s:IsHovered() and COL.panel or COL.bg)
                draw.RoundedBox(4, 0, 0, w, h, bg)
                local lbl = node.id or "?"
                local badges = {}
                if node.isStart   then table.insert(badges, "▶") end
                if node.singleUse then table.insert(badges, "①") end
                local prefix = #badges > 0 and (table.concat(badges, "") .. " ") or ""
                draw.SimpleText(prefix .. lbl, "DermaDefault", 8, h/2, COL.textMain, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end
            nb.DoClick = function()
                selectedNode = node
                for _, b in ipairs(nodeBtns) do b._sel = (b._node == node) end
                LoadNodeEditor(node)
            end
            table.insert(nodeBtns, nb)
        end

        -- Auto-select first if nothing selected.
        if not selectedNode and #nodes > 0 then
            selectedNode = nodes[1]
            if nodeBtns[1] then nodeBtns[1]._sel = true end
            LoadNodeEditor(selectedNode)
        end
    end

    LoadNodeEditor = function(node)
        nodeEditorPanel:Clear()

        local ep = nodeEditorPanel
        local EW = RIGHT_W - PAD * 2

        -- ---- Shared helpers (local to this editor instance) ----
        local function RL(parent, text, x, y)
            local l = vgui.Create("DLabel", parent)
            l:SetPos(x, y); l:SetText(text)
            l:SetTextColor(COL.textMuted); l:SizeToContents()
        end
        local function RE(parent, ph, x, y, w, h)
            local e = vgui.Create("DTextEntry", parent)
            e:SetPos(x, y); e:SetSize(w, h or 20)
            e:SetPlaceholderText(ph); e:SetTextColor(COL.textMain)
            e.Paint = function(s, sw, sh)
                draw.RoundedBox(3, 0, 0, sw, sh, Color(30,30,30,220))
                s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
            end
            return e
        end
        local function MakeCheckbox(parent, label, x, y, getValue, setValue)
            local cb = vgui.Create("DCheckBox", parent)
            cb:SetPos(x, y); cb:SetSize(16, 16); cb:SetValue(getValue())
            cb.OnChange = function(s, val) setValue(val) end
            local lbl = vgui.Create("DLabel", parent)
            lbl:SetPos(x + 20, y); lbl:SetText(label)
            lbl:SetTextColor(COL.textSub); lbl:SizeToContents()
            return cb
        end

        -- ---- MakeConditionsList ----
        -- Renders a scrollable list of condition rows into `container` (a DScrollPanel).
        -- Each row: [ any|all ▾ ] [ choiceID entry ] [ × ]   + [ + Add Condition ] button
        -- condList is the array of {ids=[...], mode="any"|"all"} tables (mutated in place).
        -- rowH is the pixel height of each row (used to size the container externally).
        local ROW_H   = 28
        local ROW_GAP = 4
        -- onChange is called whenever a row is added or removed (so callers can resize).
        local function MakeConditionsList(parent, condList, containerW, onChange)
            local function RebuildRows()
                parent:Clear()

                for ci, cond in ipairs(condList) do
                    local row = vgui.Create("DPanel", parent)
                    row:Dock(TOP)
                    row:SetTall(ROW_H)
                    row:DockMargin(0, ci == 1 and 0 or ROW_GAP, 0, 0)
                    row.Paint = function(s, w, h)
                        draw.RoundedBox(3, 0, 0, w, h, Color(35,35,35,200))
                    end

                    local mc = vgui.Create("DComboBox", row)
                    mc:SetPos(2, 4); mc:SetSize(52, 20)
                    mc:SetTextColor(COL.textMain)
                    mc.Paint = function(s, w, h)
                        draw.RoundedBox(3,0,0,w,h,Color(25,25,25,220))
                        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
                    end
                    mc:AddChoice("any"); mc:AddChoice("all")
                    mc:SetValue(cond.mode or "any")
                    mc.OnSelect = function(s, idx, val) cond.mode = val end

                    -- "Not" checkbox — inverts the whole row's result.
                    local notCB = vgui.Create("DCheckBox", row)
                    notCB:SetPos(58, 6); notCB:SetSize(14, 14)
                    notCB:SetValue(cond.negate or false)
                    notCB.OnChange = function(s, val) cond.negate = val end

                    local notLbl = vgui.Create("DLabel", row)
                    notLbl:SetPos(75, 5); notLbl:SetText("Not")
                    notLbl:SetTextColor(Color(200, 120, 120)); notLbl:SizeToContents()

                    local ie = vgui.Create("DTextEntry", row)
                    ie:SetPos(102, 4); ie:SetSize(containerW - 102 - 30, 20)
                    ie:SetPlaceholderText("choiceID, choiceID2 ...")
                    ie:SetTextColor(COL.textMain)
                    ie.Paint = function(s, w, h)
                        draw.RoundedBox(3,0,0,w,h,Color(25,25,25,220))
                        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
                    end
                    ie:SetText(table.concat(cond.ids or {}, ", "))
                    ie.OnChange = function(s)
                        local list = {}
                        for part in (s:GetText() .. ","):gmatch("([^,]+),") do
                            local t = part:match("^%s*(.-)%s*$")
                            if t ~= "" then table.insert(list, t) end
                        end
                        cond.ids = list
                    end

                    local xb = vgui.Create("DButton", row)
                    xb:SetPos(containerW - 26, 4); xb:SetSize(24, 20)
                    xb:SetText("")
                    xb.Paint = function(s, w, h)
                        draw.RoundedBox(3,0,0,w,h, s:IsHovered() and COL.dangerHover or COL.danger)
                        draw.SimpleText("×","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                    end
                    xb.DoClick = function()
                        table.remove(condList, ci)
                        RebuildRows()
                        if onChange then onChange() end
                    end
                end

                local ab = vgui.Create("DButton", parent)
                ab:Dock(TOP); ab:SetTall(22)
                ab:DockMargin(0, ROW_GAP, 0, 0); ab:SetText("")
                ab.Paint = function(s, w, h)
                    draw.RoundedBox(3,0,0,w,h, s:IsHovered() and Color(60,80,60,200) or Color(45,65,45,200))
                    draw.SimpleText("+ Add Condition","DermaDefault",w/2,h/2,COL.textSub,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
                ab.DoClick = function()
                    table.insert(condList, { ids = {}, mode = "any", negate = false })
                    RebuildRows()
                    if onChange then onChange() end
                end
            end
            RebuildRows()
        end

        -- Returns pixel height needed to show condList fully (no scroll needed).
        local function CondListH(condList)
            local n = #condList
            return n * (ROW_H + ROW_GAP) + 22 + ROW_GAP  -- rows + add button
        end

        -- ---- Node ID ----
        MakeLabel(ep, "Node ID:", PAD, 10)
        local idEntry = MakeEntry(ep, "unique_id", PAD + 70, 8, EW - 70, 24)
        idEntry:SetText(node.id or "")
        if node.id == "start" then idEntry:SetEditable(false) end
        idEntry.OnChange = function(s)
            local val = s:GetText()
            if val ~= "" then node.id = val end
        end

        -- ---- Node flags ----
        MakeCheckbox(ep, "Is start node", PAD,       38,
            function() return node.isStart   or false end,
            function(v) node.isStart   = v end)
        MakeCheckbox(ep, "Single use",    PAD + 140, 38,
            function() return node.singleUse or false end,
            function(v) node.singleUse = v end)

        MakeLabel(ep, "Conversation ID:", PAD + 280, 40)
        local nodeChoiceEntry = MakeEntry(ep, "id_for_singleUse_tracking", PAD + 390, 38, EW - 390, 22)
        nodeChoiceEntry:SetText(node.choiceID or "")
        nodeChoiceEntry.OnChange = function(s) node.choiceID = s:GetText() end

        -- ---- Storage / Shop node flags ----
        local storageCB = MakeCheckbox(ep, "Storage node", PAD, 62,
            function() return node.nodeType == "storage" end,
            function(v) node.nodeType = v and "storage" or (node.nodeType == "storage" and nil or node.nodeType) end)
        MakeCheckbox(ep, "Global storage", PAD + 120, 62,
            function() return node.storageGlobal or false end,
            function(v) node.storageGlobal = v end)
        MakeCheckbox(ep, "Shop node", PAD + 260, 62,
            function() return node.nodeType == "shop" end,
            function(v) node.nodeType = v and "shop" or (node.nodeType == "shop" and nil or node.nodeType) end)

        -- ---- Node required conditions ----
        MakeLabel(ep, "Required conditions (AND between rows):", PAD, 86)

        if not node.requiredConditions then node.requiredConditions = {} end

        -- Fixed-height scroll that shows up to 3 rows before scrolling.
        local MAX_VISIBLE_COND_ROWS = 3
        local nodeCondScrollH = math.min(
            math.max(CondListH(node.requiredConditions), 28),
            MAX_VISIBLE_COND_ROWS * (ROW_H + ROW_GAP) + 22 + ROW_GAP + 4
        )

        local nodeCondScroll = vgui.Create("DScrollPanel", ep)
        nodeCondScroll:SetPos(PAD, 102)
        nodeCondScroll:SetSize(EW, nodeCondScrollH)
        local ncSB = nodeCondScroll:GetVBar()
        ncSB:SetWide(4)
        ncSB.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
        ncSB.btnUp.Paint   = function() end
        ncSB.btnDown.Paint = function() end
        ncSB.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

        MakeConditionsList(nodeCondScroll, node.requiredConditions, EW - 8)

        -- ---- Dialogue text ----
        local textY = 102 + nodeCondScrollH + 10
        MakeLabel(ep, "Text:", PAD, textY)
        local textArea = vgui.Create("DTextEntry", ep)
        textArea:SetPos(PAD, textY + 16)
        textArea:SetSize(EW, 100)
        textArea:SetMultiline(true)
        textArea:SetText(node.text or "")
        textArea:SetTextColor(COL.textMain)
        textArea.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, Color(30, 30, 30, 220))
            s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
        end
        textArea.OnChange = function(s) node.text = s:GetText() end

        -- ---- Options ----
        local optLabelY = textY + 16 + 100 + 10
        MakeLabel(ep, "Options:", PAD, optLabelY)

        local optScroll = vgui.Create("DScrollPanel", ep)
        optScroll:SetPos(PAD, optLabelY + 16)
        optScroll:SetSize(EW, contentH - (optLabelY + 16) - 4)
        local sb = optScroll:GetVBar()
        sb:SetWide(4)
        sb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
        sb.btnUp.Paint   = function() end
        sb.btnDown.Paint = function() end
        sb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

        local RebuildOptRows

        -- Height constants for option rows.
        local OPT_BASE_H    = 70   -- label/action/important/choiceID rows
        local OPT_COND_LABEL_H = 20
        local OPT_COND_MIN_H   = 28  -- minimum visible height for cond area (just the + button)

        RebuildOptRows = function()
            optScroll:Clear()

            for oi, opt in ipairs(node.options or {}) do
                if not opt.requiresConditions then opt.requiresConditions = {} end

                -- Total visible condition area height (capped at 3 rows before scrolling).
                local condVisH = math.min(
                    math.max(CondListH(opt.requiresConditions), OPT_COND_MIN_H),
                    3 * (ROW_H + ROW_GAP) + 22 + ROW_GAP + 4
                )
                local optRowH = OPT_BASE_H + OPT_COND_LABEL_H + condVisH + 8

                local row = vgui.Create("DPanel", optScroll)
                row:Dock(TOP)
                row:SetTall(optRowH)
                row:DockMargin(0, 2, 0, 2)
                row.Paint = function(s, w, h)
                    draw.RoundedBox(3, 0, 0, w, h, COL.bg)
                end

                local HALF = math.floor((EW - 110) / 2)

                -- Label | Action | Remove
                RL(row, "Label:",  6, 6)
                local lE = RE(row, "Button text", 50, 4, HALF - 54, 20)
                lE:SetText(opt.label or "")
                lE.OnChange = function(s) opt.label = s:GetText() end

                RL(row, "Action:", HALF - 2, 6)
                local aE = RE(row, "end / next / nodeID", HALF + 44, 4, HALF - 44, 20)
                aE:SetText(opt.action or "end")
                aE.OnChange = function(s) opt.action = s:GetText() end

                local removeBtn = vgui.Create("DButton", row)
                removeBtn:SetPos(EW - 100, 4); removeBtn:SetSize(94, 20); removeBtn:SetText("")
                removeBtn.Paint = function(s, w, h)
                    draw.RoundedBox(3,0,0,w,h, s:IsHovered() and COL.dangerHover or COL.danger)
                    draw.SimpleText("Remove","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
                removeBtn.DoClick = function()
                    table.remove(node.options, oi)
                    RebuildOptRows()
                end

                -- Important | Choice ID
                MakeCheckbox(row, "Important", 6, 32,
                    function() return opt.important or false end,
                    function(v) opt.important = v end)

                RL(row, "Choice ID:", 100, 34)
                local cE = RE(row, "saved_when_picked", 168, 32, HALF - 80, 20)
                cE:SetText(opt.choiceID or "")
                cE.OnChange = function(s) opt.choiceID = s:GetText() end

                -- Required conditions
                RL(row, "Requires (AND between rows):", 6, 58)

                local condScroll = vgui.Create("DScrollPanel", row)
                condScroll:SetPos(6, OPT_BASE_H + OPT_COND_LABEL_H - 10)
                condScroll:SetSize(EW - 12, condVisH)
                local csb = condScroll:GetVBar()
                csb:SetWide(4)
                csb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
                csb.btnUp.Paint   = function() end
                csb.btnDown.Paint = function() end
                csb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

                MakeConditionsList(condScroll, opt.requiresConditions, EW - 20, RebuildOptRows)
            end

            -- + Add Option
            local addOptBtn = vgui.Create("DButton", optScroll)
            addOptBtn:Dock(TOP); addOptBtn:SetTall(28)
            addOptBtn:DockMargin(0, 6, 0, 0); addOptBtn:SetText("")
            addOptBtn.Paint = function(s, w, h)
                draw.RoundedBox(4,0,0,w,h, s:IsHovered() and COL.accentHover or COL.accent)
                draw.SimpleText("+ Add Option","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
            end
            addOptBtn.DoClick = function()
                if not node.options then node.options = {} end
                table.insert(node.options, {
                    label = "Continue", action = "end",
                    important = false, choiceID = "", storageGlobal = false, requiresConditions = {}
                })
                RebuildOptRows()
            end
        end

        RebuildOptRows()
    end

    -- Add node button logic.
    addNodeBtn.DoClick = function()
        local newID = "node_" .. tostring(#nodes + 1)
        local newNode = {
            id      = newID,
            text    = "",
            options = {{label = "Stop chatting", action = "end"}},
        }
        table.insert(nodes, newNode)
        selectedNode = newNode
        RebuildNodeList(newID)
        LoadNodeEditor(newNode)
    end

    RebuildNodeList("start")

    -- -------------------------------------------------------
    --  Bottom bar: Save & Apply  |  Save to Map  |  Delete Node
    -- -------------------------------------------------------
    local saveBtn = vgui.Create("DButton", frame)
    saveBtn:SetPos(W / 2 - 210, H - 40)
    saveBtn:SetSize(200, 32)
    saveBtn:SetText("")
    saveBtn.Paint = function(s, w, h)
        local bg = s:IsHovered() and COL.greenHover or COL.green
        draw.RoundedBox(6, 0, 0, w, h, bg)
        draw.SimpleText("Save & Apply", "DermaDefaultBold", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    saveBtn.DoClick = function()
        local idleVal = idleCombo:GetValue()
        local talkVal = talkCombo:GetValue()
        local customID = customIDEntry:GetText()
        local finalData = {
            name        = nameEntry:GetText(),
            description = descEntry:GetText(),
            model       = modelEntry:GetText(),
            idleAnim    = (idleVal == "(none)") and "" or idleVal,
            talkAnim    = (talkVal == "(none)") and "" or talkVal,
            customUID   = customID,  -- server strips this after applying it
            dialogue    = nodes,
        }
        ent.CachedDialogueData = finalData
        net.Start("DialogueEdit")
        net.WriteEntity(ent)
        net.WriteString(util.TableToJSON(finalData))
        net.SendToServer()
        frame:Remove()
    end

    -- Save to Map: persists ALL dialogue entity positions/rotations on this map.
    local mapBtn = vgui.Create("DButton", frame)
    mapBtn:SetPos(W / 2 + 10, H - 40)
    mapBtn:SetSize(200, 32)
    mapBtn:SetText("")
    mapBtn.Paint = function(s, w, h)
        local bg = s:IsHovered() and Color(180, 140, 50, 255) or Color(160, 120, 40, 255)
        draw.RoundedBox(6, 0, 0, w, h, bg)
        draw.SimpleText("Save to Map", "DermaDefaultBold", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    mapBtn.DoClick = function()
        net.Start("DialogueSaveToMap")
        net.SendToServer()
    end

    -- Delete node button (bottom-left).
    local delNodeBtn = vgui.Create("DButton", frame)
    delNodeBtn:SetPos(PAD, H - 40)
    delNodeBtn:SetSize(130, 32)
    delNodeBtn:SetText("")
    delNodeBtn.Paint = function(s, w, h)
        local bg = s:IsHovered() and COL.dangerHover or COL.danger
        draw.RoundedBox(6, 0, 0, w, h, bg)
        draw.SimpleText("Delete Node", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    delNodeBtn.DoClick = function()
        if not selectedNode or selectedNode.id == "start" then return end
        for i, n in ipairs(nodes) do
            if n == selectedNode then
                table.remove(nodes, i)
                break
            end
        end
        selectedNode = nil
        nodeEditorPanel:Clear()
        RebuildNodeList("start")
    end
end

-- ================================================================
--  net.Receive – registered once here at the bottom.
-- ================================================================
net.Receive("DialogueOpen", function()
    local jsonStr    = net.ReadString()
    local ent        = net.ReadEntity()
    local choicesStr = net.ReadString()
    local startID    = net.ReadString()
    local data       = util.JSONToTable(jsonStr)
    if not data then return end
    if IsValid(ent) then ent.CachedDialogueData = data end
    dlgState.playerChoices = util.JSONToTable(choicesStr) or {}
    dlgState.startNodeID   = (startID ~= "") and startID or "start"
    OpenDialogueBox(data, ent)
end)

-- ================================================================
--  Admin: Choices Menu
-- ================================================================

local choicesMenuPanel = nil

local TYPE_COL = {
    conversation = Color(120, 180, 255),
    choice       = Color(150, 220, 150),
    unknown      = Color(160, 160, 160),
}
local TYPE_LABEL = {
    conversation = "Conversation",
    choice       = "Choice",
    unknown      = "Unknown",
}

local function OpenChoicesMenu()
    if not LocalPlayer():IsAdmin() then return end
    if IsValid(choicesMenuPanel) then choicesMenuPanel:Remove() end

    local W, H = 700, 520
    local frame = vgui.Create("DFrame")
    frame:SetSize(W, H)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, 30, COL.bgMid)
        draw.SimpleText("Player Choices", "DermaDefaultBold", 10, 15, COL.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COL.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    choicesMenuPanel = frame

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(60, 22); closeBtn:SetPos(W - 68, 4); closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
        draw.SimpleText("Close", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() frame:Remove() end

    local PAD = 10

    -- ---- Player selector ----
    local selectorPanel = vgui.Create("DPanel", frame)
    selectorPanel:SetPos(PAD, 35)
    selectorPanel:SetSize(W - PAD * 2, 36)
    selectorPanel.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
    end

    local selLabel = vgui.Create("DLabel", selectorPanel)
    selLabel:SetPos(8, 10); selLabel:SetText("Player:")
    selLabel:SetTextColor(COL.textMuted); selLabel:SizeToContents()

    local playerCombo = vgui.Create("DComboBox", selectorPanel)
    playerCombo:SetPos(58, 6); playerCombo:SetSize(400, 24)
    playerCombo:SetTextColor(COL.textMain)
    playerCombo.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(30, 30, 30, 220))
        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
    end

    -- Populate with all connected players.
    local playerMap = {}  -- display name -> steamid64
    for _, p in ipairs(player.GetAll()) do
        local display = p:Nick() .. " (" .. p:SteamID() .. ")"
        playerCombo:AddChoice(display)
        playerMap[display] = p:SteamID64()
    end

    -- ---- Legend ----
    local legendPanel = vgui.Create("DPanel", frame)
    legendPanel:SetPos(PAD, 78)
    legendPanel:SetSize(W - PAD * 2, 22)
    legendPanel.Paint = function() end

    local lx = 0
    for _, t in ipairs({"conversation", "choice", "unknown"}) do
        local dot = vgui.Create("DPanel", legendPanel)
        dot:SetPos(lx, 4); dot:SetSize(12, 12)
        local c = TYPE_COL[t]
        dot.Paint = function(s, w, h) draw.RoundedBox(2, 0, 0, w, h, c) end

        local lbl = vgui.Create("DLabel", legendPanel)
        lbl:SetPos(lx + 16, 3); lbl:SetText(TYPE_LABEL[t])
        lbl:SetTextColor(COL.textMuted); lbl:SizeToContents()
        lx = lx + 16 + lbl:GetWide() + 20
    end

    -- ---- Choices list ----
    local listScroll = vgui.Create("DScrollPanel", frame)
    listScroll:SetPos(PAD, 106)
    listScroll:SetSize(W - PAD * 2, H - 106 - PAD)
    local sb = listScroll:GetVBar()
    sb:SetWide(4)
    sb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
    sb.btnUp.Paint   = function() end
    sb.btnDown.Paint = function() end
    sb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

    local currentSteam = nil  -- steamid64 of the selected player

    local function RebuildChoiceList(entries)
        listScroll:Clear()

        if #entries == 0 then
            local empty = vgui.Create("DLabel", listScroll)
            empty:Dock(TOP); empty:DockMargin(0, 10, 0, 0)
            empty:SetText("No choices recorded for this player.")
            empty:SetTextColor(COL.textMuted)
            empty:SetContentAlignment(5)
            empty:SetTall(30)
            return
        end

        -- Section headers + rows.
        local lastType = nil
        for _, entry in ipairs(entries) do
            -- Section header when type changes.
            if entry.type ~= lastType then
                lastType = entry.type
                local hdr = vgui.Create("DPanel", listScroll)
                hdr:Dock(TOP); hdr:SetTall(24); hdr:DockMargin(0, 6, 0, 2)
                local hdrCol = TYPE_COL[entry.type] or COL.textMuted
                hdr.Paint = function(s, w, h)
                    draw.RoundedBox(3, 0, 0, w, h, Color(hdrCol.r*0.3, hdrCol.g*0.3, hdrCol.b*0.3, 180))
                    draw.SimpleText(
                        TYPE_LABEL[entry.type] or entry.type,
                        "DermaDefaultBold", 8, h/2,
                        hdrCol, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER
                    )
                end
            end

            -- Choice row.
            local row = vgui.Create("DPanel", listScroll)
            row:Dock(TOP); row:SetTall(34); row:DockMargin(0, 1, 0, 0)
            local entryType = entry.type
            local entryID   = entry.id
            local entrySrc  = entry.source
            row.Paint = function(s, w, h)
                draw.RoundedBox(3, 0, 0, w, h, COL.bgMid)
                -- Colour dot
                local c = TYPE_COL[entryType] or COL.textMuted
                draw.RoundedBox(2, 8, h/2 - 5, 10, 10, c)
                -- ID
                draw.SimpleText(entryID, "DermaDefaultBold", 26, h/2, COL.textMain, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                -- Source hint
                if entrySrc ~= "" then
                    draw.SimpleText(entrySrc, "DermaDefault", 26 + 220, h/2, COL.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                end
            end

            local delBtn = vgui.Create("DButton", row)
            delBtn:SetSize(70, 22); delBtn:SetPos(W - PAD * 2 - 74, 6); delBtn:SetText("")
            delBtn.Paint = function(s, w, h)
                draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
                draw.SimpleText("Delete", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            local capturedID    = entryID
            local capturedSteam = currentSteam
            delBtn.DoClick = function()
                if not capturedSteam then return end
                net.Start("DialogueAdminDeleteChoice")
                net.WriteString(capturedSteam)
                net.WriteString(capturedID)
                net.SendToServer()
            end
        end
    end

    -- Load button.
    local loadBtn = vgui.Create("DButton", selectorPanel)
    loadBtn:SetPos(468, 6); loadBtn:SetSize(80, 24); loadBtn:SetText("")
    loadBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("Load", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    loadBtn.DoClick = function()
        local sel = playerCombo:GetValue()
        local sid = playerMap[sel]
        if not sid then return end
        currentSteam = sid
        net.Start("DialogueAdminGetChoices")
        net.WriteString(sid)
        net.SendToServer()
    end

    -- Receive data back from server.
    net.Receive("DialogueAdminChoicesData", function()
        local steamID = net.ReadString()
        local entries = util.JSONToTable(net.ReadString()) or {}
        if IsValid(frame) then
            RebuildChoiceList(entries)
        end
    end)
end

-- Hook into dialogue box to add "Choices Menu" button for admins.
-- This is called from the dialogue box's Edit button area — we expose
-- it as a standalone function so it can be called from anywhere.
function OpenAdminChoicesMenu()
    OpenChoicesMenu()
end

-- Concommand for admins so it can be opened without needing an NPC.
concommand.Add("dlg_choices", function()
    if not LocalPlayer():IsAdmin() then return end
    OpenChoicesMenu()
end, nil, "Open the dialogue player choices admin panel.")