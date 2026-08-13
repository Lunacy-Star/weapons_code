AddCSLuaFile()

if SERVER then
    util.AddNetworkString("OpenCraftingStationMenu")
    return
end

local function CreateItemCard(item, onClick)
    local card = vgui.Create("DButton")
    card:SetSize(100, 100)
    card:SetText("")
    card:SetTooltip(item.name)
    card.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 45, 220))
        draw.RoundedBox(6, 2, 2, w - 4, h - 4, Color(55, 55, 55, 200))
    end
    card.DoClick = function()
        if onClick then
            onClick(item)
        end
    end

    local icon = vgui.Create("DImage", card)
    icon:Dock(FILL)
    icon:SetImage(item.icon or "materials/entities/what.png")
    icon:SetKeepAspect(true)
    icon:SetMouseInputEnabled(false)

    return card
end

local function BuildDetailsPanel(parent)
    local details = vgui.Create("DPanel", parent)
    details:Dock(FILL)
    details:DockMargin(10, 10, 10, 10)
    details.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(40, 40, 40, 220))
    end

    local selectedTitle = vgui.Create("DLabel", details)
    selectedTitle:Dock(TOP)
    selectedTitle:SetTall(28)
    selectedTitle:SetText("Select an item to see details")
    selectedTitle:SetFont("DermaLarge")
    selectedTitle:SetTextColor(Color(255, 255, 255))
    selectedTitle:DockMargin(10, 10, 10, 10)

    local separator = vgui.Create("DPanel", details)
    separator:Dock(TOP)
    separator:SetTall(2)
    separator:DockMargin(10, 0, 10, 10)
    separator.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(100, 100, 100, 200))
    end

    local scroll = vgui.Create("DScrollPanel", details)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 0, 10, 10)

    local function SetDetails(item)
        scroll:Clear()
        selectedTitle:SetText(item.name)

        local descHeader = vgui.Create("DLabel", scroll)
        descHeader:Dock(TOP)
        descHeader:SetText("Description:")
        descHeader:SetFont("DermaDefaultBold")
        descHeader:SetTextColor(Color(200, 200, 200))
        descHeader:DockMargin(0, 0, 0, 5)

        local descLabel = vgui.Create("DLabel", scroll)
        descLabel:Dock(TOP)
        descLabel:SetText(item.description)
        descLabel:SetFont("DermaDefault")
        descLabel:SetTextColor(Color(220, 220, 220))
        descLabel:SetAutoStretchVertical(true)
        descLabel:SetWrap(true)
        descLabel:DockMargin(0, 0, 0, 15)

        local reqLabel = vgui.Create("DLabel", scroll)
        reqLabel:Dock(TOP)
        reqLabel:SetText("Requirements:")
        reqLabel:SetFont("DermaDefaultBold")
        reqLabel:SetTextColor(Color(180, 200, 255))
        reqLabel:DockMargin(0, 0, 0, 5)

        for _, req in ipairs(item.requirements or {}) do
            local row = vgui.Create("DLabel", scroll)
            row:Dock(TOP)
            row:SetText("- " .. req.amount .. "x " .. req.name)
            row:SetFont("DermaDefault")
            row:SetTextColor(Color(200, 200, 200))
            row:SetAutoStretchVertical(true)
            row:SetWrap(true)
            row:DockMargin(10, 0, 0, 5)
        end
    end

    return details, SetDetails
end

local function OpenCraftingStationUI(stationTitle, stationEnt, profession, playerKnowledge)
    if IsValid(CraftingStationFrame) then
        CraftingStationFrame:Remove()
    end

    profession = profession or "Alchemy"
    playerKnowledge = playerKnowledge or {}

    local CraftingStationItems = GetCraftingStationItems and GetCraftingStationItems(profession, playerKnowledge) or {}

    CraftingStationFrame = vgui.Create("DFrame")
    CraftingStationFrame:SetTitle(stationTitle or "Crafting Station")
    CraftingStationFrame:SetSize(900, 560)
    CraftingStationFrame:Center()
    CraftingStationFrame:MakePopup()
    CraftingStationFrame.Paint = function(self, w, h)
        draw.RoundedBox(8, 0, 0, w, h, Color(35, 35, 35, 240))
    end

    local mainPanel = vgui.Create("DPanel", CraftingStationFrame)
    mainPanel:Dock(FILL)
    mainPanel:DockMargin(10, 30, 10, 10)
    mainPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(45, 45, 45, 220))
    end

    local leftPanel = vgui.Create("DPanel", mainPanel)
    leftPanel:Dock(LEFT)
    leftPanel:SetWide(560)
    leftPanel:DockMargin(10, 10, 5, 10)
    leftPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50, 220))
    end

    local rightPanel = vgui.Create("DPanel", mainPanel)
    rightPanel:Dock(FILL)
    rightPanel:DockMargin(5, 10, 10, 10)
    rightPanel.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(50, 50, 50, 220))
    end

    local gridLabel = vgui.Create("DLabel", leftPanel)
    gridLabel:Dock(TOP)
    gridLabel:SetTall(24)
    gridLabel:SetText("Available recipes")
    gridLabel:SetFont("DermaDefaultBold")
    gridLabel:SetTextColor(Color(255, 255, 255))
    gridLabel:DockMargin(10, 10, 10, 5)

    local tooltipLabel = vgui.Create("DLabel", leftPanel)
    tooltipLabel:Dock(TOP)
    tooltipLabel:SetTall(24)
    tooltipLabel:SetText("Click a recipe to view details.")
    tooltipLabel:SetFont("DermaDefault")
    tooltipLabel:SetTextColor(Color(190, 190, 190))
    tooltipLabel:DockMargin(10, 0, 10, 10)

    local gridScroll = vgui.Create("DScrollPanel", leftPanel)
    gridScroll:Dock(FILL)
    gridScroll:DockMargin(10, 0, 10, 10)

    local grid = vgui.Create("DIconLayout", gridScroll)
    grid:Dock(FILL)
    grid:SetSpaceX(8)
    grid:SetSpaceY(8)
    grid:SetBorder(8)
    grid:SetTall(400)

    local detailsPanel, SetDetails = BuildDetailsPanel(rightPanel)

    for _, item in ipairs(CraftingStationItems) do
        local card = CreateItemCard(item, function(selectedItem)
            tooltipLabel:SetText(selectedItem.name)
            SetDetails(selectedItem)
        end)
        grid:Add(card)
    end

    if #CraftingStationItems > 0 then
        local firstItem = CraftingStationItems[1]
        tooltipLabel:SetText(firstItem.name)
        SetDetails(firstItem)
    else
        tooltipLabel:SetText("No recipes available for your skill level.")
    end
end

net.Receive("OpenCraftingStationMenu", function()
    local entity = net.ReadEntity()
    local title = net.ReadString()
    local profession = net.ReadString()
    local knowledge = net.ReadTable() or {}
    OpenCraftingStationUI(title, entity, profession, knowledge)
end)
