--------------------------------------------------------------------------
-- [GGL] Rogue TBC Combat - Rotation CodeSnippet (Order 1)
--
-- Rogue Combat epees 20/41/0 oriente parse (PvE raid) :
--
--   1. Slice and Dice ~100 % d'uptime (LA stat des top parses) —
--      refresh a n'importe quel nombre de CP quand il tombe
--   2. Rupture 5 CP quand SnD est couvert (meilleur DPE avec de l'AP)
--   3. Eviscerate 5 CP seulement quand SnD ET Rupture sont couverts
--   4. Sinister Strike en builder avec POOLING d'energie : jamais de
--      SnD qui tombe faute d'energie, jamais d'energie qui cap
--   5. Blade Flurry + Adrenaline Rush groupes dans la fenetre de burst,
--      Thistle Tea sur les creux d'energie, Haste Potion sur boss
--
-- Toggles UI : Rupture, Eviscerate, Expose Armor (si assigne),
-- Blade Flurry, Adrenaline Rush, Thistle Tea, potions, trinkets, Kick.
-- Macro : /run Action.SetToggle({2, "UseRupture"}) etc.
--------------------------------------------------------------------------

local _G, setmetatable, ipairs                       = _G, setmetatable, ipairs

local GetSpellInfo                                   = _G.GetSpellInfo

local TMW                                            = _G.TMW
local Action                                         = _G.Action
local CONST                                          = Action.Const
local Create                                         = Action.Create
local GetToggle                                      = Action.GetToggle
local GetGCD                                         = Action.GetGCD
local GetCurrentGCD                                  = Action.GetCurrentGCD
local GetPing                                        = Action.GetPing
local BurstIsON                                      = Action.BurstIsON
local IsUnitEnemy                                    = Action.IsUnitEnemy
local Unit                                           = Action.Unit
local Player                                         = Action.Player

local ACTION_CONST_AUTOTARGET                        = CONST.AUTOTARGET

--------------------------------------------------------------------------
-- [[ SPELLS - TBC IDs ]]
--------------------------------------------------------------------------
Action[Action.PlayerClass] = {
    -- Racials
    BloodFury                 = Create({ Type = "Spell", ID = 20572                                            }),
    Berserking                = Create({ Type = "Spell", ID = 20554                                            }),
    -- Core Combat
    SinisterStrike            = Create({ Type = "Spell", ID = 1752,  useMaxRank = true                         }),
    Backstab                  = Create({ Type = "Spell", ID = 53,    useMaxRank = true                         }), -- fallback dague
    SliceandDice              = Create({ Type = "Spell", ID = 5171,  useMaxRank = true, isCP = true            }),
    Rupture                   = Create({ Type = "Spell", ID = 1943,  useMaxRank = true, isCP = true            }),
    Eviscerate                = Create({ Type = "Spell", ID = 2098,  useMaxRank = true, isCP = true            }),
    ExposeArmor               = Create({ Type = "Spell", ID = 8647,  useMaxRank = true, isCP = true            }),
    -- Cooldowns
    BladeFlurry               = Create({ Type = "Spell", ID = 13877, isTalent = true                           }),
    AdrenalineRush            = Create({ Type = "Spell", ID = 13750, isTalent = true                           }),
    -- Utilitaire
    Kick                      = Create({ Type = "Spell", ID = 1766,  useMaxRank = true                         }),
    Feint                     = Create({ Type = "Spell", ID = 1966,  useMaxRank = true                         }),
    Vanish                    = Create({ Type = "Spell", ID = 1856,  useMaxRank = true                         }),
    Sprint                    = Create({ Type = "Spell", ID = 2983,  useMaxRank = true                         }),
    Evasion                   = Create({ Type = "Spell", ID = 5277,  useMaxRank = true                         }),
    CloakofShadows            = Create({ Type = "Spell", ID = 31224                                            }), -- TBC only
    Stealth                   = Create({ Type = "Spell", ID = 1784,  useMaxRank = true                         }),
    Garrote                   = Create({ Type = "Spell", ID = 703,   useMaxRank = true                         }),
    -- Consumables (usage releve top logs : sappers meme en mono-cible)
    ThistleTea                = Create({ Type = "Item",   ID = 7676                                            }),
    HastePotion               = Create({ Type = "Potion", ID = 22838                                           }),
    SuperSapperCharge         = Create({ Type = "Item",   ID = 23827                                           }),
    GoblinSapperCharge        = Create({ Type = "Item",   ID = 10646                                           }),
    -- Hidden (talents trackes)
    ImprovedSliceandDice      = Create({ Type = "Spell", ID = 14165, Hidden = true, isTalent = true, useMaxRank = true }),
    ImprovedSinisterStrike    = Create({ Type = "Spell", ID = 13732, Hidden = true, isTalent = true, useMaxRank = true }),
    Ruthlessness              = Create({ Type = "Spell", ID = 14156, Hidden = true, isTalent = true, useMaxRank = true }),
}

local A = setmetatable(Action[Action.PlayerClass], { __index = Action })

--------------------------------------------------------------------------
-- [[ CONDITIONS ]]
--------------------------------------------------------------------------
local Temp = {
    AttackTypes               = { "TotalImun", "DamagePhysImun" },
    AuraForKick               = { "TotalImun", "DamagePhysImun", "KickImun" },
    -- Tables de TOUS les rangs (le rang applique est le rang max)
    AuraSliceandDice          = { 5171, 6774 },
    AuraRupture               = { 1943, 8639, 8640, 11273, 11274, 11275, 26867 },
    AuraExposeArmor           = { 8647, 8649, 8650, 11197, 11198, 26866 },
    AuraSunderArmor           = { 7386, 7405, 8380, 11596, 11597, 25225 },
    -- Duree de base de SnD par CP (avant Improved SnD)
    SnDDurationByCP           = { [1] = 9, [2] = 12, [3] = 15, [4] = 18, [5] = 21 },
}

local function InMelee(unitID)
    return A.SinisterStrike:IsInRange(unitID)
end

local function ToggleOr(key, default)
    local value = GetToggle(2, key)
    if value == nil then
        return default
    end
    return value
end

-- Builder selon l'arme (Sinister Strike epees/masses, Backstab dagues)
local function GetBuilder()
    if ToggleOr("UseBackstab", false) then
        return A.Backstab
    end
    return A.SinisterStrike
end

--------------------------------------------------------------------------
-- [[ ROTATION : META 3 (Combat parse) ]]
--------------------------------------------------------------------------
A[3] = function(icon)
    local combatTime                      = Unit("player"):CombatTime()
    local inCombat                        = combatTime > 0
    local energy                          = Player:Energy()
    local comboPoints                     = Player:ComboPoints()
    local isStealthed                     = Unit("player"):HasBuffs(A.Stealth.ID, true) > 0
    local isTarget, isTargetInMelee

    if IsUnitEnemy("target") then
        isTarget                          = "target"
        isTargetInMelee                   = InMelee(isTarget)
    end

    -- En camouflage : opener des top logs = Sinister Strike direct
    -- (pas de Garrote/Cheap Shot dans leurs casts — CS inutile sur boss,
    -- Garrote retarde SnD). Toggle Garrote pour ceux qui y tiennent
    if isStealthed then
        if isTarget and isTargetInMelee then
            if ToggleOr("Opener-Garrote", false) and A.Garrote:IsReady(isTarget) and energy >= A.Garrote:GetSpellPowerCostCache() and A.Garrote:AbsentImun(isTarget, Temp.AttackTypes) then
                return A.Garrote:Show(icon)
            end

            local opener = GetBuilder()
            if opener:IsReady(isTarget) and energy >= opener:GetSpellPowerCostCache() and opener:AbsentImun(isTarget, Temp.AttackTypes) then
                return opener:Show(icon)
            end
        end
        return -- nil
    end

    -- Return : pas de cible
    if not isTarget then
        if inCombat and ToggleOr("AutoTarget", true) then
            return A:Show(icon, ACTION_CONST_AUTOTARGET)
        end
        return -- nil
    end

    -- [[ KICK ]]
    if ToggleOr("Interrupt-Kick", true) and isTargetInMelee then
        local castLeft, _, _, _, notInterruptAble = Unit(isTarget):IsCastingRemains()
        if castLeft and castLeft > GetPing() + 0.1 and not notInterruptAble and A.Kick:IsReady(isTarget) and energy >= A.Kick:GetSpellPowerCostCache() and A.Kick:AbsentImun(isTarget, Temp.AuraForKick) then
            return A.Kick:Show(icon)
        end
    end

    -- Return : rien a faire hors melee
    if not isTargetInMelee then
        return -- nil
    end

    local buffSnD = Unit("player"):HasBuffs(Temp.AuraSliceandDice, true)

    -- [[ BURST ]] : Blade Flurry + Adrenaline Rush groupes
    if inCombat and BurstIsON(isTarget) and A.AbsentImun(nil, isTarget, Temp.AttackTypes) and buffSnD > 0 then
        -- BladeFlurry : +20 % haste (et cleave), on cooldown
        if ToggleOr("UseBladeFlurry", true) and A.BladeFlurry:IsReady("player") and energy >= 25 then
            return A.BladeFlurry:Show(icon)
        end

        -- AdrenalineRush : dans la fenetre Blade Flurry si possible
        if ToggleOr("UseAdrenalineRush", true) and A.AdrenalineRush:IsReady("player") and (Unit("player"):HasBuffs(A.BladeFlurry.ID, true) > 0 or not ToggleOr("UseBladeFlurry", true) or A.BladeFlurry:GetCooldown() > 60) then
            return A.AdrenalineRush:Show(icon)
        end

        if A.Berserking:AutoRacial(isTarget) then
            return A.Berserking:Show(icon)
        end

        if A.BloodFury:AutoRacial(isTarget) then
            return A.BloodFury:Show(icon)
        end

        if ToggleOr("UseTrinket1", true) and A.Trinket1:IsReady(isTarget) and A.Trinket1:IsItemDamager() then
            return A.Trinket1:Show(icon)
        end

        if ToggleOr("UseTrinket2", true) and A.Trinket2:IsReady(isTarget) and A.Trinket2:IsItemDamager() then
            return A.Trinket2:Show(icon)
        end

        -- HastePotion : sur boss, idealement dans Adrenaline Rush
        if ToggleOr("HastePotion", true) and Unit(isTarget):IsBoss() and A.HastePotion:IsReady("player") and (Unit("player"):HasBuffs(A.AdrenalineRush.ID, true) > 0 or A.AdrenalineRush:GetCooldown() > 120 or not ToggleOr("UseAdrenalineRush", true)) then
            return A.HastePotion:Show(icon)
        end

        -- Sappers : releve top logs, utilises meme en mono-cible sur boss
        if ToggleOr("UseSappers", true) and Unit(isTarget):IsBoss() then
            if A.SuperSapperCharge:IsReady("player") then
                return A.SuperSapperCharge:Show(icon)
            end
            if A.GoblinSapperCharge:IsReady("player") then
                return A.GoblinSapperCharge:Show(icon)
            end
        end
    end

    -- ThistleTea : creux d'energie (hors GCD)
    if ToggleOr("UseThistleTea", true) and inCombat and energy <= 25 and A.ThistleTea:IsReady("player") then
        return A.ThistleTea:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ CYCLE : SnD > Rupture > Eviscerate > builder avec pooling ]]
    ----------------------------------------------------------------------
    local builder     = GetBuilder()
    local builderCost = builder:GetSpellPowerCostCache()
    local sndCost     = A.SliceandDice:GetSpellPowerCostCache()

    -- SliceandDice : LA priorite absolue — refresh des que <= 1 GCD
    -- restant, avec n'importe quel nombre de CP
    if comboPoints >= 1 and buffSnD <= GetGCD() + GetCurrentGCD() and energy >= sndCost and A.SliceandDice:IsReady(isTarget, true) then
        return A.SliceandDice:Show(icon)
    end

    local useExposeArmor = ToggleOr("UseExposeArmor", true)
    local debuffEA       = Unit(isTarget):HasDeBuffs(Temp.AuraExposeArmor)

    -- ExposeArmor : 5 CP, DOUBLE UPTIME avec SnD — le cycle des top logs
    -- (EA maintenu a 90-99 %). Refresh sous 5 s restantes, ignore si un
    -- guerrier maintient Sunder Armor
    if useExposeArmor and comboPoints >= 5 and debuffEA <= 5 and Unit(isTarget):HasDeBuffs(Temp.AuraSunderArmor) == 0 and Unit(isTarget):TimeToDie() > 8 and energy >= A.ExposeArmor:GetSpellPowerCostCache() and A.ExposeArmor:IsReady(isTarget) then
        return A.ExposeArmor:Show(icon)
    end

    -- Garde CP : si EA expire bientot, on reserve les 5 CP pour lui
    local holdForEA = useExposeArmor and debuffEA > 0 and debuffEA <= 8 and Unit(isTarget):HasDeBuffs(Temp.AuraSunderArmor) == 0

    -- Rupture : optionnel (top logs : 1-2 casts en debut de combat,
    -- aucun sur les combats longs) — seulement quand SnD et EA sont
    -- larges et que rien d'autre ne reclame les CP
    if ToggleOr("UseRupture", true) and not holdForEA and comboPoints >= 5 and buffSnD > 6 and Unit(isTarget):HasDeBuffs(Temp.AuraRupture, true) == 0 and Unit(isTarget):TimeToDie() > 16 and energy >= A.Rupture:GetSpellPowerCostCache() and A.Rupture:IsReady(isTarget) and A.Rupture:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Rupture:Show(icon)
    end

    -- Eviscerate : dump 5 CP quand SnD (et EA) sont couverts, ou cible
    -- mourante
    if ToggleOr("UseEviscerate", true) and not holdForEA and comboPoints >= 5 and energy >= A.Eviscerate:GetSpellPowerCostCache() and A.Eviscerate:IsReady(isTarget) and A.Eviscerate:AbsentImun(isTarget, Temp.AttackTypes) and (Unit(isTarget):TimeToDie() <= 6 or (buffSnD > 6 and (not useExposeArmor or debuffEA > 8 or Unit(isTarget):HasDeBuffs(Temp.AuraSunderArmor) > 0))) then
        return A.Eviscerate:Show(icon)
    end

    -- Builder (SinisterStrike / Backstab) avec POOLING :
    --   - jamais si ca laisserait SnD tomber faute d'energie
    --     (SnD < 3 s -> reserver son cout)
    --   - a 5 CP : seulement si l'energie va capper (>= 85)
    local reserve = 0
    if buffSnD > 0 and buffSnD < 3 then
        reserve = sndCost
    end

    if comboPoints < 5 then
        if energy >= builderCost + reserve and builder:IsReady(isTarget) and builder:AbsentImun(isTarget, Temp.AttackTypes) then
            return builder:Show(icon)
        end
    else
        -- anti-cap d'energie a 5 CP (finishers en attente)
        if energy >= 85 and builder:IsReady(isTarget) and builder:AbsentImun(isTarget, Temp.AttackTypes) then
            return builder:Show(icon)
        end
    end
end

--------------------------------------------------------------------------
-- [[ META 5 : defensifs passifs ]]
--------------------------------------------------------------------------
A[5] = function(icon)
    -- CloakofShadows en catastrophe magique (toggle, off par defaut)
    if ToggleOr("UseCloak-Auto", false) and Unit("player"):CombatTime() > 0 and Unit("player"):HealthPercent() <= 35 and A.CloakofShadows:IsReadyP("player") then
        return A.CloakofShadows:Show(icon)
    end
end

-- Nil (metas non utilisees par ce profil)
A[1] = nil
A[2] = nil
A[4] = nil
A[6] = nil
A[7] = nil
A[8] = nil
