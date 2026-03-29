AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Icy Glare"
ENT.BuffRegistration = "Icy_Glare"
ENT.BuffType = "permabuffs"
ENT.Description =
    "If at least one enemy in combat resists ailments, ailment infliction is increased by 5% for Haru's party. Against bosses, when Haru applies an ailment when they resist it instead pops for 30 almighty damage."
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

    targetBuffsTable["Icy_Glare"] = {
        stacks = 1,
        targets = "party",
        caster = ply:UserID(),
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_icyglare"
    }

    AssignStat(activator, "Icy_Glare", targetBuffsTable["Icy_Glare"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1
    self:Remove()
end

scripted_ents.Register(ENT, "smti_icyglare")
