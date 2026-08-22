-- Color-coded targeting reticle: blue for your fight side, green for
-- anyone not sharing a fight with you, red for the opposing side.
-- Fed by TBC_MyFightSides, networked from TBC_FightSideSync in
-- autorun/tbc_weapon_metatable.lua. Only draws while holding a weapon whose
-- class starts with "smti_". AOE weapons (SWEP.Targets == "aoe") highlight
-- everyone on the crosshair target's side. SWEP.PrimarySelfOnly weapons
-- (Guard, Tag, etc. - primary always casts on the caster, no secondary
-- fire at all) always highlight the local player. SWEP.FallsBackToSelf
-- weapons (most buffs/heals, e.g. Tarukaja) mirror what PrimaryAttack
-- itself does now that its secondary-fire self-cast was folded in: trace
-- normally, and highlight self only when the trace finds nothing.
-- Everything else highlights just the crosshair target.

local TRACE_RANGE = 250
local HULL_SIZE = 15

local COLOR_ALLY = Color(80, 160, 255, 255)
local COLOR_NEUTRAL = Color(90, 230, 120, 255)
local COLOR_ENEMY = Color(255, 70, 70, 255)

surface.CreateFont(
    "TBC_TargetReticleFont",
    {
        font = "Roboto",
        size = 14,
        weight = 700,
        antialias = true
    }
)

local function GetFightSideOf(ent)
    if not IsValid(ent) then
        return nil
    end

    for _, member in ipairs(TBC_MyFightSides.Side1) do
        if member == ent then
            return "Side1"
        end
    end

    for _, member in ipairs(TBC_MyFightSides.Side2) do
        if member == ent then
            return "Side2"
        end
    end

    return nil
end

local function GetRelationship(ent)
    local mySide = GetFightSideOf(LocalPlayer())
    if not mySide then
        return "neutral"
    end

    local entSide = GetFightSideOf(ent)
    if not entSide then
        return "neutral"
    end

    if entSide == mySide then
        return "ally"
    end

    return "enemy"
end

local function GetRelationshipColor(relationship)
    if relationship == "ally" then
        return COLOR_ALLY
    end

    if relationship == "enemy" then
        return COLOR_ENEMY
    end

    return COLOR_NEUTRAL
end

-- Mirrors the trace every smti_ weapon uses to find its target (250 range,
-- a 20-unit forgiveness hull), so the reticle shows exactly what clicking
-- would actually hit.
local function TraceCrosshairTarget()
    local ply = LocalPlayer()
    if not IsValid(ply) then
        return nil
    end

    local shootPos = ply:EyePos()
    local shootEnd = shootPos + ply:EyeAngles():Forward() * TRACE_RANGE
    local half = Vector(1, 1, 1) * HULL_SIZE

    local tr = util.TraceHull(
        {
            start = shootPos,
            endpos = shootEnd,
            filter = ply,
            mask = MASK_SHOT_HULL,
            mins = -half,
            maxs = half
        }
    )

    if IsValid(tr.Entity) and CheckIfValidTBCEntity(tr.Entity) then
        return tr.Entity
    end

    return nil
end

local function IsSmtiWeapon(wep)
    return IsValid(wep) and string.sub(wep:GetClass(), 1, 5) == "smti_"
end

local function GetReticleTargets()
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if not IsSmtiWeapon(wep) then
        return {}
    end

    -- Guard, Tag, etc.: primary always casts on the caster, no trace at all.
    if wep.PrimarySelfOnly then
        return {ply}
    end

    local targets = {}
    local anchor = TraceCrosshairTarget()
    if not IsValid(anchor) then
        -- FallsBackToSelf weapons (most buffs/heals) do exactly this in
        -- PrimaryAttack now: nothing under the crosshair means self-cast.
        if wep.FallsBackToSelf then
            table.insert(targets, ply)
        end
        return targets
    end

    if wep.Targets == "aoe" then
        local side = GetFightSideOf(anchor)
        if side then
            for _, member in ipairs(TBC_MyFightSides[side]) do
                if IsValid(member) then
                    table.insert(targets, member)
                end
            end
            return targets
        end
    end

    table.insert(targets, anchor)
    return targets
end

local function DrawBracket(ent, color)
    local mins, maxs = ent:GetRenderBounds()
    local topWorld = ent:LocalToWorld(Vector(0, 0, maxs.z))
    local bottomWorld = ent:LocalToWorld(Vector(0, 0, mins.z))

    local topScreen = topWorld:ToScreen()
    local bottomScreen = bottomWorld:ToScreen()

    if not topScreen.visible and not bottomScreen.visible then
        return
    end

    local centerX = (topScreen.x + bottomScreen.x) * 0.5
    local height = math.abs(bottomScreen.y - topScreen.y)
    if height < 4 then
        return
    end

    local width = height * 0.55
    local x, y = centerX - width * 0.5, topScreen.y
    local armLen = math.Clamp(math.min(width, height) * 0.28, 4, 18)

    surface.SetDrawColor(color)

    -- top-left
    surface.DrawLine(x, y, x + armLen, y)
    surface.DrawLine(x, y, x, y + armLen)
    -- top-right
    surface.DrawLine(x + width, y, x + width - armLen, y)
    surface.DrawLine(x + width, y, x + width, y + armLen)
    -- bottom-left
    surface.DrawLine(x, y + height, x + armLen, y + height)
    surface.DrawLine(x, y + height, x, y + height - armLen)
    -- bottom-right
    surface.DrawLine(x + width, y + height, x + width - armLen, y + height)
    surface.DrawLine(x + width, y + height, x + width, y + height - armLen)

    draw.SimpleTextOutlined(
        "TARGET",
        "TBC_TargetReticleFont",
        centerX,
        y + height + 4,
        color,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP,
        1,
        Color(0, 0, 0, 200)
    )
end

hook.Add(
    "HUDPaint",
    "TBC_DrawTargetReticles",
    function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then
            return
        end

        -- ply can legitimately appear here now (PrimarySelfOnly/SecondarySelfOnly
        -- weapons highlight the caster), so it's not filtered out anymore.
        local targets = GetReticleTargets()
        for _, ent in ipairs(targets) do
            if IsValid(ent) then
                DrawBracket(ent, GetRelationshipColor(GetRelationship(ent)))
            end
        end
    end
)
