AddCSLuaFile()

-- ============================================================
-- Crafting Station Items Database
-- ============================================================
-- Organized by profession with knowledge requirements
-- Items with requiredKnowledge = nil are always available

CRAFTING_STATION_DATA = {
    Alchemy = {
        {
            name = "Healing Potion",
            description = "A basic potion that restores some health over time.",
            requirements = {
                {name = "Herbs", amount = 2},
                {name = "Glass Vial", amount = 1}
            },
            requiredKnowledge = nil,
            icon = "materials/entities/what.png"
        },
        {
            name = "Mana Elixir",
            description = "A potion that replenishes magical energy quickly.",
            requirements = {
                {name = "Mana Herb", amount = 2},
                {name = "Crystal Shard", amount = 1}
            },
            requiredKnowledge = "Advanced Alchemy",
            icon = "materials/entities/what.png"
        },
        {
            name = "Spark Bomb",
            description = "A small explosive device that emits an electrical burst.",
            requirements = {
                {name = "Gunpowder", amount = 3},
                {name = "Copper Wire", amount = 1}
            },
            requiredKnowledge = "Explosive Compounds",
            icon = "materials/entities/what.png"
        }
    },
    Cooking = {
        {
            name = "Baked Stew",
            description = "A hearty meal that restores hunger and grants a small buff.",
            requirements = {
                {name = "Meat", amount = 2},
                {name = "Vegetables", amount = 3}
            },
            requiredKnowledge = nil,
            icon = "materials/entities/what.png"
        },
        {
            name = "Grilled Fish",
            description = "A delicious grilled fish with herbs and spices.",
            requirements = {
                {name = "Fresh Fish", amount = 1},
                {name = "Herbs", amount = 2},
                {name = "Butter", amount = 1}
            },
            requiredKnowledge = "Advanced Cooking",
            icon = "materials/entities/what.png"
        },
        {
            name = "Energy Bar",
            description = "A nutritious bar that provides sustained energy.",
            requirements = {
                {name = "Grain", amount = 3},
                {name = "Honey", amount = 1},
                {name = "Nuts", amount = 2}
            },
            requiredKnowledge = "Preservation",
            icon = "materials/entities/what.png"
        }
    },
    Crafting = {
        {
            name = "Iron Ingot",
            description = "A refined metal bar used for crafting sturdy equipment.",
            requirements = {
                {name = "Iron Ore", amount = 4},
                {name = "Coal", amount = 2}
            },
            requiredKnowledge = nil,
            icon = "materials/entities/what.png"
        },
        {
            name = "Wooden Plank",
            description = "A basic plank used for furniture and simple constructions.",
            requirements = {
                {name = "Wood", amount = 3}
            },
            requiredKnowledge = nil,
            icon = "materials/entities/what.png"
        },
        {
            name = "Crafting Knife",
            description = "A simple tool useful for precise crafting work.",
            requirements = {
                {name = "Iron Ingot", amount = 1},
                {name = "Wood", amount = 1}
            },
            requiredKnowledge = "Tool Crafting",
            icon = "materials/entities/what.png"
        },
        {
            name = "Leather Gloves",
            description = "Protective gloves crafted from treated leather.",
            requirements = {
                {name = "Leather", amount = 2},
                {name = "Thread", amount = 1}
            },
            requiredKnowledge = "Leatherworking",
            icon = "materials/entities/what.png"
        }
    }
}

-- ============================================================
-- Helper: Get available items for a profession and player knowledge
-- ============================================================
function GetCraftingStationItems(profession, playerKnowledge)
    if not CRAFTING_STATION_DATA[profession] then
        return {}
    end

    playerKnowledge = playerKnowledge or {}
    local available = {}

    for _, item in ipairs(CRAFTING_STATION_DATA[profession]) do
        if not item.requiredKnowledge or table.HasValue(playerKnowledge, item.requiredKnowledge) then
            table.insert(available, item)
        end
    end

    return available
end
