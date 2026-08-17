AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Life Bonus"
ENT.BuffRegistration = "Life_Bonus"
ENT.BuffType = "permabuffs"
ENT.Description = "Increase Max HP by 50 while active."
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

    targetBuffsTable["Life_Bonus"] = {
        stacks = 1,
        maxHPBonus = 50,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_lifebonus"
    }

    AssignStat(activator, "Life_Bonus", targetBuffsTable["Life_Bonus"],
               "permabuffs")

    ApplyStatBoostBuff(activator, targetBuffsTable["Life_Bonus"])

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_lifebonus")
