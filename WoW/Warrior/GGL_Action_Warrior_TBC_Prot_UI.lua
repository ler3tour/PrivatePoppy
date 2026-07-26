--------------------------------------------------------------------------
-- [GGL] Warrior TBC Prot - Profile UI CodeSnippet (Order 2)
-- Panneau /action pour le profil Protection DPS max.
--------------------------------------------------------------------------

local A                            = _G.Action
local WR                           = A[A.PlayerClass]
local L                            = {
    AOE                            = { enUS = "Use\nAoE",
        frFR = "Utiliser\nAoE" },
    AOETT                          = { enUS = "Enables Cleave on 2+ targets",
        frFR = "Active Enchainement sur 2+ cibles" },
    STOPCAST                       = { enUS = "Stop cast\n(HS/Cleave queue)",
        frFR = "Stop cast\n(file HS/Cleave)" },
    STOPCASTTT                     = { enUS = "Cancels a queued Heroic Strike/Cleave if the target becomes immune",
        frFR = "Annule un Coup heroique/Enchainement en file si la cible devient immunisee" },
    ROTATION_HEADER                = { enUS = "Rotation (Shield Slam > Revenge > Devastate)",
        frFR = "Rotation (Heurt de bouclier > Vengeance > Devastation)" },
    SHIELDBLOCK                    = { enUS = WR.ShieldBlock:Info() .. "\nOn cooldown",
        frFR = WR.ShieldBlock:Info() .. "\nDes que possible" },
    SHIELDBLOCKTT                  = { enUS = "Off-GCD: prevents crushing blows AND generates Revenge procs (blocked hits enable Revenge) — top parses keep it rolling",
        frFR = "Hors GCD : evite les coups ecrasants ET genere des procs Vengeance (les coups bloques activent Vengeance) — les top parses le maintiennent en continu" },
    THUNDERCLAP                    = { enUS = WR.ThunderClap:Info() .. "\nMaintain debuff",
        frFR = WR.ThunderClap:Info() .. "\nMaintenir le debuff" },
    THUNDERCLAPTT                  = { enUS = "Costs a GCD: turn OFF for maximum DPS if another warrior applies it",
        frFR = "Coute un GCD : OFF pour le DPS maximum si un autre guerrier l'applique" },
    DEMOSHOUT                      = { enUS = WR.DemoralizingShout:Info() .. "\nMaintain debuff",
        frFR = WR.DemoralizingShout:Info() .. "\nMaintenir le debuff" },
    DEMOSHOUTTT                    = { enUS = "Costs a GCD: turn OFF for maximum DPS if another warrior applies it",
        frFR = "Coute un GCD : OFF pour le DPS maximum si un autre guerrier l'applique" },
    KICK_SHIELDBASH                = { enUS = WR.ShieldBash:Info() .. "\nAuto kick",
        frFR = WR.ShieldBash:Info() .. "\nKick auto" },
    KICK_SHIELDBASHTT              = { enUS = "Interrupts enemy casts (dungeons / caster trash)",
        frFR = "Interrompt les casts ennemis (donjons / trash casteurs)" },
    HEROICSTRIKE_PWR               = { enUS = WR.HeroicStrike:Info() .. "\n>= rage (value)",
        frFR = WR.HeroicStrike:Info() .. "\n>= rage (valeur)" },
    HEROICSTRIKE_PWRTT             = { enUS = "Rage dump threshold. The reserve logic already protects Shield Slam/Shield Block; lower = more HS = more DPS when incoming rage is high",
        frFR = "Seuil de vidange. La reserve protege deja Heurt de bouclier/Blocage ; plus bas = plus de HS = plus de DPS quand la rage entrante est forte" },
    CLEAVE_PWR                     = { enUS = WR.Cleave:Info() .. "\n>= rage (value)",
        frFR = WR.Cleave:Info() .. "\n>= rage (valeur)" },
    CLEAVE_PWRTT                   = { enUS = "Minimum rage before queueing Cleave (AoE mode)",
        frFR = "Rage minimale avant de mettre Enchainement en file (mode AoE)" },
    BLOODRAGE_LIMITHP              = { enUS = WR.Bloodrage:Info() .. "\n>= health (%)",
        frFR = WR.Bloodrage:Info() .. "\n>= sante (%)" },
    BLOODRAGE_LIMITHPTT            = { enUS = "Bloodrage only above this health percentage",
        frFR = "Sanguinaire uniquement au-dessus de ce pourcentage de sante" },
    MIGHTYRAGEPOTION               = { enUS = WR.MightyRagePotion:Info() .. "\nIn burst window",
        frFR = WR.MightyRagePotion:Info() .. "\nEn fenetre de burst" },
    MIGHTYRAGEPOTIONTT             = { enUS = "Uses the potion during the burst window when rage is low",
        frFR = "Utilise la potion pendant la fenetre de burst quand la rage manque" },
    SHOUT                          = { enUS = "Used shout:",
        frFR = "Cri utilise :" },
    SHOUTTT                        = { enUS = "Commanding Shout: +max health (tank default)\nBattle Shout: attack power (more DPS)",
        frFR = "Cri de commandement : +PV max (defaut tank)\nCri de guerre : puissance d'attaque (plus de DPS)" },
    DEFENSE_HEADER                 = { enUS = "Defense",
        frFR = "Defense" },
    SHIELDWALL_HP                  = { enUS = WR.ShieldWall:Info() .. "\n<= health (%)",
        frFR = WR.ShieldWall:Info() .. "\n<= sante (%)" },
    LASTSTAND_HP                   = { enUS = WR.LastStand:Info() .. "\n<= health (%)",
        frFR = WR.LastStand:Info() .. "\n<= sante (%)" },
    DEFENSE_TT                     = { enUS = "0 = disabled. Triggers below this health percentage",
        frFR = "0 = desactive. Se declenche sous ce pourcentage de sante" },
}

A.Data.ProfileEnabled[A.CurrentProfile]             = true
A.Data.ProfileUI                                    = {
    DateTime = "v1 (26.07.2026)",
    [2]                                             = { LayoutOptions = { gutter = 2, padding = { left = 5, right = 5 } } },
    [7]                                             = {
        ["kick"] = { Enabled = true, Key = "ShieldBash", LUAVER = 1, LUA = [[
                local Obj      = Action[Action.PlayerClass]
                local Temp     = {"TotalImun", "DamagePhysImun", "KickImun"}
                local castLeft, _, _, _, notInterruptAble = Unit(thisunit):IsCastingRemains()
                return  Obj.ShieldBash and
                        Obj.ShieldBash:IsReadyM(thisunit) and
                        Obj.ShieldBash:AbsentImun(thisunit, Temp) and
                        castLeft > 0 and
                        not notInterruptAble
            ]] },
        ["laststand"] = { Enabled = true, Key = "LastStand", LUAVER = 2, LUA = [[
                local Obj = Action[Action.PlayerClass]
                return  Obj.LastStand and
                        Obj.LastStand:IsReadyM(thisunit) and
                        UnitIsUnit(thisunit, "player")
            ]] },
        ["shieldwall"] = { Enabled = true, Key = "ShieldWall", LUAVER = 2, LUA = [[
                local Obj = Action[Action.PlayerClass]
                return  Obj.ShieldWall and
                        Obj.ShieldWall:IsReadyM(thisunit) and
                        UnitIsUnit(thisunit, "player")
            ]] },
    },
}

local ProfileUI                                     = A.Data.ProfileUI[2]

-- [[ General ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "AoE",
        DBV           = false,
        L             = L.AOE,
        TT            = L.AOETT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "StopCast",
        DBV           = true,
        L             = L.STOPCAST,
        TT            = L.STOPCASTTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "Interrupt-ShieldBash",
        DBV           = true,
        L             = L.KICK_SHIELDBASH,
        TT            = L.KICK_SHIELDBASHTT,
        M             = {},
    },
}

-- [[ Rotation ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.ROTATION_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "ShieldBlock",
        DBV           = true,
        L             = L.SHIELDBLOCK,
        TT            = L.SHIELDBLOCKTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "MaintainThunderClap",
        DBV           = false,
        L             = L.THUNDERCLAP,
        TT            = L.THUNDERCLAPTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "MaintainDemoShout",
        DBV           = false,
        L             = L.DEMOSHOUT,
        TT            = L.DEMOSHOUTTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Slider",
        MIN           = 30,
        MAX           = 100,
        DB            = "HeroicStrike-PWR",
        DBV           = 50,
        L             = L.HEROICSTRIKE_PWR,
        TT            = L.HEROICSTRIKE_PWRTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 20,
        MAX           = 100,
        DB            = "Cleave-PWR",
        DBV           = 50,
        L             = L.CLEAVE_PWR,
        TT            = L.CLEAVE_PWRTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 0,
        MAX           = 100,
        DB            = "Bloodrage-LimitHP",
        DBV           = 35,
        L             = L.BLOODRAGE_LIMITHP,
        TT            = L.BLOODRAGE_LIMITHPTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Dropdown",
        OT            = {
            { text = (WR.CommandingShout:Info()),  value = "CommandingShout" },
            { text = (WR.BattleShout:Info()),      value = "BattleShout" },
            { text = "OFF",                        value = "OFF" },
        },
        DB            = "ShoutToUse",
        DBV           = "CommandingShout",
        L             = L.SHOUT,
        TT            = L.SHOUTTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "MightyRagePotion",
        DBV           = false,
        L             = L.MIGHTYRAGEPOTION,
        TT            = L.MIGHTYRAGEPOTIONTT,
        M             = {},
    },
}

-- [[ Defense ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.DEFENSE_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Slider",
        MIN           = 0,
        MAX           = 100,
        DB            = "ShieldWallHP",
        DBV           = 25,
        L             = L.SHIELDWALL_HP,
        TT            = L.DEFENSE_TT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 0,
        MAX           = 100,
        DB            = "LastStandHP",
        DBV           = 35,
        L             = L.LASTSTAND_HP,
        TT            = L.DEFENSE_TT,
        M             = {},
    },
}
