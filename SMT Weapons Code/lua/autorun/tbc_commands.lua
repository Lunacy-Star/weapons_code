if SERVER then
    util.AddNetworkString("useturn")

    concommand.Add("partycreate", function(ply, cmd, args)
        if IsPlayerInAnyParty(ply) then
            ply:ChatPrint("You're already in a party.")
            return
        end

        CreateParty(ply)
    end)

    concommand.Add("partyleave", function(ply, cmd, args)
        local partyId = IsPlayerInAnyParty(ply)
        if not partyId then
            ply:ChatPrint("You're not in a party...")
            return
        end

        RemoveFromParty(ply, partyId)
    end)

    -- Finds a connected player (other than ply) whose name contains nameQuery,
    -- case-insensitively. Returns the player, or nil plus a feedback message.
    local function FindPlayerByPartialName(ply, nameQuery)
        local lowerQuery = string.lower(nameQuery)
        local found, multipleMatches

        for _, target in ipairs(player.GetAll()) do
            if target ~= ply and string.find(string.lower(target:Name()), lowerQuery, 1, true) then
                if found then
                    multipleMatches = true
                else
                    found = target
                end
            end
        end

        if not found then
            return nil, "No player found matching \"" .. nameQuery .. "\"."
        end
        if multipleMatches then
            return nil, "Multiple players match \"" .. nameQuery .. "\" - please be more specific."
        end
        return found
    end

    hook.Add("PlayerSay", "PartyInviteChatCommand", function(ply, text)
        local cmd = string.lower(text)
        if string.sub(cmd, 1, 13) ~= "/partyinvite " then
            return
        end

        local targetName = string.Trim(string.sub(text, 14))
        if targetName == "" then
            ply:ChatPrint("Usage: /partyinvite <name>")
            return ""
        end

        local target, err = FindPlayerByPartialName(ply, targetName)
        if not target then
            ply:ChatPrint(err)
            return ""
        end

        local success, message = InvitePlayerToParty(ply, target)
        if message then
            ply:ChatPrint(message)
        end

        return ""
    end)

    -- Admin-only: forces a player into the admin's own party, creating one
    -- for the admin first if they don't already have one.
    hook.Add("PlayerSay", "PartyForceChatCommand", function(ply, text)
        local cmd = string.lower(text)
        if string.sub(cmd, 1, 12) ~= "/partyforce " then
            return
        end

        if not ply:IsAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return ""
        end

        local targetName = string.Trim(string.sub(text, 13))
        if targetName == "" then
            ply:ChatPrint("Usage: /partyforce <name>")
            return ""
        end

        local target, err = FindPlayerByPartialName(ply, targetName)
        if not target then
            ply:ChatPrint(err)
            return ""
        end

        local partyId = IsPlayerInAnyParty(ply)
        if not partyId then
            partyId = CreateParty(ply)
        end

        AssignParty(target, partyId)
        ply:ChatPrint("Forced " .. target:Nick() .. " into your party.")

        return ""
    end)

    -- Admin-only: strips a player from whatever party they're currently in,
    -- regardless of who leads it.
    hook.Add("PlayerSay", "PartyStripChatCommand", function(ply, text)
        local cmd = string.lower(text)
        if string.sub(cmd, 1, 12) ~= "/partystrip " then
            return
        end

        if not ply:IsAdmin() then
            ply:ChatPrint("You do not have permission to use this command.")
            return ""
        end

        local targetName = string.Trim(string.sub(text, 13))
        if targetName == "" then
            ply:ChatPrint("Usage: /partystrip <name>")
            return ""
        end

        local target, err = FindPlayerByPartialName(ply, targetName)
        if not target then
            ply:ChatPrint(err)
            return ""
        end

        if not IsPlayerInAnyParty(target) then
            ply:ChatPrint(target:Nick() .. " isn't in a party.")
            return ""
        end

        AdminRemoveFromParty(ply, target)
        ply:ChatPrint("Removed " .. target:Nick() .. " from their party.")

        return ""
    end)

    concommand.Add("useturn", function(ply, cmd, args)
        -- Validate if the player is in a fight
        local engageWeapon = ply:GetWeapon("smti_engageswep")
        if not IsValid(engageWeapon) then
            ply:ChatPrint("You don't have the Engage SWEP or it's not valid.")
            return
        end

        if not engageWeapon.FightId or
            not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
            ply:ChatPrint("You are not in a fight.")
            return
        end

        local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
        if not fight.Started then
            ply:ChatPrint("The fight has not started yet.")
            return
        end

        -- Call the function to proceed to the next turn using the metatable
        TBCWeaponMetatable.NextTurn(engageWeapon)
    end)

    hook.Add("PlayerSay", "UseTurnChatCommand", function(ply, text, team)
        local cmd = string.lower(text) -- Convert the text to lowercase for case-insensitive comparison
        if cmd == "/useturn" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return
            end

            TBCWeaponMetatable.NextTurn(engageWeapon)
            return "" -- Prevent the message "/useturn" from being displayed in the chat
        end
    end)

    hook.Add("PlayerSay", "TBCBatonPass", function(ply, text)
        local command = string.lower(text)
        if string.sub(command, 1, 9) == "/bp" or string.sub(command, 1, 9) ==
            "/batonpass" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return ""
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return ""
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return ""
            end

            if (timer.Exists("TurnEndTimer_" .. ply:UserID())) then
                ply:ChatPrint("Can you wait a little bit? Let it sync in...")
                return ""
            end

            local currentActiveSide = fight.ActiveSide
            local currentTurnPlayer =
                fight[currentActiveSide][fight.ActiveMember]

            -- The entity whose One More is being passed: the player, or their
            -- demon companion if they are acting through it on its turn
            local actingEntity = ply

            if currentTurnPlayer ~= ply then
                local controlledDemon = ply.TBCControlledDemon
                if IsValid(controlledDemon) and currentTurnPlayer == controlledDemon then
                    actingEntity = controlledDemon
                else
                    ply:ChatPrint("It's not your turn yet.")
                    return ""
                end
            end

            if fight.TurnCounter > 1 then
                local userBuffsTable = GetAllStats(actingEntity, "buffs")
                if userBuffsTable["One_More"] then
                    -- pass to the NEXT member in the turn order, wrapping around
                    local nextMemberIndex = fight.ActiveMember + 1
                    if nextMemberIndex > #fight[fight.ActiveSide] then
                        nextMemberIndex = 1
                    end

                    local nextTurnPlayer =
                        fight[fight.ActiveSide][nextMemberIndex]

                    engageWeapon:AnnounceMessage(actingEntity:Name() ..
                                                     " has passed the baton to " ..
                                                     nextTurnPlayer:Name() ..
                                                     "!")

                    RemoveStat(actingEntity, "One_More", "buffs")

                    local targetBuffsTable =
                        GetAllStats(nextTurnPlayer, "buffs")

                    targetBuffsTable["Baton_Pass"] = {stacks = 1, duration = 1}

                    AssignStat(nextTurnPlayer, "Baton_Pass",
                               targetBuffsTable["Baton_Pass"], "buffs")

                    nextTurnPlayer:ChatPrint("You now have Baton Pass!")

                    engageWeapon:EndAbility()
                else
                    ply:ChatPrint(
                        "You don't have One More. Therefore, you don't have a baton to pass...")
                    return ""
                end
            else
                ply:ChatPrint(
                    "This is the last turn in the turn cycle. You cannot baton pass.")
                return ""
            end

            return ""
        end
    end)

    hook.Add("PlayerSay", "TBCGuard", function(ply, text)
        local command = string.lower(text)
        if string.sub(command, 1, 9) == "/guard" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return ""
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return ""
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return ""
            end

            if (timer.Exists("TurnEndTimer_" .. ply:UserID())) then
                ply:ChatPrint("Can you wait a little bit? Let it sync in...")
                return ""
            end

            local currentActiveSide = fight.ActiveSide
            local currentTurnPlayer =
                fight[currentActiveSide][fight.ActiveMember]

            if currentTurnPlayer ~= ply then
                ply:ChatPrint("It's not your turn yet.")
                return ""
            end

            local userBuffsTable = GetAllStats(ply, "buffs")

            userBuffsTable["Guard"] = {stacks = 1, duration = 2}

            AssignStat(ply, "Guard", userBuffsTable["Guard"], "buffs")

            engageWeapon:AnnounceMessage(ply:Name() .. " is now guarding!")

            HandleGuardReaction(ply, userBuffsTable)

            engageWeapon:EndAbility()

            return ""
        end
    end)

    hook.Add("PlayerSay", "TBCSetHPCommand", function(ply, text)
        local command = string.lower(text)
        if string.sub(command, 1, 9) == "/tbcsethp" then
            -- Hide the command from chat regardless of admin status
            local hideCommand = ""

            -- Check if the player is an admin
            if ply:IsAdmin() then
                local args = string.Split(string.sub(text, 10), " ")
                if #args == 3 then
                    local targetName = string.lower(args[2])
                    local hpToSet = tonumber(args[3])

                    if hpToSet then
                        local playerFound = false -- Flag to check if any player is found

                        for _, target in pairs(player.GetAll()) do
                            if string.find(string.lower(target:Name()),
                                           targetName, 1, true) then
                                target:SetNWInt("TBCHP", hpToSet)
                                ply:ChatPrint(
                                    "Set " .. target:Name() .. "'s HP to " ..
                                        hpToSet)
                                target:ChatPrint(ply:Name() ..
                                                     " set your HP to " ..
                                                     hpToSet)
                                playerFound = true -- Set flag to true if player is found
                            end
                        end

                        if not playerFound then
                            ply:ChatPrint("Player not found!")
                        end
                    else
                        ply:ChatPrint("Invalid HP value!")
                    end
                else
                    ply:ChatPrint("Usage: /tbcSetHP <name> <hpToSet>")
                end
            else
                ply:ChatPrint("You do not have permission to use this command.")
            end

            return hideCommand -- Hide the command from the chat
        end
    end)

    hook.Add("PlayerSay", "TBCSetMPCommand", function(ply, text)
        local command = string.lower(text)
        if string.sub(command, 1, 9) == "/tbcsetmp" then
            -- Hide the command from chat regardless of admin status
            local hideCommand = ""

            -- Check if the player is an admin
            if ply:IsAdmin() then
                local args = string.Split(string.sub(text, 10), " ")
                if #args == 3 then
                    local targetName = string.lower(args[2])
                    local mpToSet = tonumber(args[3])

                    if mpToSet then
                        local playerFound = false -- Flag to check if any player is found

                        for _, target in pairs(player.GetAll()) do
                            if string.find(string.lower(target:Name()),
                                           targetName, 1, true) then
                                target:SetNWInt("TBCMP", mpToSet)
                                ply:ChatPrint(
                                    "Set " .. target:Name() .. "'s MP to " ..
                                        mpToSet)
                                target:ChatPrint(ply:Name() ..
                                                     " set your MP to " ..
                                                     mpToSet)
                                playerFound = true -- Set flag to true if player is found
                            end
                        end

                        if not playerFound then
                            ply:ChatPrint("Player not found!")
                        end
                    else
                        ply:ChatPrint("Invalid MP value!")
                    end
                else
                    ply:ChatPrint("Usage: /tbcSetMP <name> <mpToSet>")
                end
            else
                ply:ChatPrint("You do not have permission to use this command.")
            end

            return hideCommand -- Hide the command from the chat
        end
    end)

    hook.Add("PlayerSay", "TBCSetTechCommand", function(ply, text)
        local command = string.lower(text)

        if string.sub(command, 1, 11) == "/tbcsettech" then
            -- Hide the command from chat regardless of admin status
            local hideCommand = ""

            -- Check if the player is an admin
            if ply:IsAdmin() then
                local args = string.Split(string.sub(text, 12), " ")
                if #args == 3 then
                    local targetName = string.lower(args[2])
                    local techToSet = tonumber(args[3])

                    if techToSet then
                        local playerFound = false -- Flag to check if any player is found

                        for _, target in pairs(player.GetAll()) do
                            if string.find(string.lower(target:Name()),
                                           targetName, 1, true) then
                                target:SetNWInt("TBCTechnique", techToSet)
                                ply:ChatPrint(
                                    "Set " .. target:Name() ..
                                        "'s Technique to " .. techToSet)
                                target:ChatPrint(ply:Name() ..
                                                     " set your Technique to " ..
                                                     techToSet)
                                playerFound = true -- Set flag to true if player is found
                            end
                        end

                        if not playerFound then
                            ply:ChatPrint("Player not found!")
                        end
                    else
                        ply:ChatPrint("Invalid Technique value!")
                    end
                else
                    ply:ChatPrint("Usage: /tbcSetTech <name> <techToSet>")
                end
            else
                ply:ChatPrint("You do not have permission to use this command.")
            end

            return hideCommand -- Hide the command from the chat
        end
    end)

    hook.Add("PlayerSay", "TBCSetLuckCommand", function(ply, text)
        local command = string.lower(text)

        if string.sub(command, 1, 11) == "/tbcsetluck" then
            -- Hide the command from chat regardless of admin status
            local hideCommand = ""

            -- Check if the player is an admin
            if ply:IsAdmin() then
                local args = string.Split(string.sub(text, 12), " ")
                if #args == 3 then
                    local targetName = string.lower(args[2])
                    local luckToSet = tonumber(args[3])

                    if luckToSet then
                        local playerFound = false -- Flag to check if any player is found

                        for _, target in pairs(player.GetAll()) do
                            if string.find(string.lower(target:Name()),
                                           targetName, 1, true) then
                                target:SetNWInt("TBCLuck", luckToSet)
                                ply:ChatPrint(
                                    "Set " .. target:Name() .. "'s Luck to " ..
                                        luckToSet)
                                target:ChatPrint(ply:Name() ..
                                                     " set your Luck to " ..
                                                     luckToSet)
                                playerFound = true -- Set flag to true if player is found
                            end
                        end

                        if not playerFound then
                            ply:ChatPrint("Player not found!")
                        end
                    else
                        ply:ChatPrint("Invalid Luck value!")
                    end
                else
                    ply:ChatPrint("Usage: /tbcSetLuck <name> <luckToSet>")
                end
            else
                ply:ChatPrint("You do not have permission to use this command.")
            end

            return hideCommand -- Hide the command from the chat
        end
    end)

    hook.Add("PlayerSay", "EscapeChatCommand", function(ply, text, team)
        local cmd = string.lower(text) -- Convert the text to lowercase for case-insensitive comparison
        if cmd == "/escape" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return ""
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return ""
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return ""
            end

            if (timer.Exists("TurnEndTimer_" .. ply:UserID())) then
                ply:ChatPrint("Can you wait a little bit? Let it sync in...")
                return ""
            end

            local currentActiveSide = fight.ActiveSide
            local currentTurnPlayer =
                fight[currentActiveSide][fight.ActiveMember]

            if currentTurnPlayer ~= ply then
                ply:ChatPrint("It's not your turn yet.")
                return ""
            end

            -- Call the function to proceed to escape using the metatable
            TBCWeaponMetatable.Escape(engageWeapon)
            return ""
        end
    end)

    hook.Add("PlayerSay", "NegotiateChatCommand", function(ply, text, team)
        local cmd = string.lower(text) -- Convert the text to lowercase for case-insensitive comparison
        if cmd == "/negotiate" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return ""
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return ""
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return ""
            end

            if (timer.Exists("TurnEndTimer_" .. ply:UserID())) then
                ply:ChatPrint("Can you wait a little bit? Let it sync in...")
                return ""
            end

            local currentActiveSide = fight.ActiveSide
            local currentTurnPlayer =
                fight[currentActiveSide][fight.ActiveMember]

            if currentTurnPlayer ~= ply then
                ply:ChatPrint("It's not your turn yet.")
                return ""
            end

            -- Call the function to proceed to escape using the metatable
            TBCWeaponMetatable.Negotiation(engageWeapon)
            return "" -- Prevent the message "/useturn" from being displayed in the chat
        end
    end)

    hook.Add("PlayerSay", "EndFightCommand", function(ply, text, team)
        if string.lower(text) == "/endfight" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return ""
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return ""
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return ""
            end

            local playerInFight = false
            for _, player in ipairs(fight.Side1) do
                if player == ply then
                    playerInFight = true
                    break
                end
            end
            for _, player in ipairs(fight.Side2) do
                if player == ply then
                    playerInFight = true
                    break
                end
            end
            if playerInFight then
                local userId = ply:UserID()
                -- Toggle the player's end fight request
                if fight.EndRequests[userId] then
                    fight.EndRequests[userId] = nil -- Remove the end fight request
                    engageWeapon:AnnounceMessage(ply:Nick() ..
                                                     " has cancelled their vote to end the fight.")
                else
                    fight.EndRequests[userId] = true -- Add the end fight request
                    engageWeapon:AnnounceMessage(ply:Nick() ..
                                                     " has voted to end the fight.")
                end
                TBCWeaponMetatable.CheckEndFight(engageWeapon) -- Check if the fight should be ended
            end

            return "" -- Prevent the message from being sent to chat
        end
    end)

    -- New hook for /afk command
    hook.Add("PlayerSay", "AFKCommand", function(ply, text, team)
        if string.lower(text) == "/afk" then
            -- Validate if the player is in a fight
            local engageWeapon = ply:GetWeapon("smti_engageswep")
            if not IsValid(engageWeapon) then
                ply:ChatPrint(
                    "You don't have the Engage SWEP or it's not valid.")
                return ""
            end

            if not engageWeapon.FightId or
                not TBCWeaponMetatable.OngoingFights[engageWeapon.FightId] then
                ply:ChatPrint("You are not in a fight.")
                return ""
            end

            local fight = TBCWeaponMetatable.OngoingFights[engageWeapon.FightId]
            if not fight.Started then
                ply:ChatPrint("The fight has not started yet.")
                return ""
            end

            local playerSide = nil
            local activePlayer = fight[fight.ActiveSide][fight.ActiveMember]

            -- Determine the side of the player issuing the /afk command
            for _, player in ipairs(fight.Side1) do
                if player == ply then
                    playerSide = "Side1"
                    break
                end
            end
            for _, player in ipairs(fight.Side2) do
                if player == ply then
                    playerSide = "Side2"
                    break
                end
            end

            -- Check if the player is on the same side as the active player
            if playerSide and fight.ActiveSide == playerSide then
                if #fight[fight.ActiveSide] > 2 then
                    local userId = ply:UserID()

                    -- Toggle the player's afk request
                    if fight.AFKRequests[userId] then
                        fight.AFKRequests[userId] = nil -- Remove the afk request
                        engageWeapon:AnnounceMessage(ply:Nick() ..
                                                         " has cancelled their vote to skip due to AFK.")
                    else
                        fight.AFKRequests[userId] = true -- Add the afk request
                        engageWeapon:AnnounceMessage(ply:Nick() ..
                                                         " has voted to skip due to AFK.")
                    end

                    TBCWeaponMetatable.CheckAFK(engageWeapon) -- Check if the active player's turn should be skipped
                else
                    ply:ChatPrint(
                        "You cannot vote to skip with less than 3 members in your party.")
                end
            else
                -- Notify the player they can't vote as the active player is not on their side
                ply:ChatPrint(
                    "You cannot vote to skip as the active player is not on your side.")
            end

            return "" -- Prevent the message from being sent to chat
        end
    end)
end
