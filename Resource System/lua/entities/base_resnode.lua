AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Nara"
ENT.Category = "Crafting Resource Nodes"
ENT.SlotType = "Resources"
ENT.ShowInfo = true

ENT.Spawnable = true
ENT.AdminOnly = false

if SERVER then
    util.AddNetworkString("GatherProgress")
    util.AddNetworkString("GatherStart")
    util.AddNetworkString("GatherEnd")
end

if CLIENT then
    -- Client-side table to track gathering progress for UI
    local clientGatherData = nil

    -- Receive progress updates
    net.Receive("GatherProgress", function()
        local ent = net.ReadEntity()
        local progress = net.ReadFloat()

        if IsValid(ent) then
            clientGatherData = {
                progress = progress,
                entity = ent,
                lastUpdate = CurTime()
            }
        end
    end)

    -- Receive gathering start notification
    net.Receive("GatherStart", function()
        local ent = net.ReadEntity()

        if IsValid(ent) then
            clientGatherData = {
                progress = 0,
                entity = ent,
                lastUpdate = CurTime()
            }
        end
    end)

    -- Receive gathering end notification
    net.Receive("GatherEnd", function()
        local ent = net.ReadEntity()
        clientGatherData = nil
    end)

    local function DrawProgressBar(progress)
        local scrW, scrH = ScrW(), ScrH()

        -- Progress bar
        local barWidth = 350
        local barHeight = 25
        local borderWidth = 2

        local x = (scrW - barWidth) / 2
        local y = (scrH - barHeight) / 1.4

        local fillWidth = 346 * progress
        local percentage = math.floor(progress * 100)

        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(x - borderWidth, y - borderWidth,
                         barWidth + (borderWidth * 2),
                         barHeight + (borderWidth * 2))

        -- bar background
        surface.SetDrawColor(20, 20, 20, 255)
        surface.DrawRect(x, y, barWidth, barHeight)

        -- filling
        surface.SetDrawColor(0, 166, 36, 255)
        surface.DrawRect(x + 2, y + 2, fillWidth, barHeight - 4)

        -- Draw percentage text
        surface.SetFont("DermaDefault")
        local text = percentage .. "%"
        local textW, textH = surface.GetTextSize(text)

        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x + (barWidth - textW) / 2,
                           y + (barHeight - textH) / 2)
        surface.DrawText(text)
    end

    hook.Add("HUDPaint", "DrawProgressBar", function()
        if clientGatherData then
            local gatherData = clientGatherData
            local progress = gatherData.progress or 0
            DrawProgressBar(progress)

            if not gatherData.entity then clientGatherData = nil end
            if CurTime() - gatherData.lastUpdate > 5 then
                clientGatherData = nil
            end
        else
            clientGatherData = nil
        end
    end)
end

function ENT:Initialize()
    local randomModel = self.PossibleModels[math.random(#self.PossibleModels)]

    self:SetModel(randomModel)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self.LastUseTime = 0

    -- Initialize tables
    self.PlayerCooldowns = {}
    self.ActiveGatherers = {}

    local phys = self:GetPhysicsObject()
    if (phys:IsValid()) then
        phys:EnableGravity(true)
        phys:EnableMotion(false)
        phys:Wake()
    end
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then return end

    local currentTime = CurTime()

    if currentTime - self.LastUseTime < 1 then return end

    self.LastUseTime = currentTime

    -- Check if player is already gathering from this tree
    if self:IsPlayerGathering(activator) then
        if SERVER then
            activator:ChatPrint("You are already gathering from this tree!")
        end
        return
    end

    -- Check player cooldown
    if self:IsPlayerOnCooldown(activator) then
        if SERVER then
            local remaining = math.ceil(self:GetPlayerCooldownRemaining(
                                            activator, self))
            activator:ChatPrint("You must wait " .. remaining ..
                                    " seconds before gathering from this tree again!")
        end
        return
    end

    -- Check inventory validity
    if not PickUpResourceValidity(activator, self.SlotType,
                                  self.ResourceRegistration, 1) then
        return false
    end

    -- Start gathering
    self:StartGathering(activator)
end

function ENT:GetPlayerCooldownRemaining(ply)
    local steamID = ply:SteamID()
    local cooldownEnd = self.PlayerCooldowns[steamID]

    if not cooldownEnd then return 0 end

    return math.max(0, cooldownEnd - CurTime())
end

function ENT:SetPlayerCooldown(ply)
    local steamID = ply:SteamID()
    self.PlayerCooldowns[steamID] = CurTime() + self.PlayerCooldown

    -- Clean up old cooldowns to prevent memory bloat
    for id, endTime in pairs(self.PlayerCooldowns) do
        if CurTime() > endTime then self.PlayerCooldowns[id] = nil end
    end
end

function ENT:GetActiveGatherers() return self.ActiveGatherers end

function ENT:IsPlayerGathering(ply)
    return self.ActiveGatherers[ply:SteamID()] ~= nil
end

function ENT:IsPlayerOnCooldown(ply)
    local steamID = ply:SteamID()
    local cooldownEnd = self.PlayerCooldowns[steamID]

    if not cooldownEnd then return false end

    return CurTime() < cooldownEnd
end

function ENT:StartGathering(ply)
    local steamID = ply:SteamID()

    self.ActiveGatherers[steamID] = {
        player = ply,
        startTime = CurTime(),
        progress = 0
    }

    -- Send notification to player
    if SERVER then
        ply:ChatPrint("Started gathering wood...")
        net.Start("GatherStart")
        net.WriteEntity(self)
        net.Send(ply)
    end
end

function ENT:CancelGathering(ply)
    local steamID = ply:SteamID()

    if self.ActiveGatherers[steamID] then
        if IsValid(ply) and SERVER then
            ply:ChatPrint("Gathering cancelled!")
            -- Notify client that gathering ended
            net.Start("GatherEnd")
            net.WriteEntity(self)
            net.Send(ply)
        end

        self.ActiveGatherers[steamID] = nil
    end

    return self
end

function ENT:CompleteGathering(ply)
    local steamID = ply:SteamID()

    if IsValid(ply) and SERVER then
        -- Give resources
        AddResourceToPlayer(ply, self.ResourceRegistration, self.SlotAmount)

        -- Set cooldown for this player
        self:SetPlayerCooldown(ply)

        -- Sound effect (optional)
        self:EmitSound("physics/wood/wood_solid_impact_hard" ..
                           math.random(1, 3) .. ".wav")

        -- Notify client that gathering ended
        net.Start("GatherEnd")
        net.WriteEntity(self)
        net.Send(ply)
    end

    -- Remove from active gatherers
    self.ActiveGatherers[steamID] = nil
end

function ENT:Think()
    if not self.ActiveGatherers or table.IsEmpty(self.ActiveGatherers) then
        return
    end

    -- Process each active gatherer
    for steamID, gatherData in pairs(self.ActiveGatherers) do
        local ply = gatherData.player
        local shouldContinue = false

        -- Check if gatherer is still valid
        if not IsValid(ply) or not ply:Alive() then
            self.ActiveGatherers[steamID] = nil
            shouldContinue = true
        end

        -- Check distance
        if not shouldContinue then
            local dist = ply:GetPos():Distance(self:GetPos())
            if dist > self.GatherRange then
                self:CancelGathering(ply)
                shouldContinue = true
            end
        end

        -- Check if player is looking at the tree
        if not shouldContinue then
            local trace = ply:GetEyeTrace()
            if not IsValid(trace.Entity) or trace.Entity ~= self then
                -- Allow some angle tolerance before cancelling
                local dir = (self:GetPos() - ply:GetShootPos()):GetNormalized()
                local dot = ply:GetAimVector():Dot(dir)
                local angle = math.deg(math.acos(math.Clamp(dot, -1, 1)))

                if angle > self.MaxLookAngle then
                    self:CancelGathering(ply)
                    shouldContinue = true
                end
            end
        end

        -- Update progress and check completion
        if not shouldContinue then
            local elapsed = CurTime() - gatherData.startTime
            local progress = math.Clamp(elapsed / self.GatherTime, 0, 1)
            gatherData.progress = progress

            -- Send progress to the player
            if SERVER then
                net.Start("GatherProgress")
                net.WriteEntity(self)
                net.WriteFloat(progress)
                net.Send(ply)
            end

            -- Complete gathering
            if progress >= 1 then self:CompleteGathering(ply) end
        end
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

scripted_ents.Register(ENT, "base_resnode")
