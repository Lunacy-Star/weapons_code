if SERVER then
    AddCSLuaFile()

    util.AddNetworkString("mtchat_submit")
    util.AddNetworkString("mtchat_broadcast")
	util.AddNetworkString("mtchat_typing")
	
	util.AddNetworkString("mtchat_setnamecolor")
	util.AddNetworkString("mtchat_namecolor_update")
	util.AddNetworkString("mtchat_namecolor_sync")
	util.AddNetworkString("mtchat_radiussync")
	
    -- mtc_chatradius: 0 = global (no proximity restrictions) / >0 = only within radius gets real message
    -- mtc_chatterradius: extra "outer band" distance where you see: "You hear chattering ..."
	
    local cvChatRadius = CreateConVar("mtc_chatradius", "0", FCVAR_ARCHIVE + FCVAR_NOTIFY, "MTChat proximity radius (0 = global).")
    local cvChatterRadius = CreateConVar("mtc_chatterradius", "200", FCVAR_ARCHIVE + FCVAR_NOTIFY, "MTChat chatter band added on top of mtc_chatradius.")
    local cvYellAdd = CreateConVar("mtc_yelladd", "250", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Extra radius added when using /y or [yell].")
    local cvWhisperSub = CreateConVar("mtc_whispersub", "250", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Radius subtracted when using /w or [whisper].")
    local cvAllowGlobalWhisper = CreateConVar("mtc_allowglobalwhisper", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "If 1 and mtc_chatradius is 0, whisper becomes local-only.")
	local cvAllowRolls = CreateConVar("mtc_allowrolls", "1", FCVAR_ARCHIVE + FCVAR_NOTIFY, "Allow /roll and /rolltrace chat commands.")


    local function MTChat_IsAdminCaller(ply)
        -- allow server console
        if not IsValid(ply) then return true end
        return ply:IsAdmin()
    end
	
	-- Track who is currently typing in MTChat
	local MTChat_Typing = {} -- [ply] = bool

    concommand.Add("sv_mtchat_chatradius", function(ply, _, args)
        if not MTChat_IsAdminCaller(ply) then return end
        local v = tonumber(args[1] or "")
        if v == nil then return end
        v = math.max(0, math.floor(v))
        cvChatRadius:SetInt(v)
    end)

    concommand.Add("sv_mtchat_chatterradius", function(ply, _, args)
        if not MTChat_IsAdminCaller(ply) then return end
        local v = tonumber(args[1] or "")
        if v == nil then return end
        v = math.max(0, math.floor(v))
        cvChatterRadius:SetInt(v)
    end)
	
    concommand.Add("sv_mtchat_yelladd", function(ply, _, args)
        if not MTChat_IsAdminCaller(ply) then return end
        local v = tonumber(args[1] or "")
        if v == nil then return end
        v = math.max(0, math.floor(v))
        cvYellAdd:SetInt(v)
    end)

    concommand.Add("sv_mtchat_whispersub", function(ply, _, args)
        if not MTChat_IsAdminCaller(ply) then return end
        local v = tonumber(args[1] or "")
        if v == nil then return end
        v = math.max(0, math.floor(v))
        cvWhisperSub:SetInt(v)
    end)

    concommand.Add("sv_mtchat_allowglobalwhisper", function(ply, _, args)
        if not MTChat_IsAdminCaller(ply) then return end
        local v = tonumber(args[1] or "")
        if v == nil then return end
        v = (v ~= 0) and 1 or 0
        cvAllowGlobalWhisper:SetInt(v)
    end)

	concommand.Add("sv_mtchat_allowrolls", function(ply, _, args)
		if not MTChat_IsAdminCaller(ply) then return end
		local v = tonumber(args[1] or "")
		if v == nil then return end
		v = (v ~= 0) and 1 or 0
		cvAllowRolls:SetInt(v)
	end)

    local MAX_LEN = 8192 -- safety limit

	local function MTChat_ClampByte(n)
		n = tonumber(n) or 0
		n = math.floor(n)
		if n < 0 then return 0 end
		if n > 255 then return 255 end
		return n
	end

	local function MTChat_DefaultNameColor()
		return 120, 120, 120
	end

	local function MTChat_GetNameColor(ply)
		if not IsValid(ply) or not ply:IsPlayer() then
			return MTChat_DefaultNameColor()
		end
		local c = ply.MTChat_NameColor
		if istable(c) then
			return MTChat_ClampByte(c.r), MTChat_ClampByte(c.g), MTChat_ClampByte(c.b)
		end
		return MTChat_DefaultNameColor()
	end
	
    local function MTChat_BuildChatterLine(sender, listener)
        if not IsValid(sender) or not IsValid(listener) then
            return "You hear chattering..."
        end

        -- x = forward/back, y = left/right (positive = left), z = up/down
        local rel = listener:WorldToLocal(sender:EyePos())

        local parts = {}

		-- vertical: project onto listener's up vector (more stable than WorldToLocal z)
		local dv = sender:EyePos() - listener:EyePos()
		local z = dv:Dot(listener:GetUp())
		local horiz = math.sqrt(math.max(0, dv:LengthSqr() - (z * z)))

		-- less sensitive: higher minimum, stronger scaling with distance
		local vz = math.max(240, horiz * 0.75)

		if z > vz then
			parts[#parts + 1] = "above"
		elseif z < -vz then
			parts[#parts + 1] = "below"
		end

        -- choose ONE horizontal direction (front/behind OR left/right) based on strongest axis
        local ax = math.abs(rel.x)
        local ay = math.abs(rel.y)

        if ax > 64 or ay > 64 then
            if ax >= ay then
                parts[#parts+1] = (rel.x >= 0) and "in front of you" or "behind you"
            else
                parts[#parts+1] = (rel.y >= 0) and "to your left" or "to your right"
            end
        end

        if #parts == 0 then
            return "You hear chattering..."
        elseif #parts == 1 then
            return "You hear chattering " .. parts[1] .. "."
        else
            return "You hear chattering " .. parts[1] .. " and " .. parts[2] .. "."
        end
    end

	local function MTChat_ParseChatCommands(ply, msg)
		local out = {
			mode = nil,          -- "yell" | "whisper" | nil
			isMe = false,        -- true if /me used
			roll = nil,          -- { trace = bool, max = int }
			order = {},          -- preserves prefix order: "yell"/"whisper"/"roll"
			text = msg,
			prefixColor = ""     -- leading "<r,g,b>" tag(s) before commands
		}

		msg = tostring(msg or "")
		local s = string.TrimLeft(msg)
		if s == "" then out.text = ""; return out end

		-- leading <r,g,b> tags
		while true do
			local tag = string.match(s, "^(<%s*%d+%s*,%s*%d+%s*,%s*%d+%s*>)")
			if not tag then break end
			out.prefixColor = out.prefixColor .. tag
			s = string.sub(s, #tag + 1)
			s = string.TrimLeft(s)
		end

		local lower = string.lower(s)

		local function pushOrder(tok)
			out.order[#out.order + 1] = tok
		end

		local function eatToken(tok)
			if string.sub(lower, 1, #tok) == tok then
				local nextch = string.sub(lower, #tok + 1, #tok + 1)
				if nextch == "" or nextch == " " then
					s = string.sub(s, #tok + 1)
					s = string.TrimLeft(s)
					lower = string.lower(s)
					return true
				end
			end
			return false
		end

		local function eatRollArgIfPresent()
			-- Try dice notation first: NdN, NdN+N, NdN-N (e.g. 2d6+3)
			local dicePattern = "^(%d+)[dD](%d+)%s*([%+%-]?)%s*(%d*)"
			local countStr, sidesStr, op, modStr = string.match(s, dicePattern)
			if countStr and sidesStr then
				local count = tonumber(countStr) or 1
				local sides = tonumber(sidesStr) or 20
				local modifier = tonumber(modStr) or 0
				if op == "-" then modifier = -modifier end

				-- Consume the matched portion
				local full = string.match(s, "^(%d+[dD]%d+%s*[%+%-]?%s*%d*)")
				if full then
					s = string.sub(s, #full + 1)
					s = string.TrimLeft(s)
					lower = string.lower(s)
				end

				return { type = "dice", count = count, sides = sides, modifier = modifier }
			end

			-- Plain number: /roll 20
			local n = string.match(s, "^(%d+)")
			if n then
				local v = tonumber(n)
				if v then
					s = string.sub(s, #n + 1)
					s = string.TrimLeft(s)
					lower = string.lower(s)
					return { type = "simple", max = v }
				end
			end
			return nil
		end

		local function eatStatArgIfPresent()
			local statName = string.match(s, "^(%a+)")
			if statName then
				s = string.sub(s, #statName + 1)
				s = string.TrimLeft(s)
				lower = string.lower(s)
				return string.lower(statName)
			end
			return nil
		end

		local function eatOneCommand()
			-- /rollstat
			if out.roll == nil then
				if eatToken("/rollstat") then
					local stat = eatStatArgIfPresent()
					out.roll = { trace = false, global = false, rollstat = stat or "luck" }
					pushOrder("roll")
					return true
				end
			else
				if eatToken("/rollstat") then
					eatStatArgIfPresent()
					return true
				end
			end

			-- rolltrace (must come before /roll)
			if out.roll == nil then
				if eatToken("/rolltrace") then
					local v = eatRollArgIfPresent()
					out.roll = { trace = true, global = false, rollarg = v }
					pushOrder("roll")
					return true
				end

				if eatToken("/groll") then
					local v = eatRollArgIfPresent()
					out.roll = { trace = false, global = true, rollarg = v }
					pushOrder("roll")
					return true
				end

				if eatToken("/roll") then
					local v = eatRollArgIfPresent()
					out.roll = { trace = false, global = false, rollarg = v }
					pushOrder("roll")
					return true
				end
			else
				-- consume extra roll tokens without changing first
				if eatToken("/rolltrace") or eatToken("/groll") or eatToken("/roll") then
					eatRollArgIfPresent()
					return true
				end
			end

			-- yell/whisper
			if out.mode == nil then
				if eatToken("/y") or eatToken("[yell]") then out.mode = "yell"; pushOrder("yell"); return true end
				if eatToken("/w") or eatToken("[whisper]") then out.mode = "whisper"; pushOrder("whisper"); return true end
			else
				-- consume extras without changing first mode
				if eatToken("/y") or eatToken("[yell]") then return true end
				if eatToken("/w") or eatToken("[whisper]") then return true end
			end

			-- /me
			if not out.isMe then
				if eatToken("/me") then out.isMe = true; return true end
			else
				if eatToken("/me") then return true end
			end

			return false
		end

		for _ = 1, 4 do
			if not eatOneCommand() then break end
		end

		out.text = s
		return out
	end
	
	local function MTChat_BroadcastRadiusSync(target)
		net.Start("mtchat_radiussync")
			net.WriteUInt(math.max(0, cvChatRadius:GetInt()), 16)
			net.WriteUInt(math.max(0, cvChatterRadius:GetInt()), 16)
			net.WriteUInt(math.max(0, cvYellAdd:GetInt()), 16)
			net.WriteUInt(math.max(0, cvWhisperSub:GetInt()), 16)
			net.WriteBool(cvAllowGlobalWhisper:GetInt() ~= 0)
		if IsValid(target) then
			net.Send(target)
		else
			net.Broadcast()
		end
	end

	-- keep clients updated if admin changes these convars
	cvars.AddChangeCallback("mtc_chatradius", function() MTChat_BroadcastRadiusSync() end, "mtchat_radiussync_chatradius")
	cvars.AddChangeCallback("mtc_chatterradius", function() MTChat_BroadcastRadiusSync() end, "mtchat_radiussync_chatterradius")
	cvars.AddChangeCallback("mtc_yelladd", function() MTChat_BroadcastRadiusSync() end, "mtchat_radiussync_yelladd")
	cvars.AddChangeCallback("mtc_whispersub", function() MTChat_BroadcastRadiusSync() end, "mtchat_radiussync_whispersub")
	cvars.AddChangeCallback("mtc_allowglobalwhisper", function() MTChat_BroadcastRadiusSync() end, "mtchat_radiussync_allowglobalwhisper")


    net.Receive("mtchat_submit", function(_, ply)
        if not IsValid(ply) or not ply:IsPlayer() then return end

        local teamChat = net.ReadBool()
        local msg = net.ReadString() or ""

        -- Basic sanity
        msg = string.gsub(msg, "\r\n", "\n")
        if #msg < 1 then return end
        if #msg > MAX_LEN then
            msg = string.sub(msg, 1, MAX_LEN)
        end
		
        local parsed = MTChat_ParseChatCommands(ply, msg)
		
		-- /roll and /rolltrace
		if parsed.roll ~= nil then
			if cvAllowRolls:GetInt() == 0 then return end

			--roll/mute check
			local check = "/roll"
			if parsed.roll.trace then
				check = "/rolltrace"
			elseif parsed.roll.global then
				check = "/groll"
			end
			if not string.find(check, "\n", 1, true) then
				local outp = hook.Run("PlayerSay", ply, check, teamChat, false)
				if outp == "" then return end
			end

			local ACTION_TOKEN = "\x01MTCHAT_ME\x02"
			local nr, ng, nb = MTChat_GetNameColor(ply)

			-- ============================================================
			-- Resolve the roll: dice notation, stat roll, or simple max
			-- ============================================================
			local rolled, rollDesc

			if parsed.roll.rollstat then
				-- /rollstat: 1d20 + stat value
				local statLookup = {
					str = "TBCSTR", strength = "TBCSTR",
					dex = "TBCDEX", dexterity = "TBCDEX",
					chr = "TBCCHR", cha = "TBCCHR", charisma = "TBCCHR",
					luck = "TBCLuck", lck = "TBCLuck",
					tech = "TBCTechnique", technique = "TBCTechnique",
				}

				local statKey = statLookup[parsed.roll.rollstat]
				local statLabel = string.upper(parsed.roll.rollstat)
				local statValue = 0

				if statKey then
					statValue = ply:GetNWInt(statKey, 0)
				else
					-- Unknown stat name, default to luck
					statKey = "TBCLuck"
					statLabel = "LUCK"
					statValue = ply:GetNWInt(statKey, 0)
				end

				local baseRoll = math.random(1, 20)
				rolled = baseRoll + statValue
				rollDesc = string.format("1d20(%d) + %s(%d) = %d", baseRoll, statLabel, statValue, rolled)

			elseif istable(parsed.roll.rollarg) and parsed.roll.rollarg.type == "dice" then
				-- Dice notation: NdN+N
				local info = parsed.roll.rollarg
				local count = math.Clamp(info.count, 1, 100)
				local sides = math.Clamp(info.sides, 2, 100000)
				local modifier = math.Clamp(info.modifier, -100000, 100000)

				local total = 0
				local rolls = {}
				for i = 1, count do
					local r = math.random(1, sides)
					rolls[#rolls + 1] = r
					total = total + r
				end

				local diceStr = count .. "d" .. sides
				local rollList = table.concat(rolls, "+")

				if modifier ~= 0 then
					local sign = modifier > 0 and "+" or ""
					rolled = total + modifier
					rollDesc = string.format("%s(%s) %s%d = %d", diceStr, rollList, sign, modifier, rolled)
				else
					rolled = total
					if count > 1 then
						rollDesc = string.format("%s(%s) = %d", diceStr, rollList, rolled)
					else
						rollDesc = string.format("%s = %d", diceStr, rolled)
					end
				end

			else
				-- Simple: /roll or /roll N
				local max = 20
				if istable(parsed.roll.rollarg) and parsed.roll.rollarg.type == "simple" then
					max = tonumber(parsed.roll.rollarg.max) or 20
				elseif tonumber(parsed.roll.rollarg) then
					max = tonumber(parsed.roll.rollarg)
				end
				max = math.floor(max)
				if max < 2 then max = 20 end
				if max > 100000 then max = 100000 end

				rolled = math.random(1, max)
				rollDesc = string.format("%d out of %d", rolled, max)
			end

			-- prefix order build: /roll /y vs /y /roll etc
			local function prefixFor(tok)
				if tok == "roll" then return "[Roll] " end
				if tok == "yell" then return "[Yell] " end
				if tok == "whisper" then return "[Whisper] " end
				return ""
			end

			local prefix = ""
			if istable(parsed.order) and #parsed.order > 0 then
				for _, t in ipairs(parsed.order) do
					prefix = prefix .. prefixFor(t)
				end
			else
				prefix = "[Roll] "
				if parsed.mode == "yell" then prefix = prefix .. "[Yell] " end
				if parsed.mode == "whisper" then prefix = prefix .. "[Whisper] " end
			end

			-- color: starting <r,g,b> overrides default name color
			local colorPrefix = parsed.prefixColor
			if colorPrefix == "" then
				colorPrefix = string.format("<%d,%d,%d>", nr, ng, nb)
			end

			local traceSuffix = ""
			local recipients = {}

			-- Determine base recipients (team vs global)
			if teamChat then
				local t = ply:Team()
				for _, p in ipairs(player.GetAll()) do
					if IsValid(p) and p:Team() == t then
						recipients[#recipients + 1] = p
					end
				end
			else
				recipients = player.GetAll()
			end
			
			if parsed.roll.global then
				recipients = player.GetAll()
				teamChat = false -- force global delivery even if they typed in team chat
			end
			
			if parsed.roll.global then
				local body = string.format(
					"%s rolled %s (Global)",
					ply:Nick(),
					rollDesc
				)

				local displayMsg = ACTION_TOKEN .. colorPrefix .. prefix .. body

				net.Start("mtchat_broadcast")
					net.WriteEntity(ply)
					net.WriteBool(false) -- force global
					net.WriteUInt(nr, 8)
					net.WriteUInt(ng, 8)
					net.WriteUInt(nb, 8)
					net.WriteString(displayMsg)
				net.Broadcast()

				return
			end

			local chatRadius = math.max(0, cvChatRadius:GetInt())
			local chatterRadius = math.max(0, cvChatterRadius:GetInt())
			local yellAdd = math.max(0, cvYellAdd:GetInt())
			local whisperSub = math.max(0, cvWhisperSub:GetInt())
			local allowGlobalWhisper = cvAllowGlobalWhisper:GetInt() ~= 0

			-- effective talk radius
			local effectiveTalk = chatRadius
			local enforceLocalEvenWhenGlobal = false

			if parsed.mode == "yell" then
				effectiveTalk = chatRadius + yellAdd
			elseif parsed.mode == "whisper" then
				if chatRadius <= 0 then
					if allowGlobalWhisper then
						enforceLocalEvenWhenGlobal = true
						effectiveTalk = whisperSub
					else
						effectiveTalk = 0
					end
				else
					effectiveTalk = math.max(0, chatRadius - whisperSub)
				end
			end

			-- rolltrace: only to self and looked-at target (if valid + in range rule)
			if parsed.roll.trace then
				local tr = ply:GetEyeTrace()
				local tgt = IsValid(tr.Entity) and tr.Entity:IsPlayer() and tr.Entity or nil

				-- must be within "yell radius" unless global chat
				local maxTraceRange = (chatRadius <= 0 and not enforceLocalEvenWhenGlobal) and math.huge or (chatRadius + yellAdd)
				if maxTraceRange <= 0 then maxTraceRange = chatRadius + yellAdd end

				local okTarget = false
				if IsValid(tgt) then
					if maxTraceRange == math.huge then
						okTarget = true
					else
						okTarget = (ply:GetPos():DistToSqr(tgt:GetPos()) <= (maxTraceRange * maxTraceRange))
					end
				end

				if okTarget then
					traceSuffix = " (Trace: " .. tgt:Nick() .. ")"
					recipients = { ply, tgt }
				else
					traceSuffix = " (Trace: No Target)"
					recipients = { ply }
				end

				local body = string.format("%s rolled %s%s", ply:Nick(), rollDesc, traceSuffix)
				local displayMsg = ACTION_TOKEN .. colorPrefix .. prefix .. body

				net.Start("mtchat_broadcast")
					net.WriteEntity(ply)
					net.WriteBool(teamChat)
					net.WriteUInt(nr, 8)
					net.WriteUInt(ng, 8)
					net.WriteUInt(nb, 8)
					net.WriteString(displayMsg)
				net.Send(recipients)
				return
			end

			-- normal /roll: follow proximity rules like chat (including chatter band)
			if (chatRadius <= 0 and not enforceLocalEvenWhenGlobal) or (effectiveTalk <= 0 and chatRadius <= 0) then
				local body = string.format("%s rolled %s", ply:Nick(), rollDesc)
				local displayMsg = ACTION_TOKEN .. colorPrefix .. prefix .. body

				net.Start("mtchat_broadcast")
					net.WriteEntity(ply)
					net.WriteBool(teamChat)
					net.WriteUInt(nr, 8)
					net.WriteUInt(ng, 8)
					net.WriteUInt(nb, 8)
					net.WriteString(displayMsg)
				net.Send(recipients)
				return
			end

			local r2 = effectiveTalk * effectiveTalk
			local c2 = (effectiveTalk + chatterRadius) * (effectiveTalk + chatterRadius)
			local senderPos = ply:GetPos()

			local body = string.format("%s rolled %s", ply:Nick(), rollDesc)
			local displayMsg = ACTION_TOKEN .. colorPrefix .. prefix .. body

			for _, hearer in ipairs(recipients) do
				if IsValid(hearer) then
					local d2 = senderPos:DistToSqr(hearer:NearestPoint(senderPos))

					if d2 <= r2 then
						net.Start("mtchat_broadcast")
							net.WriteEntity(ply)
							net.WriteBool(teamChat)
							net.WriteUInt(nr, 8)
							net.WriteUInt(ng, 8)
							net.WriteUInt(nb, 8)
							net.WriteString(displayMsg)
						net.Send(hearer)
					elseif chatterRadius > 0 and d2 <= c2 then
						local chatter = MTChat_BuildChatterLine(ply, hearer)
						net.Start("mtchat_broadcast")
							net.WriteEntity(NULL)
							net.WriteBool(false)
							net.WriteUInt(200, 8)
							net.WriteUInt(200, 8)
							net.WriteUInt(200, 8)
							net.WriteString(chatter)
						net.Send(hearer)
					end
				end
			end

			return
		end

        -- For /me we want PlayerSay to still be able to modify the "content" portion,
        -- but not to re-insert "/me". We'll pass only parsed.text through PlayerSay.
        local sayTextForHook = parsed.text
        if sayTextForHook == "" then return end


        -- Only pass through PlayerSay if message is single-line
        if not string.find(sayTextForHook, "\n", 1, true) then
            local out = hook.Run("PlayerSay", ply, sayTextForHook, teamChat, false)
            if out == "" then return end
            if isstring(out) then
                sayTextForHook = out
            end
        end

		local ACTION_TOKEN = "\x01MTCHAT_ME\x02"

		-- Now build the final message as MTChat will display it
		local displayMsg

		local nr, ng, nb = MTChat_GetNameColor(ply)

		local modePrefix = ""
		if parsed.mode == "yell" then
			modePrefix = "[Yell] "
		elseif parsed.mode == "whisper" then
			modePrefix = "[Whisper] "
		end

		if parsed.isMe then
			local prefix = parsed.prefixColor

			-- default /me color = player's name color, unless a starting <r,g,b> was provided
			if prefix == "" then
				prefix = string.format("<%d,%d,%d>", nr, ng, nb)
			end

			-- IMPORTANT: ACTION_TOKEN must be FIRST, so client detects it. modePrefix goes after the color tag so it gets colored too.
			displayMsg = ACTION_TOKEN .. prefix .. modePrefix .. ply:Nick() .. " " .. tostring(sayTextForHook or "")
		else
			-- Normal message prefix color preserved, and yell/whisper is just plain text prefix.
			displayMsg = parsed.prefixColor .. modePrefix .. tostring(sayTextForHook or "")
		end
		
        local chatRadius = math.max(0, cvChatRadius:GetInt())
        local chatterRadius = math.max(0, cvChatterRadius:GetInt())

        local yellAdd = math.max(0, cvYellAdd:GetInt())
        local whisperSub = math.max(0, cvWhisperSub:GetInt())
        local allowGlobalWhisper = cvAllowGlobalWhisper:GetInt() ~= 0

        -- Determine effective radii
        local effectiveTalk = chatRadius
        local enforceLocalEvenWhenGlobal = false
		
        -- Build base recipient set first (team vs global)
        local recipients = {}

        if teamChat then
            local t = ply:Team()
            for _, p in ipairs(player.GetAll()) do
                if IsValid(p) and p:Team() == t then
                    recipients[#recipients+1] = p
                end
            end
        else
            recipients = player.GetAll()
        end

        if parsed.mode == "yell" then
            effectiveTalk = chatRadius + yellAdd
        elseif parsed.mode == "whisper" then
            if chatRadius <= 0 then
                -- While global, allowGlobalWhisper == 1 => whisper becomes local-only (within whisperSub), with chatter band.
                -- allowGlobalWhisper == 0 => whisper is aesthetic only (still global).
                if allowGlobalWhisper then
                    enforceLocalEvenWhenGlobal = true
                    effectiveTalk = whisperSub
                else
                    effectiveTalk = 0 -- treated as global
                end
            else
                effectiveTalk = math.max(0, chatRadius - whisperSub)
            end
        end

        -- If truly global (no local enforcement), just send displayMsg to everyone.
        if (chatRadius <= 0 and not enforceLocalEvenWhenGlobal) or effectiveTalk <= 0 and chatRadius <= 0 then
            net.Start("mtchat_broadcast")
                net.WriteEntity(ply)
                net.WriteBool(teamChat)
                net.WriteUInt(nr, 8)
                net.WriteUInt(ng, 8)
                net.WriteUInt(nb, 8)
                net.WriteString(displayMsg)
            net.Send(recipients)
            return
        end

        local r2 = effectiveTalk * effectiveTalk
        local c2 = (effectiveTalk + chatterRadius) * (effectiveTalk + chatterRadius)

        local senderPos = ply:GetPos()

        for _, hearer in ipairs(recipients) do
            if IsValid(hearer) then
                local d2 = senderPos:DistToSqr(hearer:NearestPoint(senderPos))

				if d2 <= r2 then
					net.Start("mtchat_broadcast")
						net.WriteEntity(ply) -- ALWAYS send ply; client will render /me specially via ACTION_TOKEN
						net.WriteBool(teamChat)
						net.WriteUInt(nr, 8)
						net.WriteUInt(ng, 8)
						net.WriteUInt(nb, 8)
						net.WriteString(displayMsg)
					net.Send(hearer)
                elseif chatterRadius > 0 and d2 <= c2 then
                    -- in chatter band: anonymized direction hint
                    local base = "chattering"
                    if parsed.mode == "yell" then base = "yelling" end
                    if parsed.mode == "whisper" then base = "whispering" end

                    local chatter = MTChat_BuildChatterLine(ply, hearer)
                    chatter = string.gsub(chatter, "chattering", base)

                    net.Start("mtchat_broadcast")
                        net.WriteEntity(NULL)        -- invalid => client prints only body (no player name) :contentReference[oaicite:4]{index=4}
                        net.WriteBool(false)         -- don't show (TEAM) prefix; it's just ambience
                        net.WriteUInt(200, 8)        -- name color fields ignored since ply invalid; harmless
                        net.WriteUInt(200, 8)
                        net.WriteUInt(200, 8)
                        net.WriteString(chatter)
                    net.Send(hearer)

                else
                    -- too far: nothing
                end
            end
        end

    end)
	
	net.Receive("mtchat_setnamecolor", function(_, ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end

		local r = MTChat_ClampByte(net.ReadUInt(8))
		local g = MTChat_ClampByte(net.ReadUInt(8))
		local b = MTChat_ClampByte(net.ReadUInt(8))

		ply.MTChat_NameColor = { r = r, g = g, b = b }

		-- Tell everyone immediately (so caches update even before the player speaks again)
		net.Start("mtchat_namecolor_update")
			net.WriteEntity(ply)
			net.WriteUInt(r, 8)
			net.WriteUInt(g, 8)
			net.WriteUInt(b, 8)
		net.Broadcast()
	end)
	
	net.Receive("mtchat_typing", function(_, ply)
		if not IsValid(ply) or not ply:IsPlayer() then return end

		local status = net.ReadUInt(4)
		local allowAnim = net.ReadBool()
		local allowIndicator = net.ReadBool()

		ply.MTChat_TypingStatus = status
		ply.MTChat_AllowAnim = allowAnim
		ply.MTChat_AllowIndicator = allowIndicator

		net.Start("mtchat_typing")
			net.WriteEntity(ply)
			net.WriteUInt(status, 4)
			net.WriteBool(allowAnim)
			net.WriteBool(allowIndicator)
		net.Broadcast()
	end)

	hook.Add("PlayerInitialSpawn", "MTChat_NameColorSync", function(ply)
		timer.Simple(0, function()
			if not IsValid(ply) then return end

			net.Start("mtchat_namecolor_sync")
				local all = player.GetAll()
				net.WriteUInt(#all, 8)
				for _, p in ipairs(all) do
					local r,g,b = MTChat_GetNameColor(p)
					net.WriteEntity(p)
					net.WriteUInt(r, 8)
					net.WriteUInt(g, 8)
					net.WriteUInt(b, 8)
				end
			net.Send(ply)
			
			MTChat_BroadcastRadiusSync(ply)
		end)
	end)
	
	hook.Add("PlayerDisconnected", "MTChat_ClearTyping", function(ply)
		MTChat_Typing[ply] = nil
	end)

	hook.Add("PlayerDeath", "MTChat_ClearTypingDeath", function(ply)
		MTChat_Typing[ply] = nil

		net.Start("mtchat_typing")
			net.WriteEntity(ply)
			net.WriteBool(false)
			net.WriteUInt(0, 4) -- STATUS_NONE
			net.WriteBool(false)
		net.Broadcast()
	end)

    return
end

-- CLIENT

local CFG_DIR  = "mtchat"
local CFG_FILE = "mtchat/config.json"

local function clamp(v, a, b)
    v = tonumber(v) or a
    if v < a then return a end
    if v > b then return b end
    return v
end

local function ensureDir()
    if not file.IsDir(CFG_DIR, "DATA") then
        file.CreateDir(CFG_DIR)
    end
end

local function defaultConfig()
    local sw, sh = ScrW(), ScrH()

    -- default influenced by resolution/aspect ratio
    local w = math.floor(sw * 0.38)
    local h = math.floor(sh * 0.28)

    -- clamp to keep sane
    w = clamp(w, 420, math.floor(sw * 0.80))
    h = clamp(h, 220, math.floor(sh * 0.65))

    return {
        x = math.floor(sw * 0.04),
        y = math.floor(sh * 0.62),
        w = w,
        h = h,
        boxColor = { r = 0, g = 0, b = 0, a = 220 },
    }
end

local function loadConfig()
    ensureDir()
    if not file.Exists(CFG_FILE, "DATA") then
        return defaultConfig()
    end

    local raw = file.Read(CFG_FILE, "DATA")
    if not raw or raw == "" then return defaultConfig() end

    local t = util.JSONToTable(raw)
    if not istable(t) then return defaultConfig() end

    local def = defaultConfig()
    t.x = tonumber(t.x) or def.x
    t.y = tonumber(t.y) or def.y
    t.w = tonumber(t.w) or def.w
    t.h = tonumber(t.h) or def.h

    if not istable(t.boxColor) then t.boxColor = def.boxColor end
    t.boxColor.r = clamp(t.boxColor.r, 0, 255)
    t.boxColor.g = clamp(t.boxColor.g, 0, 255)
    t.boxColor.b = clamp(t.boxColor.b, 0, 255)
    t.boxColor.a = clamp(t.boxColor.a, 0, 255)

    return t
end

local function saveConfig(cfg)
    if not istable(cfg) then return end
    ensureDir()
    file.Write(CFG_FILE, util.TableToJSON(cfg, true))
end

local CFG = loadConfig()

MTChat = MTChat or {}
MTChat.ChatOpen = false
MTChat.RangeVisualActive = MTChat.RangeVisualActive or false

MTChat.Lines = MTChat.Lines or {}

MTChat.STATUS_NONE   = 0
MTChat.STATUS_TYPING = 1
MTChat.STATUS_MENU   = 2
MTChat.STATUS_AFK    = 3

-- How long messages stay on HUD (seconds)
local cvDisplayTime = CreateClientConVar("mtchat_displaytime", "8", true, false, "Seconds chat stays visible before fading")

-- Chat receive sound (clientside only)
local cvChatSound = CreateClientConVar("mtchat_chatsound", "1", true, false, "Play a sound when a chat message is received in MTChat")
local mtchat_lastSound = 0

function MTChat_MaybePlayChatSound(ply, src)
	-- Only for actual player chat messages (not server/client console/system lines)
	if src ~= "player" then return end
	if not cvChatSound:GetBool() then return end

	-- don't play for player's own messages
	-- if IsValid(ply) and ply == LocalPlayer() then return end

	-- 1 second cooldown
	if CurTime() < (mtchat_lastSound + 1) then return end
	mtchat_lastSound = CurTime()

	surface.PlaySound("common/talk.wav")
end

local cvFontSize = CreateClientConVar(
    "mtchat_fontsize",
    "20",
    true,
    false,
    "Base font size for MTChat"
)

-- Outline color for chat text (r,g,b)
local cvTextOutline = CreateClientConVar(
    "mtchat_textoutline",
    "0,0,0",
    true,
    false,
    "Outline color for MTChat text (r,g,b)"
)

local cvFontName = CreateClientConVar(
    "mtchat_fontname",
    "Arial",
    true,
    false,
    "Base font family name for MTChat (client-installed fonts)"
)

-- Max stored chat log lines (0 = unlimited)
local cvChatLogLimit = CreateClientConVar(
	"mtchat_chatloglimit",
	"500",
	true,
	false,
	"Max MTChat log lines kept clientside (0 = unlimited). Older lines are removed first."
)

-- Default text color for chat text (r,g,b)
local cvTextColor = CreateClientConVar(
    "mtchat_textcolor",
    "255,255,255",
    true,
    false,
    "Text color for MTChat messages (r,g,b)"
)

-- Chatbox background color (r,g,b,a)
local cvChatboxColor = CreateClientConVar(
    "mtchat_chatboxcolor",
    "0,0,0,200",
    true,
    false,
    "Chatbox background color (r,g,b,a)"
)

local cvNameColor = CreateClientConVar(
	"mtchat_namecolor",
	"220,190,110",
	true,
	false,
	"Your MTChat name color (r,g,b)"
)

local cvChatAnim = CreateClientConVar(
	"mtchat_chatanim",
	"1",
	true,
	false,
	"Enable chat gesture animation while typing in MTChat"
)

local cvChatIndicator = CreateClientConVar(
	"mtchat_chatindicator",
	"1",
	true,
	false,
	"Show speech bubble above players typing in MTChat"
)

local cvChatRangeVisual = CreateClientConVar(
    "mtchat_chatrangevisual",
    "1",
    true,
    false,
    "Show a filled circle indicating your current MTChat proximity range"
)

local cvChatRangeVisualColor = CreateClientConVar(
    "mtchat_chatrangevisualcolor",
    "100,150,150,100",
    true,
    false,
    "Color for mtchat_chatrangevisual (r,g,b,a)"
)

local function MTChat_RebuildFonts()
    local size = math.Clamp(cvFontSize:GetInt(), 12, 32)

    local baseFont = string.Trim(cvFontName:GetString() or "Arial")
    if baseFont == "" then baseFont = "Arial" end

    surface.CreateFont("MTChat_Default", {
        font = baseFont,
        size = size,
        weight = 500,
        antialias = true
    })

    surface.CreateFont("MTChat_Default_Bold", {
        font = baseFont,
        size = size,
        weight = 900,
        antialias = true
    })

    surface.CreateFont("MTChat_Default_Italic", {
        font = baseFont,
        size = size,
        weight = 500,
        italic = true,
        antialias = true
    })
	
    -- Arial fallback (for p5hatty font)
    surface.CreateFont("MTChat_Alt_Arial", {
        font = "Arial",
        size = size,
        weight = 500,
        antialias = true
    })

    -- clear caches so everything rebuilds with the new font
    for _, ln in ipairs(MTChat.Lines) do
        ln.mk = nil
        ln.hudMk = nil
        ln.shadowMk = nil
        ln.hudShadow = nil
        ln._mkW = nil
        ln._hudW = nil
        ln._shadowW = nil
        ln._hudShadowW = nil
    end

    if IsValid(ENTRY) then
        ENTRY:SetFont("MTChat_Default")
    end
end

local MTCHAT_DEFAULT_CLIENT = { 90, 140, 220 }  -- client
local MTCHAT_DEFAULT_SERVER = { 235, 215, 120 } -- server

local function MTChat_DefaultRGBForSrc(src)
    if src == "client" then return MTCHAT_DEFAULT_CLIENT[1], MTCHAT_DEFAULT_CLIENT[2], MTCHAT_DEFAULT_CLIENT[3] end
    if src == "server" then return MTCHAT_DEFAULT_SERVER[1], MTCHAT_DEFAULT_SERVER[2], MTCHAT_DEFAULT_SERVER[3] end
    return 255, 255, 255
end

local MTCHAT_TEAM_NAME_COLOR = { 140, 220, 140 } -- soft green
local MTCHAT_TEAM_PREFIX    = "(TEAM) "

MTChat_RebuildFonts()
cvars.AddChangeCallback("mtchat_fontsize", MTChat_RebuildFonts, "mtchat_fontsize_update")
cvars.AddChangeCallback("mtchat_fontname", MTChat_RebuildFonts, "mtchat_fontname_update")

MTChat.Typing = MTChat.Typing or {} -- [ply] = bool
MTChat.NameColors = MTChat.NameColors or {} -- [steamid64] = {r,g,b}

MTChat.LocalTypingState = MTChat.LocalTypingState or false

local function MTChat_ParseRGBCVar(str, dr, dg, db)
	str = tostring(str or "")
	local r,g,b = string.match(str, "%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*")
	r = math.Clamp(tonumber(r) or dr or 120, 0, 255)
	g = math.Clamp(tonumber(g) or dg or 120, 0, 255)
	b = math.Clamp(tonumber(b) or db or 120, 0, 255)
	return r,g,b
end

local function MTChat_SendMyNameColor()
	local r,g,b = MTChat_ParseRGBCVar(cvNameColor:GetString(), 120,120,120)
	net.Start("mtchat_setnamecolor")
		net.WriteUInt(r, 8)
		net.WriteUInt(g, 8)
		net.WriteUInt(b, 8)
	net.SendToServer()
end

-- send once after client loads in
timer.Simple(1, MTChat_SendMyNameColor)

-- send on changes
cvars.AddChangeCallback("mtchat_namecolor", function()
	timer.Simple(0, MTChat_SendMyNameColor)
end, "mtchat_namecolor_send")


-- Hide default chat HUD while MTChat is active (or always, since MTChat is the chat)
hook.Add("HUDShouldDraw", "MTChat_HideDefaultChat", function(name)
    if name == "CHudChat" then
        return false
    end
end)

local function translateToMarkup(input)
    if not isstring(input) then return "" end
    local s = input

    -- Normalize newlines
    s = string.gsub(s, "\r\n", "\n")
	
    -- Special per-character font fallback for p5hatty
    local useArialFallback = (string.lower(string.Trim(cvFontName:GetString() or "")) == "p5hatty")

    local ARIAL_SENTINEL = "\x01MTCHAT_ARIAL\x02"
    local arialChars = {}

    if useArialFallback then
        -- Replace &, [, ], | with sentinels before escaping so we don't break special character entities later
        s = string.gsub(s, "[%&%[%]%|]", function(ch)
            local id = #arialChars + 1
            arialChars[id] = ch
            return ARIAL_SENTINEL .. id .. ARIAL_SENTINEL
        end)
    end

    -- Escape ampersand first
    s = string.gsub(s, "&", "&amp;")

    -- protect valid color tags so they survive escaping
    local COLOR_SENTINEL = "\x01MTCHAT_COLOR\x02"
    local colors = {}

    s = string.gsub(s, "<%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*>", function(r, g, b)
        r = clamp(r, 0, 255)
        g = clamp(g, 0, 255)
        b = clamp(b, 0, 255)

        local id = #colors + 1
        colors[id] = string.format("<color=%d,%d,%d>", r, g, b)
        return COLOR_SENTINEL .. id .. COLOR_SENTINEL
    end)

    -- Escape all remaining < and >
    s = string.gsub(s, "<", "&lt;")
    s = string.gsub(s, ">", "&gt;")

    -- Restore color tags
    s = string.gsub(s, COLOR_SENTINEL .. "(%d+)" .. COLOR_SENTINEL, function(id)
        return colors[tonumber(id)] or ""
    end)

	-- Bold + Italic (***text***)
	s = string.gsub(
		s,
		"%*%*%*([^%*\n]-)%*%*%*",
		"<font=MTChat_Default_Bold><font=MTChat_Default_Italic>%1</font></font>"
	)

	-- Bold (**text**)
	s = string.gsub(
		s,
		"%*%*([^%*\n]-)%*%*",
		"<font=MTChat_Default_Bold>%1</font>"
	)

	-- Italic (*text*)
	s = string.gsub(
		s,
		"%*([^%*\n]-)%*",
		"<font=MTChat_Default_Italic>%1</font>"
	)
	
    -- Newlines
    s = string.gsub(s, "\n", "<br>\n")
	
    -- Restore Arial fallback characters
    if useArialFallback then
        s = string.gsub(s, ARIAL_SENTINEL .. "(%d+)" .. ARIAL_SENTINEL, function(id)
            local ch = arialChars[tonumber(id)]
            if not ch then return "" end

            -- escape ampersand for markup
            if ch == "&" then ch = "&amp;" end

            return "<font=MTChat_Alt_Arial>" .. ch .. "</font>"
        end)
    end

    return s
end

-- UI + log

local MTChat = MTChat or {}
MTChat.Lines = MTChat.Lines or {} -- each line: { time=RealTime(), markup=..., raw=..., ply=..., team=... }

local function MTChat_GetTextColor(alpha)
    local str = cvTextColor:GetString() or "255,255,255"

    local r, g, b = string.match(str, "%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*")
    r = math.Clamp(tonumber(r) or 255, 0, 255)
    g = math.Clamp(tonumber(g) or 255, 0, 255)
    b = math.Clamp(tonumber(b) or 255, 0, 255)

    return Color(r, g, b, alpha or 255)
end

local function MTChat_GetChatboxColor()
    local cvar = cvChatboxColor or GetConVar("mtchat_chatboxcolor")
    if not cvar then
        return Color(0, 0, 0, 200)
    end

    local str = cvar:GetString() or "0,0,0,200"

    local r, g, b, a = string.match(str, "%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*")
    r = math.Clamp(tonumber(r) or 0, 0, 255)
    g = math.Clamp(tonumber(g) or 0, 0, 255)
    b = math.Clamp(tonumber(b) or 0, 0, 255)
    a = math.Clamp(tonumber(a) or 200, 0, 255)

    return Color(r, g, b, a)
end

local function MTChat_ApplyChatboxColor()
    if not istable(CFG) then return end
    CFG.boxColor = CFG.boxColor or { r = 0, g = 0, b = 0, a = 200 }

    local c = MTChat_GetChatboxColor()
    CFG.boxColor.r, CFG.boxColor.g, CFG.boxColor.b, CFG.boxColor.a = c.r, c.g, c.b, c.a

    if IsValid(PANEL) then
        PANEL:InvalidateLayout(true)
    end
end

cvars.AddChangeCallback("mtchat_chatboxcolor", function()
    timer.Simple(0, MTChat_ApplyChatboxColor)
end, "MTChat_ChatboxColorChanged")

timer.Simple(0, MTChat_ApplyChatboxColor)


local function MTChat_GetOutlineColor()
    local str = cvTextOutline:GetString() or "0,0,0"

    local r, g, b = string.match(str, "%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*")
    r = math.Clamp(tonumber(r) or 0, 0, 255)
    g = math.Clamp(tonumber(g) or 0, 0, 255)
    b = math.Clamp(tonumber(b) or 0, 0, 255)

    return Color(r, g, b, 255)
end

local function buildLineMarkup(ply, teamChat, msg, maxWidth, src, nameCol)
    local ACTION_TOKEN = "\x01MTCHAT_ME\x02"

    local isAction = false
    if isstring(msg) and string.sub(msg, 1, #ACTION_TOKEN) == ACTION_TOKEN then
        isAction = true
        msg = string.sub(msg, #ACTION_TOKEN + 1)
    end

    local body = translateToMarkup(msg)

    local nameR, nameG, nameB = 200, 200, 200
    if istable(nameCol) then
        nameR = math.Clamp(tonumber(nameCol.r) or 200, 0, 255)
        nameG = math.Clamp(tonumber(nameCol.g) or 200, 0, 255)
        nameB = math.Clamp(tonumber(nameCol.b) or 200, 0, 255)
    end

    local full
    if IsValid(ply) then
        local name = ply:Nick()

        if isAction then
            -- msg already contains "Name action..." and may start with <r,g,b> markup tags.
			if teamChat then
				local pr, pg, pb = MTCHAT_TEAM_NAME_COLOR[1], MTCHAT_TEAM_NAME_COLOR[2], MTCHAT_TEAM_NAME_COLOR[3]
				full = string.format(
					"<font=MTChat_Default><color=%d,%d,%d>%s</color>%s</font>",
					pr, pg, pb, MTCHAT_TEAM_PREFIX,
					translateToMarkup(msg)
				)
			else
				full = string.format("<font=MTChat_Default>%s</font>", translateToMarkup(msg))
			end
        else
            if teamChat then
                local pr, pg, pb = MTCHAT_TEAM_NAME_COLOR[1], MTCHAT_TEAM_NAME_COLOR[2], MTCHAT_TEAM_NAME_COLOR[3]
                local tc = MTChat_GetTextColor(255)

                full = string.format(
                    "<font=MTChat_Default><color=%d,%d,%d>%s</color><color=%d,%d,%d>%s: </color><color=%d,%d,%d>%s</color></font>",
                    pr, pg, pb,
                    MTCHAT_TEAM_PREFIX,
                    nameR, nameG, nameB,
                    name,
                    tc.r, tc.g, tc.b,
                    body
                )
            else
                local tc = MTChat_GetTextColor(255)
                full = string.format(
                    "<font=MTChat_Default><color=%d,%d,%d>%s: </color><color=%d,%d,%d>%s</color></font>",
                    nameR, nameG, nameB,
                    name,
                    tc.r, tc.g, tc.b,
                    body
                )
            end
        end
    else
        local r, g, b = MTChat_DefaultRGBForSrc(src)
        full = string.format("<font=MTChat_Default><color=%d,%d,%d>%s</color></font>", r, g, b, body)
    end

    local ok, mk = pcall(markup.Parse, full, maxWidth or 600)
    if ok and mk then return mk end

    -- fallback
    local safeBody = string.gsub(string.gsub(tostring(msg or ""), "&", "&amp;"), "\n", "<br>")
    if IsValid(ply) then
        local name = ply:Nick()
        local tc = MTChat_GetTextColor(255)
        full = string.format(
            "<font=MTChat_Default><color=%d,%d,%d>%s: </color><color=%d,%d,%d>%s</color></font>",
            nameR, nameG, nameB,
            name,
            tc.r, tc.g, tc.b,
            safeBody
        )
    else
        local r, g, b = MTChat_DefaultRGBForSrc(src)
        full = string.format("<font=MTChat_Default><color=%d,%d,%d>%s</color></font>", r, g, b, safeBody)
    end

    local ok2, mk2 = pcall(markup.Parse, full, maxWidth or 600)
    if ok2 and mk2 then return mk2 end
    return nil
end

local function buildLineMarkupShadow(ply, teamChat, msg, maxWidth, src)
    local ACTION_TOKEN = "\x01MTCHAT_ME\x02"

    local isAction = false
    if isstring(msg) and string.sub(msg, 1, #ACTION_TOKEN) == ACTION_TOKEN then
        isAction = true
        msg = string.sub(msg, #ACTION_TOKEN + 1)
    end

    local body = translateToMarkup(msg)

    local full
    if IsValid(ply) then
        local name = ply:Nick()

        if isAction then
            if teamChat then
                full = string.format("<font=MTChat_Default>%s%s</font>", MTCHAT_TEAM_PREFIX, translateToMarkup(msg))
            else
                full = string.format("<font=MTChat_Default>%s</font>", translateToMarkup(msg))
            end
        else
			if teamChat then
				full = string.format(
					"<font=MTChat_Default><color=255,255,255>%s</color><color=255,255,255>%s: </color><color=255,255,255>%s</color></font>",
					MTCHAT_TEAM_PREFIX,
					name,
					body
				)
			else
				full = string.format(
					"<font=MTChat_Default><color=255,255,255>%s: </color><color=255,255,255>%s</color></font>",
					name,
					body
				)
			end
        end
    else
        full = string.format("<font=MTChat_Default>%s</font>", body)
    end

	-- force ALL markup colors to outline color, but KEEP color segmentation
	local c = MTChat_GetOutlineColor()
	local shadowTag = string.format("<color=%d,%d,%d>", c.r, c.g, c.b)

	-- Replace every <color=r,g,b> with the shadow color (keep </color> as-is)
	full = string.gsub(full, "<color=%s*%d+%s*,%s*%d+%s*,%s*%d+%s*>", shadowTag)

	-- If somehow no color tags exist at all, wrap the whole thing once
	if not string.find(full, "<color=", 1, true) then
		full = string.gsub(full, "^<font=MTChat_Default>", "<font=MTChat_Default>" .. shadowTag)
		full = full .. "</color>"
	end

    local ok, mk = pcall(markup.Parse, full, maxWidth or 600)
    if ok and mk then return mk end
    return nil
end

local function pushLine(ply, teamChat, msg, src)
    table.insert(MTChat.Lines, {
        ply = ply,
        team = teamChat,
        raw = msg,
        src = src or (IsValid(ply) and "player" or "server"),
        t = RealTime(),
        mk = nil,
        hudMk = nil,
        shadowMk = nil,
        hudShadow = nil,
        _hudW = nil,
        _mkW = nil,
        _shadowW = nil,
        _hudShadowW = nil
    })

    -- Trim by user-set limit (0 = unlimited)
    local limit = math.max(0, cvChatLogLimit:GetInt())
    if limit > 0 then
        while #MTChat.Lines > limit do
            table.remove(MTChat.Lines, 1)
        end
    end
	
	if MTChat.ChatOpen then
		MTChat_RecalcScrollCanvas()
	end
end

local function MTChat_StripActionToken(s)
	s = tostring(s or "")
	local ACTION_TOKEN = "\x01MTCHAT_ME\x02"
	if string.sub(s, 1, #ACTION_TOKEN) == ACTION_TOKEN then
		s = string.sub(s, #ACTION_TOKEN + 1)
	end
	-- remove any other occurrences
	s = string.gsub(s, ACTION_TOKEN, "")
	return s
end


local function MTChat_StripForConsole(s)
    s = MTChat_StripActionToken(s)

    -- remove rgb tags
    s = string.gsub(s, "<%s*%d+%s*,%s*%d+%s*,%s*%d+%s*>", "")

    -- keep console newlines
    return s
end

local function MTChat_StripForClipboard(s)
	s = MTChat_StripActionToken(s)

	-- remove <r,g,b> inline color tags
	s = string.gsub(s, "<%s*%d+%s*,%s*%d+%s*,%s*%d+%s*>", "")

	-- remove * ** *** markers (clipboard should be plain)
	s = string.gsub(s, "%*%*%*([^%*\n]-)%*%*%*", "%1")
	s = string.gsub(s, "%*%*([^%*\n]-)%*%*", "%1")
	s = string.gsub(s, "%*([^%*\n]-)%*", "%1")
	return s
end

local function MTChat_BuildPlainLine(ln)
	if not ln then return "" end
	return MTChat_StripForClipboard(ln.raw)
end

local function MTChat_BuildFormattedLine(ln)
	if not ln then return "" end
	return MTChat_StripActionToken(tostring(ln.raw or ""))
end

local function MTChat_GetPlayerNameRGB(ln)
	if ln and istable(ln.nameCol) then
		return ln.nameCol.r or 200, ln.nameCol.g or 200, ln.nameCol.b or 200
	end
	if ln and IsValid(ln.ply) and MTChat.NameColors then
		local c = MTChat.NameColors[ln.ply:SteamID64()]
		if istable(c) then
			return c.r or 200, c.g or 200, c.b or 200
		end
	end
	return 200, 200, 200
end

local function MTChat_PrintConsoleWithInlineColors(text, defaultCol)
	text = tostring(text or "")
	defaultCol = defaultCol or Color(255,255,255)

	-- Current active color
	local cur = Color(defaultCol.r, defaultCol.g, defaultCol.b)

	local i = 1
	while true do
		local s, e, r, g, b = string.find(text, "<%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*>", i)
		if not s then
			local tail = string.sub(text, i)
			if tail ~= "" then
				MsgC(cur, tail)
			end
			break
		end

		-- print chunk before tag
		if s > i then
			MsgC(cur, string.sub(text, i, s - 1))
		end

		-- apply new color
		cur = Color(
			math.Clamp(tonumber(r) or cur.r, 0, 255),
			math.Clamp(tonumber(g) or cur.g, 0, 255),
			math.Clamp(tonumber(b) or cur.b, 0, 255)
		)

		i = e + 1
	end
end

local function MTChat_PrintLineToConsole(ply, teamChat, msg)
	local ACTION_TOKEN = "\x01MTCHAT_ME\x02"
	msg = tostring(msg or "")

	local isAction = false
	if string.sub(msg, 1, #ACTION_TOKEN) == ACTION_TOKEN then
		isAction = true
		msg = string.sub(msg, #ACTION_TOKEN + 1) -- strip token so it never prints
	end

	-- default body color = mtchat_textcolor
	local tc = MTChat_GetTextColor(255)
	local defaultBody = Color(tc.r, tc.g, tc.b)

	-- name color (what you already sync)
	local nameCol = Color(200,200,200)
	if IsValid(ply) and ply:IsPlayer() then
		local c = MTChat.NameColors and MTChat.NameColors[ply:SteamID64()]
		if istable(c) then
			nameCol = Color(c.r or 200, c.g or 200, c.b or 200)
		end
	end

	-- Team prefix
	if teamChat then
		MsgC(Color(MTCHAT_TEAM_NAME_COLOR[1], MTCHAT_TEAM_NAME_COLOR[2], MTCHAT_TEAM_NAME_COLOR[3]), MTCHAT_TEAM_PREFIX)
	end

	if IsValid(ply) and ply:IsPlayer() then
		if isAction then
			-- /me already contains name + text (and usually starts with <r,g,b>), so just print it colored
			MTChat_PrintConsoleWithInlineColors(msg, defaultBody)
			MsgC(Color(255,255,255), "\n")
		else
			-- Normal chat line name in name color, body in text color with inline overrides
			MsgC(nameCol, ply:Nick())
			MsgC(Color(255,255,255), ": ")
			MTChat_PrintConsoleWithInlineColors(msg, defaultBody)
			MsgC(Color(255,255,255), "\n")
		end
	else
		-- system/server line: just apply inline colors if present
		MTChat_PrintConsoleWithInlineColors(msg, defaultBody)
		MsgC(Color(255,255,255), "\n")
	end
end

hook.Add("ChatText", "MTChat_CaptureChatText", function(index, name, text, msgType)
    if not isstring(text) or text == "" then return end

	local auto = (MTChat.ChatOpen and MTChat_IsNearBottom(3))
	
    pushLine(NULL, false, text, "server")
	
	if auto then MTChat_RequestScrollToBottom() end
end)


local mtchat_oldAddText = chat.AddText
local mtchat_inAddText = false

local function MTChat_AddTextArgsToRaw(...)
    local out = {}

    for _, v in ipairs({...}) do
        if IsColor(v) then
            table.insert(out, string.format("<%d,%d,%d>", v.r or 255, v.g or 255, v.b or 255))
        elseif IsValid(v) and v:IsPlayer() then
            table.insert(out, v:Nick())
        else
            table.insert(out, tostring(v))
        end
    end

    return table.concat(out, "")
end

function chat.AddText(...)
    mtchat_oldAddText(...)

    if mtchat_inAddText then return end
    mtchat_inAddText = true

    -- player check failsafe
    for _, v in ipairs({...}) do
        if IsValid(v) and v:IsPlayer() then
            mtchat_inAddText = false
            return
        end
    end

    local raw = MTChat_AddTextArgsToRaw(...)
    if isstring(raw) and raw ~= "" then
		local auto = (MTChat.ChatOpen and MTChat_IsNearBottom(3))
		pushLine(NULL, false, raw, "client")

		-- always autoscroll while chat is open
		if auto then MTChat_RequestScrollToBottom() end
    end

    mtchat_inAddText = false
end

function MTChat_RecalcScrollCanvas()
	if not IsValid(SCROLL) then return end
	if not IsValid(MTChat._ScrollDraw) or not MTChat._ScrollEstimate then return end

	local draw = MTChat._ScrollDraw
	local pad = 2
	local maxW = math.max(0, draw:GetWide() - pad * 2)
	if maxW <= 0 then return end

	local totalH = pad
	for i = 1, #MTChat.Lines do
		totalH = totalH + MTChat._ScrollEstimate(MTChat.Lines[i], maxW)
	end

	local viewportH = SCROLL:GetTall()
	local panelH = math.max(totalH, viewportH)

	if draw._panelH ~= panelH then
		draw._panelH = panelH
		draw:SetTall(panelH)
		draw:InvalidateLayout(true)
	end

	SCROLL:GetCanvas():InvalidateLayout(true)
	SCROLL:InvalidateLayout(true)
	SCROLL:PerformLayout()
end

function MTChat_IsNearBottom(allowedLines)
    if not IsValid(SCROLL) or not IsValid(SCROLL.VBar) then return true end

    MTChat_RecalcScrollCanvas()

    local bar = SCROLL.VBar

    local canvasH = SCROLL:GetCanvas():GetTall()
    local viewH   = SCROLL:GetTall()
    local bottomScroll = math.max(0, canvasH - viewH)

    local lines = tonumber(allowedLines) or 3

    surface.SetFont("MTChat_Default")
    local _, lineH = surface.GetTextSize("Ag")
    lineH = math.max(lineH, 16)

    local allowancePx = (lineH + 6) * lines

    local distanceFromBottom = bottomScroll - bar:GetScroll()
    return distanceFromBottom <= (allowancePx + 2)
end

function MTChat_ScrollToBottom()
    if not IsValid(SCROLL) or not IsValid(SCROLL.VBar) then return end

    MTChat_RecalcScrollCanvas()

    local bar = SCROLL.VBar

    local canvasH = SCROLL:GetCanvas():GetTall()
    local viewH   = SCROLL:GetTall()
    local bottomScroll = math.max(0, canvasH - viewH)

    bar:SetScroll(bottomScroll)
end

function MTChat_RequestScrollToBottom()
	if not MTChat.ChatOpen then return end
	if not IsValid(SCROLL) or not IsValid(SCROLL.VBar) then return end

	-- Restartable "pin to bottom" job: keep setting scroll for a few frames
	timer.Remove("mtchat_force_scrollbottom")
	timer.Create("mtchat_force_scrollbottom", 0, 4, function()
		if not MTChat.ChatOpen or not IsValid(SCROLL) or not IsValid(SCROLL.VBar) then
			timer.Remove("mtchat_force_scrollbottom")
			return
		end

		-- Make sure sizes/layout update before pinning
		MTChat_RecalcScrollCanvas()
		SCROLL:GetCanvas():InvalidateLayout(true)
		SCROLL:InvalidateLayout(true)
		SCROLL:PerformLayout()

		-- Clamp-to-bottom even if CanvasSize changes again next frame
		SCROLL.VBar:SetScroll(1e9)
	end)
end


MTChat.AutoScrollLock = MTChat.AutoScrollLock or false

function MTChat_UpdateAutoScrollLock()
    MTChat.AutoScrollLock = not MTChat_IsNearBottom(3)
end

local function MTChat_DrawMarkupShadowed(mainMk, shadowMk, x, y)
    if shadowMk then
        shadowMk:Draw(x + 1, y + 1, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    if mainMk then
        mainMk:Draw(x, y, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end
end

local function MTChat_DrawBottomStack(lines, x, y, maxW, boxH, alphaFunc)
    -- draw newest at bottom
    local bottom = y + boxH

    for i = #lines, 1, -1 do
        local ln = lines[i]

        if not ln.hudMk or ln._hudW ~= maxW then
            ln._hudW = maxW
            ln.hudMk = buildLineMarkup(ln.ply, ln.team, ln.raw, maxW, ln.src, ln.nameCol)
        end
		
		if not ln.hudShadow or ln._hudShadowW ~= maxW then
			ln._hudShadowW = maxW
			ln.hudShadow = buildLineMarkupShadow(ln.ply, ln.team, ln.raw, maxW, ln.src)
		end
		
		if ln.hudMk and ln.hudShadow and ln.hudMk:GetHeight() ~= ln.hudShadow:GetHeight() then
			ln._hudShadowW = maxW
			ln.hudShadow = buildLineMarkupShadow(ln.ply, ln.team, ln.raw, maxW, ln.src)
		end

        local mk = ln.hudMk
        if mk then
            local a = 1
            if alphaFunc then
                a = alphaFunc(ln)
                if a <= 0 then continue end
            end

            local h = mk:GetHeight()
            bottom = bottom - h

            if bottom < y then break end

            surface.SetAlphaMultiplier(a)
            MTChat_DrawMarkupShadowed(mk, ln.hudShadow, x, bottom)
            surface.SetAlphaMultiplier(1)

            bottom = bottom - 4
        end
    end
end


-- show recent lines while chatbox is closed
hook.Add("HUDPaint", "MTChat_HUDDisplay", function()
    if MTChat.ChatOpen then return end

    local displayTime = math.max(0, cvDisplayTime:GetFloat())
    if displayTime <= 0 then return end

    local fadeTime = 1.0 -- fade out time
    local now = RealTime()

	local marginL, marginT, marginR, marginB = 10, 28, 10, 42
	local pad = 2

	-- Scrollbar width
	local vbarW = 16

	local PREVIEW_NUDGE_X = 5   -- offset right
	local PREVIEW_NUDGE_Y = 50   -- offset up

	local x = CFG.x + marginL + pad + PREVIEW_NUDGE_X
	local y = CFG.y + marginT + pad - PREVIEW_NUDGE_Y
	local maxW = (CFG.w - marginL - marginR - vbarW) - (pad * 2)
	local boxH = (CFG.h - marginT - marginB) - (pad * 2)


    -- draw last N lines that are still within displayTime + fadeTime
    local drawn = 0
    local maxLines = 8

    -- build a list first, oldest to newest among visible
    local visible = {}
    for i = #MTChat.Lines, 1, -1 do
        local ln = MTChat.Lines[i]
        local age = now - (ln.t or now)
        if age <= (displayTime + fadeTime) then
            table.insert(visible, 1, ln)
            if #visible >= maxLines then break end
        else
            -- since we're going backwards and older ones will only be older, we can stop
            break
        end
    end

	MTChat_DrawBottomStack(visible, x, y, maxW, boxH, function(ln)
		local age = now - (ln.t or now)

		local alpha = 1
		if age > displayTime then
			local t = (age - displayTime) / fadeTime
			alpha = 1 - clamp(t, 0, 1)
		end
		return alpha
	end)

end)

net.Receive("mtchat_broadcast", function()
	local ply = net.ReadEntity()
	local teamChat = net.ReadBool()
	local nr = net.ReadUInt(8)
	local ng = net.ReadUInt(8)
	local nb = net.ReadUInt(8)
	local msg = net.ReadString() or ""

    local auto = MTChat.ChatOpen and MTChat_IsNearBottom(3)
	pushLine(ply, teamChat, msg, IsValid(ply) and "player" or "server")

	local ln = MTChat.Lines[#MTChat.Lines]
	if ln then
		ln.nameCol = { r = nr, g = ng, b = nb }
	end

	if IsValid(ply) then
		MTChat.NameColors[ply:SteamID64()] = { r = nr, g = ng, b = nb }
	end
	
	MTChat_PrintLineToConsole(ply, teamChat, msg)
	
	MTChat_MaybePlayChatSound(ply, IsValid(ply) and "player" or "server")

	if auto then MTChat_RequestScrollToBottom() end
end)

net.Receive("mtchat_namecolor_sync", function()
	local n = net.ReadUInt(8)
	for i = 1, n do
		local ply = net.ReadEntity()
		local r = net.ReadUInt(8)
		local g = net.ReadUInt(8)
		local b = net.ReadUInt(8)

		if IsValid(ply) and ply:IsPlayer() then
			MTChat.NameColors[ply:SteamID64()] = { r = r, g = g, b = b }
		end
	end
end)

net.Receive("mtchat_namecolor_update", function()
	local ply = net.ReadEntity()
	local r = net.ReadUInt(8)
	local g = net.ReadUInt(8)
	local b = net.ReadUInt(8)

	if IsValid(ply) and ply:IsPlayer() then
		MTChat.NameColors[ply:SteamID64()] = { r = r, g = g, b = b }
	end
end)

net.Receive("mtchat_typing", function()
	local ply = net.ReadEntity()
	local status = net.ReadUInt(4)
	local allowAnim = net.ReadBool()
	local allowIndicator = net.ReadBool()

	if IsValid(ply) and ply:IsPlayer() then
		MTChat.Typing[ply] = {
			status = status,
			anim = allowAnim,
			indicator = allowIndicator
		}
	end
end)

MTChat.ServerRadius = MTChat.ServerRadius or 0
MTChat.ServerChatterRadius = MTChat.ServerChatterRadius or 0
MTChat.ServerYellAdd = MTChat.ServerYellAdd or 0
MTChat.ServerWhisperSub = MTChat.ServerWhisperSub or 0
MTChat.ServerAllowGlobalWhisper = (MTChat.ServerAllowGlobalWhisper ~= false)

net.Receive("mtchat_radiussync", function()
    MTChat.ServerRadius = net.ReadUInt(16)
    MTChat.ServerChatterRadius = net.ReadUInt(16)
    MTChat.ServerYellAdd = net.ReadUInt(16)
    MTChat.ServerWhisperSub = net.ReadUInt(16)
    MTChat.ServerAllowGlobalWhisper = net.ReadBool()
end)


-- Chatbox panel

local PANEL, ENTRY, SCROLL
local activeTeamChat = false

local function applyBoundsToCfg()
    local sw, sh = ScrW(), ScrH()

    CFG.w = clamp(CFG.w, 320, math.floor(sw * 0.95))
    CFG.h = clamp(CFG.h, 180, math.floor(sh * 0.95))

    CFG.x = clamp(CFG.x, 0, sw - CFG.w)
    CFG.y = clamp(CFG.y, 0, sh - CFG.h)
end

local MTCHAT_FADE_TIME = 0.05
local MTCHAT_FADE_OUT_TIME = 0.05
local mtchat_closing = false

local function MTChat_ParseRGBA(str, dr, dg, db, da)
    str = tostring(str or "")
    local r,g,b,a = string.match(str, "%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*,%s*(%d+)%s*")
    r = math.Clamp(tonumber(r) or dr or 155, 0, 255)
    g = math.Clamp(tonumber(g) or dg or 155, 0, 255)
    b = math.Clamp(tonumber(b) or db or 155, 0, 255)
    a = math.Clamp(tonumber(a) or da or 75, 0, 255)
    return r,g,b,a
end

local function MTChat_CurrentTypedMode()
    if not MTChat.ChatOpen then return nil end
    if not IsValid(ENTRY) then return nil end
    if not ENTRY:HasFocus() then return nil end

    local s = tostring(ENTRY:GetText() or "")
    s = string.TrimLeft(s)
    if s == "" then return nil end

    local lower = string.lower(s)

    -- only needs to react immediately to the prefix existing or being deleted
    if string.match(lower, "^/y%s") or string.match(lower, "^%[yell%]%s") then return "yell" end
    if string.match(lower, "^/w%s") or string.match(lower, "^%[whisper%]%s") then return "whisper" end
    return nil
end

local function MTChat_GetEffectiveVisualRadius()
    local base = tonumber(MTChat.ServerRadius) or 0
    local yellAdd = tonumber(MTChat.ServerYellAdd) or 0
    local whisperSub = tonumber(MTChat.ServerWhisperSub) or 0
    local allowGlobalWhisper = (MTChat.ServerAllowGlobalWhisper ~= false)

    local mode = MTChat_CurrentTypedMode()

    -- If server is global, only show circle while whispering (per your requirement)
    if base <= 0 then
        if mode == "whisper" and allowGlobalWhisper then
            return math.max(0, whisperSub)
        end
        return 0
    end

    if mode == "yell" then
        return math.max(0, base + yellAdd)
    elseif mode == "whisper" then
        return math.max(0, base - whisperSub)
    end

    return math.max(0, base)
end

local function MTChat_DrawFilledCircle2D(radius, segments)
    local seg = math.max(16, segments or 64)
    local verts = {}
    verts[#verts + 1] = { x = 0, y = 0 }

    for i = 0, seg do
        local a = (i / seg) * math.pi * 2
        verts[#verts + 1] = { x = math.cos(a) * radius, y = math.sin(a) * radius }
    end

    surface.DrawPoly(verts)
end

local function MTChat_GetGroundForCircle(ply)
	if not IsValid(ply) then return nil end

	-- Cache per-frame so we don't do a bunch of traces multiple times in one frame
	ply._mtchat_groundCache = ply._mtchat_groundCache or {}
	local cache = ply._mtchat_groundCache
	local fn = FrameNumber()

	if cache.fn == fn and cache.pos and cache.nrm then
		return cache.pos, cache.nrm
	end

	local basePos = ply:GetPos()

	-- Center trace (stable normal)
	local start  = basePos + Vector(0, 0, 32)
	local finish = basePos - Vector(0, 0, 256)

	local trCenter = util.TraceLine({
		start  = start,
		endpos = finish,
		filter = ply,
		mask   = MASK_SOLID_BRUSHONLY
	})

    local hitPos = trCenter.Hit and trCenter.HitPos or basePos
    local nrm    = trCenter.Hit and trCenter.HitNormal or Vector(0, 0, 1)

    -- Prevent the circle from snapping way down off cliffs/ledges. If the player is above ground by "too much", clamp the circle height.
    local MAX_DROP_GROUNDED = 64
    local MAX_DROP_AIR      = 48

    local maxDrop = ply:OnGround() and MAX_DROP_GROUNDED or MAX_DROP_AIR
    local dz = basePos.z - hitPos.z

    if dz > maxDrop then
        hitPos = Vector(hitPos.x, hitPos.y, basePos.z - maxDrop)
        nrm = Vector(0, 0, 1) -- keep it flat when we're clamping
    end

	-- Sample nearby ground height so bumps don't clip the circle
	local sampleRadius = 120      -- how far out to look for bumps
	local sampleUp     = 128      -- start above ground
	local sampleDown   = 512     -- trace down distance
	local samples      = 32       -- points around the player

	local maxZ = hitPos.z

	for i = 1, samples do
		local a = (i / samples) * math.pi * 2
		local off = Vector(math.cos(a), math.sin(a), 0) * sampleRadius
		local p = basePos + off

		local tr = util.TraceLine({
			start  = p + Vector(0, 0, sampleUp),
			endpos = p - Vector(0, 0, sampleDown),
			filter = ply,
			mask   = MASK_SOLID_BRUSHONLY
		})

		if tr.Hit and tr.HitPos.z > maxZ then
			maxZ = tr.HitPos.z
		end
	end

	-- Lift towards the highest nearby spot, but clamp so it doesn't float too much
	local lift = math.Clamp(maxZ - hitPos.z, 0, 24)

	-- Final position: small offset off the surface + extra lift for bump visibility
	local BASE_VISUAL_Z = 6  -- raise the whole circle slightly
	local pos = hitPos + nrm * 2.0 + Vector(0, 0, lift + BASE_VISUAL_Z)

	cache.fn = fn
	cache.pos = pos
	cache.nrm = nrm

	return pos, nrm
end

hook.Add("PostDrawTranslucentRenderables", "MTChat_ChatRangeVisual", function(depth, sky)
    if depth or sky then return end
    if not cvChatRangeVisual:GetBool() then return end
    if not MTChat.RangeVisualActive then return end
    if mtchat_closing then return end

    if not IsValid(PANEL) or PANEL:GetAlpha() < 5 then return end

    local lp = LocalPlayer()
    if not IsValid(lp) or not lp:Alive() then return end

    local rad = MTChat_GetEffectiveVisualRadius()
    if rad <= 0 then return end

    local pos, nrm = MTChat_GetGroundForCircle(lp)
    if not pos or not nrm then return end

    -- Build an angle whose UP axis matches the ground normal. normal:Angle() points FORWARD along the normal, so rotate to make it the UP axis for 3D2D
    local ang = nrm:Angle()
    ang:RotateAroundAxis(ang:Right(), -90)

    local scale = 0.10
    local pxRadius = rad / scale

    local r, g, b, a = MTChat_ParseRGBA(cvChatRangeVisualColor:GetString(), 155, 155, 155, 75)

    render.OverrideDepthEnable(true, true)
    cam.Start3D2D(pos, ang, scale)
        surface.SetDrawColor(r, g, b, a)
        draw.NoTexture()
        MTChat_DrawFilledCircle2D(pxRadius, 72)
    cam.End3D2D()
    render.OverrideDepthEnable(false, false)
end)

local function closeChat()
	if mtchat_closing then return end
	mtchat_closing = true
	MTChat.RangeVisualActive = false

	gui.EnableScreenClicker(false)

	if IsValid(PANEL) then
		-- Save current pos/size silently
		local x, y = PANEL:GetPos()
		local w, h = PANEL:GetSize()

		CFG.x = x
		CFG.y = y
		CFG.w = w
		CFG.h = h
		applyBoundsToCfg()
		saveConfig(CFG)

		-- Fade out, then actually remove & cleanup
		PANEL:AlphaTo(0, MTCHAT_FADE_OUT_TIME, 0, function()
			if IsValid(PANEL) then
				PANEL:Remove()
			end
			
			MTChat.ChatOpen = false
			
			-- Ensure typing state is cleared
			MTChat.LocalTypingState = false

			net.Start("mtchat_typing")
				net.WriteUInt(MTChat.STATUS_NONE, 4) -- status
				net.WriteBool(cvChatAnim:GetBool())  -- allowAnim
				net.WriteBool(cvChatIndicator:GetBool()) -- allowIndicator
			net.SendToServer()

			PANEL, ENTRY, SCROLL = nil, nil, nil
			mtchat_closing = false
			hook.Run("FinishChat")
		end)

		return
	end

	PANEL, ENTRY, SCROLL = nil, nil, nil
	mtchat_closing = false
	hook.Run("FinishChat")
end

local function openChat(teamChat)
	MTChat.ChatOpen = true
	MTChat.RangeVisualActive = true
    activeTeamChat = teamChat and true or false

    if IsValid(PANEL) then
        PANEL:Remove()
    end

    applyBoundsToCfg()

    PANEL = vgui.Create("DFrame")
	PANEL:SetAlpha(0)
    PANEL:SetTitle("")
    PANEL:ShowCloseButton(false)
    PANEL:SetDraggable(true)
    PANEL:SetSizable(true)
    PANEL:SetMinWidth(320)
    PANEL:SetMinHeight(180)
    PANEL:SetSize(CFG.w, CFG.h)
    PANEL:SetPos(CFG.x, CFG.y)
    PANEL:MakePopup()
	PANEL:AlphaTo(255, MTCHAT_FADE_TIME, 0)
    PANEL:SetKeyboardInputEnabled(true)
    PANEL:SetMouseInputEnabled(true)
	
	mtchat_closing = false

    PANEL.Paint = function(self, w, h)
        local c = CFG.boxColor or {r=0,g=0,b=0,a=220}
        draw.RoundedBox(10, 0, 0, w, h, Color(c.r, c.g, c.b, c.a))
        surface.SetDrawColor(255, 255, 255, 18)
        surface.DrawOutlinedRect(0, 0, w, h, 1)

        -- small hint bar
        draw.SimpleText(activeTeamChat and "Team Chat" or "Chat",
            "DermaDefaultBold",
            10, 6, Color(255,255,255,140), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
    end

    -- Scroll area for chat history
    SCROLL = vgui.Create("DScrollPanel", PANEL)
    SCROLL:Dock(FILL)
    SCROLL:DockMargin(10, 28, 10, 42)
	
	if IsValid(SCROLL) and IsValid(SCROLL.VBar) then
		local bar = SCROLL.VBar

		local oldOnScroll = bar.OnScroll
		bar.OnScroll = function(self, offset)
			if oldOnScroll then oldOnScroll(self, offset) end
			MTChat_UpdateAutoScrollLock()
		end

		local oldOnMouseWheeled = bar.OnMouseWheeled
		bar.OnMouseWheeled = function(self, dlta)
			if oldOnMouseWheeled then oldOnMouseWheeled(self, dlta) end
			MTChat_UpdateAutoScrollLock()
			return true
		end
	end


    local canvas = SCROLL:GetCanvas()
    canvas.Paint = function() end

    -- custom draw panel inside scroll
    local LOG = vgui.Create("DPanel", SCROLL)
    LOG:Dock(TOP)
    LOG:SetTall(10)
    LOG.Paint = function(self, w, h)
        -- nothing; we draw in child panel below
    end
	
	local DRAW = vgui.Create("DPanel", SCROLL:GetCanvas())
	DRAW:Dock(BOTTOM)
	DRAW:SetTall(10)
	
	DRAW:SetMouseInputEnabled(true)
	DRAW._hit = {}

	local function MTChat_EstimateLineHeight(ln, maxW)
		-- estimate so panelH is correct without forcing markup. Parse on everything. Use cached mk height if we already have it.
		if ln and ln.mk then
			return ln.mk:GetHeight() + 6
		end

		-- wrap estimate using plain text width.
		local txt
		if IsValid(ln.ply) then
			if ln.team then
				txt = (MTCHAT_TEAM_PREFIX or "") .. (ln.ply:Nick() or "") .. ": " .. tostring(ln.raw or "")
			else
				txt = (ln.ply:Nick() or "") .. ": " .. tostring(ln.raw or "")
			end
		else
			txt = tostring(ln.raw or "")
		end

		-- Strip <r,g,b> tags to avoid inflating width
		txt = string.gsub(txt, "<%s*%d+%s*,%s*%d+%s*,%s*%d+%s*>", "")

		surface.SetFont("MTChat_Default")
		local _, lineH = surface.GetTextSize("Ag")
		lineH = math.max(lineH, 16)

		-- Basic word wrap count
		local words = string.Explode(" ", txt)
		local curW = 0
		local lines = 1

		for _, w0 in ipairs(words) do
			local ww = surface.GetTextSize(w0 .. " ")
			if curW + ww > maxW and curW > 0 then
				lines = lines + 1
				curW = ww
			else
				curW = curW + ww
			end
		end

		return (lines * (lineH + 2)) + 6
	end
	
	--autoscroll
	MTChat._ScrollDraw = DRAW
	MTChat._ScrollEstimate = MTChat_EstimateLineHeight

	DRAW.Paint = function(self, w, h)
		local pad  = 2
		local maxW = w - pad * 2

		self._hit = {}

		-- Visible window in DRAW's coordinate space
		if not IsValid(SCROLL) then return end

		local scroll = (IsValid(SCROLL.VBar)) and SCROLL.VBar:GetScroll() or 0
		local viewportH = SCROLL:GetTall()
		local buffer = viewportH * 0.75

		local visTop = scroll - buffer
		local visBot = scroll + viewportH + buffer

		-- Compute TOTAL panel height cheaply (so scroll history exists)
		local totalH = pad
		for i = 1, #MTChat.Lines do
			totalH = totalH + MTChat_EstimateLineHeight(MTChat.Lines[i], maxW)
		end

		local panelH = math.max(totalH, viewportH)

		if self._panelH ~= panelH then
			self._panelH = panelH
			self:SetTall(panelH)
			self:InvalidateLayout(true)
		end

		-- Walk newest->oldest, compute Y positions, but only parse/draw if visible
		local y = panelH - pad

		for i = #MTChat.Lines, 1, -1 do
			local ln = MTChat.Lines[i]

			local lineH = MTChat_EstimateLineHeight(ln, maxW)
			y = y - lineH

			-- If we've gone above the visible region, we can stop
			if (y + lineH) < visTop then
				break
			end

			-- Skip lines below visible region
			if y > visBot then
				continue
			end

			-- Build markups ONLY for visible lines
			if not ln.mk or ln._mkW ~= maxW then
				ln._mkW = maxW
				ln.mk = buildLineMarkup(ln.ply, ln.team, ln.raw, maxW, ln.src, ln.nameCol)
			end

			if not ln.shadowMk or ln._shadowW ~= maxW then
				ln._shadowW = maxW
				ln.shadowMk = buildLineMarkupShadow(ln.ply, ln.team, ln.raw, maxW, ln.src)
			end
			
			-- keep shadow wrap identical to main wrap
			if ln.mk and ln.shadowMk and ln.mk:GetHeight() ~= ln.shadowMk:GetHeight() then
				ln._shadowW = maxW
				ln.shadowMk = buildLineMarkupShadow(ln.ply, ln.team, ln.raw, maxW, ln.src)
			end

			-- Update actual height if markup built
			if ln.mk then
				lineH = ln.mk:GetHeight() + 6
			end

			-- clickable rect only for visible
			self._hit[#self._hit + 1] = {
				ln = ln,
				x  = pad,
				y  = y,
				w  = maxW,
				h  = lineH
			}

			if ln.mk then
				MTChat_DrawMarkupShadowed(ln.mk, ln.shadowMk, pad, y)
			end
		end
	end

	
	DRAW.OnMousePressed = function(self, mc)
		if mc ~= MOUSE_RIGHT then return end

		local mx, my = self:CursorPos()
		if mx < 0 or my < 0 or mx > self:GetWide() or my > self:GetTall() then return end

		-- find which line we clicked
		local clicked
		for _, r in ipairs(self._hit or {}) do
			if mx >= r.x and mx <= (r.x + r.w) and my >= r.y and my <= (r.y + r.h) then
				clicked = r.ln
				break
			end
		end
		if not clicked then return end

		-- kill any previous context menu to guarantee selection
		if IsValid(self._ctxMenu) then
			self._ctxMenu:Remove()
			self._ctxMenu = nil
		end

		-- Defer one tick so the right-click event/focus settles
		timer.Simple(0, function()
			if not IsValid(self) or not MTChat.ChatOpen then return end

			local menu = DermaMenu(PANEL) -- parent it to the chat frame so it stays on top of it
			self._ctxMenu = menu

			menu:AddOption("Copy message text", function()
				SetClipboardText(MTChat_BuildPlainLine(clicked))
			end)

			menu:AddOption("Copy message (with formatting)", function()
				SetClipboardText(MTChat_BuildFormattedLine(clicked))
			end)

			if IsValid(clicked.ply) then
				menu:AddOption("Copy name color RGB", function()
					local r, g, b = MTChat_GetPlayerNameRGB(clicked)
					SetClipboardText(string.format("%d,%d,%d", r, g, b))
				end)
			end

			menu:Open()
			menu:SetDrawOnTop(true)
			menu:MakePopup()
		end)

	end


    -- Input entry multiline
    ENTRY = vgui.Create("DTextEntry", PANEL)
    ENTRY:Dock(BOTTOM)
    ENTRY:DockMargin(10, 0, 10, 10)
    ENTRY:SetTall(28)
    ENTRY:SetMultiline(true)
    ENTRY:SetFont("MTChat_Default")
    ENTRY:SetText("")

	-- Auto-grow entry on newline
	ENTRY._mt_baseTall = 28
	ENTRY._mt_maxFrac  = 0.35 -- max % of chatbox height the entry can consume

	local function MTChat_EntryLineCount(txt)
		txt = tostring(txt or "")
		if txt == "" then return 1 end

		-- explicit newline lines
		local lines = string.Explode("\n", txt, false)
		local explicitCount = math.max(1, #lines)

		-- If ENTRY isn't fully laid out yet, do not try to wrap-measure.
		local entryW = (IsValid(ENTRY) and ENTRY:GetWide() or 0)
		if entryW < 80 then
			return explicitCount
		end

		-- measure width available inside the entry
		local maxW = math.max(1, entryW - 20)

		-- remove inline color codes like <255,255,255> for measuring wrap width
		local function stripForMeasure(s)
			s = tostring(s or "")
			s = string.gsub(s, "<%s*%d+%s*,%s*%d+%s*,%s*%d+%s*>", "")
			return s
		end

		surface.SetFont("MTChat_Default")

		local total = 0
		for _, line in ipairs(lines) do
			local clean = stripForMeasure(line)

			-- Empty line still counts as 1 visible line
			if clean == "" then
				total = total + 1
			else
				local w = select(1, surface.GetTextSize(clean))

				-- Only becomes 2+ when it truly exceeds the available width
				local wraps = math.max(1, math.floor((w - 1) / maxW) + 1)
				total = total + wraps
			end
		end

		return math.max(1, total)
	end

	local function MTChat_UpdateEntryHeight()
		if not IsValid(ENTRY) or not IsValid(PANEL) then return end

		local txt = ENTRY:GetText() or ""
		local lines = MTChat_EntryLineCount(txt)

		-- measure per-line height from current font
		surface.SetFont("MTChat_Default")
		local _, lineH = surface.GetTextSize("Ag")
		lineH = math.max(lineH, 16)

		local pad = 12 -- internal padding feel
		local want = ENTRY._mt_baseTall

		if lines > 1 then
			want = pad + (lines * (lineH + 2))
		end

		local maxTall = math.floor(PANEL:GetTall() * ENTRY._mt_maxFrac)
		want = clamp(want, ENTRY._mt_baseTall, math.max(ENTRY._mt_baseTall, maxTall))

		if ENTRY:GetTall() ~= want then
			ENTRY:SetTall(want)
			-- SCROLL is Dock(FILL), so it will naturally resize.
			if IsValid(SCROLL) then
				SCROLL:InvalidateLayout(true)
			end
		end

		-- Allow scrolling inside entry without showing a scrollbar
		if ENTRY.VBar and IsValid(ENTRY.VBar) then
			ENTRY.VBar:SetWide(0)
			ENTRY.VBar:SetAlpha(0)
			ENTRY.VBar.Paint = function() end
			if ENTRY.VBar.btnGrip then ENTRY.VBar.btnGrip.Paint = function() end end
			if ENTRY.VBar.btnUp then ENTRY.VBar.btnUp.Paint = function() end end
			if ENTRY.VBar.btnDown then ENTRY.VBar.btnDown.Paint = function() end end
		end
	end

	-- Update height whenever text changes
	ENTRY.OnChange = function()
		MTChat_UpdateEntryHeight()
	end

	-- keep it correct if something edits text without firing OnChange reliably
	ENTRY.Think = function(self)
		self._mt_lastText = self._mt_lastText or ""
		local t = self:GetText() or ""
		if t ~= self._mt_lastText then
			self._mt_lastText = t
			MTChat_UpdateEntryHeight()
		end
	end

	-- Initialize once
	timer.Simple(0, MTChat_UpdateEntryHeight)


    ENTRY.Paint = function(self, w, h)
        draw.RoundedBox(6, 0, 0, w, h, Color(0,0,0,160))
        surface.SetDrawColor(255,255,255,25)
        surface.DrawOutlinedRect(0, 0, w, h, 1)
		local tc = MTChat_GetTextColor(230)
		self:DrawTextEntryText(tc, Color(80,160,255,255), Color(255,255,255,230), Color(80,160,255,255), Color(255,255,255,120))
    end

    -- Shift+Enter = newline, Enter = send
    ENTRY.OnKeyCodeTyped = function(self, code)
        if code == KEY_ESCAPE then
            closeChat()
            return
        end

        if code == KEY_ENTER then
            if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT) then
                -- newline
				self:SetText(self:GetText() .. "\n")
				self:SetCaretPos(#self:GetText())
				MTChat_UpdateEntryHeight()
				return
            end

            -- send
            local txt = self:GetText() or ""
            txt = string.Trim(txt)

            if txt ~= "" then
                net.Start("mtchat_submit")
                    net.WriteBool(activeTeamChat)
                    net.WriteString(txt)
                net.SendToServer()
            end

            ENTRY:SetTall(ENTRY._mt_baseTall or 28)
			closeChat()
            return
        end
    end

    -- Focus the entry
    timer.Simple(0, function()
        if IsValid(ENTRY) then
            ENTRY:RequestFocus()
        end
    end)

	ENTRY.OnFocusChanged = function(self, gained)
		MTChat.LocalTypingState = gained and true or false

		net.Start("mtchat_typing")
			net.WriteUInt(MTChat.STATUS_TYPING, 4)
			net.WriteBool(cvChatAnim:GetBool())
			net.WriteBool(cvChatIndicator:GetBool())
		net.SendToServer()
	end

	
	-- Pin to bottom reliably on open: wait for CanvasSize to stabilize.
	timer.Remove("mtchat_scrollbottom_onopen")

	local lastCanvas = -1
	local stableCount = 0

	timer.Create("mtchat_scrollbottom_onopen", 0, 30, function()
		if not IsValid(PANEL) or not MTChat.ChatOpen then
			timer.Remove("mtchat_scrollbottom_onopen")
			return
		end
		if not IsValid(SCROLL) or not IsValid(SCROLL.VBar) then
			timer.Remove("mtchat_scrollbottom_onopen")
			return
		end

		local bar = SCROLL.VBar

		-- Force layout updates
		SCROLL:InvalidateLayout(true)
		bar:InvalidateLayout(true)

		local cs = bar.CanvasSize or 0
		if cs <= 0 then
			lastCanvas = -1
			stableCount = 0
			return
		end

		if cs == lastCanvas then
			stableCount = stableCount + 1
		else
			stableCount = 0
			lastCanvas = cs
			-- Re-pin any time it changes
			bar:SetScroll(cs)
		end

		-- Once it stops changing for ~2 frames, pin one last time and stop.
		if stableCount >= 2 then
			bar:SetScroll(cs)
			timer.Remove("mtchat_scrollbottom_onopen")
		end
	end)

    -- Save when user resizes/drags and then closes; no extra noise.
    PANEL.OnClose = function()
        closeChat()
    end
	
	timer.Simple(0, function()
		if not MTChat.ChatOpen then return end
		MTChat.AutoScrollLock = false
		MTChat_UpdateAutoScrollLock()
		MTChat_ScrollToBottom()
	end)
end

local function MTChat_SendTypingPrefsRefresh()
	net.Start("mtchat_typing")
		net.WriteUInt(MTChat.LocalTypingState and MTChat.STATUS_TYPING or MTChat.STATUS_NONE, 4)
		net.WriteBool(cvChatAnim:GetBool())
		net.WriteBool(cvChatIndicator:GetBool())
	net.SendToServer()
end

hook.Add("StartChat", "MTChat_StartChat", function(teamChat)
    -- Suppress default chat UI and open MTChat's
    openChat(teamChat)
    gui.EnableScreenClicker(true)
    return true
end)

hook.Add("FinishChat", "MTChat_FinishChat", function()
    MTChat.ChatOpen = false
    MTChat.RangeVisualActive = false
end)

MTChat.GestureW = MTChat.GestureW or {} -- [ply] = 0..1

hook.Add("Think", "MTChat_ChatGesture", function()
	-- if not cvChatAnim:GetBool() then return end -- REMOVED: locally disabling anim shouldn't stop processing for others

	local ft = FrameTime()
	local inSpd = ft * 6
	local outSpd = ft * 8

	for _, ply in ipairs(player.GetAll()) do
		local data = MTChat.Typing[ply]
		-- treat typing status as the only one that animates
		local should = data and (data.status == MTChat.STATUS_TYPING) and data.anim

		local w = MTChat.GestureW[ply] or 0

		if should then
			-- only restart when entering from 0 -> >0
			if w <= 0 then
				ply:AnimRestartGesture(GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GMOD_IN_CHAT, false)
			end
			w = math.min(1, w + inSpd)
		else
			w = math.max(0, w - outSpd)
		end

		MTChat.GestureW[ply] = w

		if w > 0 then
			ply:AnimSetGestureWeight(GESTURE_SLOT_ATTACK_AND_RELOAD, w)
		end
	end
end)

local mtchatBubbleMat = Material("icon16/comment.png") -- built-in icon16
local mtchatMenuMat   = Material("icon16/application.png")
local mtchatAFKMat    = Material("icon16/time.png")

local function MTChat_GetStatusIcon(status)
	if status == MTChat.STATUS_TYPING then return mtchatBubbleMat end
	if status == MTChat.STATUS_MENU then return mtchatMenuMat end
	if status == MTChat.STATUS_AFK then return mtchatAFKMat end
	return nil
end

hook.Add("PostDrawTranslucentRenderables", "MTChat_DrawAllIndicators", function(depth, sky)
	if depth or sky then return end
	if not cvChatIndicator:GetBool() then return end

	local lp = LocalPlayer()
	local eyeAng = EyeAngles()
	local ang = Angle(0, eyeAng.y - 90, 90)

	for _, ply in ipairs(player.GetAll()) do
		if not IsValid(ply) or not ply:Alive() or ply:IsDormant() then continue end
		
		-- Don't draw on self in first person (unless using a camera/thirdperson mod that allows seeing self)
		if ply == lp and lp:GetViewEntity() == lp and not lp:ShouldDrawLocalPlayer() then continue end

		local data = MTChat.Typing[ply]
		if not data or not data.indicator then continue end
		
		local status = data.status or 0
		if status == MTChat.STATUS_NONE then continue end

		local mat = MTChat_GetStatusIcon(status)
		if not mat then continue end

		-- position above head
		local pos = ply:EyePos() + Vector(0, 0, 22)

		cam.Start3D2D(pos, ang, 0.18)
			surface.SetMaterial(mat)
			
			-- Lighting
			local light = render.ComputeLighting(pos, Vector(0,0,1))
			
			-- Map 0..1 vector to 0..255 color, with a small minimum so it's not invisible in pitch black
			local r = math.Clamp(light.x * 255, 30, 255)
			local g = math.Clamp(light.y * 255, 30, 255)
			local b = math.Clamp(light.z * 255, 30, 255)

			surface.SetDrawColor(r, g, b, 220)

			surface.DrawTexturedRect(-24, -24, 48, 48)
		cam.End3D2D()
	end
end)

local mtchat_lastStatusTime = 0
local mtchat_currentStatus = 0

hook.Add("Think", "MTChat_StatusUpdateResult", function()
	local now = RealTime()
	if now < (mtchat_lastStatusTime + 0.25) then return end
	mtchat_lastStatusTime = now

	local newStatus = MTChat.STATUS_NONE

	if not system.HasFocus() then
		newStatus = MTChat.STATUS_AFK
	elseif MTChat.LocalTypingState then
		newStatus = MTChat.STATUS_TYPING
	elseif vgui.CursorVisible() or (gui.IsGameUIVisible and gui.IsGameUIVisible()) then
		newStatus = MTChat.STATUS_MENU
	end

	if newStatus ~= mtchat_currentStatus then
		mtchat_currentStatus = newStatus
		
		net.Start("mtchat_typing")
			net.WriteUInt(newStatus, 4)
			net.WriteBool(cvChatAnim:GetBool())
			net.WriteBool(cvChatIndicator:GetBool())
		net.SendToServer()
	end
end)

-- Concommands

concommand.Add("mtchat_chatboxreset", function()
    CFG = defaultConfig()
    saveConfig(CFG)
    if IsValid(PANEL) then
        PANEL:SetSize(CFG.w, CFG.h)
        PANEL:SetPos(CFG.x, CFG.y)
    end
end)

local function parseRGB(str)
    if not isstring(str) then return nil end
    str = string.Trim(str)
    str = string.gsub(str, "[<>]", "") -- allow "<0,0,0>" or "0,0,0"

    local r, g, b = string.match(str, "^(%d+)%s*,%s*(%d+)%s*,%s*(%d+)$")
    if not r then return nil end
    r = clamp(r, 0, 255)
    g = clamp(g, 0, 255)
    b = clamp(b, 0, 255)
    return r, g, b
end

concommand.Add("mtchat_chatlogclear", function()
	MTChat.Lines = {}

	-- If chat is open, force a clean redraw and pin to bottom
	if IsValid(SCROLL) then
		SCROLL:InvalidateLayout(true)
	end

	-- if DRAW panel stores hitboxes/menus, clear them if present. avoids right-click hitboxes from referencing old lines.
	if IsValid(PANEL) then
		timer.Simple(0, function()
			if IsValid(SCROLL) and IsValid(SCROLL.VBar) then
				SCROLL.VBar:SetScroll(SCROLL.VBar.CanvasSize or 0)
			end
		end)
	end
end)

cvars.AddChangeCallback("mtchat_chatloglimit", function(_, _, newVal)
	local limit = math.max(0, tonumber(newVal) or 0)
	if limit > 0 then
		while #MTChat.Lines > limit do
			table.remove(MTChat.Lines, 1)
		end
	end

	if IsValid(SCROLL) then
		SCROLL:InvalidateLayout(true)
	end
end, "mtchat_chatloglimit_trim")

cvars.AddChangeCallback("mtchat_chatindicator", function()
	local lp = LocalPlayer()
	if IsValid(lp) and MTChat.Typing[lp] then
		MTChat.Typing[lp].indicator = cvChatIndicator:GetBool()
	end
	MTChat_SendTypingPrefsRefresh()
end, "mtchat_chatindicator_refresh")

cvars.AddChangeCallback("mtchat_chatanim", function()
	local lp = LocalPlayer()
	if IsValid(lp) and MTChat.Typing[lp] then
		MTChat.Typing[lp].anim = cvChatAnim:GetBool()
	end
	MTChat_SendTypingPrefsRefresh()
end, "mtchat_chatanim_refresh")