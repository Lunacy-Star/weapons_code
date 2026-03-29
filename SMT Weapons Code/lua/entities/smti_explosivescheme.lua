AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Explosive Scheme"
ENT.BuffRegistration = "Explosive_Scheme"
ENT.BuffType = "permabuffs"
ENT.Description =
    "Futaba's curative spells have a 25% chance of curing ailments. When her current health reaches 66.6% of her hp (200 HP for default max HP), she loses the effect and gains +7 Luck as long as her HP is equal to or lower than the threshold. When her current health reaches 41.6% of her hp (125 HP for default max HP), all healing spells cast by Futaba are 20% stronger on her as long as her HP is equal to or lower than the threshold."
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

    targetBuffsTable["Explosive_Scheme"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_explosivescheme"
    }

    AssignStat(activator, "Explosive_Scheme", targetBuffsTable["Explosive_Scheme"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1
    self:Remove()
end

scripted_ents.Register(ENT, "smti_explosivescheme")
