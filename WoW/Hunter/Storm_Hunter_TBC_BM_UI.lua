--------------------------------------------------------------------------
-- [Storm] Hunter TBC BM - Profile UI CodeSnippet (Order 2)
-- Panneau /action + barre de boutons a l'ecran.
--------------------------------------------------------------------------

local A                            = _G.Action
local HU                           = A[A.PlayerClass]
local L                            = {
    ROTATION_HEADER                = { enUS = "Shot weaving (Auto Shot is sacred)",
        frFR = "Shot weaving (l'Auto Shot est sacre)" },
    SERPENT                        = { enUS = HU.SerpentSting:Info() .. "\nMaintain",
        frFR = HU.SerpentSting:Info() .. "\nMaintenir" },
    SERPENTTT                      = { enUS = "OFF (default): at high gear it clips the 1:1 Auto/Steady cycle and LOSES DPS\nON: maintained on the target (low gear / long fights)",
        frFR = "OFF (defaut) : a haut gear il clippe le cycle 1:1 Auto/Steady et FAIT PERDRE du DPS\nON : maintenu sur la cible (petit gear / combats longs)" },
    ARCANE                         = { enUS = HU.ArcaneShot:Info() .. "\nWeave",
        frFR = HU.ArcaneShot:Info() .. "\nTisser" },
    ARCANETT                       = { enUS = "ON (default, top logs: 5-7.5 CPM): woven when the auto shot timer allows",
        frFR = "ON (defaut, top logs : 5-7,5 CPM) : tisse quand le timer d'auto le permet" },
    RAPTOR                         = { enUS = HU.RaptorStrike:Info() .. "\nMelee weaving",
        frFR = HU.RaptorStrike:Info() .. "\nMelee weaving" },
    RAPTORTT                       = { enUS = "Top logs: 9-33 casts per fight! On big-hitbox bosses, standing at the melee/ranged overlap weaves free Raptor Strikes (on next melee swing, no ranged cost). Only triggers when YOU are in melee range",
        frFR = "Top logs : 9-33 casts par combat ! Sur les boss a grosse hitbox, se placer au chevauchement melee/distance tisse des Raptor Strike gratuits (prochain coup melee, zero cout ranged). Ne se declenche que si VOUS etes a portee melee" },
    FLAMECAP                       = { enUS = "Flame Cap\nOn boss (burst)",
        frFR = "Chapeflamme\nSur boss (burst)" },
    FLAMECAPTT                     = { enUS = "Top logs: ~71% uptime. Own cooldown, does not share with potions",
        frFR = "Top logs : ~71 % d'uptime. Cooldown propre, ne partage pas celui des potions" },
    SAPPERS                        = { enUS = "Super Sapper\nOn boss (burst)",
        frFR = "Super sapeur\nSur boss (burst)" },
    SAPPERSTT                      = { enUS = "Used even single-target on bosses (top logs). Requires engineering",
        frFR = "Utilisee meme en mono-cible sur les boss (top logs). Ingenierie requise" },
    MULTI                          = { enUS = HU.MultiShot:Info() .. "\nWeave single",
        frFR = HU.MultiShot:Info() .. "\nTisser en mono" },
    MULTITT                        = { enUS = "ON (default, top logs: ~4 CPM = on cooldown): woven single-target when the auto timer allows; always fires in AoE mode",
        frFR = "ON (defaut, top logs : ~4 CPM = des que possible) : tisse en mono quand le timer d'auto le permet ; part toujours en mode AoE" },
    AOE                            = { enUS = "Use\nAoE",
        frFR = "Utiliser\nAoE" },
    AOETT                          = { enUS = "Enables Multi-Shot on 3+ targets",
        frFR = "Active Multi-Shot sur 3+ cibles" },
    PETATTACK                      = { enUS = "Pet attack\nAuto",
        frFR = "Attaque du familier\nAuto" },
    PETATTACKTT                    = { enUS = "Sends the pet on your target automatically (35-40% of BM damage!), re-sends after target switches",
        frFR = "Envoie automatiquement le familier sur votre cible (35-40 % du DPS BM !), le renvoie apres un switch de cible" },
    WEAVEBUFFER                    = { enUS = "Weaving\nBuffer (ms)",
        frFR = "Weaving\nMarge (ms)" },
    WEAVEBUFFERTT                  = { enUS = "Safety margin added to the Steady Shot cast fit check before the next Auto Shot\nHigher = safer autos, fewer Steadies. Lower = more Steadies, risk of clipping\nTune with your latency (default 100)",
        frFR = "Marge de securite ajoutee au calcul 'le cast de Steady tient-il avant le prochain Auto Shot'\nPlus haut = autos surs, moins de Steady. Plus bas = plus de Steady, risque de clipping\nA regler selon votre latence (defaut 100)" },
    MARK                           = { enUS = HU.HuntersMark:Info() .. "\nApply if missing",
        frFR = HU.HuntersMark:Info() .. "\nPoser si absent" },
    MARKTT                         = { enUS = "Applies Hunter's Mark when the target lacks it",
        frFR = "Pose la Marque du chasseur si la cible ne l'a pas" },
    BURST_HEADER                   = { enUS = "Cooldowns & consumables",
        frFR = "Cooldowns & consommables" },
    BESTIALWRATH                   = { enUS = HU.BestialWrath:Info() .. "\nOn cooldown",
        frFR = HU.BestialWrath:Info() .. "\nDes que possible" },
    BESTIALWRATHTT                 = { enUS = "The BM cooldown — fired on cooldown in burst windows with Rapid Fire",
        frFR = "LE cooldown BM — utilise des que possible dans les fenetres de burst avec Rapid Fire" },
    RAPIDFIRE                      = { enUS = HU.RapidFire:Info() .. "\nOn cooldown",
        frFR = HU.RapidFire:Info() .. "\nDes que possible" },
    RAPIDFIRETT                    = { enUS = "+40% ranged haste, paired with Bestial Wrath",
        frFR = "+40 % de haste distance, groupe avec Bestial Wrath" },
    HASTEPOTION                    = { enUS = HU.HastePotion:Info() .. "\nOn boss (burst)",
        frFR = HU.HastePotion:Info() .. "\nSur boss (burst)" },
    HASTEPOTIONTT                  = { enUS = "Used inside the Rapid Fire window on bosses",
        frFR = "Utilisee dans la fenetre Rapid Fire sur les boss" },
    USE_TRINKET1                   = { enUS = "Trinket 1 (top slot)\nAuto use",
        frFR = "Bijou 1 (slot haut)\nUtilisation auto" },
    USE_TRINKET2                   = { enUS = "Trinket 2 (bottom slot)\nAuto use",
        frFR = "Bijou 2 (slot bas)\nUtilisation auto" },
    USE_TRINKETTT                  = { enUS = "ON: used during the burst window\nOFF: manual control",
        frFR = "ON : utilise pendant la fenetre de burst\nOFF : controle manuel" },
    PET_HEADER                     = { enUS = "Pet & mana",
        frFR = "Familier & mana" },
    AUTOVIPER                      = { enUS = HU.AspectoftheViper:Info() .. "\nAuto swap",
        frFR = HU.AspectoftheViper:Info() .. "\nBascule auto" },
    AUTOVIPERTT                    = { enUS = "Switches to Viper below the mana threshold, back to Hawk above 60%",
        frFR = "Passe en Vipere sous le seuil de mana, retour Faucon au-dessus de 60 %" },
    VIPERMANA                      = { enUS = HU.AspectoftheViper:Info() .. "\n<= mana (%)",
        frFR = HU.AspectoftheViper:Info() .. "\n<= mana (%)" },
    VIPERMANATT                    = { enUS = "Mana threshold to switch to Viper",
        frFR = "Seuil de mana pour passer en Vipere" },
    MENDPET                        = { enUS = HU.MendPet:Info() .. "\nAuto (channel!)",
        frFR = HU.MendPet:Info() .. "\nAuto (canalisation !)" },
    MENDPETTT                      = { enUS = "OFF (default): 5s channel = big DPS loss, keep it manual\nON: channels when pet drops below the threshold",
        frFR = "OFF (defaut) : canalisation de 5 s = grosse perte de DPS, gardez-le manuel\nON : canalise quand le familier passe sous le seuil" },
    MENDPETHP                      = { enUS = HU.MendPet:Info() .. "\nPet <= health (%)",
        frFR = HU.MendPet:Info() .. "\nFamilier <= sante (%)" },
    FEIGN                          = { enUS = HU.FeignDeath:Info() .. "\nAuto (high threat)",
        frFR = HU.FeignDeath:Info() .. "\nAuto (aggro haute)" },
    FEIGNTT                        = { enUS = "OFF (default): manual control",
        frFR = "OFF (defaut) : controle manuel" },
}

A.Data.ProfileEnabled[A.CurrentProfile]             = true
A.Data.ProfileUI                                    = {
    DateTime = "v1 (27.07.2026)",
    [2]                                             = { LayoutOptions = { gutter = 2, padding = { left = 5, right = 5 } } },
    [7]                                             = {},
}

local ProfileUI                                     = A.Data.ProfileUI[2]

-- [[ Shot weaving ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.ROTATION_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "UseSerpentSting",
        DBV           = false,
        L             = L.SERPENT,
        TT            = L.SERPENTTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseArcaneShot",
        DBV           = true,
        L             = L.ARCANE,
        TT            = L.ARCANETT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseMultiShot",
        DBV           = true,
        L             = L.MULTI,
        TT            = L.MULTITT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseRaptorStrike",
        DBV           = true,
        L             = L.RAPTOR,
        TT            = L.RAPTORTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
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
        DB            = "UseHuntersMark",
        DBV           = true,
        L             = L.MARK,
        TT            = L.MARKTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "AutoPetAttack",
        DBV           = true,
        L             = L.PETATTACK,
        TT            = L.PETATTACKTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 50,
        MAX           = 300,
        DB            = "WeaveBuffer",
        DBV           = 100,
        L             = L.WEAVEBUFFER,
        TT            = L.WEAVEBUFFERTT,
        M             = {},
    },
}

-- [[ Cooldowns ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.BURST_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "UseBestialWrath",
        DBV           = true,
        L             = L.BESTIALWRATH,
        TT            = L.BESTIALWRATHTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseRapidFire",
        DBV           = true,
        L             = L.RAPIDFIRE,
        TT            = L.RAPIDFIRETT,
        M             = {},
    },
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
        DB            = "FlameCap",
        DBV           = true,
        L             = L.FLAMECAP,
        TT            = L.FLAMECAPTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseSappers",
        DBV           = true,
        L             = L.SAPPERS,
        TT            = L.SAPPERSTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
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

-- [[ Pet & mana ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.PET_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "AutoViper",
        DBV           = true,
        L             = L.AUTOVIPER,
        TT            = L.AUTOVIPERTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 0,
        MAX           = 40,
        DB            = "ViperMana",
        DBV           = 10,
        L             = L.VIPERMANA,
        TT            = L.VIPERMANATT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "AutoFeignDeath",
        DBV           = false,
        L             = L.FEIGN,
        TT            = L.FEIGNTT,
        M             = {},
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    RowOptions = { margin = { top = 5 } },
    {
        E             = "Checkbox",
        DB            = "AutoMendPet",
        DBV           = false,
        L             = L.MENDPET,
        TT            = L.MENDPETTT,
        M             = {},
    },
    {
        E             = "Slider",
        MIN           = 10,
        MAX           = 80,
        DB            = "MendPetHP",
        DBV           = 35,
        L             = L.MENDPETHP,
        TT            = L.MENDPETTT,
        M             = {},
    },
}

--------------------------------------------------------------------------
-- [[ BARRE DE TOGGLES A L'ECRAN ]]
-- Icone en couleur + lisere = ACTIVE | grisee = OFF | clic = bascule
-- Shift + glisser : deplacer | /stormbar : masquer
--------------------------------------------------------------------------
do
    local TMW                     = _G.TMW
    local CreateFrame             = _G.CreateFrame
    local UIParent                = _G.UIParent
    local GameTooltip             = _G.GameTooltip
    local GetSpellInfo            = _G.GetSpellInfo
    local GetItemIcon             = _G.GetItemIcon
    local GetInventoryItemTexture = _G.GetInventoryItemTexture
    local IsShiftKeyDown          = _G.IsShiftKeyDown
    local GetToggle               = A.GetToggle

    local BUTTONS = {
        { key = "UseBestialWrath",  spell = HU.BestialWrath,     default = true  },
        { key = "UseRapidFire",     spell = HU.RapidFire,        default = true  },
        { key = "UseSerpentSting",  spell = HU.SerpentSting,     default = false },
        { key = "UseRaptorStrike",  spell = HU.RaptorStrike,     default = true  },
        { key = "UseArcaneShot",    spell = HU.ArcaneShot,       default = true  },
        { key = "UseMultiShot",     spell = HU.MultiShot,        default = true  },
        { key = "AoE",              spell = HU.MultiShot,        default = false, tag = "AoE" },
        { key = "AutoViper",        spell = HU.AspectoftheViper, default = true  },
        { key = "AutoMendPet",      spell = HU.MendPet,          default = false },
        { key = "UseTrinket1",      slot  = 13, label = "Trinket 1", default = true },
        { key = "UseTrinket2",      slot  = 14, label = "Trinket 2", default = true },
        { key = "HastePotion",      item  = 22838, label = "Haste Potion", default = true },
        { key = "FlameCap",         item  = 22788, label = "Flame Cap",    default = true },
    }

    -- Acces direct a la base de reglages (Action.SetToggle refuse les
    -- cles pas encore initialisees) — semis des defauts + ecriture directe
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

    local bar = _G.StormHunterToggleBar
    if not bar then
        bar = CreateFrame("Frame", "StormHunterToggleBar", UIParent)
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
            local btn = CreateFrame("Button", "StormHunterToggleButton" .. i, bar)
            btn:SetWidth(SIZE)
            btn:SetHeight(SIZE)
            btn:SetPoint("LEFT", bar, "LEFT", PAD + (i - 1) * (SIZE + GAP), 0)

            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(btn)
            local tex
            if entry.slot then
                tex = GetInventoryItemTexture("player", entry.slot)
            elseif entry.item and GetItemIcon then
                tex = GetItemIcon(entry.item)
            elseif entry.spell then
                local _, _, spellIcon = GetSpellInfo(entry.spell.ID)
                tex = spellIcon
            end
            icon:SetTexture(tex or "Interface\\Icons\\INV_Misc_QuestionMark")
            icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            btn.icon = icon

            local border = btn:CreateTexture(nil, "OVERLAY")
            border:SetTexture("Interface\\Buttons\\UI-ActionButton-Border")
            border:SetBlendMode("ADD")
            border:SetPoint("CENTER", btn, "CENTER", 0, 0)
            border:SetWidth(SIZE * 1.7)
            border:SetHeight(SIZE * 1.7)
            btn.border = border

            if entry.tag then
                local tagText = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                tagText:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -1, -1)
                tagText:SetText(entry.tag)
            end

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

        _G.SLASH_STORMBAR1 = "/stormbar"
        _G.SlashCmdList["STORMBAR"] = function()
            if bar:IsShown() then
                bar:Hide()
            else
                bar:Show()
            end
        end
    end
end


-- Configuration du panneau overlay
local GGL_ColorHex = "|cffe8c15c"
local GGL_PANEL_TITLE = "STORM — HUNTER BM"
local GGL_PANEL_SECTIONS = {
    { title = "SHOT WEAVING (Auto Shot sacre)", items = {
        { type = "check", key = "UseSteadyShot", label = "Steady Shot (weaving)", default = true, tooltip = "Le filler du cycle 1:1" },
        { type = "check", key = "UseKillCommand", label = "Kill Command (sur proc)", default = true, tooltip = "" },
        { type = "check", key = "UseArcaneShot", label = "Arcane Shot (tisse)", default = true, tooltip = "Top logs : 5-7.5 CPM" },
        { type = "check", key = "UseMultiShot", label = "Multi-Shot (tisse en mono)", default = true, tooltip = "Top logs : ~4 CPM" },
        { type = "check", key = "UseRaptorStrike", label = "Raptor Strike (melee weaving)", default = true, tooltip = "Boss a grosse hitbox uniquement" },
        { type = "check", key = "UseSerpentSting", label = "Serpent Sting (maintien)", default = false, tooltip = "Top logs : 1 cast max" },
        { type = "check", key = "AoE", label = "Mode AoE (Multi 3+)", default = false, tooltip = "" },
        { type = "slider", key = "WeaveBuffer", label = "Marge de weaving", min = 50, max = 300, default = 100, suffix = "ms", tooltip = "A regler selon votre latence" },
    } },
    { title = "BURST", items = {
        { type = "check", key = "UseBestialWrath", label = "Bestial Wrath on cooldown", default = true, tooltip = "" },
        { type = "check", key = "UseRapidFire", label = "Rapid Fire (avec BW)", default = true, tooltip = "" },
        { type = "check", key = "HastePotion", label = "Haste Potion (boss)", default = true, tooltip = "" },
        { type = "check", key = "FlameCap", label = "Flame Cap (boss)", default = true, tooltip = "Top logs : ~71% uptime" },
        { type = "check", key = "UseSappers", label = "Super Sapper (boss)", default = true, tooltip = "Ingenierie requise" },
        { type = "check", key = "UseTrinket1", label = "Trinket 1 (slot haut)", default = true, tooltip = "" },
        { type = "check", key = "UseTrinket2", label = "Trinket 2 (slot bas)", default = true, tooltip = "" },
        { type = "check", key = "UseRacials", label = "Racials (Berserking/Blood Fury)", default = true, tooltip = "" },
    } },
    { title = "FAMILIER & MANA", items = {
        { type = "check", key = "AutoPetAttack", label = "Pet attack auto", default = true, tooltip = "35-40% du DPS BM" },
        { type = "check", key = "AutoViper", label = "Aspect Vipere auto", default = true, tooltip = "" },
        { type = "slider", key = "ViperMana", label = "Vipere si mana <=", min = 0, max = 40, default = 10, suffix = "%", tooltip = "" },
        { type = "check", key = "AutoMendPet", label = "Mend Pet auto (canalisation !)", default = false, tooltip = "" },
        { type = "slider", key = "MendPetHP", label = "Mend Pet si pet <=", min = 10, max = 80, default = 35, suffix = "%", tooltip = "" },
        { type = "check", key = "AutoFeignDeath", label = "Feign Death auto (aggro)", default = false, tooltip = "" },
        { type = "check", key = "UseHuntersMark", label = "Hunter's Mark si absente", default = true, tooltip = "" },
    } },
}

--------------------------------------------------------------------------
-- [[ OVERLAY "STORM ROTATIONS" ]] v2 — design Rome antique
-- Marbre sombre + bordures or (opaque, lisible), bouton minimap.
-- /storm ou /ggaa : afficher/masquer | glisser la barre de titre
-- Molette : scroll | Synchronise avec /action, la barre et les macros
--------------------------------------------------------------------------
do
    local TMW             = _G.TMW
    local CreateFrame     = _G.CreateFrame
    local UIParent        = _G.UIParent
    local Minimap         = _G.Minimap
    local GameTooltip     = _G.GameTooltip
    local GetToggle       = A.GetToggle
    local math            = _G.math

    local PANEL_NAME      = "StormPanel" .. (A.PlayerClass or "X")
    if _G[PANEL_NAME] then return end

    -- Palette "Rome antique" : marbre sombre, or, bronze, ivoire
    local C = {
        marble    = { 0.30, 0.24, 0.16, 1.0 },  -- teinte du marbre (opaque)
        card      = { 0.07, 0.055, 0.035, 0.92 },
        gold      = { 0.95, 0.78, 0.25 },
        goldHex   = "|cffe8c15c",
        accent    = { 0.93, 0.75, 0.22 },       -- remplissage ON
        boxOff    = { 0.22, 0.17, 0.10, 1 },
        text      = { 0.95, 0.91, 0.80 },       -- ivoire
        textDim   = { 0.62, 0.55, 0.42 },
        track     = { 0.38, 0.29, 0.16, 1 },
        red       = { 0.75, 0.15, 0.10 },
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

    local WIDTH, HEIGHT, PAD = 410, 570, 14

    local panel = CreateFrame("Frame", PANEL_NAME, UIParent)
    panel:SetWidth(WIDTH)
    panel:SetHeight(HEIGHT)
    panel:SetPoint("CENTER", UIParent, "CENTER", 220, 0)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    panel:SetFrameStrata("HIGH")
    panel:EnableMouse(true)
    panel:EnableMouseWheel(true)

    -- Marbre sombre tuile + bordure doree (textures du client : OPAQUE)
    panel:SetBackdrop({
        bgFile   = "Interface\\FrameGeneral\\UI-Background-Marble",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
        tile = true, tileSize = 256, edgeSize = 26,
        insets = { left = 7, right = 7, top = 7, bottom = 7 },
    })
    panel:SetBackdropColor(C.marble[1], C.marble[2], C.marble[3], C.marble[4])
    panel:SetBackdropBorderColor(1, 0.92, 0.65, 1)

    -- voile sombre interieur pour le contraste du texte
    local shade = panel:CreateTexture(nil, "BORDER")
    shade:SetPoint("TOPLEFT", panel, "TOPLEFT", 7, -7)
    shade:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -7, 7)
    shade:SetTexture(0, 0, 0, 0.55)

    -- barre de titre
    local titleBar = CreateFrame("Frame", nil, panel)
    titleBar:SetPoint("TOPLEFT", panel, "TOPLEFT", 7, -7)
    titleBar:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -7, -7)
    titleBar:SetHeight(32)
    titleBar:EnableMouse(true)
    local titleText = titleBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    titleText:SetText(C.goldHex .. "—  " .. GGL_PANEL_TITLE .. "  —|r")
    local titleLine = titleBar:CreateTexture(nil, "OVERLAY")
    titleLine:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 6, 0)
    titleLine:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", -6, 0)
    titleLine:SetHeight(1)
    titleLine:SetTexture(C.gold[1], C.gold[2], C.gold[3], 0.7)
    titleBar:RegisterForDrag("LeftButton")
    titleBar:SetScript("OnDragStart", function() panel:StartMoving() end)
    titleBar:SetScript("OnDragStop", function()
        panel:StopMovingOrSizing()
        panel:SetUserPlaced(true)
    end)

    local closeBtn = CreateFrame("Button", nil, titleBar)
    closeBtn:SetWidth(22)
    closeBtn:SetHeight(22)
    closeBtn:SetPoint("RIGHT", titleBar, "RIGHT", -2, 0)
    local closeText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    closeText:SetPoint("CENTER", closeBtn, "CENTER", 0, 0)
    closeText:SetText("|cffbf261aX|r")
    closeBtn:SetScript("OnClick", function() panel:Hide() end)

    -- zone scrollable
    local scroll = CreateFrame("ScrollFrame", PANEL_NAME .. "Scroll", panel)
    scroll:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -42)
    scroll:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -8, 10)
    local content = CreateFrame("Frame", PANEL_NAME .. "Content", scroll)
    content:SetWidth(WIDTH - 16)
    content:SetHeight(1)
    scroll:SetScrollChild(content)

    panel:SetScript("OnMouseWheel", function(self, delta)
        delta = delta or _G.arg1 or 0
        local cur = scroll:GetVerticalScroll() or 0
        local maxScroll = (content:GetHeight() or 0) - (HEIGHT - 55)
        if maxScroll < 0 then maxScroll = 0 end
        local target = cur - delta * 40
        if target < 0 then target = 0 end
        if target > maxScroll then target = maxScroll end
        scroll:SetVerticalScroll(target)
    end)

    local refreshers = {}
    local yOffset = -4

    local function AddTooltip(widget, label, tooltip)
        widget:SetScript("OnEnter", function()
            if not tooltip or tooltip == "" then return end
            GameTooltip:SetOwner(widget, "ANCHOR_RIGHT")
            GameTooltip:AddLine(label, C.gold[1], C.gold[2], C.gold[3])
            GameTooltip:AddLine(tooltip, 1, 1, 1, 1)
            GameTooltip:Show()
        end)
        widget:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local function NewCard(height)
        local card = CreateFrame("Frame", nil, content)
        card:SetPoint("TOPLEFT", content, "TOPLEFT", PAD, yOffset)
        card:SetWidth(WIDTH - 16 - PAD * 2)
        card:SetHeight(height)
        local cbg = card:CreateTexture(nil, "BACKGROUND")
        cbg:SetAllPoints(card)
        cbg:SetTexture(C.card[1], C.card[2], C.card[3], C.card[4])
        -- filet dore a gauche (colonne romaine)
        local pillar = card:CreateTexture(nil, "BORDER")
        pillar:SetPoint("TOPLEFT", card, "TOPLEFT", 0, 0)
        pillar:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT", 0, 0)
        pillar:SetWidth(2)
        pillar:SetTexture(C.gold[1], C.gold[2], C.gold[3], 0.55)
        yOffset = yOffset - height - 10
        return card
    end

    local ROW = 24

    for s = 1, #GGL_PANEL_SECTIONS do
        local section = GGL_PANEL_SECTIONS[s]

        local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", PAD + 2, yOffset - 2)
        header:SetText(C.goldHex .. section.title .. "|r")
        yOffset = yOffset - 18

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
                box:SetPoint("TOPLEFT", card, "TOPLEFT", 10, rowY - 3)
                local fill = box:CreateTexture(nil, "ARTWORK")
                fill:SetAllPoints(box)
                local check = box:CreateTexture(nil, "OVERLAY")
                check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
                check:SetPoint("CENTER", box, "CENTER", 0, 0)
                check:SetWidth(20)
                check:SetHeight(20)
                check:SetVertexColor(0.25, 0.13, 0.02)

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
                label:SetPoint("TOPLEFT", card, "TOPLEFT", 10, rowY - 6)
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
                label:SetPoint("TOPLEFT", card, "TOPLEFT", 10, rowY - 6)
                label:SetText(e.label)

                local valueText = card:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
                valueText:SetPoint("TOPRIGHT", card, "TOPRIGHT", -10, rowY - 6)

                local slider = CreateFrame("Slider", nil, card)
                slider:SetOrientation("HORIZONTAL")
                slider:SetPoint("TOPLEFT", card, "TOPLEFT", 150, rowY - 4)
                slider:SetWidth(WIDTH - 16 - PAD * 2 - 150 - 58)
                slider:SetHeight(16)
                slider:SetMinMaxValues(e.min, e.max)
                slider:SetValueStep(e.step or 1)
                local track = slider:CreateTexture(nil, "BACKGROUND")
                track:SetPoint("LEFT", slider, "LEFT", 0, 0)
                track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
                track:SetHeight(4)
                track:SetTexture(C.track[1], C.track[2], C.track[3], C.track[4])
                slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
                slider:EnableMouse(true)

                local updating = false
                local function Refresh()
                    updating = true
                    local v = DBGet(e.key, e.default)
                    if type(v) ~= "number" then v = e.default end
                    slider:SetValue(v)
                    valueText:SetText(C.goldHex .. v .. (e.suffix or "") .. "|r")
                    updating = false
                end
                slider:SetScript("OnValueChanged", function(self, value)
                    if updating then return end
                    value = value or _G.arg1
                    value = math.floor((value or e.default) + 0.5)
                    DBSet(e.key, value)
                    valueText:SetText(C.goldHex .. value .. (e.suffix or "") .. "|r")
                end)
                AddTooltip(slider, e.label, e.tooltip)
                refreshers[#refreshers + 1] = Refresh
                Refresh()
                rowY = rowY - ROW - 6
            end
        end
    end

    content:SetHeight(-yOffset + 12)

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

    ----------------------------------------------------------------------
    -- Bouton minimap : clic = panneau, glisser = repositionner
    ----------------------------------------------------------------------
    if Minimap then
        local mmBtn = CreateFrame("Button", PANEL_NAME .. "MinimapButton", Minimap)
        mmBtn:SetWidth(32)
        mmBtn:SetHeight(32)
        mmBtn:SetFrameStrata("MEDIUM")
        mmBtn:SetFrameLevel(8)

        local mmIcon = mmBtn:CreateTexture(nil, "BACKGROUND")
        mmIcon:SetTexture("Interface\\Icons\\INV_Shield_06")
        mmIcon:SetWidth(20)
        mmIcon:SetHeight(20)
        mmIcon:SetPoint("CENTER", mmBtn, "CENTER", 0, 1)
        mmIcon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

        local mmBorder = mmBtn:CreateTexture(nil, "OVERLAY")
        mmBorder:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        mmBorder:SetWidth(54)
        mmBorder:SetHeight(54)
        mmBorder:SetPoint("TOPLEFT", mmBtn, "TOPLEFT", 0, 0)

        mmBtn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

        local function UpdatePosition()
            local angle = DBGet("Storm-MinimapPos", 210)
            if type(angle) ~= "number" then angle = 210 end
            local rad = math.rad(angle)
            mmBtn:SetPoint("CENTER", Minimap, "CENTER", 80 * math.cos(rad), 80 * math.sin(rad))
        end
        UpdatePosition()

        mmBtn:RegisterForDrag("LeftButton")
        mmBtn:SetScript("OnDragStart", function() mmBtn.dragging = true end)
        mmBtn:SetScript("OnDragStop", function() mmBtn.dragging = false end)
        mmBtn:SetScript("OnUpdate", function()
            if not mmBtn.dragging then return end
            local mx, my = Minimap:GetCenter()
            local cx, cy = _G.GetCursorPosition()
            local scale = Minimap:GetEffectiveScale()
            cx = cx / scale
            cy = cy / scale
            local angle = math.deg(math.atan2(cy - my, cx - mx))
            DBSet("Storm-MinimapPos", angle)
            UpdatePosition()
        end)
        mmBtn:SetScript("OnClick", function()
            if panel:IsShown() then panel:Hide() else panel:Show() end
        end)
        mmBtn:SetScript("OnEnter", function()
            GameTooltip:SetOwner(mmBtn, "ANCHOR_LEFT")
            GameTooltip:AddLine(GGL_PANEL_TITLE, C.gold[1], C.gold[2], C.gold[3])
            GameTooltip:AddLine("Clic : options  |  Glisser : deplacer", 1, 1, 1)
            GameTooltip:Show()
        end)
        mmBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    _G.SLASH_STORMUI1 = "/storm"
    _G.SLASH_STORMUI2 = "/ggaa"
    _G.SlashCmdList["STORMUI"] = function()
        if panel:IsShown() then panel:Hide() else panel:Show() end
    end
end
