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
    gold = Color(255, 215, 0, 255),
    textMain = Color(255, 255, 255, 255),
    textSub = Color(200, 200, 200, 255),
    textMuted = Color(160, 160, 160, 255),
    dropOk = Color(80, 180, 120, 140)
}

local adminFrame = nil

-- ----------------------------------------------------------------
--  Drag state (same polling approach as storage UI)
-- ----------------------------------------------------------------
local adrag = {
    active = false,
    item = nil, -- { classname, slotType, slotsTaking, image, name }
    wasDown = false
}

local _aSlotRegistry = {}
local _aDropCallback = nil

local function ACancelDrag()
    adrag.active = false
    adrag.item = nil
    adrag.wasDown = false
end

local function AClearRegistry()
    _aSlotRegistry = {}
end

hook.Add(
    "Think",
    "AdminStorageDragPoll",
    function()
        local down = input.IsMouseDown(MOUSE_LEFT)

        if down and not adrag.wasDown and not adrag.active then
            local mx, my = gui.MousePos()
            for _, reg in ipairs(_aSlotRegistry) do
                if IsValid(reg.panel) and reg.item and reg.draggable then
                    local sx, sy = reg.panel:LocalToScreen(0, 0)
                    local sw, sh = reg.panel:GetSize()
                    if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                        adrag.active = true
                        adrag.item = reg.item
                        adrag.source = reg.source
                        break
                    end
                end
            end
        end

        if not down and adrag.wasDown then
            if adrag.active and _aDropCallback then
                local mx, my = gui.MousePos()
                local target = nil
                for _, reg in ipairs(_aSlotRegistry) do
                    if IsValid(reg.panel) then
                        local sx, sy = reg.panel:LocalToScreen(0, 0)
                        local sw, sh = reg.panel:GetSize()
                        if mx >= sx and mx <= sx + sw and my >= sy and my <= sy + sh then
                            target = reg
                            break
                        end
                    end
                end
                -- Also check broad drop zones
                if not target and IsValid(adminFrame) then
                    local zoneInv = adminFrame._dropZoneInv
                    local zoneSt = adminFrame._dropZoneSt
                    if IsValid(zoneInv) then
                        local sx, sy = zoneInv:LocalToScreen(0, 0)
                        local sw, sh = zoneInv:GetSize()
                        local mx2, my2 = gui.MousePos()
                        if mx2 >= sx and mx2 <= sx + sw and my2 >= sy and my2 <= sy + sh then
                            target = {source = "inventory", item = nil}
                        end
                    end
                    if not target and IsValid(zoneSt) then
                        local sx, sy = zoneSt:LocalToScreen(0, 0)
                        local sw, sh = zoneSt:GetSize()
                        local mx2, my2 = gui.MousePos()
                        if mx2 >= sx and mx2 <= sx + sw and my2 >= sy and my2 <= sy + sh then
                            target = {source = "adminstorage", item = nil}
                        end
                    end
                end
                _aDropCallback(adrag, target)
            end
            ACancelDrag()
        end

        adrag.wasDown = down
    end
)

hook.Add(
    "PostRenderVGUI",
    "AdminStorageDragGhost",
    function()
        if not adrag.active or not adrag.item then
            return
        end
        local mx, my = gui.MousePos()
        local sz = 52
        local x = mx - sz / 2
        local y = my - sz / 2
        surface.SetDrawColor(0, 0, 0, 140)
        surface.DrawRect(x - 2, y - 2, sz + 4, sz + 4)
        surface.SetMaterial(Material(adrag.item.image))
        surface.SetDrawColor(255, 255, 255, 220)
        surface.DrawTexturedRect(x, y, sz, sz)
        draw.SimpleText(
            adrag.item.name,
            "DermaDefault",
            mx,
            y + sz + 3,
            COL.textMain,
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP
        )
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

local function BuildInventoryItems(ply)
    local items = {}

    -- SWEPs
    for _, weapon in pairs(ply:GetWeapons()) do
        if weapon.SlotType and weapon.SlotsTaking then
            local wdata = weapons.Get(weapon:GetClass())
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

    -- Permabuffs
    local buffs = GetAllStatsClient and GetAllStatsClient(ply, "permabuffs")
    if buffs then
        for buffName, buffInfo in pairs(buffs) do
            if type(buffInfo) == "table" and buffInfo.SlotType and buffInfo.SlotsTaking then
                local cls = buffInfo.ClassName or buffName
                local passive = Passives and Passives[buffName]
                table.insert(
                    items,
                    {
                        classname = cls,
                        buffName = buffName,
                        buffType = "permabuffs",
                        buffData = buffInfo,
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

    -- Personas
    local personas = GetAllStatsClient and GetAllStatsClient(ply, "personas")
    if personas then
        local permapersonas = GetAllStatsClient and GetAllStatsClient(ply, "permapersonas")
        for personaName, _ in pairs(personas) do
            if not (permapersonas and permapersonas[personaName]) then
                local pdata = Personas and Personas[personaName]
                table.insert(
                    items,
                    {
                        classname = personaName,
                        buffName = personaName,
                        buffType = "personas",
                        buffData = personaName,
                        slotType = "Persona",
                        slotsTaking = 1,
                        image = (pdata and pdata.image) or GetItemImage(personaName),
                        name = (pdata and pdata.name) or personaName,
                        itemType = "passive"
                    }
                )
            end
        end
    end

    return items
end

local function NormalizeKeys(data)
    if not data or not data.slots then
        return
    end
    local norm = {}
    for k, v in pairs(data.slots) do
        norm[tostring(k)] = v
    end
    data.slots = norm
end

-- ----------------------------------------------------------------
--  Panel builder
-- ----------------------------------------------------------------
local function BuildAdminStoragePanel(targetSteam, targetNick, storageData)
    if IsValid(adminFrame) then
        adminFrame:Remove()
    end
    ACancelDrag()
    AClearRegistry()

    local ply = LocalPlayer()
    local sym = (TBC_CURRENCY and TBC_CURRENCY.LocalConfig and TBC_CURRENCY.LocalConfig.Symbol) or "ћ"
    local currentSlots = storageData.slots or {}
    local currentCurrency = storageData.currency or 0

    local W, H = 900, 660
    local PAD = 10
    local HEADER_H = 34
    local FOOTER_H = 40
    local BODY_Y = HEADER_H + PAD
    local BODY_H = H - BODY_Y - FOOTER_H - PAD * 2
    local HALF_W = math.floor((W - PAD * 3) / 2)
    local SLOT_SZ = 64
    local SLOT_COLS = math.floor((HALF_W - 16) / SLOT_SZ)
    local PAGE_BAR_H = 26
    local ARROW_W = 28
    local SLOTS_PER_PAGE = 30
    local TOTAL_SLOTS = 300
    local curPage = 1
    local maxPage = math.ceil(TOTAL_SLOTS / SLOTS_PER_PAGE)

    local RebuildStorageGrid, RebuildInventory

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
            "Admin Storage — " .. targetNick,
            "DermaDefaultBold",
            PAD,
            HEADER_H / 2,
            COL.accent,
            TEXT_ALIGN_LEFT,
            TEXT_ALIGN_CENTER
        )
        surface.SetDrawColor(COL.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    adminFrame = frame
    frame._dropZoneInv = nil
    frame._dropZoneSt = nil

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetSize(60, 22)
    closeBtn:SetPos(W - 68, 6)
    closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
        draw.SimpleText("Close", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function()
        frame:Remove()
    end

    -- ---- Inventory panel (admin's own inventory, left) ----
    local invPanel = vgui.Create("DPanel", frame)
    invPanel:SetPos(PAD, BODY_Y)
    invPanel:SetSize(HALF_W, BODY_H)
    invPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COL.bgMid)
        draw.SimpleText("Your Inventory", "DermaDefaultBold", 8, 6, COL.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
        if adrag.active and adrag.source == "adminstorage" then
            draw.RoundedBox(6, 2, 2, w - 4, h - 4, COL.dropOk)
        end
    end
    frame._dropZoneInv = invPanel

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

    -- ---- Target storage panel (right) ----
    local stPanel = vgui.Create("DPanel", frame)
    stPanel:SetPos(PAD * 2 + HALF_W, BODY_Y)
    stPanel:SetSize(HALF_W, BODY_H)
    frame._dropZoneSt = stPanel

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
            targetNick .. "'s Storage",
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
        if adrag.active and adrag.source == "inventory" then
            draw.RoundedBox(6, 2, PAGE_BAR_H, w - 4, h - PAGE_BAR_H - 2, COL.dropOk)
        end
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

    -- ----------------------------------------------------------------
    --  Slot factory
    --  source: "inventory" | "adminstorage"
    --  item:   item table or nil
    --  slotIdx: integer (storage) or nil (inventory)
    -- ----------------------------------------------------------------
    local function MakeSlot(item, source, slotIdx)
        local btn = vgui.Create("DButton")
        btn:SetSize(SLOT_SZ - 2, SLOT_SZ - 2)
        btn:SetText("")

        local draggable = (source == "inventory") or (source == "adminstorage" and item ~= nil)
        table.insert(
            _aSlotRegistry,
            {panel = btn, source = source, slotIdx = slotIdx, item = item, draggable = draggable}
        )

        btn.Paint = function(s, w, h)
            local bg = Color(30, 30, 30, 180)
            if adrag.active then
                if source == "adminstorage" and not (adrag.source == "adminstorage" and adrag.item == item) then
                    bg = COL.dropOk
                elseif source == "inventory" and adrag.source == "adminstorage" then
                    bg = COL.dropOk
                end
            elseif s:IsHovered() then
                bg = COL.panel
            end
            if adrag.active and adrag.item == item and item ~= nil then
                bg = Color(30, 30, 30, 60)
            end

            draw.RoundedBox(4, 0, 0, w, h, bg)
            surface.SetDrawColor(100, 100, 100, 80)
            surface.DrawOutlinedRect(0, 0, w, h, 1)

            if item then
                local alpha = (adrag.active and adrag.item == item) and 60 or 255
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

        btn.DoRightClick = function()
            if adrag.active then
                ACancelDrag()
                return
            end
            if not item then
                return
            end
            local menu = DermaMenu()
            if source == "adminstorage" then
                menu:AddOption(
                    "Retrieve (to your inventory)",
                    function()
                        net.Start("AdminStorageAction")
                        net.WriteString(targetSteam)
                        net.WriteString("retrieve")
                        net.WriteInt(slotIdx, 32)
                        net.SendToServer()
                    end
                )
                menu:AddOption(
                    "Drop (in world)",
                    function()
                        net.Start("AdminStorageAction")
                        net.WriteString(targetSteam)
                        net.WriteString("drop")
                        net.WriteInt(slotIdx, 32)
                        net.SendToServer()
                    end
                )
                menu:AddOption(
                    "Delete",
                    function()
                        net.Start("AdminStorageAction")
                        net.WriteString(targetSteam)
                        net.WriteString("delete")
                        net.WriteInt(slotIdx, 32)
                        net.SendToServer()
                    end
                )
            elseif source == "inventory" then
                menu:AddOption(
                    "Store into " .. targetNick .. "'s storage",
                    function()
                        net.Start("AdminStorageDeposit")
                        net.WriteString(targetSteam)
                        net.WriteString(item.classname)
                        net.WriteString(item.slotType)
                        net.WriteInt(item.slotsTaking, 32)
                        net.WriteInt(0, 32)
                        net.WriteString(item.itemType or "swep")
                        net.WriteString(item.buffName or "")
                        net.WriteString(item.buffType or "")
                        net.SendToServer()
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
        local newReg = {}
        for _, r in ipairs(_aSlotRegistry) do
            if r.source ~= "adminstorage" then
                table.insert(newReg, r)
            end
        end
        _aSlotRegistry = newReg

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
            stGrid:AddItem(MakeSlot(slots[tostring(i)], "adminstorage", i))
        end
    end

    RebuildInventory = function()
        invScroll:Clear()
        local newReg = {}
        for _, r in ipairs(_aSlotRegistry) do
            if r.source ~= "inventory" then
                table.insert(newReg, r)
            end
        end
        _aSlotRegistry = newReg

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

    -- Drop resolution
    _aDropCallback = function(d, target)
        if not target then
            return
        end
        local fromSource = d.source
        local dragItem = d.item

        if fromSource == "inventory" and target.source == "adminstorage" then
            local targetSlot = target.slotIdx or 0
            net.Start("AdminStorageDeposit")
            net.WriteString(targetSteam)
            net.WriteString(dragItem.classname)
            net.WriteString(dragItem.slotType)
            net.WriteInt(dragItem.slotsTaking, 32)
            net.WriteInt(targetSlot, 32)
            net.WriteString(dragItem.itemType or "swep")
            net.WriteString(dragItem.buffName or "")
            net.WriteString(dragItem.buffType or "")
            net.SendToServer()
        elseif fromSource == "adminstorage" and target.source == "inventory" then
            -- Target's storage → admin's inventory (retrieve)
            net.Start("AdminStorageAction")
            net.WriteString(targetSteam)
            net.WriteString("retrieve")
            net.WriteInt(d.slotIdx or 0, 32)
            net.SendToServer()
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
    storedLabel:SetText("Stored: " .. sym .. currentCurrency)

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

    -- Deposit = take from admin's wallet, put in target's storage.
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
        net.Start("AdminStorageCurrency")
        net.WriteString(targetSteam)
        net.WriteBool(true)
        net.WriteInt(math.floor(amt), 32)
        net.SendToServer()
        amountEntry:SetText("")
    end

    -- Withdraw = take from target's storage, give to admin.
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
        net.Start("AdminStorageCurrency")
        net.WriteString(targetSteam)
        net.WriteBool(false)
        net.WriteInt(math.floor(amt), 32)
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
        onHandLabel:SetText("Your wallet: " .. sym .. ((TBC_CURRENCY and TBC_CURRENCY.LocalBalance) or 0))
    end
    RefreshOnHand()
    hook.Add("TBC_CurrencyBalanceUpdated", "AdminStorageOnHand", RefreshOnHand)

    local function UpdateFromData(data)
        NormalizeKeys(data)
        currentSlots = data.slots or {}
        currentCurrency = data.currency or 0
        storedLabel:SetText("Stored: " .. sym .. currentCurrency)
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

    UpdateFromData(storageData)

    frame.OnRemove = function()
        ACancelDrag()
        AClearRegistry()
        _aDropCallback = nil
        hook.Remove("TBC_CurrencyBalanceUpdated", "AdminStorageOnHand")
    end

    -- Listen for updates from server
    net.Receive(
        "AdminStorageData",
        function()
            local raw = net.ReadString()
            local d = util.JSONToTable(raw) or {slots = {}, currency = 0}
            if IsValid(frame) then
                UpdateFromData(d)
            end
        end
    )
end

-- ----------------------------------------------------------------
--  Net receivers
-- ----------------------------------------------------------------
net.Receive(
    "AdminStorageOpen",
    function()
        local targetSteam = net.ReadString()
        local targetNick = net.ReadString()
        local raw = net.ReadString()
        local data = util.JSONToTable(raw) or {slots = {}, currency = 0}
        local norm = {}
        if data.slots then
            for k, v in pairs(data.slots) do
                norm[tostring(k)] = v
            end
            data.slots = norm
        end
        BuildAdminStoragePanel(targetSteam, targetNick, data)
    end
)

-- ----------------------------------------------------------------
--  Player combo opener
-- ----------------------------------------------------------------
local function OpenAdminStorageSelector()
    if not LocalPlayer():IsAdmin() then
        return
    end

    local sel = vgui.Create("DFrame")
    sel:SetSize(380, 100)
    sel:Center()
    sel:SetTitle("Admin Storage")
    sel:MakePopup()
    sel.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, 24, COL.bgMid)
        surface.SetDrawColor(COL.accent)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local combo = vgui.Create("DComboBox", sel)
    combo:SetPos(10, 32)
    combo:SetSize(260, 24)
    combo:SetTextColor(COL.textMain)
    combo.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, Color(30, 30, 30, 220))
        s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
    end

    local playerMap = {}
    for _, p in ipairs(player.GetAll()) do
        local disp = p:Nick() .. " (" .. p:SteamID() .. ")"
        combo:AddChoice(disp)
        playerMap[disp] = p:SteamID()
    end

    local openBtn = vgui.Create("DButton", sel)
    openBtn:SetPos(278, 32)
    openBtn:SetSize(90, 24)
    openBtn:SetText("")
    openBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("Open", "DermaDefault", w / 2, h / 2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    openBtn.DoClick = function()
        local disp = combo:GetValue()
        local sid = playerMap[disp]
        if not sid then
            return
        end
        net.Start("AdminStorageLoad")
        net.WriteString(sid)
        net.SendToServer()
        sel:Remove()
    end
end

concommand.Add(
    "adminstorage",
    function()
        if not LocalPlayer():IsAdmin() then
            return
        end
        OpenAdminStorageSelector()
    end
)
