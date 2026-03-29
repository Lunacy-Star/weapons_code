AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_resnode"
ENT.PrintName = "Tree"
ENT.ResourceRegistration = "wood"
ENT.Description = "A tree"
ENT.Author = "Nara"
ENT.Category = "Crafting Resource Nodes"
ENT.SlotAmount = 10
ENT.SlotType = "Resources"
ENT.ShowInfo = true
ENT.PossibleModels = {
    "models/props_foliage/tree_deciduous_01a-lod.mdl",
    "models/props_foliage/tree_springers_01a-lod.mdl",
    "models/props_foliage/tree_poplar_01.mdl"
}

ENT.Spawnable = true
ENT.AdminOnly = false

-- Gathering stuff
ENT.GatherTime = 3 -- Time in seconds to gather
ENT.GatherRange = 100 -- Maximum distance to gather
ENT.MaxLookAngle = 45 -- Maximum angle deviation from looking at the tree

ENT.PlayerCooldown = 5 -- Cooldown in seconds per player
ENT.PlayerCooldowns = {} -- Table to store player cooldowns
ENT.ActiveGatherers = {} -- Table to store active gatherers and their data


scripted_ents.Register(ENT, "rsn_tree")
