include("darkrp_customthings/disguise_kits.lua")

-- Define the SWEP
DEFINE_BASECLASS("player")
SWEP.PrintName = "Disguiser Kit"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
SWEP.Category = "Squish"

function SWEP:PrimaryAttack()
    if SERVER then
        return
    end

    net.Start("ResetPlayerModel")
    net.SendToServer()

    self:SetNextPrimaryFire(CurTime() + 1)
end

-- Define a global variable to hold the Derma window
local modelSelectFrame = nil

-- Secondary fire to open the Derma menu
function SWEP:SecondaryAttack()
    -- Check if the window already exists
    if IsValid(modelSelectFrame) then
        return
    end

    if CLIENT then
        local job = LocalPlayer():Team()
        local models = AvailableModels[job] or {}

        if models then
            modelSelectFrame = vgui.Create("DFrame")
            modelSelectFrame:SetSize(800, 600)
            modelSelectFrame:Center()
            modelSelectFrame:SetTitle("Select Model")
            modelSelectFrame:MakePopup()

            local iconPanel = vgui.Create("DPanel", modelSelectFrame)
            iconPanel:SetSize(200, 500)
            iconPanel:SetPos(25, 25)
            iconPanel.Paint = function(self, w, h)
                draw.RoundedBox(0, 0, 0, w, h, Color(40, 40, 40, 255))
            end

            -- scroll panel
            local scrollPanel = vgui.Create("DScrollPanel", iconPanel)
            scrollPanel:Dock(FILL)

            local iconList = vgui.Create("DIconLayout", scrollPanel)
            iconList:SetSize(200, 500) -- This will now be constrained by the scroll panel
            iconList:SetSpaceY(5)

            local modelDisplay = vgui.Create("DModelPanel", modelSelectFrame)
            modelDisplay:SetSize(500, 500)
            modelDisplay:SetPos(250, 25)
            modelDisplay:SetCamPos(Vector(50, 50, 50))
            modelDisplay:SetLookAt(Vector(0, 0, 40))

            for _, modelPath in pairs(models) do
                local icon = iconList:Add("SpawnIcon")
                icon:SetModel(modelPath)
                icon.DoClick = function()
                    modelDisplay:SetModel(modelPath)
                end
            end

            local confirmButton = vgui.Create("DButton", modelSelectFrame)
            confirmButton:SetSize(100, 30)
            confirmButton:SetPos(350, 550)
            confirmButton:SetText("Confirm")
            confirmButton:SetTextColor(Color(255, 255, 255)) -- Set the text color to white for contrast
            confirmButton.Paint = function(self, w, h)
                if self:IsHovered() then
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 102, 204))
                else
                    draw.RoundedBox(4, 0, 0, w, h, Color(0, 76, 153))
                end
            end
            confirmButton.DoClick = function()
                local selectedModel = modelDisplay:GetModel()
                if selectedModel and selectedModel ~= "" then
                    net.Start("ChangePlayerModel")
                    net.WriteString(selectedModel)
                    net.SendToServer()
                else
                    net.Start("ResetPlayerModel")
                    net.SendToServer()
                end
                net.Start("PlayExplosionSound")
                net.SendToServer()
                modelSelectFrame:Close()
                modelSelectFrame = nil
            end
        end
    end

    self:SetNextSecondaryFire(CurTime() + 1)
end

if SERVER then
    util.AddNetworkString("ChangePlayerModel")
    util.AddNetworkString("ResetPlayerModel")
    util.AddNetworkString("PlayExplosionSound")

    net.Receive(
        "PlayExplosionSound",
        function(len, ply)
            ply:EmitSound("weapons/ar2/npc_ar2_altfire.wav")
        end
    )

    net.Receive(
        "ResetPlayerModel",
        function(len, ply)
            local defaultModel = player_manager.TranslatePlayerModel(ply:GetInfo("cl_playermodel"))
            ply:SetModel(defaultModel)
        end
    )

    net.Receive(
        "ChangePlayerModel",
        function(len, ply)
            local model = net.ReadString()
            ply:SetModel(model)
        end
    )
end
