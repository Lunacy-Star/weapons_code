TBC_CURRENCY = TBC_CURRENCY or {}

TBC_CURRENCY.Config = {
    Name = "Macca",
    Symbol = "ћ",
    ModelPath = "",
    IconPath = "",
    SharedAmongCharacters = true,
    SavePath = "tbc_currency_data.json",
    StartingBalance = 1000,
    GiveRange = 150,
    GiveFacingDot = 0.6,
    DropMinAmount = 1,
    Salary = {
        GlobalEnabled = false,
        GlobalAmount = 500,
        GlobalInterval = 600
    }
}

if SERVER then
    TBC_CURRENCY._data = {}
    TBC_CURRENCY._dirty = false

    local SAVE_PATH = TBC_CURRENCY.Config.SavePath

    local function LoadData()
        if not file.Exists(SAVE_PATH, "DATA") then
            TBC_CURRENCY._data = {}
            return
        end
        local raw = file.Read(SAVE_PATH, "DATA")
        if not raw or raw == "" then
            TBC_CURRENCY._data = {}
            return
        end
        TBC_CURRENCY._data = util.JSONToTable(raw) or {}
    end

    local function SaveData()
        file.Write(SAVE_PATH, util.TableToJSON(TBC_CURRENCY._data, true))
        TBC_CURRENCY._dirty = false
    end

    local function ScheduleAutoSave()
        timer.Create(
            "TBC_CurrencyAutoSave",
            60,
            0,
            function()
                if TBC_CURRENCY._dirty then
                    SaveData()
                end
            end
        )
    end

    local function EnsurePlayer(steamID)
        if not TBC_CURRENCY._data[steamID] then
            TBC_CURRENCY._data[steamID] = {
                playerBalance = TBC_CURRENCY.Config.StartingBalance,
                chars = {}
            }
        end
        local e = TBC_CURRENCY._data[steamID]
        if e.balance ~= nil and e.playerBalance == nil then
            e.playerBalance = e.balance
            e.balance = nil
        end
        if not e.playerBalance then
            e.playerBalance = TBC_CURRENCY.Config.StartingBalance
        end
        if not e.chars then
            e.chars = {}
        end
    end

    local function HasCharacterSystem()
        return CHARACTERS ~= nil and CHARACTERS.List ~= nil
    end

    local function GetCharID(ply)
        if not IsValid(ply) then
            return ""
        end
        if not HasCharacterSystem() then
            return ""
        end
        return ply:GetNWString("AssignedCharacter", "")
    end

    local function EnsureChar(entry, charID, seedBalance)
        if charID == "" then
            return
        end
        if entry.chars[charID] == nil then
            entry.chars[charID] = seedBalance or TBC_CURRENCY.Config.StartingBalance
        end
    end

    function TBC_CURRENCY.GetBalance(ply)
        if not IsValid(ply) then
            return 0
        end
        local sid = ply:SteamID()
        EnsurePlayer(sid)
        local entry = TBC_CURRENCY._data[sid]
        local charID = GetCharID(ply)
        if TBC_CURRENCY.Config.SharedAmongCharacters or charID == "" then
            return entry.playerBalance
        end
        EnsureChar(entry, charID, entry.playerBalance)
        return entry.chars[charID]
    end

    function TBC_CURRENCY.SetBalance(ply, amount)
        if not IsValid(ply) then
            return
        end
        amount = math.max(0, math.floor(amount))
        local sid = ply:SteamID()
        EnsurePlayer(sid)
        local entry = TBC_CURRENCY._data[sid]
        local charID = GetCharID(ply)
        if TBC_CURRENCY.Config.SharedAmongCharacters or charID == "" then
            entry.playerBalance = amount
        else
            EnsureChar(entry, charID, entry.playerBalance)
            entry.chars[charID] = amount
        end
        TBC_CURRENCY._dirty = true
        TBC_CURRENCY.Sync(ply)
    end

    function TBC_CURRENCY.AdjustBalance(ply, delta)
        local current = TBC_CURRENCY.GetBalance(ply)
        local newBal = current + delta
        if newBal < 0 then
            return false
        end
        TBC_CURRENCY.SetBalance(ply, newBal)
        return true
    end

    function TBC_CURRENCY.GiveMoney(ply, amount)
        return TBC_CURRENCY.AdjustBalance(ply, math.abs(amount))
    end

    function TBC_CURRENCY.TakeMoney(ply, amount)
        return TBC_CURRENCY.AdjustBalance(ply, -math.abs(amount))
    end

    function TBC_CURRENCY.HasMoney(ply, amount)
        return TBC_CURRENCY.GetBalance(ply) >= amount
    end

    -- Forward declaration so OnCharacterSwitch can call it (defined in salary section below)
    local StartSalaryTimer

    function TBC_CURRENCY.OnCharacterSwitch(ply, newCharID)
        if not IsValid(ply) then
            return
        end
        local sid = ply:SteamID()
        EnsurePlayer(sid)
        local entry = TBC_CURRENCY._data[sid]
        if not HasCharacterSystem() or newCharID == nil or newCharID == "" or TBC_CURRENCY.Config.SharedAmongCharacters then
            TBC_CURRENCY.Sync(ply)
            return
        end
        EnsureChar(entry, newCharID, entry.playerBalance)
        TBC_CURRENCY._dirty = true
        TBC_CURRENCY.Sync(ply)
        -- Restart salary timer for the new character
        if StartSalaryTimer then
            StartSalaryTimer(ply)
        end
    end

    function TBC_CURRENCY.OnFlagChanged(newValue)
        TBC_CURRENCY.Config.SharedAmongCharacters = newValue
        if not newValue and HasCharacterSystem() then
            for _, ply in ipairs(player.GetAll()) do
                if IsValid(ply) then
                    local sid = ply:SteamID()
                    EnsurePlayer(sid)
                    local entry = TBC_CURRENCY._data[sid]
                    local curChar = GetCharID(ply)
                    if curChar ~= "" then
                        entry.chars[curChar] = entry.playerBalance
                    end
                    for charID, val in pairs(entry.chars) do
                        if charID ~= curChar and val == nil then
                            entry.chars[charID] = entry.playerBalance
                        end
                    end
                end
            end
        end
        TBC_CURRENCY._dirty = true
        SaveData()
        for _, ply in ipairs(player.GetAll()) do
            TBC_CURRENCY.Sync(ply)
        end
    end

    util.AddNetworkString("TBC_CurrencySync")
    util.AddNetworkString("TBC_CurrencyConfig")

    function TBC_CURRENCY.Sync(ply)
        if not IsValid(ply) then
            return
        end
        net.Start("TBC_CurrencySync")
        net.WriteInt(TBC_CURRENCY.GetBalance(ply), 32)
        net.Send(ply)
    end

    function TBC_CURRENCY.SyncConfig(ply)
        net.Start("TBC_CurrencyConfig")
        net.WriteString(TBC_CURRENCY.Config.Name)
        net.WriteString(TBC_CURRENCY.Config.Symbol)
        net.WriteString(TBC_CURRENCY.Config.IconPath or "")
        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end

    local function SpawnMoneyPile(pos, amount, owner)
        local ent = ents.Create("base_entity")
        if not IsValid(ent) then
            return
        end

        local mdl = TBC_CURRENCY.Config.ModelPath
        if not mdl or mdl == "" then
            mdl = "models/props_junk/PopCan01a.mdl"
        end

        ent:SetModel(mdl)
        ent:SetPos(pos)
        ent:SetAngles(Angle(0, math.random(0, 360), 0))
        ent:Spawn()
        ent:Activate()
        ent:SetColor(Color(255, 215, 0))
        ent:SetRenderMode(RENDERMODE_TRANSCOLOR)
        ent:SetNWInt("TBC_MoneyAmount", amount)
        ent:SetNWString("TBC_MoneyOwner", IsValid(owner) and owner:SteamID() or "")
        ent:SetUseType(SIMPLE_USE)

        local sym = TBC_CURRENCY.Config.Symbol
        local name = TBC_CURRENCY.Config.Name

        ent.Use = function(self, activator)
            if not IsValid(activator) or not activator:IsPlayer() then
                return
            end
            local pickupAmount = self:GetNWInt("TBC_MoneyAmount", 0)
            if pickupAmount <= 0 then
                return
            end
            TBC_CURRENCY.GiveMoney(activator, pickupAmount)
            activator:ChatPrint(string.format("You picked up %s%d %s.", sym, pickupAmount, name))
            for _, p in ipairs(player.GetAll()) do
                if IsValid(p) and p ~= activator and p:GetPos():Distance(self:GetPos()) < 300 then
                    p:ChatPrint(string.format("%s picked up %s%d %s.", activator:Nick(), sym, pickupAmount, name))
                end
            end
            self:Remove()
        end

        timer.Simple(
            300,
            function()
                if IsValid(ent) then
                    ent:Remove()
                end
            end
        )
        return ent
    end

    hook.Add(
        "Initialize",
        "TBC_Currency_Init",
        function()
            LoadData()
            ScheduleAutoSave()
        end
    )

    hook.Add(
        "PlayerInitialSpawn",
        "TBC_Currency_PlayerJoin",
        function(ply)
            timer.Simple(
                1,
                function()
                    if not IsValid(ply) then
                        return
                    end
                    EnsurePlayer(ply:SteamID())
                    TBC_CURRENCY.Sync(ply)
                    TBC_CURRENCY.SyncConfig(ply)
                end
            )
        end
    )

    hook.Add(
        "PlayerDisconnected",
        "TBC_Currency_PlayerLeave",
        function(ply)
            if TBC_CURRENCY._dirty then
                SaveData()
            end
        end
    )

    hook.Add(
        "EntityNetworkedVarChanged",
        "TBC_Currency_CharSwitch",
        function(ent, name, old, new)
            if not IsValid(ent) or not ent:IsPlayer() then
                return
            end
            if name ~= "AssignedCharacter" then
                return
            end
            if not HasCharacterSystem() then
                return
            end
            if new == "" or new == old then
                return
            end
            TBC_CURRENCY.OnCharacterSwitch(ent, new)
        end
    )

    hook.Add(
        "ShutDown",
        "TBC_Currency_Save",
        function()
            SaveData()
        end
    )

    hook.Add(
        "PlayerSay",
        "TBC_Currency_ChatCommands",
        function(ply, text)
            local args = {}
            for word in text:gmatch("%S+") do
                table.insert(args, word)
            end
            local cmd = args[1] and args[1]:lower() or ""

            if cmd == "/checkmoney" then
                local bal = TBC_CURRENCY.GetBalance(ply)
                ply:ChatPrint(string.format("Your %s: %s%d", TBC_CURRENCY.Config.Name, TBC_CURRENCY.Config.Symbol, bal))
                return ""
            end

            if cmd == "/givemoney" then
                if #args < 2 then
                    ply:ChatPrint("Usage: /givemoney <amount>")
                    return ""
                end
                local amount = tonumber(args[2])
                if not amount or amount < TBC_CURRENCY.Config.DropMinAmount then
                    ply:ChatPrint("Invalid amount.")
                    return ""
                end

                local bestTarget = nil
                local bestDot = TBC_CURRENCY.Config.GiveFacingDot
                local eyePos = ply:EyePos()
                local eyeFwd = ply:EyeAngles():Forward()

                for _, p in ipairs(player.GetAll()) do
                    if IsValid(p) and p ~= ply then
                        if ply:GetPos():Distance(p:GetPos()) <= TBC_CURRENCY.Config.GiveRange then
                            local dot = eyeFwd:Dot((p:GetPos() - eyePos):GetNormalized())
                            if dot > bestDot then
                                bestDot = dot
                                bestTarget = p
                            end
                        end
                    end
                end

                if not IsValid(bestTarget) then
                    ply:ChatPrint("No one is close enough and in front of you.")
                    return ""
                end
                if not TBC_CURRENCY.HasMoney(ply, amount) then
                    ply:ChatPrint("You don't have enough " .. TBC_CURRENCY.Config.Name .. ".")
                    return ""
                end

                TBC_CURRENCY.TakeMoney(ply, amount)
                TBC_CURRENCY.GiveMoney(bestTarget, amount)
                local sym = TBC_CURRENCY.Config.Symbol
                local name = TBC_CURRENCY.Config.Name
                ply:ChatPrint(string.format("You handed %s %s%d %s.", bestTarget:Nick(), sym, amount, name))
                bestTarget:ChatPrint(string.format("%s handed you %s%d %s.", ply:Nick(), sym, amount, name))
                return ""
            end

            if cmd == "/dropmoney" then
                if #args < 2 then
                    ply:ChatPrint("Usage: /dropmoney <amount>")
                    return ""
                end
                local amount = tonumber(args[2])
                if not amount or amount < TBC_CURRENCY.Config.DropMinAmount then
                    ply:ChatPrint("Invalid amount.")
                    return ""
                end
                if not TBC_CURRENCY.HasMoney(ply, amount) then
                    ply:ChatPrint("You don't have enough " .. TBC_CURRENCY.Config.Name .. ".")
                    return ""
                end
                TBC_CURRENCY.TakeMoney(ply, amount)
                local dropPos = ply:GetPos() + ply:GetAngles():Forward() * 40 + Vector(0, 0, 5)
                SpawnMoneyPile(dropPos, amount, ply)
                ply:ChatPrint(
                    string.format("You dropped %s%d %s.", TBC_CURRENCY.Config.Symbol, amount, TBC_CURRENCY.Config.Name)
                )
                return ""
            end

            if not ply:IsAdmin() then
                return
            end

            if cmd == "/admingivemoney" then
                if #args < 3 then
                    ply:ChatPrint("Usage: /admingivemoney <player> <amount>")
                    return ""
                end
                local target = nil
                for _, p in ipairs(player.GetAll()) do
                    if string.find(p:Nick():lower(), args[2]:lower(), 1, true) then
                        target = p
                        break
                    end
                end
                local amount = tonumber(args[3])
                if not IsValid(target) then
                    ply:ChatPrint("Player not found.")
                    return ""
                end
                if not amount or amount <= 0 then
                    ply:ChatPrint("Invalid amount.")
                    return ""
                end
                TBC_CURRENCY.GiveMoney(target, amount)
                ply:ChatPrint(
                    string.format(
                        "Gave %s%d %s to %s.",
                        TBC_CURRENCY.Config.Symbol,
                        amount,
                        TBC_CURRENCY.Config.Name,
                        target:Nick()
                    )
                )
                target:ChatPrint(
                    string.format(
                        "An admin gave you %s%d %s.",
                        TBC_CURRENCY.Config.Symbol,
                        amount,
                        TBC_CURRENCY.Config.Name
                    )
                )
                return ""
            end

            if cmd == "/admintakemoney" then
                if #args < 3 then
                    ply:ChatPrint("Usage: /admintakemoney <player> <amount>")
                    return ""
                end
                local target = nil
                for _, p in ipairs(player.GetAll()) do
                    if string.find(p:Nick():lower(), args[2]:lower(), 1, true) then
                        target = p
                        break
                    end
                end
                local amount = tonumber(args[3])
                if not IsValid(target) then
                    ply:ChatPrint("Player not found.")
                    return ""
                end
                if not amount or amount <= 0 then
                    ply:ChatPrint("Invalid amount.")
                    return ""
                end
                local ok = TBC_CURRENCY.TakeMoney(target, amount)
                if ok then
                    ply:ChatPrint(
                        string.format(
                            "Took %s%d %s from %s.",
                            TBC_CURRENCY.Config.Symbol,
                            amount,
                            TBC_CURRENCY.Config.Name,
                            target:Nick()
                        )
                    )
                    target:ChatPrint(
                        string.format(
                            "An admin took %s%d %s from you.",
                            TBC_CURRENCY.Config.Symbol,
                            amount,
                            TBC_CURRENCY.Config.Name
                        )
                    )
                else
                    ply:ChatPrint(target:Nick() .. " doesn't have enough " .. TBC_CURRENCY.Config.Name .. ".")
                end
                return ""
            end

            if cmd == "/adminmoney" then
                if #args < 2 then
                    ply:ChatPrint("Usage: /adminmoney <player>")
                    return ""
                end
                local target = nil
                for _, p in ipairs(player.GetAll()) do
                    if string.find(p:Nick():lower(), args[2]:lower(), 1, true) then
                        target = p
                        break
                    end
                end
                if not IsValid(target) then
                    ply:ChatPrint("Player not found.")
                    return ""
                end
                ply:ChatPrint(
                    string.format(
                        "%s has %s%d %s.",
                        target:Nick(),
                        TBC_CURRENCY.Config.Symbol,
                        TBC_CURRENCY.GetBalance(target),
                        TBC_CURRENCY.Config.Name
                    )
                )
                return ""
            end
        end
    )

    concommand.Add(
        "tbc_currency_give",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 2 then
                print("Usage: tbc_currency_give <name> <amount>")
                return
            end
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.find(p:Nick():lower(), args[1]:lower(), 1, true) then
                    target = p
                    break
                end
            end
            if not IsValid(target) then
                print("Player not found.")
                return
            end
            local amount = tonumber(args[2])
            if not amount or amount <= 0 then
                print("Invalid amount.")
                return
            end
            TBC_CURRENCY.GiveMoney(target, amount)
            print(
                string.format(
                    "Gave %s%d %s to %s.",
                    TBC_CURRENCY.Config.Symbol,
                    amount,
                    TBC_CURRENCY.Config.Name,
                    target:Nick()
                )
            )
        end
    )

    concommand.Add(
        "tbc_currency_take",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 2 then
                print("Usage: tbc_currency_take <name> <amount>")
                return
            end
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.find(p:Nick():lower(), args[1]:lower(), 1, true) then
                    target = p
                    break
                end
            end
            if not IsValid(target) then
                print("Player not found.")
                return
            end
            local amount = tonumber(args[2])
            if not amount or amount <= 0 then
                print("Invalid amount.")
                return
            end
            if TBC_CURRENCY.TakeMoney(target, amount) then
                print("Done.")
            else
                print("Not enough funds.")
            end
        end
    )

    concommand.Add(
        "tbc_currency_set",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 2 then
                print("Usage: tbc_currency_set <name> <amount>")
                return
            end
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.find(p:Nick():lower(), args[1]:lower(), 1, true) then
                    target = p
                    break
                end
            end
            if not IsValid(target) then
                print("Player not found.")
                return
            end
            local amount = tonumber(args[2])
            if not amount or amount < 0 then
                print("Invalid amount.")
                return
            end
            TBC_CURRENCY.SetBalance(target, amount)
            print("Balance set.")
        end
    )

    concommand.Add(
        "tbc_currency_check",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 1 then
                print("Usage: tbc_currency_check <name>")
                return
            end
            local target = nil
            for _, p in ipairs(player.GetAll()) do
                if string.find(p:Nick():lower(), args[1]:lower(), 1, true) then
                    target = p
                    break
                end
            end
            if not IsValid(target) then
                print("Player not found.")
                return
            end
            print(
                string.format(
                    "%s has %s%d %s.",
                    target:Nick(),
                    TBC_CURRENCY.Config.Symbol,
                    TBC_CURRENCY.GetBalance(target),
                    TBC_CURRENCY.Config.Name
                )
            )
        end
    )

    concommand.Add(
        "tbc_currency_shared",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 1 then
                print("Usage: tbc_currency_shared <0|1>")
                return
            end
            local val = tonumber(args[1])
            if val == nil then
                print("Use 0 or 1.")
                return
            end
            TBC_CURRENCY.OnFlagChanged(val == 1)
            print("[TBC Currency] Shared mode: " .. tostring(val == 1))
        end
    )

    concommand.Add(
        "tbc_currency_save",
        function(caller)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            SaveData()
            print("[TBC Currency] Saved.")
        end
    )

    local function SalaryTimerKey(ply)
        return "TBC_Salary_" .. ply:SteamID()
    end

    local function StopSalaryTimer(ply)
        local key = SalaryTimerKey(ply)
        if timer.Exists(key) then
            timer.Remove(key)
        end
    end

    local function ResolveSalary(ply)
        local cfg = TBC_CURRENCY.Config.Salary
        if cfg.GlobalEnabled then
            local amount = cfg.GlobalAmount or 0
            if amount <= 0 then
                return nil, nil
            end
            return amount, cfg.GlobalInterval or 600
        end
        if not HasCharacterSystem() then
            return nil, nil
        end
        local charID = GetCharID(ply)
        if charID == "" then
            return nil, nil
        end
        local charData = CHARACTERS.List[charID]
        if not charData then
            return nil, nil
        end
        local amount = charData.salary or 0
        if amount <= 0 then
            return nil, nil
        end
        local interval = charData.interval or cfg.GlobalInterval or 600
        return amount, interval
    end

    StartSalaryTimer = function(ply)
        if not IsValid(ply) then
            return
        end
        StopSalaryTimer(ply)
        local amount, interval = ResolveSalary(ply)
        if not amount then
            return
        end
        local sym = TBC_CURRENCY.Config.Symbol
        local name = TBC_CURRENCY.Config.Name
        timer.Create(
            SalaryTimerKey(ply),
            interval,
            0,
            function()
                if not IsValid(ply) then
                    StopSalaryTimer(ply)
                    return
                end
                local curAmount, _ = ResolveSalary(ply)
                if not curAmount then
                    StopSalaryTimer(ply)
                    return
                end
                TBC_CURRENCY.GiveMoney(ply, curAmount)
                ply:ChatPrint(string.format("You received your salary: %s%d %s.", sym, curAmount, name))
            end
        )
    end

    hook.Add(
        "PlayerInitialSpawn",
        "TBC_Salary_OnJoin",
        function(ply)
            timer.Simple(
                2,
                function()
                    if IsValid(ply) then
                        StartSalaryTimer(ply)
                    end
                end
            )
        end
    )

    hook.Add(
        "PlayerSpawn",
        "TBC_Salary_CharSwitch",
        function(ply)
            timer.Simple(
                0.1,
                function()
                    if IsValid(ply) then
                        StartSalaryTimer(ply)
                    end
                end
            )
        end
    )

    hook.Add(
        "PlayerDisconnected",
        "TBC_Salary_Cleanup",
        function(ply)
            StopSalaryTimer(ply)
        end
    )

    function TBC_CURRENCY.Salary_RefreshAll()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) then
                StartSalaryTimer(ply)
            end
        end
    end

    concommand.Add(
        "tbc_salary_global",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 1 then
                print("Usage: tbc_salary_global <0|1>")
                return
            end
            local val = tonumber(args[1])
            if val == nil then
                print("Use 0 or 1.")
                return
            end
            TBC_CURRENCY.Config.Salary.GlobalEnabled = val == 1
            TBC_CURRENCY.Salary_RefreshAll()
            print("[TBC Salary] Global mode: " .. tostring(val == 1))
        end
    )

    concommand.Add(
        "tbc_salary_set",
        function(caller, _, args)
            if IsValid(caller) and not caller:IsSuperAdmin() then
                caller:ChatPrint("No permission.")
                return
            end
            if #args < 2 then
                print("Usage: tbc_salary_set <amount> <interval_seconds>")
                return
            end
            local amount = tonumber(args[1])
            local interval = tonumber(args[2])
            if not amount or not interval then
                print("Invalid values.")
                return
            end
            TBC_CURRENCY.Config.Salary.GlobalAmount = amount
            TBC_CURRENCY.Config.Salary.GlobalInterval = interval
            TBC_CURRENCY.Salary_RefreshAll()
            print(string.format("[TBC Salary] Global salary: %d every %ds.", amount, interval))
        end
    )
end -- SERVER

if CLIENT then
    TBC_CURRENCY.LocalBalance = 0
    TBC_CURRENCY.LocalConfig = {Name = "Macca", Symbol = "ћ", Icon = ""}

    net.Receive(
        "TBC_CurrencySync",
        function()
            TBC_CURRENCY.LocalBalance = net.ReadInt(32)
            hook.Run("TBC_CurrencyBalanceUpdated", TBC_CURRENCY.LocalBalance)
        end
    )

    net.Receive(
        "TBC_CurrencyConfig",
        function()
            TBC_CURRENCY.LocalConfig.Name = net.ReadString()
            TBC_CURRENCY.LocalConfig.Symbol = net.ReadString()
            TBC_CURRENCY.LocalConfig.Icon = net.ReadString()
        end
    )

    function TBC_CURRENCY.FormatBalance(amount)
        amount = amount or TBC_CURRENCY.LocalBalance
        local s = tostring(math.floor(amount))
        local result = s:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
        return TBC_CURRENCY.LocalConfig.Symbol .. result
    end
end
