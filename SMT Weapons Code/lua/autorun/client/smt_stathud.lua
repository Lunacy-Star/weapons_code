AddCSLuaFile("smt_stathud")

-- ============================================================================
-- Fonts (created once at load, never per-frame)
-- ============================================================================
surface.CreateFont(
    "SMTPartyName",
    {font = "Trebuchet MS", size = 15, weight = 800, antialias = true}
)
surface.CreateFont(
    "SMTPartyNumber",
    {font = "Trebuchet MS", size = 12, weight = 700, antialias = true}
)
surface.CreateFont(
    "SMTPartyStatLabel",
    {font = "Trebuchet MS", size = 11, weight = 700, antialias = true}
)
surface.CreateFont(
    "SMTPartyAilment",
    {font = "Trebuchet MS", size = 15, weight = 700, antialias = true}
)

-- ============================================================================
-- Character portrait icons (cached — file.Exists/Material are not cheap to
-- call every frame, so each charID is resolved once and reused forever)
-- ============================================================================
local ICON_DIR = "materials/icons/characters/"
local FALLBACK_ICON_PATH = ICON_DIR .. "char_citizen.png"

local iconCache = {}

local function GetCharacterIcon(charID)
    if not charID or charID == "" then
        charID = "citizen"
    end

    local cached = iconCache[charID]
    if cached then
        return cached
    end

    local path = ICON_DIR .. "char_" .. charID .. ".png"
    if not file.Exists(path, "GAME") then
        path = FALLBACK_ICON_PATH
    end

    local mat = Material(path, "noclamp smooth")
    iconCache[charID] = mat
    return mat
end

-- ============================================================================
-- Party roster caching — resolved on the same 1s tick as the fight-info net
-- request instead of every HUDPaint call, since HUDPaint can run hundreds of
-- times a second while party membership rarely changes.
-- ============================================================================
local cachedPartyOrder = nil
local cachedPartyMembers = nil

local function RefreshPartyCache()
    local ply = LocalPlayer()
    if not IsValid(ply) then
        cachedPartyOrder, cachedPartyMembers = nil, nil
        return
    end

    local partyId = IsPlayerInAnyPartyClient and IsPlayerInAnyPartyClient(ply)
    local partyData = partyId and GetAllPartyDataClient(ply, partyId)

    if partyData and partyData.Order and #partyData.Order > 0 then
        cachedPartyOrder, cachedPartyMembers = partyData.Order, partyData.Members
    else
        cachedPartyOrder, cachedPartyMembers = nil, nil
    end
end

-- Client-side fight state
local playersInFight = {}
local enemyInFight = {}
local inAFight = false
local timeLeft = 0
local activeTurnEntity = nil

net.Receive(
    "GetFightInfo",
    function(len)
        playersInFight = net.ReadTable()
        enemyInFight = net.ReadTable()
        inAFight = net.ReadBool()
        timeLeft = net.ReadUInt(16)

        local turnEntity = net.ReadEntity()
        activeTurnEntity = IsValid(turnEntity) and turnEntity or nil
    end
)

local requestInterval = 1 -- seconds
local nextRequestTime = CurTime() + requestInterval

hook.Add(
    "Think",
    "InfoRequestThink",
    function()
        if CurTime() >= nextRequestTime then
            net.Start("GetFightInfo")
            net.SendToServer()
            RefreshPartyCache()
            nextRequestTime = CurTime() + requestInterval
        end
    end
)

-- ============================================================================
-- SMT V style party panel
-- Layout: a portrait card per member — grey header (rounded top corners) with
-- the portrait square on the left and HP/MP bars to its right, then a black
-- nameplate along the bottom (rounded bottom corners). Cards stack downward
-- from a center-right anchor.
-- ============================================================================
local CARD_WIDTH = 220
local TOP_HEIGHT = 104
local NAME_HEIGHT = 26
local CARD_HEIGHT = TOP_HEIGHT + NAME_HEIGHT
local CARD_SPACING = 12
local CARD_RADIUS = 10

local PORTRAIT_SIZE = 92
local PORTRAIT_MARGIN = 6

local STAT_BLOCK_WIDTH = CARD_WIDTH - (PORTRAIT_MARGIN * 2 + PORTRAIT_SIZE) - 10
local STAT_ROW_HEIGHT = 16
local STAT_ROW_GAP = 3
local STAT_LABEL_WIDTH = 16
local STAT_NUMBER_GAP = 6 -- space reserved between the bar and its number
local STAT_MIN_BAR_WIDTH = 20
local STAT_BAR_HEIGHT = 7

local COLOR_PORTRAIT_BG = Color(150, 150, 155, 50)
local COLOR_NAME_BG = Color(10, 10, 10, 235)
local COLOR_NAME_TEXT = Color(255, 255, 255, 255)
local COLOR_NUMBER = Color(255, 255, 255, 255)
local COLOR_LABEL = Color(230, 230, 230, 255)
local COLOR_HP_BAR = Color(96, 200, 96, 255)
local COLOR_MP_BAR = Color(64, 140, 230, 255)
local COLOR_BAR_BG = Color(20, 20, 20, 200)
local COLOR_STAT_ROW_BG = Color(15, 15, 15, 130)

local COLOR_AILMENT_BUFF_TEXT = Color(140, 230, 160, 255)
local COLOR_AILMENT_BUFF_BG = COLOR_STAT_ROW_BG
local COLOR_AILMENT_DEBUFF_TEXT = Color(255, 235, 235, 255)
local COLOR_AILMENT_DEBUFF_BG = Color(120, 25, 25, 200)
local AILMENT_LINE_HEIGHT = 25
-- Wide enough to clear the active-turn glow's outermost layer (see
-- GLOW_LAYERS_ACTIVE below) so badges don't overlap the card's halo.
local AILMENT_GAP = 44
local AILMENT_COLUMN_GAP = 8

-- Soft blurred backdrop behind each card, faked with a few concentric
-- rounded boxes that grow and fade outward (no render targets/materials
-- needed, so this stays cheap even drawn every frame per card).
local ACTIVE_TURN_SHIFT = 18

local COLOR_GLOW_IDLE = Color(0, 0, 0)
local GLOW_LAYERS_IDLE = {
    {expand = 20, alpha = 25},
    {expand = 12, alpha = 45},
    {expand = 5, alpha = 70}
}

local COLOR_GLOW_ACTIVE = Color(70, 150, 255)
local GLOW_LAYERS_ACTIVE = {
    {expand = 34, alpha = 35},
    {expand = 24, alpha = 60},
    {expand = 14, alpha = 95},
    {expand = 6, alpha = 140}
}

local function DrawCardGlow(x, y, w, h, radius, color, layers)
    for _, layer in ipairs(layers) do
        local ex = layer.expand
        draw.RoundedBox(radius + ex, x - ex, y - ex, w + ex * 2, h + ex * 2, Color(color.r, color.g, color.b, layer.alpha))
    end
end

local function DrawStatBar(x, y, width, height, current, max, fillColor)
    draw.RoundedBox(2, x, y, width, height, COLOR_BAR_BG)

    local frac = max > 0 and math.Clamp(current / max, 0, 1) or 0
    if frac > 0 then
        draw.RoundedBox(2, x, y, width * frac, height, fillColor)
    end
end

local function DrawStatRow(x, y, label, current, max, fillColor)
    draw.RoundedBox(3, x, y, STAT_BLOCK_WIDTH, STAT_ROW_HEIGHT, COLOR_STAT_ROW_BG)

    draw.SimpleText(
        label,
        "SMTPartyStatLabel",
        x + 5,
        y + STAT_ROW_HEIGHT * 0.5,
        COLOR_LABEL,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER
    )

    -- Measure the number text so the bar shrinks to make room for it instead
    -- of a fixed-width slot that large values (e.g. "4750/4750") overflow.
    local numberText = current .. "/" .. max
    surface.SetFont("SMTPartyNumber")
    local numberWidth = surface.GetTextSize(numberText)

    local barX = x + STAT_LABEL_WIDTH
    local barWidth = math.max(
        STAT_MIN_BAR_WIDTH,
        STAT_BLOCK_WIDTH - STAT_LABEL_WIDTH - numberWidth - STAT_NUMBER_GAP
    )
    local barY = y + (STAT_ROW_HEIGHT - STAT_BAR_HEIGHT) * 0.5
    DrawStatBar(barX, barY, barWidth, STAT_BAR_HEIGHT, current, max, fillColor)

    draw.SimpleText(
        numberText,
        "SMTPartyNumber",
        x + STAT_BLOCK_WIDTH - 4,
        y + STAT_ROW_HEIGHT * 0.5,
        COLOR_NUMBER,
        TEXT_ALIGN_RIGHT,
        TEXT_ALIGN_CENTER
    )
end

-- Draws one ailment column (right-aligned to columnRightEdge, vertically
-- centered against the card) and returns the width of its widest badge, so
-- the caller can place the next column further left without overlapping.
local function DrawAilmentColumn(lines, columnRightEdge, cardY, bgColor)
    if #lines == 0 then
        return 0
    end

    surface.SetFont("SMTPartyAilment")

    local maxWidth = 0
    local lineY = cardY + (CARD_HEIGHT - #lines * AILMENT_LINE_HEIGHT) * 0.5

    for _, line in ipairs(lines) do
        local textWidth = surface.GetTextSize(line.text)
        maxWidth = math.max(maxWidth, textWidth + 10)

        draw.RoundedBox(
            3,
            columnRightEdge - textWidth - 10,
            lineY,
            textWidth + 10,
            AILMENT_LINE_HEIGHT - 2,
            bgColor
        )
        draw.SimpleText(
            line.text,
            "SMTPartyAilment",
            columnRightEdge - 5,
            lineY + (AILMENT_LINE_HEIGHT - 2) * 0.5,
            line.color,
            TEXT_ALIGN_RIGHT,
            TEXT_ALIGN_CENTER
        )
        lineY = lineY + AILMENT_LINE_HEIGHT
    end

    return maxWidth
end

-- Buffs/debuffs, listed to the left of the afflicted member's card as two
-- columns — debuffs (red) further out, buffs (green) closer to the card.
local function DrawAilmentList(memberInfo, cardX, cardY)
    if not (PlayerStats and PlayerStats[memberInfo:SteamID()]) then
        return
    end

    local buffs = GetAllStatsClient(memberInfo, "buffs")
    local debuffs = GetAllStatsClient(memberInfo, "debuffs")

    local buffLines, debuffLines = {}, {}

    local function CollectAilments(ailmentTable, textColor, outLines)
        if not ailmentTable then
            return
        end

        for ailmentName, ailmentInfo in pairs(ailmentTable) do
            if not (ailmentInfo.visibility == 0) then
                outLines[#outLines + 1] = {
                    text = string.gsub(ailmentName, "_", " ") .. " " .. ailmentInfo.stacks .. "x",
                    color = textColor
                }
            end
        end
    end

    CollectAilments(buffs, COLOR_AILMENT_BUFF_TEXT, buffLines)
    CollectAilments(debuffs, COLOR_AILMENT_DEBUFF_TEXT, debuffLines)

    if #buffLines == 0 and #debuffLines == 0 then
        return
    end

    local buffColumnRightEdge = cardX - AILMENT_GAP
    local buffColumnWidth = DrawAilmentColumn(buffLines, buffColumnRightEdge, cardY, COLOR_AILMENT_BUFF_BG)

    local debuffColumnRightEdge = buffColumnRightEdge
    if buffColumnWidth > 0 then
        debuffColumnRightEdge = buffColumnRightEdge - buffColumnWidth - AILMENT_COLUMN_GAP
    end
    DrawAilmentColumn(debuffLines, debuffColumnRightEdge, cardY, COLOR_AILMENT_DEBUFF_BG)
end

local function DrawPartyRow(memberInfo, x, y, isActiveTurn)
    local hp = memberInfo:GetNWInt("TBCHP", 100)
    local maxHp = memberInfo:GetNWInt("TBCMAXHP", 100)
    local mp = memberInfo:GetNWInt("TBCMP", 100)
    local maxMp = memberInfo:GetNWInt("TBCMAXMP", 100)
    local charID = memberInfo:GetNWString("AssignedCharacter", "")

    if isActiveTurn then
        DrawCardGlow(x, y, CARD_WIDTH, CARD_HEIGHT, CARD_RADIUS, COLOR_GLOW_ACTIVE, GLOW_LAYERS_ACTIVE)
    else
        DrawCardGlow(x, y, CARD_WIDTH, CARD_HEIGHT, CARD_RADIUS, COLOR_GLOW_IDLE, GLOW_LAYERS_IDLE)
    end

    DrawAilmentList(memberInfo, x, y)

    -- Grey header (rounded top corners only)
    draw.RoundedBoxEx(CARD_RADIUS, x, y, CARD_WIDTH, TOP_HEIGHT, COLOR_PORTRAIT_BG, true, true, false, false)

    -- Portrait square, left-aligned within the header
    local portraitY = y + (TOP_HEIGHT - PORTRAIT_SIZE) * 0.5
    surface.SetDrawColor(255, 255, 255, 255)
    surface.SetMaterial(GetCharacterIcon(charID))
    surface.DrawTexturedRect(x + PORTRAIT_MARGIN, portraitY, PORTRAIT_SIZE, PORTRAIT_SIZE)

    -- Nameplate (rounded bottom corners only)
    draw.RoundedBoxEx(
        CARD_RADIUS,
        x,
        y + TOP_HEIGHT,
        CARD_WIDTH,
        NAME_HEIGHT,
        COLOR_NAME_BG,
        false,
        false,
        true,
        true
    )
    draw.SimpleText(
        memberInfo:Name(),
        "SMTPartyName",
        x + CARD_WIDTH * 0.5,
        y + TOP_HEIGHT + NAME_HEIGHT * 0.5,
        COLOR_NAME_TEXT,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_CENTER
    )

    -- HP/MP stacked to the right of the portrait, vertically centered in the header
    local statX = x + PORTRAIT_MARGIN + PORTRAIT_SIZE + 10
    local statBlockHeight = STAT_ROW_HEIGHT * 2 + STAT_ROW_GAP
    local statY = y + (TOP_HEIGHT - statBlockHeight) * 0.5
    DrawStatRow(statX, statY, "HP", hp, maxHp, COLOR_HP_BAR)
    DrawStatRow(statX, statY + STAT_ROW_HEIGHT + STAT_ROW_GAP, "MP", mp, maxMp, COLOR_MP_BAR)
end

hook.Add(
    "HUDPaint",
    "SMTPartyHUD",
    function()
        local ply = LocalPlayer()
        if not IsValid(ply) then
            return
        end

        local engageWeapon = ply:GetWeapon("smti_engageswep")
        if not IsValid(engageWeapon) then
            return
        end

        local screenWidth, screenHeight = ScrW(), ScrH()
        local anchorX = screenWidth - CARD_WIDTH - screenWidth * 0.035
        local anchorY = screenHeight * 0.12

        if inAFight then
            if timeLeft then
                local minutes = math.floor(timeLeft / 60)
                local seconds = math.floor(timeLeft % 60)

                -- Format the time as MM:SS
                local timeText = string.format("%02d:%02d", minutes, seconds)

                -- Set the position and size for the text
                local font = "TargetID"

                -- Draw the text on the screen
                draw.SimpleText(
                    timeText,
                    font,
                    screenWidth * 0.01 + 1500,
                    screenHeight * 0.03,
                    Color(255, 255, 255, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            end -- Exit if the timer doesn't exist anymore

            for i, memberInfo in ipairs(playersInFight) do
                if IsValid(memberInfo) then
                    local isActiveTurn = activeTurnEntity ~= nil and memberInfo == activeTurnEntity
                    local rowX = anchorX - (isActiveTurn and ACTIVE_TURN_SHIFT or 0)
                    DrawPartyRow(memberInfo, rowX, anchorY + (i - 1) * (CARD_HEIGHT + CARD_SPACING), isActiveTurn)
                end
            end
        elseif cachedPartyOrder then
            for i, steamID in ipairs(cachedPartyOrder) do
                local memberInfo = cachedPartyMembers[steamID]
                if IsValid(memberInfo) then
                    local isActiveTurn = activeTurnEntity ~= nil and memberInfo == activeTurnEntity
                    local rowX = anchorX - (isActiveTurn and ACTIVE_TURN_SHIFT or 0)
                    DrawPartyRow(memberInfo, rowX, anchorY + (i - 1) * (CARD_HEIGHT + CARD_SPACING), isActiveTurn)
                end
            end
        else
            DrawPartyRow(ply, anchorX, anchorY, false)
        end
    end
)

local allies = Material("materials/icons/allyicon.png")
local enemies = Material("materials/icons/enemyicon.png")

hook.Add(
    "PostPlayerDraw",
    "DrawImagesAbovePlayers",
    function(ply)
        if not IsValid(ply) then
            return
        end -- Check if the player entity is valid

        if inAFight then
            for i, memberInfo in ipairs(playersInFight) do
                if IsValid(memberInfo) then
                    -- Get the player's position and adjust the z-coordinate to move the image above the player's head
                    local pos = memberInfo:GetPos()
                    pos.z = pos.z + 80 -- Image position in height

                    -- rendering properties
                    cam.Start3D2D(pos, Angle(0, EyeAngles().y - 90, 90), 0.1) -- The 0.1 is the scale
                    surface.SetDrawColor(255, 255, 255, 255) -- color and alpha
                    surface.SetMaterial(allies) -- Set the image
                    surface.DrawTexturedRect(-64, -64, 128, 128) -- centered at the player's position
                    cam.End3D2D()
                end
            end

            for i, memberInfo in ipairs(enemyInFight) do
                if IsValid(memberInfo) then
                    -- Get the player's position and adjust the z-coordinate to move the image above the player's head
                    local pos = memberInfo:GetPos()
                    pos.z = pos.z + 80 -- Image position in height

                    -- Set up the rendering properties
                    cam.Start3D2D(pos, Angle(0, EyeAngles().y - 90, 90), 0.1) -- The 0.1 is the scale
                    surface.SetDrawColor(255, 255, 255, 255) -- color and alpha
                    surface.SetMaterial(enemies) -- Set the image
                    surface.DrawTexturedRect(-64, -64, 128, 128) -- centered at the player's position
                    cam.End3D2D()
                end
            end
        end
    end
)

-- Client-side script
hook.Add(
    "HUDPaint",
    "DrawStatsWhenLookingAtPlayer",
    function()
        local localPlayer = LocalPlayer() -- Get the local player
        local trace = localPlayer:GetEyeTrace() -- Get where the player is looking
        local target = trace.Entity -- Get the entity the player is looking at

        -- Check if the entity is a valid player and within a certain distance (e.g., 500 units)
        if IsValid(target) and CheckIfValidTBCEntity(target) and localPlayer:GetPos():Distance(target:GetPos()) < 500 then
            -- Get the target's position and convert it to 2D screen coordinates
            local targetPos = target:GetPos() + Vector(0, 0, 80) -- The Vector offset is to position the text above the player's head
            local screenPos = targetPos:ToScreen()

            -- Get the networked stats
            local tbchp = target:GetNWInt("TBCHP", 100) -- Default value is used if the variable isn't set
            local tbcmp = target:GetNWInt("TBCMP", 50)
            local tbcluck = target:GetNWInt("TBCLuck", 10)
            local tbctechnique = target:GetNWInt("TBCTechnique", 10)

            -- Draw the stats on the screen
            draw.SimpleText(
                "TBCHP: " .. tbchp,
                "TargetID",
                screenPos.x,
                screenPos.y,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "TBCMP: " .. tbcmp,
                "TargetID",
                screenPos.x,
                screenPos.y + 15,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "TBCLuck: " .. tbcluck,
                "TargetID",
                screenPos.x,
                screenPos.y + 30,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
            draw.SimpleText(
                "TBCTechnique: " .. tbctechnique,
                "TargetID",
                screenPos.x,
                screenPos.y + 45,
                Color(255, 255, 255, 255),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )

            if tbchp <= 0 then
                draw.SimpleText(
                    "DEAD. GONE. HOW DOES IT FEEL TO BE DEAD?",
                    "TargetID",
                    screenPos.x,
                    screenPos.y + 60,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "Bye bye, you're history, you're through! You're dust.",
                    "Default",
                    screenPos.x,
                    screenPos.y + 75,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "I hope you improve your lousy score.",
                    "Default",
                    screenPos.x,
                    screenPos.y + 90,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "Adios, see you later, bye bye!",
                    "Default",
                    screenPos.x,
                    screenPos.y + 105,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
                draw.SimpleText(
                    "Try Again...",
                    "Default",
                    screenPos.x,
                    screenPos.y + 120,
                    Color(255, 0, 0, 255),
                    TEXT_ALIGN_CENTER,
                    TEXT_ALIGN_CENTER
                )
            else
                if PlayerStats and PlayerStats[target:SteamID()] then
                    local buffs = GetAllStatsClient(target, "buffs")
                    local debuffs = GetAllStatsClient(target, "debuffs")
                    local isEmpty = true
                    if buffs then
                        local buffText = "Buffs: "
                        for status, properties in pairs(buffs) do
                            isEmpty = false
                            buffText = buffText .. string.gsub(status, "_", " ")
                            if properties.stacks then
                                buffText = buffText .. properties.stacks .. "x "
                            end
                        end

                        if not isEmpty then
                            draw.SimpleText(
                                buffText,
                                "TargetID",
                                screenPos.x,
                                screenPos.y + 60,
                                Color(255, 255, 255, 255),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_CENTER
                            )
                        end
                    end

                    if debuffs then
                        local debuffText = "Debuffs: "
                        isEmpty = true
                        for status, properties in pairs(debuffs) do
                            isEmpty = false
                            debuffText = debuffText .. string.gsub(status, "_", " ")
                            if properties.stacks then
                                debuffText = debuffText .. properties.stacks .. "x "
                            end
                        end

                        if not isEmpty then
                            draw.SimpleText(
                                debuffText,
                                "TargetID",
                                screenPos.x,
                                screenPos.y + 75,
                                Color(255, 255, 255, 255),
                                TEXT_ALIGN_CENTER,
                                TEXT_ALIGN_CENTER
                            )
                        end
                    end
                end
            end
        end
    end
)
