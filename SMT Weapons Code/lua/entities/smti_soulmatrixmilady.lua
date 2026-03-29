AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Soul Matrix Milady"
ENT.BuffRegistration = "Soul_Matrix_Milady"
ENT.BuffType = "permabuffs"
ENT.Description =
    "[STR 5] Base Technique increases to 65, but lowers Luck by 1. \n[DEX 5] Sukukajas directed at Milady will reduce her Sukunda count (if any) by 1. \n[CHR 5] Casting Fire spells heals Milady by 6 HP."
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

    targetBuffsTable["Soul_Matrix_Milady"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_soulmatrixmilady"
    }

    AssignStat(activator, "Soul_Matrix_Milady",
               targetBuffsTable["Soul_Matrix_Milady"], "permabuffs")

    local targetDebuffsTable = {}

    targetDebuffsTable["Soul_Matrix_Milady"] = {stacks = 1, visibility = 0}

    AssignStat(activator, "Soul_Matrix_Milady",
               targetDebuffsTable["Soul_Matrix_Milady"], "permadebuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1
    self:Remove()
end

scripted_ents.Register(ENT, "smti_soulmatrixmilady")
