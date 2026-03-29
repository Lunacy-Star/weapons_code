AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Devotion of Rebuttal"
ENT.BuffRegistration = "Devotion_of_Rebuttal"
ENT.BuffType = "permabuffs"
ENT.Description =
    "All damage that exceeds 25% of Yukimi's Max HP will have its value reduced to 25% of Yukimi's Max HP. This does not trigger against instakills."
ENT.Author = "Nara"
ENT.Category = "SMT Imagine Passives"
ENT.SlotsTaking = 1
ENT.SlotType = "Equipment"
ENT.Rarity = "Exclusive"

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

    targetBuffsTable["Devotion_of_Rebuttal"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_devotionofrebuttal"
    }

    AssignStat(activator, "Devotion_of_Rebuttal",
               targetBuffsTable["Devotion_of_Rebuttal"], "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_devotionofrebuttal")
