if SERVER then return end

local COL = {
    bg          = Color(40,  40,  40,  245),
    bgMid       = Color(45,  45,  45,  220),
    bgDark      = Color(28,  28,  28,  240),
    panel       = Color(60,  60,  60,  200),
    accent      = Color(80,  120, 180, 255),
    accentHover = Color(100, 140, 200, 255),
    green       = Color(80,  180, 120, 255),
    greenHover  = Color(100, 200, 140, 255),
    danger      = Color(180, 70,  70,  255),
    dangerHover = Color(200, 90,  90,  255),
    gold        = Color(255, 215, 0,   255),
    textMain    = Color(255, 255, 255, 255),
    textSub     = Color(200, 200, 200, 255),
    textMuted   = Color(160, 160, 160, 255),
    disabled    = Color(100, 100, 100, 200),
    disabledBg  = Color(40,  40,  40,  160),
}

local SLOTS_PER_PAGE = 50
local TOTAL_SLOTS    = 150
local shopFrame      = nil

-- ----------------------------------------------------------------
--  Helpers shared by shop and editor
-- ----------------------------------------------------------------
local function GetItemImage(classname)
    local path = "materials/entities/" .. classname .. ".png"
    if file.Exists(path, "GAME") then return path end
    -- Also check Passives/Personas for their image field
    if Passives then
        for _, p in pairs(Passives) do
            if p.classname == classname and p.image then return p.image end
        end
    end
    if Personas and Personas[classname] and Personas[classname].image then
        return Personas[classname].image
    end
    return "materials/entities/what.png"
end

local function GetItemName(classname)
    local wdata = weapons.Get(classname)
    if wdata then return wdata.PrintName or classname end
    -- Check Passives by classname
    if Passives then
        for _, p in pairs(Passives) do
            if p.classname == classname then return p.name or classname end
        end
    end
    -- Check Personas by key
    if Personas and Personas[classname] then return Personas[classname].name or classname end
    return classname
end

local function GetItemDesc(classname)
    local wdata = weapons.Get(classname)
    if wdata then return wdata.Purpose or wdata.Description or wdata.Desc or "" end
    if Passives then
        for _, p in pairs(Passives) do
            if p.classname == classname then return p.description or "" end
        end
    end
    if Personas and Personas[classname] then return Personas[classname].description or "" end
    return ""
end

-- Returns slotType, slotsTaking, itemKind ("swep"|"passive"|"persona")
local function GetSlotInfo(classname)
    local wdata = weapons.Get(classname)
    if wdata and wdata.SlotType then return wdata.SlotType, wdata.SlotsTaking or 1, "swep" end
    if Passives then
        for buffName, p in pairs(Passives) do
            if p.classname == classname then
                -- Look up live slot info from scripted ent if possible
                local entData = scripted_ents and scripted_ents.GetStored(classname)
                local st = entData and entData.t and entData.t.SlotType or "Equipment"
                local ss = entData and entData.t and entData.t.SlotsTaking or 1
                return st, ss, "passive", buffName
            end
        end
    end
    if Personas and Personas[classname] then return "Persona", 1, "persona" end
    return nil, nil, nil
end

local function Sym()
    return (TBC_CURRENCY and TBC_CURRENCY.LocalConfig and TBC_CURRENCY.LocalConfig.Symbol) or "ћ"
end

local function FormatMoney(n)
    return Sym() .. tostring(math.floor(n or 0))
end

-- Returns canShow (bool) — false means hide entirely (visibility conditions).
-- Returns canGive (bool) — false means greyed but still visible (can't put in inventory).
-- Returns reason (string) — shown in detail panel.
local function CheckEligibility(shopItem)
    local ply = LocalPlayer()
    local bal = (TBC_CURRENCY and TBC_CURRENCY.LocalBalance) or 0
    local classname = shopItem.classname
    local _, _, itemKind = GetSlotInfo(classname)

    -- Money check
    if (shopItem.price or 0) > bal then
        return true, false, "Not enough " .. (TBC_CURRENCY and TBC_CURRENCY.LocalConfig.Name or "currency") .. "."
    end

    -- Item cost check (client-side preview)
    for _, cost in ipairs(shopItem.itemCost or {}) do
        if cost.classname and cost.classname ~= "" then
            if not ply:HasWeapon(cost.classname) then
                return true, false, "Missing required item: " .. GetItemName(cost.classname)
            end
        end
    end

    -- Already-have check varies by type
    if itemKind == "passive" then
        local buffs = GetAllStatsClient and GetAllStatsClient(ply, "permabuffs")
        -- Find the buffName for this classname
        local buffName = nil
        if Passives then
            for bn, p in pairs(Passives) do
                if p.classname == classname then buffName = bn break end
            end
        end
        if buffName and buffs and buffs[buffName] then
            return true, false, "Already have this passive (can still store)."
        end
    elseif itemKind == "persona" then
        local personas = GetAllStatsClient and GetAllStatsClient(ply, "personas")
        if personas and personas[classname] then
            return true, false, "Already have this persona (can still store)."
        end
    else
        if ply:HasWeapon(classname) then
            return true, false, "Already in inventory (can still store or drop)."
        end
        -- Slot space check for SWEPs
        local slotType, slotsTaking = GetSlotInfo(classname)
        if slotType and slotsTaking then
            local maxEq = ply:GetNWInt("TBCEquipmentSlots", 15)
            local maxIt = ply:GetNWInt("TBCItemSlots", 10)
            local eq, it = 0, 0
            for _, w in pairs(ply:GetWeapons()) do
                if w.SlotType == "Equipment" and w.SlotsTaking then eq = eq + w.SlotsTaking end
                if w.SlotType == "Item"      and w.SlotsTaking then it = it + w.SlotsTaking end
            end
            if slotType == "Equipment" and eq + slotsTaking > maxEq then
                return true, false, "Not enough Equipment slots (can still store or drop)."
            end
            if slotType == "Item" and it + slotsTaking > maxIt then
                return true, false, "Not enough Item slots (can still store or drop)."
            end
        end
    end

    return true, true, nil
end

-- ----------------------------------------------------------------
--  Detail panel (right side)
-- ----------------------------------------------------------------
local function BuildDetailPanel(parent, x, y, w, h)
    local dp = vgui.Create("DPanel", parent)
    dp:SetPos(x, y); dp:SetSize(w, h)
    dp.Paint = function(s, sw, sh)
        draw.RoundedBox(6, 0, 0, sw, sh, COL.bgMid)
    end
    dp._item = nil

    local ISIZE  = 80
    local PAD    = 10

    local iconPnl = vgui.Create("DPanel", dp)
    iconPnl:SetPos(PAD, PAD); iconPnl:SetSize(ISIZE, ISIZE)
    iconPnl.Paint = function(s, sw, sh)
        draw.RoundedBox(4, 0, 0, sw, sh, COL.bgDark)
        if dp._item then
            surface.SetMaterial(Material(GetItemImage(dp._item.classname)))
            surface.SetDrawColor(255,255,255,255)
            surface.DrawTexturedRect(4, 4, sw-8, sh-8)
        end
    end

    local nameLabel = vgui.Create("DLabel", dp)
    nameLabel:SetPos(PAD + ISIZE + 8, PAD)
    nameLabel:SetSize(w - PAD*2 - ISIZE - 8, 22)
    nameLabel:SetFont("DermaDefaultBold")
    nameLabel:SetTextColor(COL.textMain)

    local priceLabel = vgui.Create("DLabel", dp)
    priceLabel:SetPos(PAD + ISIZE + 8, PAD + 24)
    priceLabel:SetSize(w - PAD*2 - ISIZE - 8, 20)
    priceLabel:SetTextColor(COL.gold)

    local slotLabel = vgui.Create("DLabel", dp)
    slotLabel:SetPos(PAD + ISIZE + 8, PAD + 46)
    slotLabel:SetSize(w - PAD*2 - ISIZE - 8, 20)
    slotLabel:SetTextColor(COL.textMuted)

    local descScroll = vgui.Create("DScrollPanel", dp)
    descScroll:SetPos(PAD, PAD + ISIZE + 8)
    descScroll:SetSize(w - PAD*2, h - PAD*3 - ISIZE - 8 - 80)
    local dsb = descScroll:GetVBar(); dsb:SetWide(4)
    dsb.Paint         = function(s,sw,sh) draw.RoundedBox(2,0,0,sw,sh,Color(30,30,30,120)) end
    dsb.btnUp.Paint   = function() end; dsb.btnDown.Paint = function() end
    dsb.btnGrip.Paint = function(s,sw,sh) draw.RoundedBox(2,0,0,sw,sh,COL.accent) end

    local descLabel = vgui.Create("DLabel", descScroll)
    descLabel:SetSize(w - PAD*2 - 8, 0)
    descLabel:SetPos(4, 4)
    descLabel:SetTextColor(COL.textSub)
    descLabel:SetWrap(true)
    descLabel:SetAutoStretchVertical(true)

    local costLabel = vgui.Create("DLabel", dp)
    costLabel:SetPos(PAD, h - 76)
    costLabel:SetSize(w - PAD*2, 20)
    costLabel:SetTextColor(COL.textMuted)

    local reasonLabel = vgui.Create("DLabel", dp)
    reasonLabel:SetPos(PAD, h - 56)
    reasonLabel:SetSize(w - PAD*2, 20)
    reasonLabel:SetTextColor(COL.danger)

    local buyBtn = vgui.Create("DButton", dp)
    buyBtn:SetPos(PAD, h - 34); buyBtn:SetSize(w - PAD*2, 28); buyBtn:SetText("")
    buyBtn._enabled = false
    buyBtn.Paint = function(s, sw, sh)
        local bg = s._enabled and (s:IsHovered() and COL.greenHover or COL.green) or COL.disabled
        draw.RoundedBox(4, 0, 0, sw, sh, bg)
        draw.SimpleText("Purchase", "DermaDefaultBold", sw/2, sh/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    dp.SetItem = function(self, item, onBuy)
        self._item = item
        if not item then
            nameLabel:SetText("")
            priceLabel:SetText("")
            slotLabel:SetText("")
            descLabel:SetText("")
            costLabel:SetText("")
            reasonLabel:SetText("")
            buyBtn._enabled = false
            buyBtn.DoClick  = function() end
            return
        end

        nameLabel:SetText(GetItemName(item.classname))
        priceLabel:SetText("Price: " .. FormatMoney(item.price))

        local st, ss = GetSlotInfo(item.classname)
        slotLabel:SetText(st and (st .. " — " .. (ss or 1) .. " slot(s)") or "")

        descLabel:SetText(GetItemDesc(item.classname))

        local costs = {}
        for _, c in ipairs(item.itemCost or {}) do
            if c.classname and c.classname ~= "" then
                table.insert(costs, GetItemName(c.classname))
            end
        end
        costLabel:SetText(#costs > 0 and ("Also requires: " .. table.concat(costs, ", ")) or "")

        local _, canGive, reason = CheckEligibility(item)
        reasonLabel:SetText(reason or "")
        -- Button is always enabled — clicking it opens the confirm which handles mode restrictions.
        buyBtn._enabled = true
        buyBtn.DoClick  = function()
            if onBuy then onBuy(item, canGive) end
        end
    end

    return dp
end

-- ----------------------------------------------------------------
--  Purchase confirmation popup
-- ----------------------------------------------------------------
local function OpenPurchaseConfirm(item, npcUID, canGive, onDone)
    local ply = LocalPlayer()
    local bal = (TBC_CURRENCY and TBC_CURRENCY.LocalBalance) or 0
    local after = bal - (item.price or 0)

    local W, H = 380, 230
    local popup = vgui.Create("DFrame")
    popup:SetSize(W, H); popup:Center(); popup:SetTitle("")
    popup:SetDraggable(false); popup:ShowCloseButton(false); popup:MakePopup()
    popup.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, 30, COL.bgMid)
        draw.SimpleText("Confirm Purchase", "DermaDefaultBold", 10, 15, COL.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COL.accent); surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local PAD = 12

    local function Lbl(text, y, col)
        local l = vgui.Create("DLabel", popup)
        l:SetPos(PAD, y); l:SetSize(W - PAD*2, 20)
        l:SetText(text); l:SetTextColor(col or COL.textSub)
        return l
    end

    Lbl(GetItemName(item.classname), 36, COL.textMain)
    Lbl("Cost: " .. FormatMoney(item.price), 56, COL.gold)
    Lbl("Balance after: " .. FormatMoney(after), 76, after >= 0 and COL.textSub or COL.danger)

    local costs = {}
    for _, c in ipairs(item.itemCost or {}) do
        if c.classname and c.classname ~= "" then table.insert(costs, GetItemName(c.classname)) end
    end
    if #costs > 0 then
        Lbl("Items given up: " .. table.concat(costs, ", "), 96, COL.textMuted)
    end

    local BTN_W = math.floor((W - PAD*5) / 4)
    local BTN_Y = H - 48

    local function Btn(lbl, x, col, hov, enabled, fn)
        local b = vgui.Create("DButton", popup)
        b:SetPos(x, BTN_Y); b:SetSize(BTN_W, 32); b:SetText("")
        b.Paint = function(s, w, h)
            local bg = enabled and (s:IsHovered() and hov or col) or COL.disabled
            draw.RoundedBox(4, 0, 0, w, h, bg)
            draw.SimpleText(lbl, "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        b.DoClick = function() if enabled then fn() end end
        return b
    end

    local x = PAD
    Btn("Purchase",        x, COL.green,              COL.greenHover,              canGive, function()
        net.Start("ShopBuy"); net.WriteString(npcUID)
        net.WriteInt(item._index, 32); net.WriteString("give"); net.SendToServer()
        popup:Remove(); if onDone then onDone() end
    end)
    x = x + BTN_W + PAD
    Btn("→ Storage",       x, COL.accent,             COL.accentHover,             true,    function()
        net.Start("ShopBuy"); net.WriteString(npcUID)
        net.WriteInt(item._index, 32); net.WriteString("storage"); net.SendToServer()
        popup:Remove(); if onDone then onDone() end
    end)
    x = x + BTN_W + PAD
    Btn("Drop",            x, Color(160,120,40,255),   Color(180,140,60,255),       true,    function()
        net.Start("ShopBuy"); net.WriteString(npcUID)
        net.WriteInt(item._index, 32); net.WriteString("drop"); net.SendToServer()
        popup:Remove(); if onDone then onDone() end
    end)
    x = x + BTN_W + PAD
    Btn("Cancel",          x, COL.danger,              COL.dangerHover,             true,    function()
        popup:Remove()
    end)
end

-- ----------------------------------------------------------------
--  Main shop panel
-- ----------------------------------------------------------------
local function BuildShopPanel(npcUID, shopData, playerChoices, isAdmin)
    if IsValid(shopFrame) then shopFrame:Remove() end

    local W, H      = 900, 660
    local PAD       = 10
    local HEADER_H  = 34
    local BODY_Y    = HEADER_H + PAD
    local DETAIL_W  = 260
    local GRID_W    = W - PAD*3 - DETAIL_W
    local BODY_H    = H - BODY_Y - PAD
    local SLOT_SZ   = 64
    local SLOT_COLS = math.floor((GRID_W - 8) / SLOT_SZ)
    local PAGE_BAR_H = 26
    local ARROW_W   = 28
    local curPage   = 1
    local maxPage   = math.ceil(TOTAL_SLOTS / SLOTS_PER_PAGE)

    -- Evaluate conditions client-side using playerChoices.
    local function MeetsConds(conds)
        if not conds or #conds == 0 then return true end
        for _, row in ipairs(conds) do
            local ids    = row.ids    or {}
            local mode   = row.mode   or "any"
            local negate = row.negate or false
            if #ids == 0 then continue end
            local passes
            if mode == "all" then
                passes = true
                for _, id in ipairs(ids) do
                    if not playerChoices[id] then passes = false break end
                end
            else
                passes = false
                for _, id in ipairs(ids) do
                    if playerChoices[id] then passes = true break end
                end
            end
            if negate then passes = not passes end
            if not passes then return false end
        end
        return true
    end

    local frame = vgui.Create("DFrame")
    frame:SetSize(W, H); frame:Center(); frame:SetTitle("")
    frame:SetDraggable(true); frame:ShowCloseButton(false); frame:MakePopup()
    frame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, HEADER_H, COL.bgMid)
        draw.SimpleText("Shop", "DermaDefaultBold", PAD, HEADER_H/2, COL.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COL.accent); surface.DrawOutlinedRect(0, 0, w, h, 1)
    end
    shopFrame = frame

    local closeBtn = vgui.Create("DButton", frame)
    closeBtn:SetPos(W - 68, 6); closeBtn:SetSize(60, 22); closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
        draw.SimpleText("Close", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() frame:Remove() end

    if isAdmin then
        local editBtn = vgui.Create("DButton", frame)
        editBtn:SetPos(W - 138, 6); editBtn:SetSize(62, 22); editBtn:SetText("")
        editBtn.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
            draw.SimpleText("Edit Shop", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        editBtn.DoClick = function()
            frame:Remove()
            OpenShopEditor(npcUID, shopData)
        end
    end

    -- ---- Grid panel ----
    local gridPanel = vgui.Create("DPanel", frame)
    gridPanel:SetPos(PAD, BODY_Y); gridPanel:SetSize(GRID_W, BODY_H)
    gridPanel.Paint = function(s, w, h) draw.RoundedBox(6, 0, 0, w, h, COL.bgMid) end

    local prevBtn = vgui.Create("DButton", gridPanel)
    prevBtn:SetPos(4, 4); prevBtn:SetSize(ARROW_W, PAGE_BAR_H - 8); prevBtn:SetText("")
    prevBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("◄", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local nextBtn = vgui.Create("DButton", gridPanel)
    nextBtn:SetPos(GRID_W - 4 - ARROW_W, 4); nextBtn:SetSize(ARROW_W, PAGE_BAR_H - 8); nextBtn:SetText("")
    nextBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("►", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    gridPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COL.bgMid)
        draw.SimpleText("Page " .. curPage .. " / " .. maxPage, "DermaDefault", w/2, PAGE_BAR_H/2, COL.textMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local gridScroll = vgui.Create("DScrollPanel", gridPanel)
    gridScroll:SetPos(4, PAGE_BAR_H + 2)
    gridScroll:SetSize(GRID_W - 8, BODY_H - PAGE_BAR_H - 6)
    local gsb = gridScroll:GetVBar(); gsb:SetWide(4)
    gsb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
    gsb.btnUp.Paint   = function() end; gsb.btnDown.Paint = function() end
    gsb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

    -- ---- Detail panel ----
    local detailPanel = BuildDetailPanel(frame, PAD*2 + GRID_W, BODY_Y, DETAIL_W, BODY_H)

    local function RebuildGrid()
        gridScroll:Clear()
        local grid = vgui.Create("DGrid", gridScroll)
        grid:SetCols(SLOT_COLS); grid:SetColWide(SLOT_SZ); grid:SetRowHeight(SLOT_SZ)
        grid:SetWide(SLOT_COLS * SLOT_SZ); grid.Paint = function() end

        local startIdx = (curPage - 1) * SLOTS_PER_PAGE + 1
        local endIdx   = math.min(startIdx + SLOTS_PER_PAGE - 1, #shopData)

        for i = startIdx, endIdx do
            local item = shopData[i]
            item._index = i

            -- Visibility condition — if fails, skip entirely.
            if not MeetsConds(item.conditions) then continue end

            local _, canGive, _ = CheckEligibility(item)

            local btn = vgui.Create("DButton")
            btn:SetSize(SLOT_SZ - 2, SLOT_SZ - 2); btn:SetText("")
            btn.Paint = function(s, w, h)
                local bg = s:IsHovered() and COL.panel or Color(30,30,30,180)
                draw.RoundedBox(4, 0, 0, w, h, bg)
                surface.SetDrawColor(100,100,100,80); surface.DrawOutlinedRect(0,0,w,h,1)
                surface.SetMaterial(Material(GetItemImage(item.classname)))
                surface.SetDrawColor(255, 255, 255, canGive and 255 or 100)
                surface.DrawTexturedRect(4, 4, w - 8, h - 16)
                draw.SimpleText(FormatMoney(item.price), "DermaDefault", w/2, h - 3,
                    canGive and COL.gold or COL.disabled, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
            end
            btn.DoClick = function()
                detailPanel:SetItem(item, function(it, canGive)
                    OpenPurchaseConfirm(it, npcUID, canGive, function()
                        -- Refresh the grid so eligibility updates, but keep shop open
                        RebuildGrid()
                        detailPanel:SetItem(nil, nil)
                    end)
                end)
            end
            btn:SetTooltip(GetItemName(item.classname))
            grid:AddItem(btn)
        end
    end

    prevBtn.DoClick = function()
        if curPage > 1 then curPage = curPage - 1; RebuildGrid() end
    end
    nextBtn.DoClick = function()
        if curPage < maxPage then curPage = curPage + 1; RebuildGrid() end
    end

    RebuildGrid()
end

-- ----------------------------------------------------------------
--  Admin shop editor
-- ----------------------------------------------------------------
function OpenShopEditor(npcUID, shopData)
    -- Deep copy so we don't mutate live data before saving.
    local items = {}
    for _, v in ipairs(shopData or {}) do
        local copy = {}
        for k2, v2 in pairs(v) do copy[k2] = v2 end
        copy.itemCost   = {}
        for _, c in ipairs(v.itemCost or {}) do
            table.insert(copy.itemCost, { classname = c.classname })
        end
        copy.conditions = {}
        for _, c in ipairs(v.conditions or {}) do
            table.insert(copy.conditions, { ids = table.Copy(c.ids or {}), mode = c.mode or "any", negate = c.negate or false })
        end
        table.insert(items, copy)
    end

    -- Drag state for editor reorder
    local edrag = { active = false, fromIdx = nil, wasDown = false }
    local _edSlotReg = {}

    local function ECancelDrag() edrag.active = false edrag.fromIdx = nil edrag.wasDown = false end

    local W, H     = 960, 700
    local PAD      = 10
    local HEADER_H = 34
    local SLOT_SZ  = 64
    local SLOT_COLS = 8
    local PAGE_BAR_H = 26
    local ARROW_W  = 28
    local GRID_W   = SLOT_COLS * SLOT_SZ + 16
    local RIGHT_X  = PAD + GRID_W + PAD
    local RIGHT_W  = W - RIGHT_X - PAD
    local curPage  = 1
    local SLOTS_PER_PAGE = 50
    local maxPage  = math.ceil(TOTAL_SLOTS / SLOTS_PER_PAGE)

    local edFrame = vgui.Create("DFrame")
    edFrame:SetSize(W, H); edFrame:Center(); edFrame:SetTitle("")
    edFrame:SetDraggable(true); edFrame:ShowCloseButton(false); edFrame:MakePopup()
    edFrame.Paint = function(s, w, h)
        draw.RoundedBox(8, 0, 0, w, h, COL.bg)
        draw.RoundedBox(8, 0, 0, w, HEADER_H, COL.bgMid)
        draw.SimpleText("Edit Shop — " .. npcUID, "DermaDefaultBold", PAD, HEADER_H/2, COL.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        surface.SetDrawColor(COL.accent); surface.DrawOutlinedRect(0, 0, w, h, 1)
    end

    local closeBtn = vgui.Create("DButton", edFrame)
    closeBtn:SetPos(W - 68, 6); closeBtn:SetSize(60, 22); closeBtn:SetText("")
    closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
        draw.SimpleText("Close", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    closeBtn.DoClick = function() ECancelDrag(); edFrame:Remove() end

    local saveBtn = vgui.Create("DButton", edFrame)
    saveBtn:SetPos(W - 138, 6); saveBtn:SetSize(62, 22); saveBtn:SetText("")
    saveBtn.Paint = function(s, w, h)
        draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.greenHover or COL.green)
        draw.SimpleText("Save", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    saveBtn.DoClick = function()
        net.Start("ShopSave")
        net.WriteString(npcUID)
        net.WriteString(util.TableToJSON(items))
        net.SendToServer()
        edFrame:Remove()
    end

    -- ---- Grid (left) ----
    local gridPanel = vgui.Create("DPanel", edFrame)
    gridPanel:SetPos(PAD, HEADER_H + PAD); gridPanel:SetSize(GRID_W, H - HEADER_H - PAD * 2)

    local prevBtn = vgui.Create("DButton", gridPanel)
    prevBtn:SetPos(4, 4); prevBtn:SetSize(ARROW_W, PAGE_BAR_H - 8); prevBtn:SetText("")
    prevBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("◄", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    local nextBtn = vgui.Create("DButton", gridPanel)
    nextBtn:SetPos(GRID_W - 4 - ARROW_W, 4); nextBtn:SetSize(ARROW_W, PAGE_BAR_H - 8); nextBtn:SetText("")
    nextBtn.Paint = function(s, w, h)
        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.accentHover or COL.accent)
        draw.SimpleText("►", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    gridPanel.Paint = function(s, w, h)
        draw.RoundedBox(6, 0, 0, w, h, COL.bgMid)
        draw.SimpleText("Page " .. curPage .. " / " .. maxPage, "DermaDefault", w/2, PAGE_BAR_H/2, COL.textMuted, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local gridScroll = vgui.Create("DScrollPanel", gridPanel)
    gridScroll:SetPos(4, PAGE_BAR_H + 2)
    gridScroll:SetSize(GRID_W - 8, gridPanel:GetTall() - PAGE_BAR_H - 32)
    local gsb = gridScroll:GetVBar(); gsb:SetWide(4)
    gsb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
    gsb.btnUp.Paint   = function() end; gsb.btnDown.Paint = function() end
    gsb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

    -- ---- Right: item editor ----
    local rightPanel = vgui.Create("DScrollPanel", edFrame)
    rightPanel:SetPos(RIGHT_X, HEADER_H + PAD); rightPanel:SetSize(RIGHT_W, H - HEADER_H - PAD*2)
    local rsb = rightPanel:GetVBar(); rsb:SetWide(4)
    rsb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
    rsb.btnUp.Paint   = function() end; rsb.btnDown.Paint = function() end
    rsb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

    local selectedIdx = nil
    local RebuildGrid, LoadItemEditor

    -- ---- Condition builder (same rows as dialogue) ----
    local ROW_H, ROW_GAP = 28, 4
    local function MakeCondRows(parent, condList, containerW, onChange)
        local function RebuildRows()
            parent:Clear()
            for ci, cond in ipairs(condList) do
                local row = vgui.Create("DPanel", parent)
                row:Dock(TOP); row:SetTall(ROW_H); row:DockMargin(0, ci==1 and 0 or ROW_GAP, 0, 0)
                row.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(35,35,35,200)) end

                local mc = vgui.Create("DComboBox", row)
                mc:SetPos(2,4); mc:SetSize(52,20); mc:SetTextColor(COL.textMain)
                mc.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(25,25,25,220)) s:DrawTextEntryText(COL.textMain,COL.accent,COL.textMain) end
                mc:AddChoice("any"); mc:AddChoice("all"); mc:SetValue(cond.mode or "any")
                mc.OnSelect = function(s,idx,val) cond.mode = val end

                local notCB = vgui.Create("DCheckBox", row)
                notCB:SetPos(58,6); notCB:SetSize(14,14); notCB:SetValue(cond.negate or false)
                notCB.OnChange = function(s,val) cond.negate = val end
                local notLbl = vgui.Create("DLabel", row)
                notLbl:SetPos(75,5); notLbl:SetText("Not"); notLbl:SetTextColor(Color(200,120,120)); notLbl:SizeToContents()

                local ie = vgui.Create("DTextEntry", row)
                ie:SetPos(102,4); ie:SetSize(containerW-102-30,20)
                ie:SetPlaceholderText("choiceID, choiceID2 ..."); ie:SetTextColor(COL.textMain)
                ie.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(25,25,25,220)) s:DrawTextEntryText(COL.textMain,COL.accent,COL.textMain) end
                ie:SetText(table.concat(cond.ids or {}, ", "))
                ie.OnChange = function(s)
                    local list = {}
                    for part in (s:GetText()..","): gmatch("([^,]+),") do
                        local t = part:match("^%s*(.-)%s*$")
                        if t ~= "" then table.insert(list, t) end
                    end
                    cond.ids = list
                end

                local xb = vgui.Create("DButton", row)
                xb:SetPos(containerW-26,4); xb:SetSize(24,20); xb:SetText("")
                xb.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,s:IsHovered() and COL.dangerHover or COL.danger) draw.SimpleText("×","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
                xb.DoClick = function() table.remove(condList,ci) RebuildRows() if onChange then onChange() end end
            end
            local ab = vgui.Create("DButton", parent)
            ab:Dock(TOP); ab:SetTall(22); ab:DockMargin(0,ROW_GAP,0,0); ab:SetText("")
            ab.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,s:IsHovered() and Color(60,80,60,200) or Color(45,65,45,200)) draw.SimpleText("+ Add Condition","DermaDefault",w/2,h/2,COL.textSub,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
            ab.DoClick = function() table.insert(condList,{ids={},mode="any",negate=false}) RebuildRows() if onChange then onChange() end end
        end
        RebuildRows()
    end

    LoadItemEditor = function(idx)
        selectedIdx = idx
        rightPanel:Clear()

        if not idx or not items[idx] then
            local lbl = vgui.Create("DLabel", rightPanel)
            lbl:Dock(TOP); lbl:SetTall(40); lbl:SetText("Select an item to edit.")
            lbl:SetTextColor(COL.textMuted); lbl:SetContentAlignment(5)
            return
        end

        local item = items[idx]
        local EW   = RIGHT_W - 16

        local function RL(text, y)
            local l = vgui.Create("DLabel", rightPanel)
            l:Dock(TOP); l:SetTall(18); l:DockMargin(4,y==0 and 4 or 2,4,0)
            l:SetText(text); l:SetTextColor(COL.textMuted)
        end
        local function RE(ph, val, onChange)
            local e = vgui.Create("DTextEntry", rightPanel)
            e:Dock(TOP); e:SetTall(24); e:DockMargin(4,2,4,0)
            e:SetPlaceholderText(ph); e:SetText(val or ""); e:SetTextColor(COL.textMain)
            e.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(30,30,30,220)) s:DrawTextEntryText(COL.textMain,COL.accent,COL.textMain) end
            e.OnChange = onChange
            return e
        end

        -- Item icon + name preview
        local prevRow = vgui.Create("DPanel", rightPanel)
        prevRow:Dock(TOP); prevRow:SetTall(SLOT_SZ + 4); prevRow:DockMargin(4,4,4,0)
        prevRow.Paint = function(s,w,h) draw.RoundedBox(4,0,0,w,h,COL.bgDark) end
        local prevIcon = vgui.Create("DPanel", prevRow)
        prevIcon:SetPos(4,2); prevIcon:SetSize(SLOT_SZ,SLOT_SZ); prevIcon.Paint = function(s,w,h)
            if item.classname and item.classname ~= "" then
                surface.SetMaterial(Material(GetItemImage(item.classname)))
                surface.SetDrawColor(255,255,255,255); surface.DrawTexturedRect(0,0,w,h)
            end
        end
        local prevName = vgui.Create("DLabel", prevRow)
        prevName:SetPos(SLOT_SZ+10,2); prevName:SetSize(EW-SLOT_SZ-16,22)
        prevName:SetTextColor(COL.textMain); prevName:SetFont("DermaDefaultBold")
        prevName:SetText(GetItemName(item.classname or ""))

        RL("Classname:"); RE("weapon_classname", item.classname, function(s)
            item.classname = s:GetText()
            prevName:SetText(GetItemName(item.classname))
            prevIcon:InvalidateLayout()
        end)

        RL("Price:"); RE("0", tostring(item.price or 0), function(s)
            item.price = tonumber(s:GetText()) or 0
        end)

        -- Item costs
        RL("Item Costs (items player must give up):")
        for ci, cost in ipairs(item.itemCost or {}) do
            local costRow = vgui.Create("DPanel", rightPanel)
            costRow:Dock(TOP); costRow:SetTall(26); costRow:DockMargin(4,2,4,0)
            costRow.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(35,35,35,200)) end
            local ce = vgui.Create("DTextEntry", costRow)
            ce:SetPos(2,3); ce:SetSize(EW-32,20); ce:SetPlaceholderText("weapon_classname")
            ce:SetTextColor(COL.textMain); ce:SetText(cost.classname or "")
            ce.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(25,25,25,220)) s:DrawTextEntryText(COL.textMain,COL.accent,COL.textMain) end
            ce.OnChange = function(s) cost.classname = s:GetText() end
            local capCI = ci
            local delB = vgui.Create("DButton", costRow)
            delB:SetPos(EW-28,3); delB:SetSize(24,20); delB:SetText("")
            delB.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,s:IsHovered() and COL.dangerHover or COL.danger) draw.SimpleText("×","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
            delB.DoClick = function() table.remove(item.itemCost,capCI) LoadItemEditor(idx) end
        end
        local addCostBtn = vgui.Create("DButton", rightPanel)
        addCostBtn:Dock(TOP); addCostBtn:SetTall(22); addCostBtn:DockMargin(4,2,4,0); addCostBtn:SetText("")
        addCostBtn.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,s:IsHovered() and Color(60,80,60,200) or Color(45,65,45,200)) draw.SimpleText("+ Add Item Cost","DermaDefault",w/2,h/2,COL.textSub,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
        addCostBtn.DoClick = function() table.insert(item.itemCost,{classname=""}) LoadItemEditor(idx) end

        -- Visibility conditions
        RL("Visibility Conditions (AND between rows):")
        local condScroll = vgui.Create("DScrollPanel", rightPanel)
        condScroll:Dock(TOP); condScroll:SetTall(120); condScroll:DockMargin(4,2,4,0)
        local csb = condScroll:GetVBar(); csb:SetWide(4)
        csb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
        csb.btnUp.Paint   = function() end; csb.btnDown.Paint = function() end
        csb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end
        MakeCondRows(condScroll, item.conditions, EW - 8)

        -- Delete item button
        local delItemBtn = vgui.Create("DButton", rightPanel)
        delItemBtn:Dock(TOP); delItemBtn:SetTall(28); delItemBtn:DockMargin(4,8,4,0); delItemBtn:SetText("")
        delItemBtn.Paint = function(s,w,h) draw.RoundedBox(4,0,0,w,h,s:IsHovered() and COL.dangerHover or COL.danger) draw.SimpleText("Remove Item from Shop","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
        delItemBtn.DoClick = function()
            table.remove(items, idx)
            selectedIdx = nil
            RebuildGrid()
            LoadItemEditor(nil)
        end
    end

    -- ---- Bottom bar: classname entry + Add + Browse ----
    local addRow = vgui.Create("DPanel", gridPanel)
    addRow:SetPos(4, gridPanel:GetTall() - 28)
    addRow:SetSize(GRID_W - 8, 24)
    addRow.Paint = function() end

    local classEntry = vgui.Create("DTextEntry", addRow)
    classEntry:SetPos(0, 0); classEntry:SetSize(GRID_W - 138, 24)
    classEntry:SetPlaceholderText("weapon classname..."); classEntry:SetTextColor(COL.textMain)
    classEntry.Paint = function(s,w,h) draw.RoundedBox(3,0,0,w,h,Color(30,30,30,220)) s:DrawTextEntryText(COL.textMain,COL.accent,COL.textMain) end

    local function DoAddItem(cls)
        cls = cls and cls:Trim() or ""
        if cls == "" then return end
        table.insert(items, { classname = cls, price = 0, conditions = {}, itemCost = {} })
        classEntry:SetText("")
        curPage = math.ceil(math.max(#items, 1) / SLOTS_PER_PAGE)
        maxPage = math.ceil(TOTAL_SLOTS / SLOTS_PER_PAGE)
        RebuildGrid()
        LoadItemEditor(#items)
    end

    local addBtn = vgui.Create("DButton", addRow)
    addBtn:SetPos(GRID_W - 134, 0); addBtn:SetSize(58, 24); addBtn:SetText("")
    addBtn.Paint = function(s,w,h) draw.RoundedBox(4,0,0,w,h,s:IsHovered() and COL.greenHover or COL.green) draw.SimpleText("+ Add","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    addBtn.DoClick = function() DoAddItem(classEntry:GetText()) end

    local browseBtn = vgui.Create("DButton", addRow)
    browseBtn:SetPos(GRID_W - 72, 0); browseBtn:SetSize(68, 24); browseBtn:SetText("")
    browseBtn.Paint = function(s,w,h) draw.RoundedBox(4,0,0,w,h,s:IsHovered() and COL.accentHover or COL.accent) draw.SimpleText("Browse...","DermaDefault",w/2,h/2,COL.textMain,TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER) end
    browseBtn.DoClick = function()
        -- Build combined list: SWEPs + passives + personas
        local wlist = {}

        for _, wdata in ipairs(weapons.GetList()) do
            if wdata and wdata.ClassName and wdata.SlotType then
                table.insert(wlist, {
                    classname = wdata.ClassName,
                    name      = wdata.PrintName or wdata.ClassName,
                    category  = wdata.SlotType or "Equipment",
                })
            end
        end

        if Passives then
            for buffName, pdata in pairs(Passives) do
                if pdata.classname then
                    table.insert(wlist, {
                        classname = pdata.classname,
                        name      = pdata.name or pdata.classname,
                        category  = "Passive",
                        buffName  = buffName,
                    })
                end
            end
        end

        if Personas then
            for personaName, pdata in pairs(Personas) do
                table.insert(wlist, {
                    classname = personaName,
                    name      = pdata.name or personaName,
                    category  = "Persona",
                })
            end
        end

        table.sort(wlist, function(a, b)
            if a.category ~= b.category then return a.category < b.category end
            return a.name < b.name
        end)

        local BW, BH = 420, 500
        local bFrame = vgui.Create("DFrame")
        bFrame:SetSize(BW, BH); bFrame:Center(); bFrame:SetTitle("")
        bFrame:SetDraggable(true); bFrame:ShowCloseButton(false); bFrame:MakePopup()
        bFrame.Paint = function(s, w, h)
            draw.RoundedBox(8, 0, 0, w, h, COL.bg)
            draw.RoundedBox(8, 0, 0, w, 30, COL.bgMid)
            draw.SimpleText("Browse Weapons", "DermaDefaultBold", 10, 15, COL.accent, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            surface.SetDrawColor(COL.accent); surface.DrawOutlinedRect(0, 0, w, h, 1)
        end

        local closeBrowse = vgui.Create("DButton", bFrame)
        closeBrowse:SetSize(60, 22); closeBrowse:SetPos(BW - 68, 4); closeBrowse:SetText("")
        closeBrowse.Paint = function(s, w, h)
            draw.RoundedBox(4, 0, 0, w, h, s:IsHovered() and COL.dangerHover or COL.danger)
            draw.SimpleText("Close", "DermaDefault", w/2, h/2, COL.textMain, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        closeBrowse.DoClick = function() bFrame:Remove() end

        local searchEntry = vgui.Create("DTextEntry", bFrame)
        searchEntry:SetPos(8, 34); searchEntry:SetSize(BW - 16, 24)
        searchEntry:SetPlaceholderText("Search by name or classname...")
        searchEntry:SetTextColor(COL.textMain)
        searchEntry.Paint = function(s, w, h)
            draw.RoundedBox(3, 0, 0, w, h, Color(30,30,30,220))
            s:DrawTextEntryText(COL.textMain, COL.accent, COL.textMain)
        end

        local listScroll = vgui.Create("DScrollPanel", bFrame)
        listScroll:SetPos(8, 62); listScroll:SetSize(BW - 16, BH - 70)
        local lsb = listScroll:GetVBar(); lsb:SetWide(4)
        lsb.Paint         = function(s,w,h) draw.RoundedBox(2,0,0,w,h,Color(30,30,30,120)) end
        lsb.btnUp.Paint   = function() end; lsb.btnDown.Paint = function() end
        lsb.btnGrip.Paint = function(s,w,h) draw.RoundedBox(2,0,0,w,h,COL.accent) end

        local function RebuildList(filter)
            listScroll:Clear()
            filter = filter and filter:lower() or ""
            for _, entry in ipairs(wlist) do
                if filter == "" or entry.name:lower():find(filter, 1, true) or entry.classname:lower():find(filter, 1, true) or (entry.category or ""):lower():find(filter, 1, true) then
                    local row = vgui.Create("DButton", listScroll)
                    row:Dock(TOP); row:SetTall(36); row:DockMargin(0, 1, 0, 0); row:SetText("")
                    local capEntry = entry
                    row.Paint = function(s, w, h)
                        draw.RoundedBox(3, 0, 0, w, h, s:IsHovered() and COL.panel or COL.bgMid)
                        surface.SetMaterial(Material(GetItemImage(capEntry.classname)))
                        surface.SetDrawColor(255, 255, 255, 255)
                        surface.DrawTexturedRect(4, 2, 32, 32)
                        draw.SimpleText(capEntry.name, "DermaDefaultBold", 44, 8, COL.textMain, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                        draw.SimpleText(capEntry.classname .. "  [" .. (capEntry.category or "") .. "]", "DermaDefault", 44, 20, COL.textMuted, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end
                    row.DoClick = function()
                        classEntry:SetText(capEntry.classname)
                        bFrame:Remove()
                    end
                end
            end
        end

        RebuildList("")
        searchEntry.OnChange = function(s) RebuildList(s:GetText()) end
    end

    RebuildGrid = function()
        gridScroll:Clear()
        _edSlotReg = {}
        local grid = vgui.Create("DGrid", gridScroll)
        grid:SetCols(SLOT_COLS); grid:SetColWide(SLOT_SZ); grid:SetRowHeight(SLOT_SZ)
        grid:SetWide(SLOT_COLS * SLOT_SZ); grid.Paint = function() end

        local startIdx = (curPage - 1) * SLOTS_PER_PAGE + 1
        local endIdx   = math.min(startIdx + SLOTS_PER_PAGE - 1, #items)

        for i = startIdx, endIdx do
            local item = items[i]
            local capI = i

            local btn = vgui.Create("DButton")
            btn:SetSize(SLOT_SZ-2, SLOT_SZ-2); btn:SetText("")
            table.insert(_edSlotReg, { panel = btn, idx = capI })

            btn.Paint = function(s, w, h)
                local isSelected = (selectedIdx == capI)
                local isDragging = (edrag.active and edrag.fromIdx == capI)
                local bg = isDragging and Color(30,30,30,60) or (isSelected and COL.accent or (s:IsHovered() and COL.panel or Color(30,30,30,180)))
                draw.RoundedBox(4,0,0,w,h,bg)
                surface.SetDrawColor(100,100,100,80); surface.DrawOutlinedRect(0,0,w,h,1)
                if item.classname and item.classname ~= "" then
                    surface.SetMaterial(Material(GetItemImage(item.classname)))
                    surface.SetDrawColor(255,255,255,isDragging and 60 or 255)
                    surface.DrawTexturedRect(4,4,w-8,h-8)
                else
                    draw.SimpleText(tostring(capI),"DermaDefault",w/2,h/2,Color(55,55,55,200),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
                end
            end
            btn.DoClick = function() LoadItemEditor(capI) end
            grid:AddItem(btn)
        end
    end

    -- Drag-to-reorder for editor
    hook.Add("Think", "ShopEditorDrag", function()
        if not IsValid(edFrame) then hook.Remove("Think","ShopEditorDrag") ECancelDrag() return end
        local down = input.IsMouseDown(MOUSE_LEFT)
        if down and not edrag.wasDown and not edrag.active then
            local mx, my = gui.MousePos()
            for _, reg in ipairs(_edSlotReg) do
                if IsValid(reg.panel) then
                    local sx,sy = reg.panel:LocalToScreen(0,0)
                    local sw,sh = reg.panel:GetSize()
                    if mx>=sx and mx<=sx+sw and my>=sy and my<=sy+sh then
                        edrag.active  = true
                        edrag.fromIdx = reg.idx
                        break
                    end
                end
            end
        end
        if not down and edrag.wasDown then
            if edrag.active then
                local mx, my = gui.MousePos()
                for _, reg in ipairs(_edSlotReg) do
                    if IsValid(reg.panel) and reg.idx ~= edrag.fromIdx then
                        local sx,sy = reg.panel:LocalToScreen(0,0)
                        local sw,sh = reg.panel:GetSize()
                        if mx>=sx and mx<=sx+sw and my>=sy and my<=sy+sh then
                            local from, to = edrag.fromIdx, reg.idx
                            local tmp = items[from]; items[from] = items[to]; items[to] = tmp
                            RebuildGrid()
                            if selectedIdx == from then LoadItemEditor(to)
                            elseif selectedIdx == to then LoadItemEditor(from) end
                            break
                        end
                    end
                end
            end
            ECancelDrag()
        end
        edrag.wasDown = down
    end)

    hook.Add("PostRenderVGUI", "ShopEditorDragGhost", function()
        if not edrag.active or not IsValid(edFrame) then return end
        local item = items[edrag.fromIdx]
        if not item then return end
        local mx, my = gui.MousePos()
        local sz = 48
        surface.SetDrawColor(0,0,0,140); surface.DrawRect(mx-sz/2-2,my-sz/2-2,sz+4,sz+4)
        if item.classname and item.classname ~= "" then
            surface.SetMaterial(Material(GetItemImage(item.classname)))
            surface.SetDrawColor(255,255,255,220); surface.DrawTexturedRect(mx-sz/2,my-sz/2,sz,sz)
        end
    end)

    edFrame.OnRemove = function()
        hook.Remove("Think","ShopEditorDrag")
        hook.Remove("PostRenderVGUI","ShopEditorDragGhost")
        ECancelDrag()
    end

    prevBtn.DoClick = function()
        if curPage > 1 then curPage = curPage - 1; RebuildGrid() end
    end
    nextBtn.DoClick = function()
        if curPage < maxPage then curPage = curPage + 1; RebuildGrid() end
    end

    RebuildGrid()
    LoadItemEditor(nil)
end

-- ----------------------------------------------------------------
--  Net receivers
-- ----------------------------------------------------------------
net.Receive("ShopOpen", function()
    local npcUID      = net.ReadString()
    local raw         = net.ReadString()
    local choicesRaw  = net.ReadString()
    local isAdmin     = net.ReadBool()
    local shopData    = util.JSONToTable(raw) or {}
    local choices     = util.JSONToTable(choicesRaw) or {}
    BuildShopPanel(npcUID, shopData, choices, isAdmin)
end)

net.Receive("ShopSaved", function()
    local npcUID = net.ReadString()
    local raw    = net.ReadString()
    local data   = util.JSONToTable(raw) or {}
    -- If the shop panel is open (unlikely after save from editor), update it.
    -- Mostly the editor closes on save, so this is informational.
end)