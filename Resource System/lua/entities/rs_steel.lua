AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Steel"
ENT.ResourceRegistration = "steel"
ENT.Description = "Small piece of steel"
ENT.Author = "Nara"
ENT.Category = "Crafting Resources"
ENT.SlotAmount = 1
ENT.SlotType = "Resources"
ENT.ShowInfo = true
ENT.PossibleModels = {
    "models/gibs/metal_gib1.mdl", "models/gibs/metal_gib2.mdl",
    "models/gibs/metal_gib3.mdl", "models/gibs/metal_gib4.mdl",
    "models/gibs/metal_gib5.mdl"
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

scripted_ents.Register(ENT, "rs_steel")
