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
    FORCEDEF                       = { enUS = WR.DefensiveStance:Info() .. "\nLock stance",
        frFR = WR.DefensiveStance:Info() .. "\nVerrouiller la posture" },
    FORCEDEFTT                     = { enUS = "ON: switches to Defensive Stance and STAYS there until you turn it off — all automatic stance dances are suspended (kicks fall back to Shield Bash, Reflect/Disarm stay available)\nMacro: /run Action.SetToggle({2, \"ForceDefStance\"})",
        frFR = "ON : bascule en Posture defensive et Y RESTE tant que vous ne le desactivez pas — tous les stance dances automatiques sont suspendus (les kicks passent sur Heurt de bouclier, Renvoi/Desarmement restent disponibles)\nMacro : /run Action.SetToggle({2, \"ForceDefStance\"})" },
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
    KICK_ONLYIMPORTANT             = { enUS = "Kick only\nheals / CC / rez",
        frFR = "Kick seulement\nheals / CC / rez" },
    KICK_ONLYIMPORTANTTT           = { enUS = "Saves your interrupt for key casts: heals, Fear, Polymorph, Cyclone, resurrections...\nOFF = kicks any interruptible cast",
        frFR = "Garde votre interruption pour les casts cles : heals, Fear, Polymorphe, Cyclone, resurrections...\nOFF = kick n'importe quel cast interruptible" },
    KICK_ATCASTDONE                = { enUS = "Anti-fake\nKick at >= cast (%)",
        frFR = "Anti-fake\nKick a >= du cast (%)" },
    KICK_ATCASTDONETT              = { enUS = "Waits until the enemy cast reached this percentage before kicking, to beat fake-casting\n0 = kick instantly (kickable by fakes)\n30-50 = recommended vs good players",
        frFR = "Attend que le cast ennemi atteigne ce pourcentage avant de kicker, pour battre les fake casts\n0 = kick instantane (vulnerable aux fakes)\n30-50 = recommande contre les bons joueurs" },
    MIGHTYRAGEPOTION               = { enUS = WR.MightyRagePotion:Info() .. "\nIn burst window",
        frFR = WR.MightyRagePotion:Info() .. "\nEn fenetre de burst" },
    MIGHTYRAGEPOTIONTT             = { enUS = "Uses the potion during the burst window when rage is low (< 25)",
        frFR = "Utilise la potion pendant la fenetre de burst quand la rage manque (< 25)" },
    REFLECT_ONLYIMPORTANT          = { enUS = WR.SpellReflection:Info() .. "\nOnly CC & big nukes",
        frFR = WR.SpellReflection:Info() .. "\nSeulement CC & gros sorts" },
    REFLECT_ONLYIMPORTANTTT        = { enUS = "Only starts the shield swap for spells worth reflecting: Fear, Polymorph, Cyclone, Entangling Roots, Frostbolt, Fireball, Pyroblast, Shadow Bolt, Soul Fire, Mind Control...\nOFF = reflects any cast targeting you",
        frFR = "Ne lance le swap bouclier que pour les sorts qui valent le renvoi : Fear, Polymorphe, Cyclone, Sarments, Eclair de givre, Boule de feu, Pyrobarrage, Trait de l'ombre, Feu de l'ame, Controle mental...\nOFF = renvoie n'importe quel cast qui vous cible" },
    BERSERKERRAGE_PREFEAR          = { enUS = WR.BerserkerRage:Info() .. "\nPre-cast vs Fear",
        frFR = WR.BerserkerRage:Info() .. "\nAnticipation anti-Fear" },
    BERSERKERRAGE_PREFEARTT        = { enUS = "Uses Berserker Rage WHILE the enemy Fear/Howl of Terror is still casting on you (10s immunity), with emergency stance dance\nMacro toggle: /run Action.SetToggle({2, \"UseBerserkerRage-PreFear\"})",
        frFR = "Utilise Rage berserker PENDANT que le Fear/Hurlement de terreur ennemi est encore en cast sur vous (10 s d'immunite), avec stance dance d'urgence\nMacro : /run Action.SetToggle({2, \"UseBerserkerRage-PreFear\"})" },
    REND                           = { enUS = WR.Rend:Info() .. "\nAnti-restealth",
        frFR = WR.Rend:Info() .. "\nAnti-camouflage" },
    RENDTT                         = { enUS = "Keeps Rend rolling on Rogues and Druids to deny restealth (Battle Stance dance when rage allows)",
        frFR = "Maintient Pourfendre sur les Voleurs et Druides pour empecher le retour en camouflage (bascule en Posture de combat quand la rage le permet)" },
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
    {
        E             = "Checkbox",
        DB            = "ForceDefStance",
        DBV           = false,
        L             = L.FORCEDEF,
        TT            = L.FORCEDEFTT,
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
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Checkbox",
        DB            = "Interrupt-OnlyImportant",
        DBV           = false,
        L             = L.KICK_ONLYIMPORTANT,
        TT            = L.KICK_ONLYIMPORTANTTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 0,
        MAX           = 70,
        DB            = "Interrupt-AtCastDone",
        DBV           = 30,
        L             = L.KICK_ATCASTDONE,
        TT            = L.KICK_ATCASTDONETT,
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
    {
        E             = "Checkbox",
        DB            = "SpellReflection-OnlyImportant",
        DBV           = true,
        L             = L.REFLECT_ONLYIMPORTANT,
        TT            = L.REFLECT_ONLYIMPORTANTTT,
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
        DB            = "UseRend",
        DBV           = true,
        L             = L.REND,
        TT            = L.RENDTT,
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
    {
        E             = "Checkbox",
        DB            = "MightyRagePotion",
        DBV           = true,
        L             = L.MIGHTYRAGEPOTION,
        TT            = L.MIGHTYRAGEPOTIONTT,
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
        DB            = "UseBerserkerRage-PreFear",
        DBV           = true,
        L             = L.BERSERKERRAGE_PREFEAR,
        TT            = L.BERSERKERRAGE_PREFEARTT,
        M             = {},
    },
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

--------------------------------------------------------------------------
-- [[ BARRE DE TOGGLES A L'ECRAN - PvP ]]
-- Boutons cliquables avec le skin (icone) de chaque sort :
--   - icone en couleur + lisere dore  = ACTIVE
--   - icone grisee                    = DESACTIVE
--   - Disarm : clic cycle OFF -> "CD" (on cooldown) -> "BURST"
--   - "F" = kick @focus | 1er bouton = verrou Posture defensive
--   - clic gauche : bascule | Shift + glisser : deplacer | /gglbar : masquer
--------------------------------------------------------------------------
do
    local TMW             = _G.TMW
    local CreateFrame     = _G.CreateFrame
    local UIParent        = _G.UIParent
    local GameTooltip     = _G.GameTooltip
    local GetSpellInfo    = _G.GetSpellInfo
    local IsShiftKeyDown  = _G.IsShiftKeyDown
    local GetToggle       = A.GetToggle
    local SetToggle       = A.SetToggle

    -- cycle : liste de valeurs (clic passe a la suivante), tags affiches
    local BUTTONS = {
        { key = "ForceDefStance",       spell = WR.DefensiveStance,    default = false },
        { key = "Interrupt-Pummel",     spell = WR.Pummel,             default = true  },
        { key = "Interrupt-Focus",      spell = WR.Pummel,             default = true, tag = "F" },
        { key = "Interrupt-ShieldBash", spell = WR.ShieldBash,         default = false },
        { key = "UseSpellReflection",   spell = WR.SpellReflection,    default = true  },
        { key = "Trigger-Disarm",       spell = WR.Disarm,             default = "ON BURST",
          cycle = { "OFF", "ON COOLDOWN", "ON BURST" },
          cycleTags = { ["ON COOLDOWN"] = "CD", ["ON BURST"] = "BURST" } },
        { key = "UseIntimidatingShout", spell = WR.IntimidatingShout,  default = false },
        { key = "UsePiercingHowl",      spell = WR.PiercingHowl,       default = true  },
        { key = "UseHamstring",         spell = WR.Hamstring,          default = true  },
        { key = "UseIntercept",         spell = WR.Intercept,          default = true  },
        { key = "UseOverpower",         spell = WR.Overpower,          default = true  },
    }


    -- Acces direct a la base de reglages (Action.SetToggle refuse les
    -- cles pas encore initialisees : "X is not found!") — on seme les
    -- valeurs par defaut nous-memes et on ecrit directement, comme le
    -- fait le code GGL d'origine (TMW.db.profile.ActionDB[2])
    local function GetDB()
        return TMW.db and TMW.db.profile and TMW.db.profile.ActionDB and TMW.db.profile.ActionDB[2]
    end

    local function SeedDefaults()
        local db = GetDB()
        if not db then return end
        for i = 1, #BUTTONS do
            local e = BUTTONS[i]
            if db[e.key] == nil then
                db[e.key] = e.default
            end
        end
    end
    SeedDefaults()

    local SIZE, GAP, PAD = 32, 4, 4

    local function GetValue(entry)
        local value = GetToggle(2, entry.key)
        if value == nil then
            return entry.default
        end
        return value
    end

    local function IsActive(entry)
        local value = GetValue(entry)
        if entry.cycle then
            return value ~= "OFF"
        end
        return value and true or false
    end

    local bar = _G.GGLPvPToggleBar
    if not bar then
        bar = CreateFrame("Frame", "GGLPvPToggleBar", UIParent)
        bar:SetWidth(PAD * 2 + #BUTTONS * SIZE + (#BUTTONS - 1) * GAP)
        bar:SetHeight(PAD * 2 + SIZE)
        bar:SetPoint("CENTER", UIParent, "CENTER", 0, -220)
        bar:SetMovable(true)
        bar:EnableMouse(true)
        bar:SetClampedToScreen(true)
        bar:SetFrameStrata("MEDIUM")

        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(bar)
        bg:SetTexture(0, 0, 0, 0.45)

        bar.buttons = {}

        local function StartDrag()
            if IsShiftKeyDown() then
                bar:StartMoving()
                bar.isMoving = true
            end
        end
        local function StopDrag()
            if bar.isMoving then
                bar:StopMovingOrSizing()
                bar:SetUserPlaced(true)
                bar.isMoving = false
            end
        end
        bar:RegisterForDrag("LeftButton")
        bar:SetScript("OnDragStart", StartDrag)
        bar:SetScript("OnDragStop", StopDrag)

        for i = 1, #BUTTONS do
            local entry = BUTTONS[i]
            local btn = CreateFrame("Button", "GGLPvPToggleButton" .. i, bar)
            btn:SetWidth(SIZE)
            btn:SetHeight(SIZE)
            btn:SetPoint("LEFT", bar, "LEFT", PAD + (i - 1) * (SIZE + GAP), 0)

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(btn)
            local _, _, spellIcon = GetSpellInfo(entry.spell.ID)
            icon:SetTexture(spellIcon or "Interface\\Icons\\INV_Misc_QuestionMark")
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            btn.icon = icon

            local border = btn:CreateTexture(nil, "OVERLAY")
            border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            border:SetBlendMode("ADD")
            border:SetPoint("CENTER", btn, "CENTER", 0, 0)
            border:SetWidth(SIZE * 1.7)
            border:SetHeight(SIZE * 1.7)
            btn.border = border

            -- tag statique ("F" pour le kick focus)
            if entry.tag then
                local tagText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                tagText:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -1, -1)
                tagText:SetText(entry.tag)
            end

            -- tag dynamique (etats du cycle Disarm)
            if entry.cycle then
                local cycleText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                cycleText:SetPoint("BOTTOM", btn, "BOTTOM", 0, 1)
                btn.cycleText = cycleText
            end

            btn.entry = entry

            btn:RegisterForDrag("LeftButton")
            btn:SetScript("OnDragStart", StartDrag)
            btn:SetScript("OnDragStop", StopDrag)

            btn:SetScript("OnClick", function()
                local db = GetDB()
                if not db then return end
                if entry.cycle then
                    local current = GetValue(entry)
                    local nextIndex = 1
                    for c = 1, #entry.cycle do
                        if entry.cycle[c] == current then
                            nextIndex = (c % #entry.cycle) + 1
                            break
                        end
                    end
                    db[entry.key] = entry.cycle[nextIndex]
                else
                    local current = db[entry.key]
                    if current == nil then
                        current = entry.default
                    end
                    db[entry.key] = not current
                end
            end)

            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_TOP")
                GameTooltip:AddLine((entry.spell:Info()) or entry.key)
                local value = GetValue(entry)
                if entry.cycle then
                    GameTooltip:AddLine("Mode : |cff00ff00" .. tostring(value) .. "|r - clic pour changer", 1, 1, 1)
                elseif IsActive(entry) then
                    GameTooltip:AddLine("|cff00ff00ACTIVE|r - clic pour desactiver", 1, 1, 1)
                else
                    GameTooltip:AddLine("|cffff2020DESACTIVE|r - clic pour activer", 1, 1, 1)
                end
                GameTooltip:AddLine("Shift + glisser : deplacer la barre", 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            bar.buttons[i] = btn
        end

        local elapsedSince = 0
        bar:SetScript("OnUpdate", function(self, elapsed)
            elapsedSince = elapsedSince + (elapsed or _G.arg1 or 0.02)
            if elapsedSince < 0.2 then return end
            elapsedSince = 0
            SeedDefaults()
            for j = 1, #bar.buttons do
                local b = bar.buttons[j]
                if IsActive(b.entry) then
                    b.icon:SetVertexColor(1, 1, 1)
                    b.border:Show()
                else
                    b.icon:SetVertexColor(0.25, 0.25, 0.25)
                    b.border:Hide()
                end
                if b.cycleText then
                    local value = GetValue(b.entry)
                    b.cycleText:SetText((b.entry.cycleTags and b.entry.cycleTags[value]) or "")
                end
            end
        end)

        _G.SLASH_GGLBAR1 = "/gglbar"
        _G.SlashCmdList["GGLBAR"] = function()
            if bar:IsShown() then
                bar:Hide()
            else
                bar:Show()
            end
        end
    end
end


-- Configuration du panneau overlay
local GGL_ColorHex = "|cffb16bff"
local GGL_PANEL_TITLE = "GGL — WARRIOR PVP ARMS"
local GGL_PANEL_SECTIONS = {
    { title = "GENERAL", items = {
        { type = "check", key = "ForceDefStance", label = "Verrou Posture defensive", default = false, tooltip = "Y reste tant qu'actif" },
        { type = "check", key = "mouseover", label = "Actions @mouseover", default = true, tooltip = "" },
        { type = "check", key = "StopCast", label = "Stop cast HS/Cleave", default = true, tooltip = "" },
        { type = "check", key = "AoE", label = "Mode AoE (Cleave)", default = false, tooltip = "" },
        { type = "check", key = "UseMortalStrike", label = "Mortal Strike", default = true, tooltip = "Coeur du build Arms" },
        { type = "check", key = "UseExecute", label = "Execute (< 20%)", default = true, tooltip = "" },
        { type = "check", key = "UseWhirlwind", label = "Whirlwind", default = true, tooltip = "" },
        { type = "check", key = "UseHeroicStrike", label = "Heroic Strike (vidange)", default = true, tooltip = "" },
        { type = "check", key = "UseCleave", label = "Cleave (mode AoE)", default = true, tooltip = "" },
        { type = "check", key = "UseBloodrage", label = "Bloodrage", default = true, tooltip = "" },
        { type = "check", key = "UseCharge", label = "Charge (pre-combat)", default = true, tooltip = "" },
    } },
    { title = "INTERRUPTS", items = {
        { type = "check", key = "Interrupt-Pummel", label = "Pummel (kick auto)", default = true, tooltip = "" },
        { type = "check", key = "Interrupt-Focus", label = "Pummel @focus", default = true, tooltip = "Kick le focus sans changer de cible" },
        { type = "check", key = "Interrupt-ShieldBash", label = "Shield Bash (bouclier equipe)", default = false, tooltip = "" },
        { type = "check", key = "Interrupt-OnlyImportant", label = "Kick seulement heals/CC/rez", default = false, tooltip = "" },
        { type = "slider", key = "Interrupt-AtCastDone", label = "Anti-fake : kick a >= du cast", min = 0, max = 70, default = 30, suffix = "%", tooltip = "0 = instantane" },
    } },
    { title = "SPELL REFLECTION", items = {
        { type = "check", key = "UseSpellReflection", label = "Renvoi auto", default = true, tooltip = "" },
        { type = "check", key = "SpellReflection-AutoSwap", label = "Swap bouclier auto", default = true, tooltip = "Macro SwapWeapon requise" },
        { type = "check", key = "SpellReflection-OnlyImportant", label = "Seulement CC & gros sorts", default = true, tooltip = "" },
    } },
    { title = "CONTROLE", items = {
        { type = "cycle", key = "Trigger-Disarm", label = "Disarm", default = "ON BURST", options = { { text = "OFF", value = "OFF", width = 36 }, { text = "CD", value = "ON COOLDOWN", width = 36 }, { text = "BURST", value = "ON BURST", width = 52 } }, tooltip = "Sur burst ennemi ou des que possible" },
        { type = "check", key = "UseIntimidatingShout", label = "Intimidating Shout (a la demande)", default = false, tooltip = "ON = fear des que possible" },
        { type = "check", key = "UsePiercingHowl", label = "Piercing Howl (complement)", default = true, tooltip = "" },
        { type = "check", key = "UseHamstring", label = "Hamstring (snare principal)", default = true, tooltip = "" },
        { type = "check", key = "UseIntercept", label = "Intercept (gap-closer)", default = true, tooltip = "" },
        { type = "check", key = "UseOverpower", label = "Overpower sur esquive", default = true, tooltip = "" },
        { type = "check", key = "UseRend", label = "Rend anti-restealth", default = true, tooltip = "Rogues et druides" },
        { type = "check", key = "UseVictoryRush", label = "Victory Rush", default = true, tooltip = "" },
    } },
    { title = "EQUIPE (2v2 druide / 3v3 WLD)", items = {
        { type = "check", key = "Intervene-Healer", label = "Intervene sur le druide", default = true, tooltip = "" },
        { type = "slider", key = "Intervene-HealerHP", label = "Intervene si heal <= PV", min = 10, max = 100, default = 60, suffix = "%", tooltip = "" },
        { type = "cycle", key = "ShoutToUse", label = "Cri utilise", default = "BattleShout", options = { { text = "Battle", value = "BattleShout", width = 48 }, { text = "Command.", value = "CommandingShout", width = 64 }, { text = "OFF", value = "OFF", width = 36 } }, tooltip = "" },
    } },
    { title = "ANTI-CC & DIVERS", items = {
        { type = "check", key = "UseBerserkerRage-PreFear", label = "Berserker Rage anti-fear (pre-cast)", default = true, tooltip = "" },
        { type = "check", key = "UseBerserkerRage-LoC", label = "Berserker Rage (perte de controle)", default = true, tooltip = "" },
        { type = "check", key = "UseDeathWish-LoC", label = "Death Wish (anti-fear)", default = true, tooltip = "" },
        { type = "check", key = "UseRacial-LoC", label = "Racial auto (perte de controle)", default = true, tooltip = "" },
        { type = "check", key = "MightyRagePotion", label = "Mighty Rage Potion (burst)", default = true, tooltip = "" },
        { type = "check", key = "UseDeathWish", label = "Death Wish (burst)", default = true, tooltip = "" },
        { type = "check", key = "UseRecklessness", label = "Recklessness (burst)", default = true, tooltip = "" },
        { type = "check", key = "UseRacials", label = "Racials (Berserking/Blood Fury)", default = true, tooltip = "" },
        { type = "check", key = "UseTrinket1", label = "Trinket 1 (slot haut)", default = true, tooltip = "" },
        { type = "check", key = "UseTrinket2", label = "Trinket 2 (slot bas)", default = true, tooltip = "" },
        { type = "slider", key = "HeroicStrike-PWR", label = "Heroic Strike >= rage", min = 15, max = 100, default = 60, suffix = "", tooltip = "" },
        { type = "slider", key = "Bloodrage-LimitHP", label = "Bloodrage >= PV", min = 0, max = 100, default = 70, suffix = "%", tooltip = "" },
    } },
}

--------------------------------------------------------------------------
-- [[ OVERLAY "GGL ROTATIONS" ]] — panneau d'options style Magic Rotations
-- /gglui : afficher/masquer | glisser la barre de titre pour deplacer
-- Molette : scroll | Tout est synchronise avec /action et la barre
--------------------------------------------------------------------------
do
    local TMW             = _G.TMW
    local CreateFrame     = _G.CreateFrame
    local UIParent        = _G.UIParent
    local GameTooltip     = _G.GameTooltip
    local GetToggle       = A.GetToggle

    local PANEL_NAME      = "GGLPanel" .. (A.PlayerClass or "X")
    if _G[PANEL_NAME] then return end

    -- Palette (style Magic Rotations)
    local C = {
        bg        = { 0.05, 0.05, 0.07, 0.96 },
        card      = { 0.09, 0.09, 0.13, 0.95 },
        title     = "|cffb16bff",
        section   = { 0.69, 0.42, 1.00 },
        accent    = { 0.55, 0.36, 0.96 },
        accentHi  = { 0.66, 0.47, 1.00 },
        boxOff    = { 0.16, 0.16, 0.22, 1 },
        text      = { 0.92, 0.92, 0.95 },
        textDim   = { 0.55, 0.55, 0.62 },
        track     = { 0.20, 0.20, 0.28, 1 },
    }

    local function GetDB()
        return TMW.db and TMW.db.profile and TMW.db.profile.ActionDB and TMW.db.profile.ActionDB[2]
    end

    local function DBGet(key, default)
        local db = GetDB()
        local v = db and db[key]
        if v == nil then return default end
        return v
    end

    local function DBSet(key, value)
        local db = GetDB()
        if db then db[key] = value end
    end

    -- semis des defauts
    for s = 1, #GGL_PANEL_SECTIONS do
        local items = GGL_PANEL_SECTIONS[s].items
        for it = 1, #items do
            local e = items[it]
            if e.key then
                local db = GetDB()
                if db and db[e.key] == nil then db[e.key] = e.default end
            end
        end
    end

    local WIDTH, HEIGHT, PAD = 400, 560, 10

    local panel = CreateFrame("Frame", PANEL_NAME, UIParent)
    panel:SetWidth(WIDTH)
    panel:SetHeight(HEIGHT)
    panel:SetPoint("CENTER", UIParent, "CENTER", 220, 0)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetFrameStrata("HIGH")
    panel:EnableMouse(true)
    panel:EnableMouseWheel(true)

    local bg = panel:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(panel)
    bg:SetTexture(C.bg[1], C.bg[2], C.bg[3], C.bg[4])

    -- barre de titre
    local titleBar = CreateFrame("Frame", nil, panel)
    titleBar:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(30)
    titleBar:EnableMouse(true)
    local tbg = titleBar:CreateTexture(nil, "BACKGROUND")
    tbg:SetAllPoints(titleBar)
    tbg:SetTexture(0.08, 0.07, 0.12, 1)
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", titleBar, "LEFT", 10, 0)
    titleText:SetText(C.title .. GGL_PANEL_TITLE .. "|r")
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() panel:StartMoving() end)
    titleBar:SetScript("OnDragStop", function()
        panel:StopMovingOrSizing()
        panel:SetUserPlaced(true)
    end)

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetWidth(22)
    closeBtn:SetHeight(22)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -6, 0)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeText:SetText("|cffaaaaaaX|r")
    closeBtn:SetScript("OnClick", function() panel:Hide() end)

    -- zone scrollable
    local scroll = CreateFrame("ScrollFrame", PANEL_NAME .. "Scroll", panel)
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, -34)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 6)
    local content = CreateFrame("Frame", PANEL_NAME .. "Content", scroll)
    content:SetWidth(WIDTH)
    content:SetHeight(1)
    scroll:SetScrollChild(content)

    panel:SetScript("OnMouseWheel", function(self, delta)
        delta = delta or _G.arg1 or 0
        local cur = scroll:GetVerticalScroll() or 0
        local maxScroll = (content:GetHeight() or 0) - (HEIGHT - 40)
        if maxScroll < 0 then maxScroll = 0 end
        local target = cur - delta * 40
        if target < 0 then target = 0 end
        if target > maxScroll then target = maxScroll end
        scroll:SetVerticalScroll(target)
    end)

    local refreshers = {}
    local yOffset = -6

    local function AddTooltip(widget, label, tooltip)
        widget:SetScript("OnEnter", function()
            if not tooltip then return end
            GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")
            GameTooltip:AddLine(label, 0.9, 0.75, 1)
            GameTooltip:AddLine(tooltip, 1, 1, 1, 1)
            GameTooltip:Show()
        end)
        widget:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local function NewCard(height)
        local card = CreateFrame("Frame", nil, content)
        card:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, yOffset)
        card:SetWidth(WIDTH - PAD * 2)
        card:SetHeight(height)
        local cbg = card:CreateTexture(nil, "BACKGROUND")
        cbg:SetAllPoints(card)
        cbg:SetTexture(C.card[1], C.card[2], C.card[3], C.card[4])
        yOffset = yOffset - height - 8
        return card
    end

    local ROW = 24

    for s = 1, #GGL_PANEL_SECTIONS do
        local section = GGL_PANEL_SECTIONS[s]

        -- header de section
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 2, yOffset - 2)
        header:SetText(GGL_ColorHex .. section.title .. "|r")
        yOffset = yOffset - 18

        -- hauteur de la carte
        local h = 8
        for it = 1, #section.items do
            local e = section.items[it]
            h = h + ((e.type == "slider") and (ROW + 6) or ROW)
        end
        local card = NewCard(h)

        local rowY = -6
        for it = 1, #section.items do
            local e = section.items[it]

            if e.type == "check" then
                local box = CreateFrame("Button", nil, card)
                box:SetWidth(16)
                box:SetHeight(16)
                box:SetPoint("TOPLEFT", card, "TOPLEFT", 8, rowY - 3)
                local fill = box:CreateTexture(nil, "ARTWORK")
                fill:SetAllPoints(box)
                local check = box:CreateTexture(nil, "OVERLAY")
                check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                check:SetPoint("CENTER", box, "CENTER", 0, 0)
                check:SetWidth(20)
                check:SetHeight(20)

                local label = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                label:SetPoint("LEFT", box, "RIGHT", 8, 0)
                label:SetText(e.label)

                local function Refresh()
                    if DBGet(e.key, e.default) then
                        fill:SetTexture(C.accent[1], C.accent[2], C.accent[3], 1)
                        check:Show()
                        label:SetTextColor(C.text[1], C.text[2], C.text[3])
                    else
                        fill:SetTexture(C.boxOff[1], C.boxOff[2], C.boxOff[3], 1)
                        check:Hide()
                        label:SetTextColor(C.textDim[1], C.textDim[2], C.textDim[3])
                    end
                end
                box:SetScript("OnClick", function()
                    DBSet(e.key, not DBGet(e.key, e.default))
                    Refresh()
                end)
                AddTooltip(box, e.label, e.tooltip)
                refreshers[#refreshers + 1] = Refresh
                Refresh()
                rowY = rowY - ROW

            elseif e.type == "cycle" then
                local label = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                label:SetPoint("TOPLEFT", card, "TOPLEFT", 8, rowY - 6)
                label:SetText(e.label)

                local chips = {}
                local cx = 150
                for ci = 1, #e.options do
                    local opt = e.options[ci]
                    local chip = CreateFrame("Button", nil, card)
                    chip:SetWidth(opt.width or 52)
                    chip:SetHeight(17)
                    chip:SetPoint("TOPLEFT", card, "TOPLEFT", cx, rowY - 3)
                    cx = cx + (opt.width or 52) + 4
                    local cfill = chip:CreateTexture(nil, "ARTWORK")
                    cfill:SetAllPoints(chip)
                    local ctext = chip:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                    ctext:SetPoint("CENTER", chip, "CENTER", 0, 0)
                    ctext:SetText(opt.text)
                    chip.fill = cfill
                    chip.value = opt.value
                    chip.text = ctext
                    chips[ci] = chip
                    chip:SetScript("OnClick", function()
                        DBSet(e.key, opt.value)
                        for cj = 1, #chips do
                            local other = chips[cj]
                            if other.value == opt.value then
                                other.fill:SetTexture(C.accent[1], C.accent[2], C.accent[3], 1)
                            else
                                other.fill:SetTexture(C.boxOff[1], C.boxOff[2], C.boxOff[3], 1)
                            end
                        end
                    end)
                    AddTooltip(chip, e.label, e.tooltip)
                end
                local function Refresh()
                    local current = DBGet(e.key, e.default)
                    for cj = 1, #chips do
                        local chip = chips[cj]
                        if chip.value == current then
                            chip.fill:SetTexture(C.accent[1], C.accent[2], C.accent[3], 1)
                        else
                            chip.fill:SetTexture(C.boxOff[1], C.boxOff[2], C.boxOff[3], 1)
                        end
                    end
                end
                refreshers[#refreshers + 1] = Refresh
                Refresh()
                rowY = rowY - ROW

            elseif e.type == "slider" then
                local label = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                label:SetPoint("TOPLEFT", card, "TOPLEFT", 8, rowY - 6)
                label:SetText(e.label)

                local valueText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                valueText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, rowY - 6)

                local slider = CreateFrame("Slider", nil, card)
                slider:SetOrientation("HORIZONTAL")
                slider:SetPoint("TOPLEFT", card, "TOPLEFT", 150, rowY - 4)
                slider:SetWidth(WIDTH - PAD * 2 - 150 - 56)
                slider:SetHeight(16)
                slider:SetMinMaxValues(e.min, e.max)
                slider:SetValueStep(e.step or 1)
                local track = slider:CreateTexture(nil, "BACKGROUND")
                track:SetPoint("LEFT", slider, "LEFT", 0, 0)
                track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
                track:SetHeight(4)
                track:SetTexture(C.track[1], C.track[2], C.track[3], 1)
                slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
                slider:EnableMouse(true)

                local updating = false
                local function Refresh()
                    updating = true
                    local v = DBGet(e.key, e.default)
                    if type(v) ~= "number" then v = e.default end
                    slider:SetValue(v)
                    valueText:SetText(GGL_ColorHex .. v .. (e.suffix or "") .. "|r")
                    updating = false
                end
                slider:SetScript("OnValueChanged", function(self, value)
                    if updating then return end
                    value = value or _G.arg1
                    value = math.floor((value or e.default) + 0.5)
                    DBSet(e.key, value)
                    valueText:SetText(GGL_ColorHex .. value .. (e.suffix or "") .. "|r")
                end)
                AddTooltip(slider, e.label, e.tooltip)
                refreshers[#refreshers + 1] = Refresh
                Refresh()
                rowY = rowY - ROW - 6
            end
        end
    end

    content:SetHeight(-yOffset + 12)

    -- resync visuel (barre, /action et macros restent synchronises)
    local elapsedSince = 0
    panel:SetScript("OnUpdate", function(self, elapsed)
        elapsedSince = elapsedSince + (elapsed or _G.arg1 or 0.02)
        if elapsedSince < 0.4 then return end
        elapsedSince = 0
        for r = 1, #refreshers do
            refreshers[r]()
        end
    end)

    panel:Hide()

    _G.SLASH_GGLUI1 = "/gglui"
    _G.SLASH_GGLUI2 = "/ggaa"
    _G.SlashCmdList["GGLUI"] = function()
        if panel:IsShown() then panel:Hide() else panel:Show() end
    end
end
