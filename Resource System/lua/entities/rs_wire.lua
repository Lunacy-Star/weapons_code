AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Wire"
ENT.ResourceRegistration = "wire"
ENT.Description = "Small piece of wire"
ENT.Author = "Nara"
ENT.Category = "Crafting Resources"
ENT.SlotAmount = 1
ENT.SlotType = "Resources"
ENT.ShowInfo = true
ENT.PossibleModels = {
    "models/Gibs/HGIBS.mdl", "models/Gibs/HGIBS_rib.mdl",
    "models/Gibs/HGIBS_spine.mdl"
}

ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    local randomModel = self.PossibleModels[math.random(#self.PossibleModels)]

    self:SetModel(randomModel)
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

    if not IsValid(activator) or not activator:IsPlayer() then return end

    if not PickUpResourceValidity(activator, self.SlotType, self.ResourceRegistration, self.SlotAmount) then
        return false
    end

    AddResourceToPlayer(activator, self.ResourceRegistration, self.SlotAmount)

    self:Remove()
end

scripted_ents.Register(ENT, "rs_wire")
