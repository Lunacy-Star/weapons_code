-- Battle announcements: chat text for fight participants + an on-screen
-- stacking block for everyone nearby (bystanders included). Two independent
-- client settings gate the two outputs (see custom_tab_menu.lua Settings tab).

SMT_CHATPRINT_RADIUS = 800

if SERVER then
    util.AddNetworkString("SMT_ChatBlock")
end

-- fightPlayers: array of players guaranteed the chat line (the fight's participants).
-- position: world position the announcement originated from, used to find nearby
--   bystanders who should see the on-screen block but not the chat line.
-- message: the text to announce.
--
-- Also appends the message to the CombatLog of every distinct party a fight
-- participant belongs to (not bystanders' parties, per design).
function SMT_ChatPrint(fightPlayers, position, message)
    if not SERVER then return end
    if not message or message == "" then return end

    fightPlayers = fightPlayers or {}

    if #fightPlayers > 0 then
        net.Start("SMT_ChatBlock")
        net.WriteString(message)
        net.WriteBool(true) -- also show in chat
        net.Send(fightPlayers)
    end

    if position then
        local radiusSqr = SMT_CHATPRINT_RADIUS * SMT_CHATPRINT_RADIUS
        local bystanders = {}

        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and not table.HasValue(fightPlayers, ply) then
                if ply:GetPos():DistToSqr(position) <= radiusSqr then
                    table.insert(bystanders, ply)
                end
            end
        end

        if #bystanders > 0 then
            net.Start("SMT_ChatBlock")
            net.WriteString(message)
            net.WriteBool(false) -- block only, no chat line
            net.Send(bystanders)
        end
    end

    if PlayerParties and IsPlayerInAnyParty then
        local loggedParties = {}
        for _, ply in ipairs(fightPlayers) do
            local partyId = IsPlayerInAnyParty(ply)
            if partyId and not loggedParties[partyId] then
                loggedParties[partyId] = true

                local party = PlayerParties[partyId]
                if party then
                    party.CombatLog = party.CombatLog or {}
                    table.insert(party.CombatLog, {text = message, time = os.time()})
                    if #party.CombatLog > 100 then
                        table.remove(party.CombatLog, 1)
                    end
                end
            end
        end
    end
end

if CLIENT then
    CreateClientConVar("smt_chatprint_showchat", "1", true, false, "Show battle announcements in chat.")
    CreateClientConVar("smt_chatprint_showblocks", "1", true, false, "Show battle announcement blocks on screen.")
    CreateClientConVar("smt_chatprint_shownearby", "1", true, false, "Show battle announcement blocks for fights you're not part of.")

    local BLOCK_DURATION = 6
    local BLOCK_FADE_TIME = 0.6
    local BLOCK_WIDTH = 900
    local BLOCK_HEIGHT = 40
    local BLOCK_GAP = 6
    local BLOCK_TOP_Y = 90
    local SLIDE_SPEED = 10

    surface.CreateFont("SMT_ChatPrintFont", {
        font = "Arial",
        size = 18,
        weight = 600,
        antialias = true
    })

    local activeBlocks = {}

    net.Receive("SMT_ChatBlock", function()
        local message = net.ReadString()
        local showChat = net.ReadBool()

        if showChat and GetConVar("smt_chatprint_showchat"):GetBool() then
            chat.AddText(Color(255, 255, 255), message)
        end

        -- showChat is true only for fight participants; bystanders (showChat == false)
        -- are additionally gated by the "other party notifications" setting.
        if GetConVar("smt_chatprint_showblocks"):GetBool() and (showChat or GetConVar("smt_chatprint_shownearby"):GetBool()) then
            table.insert(activeBlocks, {
                text = message,
                spawnTime = CurTime(),
                y = BLOCK_TOP_Y - BLOCK_HEIGHT -- starts just above its slot, slides down into place
            })
        end
    end)

    hook.Add("HUDPaint", "SMT_ChatPrintBlocks_Draw", function()
        if #activeBlocks == 0 then return end

        local now = CurTime()
        local dt = FrameTime()

        for i = #activeBlocks, 1, -1 do
            if now - activeBlocks[i].spawnTime >= BLOCK_DURATION then
                table.remove(activeBlocks, i)
            end
        end

        local x = ScrW() / 2 - BLOCK_WIDTH / 2
        local lerpFrac = 1 - math.exp(-SLIDE_SPEED * dt)

        for i, block in ipairs(activeBlocks) do
            local targetY = BLOCK_TOP_Y + (i - 1) * (BLOCK_HEIGHT + BLOCK_GAP)
            block.y = Lerp(lerpFrac, block.y, targetY)

            local age = now - block.spawnTime
            local alpha = 255
            if age > BLOCK_DURATION - BLOCK_FADE_TIME then
                alpha = 255 * math.max(0, (BLOCK_DURATION - age) / BLOCK_FADE_TIME)
            end

            draw.RoundedBox(4, x, block.y, BLOCK_WIDTH, BLOCK_HEIGHT, Color(0, 0, 0, 200 * (alpha / 255)))
            draw.SimpleText(
                block.text,
                "SMT_ChatPrintFont",
                x + BLOCK_WIDTH / 2,
                block.y + BLOCK_HEIGHT / 2,
                Color(255, 255, 255, alpha),
                TEXT_ALIGN_CENTER,
                TEXT_ALIGN_CENTER
            )
        end
    end)
end
