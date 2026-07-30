--------------------------------------------------------------------------
-- [GGL] Warrior TBC - Fury DPS CodeSnippet
--
-- Snippet TellMeWhen "Code Snippets" pour le framework Action
-- (https://github.com/MisterCrab/Action), au format des profils GGL.
--
-- Import : /tmw -> Profile -> Code Snippets -> New -> coller ce fichier
-- (ou remplacer le contenu du snippet "Warrior" d'un profil [GGL] copie).
-- Cible : client TBC 2.4.3 / 2.5.x, spec Fury 17/44/0 (Rampage),
-- objectif damage max mono-cible + bascule AoE via le toggle "AoE".
--
-- Priorite implementee (meta 3 - rotation principale) :
--   Burst    : Death Wish > Recklessness > racials > trinkets > Haste Potion
--   Rage     : Bloodrage on CD, Berserker Rage (Improved) si rage basse
--   Rotation : Rampage (upkeep) > Bloodthirst > Whirlwind > Execute (<20%)
--              > Victory Rush > Heroic Strike / Cleave (rage dump)
--------------------------------------------------------------------------

local _G, setmetatable, pairs, math                  = _G, setmetatable, pairs, math

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
local DetermineCountGCDs                             = Action.DetermineCountGCDs
local Unit                                           = Action.Unit
local Player                                         = Action.Player
local LoC                                            = Action.LossOfControl
local MultiUnits                                     = Action.MultiUnits
local TeamCache                                      = Action.TeamCache
local TeamCacheFriendly                              = TeamCache.Friendly

local ACTION_CONST_STOPCAST                          = CONST.STOPCAST
local ACTION_CONST_AUTOTARGET                        = CONST.AUTOTARGET
local ACTION_CONST_CACHE_DEFAULT_TIMER               = CONST.CACHE_DEFAULT_TIMER

local GetShapeshiftForm                              = _G.GetShapeshiftForm

--------------------------------------------------------------------------
-- [[ SPELLS - TBC IDs ]]
--------------------------------------------------------------------------
Action[Action.PlayerClass] = {
    -- Racials
    BloodFury                 = Create({ Type = "Spell", ID = 20572                                            }),
    Berserking                = Create({ Type = "Spell", ID = 20554                                            }),
    WarStomp                  = Create({ Type = "Spell", ID = 20549                                            }),
    Stoneform                 = Create({ Type = "Spell", ID = 20594                                            }),
    WilloftheForsaken         = Create({ Type = "Spell", ID = 7744                                             }),
    Perception                = Create({ Type = "Spell", ID = 20600, FixedTexture = CONST.HUMAN                }),
    -- Stances
    BattleStance              = Create({ Type = "Spell", ID = 2457,  isStance = 1                              }),
    DefensiveStance           = Create({ Type = "Spell", ID = 71,    isStance = 2                              }),
    BerserkerStance           = Create({ Type = "Spell", ID = 2458,  isStance = 3                              }),
    -- Core Fury rotation
    Rampage                   = Create({ Type = "Spell", ID = 29801, isTalent = true, useMaxRank = true        }), -- 41pt Fury (TBC)
    Bloodthirst               = Create({ Type = "Spell", ID = 23881, isTalent = true, useMaxRank = true        }),
    Whirlwind                 = Create({ Type = "Spell", ID = 1680                                             }),
    Execute                   = Create({ Type = "Spell", ID = 5308,  useMaxRank = true                         }),
    VictoryRush               = Create({ Type = "Spell", ID = 34428                                            }), -- TBC only
    HeroicStrike              = Create({ Type = "Spell", ID = 78,    useMaxRank = true                         }),
    Cleave                    = Create({ Type = "Spell", ID = 845,   useMaxRank = true                         }),
    Slam                      = Create({ Type = "Spell", ID = 1464,  useMaxRank = true                         }),
    -- Arms (fallback si le perso est spec MS)
    MortalStrike              = Create({ Type = "Spell", ID = 12294, isTalent = true, useMaxRank = true        }),
    Overpower                 = Create({ Type = "Spell", ID = 7384,  useMaxRank = true                         }),
    SweepingStrikes           = Create({ Type = "Spell", ID = 12328, isTalent = true                           }), -- TBC: swap d'ID avec DeathWish vs Classic
    -- Burst
    DeathWish                 = Create({ Type = "Spell", ID = 12292, isTalent = true                           }), -- TBC: 12292 (12328 en Classic Era)
    Recklessness              = Create({ Type = "Spell", ID = 1719                                             }),
    Bloodrage                 = Create({ Type = "Spell", ID = 2687                                             }),
    BerserkerRage             = Create({ Type = "Spell", ID = 18499                                            }),
    -- Utility / debuffs
    SunderArmor               = Create({ Type = "Spell", ID = 7386,  useMaxRank = true                         }),
    DemoralizingShout         = Create({ Type = "Spell", ID = 1160,  useMaxRank = true                         }),
    ThunderClap               = Create({ Type = "Spell", ID = 6343,  useMaxRank = true                         }),
    Hamstring                 = Create({ Type = "Spell", ID = 1715,  useMaxRank = true                         }),
    Rend                      = Create({ Type = "Spell", ID = 772,   useMaxRank = true                         }),
    Pummel                    = Create({ Type = "Spell", ID = 6552,  useMaxRank = true                         }),
    ShieldBash                = Create({ Type = "Spell", ID = 72,    useMaxRank = true                         }),
    Intercept                 = Create({ Type = "Spell", ID = 20252, useMaxRank = true                         }),
    Charge                    = Create({ Type = "Spell", ID = 100,   useMaxRank = true                         }),
    SpellReflection           = Create({ Type = "Spell", ID = 23920                                            }), -- TBC only
    Intervene                 = Create({ Type = "Spell", ID = 3411                                             }), -- TBC only
    -- Buffs
    BattleShout               = Create({ Type = "Spell", ID = 6673,  useMaxRank = true                         }),
    CommandingShout           = Create({ Type = "Spell", ID = 469                                              }), -- TBC only
    -- Consumables
    HastePotion               = Create({ Type = "Potion", ID = 22838                                           }), -- meilleure potion DPS TBC
    MightyRagePotion          = Create({ Type = "Potion", ID = 13442                                           }),
    -- Hidden (talents trackes, jamais affiches)
    Flurry                    = Create({ Type = "Spell", ID = 12319, Hidden = true, isTalent = true, useMaxRank = true }),
    TacticalMastery           = Create({ Type = "Spell", ID = 12295, Hidden = true, isTalent = true, useMaxRank = true }),
    ImprovedBerserkerRage     = Create({ Type = "Spell", ID = 20500, Hidden = true, isTalent = true, useMaxRank = true }),
}

Player:RegisterWeaponTwoHand()
Player:RegisterWeaponOffHand()

local A = setmetatable(Action[Action.PlayerClass], { __index = Action })

--------------------------------------------------------------------------
-- [[ CONDITIONS ]]
--------------------------------------------------------------------------
local Temp = {
    AttackTypes               = { "TotalImun", "DamagePhysImun" },
    AuraForInterrupt          = { "TotalImun", "KickImun" },
}

local function GetStance()
    return GetShapeshiftForm() or 0
end

local function InMelee(unitID)
    return A.Bloodthirst:IsInRange(unitID)
end

-- Toggle du profil UI avec valeur par defaut si la cle n'existe pas
-- (permet d'utiliser ce snippet avec le "Profile UI" GGL d'origine)
local function ToggleOr(key, default)
    local value = GetToggle(2, key)
    if value == nil then
        return default
    end
    return value
end

-- Heroic Strike / Cleave deja en file : leur cout doit etre reserve
local function HeroicStrikeAdjustedPower()
    if A.HeroicStrike:IsSpellCurrent() then
        return A.HeroicStrike:GetSpellPowerCostCache()
    elseif A.Cleave:IsSpellCurrent() then
        return A.Cleave:GetSpellPowerCostCache()
    end
    return 0
end

local function IsCurrentAttack()
    return A.HeroicStrike:IsSpellCurrent() or A.Cleave:IsSpellCurrent()
end

-- Somme des couts en rage des sorts passes en arguments (non bloques)
local function CalculateRage(...)
    local total = 0
    for i = 1, select("#", ...) do
        local object = select(i, ...)
        if object and not object:IsBlocked() and not object:IsBlockedBySpellBook() then
            total = total + object:GetSpellPowerCostCache()
        end
    end
    return total
end

-- Temps restant du buff Rampage sur le joueur (0 si absent)
local function RampageTimeLeft()
    return Unit("player"):HasBuffs(A.Rampage.ID, true)
end

--------------------------------------------------------------------------
-- [[ ROTATION : META 3 (main DPS) ]]
--------------------------------------------------------------------------
A[3] = function(icon)
    local inStance                        = GetStance()
    local combatTime                      = Unit("player"):CombatTime()
    local inCombat                        = combatTime > 0
    local inAoE                           = ToggleOr("AoE", false)
    local myRage                          = Unit("player"):Power()
    local targetHealthPercent             = Unit("target"):HealthPercent()
    local isFury                          = A.Bloodthirst:GetTalentRank() > 0 or not A.Bloodthirst:IsBlockedBySpellBook()
    local isTarget, isTargetInMelee

    if IsUnitEnemy("target") then
        isTarget                          = "target"
        isTargetInMelee                   = InMelee(isTarget)
    else
        targetHealthPercent               = 100
    end

    local executePhase                    = isTarget and targetHealthPercent <= 20

    -- StopCast : annule un Heroic Strike / Cleave en file si la rage doit
    -- servir a Execute (phase <20%) ou si la cible devient immunisee
    if ToggleOr("StopCast", true) and isTarget then
        if A.HeroicStrike:IsSpellCurrent() and (not A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) or (executePhase and A.Execute:IsReadyP(isTarget))) then
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end
        if A.Cleave:IsSpellCurrent() and (not A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) or (executePhase and A.Execute:IsReadyP(isTarget))) then
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end
    end

    -- BerserkerRage : anti-Fear/Incapacitate (Loss of Control)
    if inStance == 3 and ToggleOr("UseBerserkerRage-LoC", true) and (LoC:Get("FEAR") > 0 or LoC:Get("INCAPACITATE") > 0) and A.BerserkerRage:IsReadyP("player") then
        return A.BerserkerRage:Show(icon)
    end

    -- DeathWish : immunise contre le Fear (Loss of Control)
    if LoC:Get("FEAR") > 0 and ToggleOr("UseDeathWish-LoC", true) and A.DeathWish:IsReadyP("player") then
        return A.DeathWish:Show(icon)
    end

    -- BattleShout : hors combat ou sans cible primaire
    if (not inCombat or not isTarget) and A.BattleShout:IsReady("player") and Unit("player"):HasBuffs(A.BattleShout.ID) <= GetGCD() + GetCurrentGCD() then
        return A.BattleShout:Show(icon)
    end

    -- Return : pas de cible
    if not isTarget then
        if inCombat and ToggleOr("AutoTarget", true) then
            return A:Show(icon, ACTION_CONST_AUTOTARGET)
        end
        return -- nil
    end

    -- [[ NO COMBAT - PRE COMBAT ]]
    if not inCombat then
        -- Bloodrage : pre-pull rage
        if myRage <= 80 and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 35) then
            return A.Bloodrage:Show(icon)
        end

        -- Charge (BattleStance requis)
        if A.Charge:IsReady(isTarget, nil, nil, nil, true) then
            if inStance ~= 1 and A.BattleStance:IsReady("player") then
                return A.BattleStance:Show(icon)
            end
            if inStance == 1 then
                return A.Charge:Show(icon)
            end
        end
    end

    -- [[ INTERRUPTS ]]
    if isTargetInMelee and ToggleOr("Interrupts", true) and Unit(isTarget):IsCastingRemains() > GetPing() + 0.1 and A.Pummel:AbsentImun(isTarget, Temp.AuraForInterrupt) then
        if inStance == 3 and A.Pummel:IsReady(isTarget) then
            return A.Pummel:Show(icon)
        end
    end

    -- Stance : la rotation Fury vit en Berserker Stance
    -- (bascule uniquement si on ne perd pas de rage utile : Tactical Mastery)
    if isFury and inStance ~= 3 and A.BerserkerStance:IsReady("player") and (myRage <= A.TacticalMastery:GetTalentRank() * 5 + 10 or not inCombat) then
        return A.BerserkerStance:Show(icon)
    end

    -- Intercept : gap-closer en combat
    if inCombat and not isTargetInMelee and inStance == 3 and A.Intercept:IsReady(isTarget, nil, nil, nil, true) and myRage >= A.Intercept:GetSpellPowerCostCache() and A.Charge:GetSpellTimeSinceLastCast() > 2 then
        return A.Intercept:Show(icon)
    end

    -- Return : rien a faire hors melee
    if not isTargetInMelee then
        return -- nil
    end

    -- [[ BURST ]]
    if inCombat and BurstIsON(isTarget) and A.AbsentImun(nil, isTarget, Temp.AttackTypes) then
        local timing20        = ToggleOr("BurstTimingTo20", false)
        local ttdto20         = Unit(isTarget):TimeToDieX(20)
        local isboss          = Unit(isTarget):IsBoss()
        local timetouseall    = (DetermineCountGCDs(A.BloodFury, A.Berserking, A.Recklessness, A.DeathWish) * (GetGCD() * 3)) + GetCurrentGCD() + GetPing() + ACTION_CONST_CACHE_DEFAULT_TIMER + (TMW.UPD_INTV or 0)

        -- Berserking (Troll)
        if A.Berserking:AutoRacial(isTarget) and A.Berserking:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) then
            return A.Berserking:Show(icon)
        end

        -- BloodFury (Orc)
        if A.BloodFury:AutoRacial(isTarget) and A.BloodFury:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) then
            return A.BloodFury:Show(icon)
        end

        -- DeathWish
        if A.DeathWish:IsReady("player") and A.DeathWish:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) and myRage >= A.DeathWish:GetSpellPowerCostCache() + 30 then
            return A.DeathWish:Show(icon)
        end

        -- Recklessness : a coupler avec DeathWish si possible
        if inStance == 3 and A.Recklessness:IsReady("player") and A.Recklessness:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) and (A.DeathWish:GetCooldown() > 30 or Unit("player"):HasBuffs(A.DeathWish.ID) > 0 or A.DeathWish:GetTalentRank() == 0) then
            return A.Recklessness:Show(icon)
        end

        -- Trinkets
        if A.Trinket1:IsReady(isTarget) and A.Trinket1:IsItemDamager() and A.Trinket1:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) then
            return A.Trinket1:Show(icon)
        end
        if A.Trinket2:IsReady(isTarget) and A.Trinket2:IsItemDamager() and A.Trinket2:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) then
            return A.Trinket2:Show(icon)
        end

        -- HastePotion : dans la fenetre DeathWish sur boss
        if ToggleOr("HastePotion", true) and A.HastePotion:IsReady("player") and isboss and (Unit("player"):HasBuffs(A.DeathWish.ID) > 0 or A.DeathWish:GetTalentRank() == 0 or A.DeathWish:GetCooldown() > 60) and A.HastePotion:CanCastBurst(targetHealthPercent, timing20, ttdto20, isboss, timetouseall) then
            return A.HastePotion:Show(icon)
        end
    end

    -- Bloodrage : on cooldown en combat (rage quasi gratuite)
    if inCombat and myRage < (80 - HeroicStrikeAdjustedPower()) and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 35) then
        return A.Bloodrage:Show(icon)
    end

    -- BerserkerRage : gain de rage (Improved Berserker Rage)
    if inCombat and inStance == 3 and ToggleOr("UseBerserkerRage-GainRage", true) and A.ImprovedBerserkerRage:GetTalentRank() > 0 and A.BerserkerRage:IsReady("player") and myRage <= 15 + (A.ImprovedBerserkerRage:GetTalentRank() * 5) then
        return A.BerserkerRage:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ CORE FURY PRIORITY ]]
    ----------------------------------------------------------------------

    -- Rampage : maintenir le buff (necessite un crit recent - IsUsable gere)
    -- Refresh sous 5 s ou pose initiale ; jamais au detriment d'un
    -- Bloodthirst pret si la rage ne couvre pas les deux
    if A.Rampage:GetTalentRank() > 0 or not A.Rampage:IsBlockedBySpellBook() then
        local rampageLeft = RampageTimeLeft()
        if rampageLeft <= ToggleOr("Rampage-Refresh", 5) + GetGCD() + GetCurrentGCD() and A.Rampage:IsReady("player") and (myRage >= CalculateRage(A.Rampage, A.Bloodthirst) or A.Bloodthirst:GetCooldown() > GetGCD() or rampageLeft == 0) then
            return A.Rampage:Show(icon)
        end
    end

    -- Whirlwind : AoE 4+ prioritaire sur Bloodthirst
    if inAoE and inStance == 3 and A.Whirlwind:IsReady(isTarget, true) and A.Whirlwind:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.Whirlwind:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() and MultiUnits:GetBySpell(A.Hamstring, 7) >= 4 then
        return A.Whirlwind:Show(icon)
    end

    -- Bloodthirst
    if A.Bloodthirst:IsReady(isTarget) and A.Bloodthirst:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.Bloodthirst:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() then
        return A.Bloodthirst:Show(icon)
    end

    -- MortalStrike (fallback spec Arms)
    if A.MortalStrike:IsReady(isTarget) and A.MortalStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.MortalStrike:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() then
        return A.MortalStrike:Show(icon)
    end

    -- Whirlwind : single target, en gardant la rage d'un Bloodthirst
    -- qui revient dans le GCD courant
    if inStance == 3 and A.Whirlwind:IsReady(isTarget, true) and A.Whirlwind:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.Whirlwind:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() + ((A.Bloodthirst:GetCooldown() <= GetGCD() and not A.Bloodthirst:IsBlockedBySpellBook()) and A.Bloodthirst:GetSpellPowerCostCache() or 0) then
        return A.Whirlwind:Show(icon)
    end

    -- Execute : vidange de rage sous 20 % (Bloodthirst/Whirlwind restent
    -- prioritaires : plus de degats par point de rage)
    if executePhase and A.Execute:IsReady(isTarget) and A.Execute:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Execute:Show(icon)
    end

    -- VictoryRush : gratuit apres un kill, a caser entre deux GCD
    if A.VictoryRush:IsReady(isTarget) and A.VictoryRush:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.VictoryRush:Show(icon)
    end

    -- SunderArmor : monte 5 stacks en raid (toggle, off par defaut en solo)
    if not A.IsInPvP and ToggleOr("PrioritizeSA", false) and A.SunderArmor:IsReady(isTarget) and A.SunderArmor:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= 45 + HeroicStrikeAdjustedPower() and Unit(isTarget):HasDeBuffsStacks(A.SunderArmor.ID, true) < 5 then
        return A.SunderArmor:Show(icon)
    end

    -- Cleave : rage dump AoE
    if inAoE and not IsCurrentAttack() and MultiUnits:GetBySpell(A.Hamstring, 7) >= 2 and A.Cleave:IsReady(isTarget, true) and A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("Cleave-PWR", 50) then
        return A.Cleave:Show(icon)
    end

    -- HeroicStrike : rage dump single target (jamais en phase Execute :
    -- la rage part dans Execute)
    if not executePhase and not inAoE and not IsCurrentAttack() and A.HeroicStrike:IsReady(isTarget) and A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("HeroicStrike-PWR", 60) then
        return A.HeroicStrike:Show(icon)
    end

    -- Hamstring : filler pour pecher les procs Flurry/Windfury a tres
    -- haute rage uniquement (toggle, off par defaut)
    if ToggleOr("HamstringFiller", false) and A.Hamstring:IsReady(isTarget) and A.Flurry:GetTalentRank() > 0 and Unit("player"):HasBuffs(A.Flurry.ID, true) == 0 and myRage >= 80 and A.Hamstring:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Hamstring:Show(icon)
    end
end

--------------------------------------------------------------------------
-- [[ META 5 : Trinkets / utilitaires passifs ]]
--------------------------------------------------------------------------
A[5] = function(icon)
    -- BerserkerRage : Loss of Control (icone passive)
    if GetStance() == 3 and (LoC:Get("FEAR") > 0 or LoC:Get("INCAPACITATE") > 0) and A.BerserkerRage:IsReadyP("player") then
        return A.BerserkerRage:Show(icon)
    end
end

-- Nil (rien pour ce profil ici, on nettoie les metas non utilisees)
A[1] = nil
A[2] = nil
A[4] = nil
A[6] = nil
A[7] = nil
A[8] = nil
