--------------------------------------------------------------------------
-- [GGL] Rogue TBC Combat - Profile UI CodeSnippet (Order 2)
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
-- Shift + glisser : deplacer | /gglbar : masquer
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

    local bar = _G.GGLRogueToggleBar
    if not bar then
        bar = CreateFrame("Frame", "GGLRogueToggleBar", UIParent)
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
            local btn = CreateFrame("Button", "GGLRogueToggleButton" .. i, bar)
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
