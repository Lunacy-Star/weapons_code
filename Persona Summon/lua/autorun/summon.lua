-- Enhanced Persona Summoning System
-- This script adds a /summon command that creates a following NPC with movement and attack animations

if SERVER then
    -- Table to store each player's persona entity
    local playerPersonas = {}
    -- Table to track player states
    local playerStates = {}

    -- Model to use (with fallbacks)
    local modelOptions = {
        "models/smtdx2_nk/pixie/pixiedx2.mdl", -- First choice
        "models/Humans/Group01/Female_01.mdl" -- Fallback model if first isn't available
    }

    -- Animation sequence names (adjust these based on what's available in your model)
    local animations = {
        idle = {"idle_all_02", "idle", "idle_subtle"},
        walk = {"walk_all", "walk", "run"},
        attack = {"range_attack_pistol", "range_attack", "melee_attack"}
    }

    -- Try to precache models (but don't force downloads)
    for _, model in ipairs(modelOptions) do 
        util.PrecacheModel(model) 
    end

    -- Clean up persona when player disconnects
    hook.Add("PlayerDisconnected", "CleanupPersona", function(ply)
        if IsValid(playerPersonas[ply]) then
            playerPersonas[ply]:Remove()
            playerPersonas[ply] = nil
        end
        playerStates[ply] = nil
    end)

    -- Find a valid model from our options
    local function FindValidModel()
        for _, model in ipairs(modelOptions) do
            if util.IsValidModel(model) then return model end
        end
        -- Last resort - return default citizen model which will always exist
        return "models/Humans/Group01/Female_01.mdl"
    end

    -- Find a valid animation sequence for the entity
    local function FindSequence(entity, animationType)
        local sequenceOptions = animations[animationType] or animations.idle
        
        for _, seqName in ipairs(sequenceOptions) do
            local seq = entity:LookupSequence(seqName)
            if seq and seq ~= -1 then
                return seq
            end
        end
        
        -- Last resort, use ACT based animations
        if animationType == "walk" then
            return entity:SelectWeightedSequence(ACT_WALK)
        elseif animationType == "attack" then
            return entity:SelectWeightedSequence(ACT_RANGE_ATTACK1)
        else
            return entity:SelectWeightedSequence(ACT_IDLE)
        end
    end

    -- Create the persona entity
    local function CreatePersona(ply)
        -- Remove existing persona if there is one
        if IsValid(playerPersonas[ply]) then 
            playerPersonas[ply]:Remove() 
        end

        -- Initialize player state
        playerStates[ply] = {
            isMoving = false,
            isAttacking = false,
            lastAnimationType = "idle",
            lastAnimationChange = 0
        }

        -- Find a valid model
        local modelToUse = FindValidModel()

        -- Create new persona entity (using prop_dynamic which works well for custom models)
        local persona = ents.Create("prop_dynamic")
        if not IsValid(persona) then return nil end

        -- Set position behind and to the left of player
        local behind = ply:GetForward() * -50 -- 50 units behind
        local left = ply:GetRight() * -30     -- 30 units to the left
        local pos = ply:GetPos() + behind + left
        pos.z = ply:GetPos().z -- Same height as player
        persona:SetPos(pos)

        -- Set model and other properties
        persona:SetModel(modelToUse)
        persona:SetAngles(ply:GetAngles())
        persona:SetOwner(ply)

        -- Spawn the entity first
        persona:Spawn()
        persona:Activate()

        -- Enable animation updates
        persona:SetPlaybackRate(1.0)

        -- Set initial idle animation
        local idleSequence = FindSequence(persona, "idle")
        persona:ResetSequence(idleSequence)

        -- Make it non-solid so it doesn't block players
        persona:SetCollisionGroup(COLLISION_GROUP_WORLD)

        -- Store reference to persona
        playerPersonas[ply] = persona

        -- Tell the player which model was used
        ply:ChatPrint("Persona summoned using model: " .. modelToUse)

        return persona
    end

    -- Hook to detect player attacking (via weapon primary attack)
    hook.Add("EntityFireBullets", "PersonaDetectAttack", function(entity, data)
        if entity:IsPlayer() and IsValid(playerPersonas[entity]) then
            playerStates[entity].isAttacking = true
            playerStates[entity].attackStartTime = CurTime()
        end
    end)

    -- Update persona position and animation every frame
    hook.Add("Think", "UpdatePersonaState", function()
        for ply, persona in pairs(playerPersonas) do
            if IsValid(ply) and IsValid(persona) and playerStates[ply] then
                local state = playerStates[ply]
                
                -- Calculate position behind and to the left of the player
                local behind = ply:GetForward() * -50 -- 50 units behind
                local left = ply:GetRight() * -30     -- 30 units to the left
                local targetPos = ply:GetPos() + behind + left
                targetPos.z = ply:GetPos().z

                -- Smoothly move toward target position
                local currentPos = persona:GetPos()
                local newPos = LerpVector(0.1, currentPos, targetPos)
                persona:SetPos(newPos)

                -- Make persona face same direction as player
                persona:SetAngles(ply:GetAngles())

                -- Detect player movement
                local velocity = ply:GetVelocity()
                local speed = velocity:Length()
                state.isMoving = speed > 50 -- Consider moving if speed is above threshold
                
                -- Reset attack state after a short time
                if state.isAttacking and CurTime() - state.attackStartTime > 1.5 then
                    state.isAttacking = false
                end

                -- Determine which animation to play
                local currentAnimationType = "idle"
                if state.isAttacking then
                    currentAnimationType = "attack"
                elseif state.isMoving then
                    currentAnimationType = "walk"
                end

                -- Only change animation if state changed or it's been a while
                if currentAnimationType ~= state.lastAnimationType or 
                   CurTime() - state.lastAnimationChange > 10 then
                    
                    local sequence = FindSequence(persona, currentAnimationType)
                    persona:ResetSequence(sequence)
                    
                    state.lastAnimationType = currentAnimationType
                    state.lastAnimationChange = CurTime()
                end
            else
                -- Clean up invalid references
                if not IsValid(ply) or not IsValid(persona) then
                    if IsValid(persona) then persona:Remove() end
                    playerPersonas[ply] = nil
                    playerStates[ply] = nil
                end
            end
        end
    end)

    -- Add chat command
    hook.Add("PlayerSay", "PersonaSummon", function(ply, text, team)
        local cmd = string.lower(text) -- Convert the text to lowercase for case-insensitive comparison

        if cmd == "/summon" then
            local persona = CreatePersona(ply)

            if IsValid(persona) then
                ply:ChatPrint("Persona has been summoned!")
            else
                ply:ChatPrint("Failed to summon persona.")
            end

            return "" -- Prevent the message from being displayed in the chat
        elseif cmd == "/dismiss" then
            if IsValid(playerPersonas[ply]) then
                playerPersonas[ply]:Remove()
                playerPersonas[ply] = nil
                playerStates[ply] = nil
                ply:ChatPrint("Persona has been dismissed.")
            else
                ply:ChatPrint("You don't have a persona summoned.")
            end

            return "" -- Prevent the message from being displayed in the chat
        end
    end)

    -- Hook to detect player weapon attacks (additional method)
    hook.Add("KeyPress", "PersonaDetectAttackKey", function(ply, key)
        if (key == IN_ATTACK or key == IN_ATTACK2) and 
           IsValid(playerPersonas[ply]) and 
           playerStates[ply] then
            playerStates[ply].isAttacking = true
            playerStates[ply].attackStartTime = CurTime()
        end
    end)
end