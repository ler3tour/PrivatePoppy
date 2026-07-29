--------------------------------------------------------------------------
-- [GGL] Hunter TBC BM - Profile UI CodeSnippet (Order 2)
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
    ARCANETT                       = { enUS = "OFF (default): clips the 1:1 cycle at high haste\nON: woven when the auto shot timer allows (low gear)",
        frFR = "OFF (defaut) : clippe le cycle 1:1 a haute haste\nON : tisse quand le timer d'auto le permet (petit gear)" },
    MULTI                          = { enUS = HU.MultiShot:Info() .. "\nWeave single",
        frFR = HU.MultiShot:Info() .. "\nTisser en mono" },
    MULTITT                        = { enUS = "Multi-Shot always fires in AoE mode (3+ targets)\nON: also woven single-target (low gear '1:1.5' cycle)",
        frFR = "Multi-Shot part toujours en mode AoE (3+ cibles)\nON : aussi tisse en mono-cible (cycle '1:1.5' petit gear)" },
    AOE                            = { enUS = "Use\nAoE",
        frFR = "Utiliser\nAoE" },
    AOETT                          = { enUS = "Enables Multi-Shot on 3+ targets",
        frFR = "Active Multi-Shot sur 3+ cibles" },
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
        DBV           = false,
        L             = L.ARCANE,
        TT            = L.ARCANETT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseMultiShot",
        DBV           = false,
        L             = L.MULTI,
        TT            = L.MULTITT,
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
-- Shift + glisser : deplacer | /gglbar : masquer
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
        { key = "UseArcaneShot",    spell = HU.ArcaneShot,       default = false },
        { key = "UseMultiShot",     spell = HU.MultiShot,        default = false },
        { key = "AoE",              spell = HU.MultiShot,        default = false, tag = "AoE" },
        { key = "AutoViper",        spell = HU.AspectoftheViper, default = true  },
        { key = "AutoMendPet",      spell = HU.MendPet,          default = false },
        { key = "UseTrinket1",      slot  = 13, label = "Trinket 1", default = true },
        { key = "UseTrinket2",      slot  = 14, label = "Trinket 2", default = true },
        { key = "HastePotion",      item  = 22838, label = "Haste Potion", default = true },
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

    local bar = _G.GGLHunterToggleBar
    if not bar then
        bar = CreateFrame("Frame", "GGLHunterToggleBar", UIParent)
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
            local btn = CreateFrame("Button", "GGLHunterToggleButton" .. i, bar)
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
