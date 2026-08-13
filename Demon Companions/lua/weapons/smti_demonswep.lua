-- Demon Commander SWEP
-- Left-click: aim at your demon to select it / aim at the world to order it there
-- Right-click: toggle the selected demon between following you and staying put
-- Reload: switch control between yourself and the selected demon (weapon swap)

SWEP.PrintName = "Demon Commander"
SWEP.Author = "Nara"
SWEP.Instructions =
    "LMB on your demon: select it. LMB on ground: send it there.\nRMB: follow/stay. R: act through the demon (swaps weapons)."
SWEP.Category = "Custom"

SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Weight = 5

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"
SWEP.UseHands = true

function SWEP:Initialize()
    self:SetHoldType("normal")
end

-- The demon currently selected for orders; falls back to the first deployed one
local function getActiveDemon(ply)
    local selected = ply:GetNWEntity("ActiveDemon", NULL)
    if IsValid(selected) and selected:GetMaster() == ply then
        return selected
    end

    if SERVER and DEMONCOMP and DEMONCOMP.GetDeployedDemons then
        local deployed = DEMONCOMP.GetDeployedDemons(ply)
        if deployed[1] then
            ply:SetNWEntity("ActiveDemon", deployed[1])
            return deployed[1]
        end
    end

    return NULL
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 0.3)
    if CLIENT then return end

    local ply = self:GetOwner()

    local tr = util.TraceLine({
        start = ply:GetShootPos(),
        endpos = ply:GetShootPos() + ply:GetAimVector() * 2000,
        filter = ply,
        mask = MASK_SHOT_HULL
    })

    -- Selecting one of your own demons
    if IsValid(tr.Entity) and tr.Entity:GetClass() == "smt_demon" then
        if tr.Entity:GetMaster() == ply then
            ply:SetNWEntity("ActiveDemon", tr.Entity)
            ply:ChatPrint(tr.Entity:Name() .. " is now your active demon.")
        else
            ply:ChatPrint("That demon does not answer to you.")
        end
        return
    end

    -- Ordering the active demon to a position
    local demon = getActiveDemon(ply)
    if not IsValid(demon) then
        ply:ChatPrint("You have no demon deployed. Use /demondeploy first.")
        return
    end

    if tr.Hit then
        demon:OrderMoveTo(tr.HitPos)
        ply:ChatPrint(demon:Name() .. " is moving to your mark and will hold there.")
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 0.3)
    if CLIENT then return end

    local ply = self:GetOwner()
    local demon = getActiveDemon(ply)
    if not IsValid(demon) then
        ply:ChatPrint("You have no demon deployed. Use /demondeploy first.")
        return
    end

    if demon.MoveState == "follow" then
        demon:OrderStay()
        ply:ChatPrint(demon:Name() .. " is holding position.")
    else
        demon:OrderFollow()
        ply:ChatPrint(demon:Name() .. " is following you.")
    end
end

function SWEP:Reload()
    if CLIENT then return end

    local ply = self:GetOwner()

    -- debounce: Reload is called every tick while R is held
    if (self.NextControlToggle or 0) > CurTime() then return end
    self.NextControlToggle = CurTime() + 0.6

    if not DEMONCOMP or not DEMONCOMP.ToggleControl then return end

    if DEMONCOMP.IsControlling(ply) then
        DEMONCOMP.EndControl(ply)
        return
    end

    local demon = getActiveDemon(ply)
    if not IsValid(demon) then
        ply:ChatPrint("You have no demon deployed. Use /demondeploy first.")
        return
    end

    local ok, msg = DEMONCOMP.StartControl(ply, demon)
    if not ok and msg then
        ply:ChatPrint(msg)
    end
end

if CLIENT then
    surface.CreateFont("DemonCommanderHUD", {font = "Trebuchet24", size = 22, weight = 600})

    function SWEP:DrawHUD()
        local ply = LocalPlayer()
        local demon = ply:GetNWEntity("ActiveDemon", NULL)
        local controlling = ply:GetNWBool("DemonControlling", false)

        local lines = {}
        if IsValid(demon) then
            table.insert(lines, "Active demon: " .. demon:GetNWString("DemonName", "Demon") ..
                " (HP " .. demon:GetNWInt("TBCHP", 0) .. "/" .. demon:GetNWInt("TBCMAXHP", 0) ..
                "  MP " .. demon:GetNWInt("TBCMP", 0) .. "/" .. demon:GetNWInt("TBCMAXMP", 0) .. ")")
        else
            table.insert(lines, "No demon deployed - use /demondeploy")
        end

        if controlling then
            table.insert(lines, "ACTING THROUGH DEMON - your attacks use its stats. R to switch back.")
        else
            table.insert(lines, "LMB: select/send  |  RMB: follow/stay  |  R: act through demon")
        end

        local x = ScrW() / 2
        local y = ScrH() - 90
        for i, line in ipairs(lines) do
            draw.SimpleTextOutlined(line, "DemonCommanderHUD", x, y + (i - 1) * 24,
                controlling and Color(255, 120, 120) or Color(235, 235, 235),
                TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 220))
        end
    end
end

-- Also show a persistent hint while controlling a demon, whatever weapon is out
if CLIENT then
    hook.Add("HUDPaint", "DemonControlIndicator", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:GetNWBool("DemonControlling", false) then return end

        local wep = ply:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "smti_demonswep" then return end

        local demon = ply:GetNWEntity("ControlledDemon", NULL)
        local name = IsValid(demon) and demon:GetNWString("DemonName", "Demon") or "Demon"

        draw.SimpleTextOutlined("Acting through " .. name .. " - attacks use its stats",
            "Default", ScrW() / 2, 40, Color(255, 120, 120),
            TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0, 220))
    end)
end
