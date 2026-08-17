AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Sudama"
ENT.Description =
    "A spirit of rivers and mountains in Japanese lore, they dwell in ancient trees and ageless rocks. They are not evil, and will often appear as humans or supernatural wonders to warn people."
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
        if personas["persona_sudama"] then
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

    AssignStat(ply, "persona_sudama", "persona_sudama", "personas")

    ply:ChatPrint("You've picked up " .. self.PrintName .. "!")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "persona_sudama")
