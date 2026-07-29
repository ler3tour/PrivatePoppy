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
    ZERKERDPS                      = { enUS = "Zerker DPS mode\n(top logs)",
        frFR = "Mode Zerker DPS\n(top logs)" },
    ZERKERDPSTT                    = { enUS = "The playstyle of top-parsing prot warriors when NOT actively tanking (~80% Berserker Stance uptime observed): Devastate/Heroic Strike spam in Berserker Stance, Whirlwind and Berserker Rage on cooldown, Recklessness in burst, Intercept.\nOFF (default): classic Defensive Stance tanking mode.\nMacro: /run Action.SetToggle({2, \"ZerkerDPS\"})",
        frFR = "Le style des guerriers prot top parses quand ils ne tankent PAS activement (~80 % d'uptime Posture berserker observe) : spam Devastation/Coup heroique en Posture berserker, Tourbillon et Rage berserker des que disponibles, Temerite en burst, Interception.\nOFF (defaut) : mode tank classique en Posture defensive.\nMacro : /run Action.SetToggle({2, \"ZerkerDPS\"})" },
    SHIELDBLOCK                    = { enUS = WR.ShieldBlock:Info() .. "\nOn cooldown",
        frFR = WR.ShieldBlock:Info() .. "\nDes que possible" },
    SHIELDBLOCKTT                  = { enUS = "Off-GCD: prevents crushing blows AND generates Revenge procs (blocked hits enable Revenge) — top parses keep it rolling",
        frFR = "Hors GCD : evite les coups ecrasants ET genere des procs Vengeance (les coups bloques activent Vengeance) — les top parses le maintiennent en continu" },
    THUNDERCLAP                    = { enUS = WR.ThunderClap:Info() .. "\nMaintain debuff",
        frFR = WR.ThunderClap:Info() .. "\nMaintenir le debuff" },
    THUNDERCLAPTT                  = { enUS = "Top parses maintain it themselves (~88% uptime observed). Turn OFF only if another warrior applies it",
        frFR = "Les top parses le maintiennent eux-memes (~88 % d'uptime observe). OFF seulement si un autre guerrier l'applique" },
    HASTEPOTION                    = { enUS = WR.HastePotion:Info() .. "\nOn boss (burst)",
        frFR = WR.HastePotion:Info() .. "\nSur boss (burst)" },
    HASTEPOTIONTT                  = { enUS = "Top parses double-pot Haste Potion on boss kills",
        frFR = "Les top parses double-potent la Potion de hate sur les kills de boss" },
    SAPPER                         = { enUS = "Super Sapper Charge\nAoE packs",
        frFR = "Super charge de sapeur\nPacks AoE" },
    SAPPERTT                       = { enUS = "Engineering AoE on 3+ enemies in melee (requires AoE + Burst toggles)",
        frFR = "AoE ingenieur sur 3+ ennemis en melee (necessite les toggles AoE + Burst)" },
    BRDANCE                        = { enUS = WR.BerserkerRage:Info() .. "\nStance dance (rage)",
        frFR = WR.BerserkerRage:Info() .. "\nStance dance (rage)" },
    BRDANCETT                      = { enUS = "Quick Def->Berserker->Def dance for extra rage, only below 10 rage and above 80% HP (seen on top parses). Risky while actively tanking",
        frFR = "Aller-retour eclair Def->Berserker->Def pour de la rage, seulement sous 10 rage et au-dessus de 80 % PV (vu sur les top parses). Risque en tanking actif" },
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
    USE_TRINKET1                   = { enUS = "Trinket 1 (top slot)\nAuto use",
        frFR = "Bijou 1 (slot haut)\nUtilisation auto" },
    USE_TRINKET2                   = { enUS = "Trinket 2 (bottom slot)\nAuto use",
        frFR = "Bijou 2 (slot bas)\nUtilisation auto" },
    USE_TRINKETTT                  = { enUS = "ON: the rotation uses this on-use trinket during the burst window (Burst toggle must be on)\nOFF: you keep manual control\nMacro: /run Action.SetToggle({2, \"UseTrinket1\"}) (or UseTrinket2)",
        frFR = "ON : la rotation utilise ce bijou on-use pendant la fenetre de burst (toggle Burst actif requis)\nOFF : vous gardez le controle manuel\nMacro : /run Action.SetToggle({2, \"UseTrinket1\"}) (ou UseTrinket2)" },
    SHOUT                          = { enUS = "Used shout:",
        frFR = "Cri utilise :" },
    SHOUTTT                        = { enUS = "Commanding Shout: +max health (tank default)\nBattle Shout: attack power (more DPS)",
        frFR = "Cri de commandement : +PV max (defaut tank)\nCri de guerre : puissance d'attaque (plus de DPS)" },
    DEFENSE_HEADER                 = { enUS = "Defense (manual by default)",
        frFR = "Defense (manuel par defaut)" },
    USE_SHIELDWALL                 = { enUS = WR.ShieldWall:Info() .. "\nAuto use",
        frFR = WR.ShieldWall:Info() .. "\nUtilisation auto" },
    USE_SHIELDWALLTT               = { enUS = "OFF (default): you keep full manual control of this cooldown\nON: the rotation fires it below the HP threshold\nMacro toggle: /run Action.SetToggle({2, \"UseShieldWall\"})",
        frFR = "OFF (defaut) : vous gardez le controle manuel total de ce cooldown\nON : la rotation le declenche sous le seuil de PV\nMacro : /run Action.SetToggle({2, \"UseShieldWall\"})" },
    USE_LASTSTAND                  = { enUS = WR.LastStand:Info() .. "\nAuto use",
        frFR = WR.LastStand:Info() .. "\nUtilisation auto" },
    USE_LASTSTANDTT                = { enUS = "OFF (default): you keep full manual control of this cooldown\nON: the rotation fires it below the HP threshold\nMacro toggle: /run Action.SetToggle({2, \"UseLastStand\"})",
        frFR = "OFF (defaut) : vous gardez le controle manuel total de ce cooldown\nON : la rotation le declenche sous le seuil de PV\nMacro : /run Action.SetToggle({2, \"UseLastStand\"})" },
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
        DB            = "ZerkerDPS",
        DBV           = false,
        L             = L.ZERKERDPS,
        TT            = L.ZERKERDPSTT,
        M             = {},
    },
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
        DBV           = true,
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
        DBV           = 40,
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
    {
        E             = "Checkbox",
        DB            = "UseTrinket1",
        DBV           = true,
        L             = L.USE_TRINKET1,
        TT            = L.USE_TRINKETTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseTrinket2",
        DBV           = true,
        L             = L.USE_TRINKET2,
        TT            = L.USE_TRINKETTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Checkbox",
        DB            = "HastePotion",
        DBV           = true,
        L             = L.HASTEPOTION,
        TT            = L.HASTEPOTIONTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "SuperSapperCharge",
        DBV           = false,
        L             = L.SAPPER,
        TT            = L.SAPPERTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "BerserkerRage-Dance",
        DBV           = false,
        L             = L.BRDANCE,
        TT            = L.BRDANCETT,
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
        E             = "Checkbox",
        DB            = "UseShieldWall",
        DBV           = false,
        L             = L.USE_SHIELDWALL,
        TT            = L.USE_SHIELDWALLTT,
        M             = {},
    },
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
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "UseLastStand",
        DBV           = false,
        L             = L.USE_LASTSTAND,
        TT            = L.USE_LASTSTANDTT,
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

--------------------------------------------------------------------------
-- [[ BARRE DE TOGGLES A L'ECRAN ]]
-- Boutons cliquables avec le skin (icone) de chaque sort :
--   - icone en couleur + lisere dore  = AUTO ACTIVE
--   - icone grisee                    = DESACTIVE (controle manuel)
--   - clic gauche : bascule le toggle correspondant
--   - Shift + glisser : deplace la barre (position sauvegardee)
--   - /gglbar : affiche / masque la barre
--------------------------------------------------------------------------
do
    local TMW             = _G.TMW
    local CreateFrame             = _G.CreateFrame
    local UIParent                = _G.UIParent
    local GameTooltip             = _G.GameTooltip
    local GetSpellInfo            = _G.GetSpellInfo
    local GetInventoryItemTexture = _G.GetInventoryItemTexture
    local IsShiftKeyDown          = _G.IsShiftKeyDown
    local GetToggle               = A.GetToggle
    local SetToggle               = A.SetToggle

    -- Toggles exposes sur la barre (ordre d'affichage).
    -- Ajouter/retirer une ligne suffit pour changer la barre.
    -- spell = icone du sort | slot = icone de l'objet equipe (13/14 = trinkets)
    local BUTTONS = {
        { key = "ZerkerDPS",            spell = WR.BerserkerStance,   default = false },
        { key = "ShieldBlock",          spell = WR.ShieldBlock,       default = true  },
        { key = "MaintainThunderClap",  spell = WR.ThunderClap,       default = true  },
        { key = "MaintainDemoShout",    spell = WR.DemoralizingShout, default = false },
        { key = "Interrupt-ShieldBash", spell = WR.ShieldBash,        default = true  },
        { key = "AoE",                  spell = WR.Cleave,            default = false },
        { key = "UseTrinket1",          slot  = 13, label = "Trinket 1", default = true },
        { key = "UseTrinket2",          slot  = 14, label = "Trinket 2", default = true },
        { key = "UseShieldWall",        spell = WR.ShieldWall,        default = false },
        { key = "UseLastStand",         spell = WR.LastStand,         default = false },
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

    local function GetState(entry)
        local value = GetToggle(2, entry.key)
        if value == nil then
            return entry.default
        end
        return value and true or false
    end

    local bar = _G.GGLProtToggleBar
    if not bar then
        bar = CreateFrame("Frame", "GGLProtToggleBar", UIParent)
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
            local btn = CreateFrame("Button", "GGLProtToggleButton" .. i, bar)
            btn:SetWidth(SIZE)
            btn:SetHeight(SIZE)
            btn:SetPoint("LEFT", bar, "LEFT", PAD + (i - 1) * (SIZE + GAP), 0)

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(btn)
            local tex
            if entry.slot then
                tex = GetInventoryItemTexture("player", entry.slot)
            elseif entry.spell then
                local _, _, spellIcon = GetSpellInfo(entry.spell.ID)
                tex = spellIcon
            end
            icon:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- coupe le bord moche
            btn.icon = icon

            -- lisere dore "actif" (le glow des boutons d'action Blizzard)
            local border = btn:CreateTexture(nil, "OVERLAY")
            border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            border:SetBlendMode("ADD")
            border:SetPoint("CENTER", btn, "CENTER", 0, 0)
            border:SetWidth(SIZE * 1.7)
            border:SetHeight(SIZE * 1.7)
            btn.border = border

            btn.entry = entry

            btn:RegisterForDrag("LeftButton")
            btn:SetScript("OnDragStart", StartDrag)
            btn:SetScript("OnDragStop", StopDrag)

            btn:SetScript("OnClick", function()
                local db = GetDB()
                if not db then return end
                local current = db[entry.key]
                if current == nil then
                    current = entry.default
                end
                db[entry.key] = not current
            end)

            btn:SetScript("OnEnter", function()
                GameTooltip:SetOwner(btn, "ANCHOR_TOP")
                GameTooltip:AddLine(entry.label or (entry.spell and entry.spell:Info()) or entry.key)
                if GetState(entry) then
                    GameTooltip:AddLine("AUTO : |cff00ff00ACTIVE|r - clic pour desactiver", 1, 1, 1)
                else
                    GameTooltip:AddLine("AUTO : |cffff2020DESACTIVE|r - clic pour activer", 1, 1, 1)
                end
                GameTooltip:AddLine("Shift + glisser : deplacer la barre", 0.6, 0.6, 0.6)
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            bar.buttons[i] = btn
        end

        -- rafraichissement visuel (suit aussi les changements via /action
        -- ou macros SetToggle)
        local elapsedSince = 0
        bar:SetScript("OnUpdate", function(self, elapsed)
            elapsedSince = elapsedSince + (elapsed or _G.arg1 or 0.02)
            if elapsedSince < 0.2 then return end
            elapsedSince = 0
            SeedDefaults()
            for j = 1, #bar.buttons do
                local b = bar.buttons[j]
                -- icone dynamique des trinkets (suit les swaps d'equipement)
                if b.entry.slot then
                    local t = GetInventoryItemTexture("player", b.entry.slot)
                    if t then
                        b.icon:SetTexture(t)
                    end
                end
                if GetState(b.entry) then
                    b.icon:SetVertexColor(1, 1, 1)
                    b.border:Show()
                else
                    b.icon:SetVertexColor(0.25, 0.25, 0.25)
                    b.border:Hide()
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
local GGL_PANEL_TITLE = "GGL — WARRIOR PROT"
local GGL_PANEL_SECTIONS = {
    { title = "ROTATION", items = {
        { type = "check", key = "ZerkerDPS", label = "Mode Zerker DPS (top logs)", default = false, tooltip = "Berserker Stance quand vous ne tankez pas" },
        { type = "check", key = "ShieldBlock", label = "Shield Block on cooldown", default = true, tooltip = "Anti-crush + procs Revenge" },
        { type = "check", key = "MaintainThunderClap", label = "Thunder Clap (maintien)", default = true, tooltip = "OFF si un autre guerrier l'applique" },
        { type = "check", key = "MaintainDemoShout", label = "Demoralizing Shout (maintien)", default = false, tooltip = "Coute un GCD" },
        { type = "check", key = "Interrupt-ShieldBash", label = "Shield Bash (kick auto)", default = true, tooltip = "" },
        { type = "check", key = "AoE", label = "Mode AoE (Cleave)", default = false, tooltip = "" },
        { type = "check", key = "StopCast", label = "Stop cast HS/Cleave", default = true, tooltip = "" },
    } },
    { title = "BURST", items = {
        { type = "check", key = "UseTrinket1", label = "Trinket 1 (slot haut)", default = true, tooltip = "" },
        { type = "check", key = "UseTrinket2", label = "Trinket 2 (slot bas)", default = true, tooltip = "" },
        { type = "check", key = "HastePotion", label = "Haste Potion (boss)", default = true, tooltip = "" },
        { type = "check", key = "SuperSapperCharge", label = "Super Sapper (AoE 3+)", default = false, tooltip = "Ingenierie requise" },
        { type = "check", key = "MightyRagePotion", label = "Mighty Rage Potion", default = false, tooltip = "Si rage < 25 en burst" },
        { type = "check", key = "BerserkerRage-Dance", label = "Berserker Rage dance (rage)", default = false, tooltip = "Risque en tanking actif" },
    } },
    { title = "REGLAGES", items = {
        { type = "cycle", key = "ShoutToUse", label = "Cri utilise", default = "CommandingShout", options = { { text = "Command.", value = "CommandingShout", width = 64 }, { text = "Battle", value = "BattleShout", width = 48 }, { text = "OFF", value = "OFF", width = 36 } }, tooltip = "Commanding = PV max, Battle = AP" },
        { type = "slider", key = "HeroicStrike-PWR", label = "Heroic Strike >= rage", min = 30, max = 100, default = 40, suffix = "", tooltip = "Seuil de vidange" },
        { type = "slider", key = "Cleave-PWR", label = "Cleave >= rage", min = 20, max = 100, default = 50, suffix = "", tooltip = "" },
        { type = "slider", key = "Bloodrage-LimitHP", label = "Bloodrage >= PV", min = 0, max = 100, default = 35, suffix = "%", tooltip = "" },
    } },
    { title = "DEFENSE (manuel par defaut)", items = {
        { type = "check", key = "UseShieldWall", label = "Shield Wall auto", default = false, tooltip = "OFF = controle manuel" },
        { type = "slider", key = "ShieldWallHP", label = "Shield Wall <= PV", min = 0, max = 100, default = 25, suffix = "%", tooltip = "" },
        { type = "check", key = "UseLastStand", label = "Last Stand auto", default = false, tooltip = "OFF = controle manuel" },
        { type = "slider", key = "LastStandHP", label = "Last Stand <= PV", min = 0, max = 100, default = 35, suffix = "%", tooltip = "" },
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
