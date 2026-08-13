-- Demon Companion System - Shared configuration
-- Demons are defined by their entries in CHARACTERS.List (characters_data.lua).
-- Any character with type == "Demon" can be granted to a player as a companion.

DEMONCOMP = DEMONCOMP or {}

-- How many demons a player can hold in their party at once
DEMONCOMP.MaxPartySize = 3

-- Follower behaviour tuning
DEMONCOMP.FollowDistance = 80 -- stops approaching the master at this distance
DEMONCOMP.MoveSpeed = 190 -- units per second while walking
DEMONCOMP.TeleportDistance = 1200 -- teleports to the master if further than this while following
DEMONCOMP.ArriveDistance = 24 -- "close enough" for move-to orders

-- Animation sequences tried in order per state. Multiple entries per state:
-- every time the demon enters that state one VALID sequence is picked at
-- random, so models with several idle/attack/hurt animations get variety.
-- Add a table keyed by the character id to override for a specific demon.
DEMONCOMP.Animations = {
    _default = {
        idle = {
            "idle_all_02", "idle_all_01", "idle01", "idle02", "idle",
            "idle_subtle", "batidle"
        },
        walk = {"walk_all", "walk_all_moderate", "walk01", "walk", "run_all", "run"},
        attack = {
            "attackstand", "melee_attack01", "melee_attack02", "attack01",
            "attack02", "range_attack_pistol", "range_attack01", "swing",
            "throwitem", "attack"
        },
        hurt = {
            "flinch_phys_01", "flinch_phys_02", "flinch_back_01",
            "flinch_stomach_01", "physflinch01", "flinch01", "flinch",
            "smallflinch"
        }
    }

    -- Example per-demon override (uses the CHARACTERS.List key):
    -- ["jack_frost_a"] = {
    --     idle = {"jf_idle1", "jf_idle2"},
    --     walk = {"jf_walk"},
    --     attack = {"jf_bufu", "jf_kick"},
    --     hurt = {"jf_flinch"}
    -- }
}

-- Returns the animation config for a demon character id, falling back to defaults
function DEMONCOMP.GetAnims(charId)
    local override = DEMONCOMP.Animations[charId]
    local default = DEMONCOMP.Animations._default
    if not override then return default end

    return {
        idle = override.idle or default.idle,
        walk = override.walk or default.walk,
        attack = override.attack or default.attack,
        hurt = override.hurt or default.hurt
    }
end

-- Returns charData from CHARACTERS.List if it is a valid demon character.
-- Resolved at call time because characters_data.lua may load after this file.
function DEMONCOMP.GetCharData(charId)
    if not CHARACTERS or not CHARACTERS.List then return nil end
    local charData = CHARACTERS.List[charId]
    if not charData then return nil end
    return charData
end

function DEMONCOMP.IsDemonChar(charId)
    local charData = DEMONCOMP.GetCharData(charId)
    return charData ~= nil and charData.type == "Demon"
end
