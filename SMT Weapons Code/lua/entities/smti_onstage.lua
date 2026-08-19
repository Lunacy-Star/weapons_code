AddCSLuaFile()

include("autorun/buffs_manager.lua")


ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "On Stage"
ENT.BuffRegistration = "On_Stage"
ENT.BuffType = "permabuffs"
ENT.Description = "Whenever a party member critically strikes or lands a successful weakness strike, they heal for 20 HP and restore 10 SP."
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

    targetBuffsTable["On_Stage"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_onstage"
    }

    AssignStat(activator, "On_Stage", targetBuffsTable["On_Stage"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_onstage")
