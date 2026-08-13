-- shared_resnode_persist.lua
-- Persistence system for resource nodes.
--
-- Client identification strategy:
--   base_resnode declares a NetworkVar via SetupDataTables:
--     Bool 0 "IsResourceNode"  — always true on every resource node
--
-- This file now exposes a server console command to persist all resource
-- nodes to the current map save file.

-- ============================================================
-- Server: save / load logic
-- ============================================================

if SERVER then
    local MAP_NAME      = game.GetMap()
    local SAVE_FILE     = "resnode_" .. MAP_NAME .. ".json"
    local SAVE_INTERVAL = 60

    -- Keyed by entity EntIndex while the server is running.
    local PersistentNodes = {}

    -- Serialisation helpers
    local function VecToTable(v) return {x = v.x, y = v.y, z = v.z} end
    local function AngToTable(a) return {p = a.p, y = a.y, r = a.r} end
    local function TableToVec(t) return Vector(t.x, t.y, t.z) end
    local function TableToAng(t) return Angle(t.p, t.y, t.r) end

    local function SnapshotNode(ent)
        if not IsValid(ent) then return nil end

        -- Convert absolute CurTime() deadlines to seconds-remaining so they
        -- survive a server restart (CurTime resets to 0 on each boot).
        local savedCooldowns = {}
        if ent.PlayerCooldowns then
            local now = CurTime()
            for steamID, endTime in pairs(ent.PlayerCooldowns) do
                local remaining = endTime - now
                if remaining > 0 then
                    savedCooldowns[steamID] = remaining
                end
            end
        end

        return {
            classname       = ent:GetClass(),
            pos             = VecToTable(ent:GetPos()),
            ang             = AngToTable(ent:GetAngles()),
            model           = ent:GetModel(),
            GatherTime      = ent.GatherTime,
            GatherRange     = ent.GatherRange,
            MaxLookAngle    = ent.MaxLookAngle,
            SlotAmount      = ent.SlotAmount,
            PlayerCooldown  = ent.PlayerCooldown,
            PlayerCooldowns = savedCooldowns,
        }
    end

    local function GetAllResourceNodes()
        local nodes = {}
        for _, ent in pairs(ents.GetAll()) do
            if IsValid(ent) and ent.GetIsResourceNode and ent:GetIsResourceNode() then
                table.insert(nodes, ent)
            end
        end
        return nodes
    end

    local function WriteAllResourceNodesToFile()
        local nodes = GetAllResourceNodes()
        local toSave = {}

        for _, ent in ipairs(nodes) do
            local snap = SnapshotNode(ent)
            if snap then
                table.insert(toSave, snap)
            end
        end

        local encoded = util.TableToJSON(toSave, true)
        if encoded then
            file.Write(SAVE_FILE, encoded)
            return true, #toSave
        end

        return false, 0
    end

    concommand.Add("resnode_persist", function(ply, cmd, args)
        if IsValid(ply) and not ply:IsAdmin() then
            ply:ChatPrint("You do not have permission to run this command.")
            return
        end

        local success, count = WriteAllResourceNodesToFile()
        if success then
            if IsValid(ply) then
                ply:ChatPrint("[ResnodePersist] Persisted " .. count .. " resource nodes to " .. SAVE_FILE)
            else
                print("[ResnodePersist] Persisted " .. count .. " resource nodes to " .. SAVE_FILE)
            end
        else
            if IsValid(ply) then
                ply:ChatPrint("[ResnodePersist] Failed to write persistent node file.")
            else
                print("[ResnodePersist] Failed to write persistent node file.")
            end
        end
    end)

    function SavePersistentNodes()
        WriteAllResourceNodesToFile()
    end

    local function SpawnNodeFromRecord(record)
        local ent = ents.Create(record.classname)
        if not IsValid(ent) then
            print("[ResnodePersist] WARNING: Could not create '" ..
                  tostring(record.classname) .. "'")
            return nil
        end

        ent:SetPos(TableToVec(record.pos))
        ent:SetAngles(TableToAng(record.ang))

        if record.GatherTime     then ent.GatherTime     = record.GatherTime     end
        if record.GatherRange    then ent.GatherRange    = record.GatherRange    end
        if record.MaxLookAngle   then ent.MaxLookAngle   = record.MaxLookAngle   end
        if record.SlotAmount     then ent.SlotAmount     = record.SlotAmount     end
        if record.PlayerCooldown then ent.PlayerCooldown = record.PlayerCooldown end

        -- Set Persistent BEFORE Spawn() so that Initialize() reads the correct
        -- value when it calls self:SetIsPersistent(self.Persistent or false).
        ent.Persistent = true

        ent:Spawn()
        ent:Activate()

        -- SetIsPersistent AFTER Spawn/Activate because that is when the
        -- NetworkVar is registered and the setter becomes available.
        ent:SetIsPersistent(true)

        if record.model and record.model ~= "" then
            ent:SetModel(record.model)
        end

        -- Restore per-player cooldowns AFTER Spawn/Activate because Initialize()
        -- resets PlayerCooldowns = {} and would wipe anything set beforehand.
        if record.PlayerCooldowns then
            local now = CurTime()
            ent.PlayerCooldowns = {}
            for steamID, remaining in pairs(record.PlayerCooldowns) do
                ent.PlayerCooldowns[steamID] = now + remaining
            end
        end

        local phys = ent:GetPhysicsObject()
        if IsValid(phys) then
            phys:EnableMotion(false)
            phys:EnableGravity(false)
            phys:Wake()
        end

        PersistentNodes[ent:EntIndex()] = true
        return ent
    end

    function LoadPersistentNodes()
        if not file.Exists(SAVE_FILE, "DATA") then return end

        local raw = file.Read(SAVE_FILE, "DATA")
        if not raw or raw == "" then return end

        local records = util.JSONToTable(raw)
        if not records then
            print("[ResnodePersist] WARNING: Failed to parse " .. SAVE_FILE)
            return
        end

        local spawned = 0
        for _, record in ipairs(records) do
            if SpawnNodeFromRecord(record) then spawned = spawned + 1 end
        end

        print("[ResnodePersist] Loaded " .. spawned ..
              " persistent nodes for map " .. MAP_NAME)
    end

    function SetNodePersistent(ent, persistent)
        if not IsValid(ent) then return end

        ent.Persistent = persistent
        -- NetworkVar setter — syncs to all clients immediately.
        ent:SetIsPersistent(persistent)

        if persistent then
            PersistentNodes[ent:EntIndex()] = true

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then
                phys:EnableMotion(false)
                phys:EnableGravity(false)
                phys:Wake()
            end
        else
            PersistentNodes[ent:EntIndex()] = nil
        end

        SavePersistentNodes()
    end

    timer.Create("ResnodePersist_AutoSave", SAVE_INTERVAL, 0, function()
        SavePersistentNodes()
    end)

    timer.Simple(1, function()
        LoadPersistentNodes()
    end)
end