AddCSLuaFile()

include("autorun/buffs_manager.lua")

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Gaia Pact"
ENT.BuffRegistration = "Gaia_Pact"
ENT.BuffType = "permabuffs"
ENT.Description =
    "Allies at 30% or below health redirect 40% of the damage they take to Makoto. This is disabled when Makoto herself is at 40% or below Health."
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

    targetBuffsTable["Gaia_Pact"] = {
        stacks = 1,
        targets = "party",
        caster = ply:UserID(),
        SlotsTaking = 1,
        SlotType = "Equipment",
        ClassName = "smti_gaiapact"
    }

    AssignStat(activator, "Gaia_Pact", targetBuffsTable["Gaia_Pact"],
               "permabuffs")

    self.CanUse = false
    self.NextUse = CurTime() + 1
    self:Remove()
end

scripted_ents.Register(ENT, "smti_gaiapact")
