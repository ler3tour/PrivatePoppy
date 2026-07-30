--------------------------------------------------------------------------
-- [Storm] Rogue TBC Combat - Profile UI CodeSnippet (Order 2)
-- Panneau /action + barre de boutons a l'ecran.
--------------------------------------------------------------------------

local A                            = _G.Action
local RO                           = A[A.PlayerClass]
local L                            = {
    KICK                           = { enUS = RO.Kick:Info() .. "\nAuto kick",
        frFR = RO.Kick:Info() .. "\nKick auto" },
    KICKTT                         = { enUS = "Automatically interrupts enemy casts",
        frFR = "Interrompt automatiquement les casts ennemis" },
    ROTATION_HEADER                = { enUS = "Cycle (SnD > Rupture > Eviscerate)",
        frFR = "Cycle (SnD > Rupture > Eviscerate)" },
    RUPTURE                        = { enUS = RO.Rupture:Info() .. "\n5 CP",
        frFR = RO.Rupture:Info() .. "\n5 CP" },
    RUPTURETT                      = { enUS = "5 CP Rupture when Slice and Dice is covered — best damage per energy with raid AP\nOFF: cycle becomes SnD + Eviscerate",
        frFR = "Rupture 5 CP quand Slice and Dice est couvert — meilleurs degats par energie avec l'AP de raid\nOFF : le cycle devient SnD + Eviscerate" },
    EVISCERATE                     = { enUS = RO.Eviscerate:Info() .. "\n5 CP",
        frFR = RO.Eviscerate:Info() .. "\n5 CP" },
    EVISCERATETT                   = { enUS = "5 CP Eviscerate only when SnD AND Rupture are already covered (or target is dying)",
        frFR = "Eviscerate 5 CP seulement quand SnD ET Rupture sont deja couverts (ou cible mourante)" },
    EXPOSEARMOR                    = { enUS = RO.ExposeArmor:Info() .. "\nDouble uptime",
        frFR = RO.ExposeArmor:Info() .. "\nDouble uptime" },
    EXPOSEARMORTT                  = { enUS = "The top-log cycle: 5 CP Expose Armor kept at ~90-99% uptime alongside Slice and Dice (skipped automatically if a warrior maintains Sunder Armor)\nTurn OFF if your raid does not want EA from you",
        frFR = "Le cycle des top logs : Expose Armor 5 CP maintenu a ~90-99 % d'uptime en plus de Slice and Dice (ignore automatiquement si un guerrier maintient Sunder)\nOFF si votre raid ne veut pas votre EA" },
    SAPPERS                        = { enUS = "Sapper Charges\nOn boss (burst)",
        frFR = "Charges de sapeur\nSur boss (burst)" },
    SAPPERSTT                      = { enUS = "Super + Goblin Sapper Charges used even single-target on bosses (top logs). Requires engineering",
        frFR = "Super + Charge de sapeur gobelin utilisees meme en mono-cible sur les boss (top logs). Ingenierie requise" },
    OPENER_GARROTE                 = { enUS = RO.Garrote:Info() .. "\nStealth opener",
        frFR = RO.Garrote:Info() .. "\nOpener en camouflage" },
    OPENER_GARROTETT               = { enUS = "OFF (default, matches top logs): opens with Sinister Strike directly from stealth\nON: opens with Garrote (bleed + 1 CP, delays SnD)",
        frFR = "OFF (defaut, conforme aux top logs) : ouvre directement au Sinister Strike depuis le camouflage\nON : ouvre au Garrote (saignement + 1 CP, retarde SnD)" },
    BACKSTAB                       = { enUS = RO.Backstab:Info() .. "\nDagger builder",
        frFR = RO.Backstab:Info() .. "\nBuilder dague" },
    BACKSTABTT                     = { enUS = "ON: uses Backstab instead of Sinister Strike (dagger main hand, positional!)",
        frFR = "ON : utilise Backstab a la place de Sinister Strike (dague en main droite, positionnel !)" },
    BURST_HEADER                   = { enUS = "Cooldowns & consumables",
        frFR = "Cooldowns & consommables" },
    BLADEFLURRY                    = { enUS = RO.BladeFlurry:Info() .. "\nOn cooldown",
        frFR = RO.BladeFlurry:Info() .. "\nDes que possible" },
    BLADEFLURRYTT                  = { enUS = "+20% attack speed (and cleave) — used on cooldown during burst windows",
        frFR = "+20 % vitesse d'attaque (et cleave) — utilise des que possible dans les fenetres de burst" },
    ADRENALINERUSH                 = { enUS = RO.AdrenalineRush:Info() .. "\nWith Blade Flurry",
        frFR = RO.AdrenalineRush:Info() .. "\nAvec Blade Flurry" },
    ADRENALINERUSHTT               = { enUS = "Paired inside the Blade Flurry window for the stacked haste burst",
        frFR = "Groupe dans la fenetre Blade Flurry pour cumuler la haste" },
    THISTLETEA                     = { enUS = "Thistle Tea\nEnergy < 25",
        frFR = "The aux chardons\nEnergie < 25" },
    THISTLETEATT                   = { enUS = "Restores 100 energy on low-energy dips (off-GCD)",
        frFR = "Rend 100 energies sur les creux (hors GCD)" },
    HASTEPOTION                    = { enUS = RO.HastePotion:Info() .. "\nOn boss (burst)",
        frFR = RO.HastePotion:Info() .. "\nSur boss (burst)" },
    HASTEPOTIONTT                  = { enUS = "Used inside the Adrenaline Rush window on bosses",
        frFR = "Utilisee dans la fenetre Adrenaline Rush sur les boss" },
    USE_TRINKET1                   = { enUS = "Trinket 1 (top slot)\nAuto use",
        frFR = "Bijou 1 (slot haut)\nUtilisation auto" },
    USE_TRINKET2                   = { enUS = "Trinket 2 (bottom slot)\nAuto use",
        frFR = "Bijou 2 (slot bas)\nUtilisation auto" },
    USE_TRINKETTT                  = { enUS = "ON: used during the burst window\nOFF: manual control",
        frFR = "ON : utilise pendant la fenetre de burst\nOFF : controle manuel" },
    CLOAK                          = { enUS = RO.CloakofShadows:Info() .. "\nAuto (<= 35% HP)",
        frFR = RO.CloakofShadows:Info() .. "\nAuto (<= 35 % PV)" },
    CLOAKTT                        = { enUS = "OFF (default): you keep manual control",
        frFR = "OFF (defaut) : vous gardez le controle manuel" },
}

A.Data.ProfileEnabled[A.CurrentProfile]             = true
A.Data.ProfileUI                                    = {
    DateTime = "v1 (27.07.2026)",
    [2]                                             = { LayoutOptions = { gutter = 2, padding = { left = 5, right = 5 } } },
    [7]                                             = {
        ["kick"] = { Enabled = true, Key = "Kick", LUAVER = 1, LUA = [[
                local Obj      = Action[Action.PlayerClass]
                local Temp     = {"TotalImun", "DamagePhysImun", "KickImun"}
                local castLeft, _, _, _, notInterruptAble = Unit(thisunit):IsCastingRemains()
                return  Obj.Kick and
                        Obj.Kick:IsReadyM(thisunit) and
                        Obj.Kick:AbsentImun(thisunit, Temp) and
                        castLeft > 0 and
                        not notInterruptAble
            ]] },
    },
}

local ProfileUI                                     = A.Data.ProfileUI[2]

-- [[ General ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "Interrupt-Kick",
        DBV           = true,
        L             = L.KICK,
        TT            = L.KICKTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseBackstab",
        DBV           = false,
        L             = L.BACKSTAB,
        TT            = L.BACKSTABTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseCloak-Auto",
        DBV           = false,
        L             = L.CLOAK,
        TT            = L.CLOAKTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "Opener-Garrote",
        DBV           = false,
        L             = L.OPENER_GARROTE,
        TT            = L.OPENER_GARROTETT,
        M             = {},
    },
}

-- [[ Cycle ]]
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Header",
        L             = L.ROTATION_HEADER,
    },
}
ProfileUI[#ProfileUI + 1]                           = {
    {
        E             = "Checkbox",
        DB            = "UseRupture",
        DBV           = true,
        L             = L.RUPTURE,
        TT            = L.RUPTURETT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseEviscerate",
        DBV           = true,
        L             = L.EVISCERATE,
        TT            = L.EVISCERATETT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseExposeArmor",
        DBV           = true,
        L             = L.EXPOSEARMOR,
        TT            = L.EXPOSEARMORTT,
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
        DB            = "UseBladeFlurry",
        DBV           = true,
        L             = L.BLADEFLURRY,
        TT            = L.BLADEFLURRYTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseAdrenalineRush",
        DBV           = true,
        L             = L.ADRENALINERUSH,
        TT            = L.ADRENALINERUSHTT,
        M             = {},
    },
    {
        E             = "Checkbox",
        DB            = "UseThistleTea",
        DBV           = true,
        L             = L.THISTLETEA,
        TT            = L.THISTLETEATT,
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
        DB            = "HastePotion",
        DBV           = true,
        L             = L.HASTEPOTION,
        TT            = L.HASTEPOTIONTT,
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

--------------------------------------------------------------------------
-- [[ BARRE DE TOGGLES A L'ECRAN ]]
-- Icone en couleur + lisere = ACTIVE | grisee = OFF | clic = bascule
-- Shift + glisser : deplacer | /stormbar : masquer
--------------------------------------------------------------------------
do
    local TMW             = _G.TMW
    local CreateFrame             = _G.CreateFrame
    local UIParent                = _G.UIParent
    local GameTooltip             = _G.GameTooltip
    local GetSpellInfo            = _G.GetSpellInfo
    local GetItemIcon             = _G.GetItemIcon
    local GetInventoryItemTexture = _G.GetInventoryItemTexture
    local IsShiftKeyDown          = _G.IsShiftKeyDown
    local GetToggle               = A.GetToggle
    local SetToggle               = A.SetToggle

    local BUTTONS = {
        { key = "Interrupt-Kick",    spell = RO.Kick,           default = true  },
        { key = "UseRupture",        spell = RO.Rupture,        default = true  },
        { key = "UseEviscerate",     spell = RO.Eviscerate,     default = true  },
        { key = "UseExposeArmor",    spell = RO.ExposeArmor,    default = true  },
        { key = "UseSappers",        item  = 23827, label = "Sappers",      default = true },
        { key = "UseBladeFlurry",    spell = RO.BladeFlurry,    default = true  },
        { key = "UseAdrenalineRush", spell = RO.AdrenalineRush, default = true  },
        { key = "UseThistleTea",     item  = 7676,  label = "Thistle Tea",  default = true },
        { key = "HastePotion",       item  = 22838, label = "Haste Potion", default = true },
        { key = "UseTrinket1",       slot  = 13, label = "Trinket 1", default = true },
        { key = "UseTrinket2",       slot  = 14, label = "Trinket 2", default = true },
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

    local bar = _G.StormRogueToggleBar
    if not bar then
        bar = CreateFrame("Frame", "StormRogueToggleBar", UIParent)
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
            local btn = CreateFrame("Button", "StormRogueToggleButton" .. i, bar)
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
local GGL_PANEL_TITLE = "STORM — ROGUE COMBAT"
local GGL_PANEL_SECTIONS = {
    { title = "CYCLE (SnD + Expose Armor)", items = {
        { type = "check", key = "UseSnD", label = "Slice and Dice (upkeep)", default = true, tooltip = "LA stat du parse — a ne couper que pour du 100% manuel" },
        { type = "check", key = "UseExposeArmor", label = "Expose Armor (double uptime)", default = true, tooltip = "Le cycle des top logs" },
        { type = "check", key = "UseRupture", label = "Rupture 5 CP", default = true, tooltip = "Seulement quand SnD et EA sont larges" },
        { type = "check", key = "UseEviscerate", label = "Eviscerate 5 CP (dump)", default = true, tooltip = "" },
        { type = "check", key = "Opener-Garrote", label = "Opener Garrote (stealth)", default = false, tooltip = "OFF = Sinister Strike direct (top logs)" },
        { type = "check", key = "UseBackstab", label = "Backstab (build dague)", default = false, tooltip = "Positionnel !" },
    } },
    { title = "COOLDOWNS & CONSOS", items = {
        { type = "check", key = "UseBladeFlurry", label = "Blade Flurry on cooldown", default = true, tooltip = "" },
        { type = "check", key = "UseAdrenalineRush", label = "Adrenaline Rush (avec BF)", default = true, tooltip = "" },
        { type = "check", key = "UseThistleTea", label = "Thistle Tea (energie < 25)", default = true, tooltip = "" },
        { type = "check", key = "HastePotion", label = "Haste Potion (boss)", default = true, tooltip = "" },
        { type = "check", key = "UseSappers", label = "Sappers (boss)", default = true, tooltip = "Ingenierie requise" },
        { type = "check", key = "UseTrinket1", label = "Trinket 1 (slot haut)", default = true, tooltip = "" },
        { type = "check", key = "UseTrinket2", label = "Trinket 2 (slot bas)", default = true, tooltip = "" },
        { type = "check", key = "UseRacials", label = "Racials (Berserking/Blood Fury)", default = true, tooltip = "" },
    } },
    { title = "DIVERS", items = {
        { type = "check", key = "Interrupt-Kick", label = "Kick (auto)", default = true, tooltip = "" },
        { type = "check", key = "UseCloak-Auto", label = "Cloak of Shadows auto (<= 35% PV)", default = false, tooltip = "" },
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
