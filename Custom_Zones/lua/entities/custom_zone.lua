AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Custom Zone"
ENT.Author = "Nara"
ENT.Category = "Special Entities"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Model = "models/hunter/blocks/cube025x025x025.mdl"
ENT.CustomTitle = "Zone"
ENT.ZoneMusic = ""

if not ENT.EffectRadius then ENT.EffectRadius = Vector(100, 100, 100) end

function ENT:Initialize()
    self:SetModel("models/hunter/blocks/cube025x025x025.mdl")
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_WORLD)
    self:SetSolid(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetAngles(Angle(0, 0, 0))
    self:Activate()

    self:DrawShadow(false)

    local phys = self:GetPhysicsObject()

    self:CreateTrigger()

    if (IsValid(phys)) then
        phys:EnableGravity(true)
        phys:EnableMotion(false) -- Disable motion so angles don’t change
        phys:Wake()
    end
end

function ENT:CreateTrigger()
    if IsValid(self.Trigger) then self.Trigger:Remove() end

    if SERVER then
        self.Trigger = ents.Create("zone_trigger")
        self.Trigger:SetParent(self)
        self.Trigger:SetPos(self:GetPos())
        self.Trigger:SetAngles(self:GetAngles())
        self.Trigger.EffectRadius = self.EffectRadius
        self.Trigger.CustomTitle = self.CustomTitle
        self.Trigger.ZoneMusic = self.ZoneMusic
        self.Trigger:Spawn()

        function self.Trigger:StartTouch(ent)
            if ent:IsPlayer() then
                net.Start("ZoneEntered")
                net.WriteString(self.CustomTitle)
                net.WriteString(self.ZoneMusic)
                net.Send(ent)

                -- ent:ChatPrint("You have entered " .. self.CustomTitle)
            end
        end

        function self.Trigger:EndTouch(ent)
            if ent:IsPlayer() then
                -- net.Start("ZoneExit")
                -- net.WriteString(self.CustomTitle)
                -- net.WriteString(self.ZoneMusic)
                -- net.Send(ent)

            end
        end
    end
end

function ENT:Draw()
    local player = LocalPlayer()
    if IsValid(player) then
        if player:Alive() and player:IsAdmin() then
            local weapon = player:GetActiveWeapon()
            if IsValid(weapon) and
                (weapon:GetClass() == "weapon_physgun" or weapon:GetClass() ==
                    "gmod_tool") then
                self:DrawModel()

                local min = -self.EffectRadius
                local max = self.EffectRadius

                -- Render the bounds
                render.SetColorMaterial()
                render.DrawWireframeBox(self:GetPos(), Angle(0, 0, 0), min, max,
                                        Color(0, 255, 0), false)
            end
        end
    end
end

scripted_ents.Register(ENT, "custom_zone")
