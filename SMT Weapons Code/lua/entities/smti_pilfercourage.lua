AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Pilfer Courage"
ENT.BuffRegistration = "Pilfer_Courage"
ENT.BuffType = "permabuffs"
ENT.Description = "When Oni deals a fatal blow to a target that does not revive from an Endure effect, 30% chance to inflict Panic on enemy team combatants."
ENT.Author = "Nara"
ENT.Category = "SMT Imagine Passives"
ENT.SlotsTaking = 1
ENT.SlotType = "Equipment"

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

    if not PickUpEntityValidity(activator, self.SlotType) then return false end


    local targetBuffsTable = {}

    targetBuffsTable["Pilfer_Courage"] = {
        stacks = 1,
        type = "kill",
        SlotsTaking = 1,
        visibility = 0,
        SlotType = "Equipment",
        ClassName = "smti_pilfercourage"
    }

    AssignStat(activator, "Pilfer_Courage", targetBuffsTable["Pilfer_Courage"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_pilfercourage")
