AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Alchemist Table"
ENT.Author = "Nara"
ENT.Category = "Crafting Stations"
ENT.Description = "A workbench for brewing potions and crafting alchemical reagents."
ENT.RequiredProfession = "Alchemy"
ENT.ShowInfo = true
ENT.Spawnable = true
ENT.AdminOnly = false
ENT.Model = "models/props_c17/FurnitureTable001a.mdl"


function ENT:Initialize()
    if SERVER then
        self:SetModel(self.Model)
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_NONE)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:Wake()
        end
    end
end

function ENT:GetPlayerProfession(ply)
    if not IsValid(ply) or not ply:IsPlayer() then
        return ""
    end

    if SMT_GetPlayerProfession and type(SMT_GetPlayerProfession) == "function" then
        return SMT_GetPlayerProfession(ply)
    end

    return ply:GetNWString("Profession", "")
end

function ENT:CanPlayerUse(ply)
    local profession = self:GetPlayerProfession(ply)
    return profession == self.RequiredProfession or profession == "Genius"
end

function ENT:Use(activator, caller)
    if not IsValid(activator) or not activator:IsPlayer() then
        return
    end

    if not self:CanPlayerUse(activator) then
        activator:ChatPrint("You cannot interact with this. You must be " ..
            self.RequiredProfession .. " or Genius.")
        return
    end

    if SERVER then
        local knowledge = {}
        if GetPlayerKnowledge then
            knowledge = GetPlayerKnowledge(activator:SteamID()) or {}
        end

        net.Start("OpenCraftingStationMenu")
        net.WriteEntity(self)
        net.WriteString(self.PrintName or self:GetClass())
        net.WriteString(self.RequiredProfession or "Alchemy")
        net.WriteTable(knowledge)
        net.Send(activator)
    end
end

scripted_ents.Register(ENT, "rs_alchemist_table")
