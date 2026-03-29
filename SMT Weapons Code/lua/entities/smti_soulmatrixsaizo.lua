AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Soul Matrix Saizo"
ENT.BuffRegistration = "Soul_Matrix_Saizo"
ENT.BuffType = "permabuffs"
ENT.Description =
    "[STR 5] Casting Force spells heals Saizo by 6 HP. \n[DEX 5] +5 Technique for all Force skills used by Saizo. \n[CHR 5] Healing or buffing allies grants Saizo 1 Tarukaja."
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

    targetBuffsTable["Soul_Matrix_Saizo"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_soulmatrixsaizo"
    }

    AssignStat(activator, "Soul_Matrix_Saizo",
               targetBuffsTable["Soul_Matrix_Saizo"], "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1
    self:Remove()
end

scripted_ents.Register(ENT, "smti_soulmatrixsaizo")
