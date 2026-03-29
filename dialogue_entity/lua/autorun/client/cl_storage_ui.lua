if SERVER then
    return
end

local COL = {
    bg = Color(40, 40, 40, 245),
    bgMid = Color(45, 45, 45, 220),
    panel = Color(60, 60, 60, 200),
    accent = Color(80, 120, 180, 255),
    accentHover = Color(100, 140, 200, 255),
    green = Color(80, 180, 120, 255),
    greenHover = Color(100, 200, 140, 255),
    danger = Color(180, 70, 70, 255),
    dangerHover = Color(200, 90, 90, 255),
    textMain = Color(255, 255, 255, 255),
    textSub = Color(200, 200, 200, 255),
    textMuted = Color(160, 160, 160, 255),
    gold = Color(255, 215, 0, 255),
    dropOk = Color(80, 180, 120, 140),
    dropNo = Color(180, 70, 70, 140)
}

local SLOTS_PER_PAGE = 30
local TOTAL_SLOTS = 300
local storageFrame = nil
local _storageDataCallback = nil -- set by open panel, cleared on close

-- ----------------------------------------------------------------
--  Drag state  — driven by polling, not VGUI events
-- ----------------------------------------------------------------
local drag = {
    active = false,
    source = nil, -- "inventory" | "storage"
    slotIdx = nil, -- integer, storage source slot (nil for inventory)
    item = nil, -- { classname, slotType, slotsTaking, image, name }
    wasDown = false -- left mouse state last frame
}

local function CancelDrag()
    drag.active = false
    drag.source = nil
    drag.slotIdx = nil
    drag.item = nil
    drag.wasDown = false
end

-- Each open slot button registers itself here so the drag poller can
-- hit-test on mouse-release.
-- Format: { panel=DButton, source="inventory"|"storage", slotIdx=int|nil, item=table|nil }
local _slotRegistry = {}

-- Broad drop zones — whole panels that accept a drop even if cursor is between slots.
-- Format: { panel=DPanel, source="inventory"|"storage" }
local _dropZones = {}

local function RegisterSlot(btn, source, slotIdx, itemRef)
    table.insert(_slotRegistry, {panel = btn, source = source, slotIdx = slotIdx, item = itemRef})
end

local function RegisterDropZone(pnl, source)
    table.insert(_dropZones, {panel = pnl, source = source})
end

local function ClearSlotRegistry()
    _slotRegistry = {}
    _dropZones = {}
end

-- Called once per frame while a storage panel is open.
-- Starts drag on press, resolves drop on release.
local _dragDropCallback = nil -- set to a closure by the open panel

hook.Add(
    "Think",
    "StorageDragPoll",
    function()
        local down = input.IsMouseDown(MOUSE_LEFT)

        -- Rising edge: mouse just pressed — check if cursor is over a slot with an item.
        if down and not drag.wasDown then
            if not drag.active then
                local mx, my = gui.MousePos()
                for _, reg in ipairs(_slotRegistry) do
                    if IsValid(reg.panel) and reg.item then
                        local sx, sy = reg.panel:LocalToScreen(0, 0)
                        local sw, sh = reg.panel:GetSize()
                        if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                            drag.active = true
                            drag.source = reg.source
                            drag.slotIdx = reg.slotIdx
                            drag.item = reg.item
                            break
                        end
                    end
                end
            end
        end

        -- Falling edge: mouse just released — resolve drop.
        if not down and drag.wasDown then
            if drag.active and _dragDropCallback then
                local mx, my = gui.MousePos()
                -- First try to find an exact slot under the cursor.
                local dropTarget = nil
                for _, reg in ipairs(_slotRegistry) do
                    if IsValid(reg.panel) then
                        local sx, sy = reg.panel:LocalToScreen(0, 0)
                        local sw, sh = reg.panel:GetSize()
                        if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                            dropTarget = reg
                            break
                        end
                    end
                end
                -- If no slot hit, check broad drop zones.
                if not dropTarget then
                    for _, zone in ipairs(_dropZones) do
                        if IsValid(zone.panel) then
                            local sx, sy = zone.panel:LocalToScreen(0, 0)
                            local sw, sh = zone.panel:GetSize()
                            if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                                dropTarget = {source = zone.source, slotIdx = nil, item = nil}
                                break
                            end
                        end
                    end
                end
                _dragDropCallback(drag, dropTarget)
            end
            CancelDrag()
        end

        drag.wasDown = down
    end
)

-- Ghost icon drawn over everything while dragging.
hook.Add(
    "PostRenderVGUI",
    "StorageDragGhost",
    function()
        if not drag.active or not drag.item then
            return
        end
        local mx, my = gui.MousePos()
        local sz = 52
        local x = mx - sz / 2
        local y = my - sz / 2
        surface.SetDrawColor(0, 0, 0, 140)
        surface.DrawRect(x - 2, y - 2, sz + 4, sz + 4)
        surface.SetMaterial(Material(drag.item.image))
        surface.SetDrawColor(255, 255, 255, 220)
        surface.DrawTexturedRect(x, y, sz, sz)
        draw.SimpleText(drag.item.name, "DermaDefault", mx, y + sz + 3, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end
)

-- ----------------------------------------------------------------
--  Helpers
-- ----------------------------------------------------------------
local function GetItemImage(classname)
    local path = "materials/entities/" .. classname .. ".png"
    if file.Exists(path, "GAME") then
        return path
    end
    return "materials/entities/what.png"
end

local function NormalizeSlotKeys(data)
    if not data or not data.slots then
        return
    end
    local norm = {}
    for k, v in pairs(data.slots) do
        norm[tostring(k)] = v
    end
    data.slots = norm
end

local function BuildInventoryItems(ply)
    local items = {}

    -- SWEPs
    for _, weapon in pairs(ply:GetWeapons()) do
        if weapon.SlotType and weapon.SlotsTaking then
            local wdata = weapons.Get(weapon:GetClass())
            local droppable = true
            if wdata and wdata.PersonaSkill then
                droppable = false
            end
            if droppable then
                local charID = ply:GetNWString("AssignedCharacter", "")
                local charData = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID]
                if charData and charData.weapons then
                    for _, bw in ipairs(charData.weapons) do
                        if bw == weapon:GetClass() then
                            droppable = false
                            break
                        end
                    end
                end
            end
            if droppable then
                table.insert(
                    items,
                    {
                        classname = weapon:GetClass(),
                        slotType = weapon.SlotType,
                        slotsTaking = weapon.SlotsTaking or 1,
                        image = GetItemImage(weapon:GetClass()),
                        name = (wdata and wdata.PrintName) or weapon:GetClass(),
                        itemType = "swep"
                    }
                )
            end
        end
    end

    -- Permabuffs (passives) — tracked via stats, not GetWeapons
    local buffs = GetAllStatsClient and GetAllStatsClient(ply, "permabuffs")
    if buffs then
        local charID = ply:GetNWString("AssignedCharacter", "")
        local charData = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID]
        for buffName, buffInfo in pairs(buffs) do
            if type(buffInfo) == "table" and buffInfo.SlotType and buffInfo.SlotsTaking then
                -- Skip base-character perma-buffs
                local isBase = false
                if charData and charData.permaBuffs then
                    for _, pb in pairs(charData.permaBuffs) do
                        if pb.ClassName == buffInfo.ClassName then
                            isBase = true
                            break
                        end
                    end
                end
                if not isBase then
                    local passive = Passives and Passives[buffName]
                    local cls = buffInfo.ClassName or (passive and passive.classname) or buffName
                    table.insert(
                        items,
                        {
                            classname = cls,
                            buffName = buffName,
                            buffType = "permabuffs",
                            buffData = buffInfo, -- full table for AssignStat on restore
                            slotType = buffInfo.SlotType,
                            slotsTaking = buffInfo.SlotsTaking or 1,
                            image = (passive and passive.image) or GetItemImage(cls),
                            name = (passive and passive.name) or cls,
                            itemType = "passive"
                        }
                    )
                end
            end
        end
    end

    -- Personas — tracked via "personas" stat bucket
    local personas = GetAllStatsClient and GetAllStatsClient(ply, "personas")
    if personas then
        local charID = ply:GetNWString("AssignedCharacter", "")
        local charData = CHARACTERS and CHARACTERS.List and CHARACTERS.List[charID]
        for personaName, _ in pairs(personas) do
            -- Skip permapersonas (locked to character)
            local isPerma = false
            local permapersonas = GetAllStatsClient and GetAllStatsClient(ply, "permapersonas")
            if permapersonas and permapersonas[personaName] then
                isPerma = true
            end
            if not isPerma then
                local pdata = Personas and Personas[personaName]
                table.insert(
                    items,
                    {
                        classname = personaName,
                        buffName = personaName,
                        buffType = "personas",
                        buffData = personaName, -- personas store name string as value
                        slotType = "Persona",
                        slotsTaking = 1,
                        image = (pdata and pdata.image) or GetItemImage(personaName),
                        name = (pdata and pdata.name) or personaName,
                        itemType = "passive" -- same store/take path as passives
                    }
                )
            end
        end
    end

    return items
end

function OpenStorageUI(storageKey, isGlobal, npcUID)
    if IsValid(storageFrame) then
        storageFrame:Remove()
    end
    net.Start("StorageOpen")
    net.WriteString(storageKey)
    net.WriteBool(isGlobal)
    net.WriteString(npcUID or "")
    net.SendToServer()
end

-- ----------------------------------------------------------------
--  Panel builder
-- ----------------------------------------------------------------
local function BuildStoragePanel(storageData, storageKey, isGlobal, npcUID)
    if IsValid(storageFrame) then
        storageFrame:Remove()
    end
    CancelDrag()
    ClearSlotRegistry()

    local ply = LocalPlayer()
    local sym = (TBC_CURRENCY and TBC_CURRENCY.LocalConfig and TBC_CURRENCY.LocalConfig.Symbol) or "ћ"
    local useCharScope = false
    local adminViewSteam = nil
    local currentSlots = {}

    local W, H = 900, 660
    local PAD = 10
    local HEADER_H = 34
    local FOOTER_H = 40
    local BODY_Y = HEADER_H + PAD
    local BODY_H = H - BODY_Y - FOOTER_H - PAD * 2
    local HALF_W = math.floor((W - PAD * 3) / 2)
    local SLOT_SZ = 64
    local PAGE_BAR_H = 26
    local ARROW_W = 28
    local GRID_W = HALF_W - 16
    local SLOT_COLS = math.floor(GRID_W / SLOT_SZ)
    local curPage = 1
    local maxPage = math.ceil(TOTAL_SLOTS / SLOTS_PER_PAGE)

    local RebuildStorageGrid, RebuildInventory  -- forward decls

    -- Helpers to fire net messages.
    local function NetStoreItem(item, targetSlot)
        net.Start("StorageStoreItem")
        net.WriteString(storageKey)
        net.WriteBool(isGlobal)
        net.WriteString(npcUID or "")
        net.WriteBool(useCharScope)
        net.WriteString(item.classname)
        net.WriteString(item.slotType)
        net.WriteInt(item.slotsTaking, 32)
        net.WriteInt(targetSlot or 0, 32)
        net.WriteString(item.itemType or "swep")
        net.WriteString(item.buffName or "")
        net.WriteString(item.buffType or "")
        net.WriteString(
            item.buffData and util.TableToJSON(type(item.buffData) == "table" and item.buffData or {}) or ""
        )
        net.SendToServer()
    end
    local function NetTakeItem(slotIdx)
        net.Start("StorageTakeItem")
        net.WriteString(storageKey)
        net.WriteBool(isGlobal)
        net.WriteString(npcUID or "")
        net.WriteBool(useCharScope)
        net.WriteInt(slotIdx, 32)
        net.WriteString(adminViewSteam or "")
        net.SendToServer()
    end
    local function NetMoveSlot(fromSlot, toSlot)
        net.Start("StorageMoveSlot")
        net.WriteString(storageKey)
        net.WriteBool(isGlobal)
        net.WriteString(npcUID or "")
        net.WriteBool(useCharScope)
        net.WriteInt(fromSlot, 32)
        net.WriteInt(toSlot, 32)
        net.SendToServer()
    end

    -- Drop resolution callback registered into the global poller.
    _dragDropCallback = function(d, target)
        if not target then
            return
        end -- dropped on nothing, ghost disappears

        local fromSource = d.source
        local fromSlot = d.slotIdx
        local dragItem = d.item
        local toSource = target.source
        local toSlot = target.slotIdx

        if fromSource == "inventory" and toSource == "storage" then
            NetStoreItem(dragItem, toSlot)
        elseif fromSource == "storage" and toSource == "inventory" then
            -- Storage → Inventory (take)
            NetTakeItem(fromSlot)
        elseif fromSource == "storage" and toSource == "storage" then
            if fromSlot ~= toSlot then
                -- Storage → different Storage slot (reorder/swap)
                NetMoveSlot(fromSlot, toSlot)
            end
        end
    end

    -- ---- Frame ----
    local frame = vgui.Create("DFrame")
    frame:SetSize(W, H)
    frame:Center()
    frame:SetTitle("")
    frame:SetDraggable(true)
    frame:ShowCloseButton(false)
    frame:MakePopup()
    frame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, HEADER_H, COL.bgMid)
        draw.SimpleText(
            "Storage",
            "DermaDefaultBold",
            PAD,
            HEADER_H / 2,
            COL.textMuted,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )
        surface.SetDrawColor(COL.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    storageFrame = frame

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(60, 22)
    closeBtn:SetPos(W - 68, 6)
    closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
        draw.SimpleText("Close", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        net.Start("StorageClose")
        net.SendToServer()
        frame:Remove()
    end

    -- ---- Inventory panel ----
    local invPanel = vgui.Create("DPanel", frame)
    invPanel:SetPos(PAD, BODY_Y)
    invPanel:SetSize(HALF_W, BODY_H)
    invPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COL.bgMid)
        draw.SimpleText("Inventory", "DermaDefaultBold", 8, 6, COL.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        -- Drop target highlight when dragging from storage
        if drag.active and drag.source == "storage" then
            draw.RoundedBox(6, 2, 2, w - 4, h - 4, COL.dropOk)
        end
    end

    local invScroll = vgui.Create("DScrollPanel", invPanel)
    invScroll:SetPos(4, 24)
    invScroll:SetSize(HALF_W - 8, BODY_H - 28)
    local isb = invScroll:GetVBar()
    isb:SetWide(4)
    isb.Paint = function(s, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(30, 30, 30, 120))
    end
    isb.btnUp.Paint = function()
    end
    isb.btnDown.Paint = function()
    end
    isb.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(2, 0, 0, w, h, COL.accent)
    end

    -- Register invPanel as a broad drop zone so storage items can be dropped
    -- anywhere inside the inventory panel, not just on a specific item slot.
    RegisterDropZone(invPanel, "inventory")

    -- ---- Storage panel ----
    local stPanel = vgui.Create("DPanel", frame)
    stPanel:SetPos(PAD * 2 + HALF_W, BODY_Y)
    stPanel:SetSize(HALF_W, BODY_H)

    local prevBtn = vgui.Create("DButton", stPanel)
    prevBtn:SetPos(4, 4)
    prevBtn:SetSize(ARROW_W, PAGE_BAR_H - 8)
    prevBtn:SetText("")
    prevBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("◄", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local nextBtn = vgui.Create("DButton", stPanel)
    nextBtn:SetPos(HALF_W - 4 - ARROW_W, 4)
    nextBtn:SetSize(ARROW_W, PAGE_BAR_H - 8)
    nextBtn:SetText("")
    nextBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("►", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    stPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COL.bgMid)
        draw.SimpleText(
            "Storage",
            "DermaDefaultBold",
            ARROW_W + 8,
            PAGE_BAR_H / 2,
            COL.accent,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )
        draw.SimpleText(
            "Page " .. curPage .. " / " .. maxPage,
            "DermaDefault",
            w / 2,
            PAGE_BAR_H / 2,
            COL.textMuted,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_CENTER
        )
    end

    local stScroll = vgui.Create("DScrollPanel", stPanel)
    stScroll:SetPos(4, PAGE_BAR_H + 2)
    stScroll:SetSize(HALF_W - 8, BODY_H - PAGE_BAR_H - 6)
    local ssb = stScroll:GetVBar()
    ssb:SetWide(4)
    ssb.Paint = function(s, w, h)
        draw.RoundedBox(2, 0, 0, w, h, Color(30, 30, 30, 120))
    end
    ssb.btnUp.Paint = function()
    end
    ssb.btnDown.Paint = function()
    end
    ssb.btnGrip.Paint = function(s, w, h)
        draw.RoundedBox(2, 0, 0, w, h, COL.accent)
    end

    -- Register stPanel as a broad drop zone so inventory items dropped anywhere
    -- on the storage panel go to the next free slot.
    RegisterDropZone(stPanel, "storage")

    -- ----------------------------------------------------------------
    --  Slot button factory
    --  source:  "inventory" | "storage"
    --  item:    item table or nil (empty storage slot)
    --  slotIdx: integer (storage) or nil (inventory)
    -- ----------------------------------------------------------------
    local function MakeSlot(item, source, slotIdx)
        local btn = vgui.Create("DButton")
        btn:SetSize(SLOT_SZ - 2, SLOT_SZ - 2)
        btn:SetText("")

        -- Register for hit-testing by the drag poller.
        RegisterSlot(btn, source, slotIdx, item)

        btn.Paint = function(s, w, h)
            -- Determine background.
            local bg = Color(30, 30, 30, 180)
            if drag.active then
                if source == "storage" then
                    -- Highlight storage slots as valid drop targets when dragging anything.
                    local isBeingDragged = (drag.source == "storage" and drag.slotIdx == slotIdx)
                    if not isBeingDragged then
                        bg = COL.dropOk
                    else
                        bg = Color(30, 30, 30, 80) -- dim the origin slot
                    end
                end
                -- Inventory slots highlight when dragging FROM storage.
                if source == "inventory" and drag.source == "storage" then
                    bg = COL.dropOk
                end
            elseif s:IsHovered() then
                bg = COL.panel
            end

            draw.RoundedBox(4, 0, 0, w, h, bg)
            surface.SetDrawColor(100, 100, 100, 80)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            if item then
                local alpha = (drag.active and drag.source == source and drag.slotIdx == slotIdx) and 60 or 255
                surface.SetMaterial(Material(item.image))
                surface.SetDrawColor(255, 255, 255, alpha)
                surface.DrawTexturedRect(4, 4, w - 8, h - 8)
                if alpha == 255 then
                    draw.SimpleText(
                        item.name,
                        "DermaDefault",
                        w / 2,
                        h - 3,
                        COL.textMain,
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_BOTTOM
                    )
                end
            elseif slotIdx then
                draw.SimpleText(
                    tostring(slotIdx),
                    "DermaDefault",
                    w / 2,
                    h / 2,
                    Color(55, 55, 55, 200),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            end
        end

        -- Right-click context menu (still works alongside drag).
        btn.DoRightClick = function()
            if drag.active then
                CancelDrag()
                return
            end
            if not item then
                return
            end
            local menu = DermaMenu()
            if source == "inventory" then
                menu:AddOption(
                    "Store",
                    function()
                        NetStoreItem(item, 0)
                    end
                )
            elseif source == "storage" then
                menu:AddOption(
                    "Take",
                    function()
                        NetTakeItem(slotIdx)
                    end
                )
            end
            menu:Open()
        end

        btn:SetTooltip(item and item.name or "")
        return btn
    end

    -- ----------------------------------------------------------------
    RebuildStorageGrid = function(slots)
        stScroll:Clear()
        -- Remove old storage slot registrations; rebuild from scratch.
        local newReg = {}
        for _, r in ipairs(_slotRegistry) do
            if r.source ~= "storage" then
                table.insert(newReg, r)
            end
        end
        _slotRegistry = newReg

        local stGrid = vgui.Create("DGrid", stScroll)
        stGrid:SetCols(SLOT_COLS)
        stGrid:SetColWide(SLOT_SZ)
        stGrid:SetRowHeight(SLOT_SZ)
        stGrid:SetWide(SLOT_COLS * SLOT_SZ)
        stGrid.Paint = function()
        end

        local startIdx = (curPage - 1) * SLOTS_PER_PAGE + 1
        local endIdx = math.min(startIdx + SLOTS_PER_PAGE - 1, TOTAL_SLOTS)
        for i = startIdx, endIdx do
            stGrid:AddItem(MakeSlot(slots[tostring(i)], "storage", i))
        end
    end

    RebuildInventory = function()
        invScroll:Clear()
        -- Remove old inventory slot registrations; rebuild from scratch.
        local newReg = {}
        for _, r in ipairs(_slotRegistry) do
            if r.source ~= "inventory" then
                table.insert(newReg, r)
            end
        end
        _slotRegistry = newReg

        local items = BuildInventoryItems(ply)
        local invGrid = vgui.Create("DGrid", invScroll)
        invGrid:SetCols(SLOT_COLS)
        invGrid:SetColWide(SLOT_SZ)
        invGrid:SetRowHeight(SLOT_SZ)
        invGrid:SetWide(SLOT_COLS * SLOT_SZ)
        invGrid.Paint = function()
        end
        for _, item in ipairs(items) do
            invGrid:AddItem(MakeSlot(item, "inventory", nil))
        end
    end

    prevBtn.DoClick = function()
        if curPage > 1 then
            curPage = curPage - 1
            RebuildStorageGrid(currentSlots)
        end
    end
    nextBtn.DoClick = function()
        if curPage < maxPage then
            curPage = curPage + 1
            RebuildStorageGrid(currentSlots)
        end
    end

    -- ---- Currency strip ----
    local curStrip = vgui.Create("DPanel", frame)
    curStrip:SetPos(PAD, H - FOOTER_H - PAD + 4)
    curStrip:SetSize(W - PAD * 2, FOOTER_H - 4)
    curStrip.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, COL.bgMid)
    end

    local storedLabel = vgui.Create("DLabel", curStrip)
    storedLabel:SetPos(8, 0)
    storedLabel:SetSize(200, FOOTER_H - 4)
    storedLabel:SetTextColor(COL.gold)
    storedLabel:SetContentAlignment(4)

    local amountEntry = vgui.Create("DTextEntry", curStrip)
    amountEntry:SetPos(215, 7)
    amountEntry:SetSize(90, 22)
    amountEntry:SetPlaceholderText("Amount")
    amountEntry:SetTextColor(COL.textMain)
    amountEntry:SetNumeric(true)
    amountEntry.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(30, 30, 30, 220))
        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
    end

    local depositBtn = vgui.Create("DButton", curStrip)
    depositBtn:SetPos(313, 7)
    depositBtn:SetSize(70, 22)
    depositBtn:SetText("")
    depositBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.greenHover or COL.green)
        draw.SimpleText("Deposit", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    depositBtn.DoClick = function()
        local amt = tonumber(amountEntry:GetText())
        if not amt or amt <= 0 then
            return
        end
        net.Start("StorageCurrency")
        net.WriteString(storageKey)
        net.WriteBool(isGlobal)
        net.WriteString(npcUID or "")
        net.WriteBool(useCharScope)
        net.WriteBool(true)
        net.WriteInt(math.floor(amt), 32)
        net.WriteString(adminViewSteam or "")
        net.SendToServer()
        amountEntry:SetText("")
    end

    local withdrawBtn = vgui.Create("DButton", curStrip)
    withdrawBtn:SetPos(391, 7)
    withdrawBtn:SetSize(70, 22)
    withdrawBtn:SetText("")
    withdrawBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
        draw.SimpleText("Withdraw", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    withdrawBtn.DoClick = function()
        local amt = tonumber(amountEntry:GetText())
        if not amt or amt <= 0 then
            return
        end
        net.Start("StorageCurrency")
        net.WriteString(storageKey)
        net.WriteBool(isGlobal)
        net.WriteString(npcUID or "")
        net.WriteBool(useCharScope)
        net.WriteBool(false)
        net.WriteInt(math.floor(amt), 32)
        net.WriteString(adminViewSteam or "")
        net.SendToServer()
        amountEntry:SetText("")
    end

    local onHandLabel = vgui.Create("DLabel", curStrip)
    onHandLabel:SetPos(469, 0)
    onHandLabel:SetSize(240, FOOTER_H - 4)
    onHandLabel:SetTextColor(COL.textSub)
    onHandLabel:SetContentAlignment(4)

    local function RefreshOnHand()
        if not IsValid(onHandLabel) then
            return
        end
        onHandLabel:SetText("On hand: " .. sym .. ((TBC_CURRENCY and TBC_CURRENCY.LocalBalance) or 0))
    end
    RefreshOnHand()

    local function UpdateFromData(data, viewSteam)
        adminViewSteam = viewSteam
        currentSlots = data.slots or {}
        storedLabel:SetText("Stored: " .. sym .. (data.currency or 0))
        RebuildStorageGrid(currentSlots)
        timer.Simple(
            0.1,
            function()
                if IsValid(frame) then
                    RebuildInventory()
                end
            end
        )
        RefreshOnHand()
    end

    UpdateFromData(storageData, nil)

    hook.Add("TBC_CurrencyBalanceUpdated", "StorageUI_OnHand", RefreshOnHand)
    _storageDataCallback = UpdateFromData
    frame.OnRemove = function()
        CancelDrag()
        ClearSlotRegistry()
        _dragDropCallback = nil
        _storageDataCallback = nil
        hook.Remove("TBC_CurrencyBalanceUpdated", "StorageUI_OnHand")
    end
end

-- ----------------------------------------------------------------
--  Net receivers — registered once at module level
-- ----------------------------------------------------------------
net.Receive(
    "StorageData",
    function()
        local raw = net.ReadString()
        local viewSteam = net.ReadString()
        local d = util.JSONToTable(raw) or {slots = {}, currency = 0}
        NormalizeSlotKeys(d)
        if _storageDataCallback then
            _storageDataCallback(d, viewSteam ~= "" and viewSteam or nil)
        end
    end
)

net.Receive(
    "StorageOpenUI",
    function()
        local raw = net.ReadString()
        local storageKey = net.ReadString()
        local isGlobal = net.ReadBool()
        local npcUID = net.ReadString()
        local data = util.JSONToTable(raw) or {slots = {}, currency = 0}
        NormalizeSlotKeys(data)
        BuildStoragePanel(data, storageKey, isGlobal, npcUID)
    end
)
