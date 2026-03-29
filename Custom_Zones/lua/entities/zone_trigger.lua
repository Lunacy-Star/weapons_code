AddCSLuaFile()

ENT.Base = "base_gmodentity"
ENT.Type = "anim"
ENT.PrintName = "Zone Trigger"
ENT.Author = "Nara"
ENT.Spawnable = false
ENT.CustomTitle = "Zone"

function ENT:Initialize()
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
    self:SetSolid(SOLID_BBOX)
    self:SetMoveType(MOVETYPE_NONE)
    self:SetNoDraw(true)
    if SERVER then self:SetTrigger(true) end

    -- Set collision bounds
    local radius = self.EffectRadius or Vector(100, 100, 100)
    self:PhysicsInitBox(-radius, radius)
    self:SetCollisionBounds(-radius, radius)
end
