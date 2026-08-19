AddCSLuaFile()

include("autorun/buffs_manager.lua")


ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Counterstrike"
ENT.BuffRegistration = "Counterstrike"
ENT.BuffType = "permabuffs"
ENT.Description = "25% chance to counterattack against physical attacks for 20 almighty damage."
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

    targetBuffsTable["Counterstrike"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_counterstrike"
    }

    AssignStat(activator, "Counterstrike", targetBuffsTable["Counterstrike"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_counterstrike")
