--------------------------------------------------------------------------
-- [GGL] Warrior TBC PvP - Profile UI CodeSnippet (Order 2)
--
-- Construit l'onglet classe du panneau /action : checkboxes, sliders et
-- dropdowns modifiables EN JEU, a la volee, sans reload.
-- A installer APRES le snippet rotation (GGL_Action_Warrior_TBC_PvP.lua),
-- avec Order = 2 dans TellMeWhen -> Code Snippets.
--
-- Chaque toggle est aussi bindable en macro, ex :
--   /run Action.SetToggle({2, "Interrupt-Pummel"})
--   /run Action.SetToggle({2, "UseSpellReflection"})
--------------------------------------------------------------------------

local A                            = _G.Action
local WR                           = A[A.PlayerClass]
local L                            = {
    MOUSEOVER                      = { enUS = "Use\n@mouseover",
        frFR = "Utiliser\n@mouseover" },
    MOUSEOVERTT                    = { enUS = "Unlocks actions on @mouseover units (Pummel, Intercept, Disarm...)",
        frFR = "Debloque les actions sur les unites @mouseover (Zuboticine, Interception, Desarmement...)" },
    AOE                            = { enUS = "Use\nAoE",
        frFR = "Utiliser\nAoE" },
    AOETT                          = { enUS = "Enable multiunits actions (Cleave...)",
        frFR = "Active les actions multi-cibles (Enchainement...)" },
    STOPCAST                       = { enUS = "Stop cast\n(HS/Cleave queue)",
        frFR = "Stop cast\n(file HS/Cleave)" },
    STOPCASTTT                     = { enUS = "Cancels a queued Heroic Strike/Cleave when Execute is ready or target becomes immune",
        frFR = "Annule un Coup heroique/Enchainement en file quand Execution est prete ou que la cible devient immunisee" },
    INTERRUPTS                     = { enUS = "Interrupts (kick)",
        frFR = "Interruptions (kick)" },
    KICK_PUMMEL                    = { enUS = WR.Pummel:Info() .. "\nAuto kick",
        frFR = WR.Pummel:Info() .. "\nKick auto" },
    KICK_PUMMELTT                  = { enUS = "Automatically interrupts enemy casts with " .. WR.Pummel:Info() .. " (Berserker Stance only, no auto stance switch)\nMacro toggle: /run Action.SetToggle({2, \"Interrupt-Pummel\"})",
        frFR = "Interrompt automatiquement les casts ennemis avec " .. WR.Pummel:Info() .. " (Posture berserker uniquement, pas de changement de posture auto)\nMacro : /run Action.SetToggle({2, \"Interrupt-Pummel\"})" },
    KICK_SHIELDBASH                = { enUS = WR.ShieldBash:Info() .. "\nAuto kick",
        frFR = WR.ShieldBash:Info() .. "\nKick auto" },
    KICK_SHIELDBASHTT              = { enUS = "Interrupts with " .. WR.ShieldBash:Info() .. " if a shield is already equipped (Battle/Defensive Stance)",
        frFR = "Interrompt avec " .. WR.ShieldBash:Info() .. " si un bouclier est deja equipe (Posture de combat/defensive)" },
    KICK_FOCUS                     = { enUS = WR.Pummel:Info() .. "\n@focus auto kick",
        frFR = WR.Pummel:Info() .. "\nKick auto @focus" },
    KICK_FOCUSTT                   = { enUS = "Interrupts your FOCUS target's casts without switching target (put the enemy healer/caster in focus)\nMacro toggle: /run Action.SetToggle({2, \"Interrupt-Focus\"})",
        frFR = "Interrompt les casts de votre FOCUS sans changer de cible (mettez le healer/caster adverse en focus)\nMacro : /run Action.SetToggle({2, \"Interrupt-Focus\"})" },
    TEAM_HEADER                    = { enUS = "Team (2v2 druid / 3v3 lock+druid)",
        frFR = "Equipe (2v2 druide / 3v3 demo+druide)" },
    INTERVENE_HEALER               = { enUS = WR.Intervene:Info() .. "\nProtect healer",
        frFR = WR.Intervene:Info() .. "\nProteger le heal" },
    INTERVENE_HEALERTT             = { enUS = "Intervenes to your Druid (party1/party2 auto-detected) when he takes damage below the HP threshold\nSwitches to Defensive Stance automatically\nMacro toggle: /run Action.SetToggle({2, \"Intervene-Healer\"})",
        frFR = "Intervention sur votre druide (party1/party2 auto-detecte) quand il encaisse sous le seuil de PV\nBascule automatiquement en Posture defensive\nMacro : /run Action.SetToggle({2, \"Intervene-Healer\"})" },
    INTERVENE_HEALERHP             = { enUS = WR.Intervene:Info() .. "\nHealer <= health (%)",
        frFR = WR.Intervene:Info() .. "\nHeal <= sante (%)" },
    INTERVENE_HEALERHPTT           = { enUS = "Health threshold of your healer to trigger the Intervene",
        frFR = "Seuil de sante du soigneur qui declenche l'Intervention" },
    SHOUT                          = { enUS = "Used shout:",
        frFR = "Cri utilise :" },
    SHOUTTT                        = { enUS = "Battle Shout: attack power (default)\nCommanding Shout: +max health, useful into double DPS/cleave teams",
        frFR = "Cri de guerre : puissance d'attaque (defaut)\nCri de commandement : +PV max, utile contre les equipes double DPS/cleave" },
    REFLECT_HEADER                 = { enUS = "Spell Reflection",
        frFR = "Renvoi de sort" },
    REFLECT                        = { enUS = WR.SpellReflection:Info() .. "\nAuto reflect",
        frFR = WR.SpellReflection:Info() .. "\nRenvoi auto" },
    REFLECTTT                      = { enUS = "Reflects enemy casts targeting YOU (checks target/mouseover/arena1-5)\nMacro toggle: /run Action.SetToggle({2, \"UseSpellReflection\"})",
        frFR = "Renvoie les sorts ennemis castes SUR VOUS (verifie target/mouseover/arena1-5)\nMacro : /run Action.SetToggle({2, \"UseSpellReflection\"})" },
    REFLECT_SWAP                   = { enUS = WR.SpellReflection:Info() .. "\nAuto swap shield",
        frFR = WR.SpellReflection:Info() .. "\nSwap bouclier auto" },
    REFLECT_SWAPTT                 = { enUS = "Equips 1H + shield automatically for the reflect, then swaps back\nRequires the SwapWeapon macro (create it in /action) and a shield in bags",
        frFR = "Equipe automatiquement 1M + bouclier pour le renvoi, puis re-swap\nNecessite la macro SwapWeapon (a creer dans /action) et un bouclier dans les sacs" },
    CONTROL_HEADER                 = { enUS = "PvP - Control",
        frFR = "PvP - Controle" },
    DISARM_TRIGGER                 = { enUS = WR.Disarm:Info() .. "\nTrigger",
        frFR = WR.Disarm:Info() .. "\nDeclencheur" },
    DISARM_TRIGGERTT               = { enUS = "'On cooldown': as soon as available on a melee player\n'On enemy burst': only if the melee player has offensive buffs\n'OFF': disabled\nRequires Defensive Stance (auto switch if rage allows)",
        frFR = "'On cooldown' : des que disponible sur un joueur melee\n'On enemy burst' : seulement si le joueur melee a des buffs offensifs\n'OFF' : desactive\nNecessite la Posture defensive (bascule auto si la rage le permet)" },
    ON_CD                          = { enUS = "On cooldown",
        frFR = "Des que possible" },
    ON_BURST                       = { enUS = "On enemy burst",
        frFR = "Sur burst ennemi" },
    FEAR                           = { enUS = WR.IntimidatingShout:Info() .. "\nUse now",
        frFR = WR.IntimidatingShout:Info() .. "\nUtiliser maintenant" },
    FEARTT                         = { enUS = "ON: casts the fear as soon as target is within 8y and fearable, then think to turn it OFF\nMacro toggle: /run Action.SetToggle({2, \"UseIntimidatingShout\"})",
        frFR = "ON : lance le fear des que la cible est a 8m et fearable, pensez a le remettre OFF ensuite\nMacro : /run Action.SetToggle({2, \"UseIntimidatingShout\"})" },
    HOWL                           = { enUS = WR.PiercingHowl:Info() .. "\nAuto snare",
        frFR = WR.PiercingHowl:Info() .. "\nRalentissement auto" },
    HOWLTT                         = { enUS = "Casts if the target is within 10y and not already slowed (talent required)",
        frFR = "Lance si la cible est a 10m et pas deja ralentie (talent requis)" },
    HAMSTRING                      = { enUS = WR.Hamstring:Info() .. "\nSnare uptime",
        frFR = WR.Hamstring:Info() .. "\nMaintien du snare" },
    HAMSTRINGTT                    = { enUS = "Keeps Hamstring on enemy players",
        frFR = "Maintient Entrave sur les joueurs ennemis" },
    INTERCEPT                      = { enUS = WR.Intercept:Info() .. "\nAuto gap-closer",
        frFR = WR.Intercept:Info() .. "\nGap-closer auto" },
    INTERCEPTTT                    = { enUS = "Uses Intercept when the target is out of melee (switches to Berserker Stance if Tactical Mastery keeps the rage)",
        frFR = "Utilise Interception quand la cible est hors melee (bascule en Posture berserker si Maitrise tactique conserve la rage)" },
    ROTATION_HEADER                = { enUS = "Rotation",
        frFR = "Rotation" },
    OVERPOWER                      = { enUS = WR.Overpower:Info() .. "\nOn dodge",
        frFR = WR.Overpower:Info() .. "\nSur esquive" },
    OVERPOWERTT                    = { enUS = "Tracks dodges in the combat log and stance dances to Battle Stance when rage allows",
        frFR = "Detecte les esquives dans le log de combat et bascule en Posture de combat quand la rage le permet" },
    VICTORYRUSH                    = { enUS = WR.VictoryRush:Info() .. "\nUse",
        frFR = WR.VictoryRush:Info() .. "\nUtiliser" },
    VICTORYRUSHTT                  = { enUS = "Free damage after a kill",
        frFR = "Degats gratuits apres un kill" },
    BERSERKERRAGE_GAIN             = { enUS = WR.BerserkerRage:Info() .. "\nGenerate rage",
        frFR = WR.BerserkerRage:Info() .. "\nGenerer de la rage" },
    BERSERKERRAGE_GAINTT           = { enUS = "Uses " .. WR.BerserkerRage:Info() .. " at low rage if " .. WR.ImprovedBerserkerRage:Info() .. " is talented",
        frFR = "Utilise " .. WR.BerserkerRage:Info() .. " a rage basse si " .. WR.ImprovedBerserkerRage:Info() .. " est talente" },
    HEROICSTRIKE_PWR               = { enUS = WR.HeroicStrike:Info() .. "\n>= rage (value)",
        frFR = WR.HeroicStrike:Info() .. "\n>= rage (valeur)" },
    HEROICSTRIKE_PWRTT             = { enUS = "Minimum rage before queueing Heroic Strike",
        frFR = "Rage minimale avant de mettre Coup heroique en file" },
    CLEAVE_PWR                     = { enUS = WR.Cleave:Info() .. "\n>= rage (value)",
        frFR = WR.Cleave:Info() .. "\n>= rage (valeur)" },
    CLEAVE_PWRTT                   = { enUS = "Minimum rage before queueing Cleave (AoE mode)",
        frFR = "Rage minimale avant de mettre Enchainement en file (mode AoE)" },
    BLOODRAGE_LIMITHP              = { enUS = WR.Bloodrage:Info() .. "\n>= health (%)",
        frFR = WR.Bloodrage:Info() .. "\n>= sante (%)" },
    BLOODRAGE_LIMITHPTT            = { enUS = "Bloodrage only above this health percentage",
        frFR = "Sanguinaire uniquement au-dessus de ce pourcentage de sante" },
    LOC_HEADER                     = { enUS = "Loss of Control",
        frFR = "Perte de controle" },
    BERSERKERRAGE_LOC              = { enUS = WR.BerserkerRage:Info() .. "\nLoss of Control",
        frFR = WR.BerserkerRage:Info() .. "\nPerte de controle" },
    DEATHWISH_LOC                  = { enUS = WR.DeathWish:Info() .. "\nLoss of Control",
        frFR = WR.DeathWish:Info() .. "\nPerte de controle" },
    RACIAL_LOC                     = { enUS = "Auto Racial\nLoss of Control",
        frFR = "Racial auto\nPerte de controle" },
    LOC_TT                         = { enUS = "Used to break the matching loss of control effects (fear...)",
        frFR = "Utilise pour briser les effets de perte de controle correspondants (fear...)" },
}

A.Data.ProfileEnabled[A.CurrentProfile]             = true
A.Data.ProfileUI                                    = {
    DateTime = "v1 (25.07.2026)",
    [2]                                             = { LayoutOptions = { gutter = 2, padding = { left = 5, right = 5 } } },
    [7]                                             = {
        ["kick"] = { Enabled = true, Key = "Pummel", LUAVER = 1, LUA = [[
                -- This will not switch stance!
                local Obj      = Action[Action.PlayerClass]
                local Temp     = {"TotalImun", "DamagePhysImun", "KickImun"}
                local castLeft, _, _, _, notInterruptAble = Unit(thisunit):IsCastingRemains()
                return  Obj.Pummel and
                        Obj.Pummel:IsReadyM(thisunit) and
                        Obj.Pummel:AbsentImun(thisunit, Temp) and
                        castLeft > 0 and
                        not notInterruptAble
            ]] },
        ["fear"] = { Enabled = true, Key = "IntimidatingShout", LUAVER = 1, LUA = [[
                local Obj     = Action[Action.PlayerClass]
                local Temp    = {"TotalImun", "DamagePhysImun", "FearImun"}
                return  Obj.IntimidatingShout and
                        Obj.IntimidatingShout:IsReadyM(thisunit) and
                        Obj.IntimidatingShout:AbsentImun(thisunit, Temp) and
                        Unit(thisunit):IsControlAble("fear")
            ]] },
        ["disarm"] = { Enabled = true, Key = "Disarm", LUAVER = 1, LUA = [[
                local Obj     = Action[Action.PlayerClass]
                local Temp    = {"TotalImun", "DamagePhysImun", "CCTotalImun"}
                return  Obj.Disarm and
                        Obj.Disarm:IsReadyM(thisunit) and
                        Obj.Disarm:AbsentImun(thisunit, Temp) and
                        Unit(thisunit):IsControlAble("disarm")
            ]] },
    },
}

local ProfileUI                                     = A.Data.ProfileUI[2]

-- [[ General ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "mouseover",
        DBV           = true,
        L             = L.MOUSEOVER,
        TT            = L.MOUSEOVERTT,
        M             = {},
    },
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
}

-- [[ Interrupts ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.INTERRUPTS,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "Interrupt-Pummel",
        DBV           = true,
        L             = L.KICK_PUMMEL,
        TT            = L.KICK_PUMMELTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "Interrupt-Focus",
        DBV           = true,
        L             = L.KICK_FOCUS,
        TT            = L.KICK_FOCUSTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "Interrupt-ShieldBash",
        DBV           = false,
        L             = L.KICK_SHIELDBASH,
        TT            = L.KICK_SHIELDBASHTT,
        M             = {},
    },
}

-- [[ Team : 2v2 druide / 3v3 lock+druide ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.TEAM_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "Intervene-Healer",
        DBV           = true,
        L             = L.INTERVENE_HEALER,
        TT            = L.INTERVENE_HEALERTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 10,
        MAX           = 100,
        DB            = "Intervene-HealerHP",
        DBV           = 60,
        L             = L.INTERVENE_HEALERHP,
        TT            = L.INTERVENE_HEALERHPTT,
        M             = {},
    },
    {
        E             = "Dropdown",
        OT            = {
            { text = (WR.BattleShout:Info()),      value = "BattleShout" },
            { text = (WR.CommandingShout:Info()),  value = "CommandingShout" },
            { text = "OFF",                        value = "OFF" },
        },
        DB            = "ShoutToUse",
        DBV           = "BattleShout",
        L             = L.SHOUT,
        TT            = L.SHOUTTT,
        M             = {},
    },
}

-- [[ Spell Reflection ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.REFLECT_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "UseSpellReflection",
        DBV           = true,
        L             = L.REFLECT,
        TT            = L.REFLECTTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "SpellReflection-AutoSwap",
        DBV           = true,
        L             = L.REFLECT_SWAP,
        TT            = L.REFLECT_SWAPTT,
        M             = {},
    },
}

-- [[ PvP Control ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.CONTROL_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Dropdown",
        OT            = {
            { text = L.ON_CD,       value = "ON COOLDOWN" },
            { text = L.ON_BURST,    value = "ON BURST" },
            { text = "OFF",         value = "OFF" },
        },
        DB            = "Trigger-Disarm",
        DBV           = "ON BURST",
        L             = L.DISARM_TRIGGER,
        TT            = L.DISARM_TRIGGERTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseIntimidatingShout",
        DBV           = false,
        L             = L.FEAR,
        TT            = L.FEARTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UsePiercingHowl",
        DBV           = true,
        L             = L.HOWL,
        TT            = L.HOWLTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Checkbox",
        DB            = "UseHamstring",
        DBV           = true,
        L             = L.HAMSTRING,
        TT            = L.HAMSTRINGTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseIntercept",
        DBV           = true,
        L             = L.INTERCEPT,
        TT            = L.INTERCEPTTT,
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
        DB            = "UseOverpower",
        DBV           = true,
        L             = L.OVERPOWER,
        TT            = L.OVERPOWERTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseVictoryRush",
        DBV           = true,
        L             = L.VICTORYRUSH,
        TT            = L.VICTORYRUSHTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseBerserkerRage-GainRage",
        DBV           = true,
        L             = L.BERSERKERRAGE_GAIN,
        TT            = L.BERSERKERRAGE_GAINTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Slider",
        MIN           = 15,
        MAX           = 100,
        DB            = "HeroicStrike-PWR",
        DBV           = 60,
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
        DBV           = 70,
        L             = L.BLOODRAGE_LIMITHP,
        TT            = L.BLOODRAGE_LIMITHPTT,
        M             = {},
    },
}

-- [[ Loss of Control ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.LOC_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "UseBerserkerRage-LoC",
        DBV           = true,
        L             = L.BERSERKERRAGE_LOC,
        TT            = L.LOC_TT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseDeathWish-LoC",
        DBV           = true,
        L             = L.DEATHWISH_LOC,
        TT            = L.LOC_TT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseRacial-LoC",
        DBV           = true,
        L             = L.RACIAL_LOC,
        TT            = L.LOC_TT,
        M             = {},
    },
}
