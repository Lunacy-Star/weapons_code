AddCSLuaFile()
util.PrecacheSound("Music/sleep.wav")

ENT.Base = "base_anim"
ENT.Type = "anim"
ENT.PrintName = "Bed"
ENT.Author = "Nara"
ENT.Category = "Special Entities"
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Model = "models/props_c17/FurnitureBed001a.mdl"

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self.LastUseTime = 0

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then phys:Wake() end
end

function ENT:Use(activator, caller)
    local currentTime = CurTime()
    if currentTime - self.LastUseTime < 1 then return end

    self.LastUseTime = currentTime

    local currentHP = activator:GetNWInt("TBCHP", 0)
    local maxHP = activator:GetNWInt("TBCMAXHP", 0)
    local currentMP = activator:GetNWInt("TBCMP", 0)
    local maxMP = activator:GetNWInt("TBCMAXMP", 0)
    if currentHP >= maxHP and currentMP >= maxMP then
        activator:ChatPrint("You're pretty well rested right now.")
        return
    end

    if not IsValid(activator) or not activator:IsPlayer() then return end

    -- Send a network message to trigger the client-side effect. This is found in the tbc_stathandler.lua file.
    net.Start("BedUseEffect")
    net.Send(activator)
    activator:Freeze(true)

    -- Unfreeze the player after the fade-in completes
    timer.Simple(13, function()
        if IsValid(activator) then activator:Freeze(false) end
    end)

    activator:SetNWInt("TBCHP", maxHP)
    activator:SetNWInt("TBCMP", maxMP)
end

if SERVER then util.AddNetworkString("BedUseEffect") end

if CLIENT then
    -- This is for resting on a bed.

    local fadeDuration = 10
    local fadeInDuration = 3
    local displayText = "You took a rest..."
    local textAlpha = 0

    net.Receive("BedUseEffect", function()
        local ply = LocalPlayer()

        ply:ScreenFade(SCREENFADE.OUT, Color(0, 0, 0, 255), 1, fadeDuration)

        surface.PlaySound("Music/sleep.wav")

        timer.Create("TextFadeIn", 0.05, fadeDuration / 0.05, function()
            if textAlpha < 255 then textAlpha = textAlpha + 5 end
        end)

        hook.Add("HUDPaint", "DrawSleepMessage", function()
            draw.SimpleText(displayText, "Trebuchet24", ScrW() / 2, ScrH() / 2,
                            Color(255, 255, 255, textAlpha), TEXT_ALIGN_CENTER,
                            TEXT_ALIGN_CENTER)
        end)

        timer.Simple(fadeDuration, function()
            ply:ScreenFade(SCREENFADE.IN, Color(0, 0, 0, 255), fadeInDuration, 2)

            timer.Create("TextFadeOut", 0.05, fadeInDuration / 0.05, function()
                if textAlpha > 50 then
                    textAlpha = textAlpha - 15 -- Decrease text opacity gradually
                else
                    -- Remove the text once fully faded out
                    hook.Remove("HUDPaint", "DrawSleepMessage")
                end
            end)
        end)
    end)
end

scripted_ents.Register(ENT, "bed")
