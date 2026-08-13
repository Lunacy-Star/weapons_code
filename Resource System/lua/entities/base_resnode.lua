AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.Author = "Nara"
ENT.Category = "Crafting Resource Nodes"
ENT.SlotType = "Resources"
ENT.ShowInfo = true

ENT.Spawnable = true
ENT.AdminOnly = false

-- Optional table of weapon classnames; player must have one active to gather.
-- Leave nil/unset on child entities that have no requirement.
-- Example: ENT.Requires = {"res_pickaxe", "res_drill"}
ENT.Requires = nil

-- Set to true by sv_resnode_persist when this node is tagged for persistence.
-- Networked so the client-side overlay in cl_resnode_persist can read it.
ENT.Persistent = false

if SERVER then
    util.AddNetworkString("GatherProgress")
    util.AddNetworkString("GatherStart")
    util.AddNetworkString("GatherEnd")
end

if CLIENT then
    local clientGatherData = nil

    net.Receive("GatherProgress", function()
        local ent      = net.ReadEntity()
        local progress = net.ReadFloat()

        if IsValid(ent) then
            clientGatherData = {
                progress   = progress,
                entity     = ent,
                lastUpdate = CurTime()
            }
        end
    end)

    net.Receive("GatherStart", function()
        local ent = net.ReadEntity()

        if IsValid(ent) then
            clientGatherData = {
                progress   = 0,
                entity     = ent,
                lastUpdate = CurTime()
            }
        end
    end)

    net.Receive("GatherEnd", function()
        clientGatherData = nil
    end)

    local function DrawProgressBar(progress)
        local scrW, scrH  = ScrW(), ScrH()
        local barWidth    = 350
        local barHeight   = 25
        local borderWidth = 2
        local x           = (scrW - barWidth) / 2
        local y           = (scrH - barHeight) / 1.4
        local fillWidth   = 346 * progress
        local percentage  = math.floor(progress * 100)

        surface.SetDrawColor(50, 50, 50, 200)
        surface.DrawRect(x - borderWidth, y - borderWidth,
                         barWidth + (borderWidth * 2),
                         barHeight + (borderWidth * 2))

        surface.SetDrawColor(20, 20, 20, 255)
        surface.DrawRect(x, y, barWidth, barHeight)

        surface.SetDrawColor(0, 166, 36, 255)
        surface.DrawRect(x + 2, y + 2, fillWidth, barHeight - 4)

        surface.SetFont("DermaDefault")
        local text = percentage .. "%"
        local textW, textH = surface.GetTextSize(text)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(x + (barWidth - textW) / 2, y + (barHeight - textH) / 2)
        surface.DrawText(text)
    end

    hook.Add("HUDPaint", "DrawProgressBar", function()
        if not clientGatherData then return end

        local gatherData = clientGatherData
        DrawProgressBar(gatherData.progress or 0)

        if not IsValid(gatherData.entity) or
           CurTime() - gatherData.lastUpdate > 5 then
            clientGatherData = nil
        end
    end)
end

-- ============================================================
-- Helpers
-- ============================================================

-- Returns true if the player's currently active weapon satisfies
-- this node's Requires list (or if no list is set).
function ENT:PlayerHasRequiredWeapon(ply)
    if not self.Requires or #self.Requires == 0 then return true end

    local activeWeapon = ply:GetActiveWeapon()
    if not IsValid(activeWeapon) then return false end

    local activeClass = activeWeapon:GetClass()
    for _, requiredClass in ipairs(self.Requires) do
        if activeClass == requiredClass then return true end
    end

    return false
end

-- Builds a human-readable list of required weapon PrintNames (falls back
-- to classnames if the weapon data isn't registered).
function ENT:RequiredWeaponNames()
    if not self.Requires or #self.Requires == 0 then return "" end

    local names = {}
    for _, cls in ipairs(self.Requires) do
        local wepData = weapons and weapons.Get and weapons.Get(cls)
        table.insert(names, (wepData and wepData.PrintName) or cls)
    end

    return table.concat(names, " or ")
end

-- ============================================================
-- NetworkVars — synced to clients automatically and reliably,
-- unlike SetNWBool which can lag behind entity spawn.
-- ============================================================

function ENT:SetupDataTables()
    -- Lets the client identify this as a resource node without needing
    -- to read server-only Lua fields like ResourceRegistration.
    self:NetworkVar("Bool", 0, "IsResourceNode")
    -- Tracks whether this node has been persisted to disk.
    self:NetworkVar("Bool", 1, "IsPersistent")
end

-- ============================================================
-- Entity lifecycle
-- ============================================================

function ENT:Initialize()
    local randomModel = self.PossibleModels[math.random(#self.PossibleModels)]

    self:SetModel(randomModel)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    self.LastUseTime = 0

    self.PlayerCooldowns = {}
    self.ActiveGatherers = {}

    -- NetworkVars are set here after Spawn; they are guaranteed to reach
    -- the client before any clientside code (like properties Filter) reads them.
    self:SetIsResourceNode(true)
    self:SetIsPersistent(self.Persistent or false)

    local phys = self:GetPhysicsObject()
    if phys:IsValid() then
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

    if SERVER then
        -- Required weapon check
        if not self:PlayerHasRequiredWeapon(activator) then
            activator:ChatPrint("You need to have " ..
                self:RequiredWeaponNames() .. " equipped to gather this!")
            return
        end

        -- Already gathering check
        if self:IsPlayerGathering(activator) then
            activator:ChatPrint("You are already gathering from this!")
            return
        end

        -- Cooldown check
        if self:IsPlayerOnCooldown(activator) then
            local remaining = math.ceil(self:GetPlayerCooldownRemaining(activator))
            activator:ChatPrint("You must wait " .. remaining ..
                " seconds before gathering this again!")
            return
        end

        -- Inventory validity check
        if not PickUpResourceValidity(activator, self.SlotType,
                                      self.ResourceRegistration, 1) then
            return
        end

        self:StartGathering(activator)
    end
end

-- ============================================================
-- Cooldown helpers
-- ============================================================

function ENT:GetPlayerCooldownRemaining(ply)
    local steamID    = ply:SteamID()
    local cooldownEnd = self.PlayerCooldowns[steamID]
    if not cooldownEnd then return 0 end
    return math.max(0, cooldownEnd - CurTime())
end

function ENT:SetPlayerCooldown(ply)
    local steamID = ply:SteamID()
    self.PlayerCooldowns[steamID] = CurTime() + self.PlayerCooldown

    -- Prune expired entries to prevent memory bloat
    for id, endTime in pairs(self.PlayerCooldowns) do
        if CurTime() > endTime then self.PlayerCooldowns[id] = nil end
    end
end

function ENT:GetActiveGatherers() return self.ActiveGatherers end

function ENT:IsPlayerGathering(ply)
    return self.ActiveGatherers[ply:SteamID()] ~= nil
end

function ENT:IsPlayerOnCooldown(ply)
    local steamID    = ply:SteamID()
    local cooldownEnd = self.PlayerCooldowns[steamID]
    if not cooldownEnd then return false end
    return CurTime() < cooldownEnd
end

-- ============================================================
-- Gathering state machine
-- ============================================================

function ENT:StartGathering(ply)
    local steamID = ply:SteamID()

    self.ActiveGatherers[steamID] = {
        player    = ply,
        startTime = CurTime(),
        progress  = 0
    }

    if SERVER then
        ply:ChatPrint("Started gathering " .. (self.ResourceRegistration or "resources") .. "...")
        net.Start("GatherStart")
        net.WriteEntity(self)
        net.Send(ply)
    end
end

function ENT:CancelGathering(ply, reason)
    local steamID = ply:SteamID()

    if self.ActiveGatherers[steamID] then
        if IsValid(ply) and SERVER then
            local msg = reason or "Gathering cancelled!"
            ply:ChatPrint(msg)
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
        AddResourceToPlayer(ply, self.ResourceRegistration, self.SlotAmount)
        self:SetPlayerCooldown(ply)
        self:EmitSound("physics/wood/wood_solid_impact_hard" ..
                           math.random(1, 3) .. ".wav")
        net.Start("GatherEnd")
        net.WriteEntity(self)
        net.Send(ply)
    end

    self.ActiveGatherers[steamID] = nil
end

-- ============================================================
-- Think: validate each active gatherer every 0.1 s
-- ============================================================

function ENT:Think()
    if not self.ActiveGatherers or table.IsEmpty(self.ActiveGatherers) then
        return
    end

    for steamID, gatherData in pairs(self.ActiveGatherers) do
        local ply            = gatherData.player
        local shouldContinue = false  -- set true to skip to next gatherer

        -- 1. Player no longer valid or dead
        if not IsValid(ply) or not ply:Alive() then
            self.ActiveGatherers[steamID] = nil
            shouldContinue = true
        end

        -- 2. Player moved too far away
        if not shouldContinue then
            if ply:GetPos():Distance(self:GetPos()) > self.GatherRange then
                self:CancelGathering(ply, "You moved too far away!")
                shouldContinue = true
            end
        end

        -- 3. Required weapon was unequipped mid-gather
        if not shouldContinue and self.Requires and #self.Requires > 0 then
            if not self:PlayerHasRequiredWeapon(ply) then
                self:CancelGathering(ply,
                    "You put away your " .. self:RequiredWeaponNames() ..
                    "! Gathering cancelled.")
                shouldContinue = true
            end
        end

        -- 4. Player stopped looking at the node
        if not shouldContinue then
            local trace = ply:GetEyeTrace()
            if not IsValid(trace.Entity) or trace.Entity ~= self then
                local dir   = (self:GetPos() - ply:GetShootPos()):GetNormalized()
                local dot   = ply:GetAimVector():Dot(dir)
                local angle = math.deg(math.acos(math.Clamp(dot, -1, 1)))

                if angle > self.MaxLookAngle then
                    self:CancelGathering(ply, "You looked away!")
                    shouldContinue = true
                end
            end
        end

        -- 5. Update progress and check for completion
        if not shouldContinue then
            local elapsed  = CurTime() - gatherData.startTime
            local progress = math.Clamp(elapsed / self.GatherTime, 0, 1)
            gatherData.progress = progress

            if SERVER then
                net.Start("GatherProgress")
                net.WriteEntity(self)
                net.WriteFloat(progress)
                net.Send(ply)
            end

            if progress >= 1 then
                self:CompleteGathering(ply)
            end
        end
    end

    self:NextThink(CurTime() + 0.1)
    return true
end

scripted_ents.Register(ENT, "base_resnode")