SMTDamageNumbers = SMTDamageNumbers or {}

SMTDamageNumbers.Duration = 1.1

if SERVER then
    util.AddNetworkString("SMTDamageNumber")
end

-- state: "normal" | "crit" | "weak" | "resist" | "block" | "repel" | "drain"
--      | "miss" | "heal" | "dead" | "buff" | "debuff"
-- amount is nil for states that show no number (block/repel/miss/dead); for
-- buff/debuff it's the stack count instead of a damage/heal amount.
-- label is only used by buff/debuff (the buff/debuff name).
-- Networked via PVS from the target's position, same as SMTParticles, so
-- everyone nearby sees it - not just the attacker's fight/party.
function SMTDamageNumbers.Show(target, amount, state, label)
    if not SERVER then return end
    if not IsValid(target) then return end

    state = state or "normal"

    -- variant picks between random flavor text for a state:
    --   crit: 0 = "Crit!" (90%),      1 = "SMAAAASH!!" (10%)
    --   dead: 0 = "Dead!" (90%),      1 = "Retired!" (5%), 2 = "Swoon!" (5%)
    local variant = 0
    if state == "crit" then
        variant = (math.random(1, 100) <= 10) and 1 or 0
    elseif state == "dead" then
        variant = (math.random(1, 100) <= 10) and math.random(1, 2) or 0
    end

    net.Start("SMTDamageNumber")
    net.WriteEntity(target)
    net.WriteBool(amount ~= nil)
    net.WriteInt(math.floor(amount or 0), 32)
    net.WriteString(state)
    net.WriteUInt(variant, 4)
    net.WriteString(label or "")
    net.SendPVS(target:GetPos())
end

if CLIENT then
    SMTDamageNumbers.Active = {}

    local COLOR_BLACK = Color(0, 0, 0, 255)
    local COLOR_GREY_OUTLINE = Color(140, 140, 140, 255)
    local COLOR_RED_OUTLINE = Color(210, 30, 30, 255)
    local COLOR_BLUE_OUTLINE = Color(60, 140, 255, 255)
    local COLOR_GREEN_OUTLINE = Color(50, 200, 90, 255)
    local COLOR_PURPLE_OUTLINE = Color(160, 60, 220, 255)
    local COLOR_WHITE_FILL = Color(235, 235, 235, 255)
    local COLOR_GREY_FILL = Color(200, 200, 200, 255)

    surface.CreateFont("SMTDamageNumberFont", {
        font = "Arial Black",
        size = 22,
        weight = 800,
        antialias = true
    })

    -- Tracks how many hits have already landed on a target this instant so
    -- simultaneous AoE hits fan out instead of overlapping unreadably.
    local recentHitsPerTarget = {}

    local function GetStackIndex(target)
        local index = recentHitsPerTarget[target] or 0
        recentHitsPerTarget[target] = index + 1

        timer.Simple(0.2, function()
            if recentHitsPerTarget[target] then
                recentHitsPerTarget[target] = recentHitsPerTarget[target] - 1
                if recentHitsPerTarget[target] <= 0 then
                    recentHitsPerTarget[target] = nil
                end
            end
        end)

        return index
    end

    net.Receive("SMTDamageNumber", function()
        local target = net.ReadEntity()
        local hasAmount = net.ReadBool()
        local amount = net.ReadInt(32)
        local state = net.ReadString()
        local variant = net.ReadUInt(4)
        local label = net.ReadString()

        if not IsValid(target) then return end

        local amountText = hasAmount and tostring(amount) or ""
        local text, outlineColor, fillColor = amountText, COLOR_BLACK, COLOR_WHITE_FILL

        if state == "crit" then
            local word = variant == 1 and "SMAAAASH!!" or "Crit!"
            outlineColor = variant == 1 and COLOR_BLUE_OUTLINE or COLOR_RED_OUTLINE
            text = amountText .. " " .. word
        elseif state == "weak" then
            outlineColor = COLOR_RED_OUTLINE
            text = amountText .. " Weak!"
        elseif state == "resist" then
            outlineColor = COLOR_GREY_OUTLINE
            fillColor = COLOR_GREY_FILL
            text = amountText .. " Resist!"
        elseif state == "block" then
            text = "Blocked!"
        elseif state == "repel" then
            text = "Repeled!"
        elseif state == "miss" then
            text = "Missed!"
        elseif state == "heal" then
            outlineColor = COLOR_GREEN_OUTLINE
            text = "+" .. amountText
        elseif state == "dead" then
            if variant == 1 then
                text = "Retired!"
            elseif variant == 2 then
                text = "Swoon!"
            else
                text = "Dead!"
            end
        elseif state == "buff" then
            outlineColor = COLOR_BLUE_OUTLINE
            text = amountText .. "x " .. label .. "!"
        elseif state == "debuff" then
            outlineColor = COLOR_PURPLE_OUTLINE
            text = amountText .. "x " .. label .. "!"
        else
            fillColor = COLOR_GREY_FILL
        end

        if text == "" then return end

        local stackIndex = GetStackIndex(target)

        table.insert(SMTDamageNumbers.Active, {
            target = target,
            worldPos = target:WorldSpaceCenter(),
            text = text,
            outlineColor = outlineColor,
            fillColor = fillColor,
            spawnTime = CurTime(),
            xJitter = math.random(-18, 18) + stackIndex * 16,
            startDelay = stackIndex * 0.07
        })
    end)

    hook.Add("HUDPaint", "SMTDamageNumbers_Draw", function()
        local active = SMTDamageNumbers.Active
        if #active == 0 then return end

        local now = CurTime()
        for i = #active, 1, -1 do
            local dmgNum = active[i]
            local elapsed = now - dmgNum.spawnTime - dmgNum.startDelay

            if elapsed >= SMTDamageNumbers.Duration then
                table.remove(active, i)
            elseif elapsed >= 0 then
                local worldPos = IsValid(dmgNum.target) and dmgNum.target:WorldSpaceCenter() or dmgNum.worldPos

                local t = elapsed / SMTDamageNumbers.Duration
                local bounce = math.sin(math.min(t, 1) * math.pi)
                local zOffset = 34 * (t * 0.6 + bounce * 0.5)

                local screenPos = (worldPos + Vector(0, 0, zOffset)):ToScreen()
                if screenPos.visible then
                    local alpha = 255
                    if t > 0.7 then
                        alpha = 255 * (1 - (t - 0.7) / 0.3)
                    end

                    draw.SimpleTextOutlined(
                        dmgNum.text,
                        "SMTDamageNumberFont",
                        screenPos.x + dmgNum.xJitter,
                        screenPos.y,
                        ColorAlpha(dmgNum.fillColor, alpha),
                        TEXT_ALIGN_CENTER,
                        TEXT_ALIGN_CENTER,
                        2,
                        ColorAlpha(dmgNum.outlineColor, alpha)
                    )
                end
            end
        end
    end)
end
