-- Loadout Persistence: client-side "restore your loadout?" confirm popup.
-- Styling matches SMT Weapons Code/lua/autorun/loadout_menu.lua.

if SERVER then
    return
end

local offerFrame

local function OpenLoadoutOfferPopup(charName)
    if IsValid(offerFrame) then
        offerFrame:Close()
    end

    local bgColor = Color(44, 47, 51, 255)

    local frame = vgui.Create("DFrame")
    offerFrame = frame
    frame:SetSize(420, 190)
    frame:Center()
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:MakePopup()
    frame.Paint = function(self, w, h)
        draw.RoundedBox(10, 0, 0, w, h, bgColor)
    end

    local titleLabel = vgui.Create("DLabel", frame)
    titleLabel:SetPos(15, 15)
    titleLabel:SetSize(390, 20)
    titleLabel:SetFont("DermaDefaultBold")
    titleLabel:SetTextColor(Color(255, 255, 255))
    titleLabel:SetText("Continue?")

    local bodyLabel = vgui.Create("DLabel", frame)
    bodyLabel:SetPos(15, 45)
    bodyLabel:SetSize(390, 60)
    bodyLabel:SetWrap(true)
    bodyLabel:SetAutoStretchVertical(true)
    bodyLabel:SetTextColor(Color(220, 220, 220))
    bodyLabel:SetText("Restore your saved loadout as " .. charName .. "?")

    local buttonWidth = 185
    local buttonHeight = 34
    local buttonY = 140

    local loadButton = vgui.Create("DButton", frame)
    loadButton:SetPos(15, buttonY)
    loadButton:SetSize(buttonWidth, buttonHeight)
    loadButton:SetText("Continue")
    loadButton:SetTextColor(Color(255, 255, 255))
    loadButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 102, 204))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(0, 76, 153))
        end
    end
    loadButton.DoClick = function()
        net.Start("LoadoutPersist_Confirm")
        net.WriteBool(true)
        net.SendToServer()
        frame:Close()
    end

    local freshButton = vgui.Create("DButton", frame)
    freshButton:SetPos(15 + buttonWidth + 10, buttonY)
    freshButton:SetSize(buttonWidth, buttonHeight)
    freshButton:SetText("Continue Without Loadout")
    freshButton:SetTextColor(Color(255, 255, 255))
    freshButton.Paint = function(self, w, h)
        if self:IsHovered() then
            draw.RoundedBox(4, 0, 0, w, h, Color(90, 90, 90))
        else
            draw.RoundedBox(4, 0, 0, w, h, Color(65, 65, 65))
        end
    end
    freshButton.DoClick = function()
        net.Start("LoadoutPersist_Confirm")
        net.WriteBool(false)
        net.SendToServer()
        frame:Close()
    end
end

net.Receive(
    "LoadoutPersist_Offer",
    function(len)
        local charName = net.ReadString()
        OpenLoadoutOfferPopup(charName)
    end
)
