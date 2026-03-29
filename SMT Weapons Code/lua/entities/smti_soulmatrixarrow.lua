AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Soul Matrix Arrow"
ENT.BuffRegistration = "Soul_Matrix_Arrow"
ENT.BuffType = "permabuffs"
ENT.Description =
    "[STR 5] Tarukajas directed to Arrow heal him by 6 HP. \n[DEX 5] Casting Ice spells heals Arrow by 6 HP. \n[CHR 5] Receiving 60 damage or more in a single attack applies 1 Rakukaja to Arrow."
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

    targetBuffsTable["Soul_Matrix_Arrow"] = {
        stacks = 1,
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_soulmatrixarrow"
    }

    AssignStat(activator, "Soul_Matrix_Arrow",
               targetBuffsTable["Soul_Matrix_Arrow"], "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1
    self:Remove()
end

scripted_ents.Register(ENT, "smti_soulmatrixarrow")
