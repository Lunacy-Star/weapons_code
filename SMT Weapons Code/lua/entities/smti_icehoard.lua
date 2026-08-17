AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ice Hoard"
ENT.BuffRegistration = "Ice_Hoard"
ENT.BuffType = "permabuffs"
ENT.Description = "Petit Frost heals a flat bonus +20 HP when using curative spells on allies who resist/block/drain/repel Ice (This does not apply to Lydia). If no one aside from Petit Frost has a resistance to Ice in its party, Sukukaja +1 to self instead."
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

    targetBuffsTable["Ice_Hoard"] = {
        stacks = 1,
        SlotsTaking = 1,
        visibility = 0,
        SlotType = "Equipment",
        ClassName = "smti_icehoard"
    }

    AssignStat(activator, "Ice_Hoard", targetBuffsTable["Ice_Hoard"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_icehoard")
