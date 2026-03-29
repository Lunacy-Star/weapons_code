ENT.Base                 = "base_anim"
ENT.Type                 = "anim"
ENT.PrintName            = "Dialogue NPC"
ENT.Author               = "Nara"
ENT.Category             = "Special Entities"
ENT.Spawnable            = true
ENT.AdminOnly            = false
ENT.Model                = "models/kleiner.mdl"
ENT.RenderGroup          = RENDERGROUP_OPAQUE
ENT.AutomaticFrameAdvance = true

function ENT:SpawnFunction(ply, tr, className)
    if not tr.Hit then return end
    local ent = ents.Create(className)
    ent:SetPos(tr.HitPos + tr.HitNormal)
    ent:SetAngles(Angle(0, ply:EyeAngles().y + 180, 0))
    ent:Spawn()
    ent:Activate()
    return ent
end
