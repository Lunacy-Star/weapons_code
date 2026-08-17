AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Songbird's Obituary"
ENT.BuffRegistration = "Songbird_Obituary"
ENT.BuffType = "permabuffs"
ENT.Description = "When Hua Po dies and is the only Hua Po in the party, her party gains Rakukaja +3 and is cured of all ailments. Effect becomes Rakukaja +1 and ailment cure if more than one Hua Po is present in the party."
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

    targetBuffsTable["Songbird_Obituary"] = {
        stacks = 1,
        type = "onDeath",
        SlotsTaking = 1,
        visibility = 0,
        SlotType = "Equipment",
        ClassName = "smti_songbirdsobituary"
    }

    AssignStat(activator, "Songbird_Obituary", targetBuffsTable["Songbird_Obituary"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_songbirdsobituary")
