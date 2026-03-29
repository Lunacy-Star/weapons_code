-- This file only handles the HUD proximity prompt.

include("shared.lua")

local INTERACT_DIST = 90
local FACE_DOT      = 0.4

hook.Add("HUDPaint", "DialogueProximityHUD", function()
    local ply = LocalPlayer()
    if not IsValid(ply) then return end

    local plyPos = ply:EyePos()
    local plyFwd = ply:EyeAngles():Forward()
    local closest, closestDist = nil, INTERACT_DIST

    for _, ent in ipairs(ents.FindByClass("dialogue")) do
        if not IsValid(ent) then continue end
        local dist = ply:GetPos():Distance(ent:GetPos())
        if dist < closestDist then
            local toEnt = (ent:GetPos() - plyPos):GetNormalized()
            if plyFwd:Dot(toEnt) >= FACE_DOT then
                local tr = util.TraceLine({
                    start  = plyPos,
                    endpos = ent:GetPos() + Vector(0, 0, 40),
                    filter = { ply, ent },
                    mask   = MASK_SOLID_BRUSHONLY,
                })
                if not tr.Hit then
                    closestDist = dist
                    closest     = ent
                end
            end
        end
    end

    if not closest then return end

    local name = closest:GetNWString("DialogueName", "???")
    local desc = closest:GetNWString("DialogueDesc",  "")
    local sw, sh = ScrW(), ScrH()

    draw.SimpleText(name, "DermaLarge", sw/2+1, sh*0.72+1, Color(0,0,0,200),       TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    draw.SimpleText(name, "DermaLarge", sw/2,   sh*0.72,   Color(255,255,255,235), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

    if desc ~= "" then
        draw.SimpleText(desc, "DermaDefault", sw/2+1, sh*0.72+26, Color(0,0,0,180),       TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        draw.SimpleText(desc, "DermaDefault", sw/2,   sh*0.72+25, Color(200,200,200,220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local eY = desc ~= "" and sh*0.72+50 or sh*0.72+32
    draw.SimpleText("[Press E to talk]", "DermaDefault", sw/2, eY, Color(180,200,255,200), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end)
