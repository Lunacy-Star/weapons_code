--[[---------------------------------------------------------------------------
DarkRP custom jobs
---------------------------------------------------------------------------
This file contains your custom jobs.
This file should also contain jobs from DarkRP that you edited.

Note: If you want to edit a default DarkRP job, first disable it in darkrp_config/disabled_defaults.lua
      Once you've done that, copy and paste the job to this file and edit it.

The default jobs can be found here:
https://github.com/FPtje/DarkRP/blob/master/gamemode/config/jobrelated.lua

For examples and explanation please visit this wiki page:
https://darkrp.miraheze.org/wiki/DarkRP:CustomJobFields

Add your custom jobs under the following line:
---------------------------------------------------------------------------]] 
TEAM_DUMMY =
    DarkRP.createJob("dummy", {
        color = Color(20, 150, 20, 255),
        model = {
            "models/blacksurvival_nk/jenny/jenny_bs.mdl",
            "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
            "models/blacksurvival_nk/cathy/cathy_bs.mdl"
        },
        description = [[The lad]],
        weapons = {
            "smti_engageswep", "smti_unarmedfists", "smti_1hsword1",
            "smti_rakukaja", "smti_tarukaja", "smti_tarunda", "smti_rakunda",
            "smti_sukunda", "smti_sukukaja", "smti_agi", "smti_gabishi"
        },
        essence = 20,
        command = "dummy",
        category = "Students",
        max = 25,
        turns = 1,
        salary = 0,
        admin = 0,
        vote = false,
        hasLicense = false,

        combatHP = 300,
        combatMP = 200,
        Luck = 10,
        Technique = 60,
        resist = {},
        weak = {"Ice"},
        block = {},
        drain = {"Lightning"},
        repel = {"Fire"},

        PlayerSpawn = function(ply)
            ply:SetHealth(300)
            ply:SetMaxHealth(300)
            ply:SetArmor(0)
            ply:SetMaxArmor(0)

            local job = ply:getJobTable() -- Get the job table for the player's current job 
            ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
            ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
            ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
            ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
            ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
            ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
            ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
            ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

            local resistJSON = util.TableToJSON(job.resist)
            ply:SetNW2String("resist", resistJSON)
            local weakJSON = util.TableToJSON(job.weak)
            ply:SetNW2String("weak", weakJSON)
            local blockJSON = util.TableToJSON(job.block)
            ply:SetNW2String("block", blockJSON)
            local drainJSON = util.TableToJSON(job.drain)
            ply:SetNW2String("drain", drainJSON)
            local repelJSON = util.TableToJSON(job.repel)
            ply:SetNW2String("repel", repelJSON)

            ply:SetNW2String("selectedPersona", "")

            RemoveAllStats(ply, "buffs")
            RemoveAllStats(ply, "debuffs")
            RemoveAllStats(ply, "permabuffs")
            RemoveAllStats(ply, "permadebuffs")
            RemoveAllStats(ply, "personas")

            if job.permaBuffs then
                for status, properties in pairs(job.permaBuffs) do
                    AssignStat(ply, status, properties, "permabuffs")
                end
            end

            if job.permaDebuffs then
                for status, properties in pairs(job.permaDebuffs) do
                    AssignStat(ply, status, properties, "permadebuffs")
                end
            end
        end
    })

TEAM_AMELIA_WATSON = DarkRP.createJob("Watson Amelia", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/amelia_watson/hololive/rstar/amelia_watson/amelia_watson.mdl"
    },
    description = [[Watson Amelia (ワトソン・アメリア) is a female English-speaking Virtual YouTuber associated with hololive, debuting in 2020 as part of hololive English first generation "-Myth-" alongside Ninomae Ina'nis, Takanashi Kiara, Mori Calliope and Gawr Gura.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "ame_timeskip", "ame_concoction"
    },
    essence = 20,
    command = "ame",
    type = "Boss",
    category = "Unknown (HIGHLY DANGEROUS)",
    max = 1,
    turns = 2,
    salary = 150,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 250,
    combatMP = 250,
    Luck = 6,
    Technique = 60,
    resist = {"Nuke"},
    weak = {"Gun"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

TEAM_ASHLEY_WILLIAMS = DarkRP.createJob("Ashley Williams", {
    color = Color(20, 150, 20, 255),
    model = {"models/splinks/ash_williams/ash.mdl"},
    description = [[A Devil Summo- wtf]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "ash_mygun"},
    command = "ashley_williams",
    type = "Boss",
    category = "Unknown (HIGHLY DANGEROUS)",
    max = 1,
    turns = 2,
    salary = 150,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 500,
    combatMP = 0,
    Luck = 6,
    Technique = 60,
    resist = {"Dark"},
    weak = {"Light"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(500)
        ply:SetMaxHealth(500)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

TEAM_SKELETOR = DarkRP.createJob("Skeletor", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/jqueary/callofduty/warzone2/ops/halloween/skeletor_sk_iw9_1_1_gmod.mdl",
        "models/masters_of_the_universe_vr/skeletor.mdl"
    },
    description = [[I'm going to answer the call of duty to end your life he-man -skeletor]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "skeletor_parabellum"},
    command = "skeletor",
    type = "Boss",
    category = "Unknown (HIGHLY DANGEROUS)",
    max = 1,
    turns = 2,
    salary = 150,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 500,
    combatMP = 0,
    Luck = 66,
    Technique = 66,
    resist = {"Evil"},
    weak = {"He-Man"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(500)
        ply:SetMaxHealth(500)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- STUDENT CHARACTERS

-- Gekkoukan High School Student A
TEAM_STUDENT_A = DarkRP.createJob("Gekkoukan High School Student A", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student who attends Gekkoukan High School. They innately share the potential to awakening Personas. These students have more affinity with magic.]],
    weapons = {"smti_engageswep", "smti_unarmedfists"},
    loadoutItems = {"persona_jackfrost", "persona_pixie"},
    essence = 1,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "students_a",
    type = "Human",
    race = "student",
    category = "Students",
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 200,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Gekkoukan High School Student B
TEAM_STUDENT_B = DarkRP.createJob("Gekkoukan High School Student B", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student who attends Gekkoukan High School. They innately share the potential to awakening Personas. These students have more affinity with physicality.]],
    weapons = {"smti_engageswep", "smti_unarmedfists"},
    loadoutItems = {"persona_jackfrost", "persona_pixie"},
    essence = 1,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "students_b",
    type = "Human",
    race = "student",
    category = "Students",
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 400,
    combatMP = 100,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- RESIDENT CHARACTERS 

-- Citizen
TEAM_CITIZEN = DarkRP.createJob("Citizen", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[An adult who lives in or is visiting Tatsumi Port Island. They innately share the potential to awakening Personas.]],
    weapons = {"smti_engageswep", "smti_unarmedfists"},
    loadoutItems = {"persona_jackfrost", "persona_pixie"},
    essence = 1,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "citizen",
    type = "Human",
    race = "citizen",
    category = "Residents",
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 200,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Citizen B
TEAM_CITIZEN_B = DarkRP.createJob("Citizen B", {
    color = Color(20, 150, 20, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student who attends Gekkoukan High School. They innately share the potential to awakening Personas. These students have more affinity with physicality.]],
    weapons = {"smti_engageswep", "smti_unarmedfists"},
    loadoutItems = {"persona_jackfrost", "persona_pixie"},
    essence = 1,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "citizen_b",
    type = "Human",
    race = "citizen",
    category = "Residents",
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 400,
    combatMP = 100,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Police Officer
-- TODO: SWITCH DESCRIPTION IF LORE CHANGES.
TEAM_POLICE_OFFICER = DarkRP.createJob("Police Officer", {
    color = Color(20, 150, 20, 255),
    model = {"models/blacksurvival_nk/jenny/jenny_bs.mdl"},
    description = [[An officer serving duty at Tatsumi Port Island. They are responsible for peacekeeping and looking out for any trouble, particularly those caused by unruly folks or demons that sneak into the mainland.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_ebonytonfa",
        "smti_nambutype100"
    },
    equipmentSlots = 15,
    itemSlots = 10,
    command = "police_officer",
    type = "Police",
    race = "citizen",
    category = "Residents",
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 64,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- DSR PMC
TEAM_DSR_PMC = DarkRP.createJob("D.S.R PMC", {
    color = Color(20, 150, 20, 255),
    model = {"models/blacksurvival_nk/jenny/jenny_bs.mdl"},
    description = [[A PMC contractor hired into the Demon Summoning Response unit funded by the government in response to the "rare sightings" of demon outbreaks. They specialize specifically in heavy firepower that cannot be found commonly, but cannot operate outside of the city effectively until further notice. Cannot acquire Personas or skill cards. Can infinitely restock grenades in police station.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_cm16", "smti_sras",
        "smti_rambus92fs", "smti_tabar", "smti_grenade", "smti_dsrrifle",
        "smti_prisonerdiamondformation"
    },
    equipmentSlots = 15,
    itemSlots = 10,
    command = "dsr_pmc",
    type = "Police",
    race = "citizen",
    category = "Residents",
    canUsePersonas = 0,
    canGetSkills = 0,
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 400,
    combatMP = 10,
    Luck = 10,
    Technique = 65,
    resist = {"Physical"},
    weak = {"Dark", "Ruin"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- VISITOR CHARACTERS

-- Demi-Fiend
TEAM_DEMI_FIEND = DarkRP.createJob("Demi-Fiend", {
    color = Color(0, 107, 0, 255),
    model = {"models/pacagma/smt_n/hitoshura/hitoshura_player.mdl"},
    description = [[A high school student cursed with the body of a demon holding a human heart. The Demi-fiend is one born with odds built against him, but his potential even more terrifying than said odds.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_lunge_demi",
        "smti_javelinrain", "smti_magmaaxis"
    },
    command = "demi_fiend",
    type = "Human",
    race = "student",
    category = "Visitors",
    canUsePersonas = 0,
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    noPersonas = true,

    combatHP = 400,
    combatMP = 140,
    Luck = 6,
    Technique = 50,
    resist = {"Dark"},
    weak = {"Ruin"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end

    end
})

-- Shin Megami Tensei V CHARACTERS

-- Nahobino
TEAM_NAHOBINO = DarkRP.createJob("Nahobino", {
    color = Color(205, 199, 103, 255),
    model = {"models/pacagma/smt_n/hitoshura/hitoshura_player.mdl"},
    description = [[A high school student from Jouin High School. When fused with the Proto-fiend, Aogami, he becomes a Nahobino. ]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_protosword",
        "smti_miraclewater", "smti_omagatokicritical", "smti_thalassiccalamity"
    },
    command = "nahobino",
    type = "Human",
    race = "student",
    category = "Shin Megami Tensei V",
    canUsePersonas = 0,
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    noPersonas = true,

    combatHP = 365,
    combatMP = 150,
    Luck = 10,
    Technique = 58,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end

    end
})

-- Shin Megami Tensei: Persona 2 CHARACTERS

-- Tatsuya Suou
TEAM_TATSUYA_SUOU = DarkRP.createJob("Tatsuya Suou", {
    color = Color(139, 0, 139, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl"
    },
    description = [[He's a senior student enrolling in Seven Sisters High School in Sumaru City. He has an older brother named Katsuya Suou, a police detective. Tatsuya also has an unnamed father.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_novakaiser",
        "smti_twohandedsword"
    },
    command = "tatsuya_suou",
    type = "Human",
    race = "persona_user",
    category = "Persona 2",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Ice"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Lisa Silverman
TEAM_LISA_SILVERMAN = DarkRP.createJob("Lisa Silverman", {
    color = Color(139, 0, 139, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl"
    },
    description = [[A student at Seven Sisters High School, temporarily enrolled in Gekkoukan High School. She is greatly interested in martial arts with natural charisma to back her up.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_kozanofthenorth",
        "smti_foamylover"
    },
    command = "lisa_silverman",
    type = "Human",
    race = "persona_user",
    category = "Persona 2",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {"Light"},
    weak = {"Dark"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Eikichi Mishina
TEAM_EIKICHI_MISHINA = DarkRP.createJob("Eikichi Mishina", {
    color = Color(139, 0, 139, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl"
    },
    description = [[KAZUYA MISHIMA is a student at Kasugayama High School, temporarily enrolled in Gekkoukan High School. She is greatly interested in martial arts with natural charisma to back her up.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_cm16",
        "smti_bloodyhoneymoon"
    },
    command = "eikichi_mishina",
    type = "Human",
    race = "persona_user",
    category = "Persona 2",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 320,
    combatMP = 180,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(320)
        ply:SetMaxHealth(320)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Maya Amano
TEAM_MAYA_AMANO = DarkRP.createJob("Maya Amano", {
    color = Color(139, 0, 139, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl"
    },
    description = [[Maya is a young woman in her early twenties with light skin, shoulder-length black hair styled in a flip, and purple eyes.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_absolutezero"},
    command = "maya_amano",
    type = "Human",
    race = "persona_user",
    category = "Persona 2",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 200,
    Luck = 15,
    Technique = 55,
    resist = {"Magic"},
    weak = {"Physical"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Jun Kurosu
TEAM_JUN_KUROSU = DarkRP.createJob("Jun Kurosu", {
    color = Color(139, 0, 139, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl"
    },
    description = [[As a student of Kasugayama High School, Jun is usually seen wearing the school's light blue gakuran-style uniform with black loafers. He wears the silver wristwatch he received from Tatsuya on his left, and a yellow iris in the buttonhole of his jacket.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_crossfortune"},
    command = "jun_kurosu",
    type = "Human",
    race = "persona_user",
    category = "Persona 2",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 15,
    Technique = 55,
    resist = {},
    weak = {"Nuke"},
    block = {"Wind"},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- PERSONA 1 CHARACTERS

-- Makoto Yuki
TEAM_MAKOTO_YUKI = DarkRP.createJob("Makoto Yuki", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/smt_nk/smtif/smtif_erbsf.mdl",
        "models/smt_nk/smtif/smtif_erbsm.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl",
        "models/pacagma/smt_n/hitoshura/hitoshura_player.mdl"
    },
    description = [[A transfer student enrolling in Gekkoukan High School in Iwatodai City. An active member of SEES.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_cadenza",
        "smti_twohandedsword"
    },
    command = "makoto_yuki",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Kotone Shiomi
TEAM_KOTONE_SIOMI = DarkRP.createJob("Kotone Shiomi", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/smt_nk/smtif/smtif_erbsf.mdl",
        "models/smt_nk/smtif/smtif_erbsm.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl",
        "models/pacagma/smt_n/hitoshura/hitoshura_player.mdl"
    },
    description = [[A transfer student enrolling in Gekkoukan High School in Iwatodai City. An active member of SEES. (Alternate Name: Minako Arisato)]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_healingharp",
        "smti_lanceofvitality"
    },
    command = "kotone_shiomi",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Junpei Iori
TEAM_JUNPEI_IORI = DarkRP.createJob("Junpei Iori", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/smt_nk/smtif/smtif_erbsf.mdl",
        "models/smt_nk/smtif/smtif_erbsm.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl",
        "models/pacagma/smt_n/hitoshura/hitoshura_player.mdl"
    },
    description = [[A student enrolling in Gekkoukan High School in Iwatodai City with a fondness for baseball. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_damascussword"},
    permaBuffs = {
        ["Triangle_Drill"] = {
            stacks = 1,
            type = "kill",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_triangledrill"
        }
    },
    command = "junpei_iori",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 375,
    combatMP = 125,
    Luck = 7,
    Technique = 56,
    resist = {},
    weak = {"Wind"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(375)
        ply:SetMaxHealth(375)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Yukari Takeba
TEAM_YUKARI_TAKEBA = DarkRP.createJob("Yukari Takeba", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolling in Gekkoukan High School in Iwatodai City with a fondness for archery and acting. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_hankyu"},
    permaBuffs = {
        ["Anchor_Point"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_anchorpoint"
        }
    },
    command = "yukari_takeba",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 325,
    combatMP = 175,
    Luck = 8,
    Technique = 64,
    resist = {},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(325)
        ply:SetMaxHealth(325)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Mitsuru Kirijo
TEAM_MITSURU_KIRIJO = DarkRP.createJob("Mitsuru Kirijo", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/player/dewobedil/kancolle/murasame/default_p.mdl",
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/smt_nk/smtif/smtif_erbsf.mdl",
        "models/smt_nk/smtif/smtif_erbsm.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl",
        "models/pacagma/smt_n/hitoshura/hitoshura_player.mdl"
    },
    description = [[Gekkoukan High School's valedictorian and student council president, as well as a member of the school fencing club. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_schiavona"},
    permaBuffs = {
        ["Third_Intention"] = {
            stacks = 1,
            type = "kill",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_thirdintention"
        }
    },
    command = "mitsuru_kirijo",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 330,
    combatMP = 170,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(330)
        ply:SetMaxHealth(330)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Akihiko Sanada
TEAM_AKIHIKO_SANADA = DarkRP.createJob("Akihiko Sanada", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolling in Gekkoukan High School in Iwatodai City. He is the captain of the boxing team. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_kozanofthesouth"},
    permaBuffs = {
        ["Eight_Count"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_eightcount"
        }
    },
    command = "akihiko_sanada",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 360,
    combatMP = 140,
    Luck = 9,
    Technique = 62,
    resist = {},
    weak = {"Ice"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(360)
        ply:SetMaxHealth(360)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Fuuka Yamagishi
TEAM_FUUKA_YAMAGISHI = DarkRP.createJob("Fuuka Yamagishi", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolling in Gekkoukan High School in Iwatodai City with a fondness for computers and technology. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_papillondiabolos"},
    permaBuffs = {
        ["Healing_Wave"] = {
            stacks = 1,
            type = "victory",
            targets = "party",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_healingwave"
        }
    },
    command = "fuuka_yamagishi",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 315,
    combatMP = 185,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Dark"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(315)
        ply:SetMaxHealth(315)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Ken Amada
TEAM_KEN_AMADA = DarkRP.createJob("Ken Amada", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolling in Gekkoukan High School in Iwatodai City. He is the captain of the boxing team. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_spear"},
    permaBuffs = {
        ["Premonition"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_premonition"
        }
    },
    command = "ken_amada",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 325,
    combatMP = 170,
    Luck = 8,
    Technique = 55,
    resist = {},
    weak = {"Dark"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(325)
        ply:SetMaxHealth(325)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Koromaru
TEAM_KOROMARU = DarkRP.createJob("Koromaru", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A Shiba Inu in Iwatodai City currently taken in by the SEES with the potential to summon Personas through a special Evoker. An active member of SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_randallknife"},
    permaBuffs = {
        ["Shrine_Guardian"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_shrineguardian"
        }
    },
    command = "koromaru",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 320,
    combatMP = 170,
    Luck = 13,
    Technique = 55,
    resist = {},
    weak = {"Light"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(320)
        ply:SetMaxHealth(320)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Shinjiro Aragaki
TEAM_SHINJIRO_ARAGAKI = DarkRP.createJob("Shinjiro Aragaki", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A senior student enrolling in Gekkoukan High School in Iwatodai City. He is one of the first members of the SEES.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_tabar"},
    permaBuffs = {
        ["Suppressor"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_suppressor"
        }
    },
    command = "shinjiro_aragaki",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 380,
    combatMP = 120,
    Luck = 4,
    Technique = 60,
    resist = {},
    weak = {"Bow"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(380)
        ply:SetMaxHealth(380)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Aigis
TEAM_AIGIS = DarkRP.createJob("Aigis", {
    color = Color(25, 25, 170, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[An Anti-Shadow Suppression Weapon attending Gekkoukan High School. An active member of SEES.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_cm16", "smti_orgiamode"
    },
    permaBuffs = {
        ["Papillon_Heart"] = {
            stacks = 1,
            type = "reactionHeal",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_papillonheart"
        }
    },
    command = "aigis",
    type = "Human",
    race = "sees",
    category = "Persona 3",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {"Bow", "Gun"},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- PERSONA 2 CHARACTERS

-- Yu Narukami
TEAM_YU_NARUKAMI = DarkRP.createJob("Yu Narukami", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A transfer student at Yasogami High School, temporarily enrolled in Gekkoukan High School. An active member of the Investigation Team.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_twohandedsword",
        "smti_lensoftruth"
    },
    command = "yu_narukami",
    type = "Human",
    race = "investigation_team",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 340,
    combatMP = 160,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Wind"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(340)
        ply:SetMaxHealth(340)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Rise Kujikawa
TEAM_RISE_KUJIKAWA = DarkRP.createJob("Rise Kujikawa", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A popular idol who returns to Inaba for a brief hiatus. She is a first-year student at Yasogami High School.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_encore",
        "smti_enkanohanamichi", "smti_elecrush", "smti_twinklestar"
    },
    command = "rise_kujikawa",
    type = "Human",
    race = "student",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 315,
    combatMP = 190,
    Luck = 10,
    Technique = 55,
    resist = {},
    weak = {"Gun", "Physical"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(315)
        ply:SetMaxHealth(315)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Yukiko Amagi
TEAM_YUKIKO_AMAGI = DarkRP.createJob("Yukiko Amagi", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[She is the protagonist's classmate at Yasogami High School, and her family runs Inaba's hot springs inn called the Amagi Inn where she is next in-line as manager.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_ironfanoftheempress",
        "smti_firerush", "smti_phoenixgust"
    },
    permaBuffs = {
        ["Cauterizing_Flames"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_cauterizingflames"
        }
    },
    command = "yukiko_amagi",
    type = "Human",
    race = "student",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 210,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Ice"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Chie Satonaka
TEAM_CHIE_SATONAKA = DarkRP.createJob("Chie Satonaka", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[An energetic girl with a love of kung-fu movies, she's one of the protagonist's classmates at Yasogami High School.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_ebonytonfa",
        "smti_dragonkick", "smti_physrush", "smti_trialofthedragon"
    },
    command = "chie_satonaka",
    type = "Human",
    race = "student",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 400,
    combatMP = 100,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Yosuke Hanamura
TEAM_YOSUKE_HANAMURA = DarkRP.createJob("Yosuke Hanamura", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[He is the protagonist's classmate at Yasogami High School in Inaba and the son of the Junes Department Store's Inaba branch manager.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_forcerush",
        "smti_herofromjunes"
    },
    permaBuffs = {
        ["Sukukaja"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_autosukukaja"
        }
    },
    command = "yosuke_hanamura",
    type = "Human",
    race = "student",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 325,
    combatMP = 150,
    Luck = 10,
    Technique = 65,
    resist = {},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(325)
        ply:SetMaxHealth(325)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Naoto Shirogane
TEAM_NAOTO_SHIROGANE = DarkRP.createJob("Naoto Shirogane", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[The fifth generation of the famed Shirogane detectives, Naoto arrives in Inaba to help investigate the murders, and enrolls as a first-year student at Yasogami High School.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_nambutype100",
        "smti_aimstance", "smti_darkrush", "smti_lockedon"
    },
    command = "naoto_shirogane",
    type = "Human",
    race = "police",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 175,
    Luck = 12,
    Technique = 55,
    resist = {},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Kanji Tatsumi
TEAM_KANJI_TATSUMI = DarkRP.createJob("Kanji Tatsumi", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student at Yasogami High School, temporarily enrolled in Gekkoukan High School. An active member of the Investigation Team.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_nobell",
        "smti_kabutsuchikyoko"
    },
    command = "kanji_tatsumi",
    type = "Human",
    race = "investigation_team",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 380,
    combatMP = 120,
    Luck = 12,
    Technique = 58,
    resist = {},
    weak = {"Wind"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(380)
        ply:SetMaxHealth(380)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Teddie (Kuma)
TEAM_TEDDIE_KUMA = DarkRP.createJob("Teddie (Kuma)", {
    color = Color(255, 229, 44, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A mascot bear with two forms that also seems to be an active member of the Investigation Team.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_kamuimiracle"},
    command = "teddie_kuma",
    type = "Human",
    race = "investigation_team",
    category = "Persona 4",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 310,
    combatMP = 190,
    Luck = 14,
    Technique = 56,
    resist = {"Ice"},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(310)
        ply:SetMaxHealth(310)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- PERSONA 3 Characters

-- Ren Amamiya (Joker)
TEAM_REN_AMAMIYA = DarkRP.createJob("Ren Amamiya (Joker)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A transfer student enrolled in Shujin Academy and temporarily attending Gekkoukan High School in Iwatodai City. An active member of the Phantom Thieves.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_randallknife"},
    permaBuffs = {
        ["Pinch_Anchor"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_pinchanchor"
        }
    },
    command = "ren_amamiya",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Light"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Ryuji Sakamoto
TEAM_RYUJI_SAKAMOTO = DarkRP.createJob("Ryuji Sakamoto", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Harlot]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_ironpipe",
        "smti_physrush", "smti_eccentrictemper"
    },
    permaBuffs = {
        ["Raging_Temper"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_ragingtemper"
        }
    },
    command = "ryuji_sakamoto",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 400,
    combatMP = 100,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Wind"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Ann Takamaki
TEAM_ANNTAKAMAKI = DarkRP.createJob("Ann Takamaki", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Harlot]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_gildedwhip",
        "smti_firerush"
    },
    permaBuffs = {
        ["Mastery_of_Magic"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_masteryofmagic"
        }
    },
    command = "ann_takamaki",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 310,
    combatMP = 190,
    Luck = 15,
    Technique = 55,
    resist = {},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(310)
        ply:SetMaxHealth(310)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Morgana
TEAM_MORGANA = DarkRP.createJob("Morgana", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[He is a mysterious being with ties to Mementos. He doesn't know who he is, and seeks answers to restore his memories.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_forcerush",
        "smti_majesticpresence"
    },
    permaBuffs = {
        ["Proud_Presence"] = {
            stacks = 1,
            targets = "party",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_proudpresence"
        }
    },
    command = "morgana",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 200,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Yusuke Kitagawa
TEAM_YUSUKE_KITAGAWA = DarkRP.createJob("Yusuke Kitagawa", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[it doesn't give me enough for this tbh]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_yanagiba", "smti_icerush",
        "smti_unparalleledeyes"
    },
    permaBuffs = {
        ["Scoundrel_Eyes"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_scoundreleyes"
        }
    },
    command = "yusuke_kitagawa",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 325,
    combatMP = 175,
    Luck = 5,
    Technique = 65,
    resist = {},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(325)
        ply:SetMaxHealth(325)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Makoto Niijima
TEAM_MAKOTO_NIIJIMA = DarkRP.createJob("Makoto Niijima", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[She's the student council president of Shujin Academy who lives a double life as a Phantom Thief.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_nukerush",
        "smti_gaiablessing"
    },
    permaBuffs = {
        ["Gaia_Pact"] = {
            stacks = 1,
            targets = "party",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_gaiapact"
        }
    },
    command = "makoto_niijima",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 400,
    combatMP = 100,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Ruin"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(400)
        ply:SetMaxHealth(400)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
            local buffsTable = job.permaBuffs

            buffsTable["Gaia_Pact"] = {
                stacks = 1,
                targets = "party",
                caster = ply:UserID(),
                SlotsTaking = 1,
                SlotType = "Equipment",
                ClassName = "smti_gaiapact"
            }

            AssignStat(ply, "Gaia_Pact", buffsTable["Gaia_Pact"], "permabuffs")
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Haru Okumura
TEAM_HARU_OKUMURA = DarkRP.createJob("Haru Okumura", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[uh i legit don't have any for this one.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_ruinrush",
        "smti_coolcustomer"
    },
    permaBuffs = {
        ["Icy_Glare"] = {
            stacks = 1,
            targets = "party",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_icyglare"
        }
    },
    command = "haru_okumura",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Nuke"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
            local buffsTable = job.permaBuffs

            buffsTable["Icy_Glare"] = {
                stacks = 1,
                targets = "party",
                caster = ply:UserID(),
                SlotsTaking = 1,
                SlotType = "Equipment",
                ClassName = "smti_icyglare"
            }

            AssignStat(ply, "Icy_Glare", buffsTable["Icy_Glare"], "permabuffs")
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Futaba Sakura
TEAM_FUTABA_SAKURA = DarkRP.createJob("Futaba Sakura", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[uh i legit don't have any for this one.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_grenade"},
    permaBuffs = {
        ["Explosive_Scheme"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_explosivescheme"
        }
    },
    command = "futaba_sakura",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 300,
    Luck = 20,
    Technique = 50,
    resist = {},
    weak = {"Dark"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Sumire Yoshizawa
TEAM_SUMIRE_YOSHIZAWA = DarkRP.createJob("Sumire Yoshizawa", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[She is a first-year transfer student at Shujin Academy and a talented gymnast who gets involved with the Phantom Thieves of Hearts.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_icerush",
        "smti_veilofsunrise"
    },
    permaBuffs = {
        ["Veil_of_Midnight"] = {
            stacks = 1,
            targets = "party",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_veilofmidnight"
        }
    },
    command = "sumire_yoshizawa",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 300,
    combatMP = 200,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Dark"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- PERSONA 3 X Characters

-- Wonder
TEAM_WONDER = DarkRP.createJob("Wonder", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. An active member of the Phantom Thieves.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_whitenight",
        "smti_gunfirerush", "smti_quickfocus"
    },
    permaBuffs = {
        ["Lock_On"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_lockon"
        }
    },
    command = "wonder",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Light"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Arai Motoha (Closer)
TEAM_ARAI_MOTOHA = DarkRP.createJob("Arai Motoha (Closer)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. An active member of the Phantom Thieves. The term "closer" refers to a baseball closing pitcher specializing on the final outs of a game.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_meteorhammer",
        "smti_elecrush", "smti_windup"
    },
    permaBuffs = {
        ["Closing_Pitch"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_closingpitch"
        }
    },
    command = "arai_motoha",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 340,
    combatMP = 160,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(340)
        ply:SetMaxHealth(340)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Kanou Shun (Soy)
TEAM_KANOU_SHUN = DarkRP.createJob("Kanou Shun (Soy)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. An active member of the Phantom Thieves. The term "soy" refers to soy sauce, a sauce favored by many Japanese chefs for robust flavors.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_steelhandaxe",
        "smti_rotarymachinegun", "smti_icerush", "smti_originalrecipe"
    },
    permaBuffs = {
        ["Omakase"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_omakase"
        }
    },
    command = "kanou_shun",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 380,
    combatMP = 120,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Ice"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(380)
        ply:SetMaxHealth(380)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Tomoko Noge (Moko)
TEAM_TOMOKO_NOGE = DarkRP.createJob("Tomoko Noge (Moko)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. A potential Phantom Idol. She has good experience with baseball and work ethic.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_randallknife",
        "smti_hankyu", "smti_purpleleaves", "smti_ruinrush",
        "smti_unwaveringsupport"
    },
    command = "tomoko_noge",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 300,
    combatMP = 200,
    Luck = 15,
    Technique = 55,
    resist = {},
    weak = {"Ruin"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Riko Tanemura (Wind)
TEAM_RIKO_TANEMURA = DarkRP.createJob("Riko Tanemura (Wind)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. An active member of the Phantom Thieves. She is a Discipline Committee member of the academy.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_treasureringparasol",
        "smti_forcerush", "smti_twilightshadow"
    },
    command = "riko_tanemura",
    permaBuffs = {
        ["Bird_Song"] = {
            stacks = 1,
            targets = "party",
            visibility = 0,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_birdsong"
        }
    },
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 300,
    combatMP = 200,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Force"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(300)
        ply:SetMaxHealth(300)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Minami Miyashita (Marian)
TEAM_MINAMI_MIYASHITA = DarkRP.createJob("Minami Miyashita (Marian)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. A potential Phantom Idol. She dreams of becoming a nurse like her late mother one day and is known to help parents take care of their children in busy times.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_rambussvd",
        "smti_combatmedkit", "smti_lightrush", "smti_postoperativecare"
    },
    permaBuffs = {
        ["Benevolence"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_benevolence"
        }
    },
    command = "minami_miyashita",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 350,
    combatMP = 180,
    Luck = 8,
    Technique = 56,
    resist = {},
    weak = {"Light"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Yukimi Fujikawa (Yuki)
TEAM_YUKIMI_FUJIKAWA = DarkRP.createJob("Yukimi Fujikawa (Yuki)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A student enrolled in Kokatsu Academy and temporarily attending Gekkoukan High School in Iwatodai City. A potential Phantom Idol. She seeks to become a lawyer rather than inheriting her mother's business.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_morningstar",
        "smti_dualpistols", "smti_lightrush", "smti_firmwill"
    },
    permaBuffs = {
        ["Devotion_of_Rebuttal"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_devotionofrebuttal"
        }
    },
    command = "yukimi_fujikawa",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 350,
    combatMP = 150,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Light"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(350)
        ply:SetMaxHealth(350)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Chizuko Nagao (Vino)
TEAM_CHIZUKO_NAGAO = DarkRP.createJob("Chizuko Nagao (Vino)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[An elderly lady who likes drinking and can hold her liquor very well. A potential Phantom Idol. She is good at playing saxophone but has dropped it since her husband who was enthusiastic about music had passed away.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_tridagger",
        "smti_sweeper", "smti_nukerush", "smti_roaringengine"
    },
    permaBuffs = {
        ["Second_Serving"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_secondserving"
        }
    },
    command = "chizuko_nagao",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 280,
    combatMP = 220,
    Luck = 7,
    Technique = 65,
    resist = {},
    weak = {"Nuke"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(280)
        ply:SetMaxHealth(220)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Ayaka Sakai (Chord)
TEAM_AYAKA_SAKAI = DarkRP.createJob("Ayaka Sakai (Chord)", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A college student who is also an amateur songwriter and singer. A potential Phantom Idol. She wishes to sing one day alongside her guitar playing skills.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_electricguitarassault",
        "smti_elecrush", "smti_accent"
    },
    permaBuffs = {
        ["Welcome_the_Dawn"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_welcomethedawn"
        }
    },
    command = "ayaka_sakai",
    type = "Human",
    race = "phantom_thieves",
    category = "Persona 5 X",
    equipmentSlots = 15,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,
    combatHP = 270,
    combatMP = 230,
    Luck = 10,
    Technique = 60,
    resist = {},
    weak = {"Elec"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(270)
        ply:SetMaxHealth(230)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- SOUL HACKERS 2 CHARACTERS

-- Ringo
TEAM_RINGO = DarkRP.createJob("Ringo", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[An agent of Aion, a digital hivemind that exists in the sea of humanity's data. Though unfamiliar with human society and culture, she is arguably one of the most adept at handling long-standing conflicts.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_antikythera_ringo",
        "smti_shielddeployment", "smti_mpoptimization"
    },
    permaBuffs = {
        ["Sabbath"] = {
            stacks = 1,
            type = "bonusCritDamage",
            targets = "party",
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_sabbath"
        }
    },
    command = "ringo",
    type = "Human",
    race = "aion",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 325,
    combatMP = 175,
    Luck = 12,
    Technique = 55,
    resist = {"Elec"},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(325)
        ply:SetMaxHealth(325)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Figue
TEAM_FIGUE = DarkRP.createJob("Figue", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[An agent of Aion, a digital hivemind that exists in the sea of humanity's data. Her ability in providing support through reconnaissance and analysis makes her valuable in gathering intel ahead of time.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_antikythera_figue",
        "smti_autorepair", "smti_overclock"
    },
    command = "figue",
    type = "Human",
    race = "aion",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 310,
    combatMP = 190,
    Luck = 16,
    Technique = 50,
    resist = {"Ruin"},
    weak = {},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(310)
        ply:SetMaxHealth(310)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Arrow
TEAM_ARROW = DarkRP.createJob("Arrow", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A Devil Summoner from Yatagarasu. He was given a second chance by Ringo to find his own path to peace while investigating the recent surges in demon activity.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_mk90"},
    permaBuffs = {
        ["Soul_Matrix_Arrow"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_soulmatrixarrow"
        }
    },
    command = "arrow",
    type = "Human",
    race = "devil_summoner",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 340,
    combatMP = 160,
    Luck = 10,
    Technique = 60,
    resist = {"Ice"},
    weak = {"Gun"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(340)
        ply:SetMaxHealth(340)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Milady
TEAM_MILADY = DarkRP.createJob("Milady", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A Devil Summoner from the Phantom Society. A ruthless realist who is temporarily working with Ringo to discover the myriad of truths hidden behind the rapidly increasing demon activities.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_stigma"},
    permaBuffs = {
        ["Soul_Matrix_Milady"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_soulmatrixmilady"
        }
    },
    permaDebuffs = {["Soul_Matrix_Milady"] = {stacks = 1, visibility = 0}},
    command = "milady",
    type = "Human",
    race = "devil_summoner",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 360,
    combatMP = 140,
    Luck = 8,
    Technique = 62,
    resist = {"Fire"},
    weak = {"Martial Arts"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(330)
        ply:SetMaxHealth(330)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Saizo
TEAM_SAIZO = DarkRP.createJob("Saizo", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A freelancer Devil Summoner. Though quick-witted and clever, he can be impulsive with purchases. He is often assisting Ringo during his off-time.]],
    weapons = {"smti_engageswep", "smti_unarmedfists", "smti_tommygun"},
    permaBuffs = {
        ["Soul_Matrix_Saizo"] = {
            stacks = 1,
            SlotsTaking = 1,
            SlotType = "Equipment",
            ClassName = "smti_soulmatrixsaizo"
        }
    },
    command = "saizo",
    type = "Human",
    race = "devil_summoner",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 330,
    combatMP = 170,
    Luck = 13,
    Technique = 57,
    resist = {"Force"},
    weak = {"Blade"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(330)
        ply:SetMaxHealth(330)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Ash
TEAM_ASH = DarkRP.createJob("Ash", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A Devil Summoner from the Phantom Society. Though she could come off as dry, she has a caring, yet paranoid side to her.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_blackout",
        "smti_ashestoashes"
    },
    command = "ash",
    type = "Human",
    race = "devil_summoner",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 330,
    combatMP = 170,
    Luck = 13,
    Technique = 57,
    resist = {"Ruin"},
    weak = {"Force"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(330)
        ply:SetMaxHealth(330)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Nana
TEAM_NANA = DarkRP.createJob("Nana", {
    color = Color(203, 225, 49, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[A Devil Summoner with a rather ravenous appetite for food. Despite her laidback attitude, her prowess in battle is notably potent.]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_grenadehammer",
        "smti_nerfinator"
    },
    command = "nana",
    type = "Human",
    race = "devil_summoner",
    category = "Soul Hackers 2",
    equipmentSlots = 14,
    itemSlots = 10,
    max = 1,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 325,
    combatMP = 175,
    Luck = 10,
    Technique = 60,
    resist = {"Force"},
    weak = {"Ruin"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(325)
        ply:SetMaxHealth(325)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- DEMONS/SHADOWS CHARACTERS

-- Jack Frost
TEAM_JACK_FROST_A = DarkRP.createJob("Jack Frost", {
    name = "Jack Frost", -- Display name
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Variant A.]] .. "\n\n" ..
        [[An elf-like creature who is the embodiment of all that is cold. It is said that he is the one who leaves those beautiful icy patterns on windows in the morning.]] ..
        "\n\n" .. [[HP: 190]] .. "\n\n" .. [[MP: 170]] .. "\n\n" ..
        [[Technique: 60]] .. "\n\n" .. [[Luck: 10]] .. "\n\n" .. [[Weak: Fire]] ..
        "\n\n" .. [[Resist: Ice]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_jackbufula",
        "smti_icerush", "smti_physrush"
    },
    loadoutItems = {
        "Tarukaja_Universal", "Rakukaja_Universal", "Sukukaja_Universal",
        "Tarunda_Universal", "Rakunda_Universal", "Sukunda_Universal",
        "Dekaja_Universal", "Dekunda_Universal", "Posumudi_Universal",
        "Patra_Universal", "AmritaDrop_Universal", "LifeBonus_Universal",
        "LastResort_Standard", "Sacrifice_Standard", "Bufu_Standard",
        "Mabufu_Standard", "Hama_Standard", "Mahama_Standard", "Dia_Standard",
        "IceBoost_Standard"
    },
    essence = 200,
    kilodevil = 100,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "jackfrostA",
    type = "Demon",
    race = "fairy",
    category = "Demons",
    cantSeeMembers = true,
    max = 0,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 190,
    combatMP = 170,
    Luck = 10,
    Technique = 60,
    resist = {"Ice"},
    weak = {"Fire"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(190)
        ply:SetMaxHealth(190)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

TEAM_JACK_FROST_B = DarkRP.createJob("Jack Frost", {
    name = "Jack Frost", -- Display name
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Variant B.]] .. "\n\n" ..
        [[An elf-like creature who is the embodiment of all that is cold. It is said that he is the one who leaves those beautiful icy patterns on windows in the morning.]] ..
        "\n\n" .. [[HP: 175]] .. "\n\n" .. [[MP: 175]] .. "\n\n" ..
        [[Technique: 62]] .. "\n\n" .. [[Luck: 13]] .. "\n\n" .. [[Weak: Dark]] ..
        "\n\n" .. [[Resist: Light]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_jackbufula",
        "smti_icerush", "smti_physrush"
    },
    loadoutItems = {
        "Tarukaja_Universal", "Rakukaja_Universal", "Sukukaja_Universal",
        "Tarunda_Universal", "Rakunda_Universal", "Sukunda_Universal",
        "Dekaja_Universal", "Dekunda_Universal", "Posumudi_Universal",
        "Patra_Universal", "AmritaDrop_Universal", "LifeBonus_Universal",
        "LastResort_Standard", "Sacrifice_Standard", "Bufu_Standard",
        "Mabufu_Standard", "Hama_Standard", "Mahama_Standard", "Dia_Standard",
        "IceBoost_Standard"
    },
    essence = 200,
    kilodevil = 100,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "jackfrostB",
    type = "Demon",
    race = "fairy",
    category = "Demons",
    cantSeeMembers = true,
    max = 0,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 175,
    combatMP = 175,
    Luck = 13,
    Technique = 62,
    resist = {"Light"},
    weak = {"Dark"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(190)
        ply:SetMaxHealth(190)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Pixie
TEAM_PIXIE_A = DarkRP.createJob("Pixie", {
    name = "Pixie", -- Display name
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Variant A.]] .. "\n\n" ..
        [[A small fairy found in southwestern Britain known for their cheerful nature and love of pranks. Their physical appearance changes from region to region, but their personality is always playful and mischievous. A common prank they like to pull is causing humans to wander in circles. However, they are also known to help farmers from time to time and are generally considered good fairies.]] ..
        "\n\n" .. [[HP: 200]] .. "\n\n" .. [[MP: 160]] .. "\n\n" ..
        [[Technique: 60]] .. "\n\n" .. [[Luck: 10]] .. "\n\n" ..
        [[Weak: Elec, Nuke]] .. "\n\n" .. [[Resist: Wind, Ruin]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_fortunekiss",
        "smti_elecrush", "smti_ruinrush"
    },
    loadoutItems = {
        "Tarukaja_Universal", "Rakukaja_Universal", "Sukukaja_Universal",
        "Tarunda_Universal", "Rakunda_Universal", "Sukunda_Universal",
        "Dekaja_Universal", "Dekunda_Universal", "Posumudi_Universal",
        "Patra_Universal", "AmritaDrop_Universal", "LifeBonus_Universal",
        "LastResort_Standard", "Sacrifice_Standard", "Agi_Standard",
        "Bufu_Standard", "Zio_Standard", "Mazio_Standard", "Zan_Standard",
        "Mazan_Standard", "MarinKarin_Standard", "MePatra_Standard",
        "Dia_Standard", "Media_Standard"
    },
    essence = 200,
    kilodevil = 100,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "pixieA",
    type = "Demon",
    race = "fairy",
    category = "Demons",
    cantSeeMembers = true,
    max = 0,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 200,
    combatMP = 160,
    Luck = 10,
    Technique = 60,
    resist = {"Wind", "Ruin"},
    weak = {"Elec", "Nuke"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(200)
        ply:SetMaxHealth(200)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

TEAM_PIXIE_B = DarkRP.createJob("Pixie", {
    name = "Pixie", -- Display name
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Variant B.]] .. "\n\n" ..
        [[A small fairy found in southwestern Britain known for their cheerful nature and love of pranks. Their physical appearance changes from region to region, but their personality is always playful and mischievous. A common prank they like to pull is causing humans to wander in circles. However, they are also known to help farmers from time to time and are generally considered good fairies.]] ..
        "\n\n" .. [[HP: 180]] .. "\n\n" .. [[MP: 180]] .. "\n\n" ..
        [[Technique: 62]] .. "\n\n" .. [[Luck: 12]] .. "\n\n" ..
        [[Weak: Gun, Ruin]] .. "\n\n" .. [[Resist: Fire, Elec]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_fortunekiss",
        "smti_elecrush", "smti_ruinrush"
    },
    loadoutItems = {
        "Tarukaja_Universal", "Rakukaja_Universal", "Sukukaja_Universal",
        "Tarunda_Universal", "Rakunda_Universal", "Sukunda_Universal",
        "Dekaja_Universal", "Dekunda_Universal", "Posumudi_Universal",
        "Patra_Universal", "AmritaDrop_Universal", "LifeBonus_Universal",
        "LastResort_Standard", "Sacrifice_Standard", "Agi_Standard",
        "Bufu_Standard", "Zio_Standard", "Mazio_Standard", "Zan_Standard",
        "Mazan_Standard", "MarinKarin_Standard", "MePatra_Standard",
        "Dia_Standard", "Media_Standard"
    },
    essence = 200,
    kilodevil = 100,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "pixieB",
    type = "Demon",
    race = "fairy",
    category = "Demons",
    cantSeeMembers = true,
    max = 0,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 180,
    combatMP = 180,
    Luck = 12,
    Technique = 62,
    resist = {"Fire", "Elec"},
    weak = {"Gun", "Ruin"},
    block = {},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(180)
        ply:SetMaxHealth(180)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

-- Inugami
TEAM_INUGAMI_A = DarkRP.createJob("Inugami", {
    color = Color(153, 0, 0, 255),
    model = {
        "models/blacksurvival_nk/jenny/jenny_bs.mdl",
        "models/blacksurvival_nk/jenny/jennyskin_bs.mdl",
        "models/blacksurvival_nk/cathy/cathy_bs.mdl"
    },
    description = [[Variant A.]] .. "\n\n" ..
        [[A dog spirit said to possess people in Japanese lore. Those possessed are in a state of "inu-tsuki" and lose consciousness. Onmyoji use Inugami as familiars.]] ..
        "\n\n" .. [[HP: 250]] .. "\n\n" .. [[MP: 110]] .. "\n\n" ..
        [[Technique: 60]] .. "\n\n" .. [[Luck: 10]] .. "\n\n" ..
        [[Weak: Force, Light]] .. "\n\n" .. [[Resist: Gun]] .. "\n\n" ..
        [[Block: Fire]],
    weapons = {
        "smti_engageswep", "smti_unarmedfists", "smti_firerush", "smti_physrush"
    },
    loadoutItems = {
        "Tarukaja_Universal", "Rakukaja_Universal", "Sukukaja_Universal",
        "Tarunda_Universal", "Rakunda_Universal", "Sukunda_Universal",
        "Dekaja_Universal", "Dekunda_Universal", "Posumudi_Universal",
        "Patra_Universal", "AmritaDrop_Universal", "LifeBonus_Universal",
        "LastResort_Standard", "Sacrifice_Standard", "Agi_Standard",
        "Maragi_Standard", "FireBreath_Standard", "Zio_Standard",
        "Shibaboo_Standard", "DreamNeedle_Standard", "TripleDown_Standard",
        "GiantSlice_Standard", "ResistDark_Standard"
    },
    permaBuffs = {
        ["Tansu_of_Vengeance"] = {
            stacks = 1,
            SlotsTaking = 1,
            visibility = 0,
            SlotType = "Equipment",
            ClassName = "smti_tansuofvengeance"
        }
    },
    essence = 200,
    kilodevil = 100,
    equipmentSlots = 15,
    itemSlots = 10,
    command = "inugamiA",
    type = "Demon",
    race = "beast",
    category = "Demons",
    cantSeeMembers = true,
    max = 25,
    turns = 1,
    salary = 0,
    admin = 0,
    vote = false,
    hasLicense = false,

    combatHP = 250,
    combatMP = 110,
    Luck = 10,
    Technique = 60,
    resist = {"Gun"},
    weak = {"Force", "Light"},
    block = {"Fire"},
    drain = {},
    repel = {},

    PlayerSpawn = function(ply)
        ply:SetHealth(250)
        ply:SetMaxHealth(250)
        ply:SetArmor(0)
        ply:SetMaxArmor(0)

        local job = ply:getJobTable() -- Get the job table for the player's current job 
        ply:SetNWInt("TBCHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMAXHP", job.combatHP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCMP", job.combatMP or 50) -- Set networked integer, defaulting to 50 if not set in job
        ply:SetNWInt("TBCMAXMP", job.combatMP or 100) -- Set networked integer, defaulting to 100 if not set in job
        ply:SetNWInt("TBCLuck", job.Luck or 10) -- Set networked integer, defaulting to 10 if not set in job
        ply:SetNWInt("TBCTechnique", job.Technique or 20) -- Set networked integer, defaulting to 20 if not set in job
        ply:SetNWInt("TBCEquipmentSlots", job.equipmentSlots or 15)
        ply:SetNWInt("TBCItemSlots", job.itemSlots or 10)

        local resistJSON = util.TableToJSON(job.resist)
        ply:SetNW2String("resist", resistJSON)
        local weakJSON = util.TableToJSON(job.weak)
        ply:SetNW2String("weak", weakJSON)
        local blockJSON = util.TableToJSON(job.block)
        ply:SetNW2String("block", blockJSON)
        local drainJSON = util.TableToJSON(job.drain)
        ply:SetNW2String("drain", drainJSON)
        local repelJSON = util.TableToJSON(job.repel)
        ply:SetNW2String("repel", repelJSON)

        ply:SetNW2String("selectedPersona", "")

        RemoveAllStats(ply, "buffs")
        RemoveAllStats(ply, "debuffs")
        RemoveAllStats(ply, "permabuffs")
        RemoveAllStats(ply, "permadebuffs")
        RemoveAllStats(ply, "personas")
        RemoveAllStats(ply, "permapersonas")

        if job.permaBuffs then
            for status, properties in pairs(job.permaBuffs) do
                AssignStat(ply, status, properties, "permabuffs")
            end
        end

        if job.permaDebuffs then
            for status, properties in pairs(job.permaDebuffs) do
                AssignStat(ply, status, properties, "permadebuffs")
            end
        end
    end
})

--[[---------------------------------------------------------------------------
Define which team joining players spawn into and what team you change to if demoted
---------------------------------------------------------------------------]]
GAMEMODE.DefaultTeam = TEAM_CITIZEN
--[[---------------------------------------------------------------------------
Define which teams belong to civil protection
Civil protection can set warrants, make people wanted and do some other police related things
---------------------------------------------------------------------------]]
GAMEMODE.CivilProtection = {
    [TEAM_POLICE] = true,
    [TEAM_CHIEF] = true,
    [TEAM_MAYOR] = true
}
--[[---------------------------------------------------------------------------
Jobs that are hitmen (enables the hitman menu)
---------------------------------------------------------------------------]]
DarkRP.addHitmanTeam(TEAM_MOB)

-- Default categories
DarkRP.createCategory {
    name = "Unknown (HIGHLY DANGEROUS)",
    categorises = "jobs",
    startExpanded = false,
    color = Color(153, 0, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 999
}

DarkRP.createCategory {
    name = "Visitors",
    categorises = "jobs",
    startExpanded = false,
    color = Color(0, 107, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 10
}

DarkRP.createCategory {
    name = "Students",
    categorises = "jobs",
    startExpanded = false,
    color = Color(0, 107, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 0
}

DarkRP.createCategory {
    name = "Residents",
    categorises = "jobs",
    startExpanded = false,
    color = Color(0, 107, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 0
}

DarkRP.createCategory {
    name = "Demons",
    categorises = "jobs",
    startExpanded = false,
    color = Color(153, 0, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 1
}

DarkRP.createCategory {
    name = "Persona 2",
    categorises = "jobs",
    startExpanded = false,
    color = Color(139, 0, 139, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 2
}

DarkRP.createCategory {
    name = "Persona 3",
    categorises = "jobs",
    startExpanded = false,
    color = Color(25, 25, 170, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 4
}

DarkRP.createCategory {
    name = "Persona 4",
    categorises = "jobs",
    startExpanded = false,
    color = Color(255, 229, 44, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 5
}

DarkRP.createCategory {
    name = "Persona 5",
    categorises = "jobs",
    startExpanded = false,
    color = Color(153, 0, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 5
}

DarkRP.createCategory {
    name = "Persona 5 X",
    categorises = "jobs",
    startExpanded = false,
    color = Color(153, 0, 0, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 6
}

DarkRP.createCategory {
    name = "Soul Hackers 2",
    categorises = "jobs",
    startExpanded = false,
    color = Color(203, 225, 49, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 7
}

DarkRP.createCategory {
    name = "Shin Megami Tensei V",
    categorises = "jobs",
    startExpanded = false,
    color = Color(205, 199, 103, 255),
    canSee = fp {fn.Id, true},
    sortOrder = 8
}
