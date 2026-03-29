if CLIENT then
    local thirdpersonEnabled = false
    local wasKeyDown = false
    local lastViewUpdate = CurTime()
    local fallbackTimeout = 1 -- seconds until auto-reset if CalcView not used
	local hasEverActivatedThirdperson = false
	
    -- Mode 4 state (free cam)
    local tp4_camYaw = 0
    local tp4_camPitch = 0
    local tp4_bodyYaw = 0
    local tp4_inited = false
	local tp4_cachedEyeZOff = nil

    -- 1 = default, 2 = right shoulder, 3 = left shoulder
    CreateClientConVar("3prpmodenumber", "1", true, false, "Thirdperson camera mode: 1 = normal, 2 = right shoulder, 3 = left shoulder, 4 = free-cam movement")

	hook.Add("Think", "ThirdPersonRP_Toggle", function()
		local isKeyDown = input.IsKeyDown(KEY_F2)
		if isKeyDown and not wasKeyDown then
			thirdpersonEnabled = not thirdpersonEnabled

			if thirdpersonEnabled then
				hasEverActivatedThirdperson = true
				lastViewUpdate = CurTime() -- reset timer when turning on

				-- init mode 4 angles from current view
				local ea = LocalPlayer():EyeAngles()
				tp4_camYaw = ea.y
				tp4_camPitch = ea.p
				tp4_bodyYaw = ea.y
				tp4_inited = true
			else
				lastViewUpdate = math.huge -- disable auto-disable logic while off
			end

			-- surface.PlaySound("buttons/button24.wav") -- Optional sound
		end
		wasKeyDown = isKeyDown

		-- Only auto-disable if thirdperson is active and view hasn't updated
		if thirdpersonEnabled and hasEverActivatedThirdperson and (CurTime() - lastViewUpdate) > fallbackTimeout then
			thirdpersonEnabled = false
			--chat.AddText(Color(255, 100, 100), "[ThirdPerson] Automatically disabled due to CalcView override.")
		end
	end)

    -- Apply camera logic
	hook.Add("CalcView", "ThirdPersonRP_View", function(ply, pos, ang, fov)
		if thirdpersonEnabled and ply:Alive() then
			-- detect if in vehicle and it's not SitAnywhere
			local veh = ply:GetVehicle()
			if IsValid(veh) and not (veh:GetClass() == "prop_vehicle_prisoner_pod" and veh:GetNWBool("playerdynseat", false)) then
				-- only override view if not in a normal vehicle
				return
			end

			lastViewUpdate = CurTime()

			local dist = 100
			local offset = Vector(0, 0, 0)
			local mode = GetConVar("3prpmodenumber"):GetInt()

			local isSitAnywhere = IsValid(veh) and (veh:GetClass() == "prop_vehicle_prisoner_pod") and veh:GetNWBool("playerdynseat", false)

			-- Mode 4 uses free-cam angles normally, but while noclipping it should behave like default thirdperson. camera faces where the player is looking (use live 'ang').
			local viewAng = ang
			if mode == 4 then
				dist = 165

				if ply:GetMoveType() ~= MOVETYPE_NOCLIP then
					viewAng = Angle(tp4_camPitch or ang.p, tp4_camYaw or ang.y, 0)
				end
			end


			-- Determine offset based on mode
			if mode == 2 then
				offset = ang:Right() * 15 - ang:Forward() * 55 + ang:Up() * 2
			elseif mode == 3 then
				offset = ang:Right() * -15 - ang:Forward() * 55 + ang:Up() * 2
			else
				-- mode 1 or 4
				offset = (-viewAng:Forward() * dist) + (viewAng:Up() * 10)
			end

			local pivot = pos

			if mode == 4 then
				local base = ply:GetPos()

				if not isSitAnywhere then
					tp4_cachedEyeZOff = pos.z - base.z
				elseif tp4_cachedEyeZOff ~= nil then
					-- While SitAnywhere-seated, drop the pivot a bit so the camera follows the player down. Tweak 18 to taste (try 12–28).
					pivot = base + Vector(0, 0, tp4_cachedEyeZOff - 18)
				end
			end

			local tr = util.TraceHull({
				start = pivot,
				endpos = pivot + offset,
				mins = Vector(-4, -4, -4),
				maxs = Vector(4, 4, 4),
				filter = ply
			})


			local view = {}
			view.origin = tr.HitPos + tr.HitNormal * 5
			view.angles = viewAng
			view.fov = fov
			return view
		end
	end)

    -- Draw local player in thirdperson
	hook.Add("ShouldDrawLocalPlayer", "ThirdPersonRP_Draw", function()
		return thirdpersonEnabled
	end)

    -- Cycle between 3prpmodenumber values
    concommand.Add("3prpmode", function()
        local cvar = GetConVar("3prpmodenumber")
        local current = cvar:GetInt()
        local nextVal = current + 1
        if nextVal > 4 then nextVal = 1 end
        RunConsoleCommand("3prpmodenumber", tostring(nextVal))

        --local label = ({
        --    [1] = "Rear View",
        --    [2] = "Right Shoulder",
        --    [3] = "Left Shoulder"
		--	  [4] = "Free Cam"})

        --chat.AddText(Color(100, 200, 255), "[ThirdPerson] Mode set to ", Color(255,255,255), label)
    end)
	
	hook.Add("HUDPaint", "ThirdPersonRP_Crosshair", function()
		if not thirdpersonEnabled then return end

		local mode = GetConVar("3prpmodenumber"):GetInt()
		if mode == 1 then return end -- Only for shoulder modes (2 = right, 3 = left)

		local ply = LocalPlayer()
		if not IsValid(ply) or not ply:Alive() then return end

		local wep = ply:GetActiveWeapon()

		-- Base trace for the tracer crosshair for over the shoulder
		local startPos = ply:GetShootPos()
		local aimVec   = ply:GetAimVector()
		local endPos   = startPos + aimVec * 8192

		local tr = util.TraceLine({
			start  = startPos,
			endpos = endPos,
			filter = ply
		})

		if not tr.Hit then return end

		local hitPos = tr.HitPos
		local screen = hitPos:ToScreen()
		local distSqr = hitPos:DistToSqr(ply:GetShootPos())

		-- Fade out from close to far
		local alpha = math.Clamp((distSqr - 800) / (2000 - 400), 0, 1) * 255
		if alpha <= 0 then return end

		-- Default color = white
		local r, g, b = 255, 255, 255

		-- If we have a DMB weapon, use its hit indicator only to tint orange/red when in shove/attack range.
		if IsValid(wep) and wep.IsDMB and DMB and DMB.GetHitIndicator then
			local info = DMB.GetHitIndicator(ply, wep)
			if info and info.color then
				-- Only override on orange/red; white keeps the normal look.
				local c = info.color
				if (c.r ~= 255 or c.g ~= 255 or c.b ~= 255) then
					r, g, b = c.r, c.g, c.b
				end
			end
		end

		-- Outer black border
		surface.SetDrawColor(0, 0, 0, alpha)
		surface.DrawRect(screen.x - 2, screen.y - 2, 6, 6)

		-- Inner center
		surface.SetDrawColor(r, g, b, alpha)
		surface.DrawRect(screen.x - 1, screen.y - 1, 4, 4)
	end)


	hook.Add("HUDShouldDraw", "ThirdPersonRP_HideDefaultCrosshair", function(name)
		if name ~= "CHudCrosshair" then return end
		if not thirdpersonEnabled then return end

		local mode = GetConVar("3prpmodenumber"):GetInt()
		if mode == 2 or mode == 3 or mode == 4 then
			return false
		end
	end)

    hook.Add("CreateMove", "ThirdPersonRP_Mode4_Move", function(cmd)
        if not thirdpersonEnabled then return end
        if GetConVar("3prpmodenumber"):GetInt() ~= 4 then return end

        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end
		
		--don't use freecam movement for noclip
		if ply:GetMoveType() == MOVETYPE_NOCLIP then
			return
		end
		
        if not tp4_inited then
            local ea = ply:EyeAngles()
            tp4_camYaw = ea.y
            tp4_camPitch = ea.p
            tp4_bodyYaw = ea.y
            tp4_inited = true
        end

        -- Update free camera angles from mouse input
        local mx, my = cmd:GetMouseX(), cmd:GetMouseY()
        -- Multipliers
        tp4_camYaw   = tp4_camYaw   - (mx * 0.02)


        local camAng = Angle(tp4_camPitch, tp4_camYaw, 0)

        -- Raw input
        local fm = cmd:GetForwardMove()
        local sm = cmd:GetSideMove()
		
        -- Detect automove forward drive. automove.lua sets forwardmove without the player holding IN_FORWARD (W), and uses sidemove for A/D while still moving forward.
        local autoForward = (fm > 1) and (not ply:KeyDown(IN_FORWARD))

        if autoForward then
            -- Steering: A/D should rotate facing gradually. Use sidemove sign as steer intent (automove uses sidemove when A/D held).
            local steer = 0
            if sm < -1 then steer = -1 elseif sm > 1 then steer = 1 end

            if steer ~= 0 then
                local steerRateDegPerSec = 140 -- tweak: higher = faster steering
                tp4_bodyYaw = math.NormalizeAngle(tp4_bodyYaw - steer * steerRateDegPerSec * FrameTime())
            end

            -- While automoving, keep movement forward in the facing direction. Kill sidemove so it doesn't become snap-strafe.
            cmd:SetSideMove(0)

            -- Keep the camera free: do not force tp4_bodyYaw toward camera yaw just because the player moved. Allow attacks to snap later.
        end


        -- Build a camera-relative wish direction in world space
        local wish = (camAng:Forward() * fm) + (camAng:Right() * sm)
        wish.z = 0

        local wishLen = wish:Length()
        local moving = wishLen > 1

        local buttons = cmd:GetButtons()
        local attacking = bit.band(buttons, IN_ATTACK) ~= 0 or bit.band(buttons, IN_ATTACK2) ~= 0
		local using = bit.band(buttons, IN_USE) ~= 0
		local allowPitch = attacking or using
		
		local minPitch = allowPitch and -89 or -88
		tp4_camPitch = math.Clamp(tp4_camPitch + (my * 0.02), minPitch, 88)

        -- Decide where the body should point. When moving, body snaps/turns toward movement direction quickly. On attack, body snaps to camera yaw so attacks respect where you're looking
        local targetYaw = tp4_bodyYaw
		if moving and not autoForward then
			targetYaw = wish:Angle().y
		end
		if attacking then
			targetYaw = tp4_camYaw
		end

        -- Turn rate modification
        local turnRate = 18
        tp4_bodyYaw = math.ApproachAngle(tp4_bodyYaw, targetYaw, FrameTime() * turnRate * 180)

		-- While holding Attack/Use, allow looking up/down. Otherwise keep model "looking forward" with pitch at 0.
		local pitch = allowPitch and tp4_camPitch or 0
		local bodyAng = Angle(pitch, tp4_bodyYaw, 0)
		cmd:SetViewAngles(bodyAng)


        -- Remap movement so it’s camera-relative, but expressed in bodyAng space
        if moving and not autoForward then
            local wishDir = wish / wishLen

            local maxMag = math.max(math.abs(fm), math.abs(sm))
            if maxMag < 1 then maxMag = wishLen end

			local yawAng = Angle(0, tp4_bodyYaw, 0)
			local f = wishDir:Dot(yawAng:Forward()) * maxMag
			local s = wishDir:Dot(yawAng:Right())   * maxMag

            cmd:SetForwardMove(f)
            cmd:SetSideMove(s)
        else
            -- no movement: keep still, but camera can still orbit
        end
    end)


end
