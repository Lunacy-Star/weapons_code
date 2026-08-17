AddCSLuaFile()

-- Demon companion entity. Follows its master, takes orders from the
-- Demon Commander SWEP and participates in turn-based combat as a full
-- fight member (it is inserted into the fight side list after its master).

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Demon Companion"
ENT.Author = "Nara"
ENT.Category = "Demons"

ENT.Spawnable = false
ENT.AdminOnly = true

-- Flags used by the TBC code
ENT.isTBCEntity = true -- CheckIfValidTBCEntity() accepts this entity as a target
ENT.isTBCDemon = true -- demon-specific handling (turn order, votes, cleanup)

-- ============================================================
-- Player-compatibility methods. The TBC code calls these on every
-- fight member, so the demon must answer them like a player would.
-- ============================================================
function ENT:Name()
    return self:GetNWString("DemonName", self.PrintName)
end

function ENT:Nick()
    return self:Name()
end

-- Unique, stable id so GetAllStats/AssignStat (keyed by SteamID) work on demons
function ENT:SteamID()
    return self:GetNWString("DemonGUID", "DEMON_UNKNOWN")
end

function ENT:SteamID64()
    return self:SteamID()
end

function ENT:UserID()
    return -self:EntIndex()
end

function ENT:Alive()
    return self:GetNWInt("TBCHP", 0) > 0
end

function ENT:ChatPrint(message)
    -- Forward battle messages to the master so nothing is lost
    if SERVER then
        local master = self:GetMaster()
        if IsValid(master) then
            master:ChatPrint("[" .. self:Name() .. "] " .. message)
        end
    end
end

-- The fight code and status handlers constantly ask members for a weapon to
-- read FightId off or to announce through (ply:GetActiveWeapon():AnnounceMessage,
-- target:GetWeapon("smti_engageswep").FightId, turn regen/ailment handlers...).
-- Hand over the MASTER's engage swep: it is in the same fight as the demon,
-- so FightId checks and announcements behave exactly as they would for a player.
function ENT:GetWeapon(class)
    if class == "smti_engageswep" then
        local master = self:GetMaster()
        if IsValid(master) then
            return master:GetWeapon("smti_engageswep")
        end
    end
    return NULL
end

-- Deliberately empty: this keeps demons un-engageable directly (fights start
-- through the master) and stops ClearFightId(demon) from clearing the
-- master's weapons.
function ENT:GetWeapons()
    return {}
end

function ENT:GetActiveWeapon()
    local master = self:GetMaster()
    if IsValid(master) then
        local engage = master:GetWeapon("smti_engageswep")
        if IsValid(engage) then
            return engage
        end
    end
    return NULL
end

function ENT:GetMaster()
    return self:GetNWEntity("DemonMaster", NULL)
end

if CLIENT then
    surface.CreateFont("DemonCompName", {font = "Trebuchet24", size = 26, weight = 700})

    function ENT:Draw()
        self:DrawModel()
    end

    function ENT:Think()
        self:FrameAdvance()
        self:SetNextClientThink(CurTime())
        return true
    end

    -- Overhead name + HP bar
    hook.Add("PostDrawTranslucentRenderables", "DemonCompOverhead", function()
        for _, ent in ipairs(ents.FindByClass("smt_demon")) do
            if IsValid(ent) and EyePos():DistToSqr(ent:GetPos()) <= 700 * 700 then
                DrawDemonOverhead(ent)
            end
        end
    end)

    function DrawDemonOverhead(ent)
            local pos = ent:GetPos() + Vector(0, 0, ent:OBBMaxs().z + 14)
            local ang = EyeAngles()
            ang:RotateAroundAxis(ang:Up(), -90)
            ang:RotateAroundAxis(ang:Forward(), 90)

            local hp = ent:GetNWInt("TBCHP", 0)
            local maxHp = math.max(ent:GetNWInt("TBCMAXHP", 1), 1)
            local frac = math.Clamp(hp / maxHp, 0, 1)

            local master = ent:GetMaster()
            local masterName = IsValid(master) and master:Nick() or "?"

            cam.Start3D2D(pos, ang, 0.1)
                draw.SimpleTextOutlined(ent:Name(), "DemonCompName", 0, -30,
                    Color(255, 90, 90), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
                draw.SimpleTextOutlined(masterName .. "'s demon", "Default", 0, -8,
                    Color(220, 220, 220), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))

                draw.RoundedBox(4, -60, 4, 120, 12, Color(20, 20, 20, 200))
                if frac > 0 then
                    draw.RoundedBox(4, -58, 6, 116 * frac, 8,
                        Color(255 * (1 - frac), 200 * frac + 55, 60))
                end
                if hp <= 0 then
                    draw.SimpleTextOutlined("DOWN", "Default", 0, 26,
                        Color(255, 60, 60), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color(0, 0, 0))
                end
            cam.End3D2D()
    end

    return
end

-- ============================================================
-- SERVER
-- ============================================================

-- Configures the freshly spawned entity as a specific demon.
-- savedState is the party entry ({hp = ..., mp = ...}) if it was pocketed before.
function ENT:SetupDemon(master, charId, guid, savedState)
    local charData = DEMONCOMP.GetCharData(charId)
    if not charData then
        self:Remove()
        return false
    end

    self.CharId = charId
    self:SetNWString("DemonCharId", charId)
    self:SetNWString("DemonName", charData.name or charId)
    self:SetNWString("DemonGUID", "DEMON_" .. guid)
    self:SetNWEntity("DemonMaster", master)

    -- Same networked identity the TBC code reads off players
    self:SetNWString("AssignedCharacter", charId)
    self:SetNWInt("TBCMAXHP", charData.combatHP or 100)
    self:SetNWInt("TBCMAXMP", charData.combatMP or 50)
    local savedHp = savedState and savedState.hp
    if savedHp ~= nil and savedHp <= 0 then
        savedHp = 1 -- never deploy an already-dead demon
    end
    self:SetNWInt("TBCHP", savedHp or charData.combatHP or 100)
    self:SetNWInt("TBCMP", (savedState and savedState.mp) or charData.combatMP or 50)
    self:SetNWInt("TBCLuck", charData.Luck or 10)
    self:SetNWInt("TBCTechnique", charData.Technique or 20)

    self:SetNW2String("resist", util.TableToJSON(charData.resist or {}))
    self:SetNW2String("weak", util.TableToJSON(charData.weak or {}))
    self:SetNW2String("block", util.TableToJSON(charData.block or {}))
    self:SetNW2String("drain", util.TableToJSON(charData.drain or {}))
    self:SetNW2String("repel", util.TableToJSON(charData.repel or {}))

    if charData.permaBuffs then
        for status, properties in pairs(charData.permaBuffs) do
            AssignStat(self, status, properties, "permabuffs")
            ApplyStatBoostBuff(self, properties)
        end
    end
    if charData.permaDebuffs then
        for status, properties in pairs(charData.permaDebuffs) do
            AssignStat(self, status, properties, "permadebuffs")
        end
    end

    -- Model with fallback
    local model = charData.model and charData.model[1] or nil
    if not model or not util.IsValidModel(model) then
        model = "models/Humans/Group01/Female_01.mdl"
    end
    self:SetModel(model)
    self:SetCollisionBounds(self:OBBMins(), self:OBBMaxs())

    -- Build the list of valid sequences per state for this model
    self.AnimSets = {}
    local anims = DEMONCOMP.GetAnims(charId)
    for state, sequences in pairs(anims) do
        self.AnimSets[state] = {}
        for _, seqName in ipairs(sequences) do
            local seq = self:LookupSequence(seqName)
            if seq and seq > 0 then
                table.insert(self.AnimSets[state], seq)
            end
        end
    end

    self.LastKnownHP = self:GetNWInt("TBCHP", 100)
    self:PlayStateAnim("idle", true)

    return true
end

function ENT:Initialize()
    self:SetMoveType(MOVETYPE_NONE)
    self:SetSolid(SOLID_BBOX)
    -- Players can walk through the demon but weapon traces still hit it,
    -- so it can be targeted by TBC skills.
    self:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
    self:SetUseType(SIMPLE_USE)
    self:DrawShadow(true)

    self.MoveState = "follow" -- follow | stay | moveto
    self.MoveTarget = nil
    self.CurrentAnimState = "idle"
    self.OverlayAnimEnd = 0
    self.NextAnimRefresh = 0
    self.NextHurtAllowed = 0
    self.LastKnownHP = self:GetNWInt("TBCHP", 100)

    self:SetPlaybackRate(1.0)
end

-- Picks a random valid sequence for the state. Falls back to ACT-based lookup.
function ENT:FindStateSequence(state)
    local set = self.AnimSets and self.AnimSets[state]
    if set and #set > 0 then
        return set[math.random(#set)]
    end

    local actFallback = {
        idle = ACT_IDLE,
        walk = ACT_WALK,
        attack = ACT_RANGE_ATTACK1,
        hurt = ACT_FLINCH_PHYSICS
    }
    local seq = self:SelectWeightedSequence(actFallback[state] or ACT_IDLE)
    if not seq or seq <= 0 then
        seq = self:SelectWeightedSequence(ACT_IDLE)
    end
    return seq
end

function ENT:PlayStateAnim(state, force)
    if not force and state == self.CurrentAnimState and CurTime() < self.NextAnimRefresh then
        return
    end

    local seq = self:FindStateSequence(state)
    if seq and seq > 0 then
        self:ResetSequence(seq)
        self:SetCycle(0)
        self:SetPlaybackRate(1.0)
    end

    self.CurrentAnimState = state
    -- re-roll looping anims occasionally so multi-anim states stay varied
    self.NextAnimRefresh = CurTime() + math.Rand(6, 10)
end

-- One-shot animation (attack/hurt) that temporarily overrides idle/walk
function ENT:PlayOverlayAnim(state)
    local seq = self:FindStateSequence(state)
    if seq and seq > 0 then
        self:ResetSequence(seq)
        self:SetCycle(0)
        self:SetPlaybackRate(1.0)
        local duration = self:SequenceDuration(seq)
        self.OverlayAnimEnd = CurTime() + math.Clamp(duration, 0.4, 3)
        self.CurrentAnimState = state
    end
end

function ENT:DoAttackAnim()
    self:PlayOverlayAnim("attack")
end

function ENT:DoHurtAnim()
    if CurTime() < self.NextHurtAllowed then return end
    self.NextHurtAllowed = CurTime() + 0.6
    self:PlayOverlayAnim("hurt")
end

-- Movement orders (used by the Demon Commander SWEP)
function ENT:OrderMoveTo(pos)
    self.MoveState = "moveto"
    self.MoveTarget = pos
end

function ENT:OrderStay()
    self.MoveState = "stay"
    self.MoveTarget = nil
end

function ENT:OrderFollow()
    self.MoveState = "follow"
    self.MoveTarget = nil
end

local function groundSnap(self, pos)
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 40),
        endpos = pos - Vector(0, 0, 200),
        filter = {self, self:GetMaster()},
        mask = MASK_SOLID_BRUSHONLY
    })
    if tr.Hit then
        return tr.HitPos
    end
    return pos
end

function ENT:Think()
    local master = self:GetMaster()

    if not IsValid(master) then
        -- master disconnected; the manager also cleans up, this is a fallback
        self:Remove()
        return
    end

    local now = CurTime()
    local isDead = self:GetNWInt("TBCHP", 0) <= 0

    -- Detect TBC damage (skills lower TBCHP directly, without engine damage)
    local hp = self:GetNWInt("TBCHP", 0)
    if hp < (self.LastKnownHP or hp) then
        self:DoHurtAnim()
    end
    self.LastKnownHP = hp

    local inOverlay = now < self.OverlayAnimEnd

    -- Movement
    local moving = false
    if not isDead then
        local targetPos = nil

        if self.MoveState == "follow" then
            local behind = master:GetPos() + master:GetForward() * -50 + master:GetRight() * 40
            local dist = self:GetPos():Distance(master:GetPos())

            if dist > DEMONCOMP.TeleportDistance then
                self:SetPos(groundSnap(self, behind))
            elseif dist > DEMONCOMP.FollowDistance then
                targetPos = behind
            end
        elseif self.MoveState == "moveto" and self.MoveTarget then
            if self:GetPos():Distance(self.MoveTarget) > DEMONCOMP.ArriveDistance then
                targetPos = self.MoveTarget
            else
                self.MoveState = "stay"
                self.MoveTarget = nil
            end
        end

        if targetPos then
            local dir = targetPos - self:GetPos()
            dir.z = 0
            local dist = dir:Length()

            if dist > 4 then
                dir:Normalize()
                local step = math.min(DEMONCOMP.MoveSpeed * FrameTime(), dist)
                local newPos = self:GetPos() + dir * step
                self:SetPos(groundSnap(self, newPos))
                self:SetAngles(Angle(0, dir:Angle().y, 0))
                moving = true
            end
        elseif self.MoveState == "follow" then
            -- idle next to the master: face the same way they do
            local toMaster = master:GetPos() - self:GetPos()
            if toMaster:Length2D() > 20 then
                self:SetAngles(Angle(0, toMaster:Angle().y, 0))
            end
        end
    end

    -- Animation state (overlays like attack/hurt play out first)
    if not inOverlay then
        if moving then
            self:PlayStateAnim("walk", self.CurrentAnimState ~= "walk")
        else
            self:PlayStateAnim("idle", self.CurrentAnimState ~= "idle")
        end
    end

    self:NextThink(now)
    return true
end

-- Engine damage events (weapons call DispatchTraceAttack with 0 damage
-- before running TBC logic) - used as a hurt-animation trigger.
function ENT:OnTakeDamage(dmginfo)
    self:DoHurtAnim()
end

function ENT:Use(activator)
    if not IsValid(activator) or not activator:IsPlayer() then return end
    if activator ~= self:GetMaster() then return end

    activator:ChatPrint(self:Name() .. " - HP: " .. self:GetNWInt("TBCHP", 0) ..
        "/" .. self:GetNWInt("TBCMAXHP", 0) .. " MP: " .. self:GetNWInt("TBCMP", 0) ..
        "/" .. self:GetNWInt("TBCMAXMP", 0))
end

-- Called by CheckForTeamDefeat() on every member of a defeated side.
function ENT:Kill()
    local master = self:GetMaster()
    if IsValid(master) then
        master:ChatPrint(self:Name() .. " was defeated and returned to your pocket!")
    end

    self.DiedInBattle = true
    self:Remove()
end

function ENT:OnRemove()
    if DEMONCOMP and DEMONCOMP.HandleDemonRemoved then
        DEMONCOMP.HandleDemonRemoved(self)
    end
end

scripted_ents.Register(ENT, "smt_demon")
