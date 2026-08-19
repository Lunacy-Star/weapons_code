AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Orobas"
ENT.Description =
    "One of the 72 demons of the Goetia. Known as the Prince of Hell, he appears as a horse and answers questions of the past, present, and future. He is faithful to his conjurer."
ENT.Author = "Nara"
ENT.Category = "Personas"
ENT.SlotsTaking = 1
ENT.SlotType = "Persona"

ENT.Spawnable = true
ENT.AdminOnly = false

function ENT:Initialize()
    self:SetModel("models/props_junk/PopCan01a.mdl")
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

    local ply = activator

    local PersonaSlotsAvailable = 0

    local personas = GetAllStats(ply, "personas")
    if personas then
        if personas["persona_orobas"] then
            ply:ChatPrint("You can't pick up a persona you already have!")
            return false
        end

        for personaName, personaInfo in pairs(personas) do
            PersonaSlotsAvailable = PersonaSlotsAvailable + 1
        end
    end

    if PersonaSlotsAvailable >= 3 then
        ply:ChatPrint("You've reached your inventory Persona slots!")
        return false
    end

    AssignStat(ply, "persona_orobas", "persona_orobas", "personas")

    ply:ChatPrint("You've picked up " .. self.PrintName .. "!")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "persona_orobas")
