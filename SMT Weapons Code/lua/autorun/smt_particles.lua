SMTParticles = SMTParticles or {}

SMTParticles.ParticleFile = "particles/smt_elements.pcf"

SMTParticles.Effects = {
    physical = "smt_phys_hit",
    physical_big = "smt_physbig_hit",
    fire = "smt_fire_hit",
    ice = "smt_ice_hit",
    electricity = "smt_elec_hit",
    wind = "smt_wind_hit",
    nuke = "smt_nuke_hit",
    ruin = "smt_ruin_hit",
    dark = "smt_dark_hit",
    light = "smt_light_hit",
    buff = "smt_buff_hit",
    debuff = "smt_debuff_hit",
    support = "smt_support_hit"
}

SMTParticles.EffectOrder = {
    "physical",
    "physical_big",
    "fire",
    "ice",
    "electricity",
    "wind",
    "nuke",
    "ruin",
    "dark",
    "light",
    "buff",
    "debuff",
    "support"
}

SMTParticles.Materials = {
    "aura",
    "dark_aura",
    "dark_star",
    "darkring",
    "flame",
    "ice_shard",
    "impact_star",
    "impact_star2",
    "lightning_fork",
    "ring",
    "softglow",
    "streak",
    "tar",
    "tar2",
    "wind_crescent"
}

function SMTParticles.GetEffect(name)
    if not isstring(name) then return nil end

    local requestedName = string.lower(name)
    local mappedName = SMTParticles.Effects[requestedName]

    if mappedName then return mappedName end

    for _, effectName in pairs(SMTParticles.Effects) do
        if requestedName == effectName then
            return effectName
        end
    end

    return nil
end

-- Maps SWEP.Affinity (set by every smti_ weapon) to the hit effect that
-- should play on a target when that weapon is used against them.
-- Almighty/Dual (unresistable/dual-element skills) fall back to the bigger
-- physical impact since they don't have a dedicated element of their own.
SMTParticles.AffinityEffects = {
    Blade = "physical",
    Blunt = "physical",
    ["Martial Arts"] = "physical",
    Gun = "physical",
    Bow = "physical",
    Throw = "physical",
    Physical = "physical",
    Almighty = "physical_big",
    Dual = "physical_big",
    Fire = "fire",
    Ice = "ice",
    Elec = "electricity",
    Force = "wind",
    Nuke = "nuke",
    Ruin = "ruin",
    Dark = "dark",
    Light = "light",
    Support = "support"
}

-- Resolves a weapon's Affinity straight to a precached particle system name.
function SMTParticles.GetEffectForAffinity(affinity)
    if not isstring(affinity) then return nil end

    local effectKey = SMTParticles.AffinityEffects[affinity]
    if not effectKey then return nil end

    return SMTParticles.Effects[effectKey]
end

if SERVER then
    util.AddNetworkString("SMTParticleHit")
end

-- Plays `particleName` attached to `target`, networked to everyone who can
-- see them. Called from the shared TBC validity checks so it fires whenever
-- an ability legitimately goes off on a target - independent of whether the
-- attacker's hit roll afterward succeeds or misses.
function SMTParticles.PlayOnTarget(target, particleName)
    if not SERVER then return end
    if not IsValid(target) or not isstring(particleName) then return end

    net.Start("SMTParticleHit")
    net.WriteEntity(target)
    net.WriteString(particleName)
    net.SendPVS(target:GetPos())
end

-- Convenience wrapper: resolves `weapon.Affinity` and plays the matching
-- effect on `target`. No-ops quietly for weapons with no mapped Affinity
-- (utility SWEPs like the Engage SWEP), so it's safe to call unconditionally.
function SMTParticles.TriggerForWeapon(weapon, target)
    if not SERVER then return end
    if not IsValid(weapon) or not IsValid(target) then return end

    local particleName = SMTParticles.GetEffectForAffinity(weapon.Affinity)
    if not particleName then return end

    SMTParticles.PlayOnTarget(target, particleName)
end

if CLIENT then
    net.Receive("SMTParticleHit", function()
        local target = net.ReadEntity()
        local particleName = net.ReadString()

        if not IsValid(target) or not isstring(particleName) or particleName == "" then
            return
        end

        CreateParticleSystem(target, particleName, PATTACH_ABSORIGIN_FOLLOW, 0, target:OBBCenter())
    end)
end

game.AddParticles(SMTParticles.ParticleFile)

for _, effectKey in ipairs(SMTParticles.EffectOrder) do
    PrecacheParticleSystem(SMTParticles.Effects[effectKey])
end

if SERVER then
    resource.AddFile(SMTParticles.ParticleFile)

    for _, materialName in ipairs(SMTParticles.Materials) do
        -- Each VMT has a same-named VTF, which resource.AddFile includes.
        resource.AddFile("materials/smt_particles/" .. materialName .. ".vmt")
    end
end

if CLIENT then
    local function PrintTestHelp()
        MsgC(Color(90, 220, 255), "[SMT Particles] ", color_white,
            "Usage: smt_particle_test <effect>\n")
        MsgC(Color(90, 220, 255), "[SMT Particles] ", color_white,
            "Effects: " .. table.concat(SMTParticles.EffectOrder, ", ") .. "\n")
    end

    concommand.Add("smt_particle_test", function(_, _, args)
        local effectName = SMTParticles.GetEffect(args[1])

        if not effectName then
            PrintTestHelp()
            return
        end

        local ply = LocalPlayer()
        if not IsValid(ply) then return end

        local trace = ply:GetEyeTrace()
        local hitNormal = trace.HitNormal

        CreateParticleSystemNoEntity(
            effectName,
            trace.HitPos + hitNormal * 2,
            hitNormal:Angle()
        )
    end, nil, "Spawns an SMT hit effect where you are looking.")
end
