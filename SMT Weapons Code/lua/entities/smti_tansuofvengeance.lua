AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Tansu of Vengeance"
ENT.BuffRegistration = "Tansu_of_Vengeance"
ENT.BuffType = "permabuffs"
ENT.Description = 'If an ally is dead, Inugami gains +1 Tarukaja at the start of its turns. If all allies are dead (or 4 allies are dead), Inugami gains +4 Tarukaja and is cleansed of Tarunda at the start of its turns for the rest of the fight. Effect goes away if allies revive accordingly. If Inugami started the fight alone, the effect is simplified to "gain +1 Tarukaja at the start of its turns."'
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

    targetBuffsTable["Tansu_of_Vengeance"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_tansuofvengeance"
    }

    AssignStat(activator, "Tansu_of_Vengeance", targetBuffsTable["Tansu_of_Vengeance"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1

    self:Remove()
end

scripted_ents.Register(ENT, "smti_tansuofvengeance")
