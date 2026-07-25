--------------------------------------------------------------------------
-- [GGL] Warrior TBC PvP - Rotation CodeSnippet (Order 1)
--
-- Snippet TellMeWhen "Code Snippets" pour le framework Action
-- (https://github.com/MisterCrab/Action), au format des profils GGL.
-- A installer AVANT le snippet UI (GGL_Action_Warrior_TBC_PvP_UI.lua).
--
-- Spec visee : ARMS 33/28/0 (Mortal Strike + Death Wish / Flurry +
-- Piercing Howl), le build des guerriers les mieux classes en arene TBC.
-- Variante 41/20/0 Endless Rage supportee sans modification (la rotation
-- est pilotee par les talents detectes). Fallback Fury inclus.
--
-- Orientation PvP (arene / BG) TBC :
--   - Interrupts Pummel / Shield Bash (toggles UI)
--   - Spell Reflection avec swap 1H+bouclier automatique (toggle UI)
--   - Disarm sur trigger (OFF / ON COOLDOWN / ON BURST)
--   - Intimidating Shout & Piercing Howl a la volee (toggles UI)
--   - Overpower sur esquive (log de combat), Hamstring uptime
--   - Burst Death Wish + Recklessness + trinkets via le toggle Burst
--
-- Tous les toggles sont modifiables en jeu dans /action (onglet classe)
-- ou par macro :  /run Action.SetToggle({2, "Interrupt-Pummel"})
--------------------------------------------------------------------------

local _G, setmetatable, pairs, ipairs, select, math  = _G, setmetatable, pairs, ipairs, select, math

local wipe                                           = _G.wipe
local strsub                                         = _G.strsub
local UnitGUID                                       = _G.UnitGUID
local UnitIsUnit                                     = _G.UnitIsUnit
local GetShapeshiftForm                              = _G.GetShapeshiftForm
local CombatLogGetCurrentEventInfo                   = _G.CombatLogGetCurrentEventInfo

local TMW                                            = _G.TMW
local Action                                         = _G.Action
local CONST                                          = Action.Const
local Create                                         = Action.Create
local Listener                                       = Action.Listener
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
local EnemyTeam                                      = Action.EnemyTeam

local ACTION_CONST_STOPCAST                          = CONST.STOPCAST
local ACTION_CONST_AUTOTARGET                        = CONST.AUTOTARGET
local ACTION_CONST_CACHE_DEFAULT_TIMER               = CONST.CACHE_DEFAULT_TIMER

--------------------------------------------------------------------------
-- [[ SPELLS - TBC IDs ]]
--------------------------------------------------------------------------
Action[Action.PlayerClass] = {
    -- Racials
    BloodFury                 = Create({ Type = "Spell", ID = 20572                                            }),
    Berserking                = Create({ Type = "Spell", ID = 20554                                            }),
    WarStomp                  = Create({ Type = "Spell", ID = 20549                                            }),
    WilloftheForsaken         = Create({ Type = "Spell", ID = 7744                                             }),
    EscapeArtist              = Create({ Type = "Spell", ID = 20589                                            }),
    Perception                = Create({ Type = "Spell", ID = 20600, FixedTexture = CONST.HUMAN                }),
    -- Stances
    BattleStance              = Create({ Type = "Spell", ID = 2457,  isStance = 1                              }),
    DefensiveStance           = Create({ Type = "Spell", ID = 71,    isStance = 2                              }),
    BerserkerStance           = Create({ Type = "Spell", ID = 2458,  isStance = 3                              }),
    -- Core damage
    MortalStrike              = Create({ Type = "Spell", ID = 12294, isTalent = true, useMaxRank = true        }),
    Bloodthirst               = Create({ Type = "Spell", ID = 23881, isTalent = true, useMaxRank = true        }),
    Rampage                   = Create({ Type = "Spell", ID = 29801, isTalent = true, useMaxRank = true        }),
    Whirlwind                 = Create({ Type = "Spell", ID = 1680                                             }),
    Execute                   = Create({ Type = "Spell", ID = 5308,  useMaxRank = true                         }),
    Overpower                 = Create({ Type = "Spell", ID = 7384,  useMaxRank = true                         }),
    VictoryRush               = Create({ Type = "Spell", ID = 34428                                            }),
    Slam                      = Create({ Type = "Spell", ID = 1464,  useMaxRank = true                         }),
    HeroicStrike              = Create({ Type = "Spell", ID = 78,    useMaxRank = true                         }),
    Cleave                    = Create({ Type = "Spell", ID = 845,   useMaxRank = true                         }),
    Rend                      = Create({ Type = "Spell", ID = 772,   useMaxRank = true                         }),
    -- Burst
    DeathWish                 = Create({ Type = "Spell", ID = 12292, isTalent = true                           }), -- TBC ID (12328 en Classic Era)
    Recklessness              = Create({ Type = "Spell", ID = 1719                                             }),
    Bloodrage                 = Create({ Type = "Spell", ID = 2687                                             }),
    BerserkerRage             = Create({ Type = "Spell", ID = 18499                                            }),
    SweepingStrikes           = Create({ Type = "Spell", ID = 12328, isTalent = true                           }),
    -- PvP toolkit
    Pummel                    = Create({ Type = "Spell", ID = 6552,  useMaxRank = true                         }),
    ShieldBash                = Create({ Type = "Spell", ID = 72,    useMaxRank = true                         }),
    SpellReflection           = Create({ Type = "Spell", ID = 23920                                            }), -- TBC only
    Disarm                    = Create({ Type = "Spell", ID = 676,                Click = { macrobefore = "/stopcasting" } }),
    IntimidatingShout         = Create({ Type = "Spell", ID = 5246,               Click = { macrobefore = "/stopcasting" } }),
    PiercingHowl              = Create({ Type = "Spell", ID = 12323, isTalent = true                           }),
    Hamstring                 = Create({ Type = "Spell", ID = 1715,  useMaxRank = true                         }),
    Charge                    = Create({ Type = "Spell", ID = 100,   useMaxRank = true                         }),
    Intercept                 = Create({ Type = "Spell", ID = 20252, useMaxRank = true                         }),
    Intervene                 = Create({ Type = "Spell", ID = 3411                                             }), -- TBC only
    ConcussionBlow            = Create({ Type = "Spell", ID = 12809, isTalent = true, Click = { macrobefore = "/stopcasting" } }),
    -- Defense
    ShieldBlock               = Create({ Type = "Spell", ID = 2565                                             }),
    ShieldWall                = Create({ Type = "Spell", ID = 871                                              }),
    LastStand                 = Create({ Type = "Spell", ID = 12975, isTalent = true                           }),
    Retaliation               = Create({ Type = "Spell", ID = 20230                                            }),
    -- Buffs
    BattleShout               = Create({ Type = "Spell", ID = 6673,  useMaxRank = true                         }),
    CommandingShout           = Create({ Type = "Spell", ID = 469                                              }),
    -- Equipment (swap 1H+bouclier pour Spell Reflection / defense)
    SwapWeapon                = Create({ Type = "SwapEquip", ID = 132996, Desc = "SwapWeapon",
                                         Equip1 = function() return Player:HasShield() and not Player:HasShield(true) end,
                                         Equip2 = function() return Player:HasShield(true) and ((not Player:HasWeaponTwoHand(true) and Player:HasWeaponTwoHand()) or (not Player:HasWeaponOffHand(true) and Player:HasWeaponOffHand())) end,
                                         Macro = "/run print'Make SwapWeapon Macro in /action'\n/stopcasting\n/equipslot [noworn:shield][worn:two-hand] 16 1H\n/equipslot [noworn:shield][worn:two-hand] 17 shield\n/equipslot [worn:shield] 16 1H\n/equipslot [worn:shield] 17 1H"
                                       }),
    -- Consumables
    FreeActionPotion          = Create({ Type = "Potion", ID = 5634                                            }),
    MightyRagePotion          = Create({ Type = "Potion", ID = 13442                                           }),
    -- Hidden (talents trackes)
    Flurry                    = Create({ Type = "Spell", ID = 12319, Hidden = true, isTalent = true, useMaxRank = true }),
    TacticalMastery           = Create({ Type = "Spell", ID = 12295, Hidden = true, isTalent = true, useMaxRank = true }),
    ImprovedBerserkerRage     = Create({ Type = "Spell", ID = 20500, Hidden = true, isTalent = true, useMaxRank = true }),
}

Player:RegisterShield()
Player:RegisterWeaponTwoHand()
Player:RegisterWeaponOffHand()

local A = setmetatable(Action[Action.PlayerClass], { __index = Action })

--------------------------------------------------------------------------
-- [[ DODGE LOG - Overpower ]]
--------------------------------------------------------------------------
local dodgedGUID = {}

local IsEventIsDied = {
    ["UNIT_DIED"]       = true,
    ["UNIT_DESTROYED"]  = true,
    ["UNIT_DISSIPATES"] = true,
    ["PARTY_KILL"]      = true,
    ["SPELL_INSTAKILL"] = true,
}

local function RESET_GUID(DestGUID)
    if DestGUID then
        dodgedGUID[DestGUID] = nil
    else
        wipe(dodgedGUID)
    end
end

local function COMBAT_LOG_EVENT_UNFILTERED(...)
    local _, EVENT, _, SourceGUID, _, _, _, DestGUID, _, _, _, missTypeSwing, spellName, _, missType = CombatLogGetCurrentEventInfo()

    if strsub(EVENT, -6) == "MISSED" then
        if (missTypeSwing == "DODGE" or missType == "DODGE") and UnitGUID("player") == SourceGUID then
            dodgedGUID[DestGUID] = TMW.time + 5
        end
    end

    if (EVENT == "SPELL_DAMAGE" or EVENT == "SPELL_CAST_SUCCESS") and UnitGUID("player") == SourceGUID and spellName == A.Overpower:Info() then
        RESET_GUID(DestGUID)
    end

    if IsEventIsDied[EVENT] then
        RESET_GUID(DestGUID)
    end
end

Listener:Add("ACTION_EVENT_WARRIOR_PVP", "PLAYER_REGEN_ENABLED", RESET_GUID)
Listener:Add("ACTION_EVENT_WARRIOR_PVP", "COMBAT_LOG_EVENT_UNFILTERED", COMBAT_LOG_EVENT_UNFILTERED)

local function IsOverPowerUP(unitID)
    local GUID = UnitGUID(unitID)
    return GUID and dodgedGUID[GUID] and dodgedGUID[GUID] > TMW.time
end

--------------------------------------------------------------------------
-- [[ CONDITIONS ]]
--------------------------------------------------------------------------
local Temp = {
    AttackTypes               = { "TotalImun", "DamagePhysImun" },
    AuraForKick               = { "TotalImun", "DamagePhysImun", "KickImun" },
    AuraForFear               = { "TotalImun", "DamagePhysImun", "CCTotalImun", "FearImun" },
    AuraForDisarm             = { "TotalImun", "DamagePhysImun", "CCTotalImun" },
    AuraForStun               = { "TotalImun", "CCTotalImun", "StunImun" },
    ReflectUnits              = { "target", "mouseover", "arena1", "arena2", "arena3", "arena4", "arena5" },
}

local function GetStance()
    return GetShapeshiftForm() or 0
end

local function InMelee(unitID)
    return A.Hamstring:IsInRange(unitID)
end

local function ToggleOr(key, default)
    local value = GetToggle(2, key)
    if value == nil then
        return default
    end
    return value
end

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

-- Rage conservee par Tactical Mastery lors d'un changement de stance
local function StanceKeepRage()
    return A.TacticalMastery:GetTalentRank() * 5
end

-- Cherche un ennemi en train de caster SUR NOUS (pour Spell Reflection)
local function GetReflectUnit()
    for _, unitID in ipairs(Temp.ReflectUnits) do
        if IsUnitEnemy(unitID) and UnitIsUnit(unitID .. "target", "player") then
            local castLeft = Unit(unitID):IsCastingRemains()
            if castLeft and castLeft > GetPing() + 0.1 then
                return unitID, castLeft
            end
        end
    end
end

--------------------------------------------------------------------------
-- [[ ROTATION : META 3 (PvP) ]]
--------------------------------------------------------------------------
A[3] = function(icon)
    local inStance                        = GetStance()
    local combatTime                      = Unit("player"):CombatTime()
    local inCombat                        = combatTime > 0
    local inAoE                           = ToggleOr("AoE", false)
    local myRage                          = Unit("player"):Power()
    local targetHealthPercent             = Unit("target"):HealthPercent()
    local isFury                          = A.Bloodthirst:GetTalentRank() > 0
    local isTarget, isTargetInMelee
    local isMouse,  isMouseInMelee

    if IsUnitEnemy("target") then
        isTarget                          = "target"
        isTargetInMelee                   = InMelee(isTarget)
    else
        targetHealthPercent               = 100
    end

    if ToggleOr("mouseover", true) and IsUnitEnemy("mouseover") then
        isMouse                           = "mouseover"
        isMouseInMelee                    = InMelee(isMouse)
    end

    local executePhase                    = isTarget and targetHealthPercent <= 20

    -- StopCast : annule un HS/Cleave en file si Execute est pret ou cible immunisee
    if ToggleOr("StopCast", true) and isTarget then
        if A.HeroicStrike:IsSpellCurrent() and (not A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) or (executePhase and A.Execute:IsReadyP(isTarget))) then
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end
        if A.Cleave:IsSpellCurrent() and (not A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) or (executePhase and A.Execute:IsReadyP(isTarget))) then
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end
    end

    -- [[ LOSS OF CONTROL ]]
    if inStance == 3 and ToggleOr("UseBerserkerRage-LoC", true) and (LoC:Get("FEAR") > 0 or LoC:Get("INCAPACITATE") > 0) and A.BerserkerRage:IsReadyP("player") then
        return A.BerserkerRage:Show(icon)
    end

    if LoC:Get("FEAR") > 0 and ToggleOr("UseDeathWish-LoC", true) and A.DeathWish:IsReadyP("player") then
        return A.DeathWish:Show(icon)
    end

    if ToggleOr("UseRacial-LoC", true) and A.WilloftheForsaken:AutoRacial() then
        return A.WilloftheForsaken:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ SPELL REFLECTION ]]
    -- Toggle a la volee : /run Action.SetToggle({2, "UseSpellReflection"})
    -- Etapes rejouees a chaque tick : swap bouclier -> stance -> reflect
    ----------------------------------------------------------------------
    if ToggleOr("UseSpellReflection", true) and A.SpellReflection:GetCooldown() == 0 and Unit("player"):HasBuffs(A.SpellReflection.ID, true) == 0 then
        local reflectUnit = GetReflectUnit()
        if reflectUnit then
            -- 3. Pret : bouclier equipe + stance Battle/Def + rage
            if Player:HasShield(true) and (inStance == 1 or inStance == 2) and myRage >= A.SpellReflection:GetSpellPowerCostCache() and A.SpellReflection:IsReadyByPassCastGCD("player") then
                return A.SpellReflection:Show(icon)
            end

            -- 2. Stance : Berserker -> Battle
            if Player:HasShield(true) and inStance == 3 and A.BattleStance:IsReady("player") then
                return A.BattleStance:Show(icon)
            end

            -- 1. Swap 1H + bouclier (si dispo dans les sacs)
            if ToggleOr("SpellReflection-AutoSwap", true) and not Player:HasShield(true) and Player:HasShield() then
                return A.SwapWeapon:Show(icon)
            end
        end
    end

    -- Retour dual-wield / 2H apres le reflect (hors fenetre de cast ennemie)
    if ToggleOr("SpellReflection-AutoSwap", true) and Player:HasShield(true) and not GetReflectUnit() and (A.SpellReflection:GetCooldown() > 3 or Unit("player"):HasBuffs(A.SpellReflection.ID, true) > 0 or not ToggleOr("UseSpellReflection", true)) then
        return A.SwapWeapon:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ INTERRUPTS ]]
    -- Toggle a la volee : /run Action.SetToggle({2, "Interrupt-Pummel"})
    ----------------------------------------------------------------------
    local kickUnit = isMouse or isTarget
    if kickUnit then
        local castLeft, _, _, _, notInterruptAble = Unit(kickUnit):IsCastingRemains()
        if castLeft and castLeft > GetPing() + 0.1 and not notInterruptAble then
            -- Pummel (Berserker Stance uniquement, pas de switch auto)
            if ToggleOr("Interrupt-Pummel", true) and inStance == 3 and A.Pummel:IsReady(kickUnit) and A.Pummel:AbsentImun(kickUnit, Temp.AuraForKick) then
                return A.Pummel:Show(icon)
            end

            -- ShieldBash (Battle/Def + bouclier deja equipe)
            if ToggleOr("Interrupt-ShieldBash", false) and (inStance == 1 or inStance == 2) and Player:HasShield(true) and A.ShieldBash:IsReady(kickUnit) and A.ShieldBash:AbsentImun(kickUnit, Temp.AuraForKick) then
                return A.ShieldBash:Show(icon)
            end
        end
    end

    ----------------------------------------------------------------------
    -- [[ DISARM ]] trigger : OFF / ON COOLDOWN / ON BURST
    ----------------------------------------------------------------------
    local disarmTrigger = ToggleOr("Trigger-Disarm", "ON BURST")
    if disarmTrigger ~= "OFF" and isTarget and isTargetInMelee and Unit(isTarget):IsPlayer() and Unit(isTarget):IsMelee() and Unit(isTarget):IsControlAble("disarm") and A.Disarm:AbsentImun(isTarget, Temp.AuraForDisarm) and (disarmTrigger == "ON COOLDOWN" or Unit(isTarget):HasBuffs("DamageBuffs") > 0) then
        if inStance == 2 and A.Disarm:IsReady(isTarget) then
            return A.Disarm:Show(icon)
        end

        if inStance ~= 2 and A.Disarm:GetCooldown() == 0 and A.DefensiveStance:IsReady("player") and myRage - StanceKeepRage() <= 5 + A.Disarm:GetSpellPowerCostCache() then
            return A.DefensiveStance:Show(icon)
        end
    end

    -- BattleShout : hors combat / pas de cible
    if (not inCombat or (not isTarget and not isMouse)) and A.BattleShout:IsReady("player") and Unit("player"):HasBuffs(A.BattleShout.ID) <= GetGCD() + GetCurrentGCD() then
        return A.BattleShout:Show(icon)
    end

    -- Return : pas de cible primaire
    if not isTarget and not isMouse then
        return -- nil
    end

    -- [[ NO COMBAT - PRE COMBAT ]]
    if not inCombat then
        if myRage <= 80 and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 70) then
            return A.Bloodrage:Show(icon)
        end

        -- Charge (BattleStance requis)
        if A.Charge:IsReady(isMouse or isTarget, nil, nil, nil, true) then
            if inStance ~= 1 and A.BattleStance:IsReady("player") then
                return A.BattleStance:Show(icon)
            end
            if inStance == 1 then
                return A.Charge:Show(icon)
            end
        end
    end

    -- Intercept : gap-closer (stun)
    if ToggleOr("UseIntercept", true) and inCombat and not isMouseInMelee and not isTargetInMelee and A.Intercept:IsReady(isMouse or isTarget, nil, nil, nil, true) and (A.Intercept:AbsentImun(isMouse or isTarget, Temp.AuraForStun) or Unit(isMouse or isTarget):HasBuffs(A.FreeActionPotion.ID) > 0) and A.Charge:GetSpellTimeSinceLastCast() > 2 then
        if inStance ~= 3 and A.BerserkerStance:IsReady("player") and StanceKeepRage() >= A.Intercept:GetSpellPowerCostCache() then
            return A.BerserkerStance:Show(icon)
        end
        if inStance == 3 and A.Intercept:IsReady(isMouse or isTarget) then
            return A.Intercept:Show(icon)
        end
    end

    -- Return : rien a faire hors melee
    if not isTargetInMelee then
        return -- nil
    end

    ----------------------------------------------------------------------
    -- [[ CC A LA VOLEE ]]
    ----------------------------------------------------------------------
    -- IntimidatingShout : active le toggle quand tu veux le fear
    if ToggleOr("UseIntimidatingShout", false) and A.IntimidatingShout:IsReady(isTarget) and Unit(isTarget):GetRange() <= 8 and Unit(isTarget):IsControlAble("fear") and A.IntimidatingShout:AbsentImun(isTarget, Temp.AuraForFear) then
        return A.IntimidatingShout:Show(icon)
    end

    -- PiercingHowl : snare AoE si la cible n'est pas deja ralentie
    if ToggleOr("UsePiercingHowl", true) and A.PiercingHowl:IsTalentLearned() and A.PiercingHowl:IsReady("player") and myRage >= A.PiercingHowl:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() and Unit(isTarget):GetRange() <= 10 and Unit(isTarget):HasDeBuffs(A.PiercingHowl.ID) == 0 and Unit(isTarget):IsControlAble("snare") then
        return A.PiercingHowl:Show(icon)
    end

    -- [[ BURST ]]
    if inCombat and BurstIsON(isTarget) and A.AbsentImun(nil, isTarget, Temp.AttackTypes) then
        local timetouseall = (DetermineCountGCDs(A.BloodFury, A.Berserking, A.Recklessness, A.DeathWish) * (GetGCD() * 3)) + GetCurrentGCD() + GetPing() + ACTION_CONST_CACHE_DEFAULT_TIMER + (TMW.UPD_INTV or 0)

        if A.Berserking:AutoRacial(isTarget) then
            return A.Berserking:Show(icon)
        end

        if A.BloodFury:AutoRacial(isTarget) then
            return A.BloodFury:Show(icon)
        end

        if A.DeathWish:IsReady("player") and myRage >= A.DeathWish:GetSpellPowerCostCache() + 30 then
            return A.DeathWish:Show(icon)
        end

        if inStance == 3 and A.Recklessness:IsReady("player") and (A.DeathWish:GetCooldown() > 30 or Unit("player"):HasBuffs(A.DeathWish.ID) > 0 or A.DeathWish:GetTalentRank() == 0) then
            return A.Recklessness:Show(icon)
        end

        if A.Trinket1:IsReady(isTarget) and A.Trinket1:IsItemDamager() then
            return A.Trinket1:Show(icon)
        end

        if A.Trinket2:IsReady(isTarget) and A.Trinket2:IsItemDamager() then
            return A.Trinket2:Show(icon)
        end
    end

    -- Bloodrage : rage quasi gratuite
    if inCombat and myRage < (80 - HeroicStrikeAdjustedPower()) and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 70) then
        return A.Bloodrage:Show(icon)
    end

    -- BerserkerRage : gain de rage (Improved Berserker Rage)
    if inCombat and inStance == 3 and ToggleOr("UseBerserkerRage-GainRage", true) and A.ImprovedBerserkerRage:GetTalentRank() > 0 and A.BerserkerRage:IsReady("player") and myRage <= 15 + (A.ImprovedBerserkerRage:GetTalentRank() * 5) then
        return A.BerserkerRage:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ CORE DAMAGE ]]
    ----------------------------------------------------------------------

    -- Overpower : sur esquive detectee (log), stance dance si Tactical Mastery
    if ToggleOr("UseOverpower", true) and IsOverPowerUP(isTarget) and not A.Overpower:IsBlockedBySpellBook() and A.Overpower:GetCooldown() == 0 and myRage >= A.Overpower:GetSpellPowerCostCache() and A.Overpower:AbsentImun(isTarget, Temp.AttackTypes) then
        if inStance == 1 and A.Overpower:IsReady(isTarget) then
            return A.Overpower:Show(icon)
        end

        if inStance ~= 1 and A.BattleStance:IsReady("player") and myRage - StanceKeepRage() <= 10 + A.Overpower:GetSpellPowerCostCache() then
            return A.BattleStance:Show(icon)
        end
    end

    -- MortalStrike : coeur du build Arms (debuff soins -50% a maintenir)
    if A.MortalStrike:IsReady(isTarget) and A.MortalStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.MortalStrike:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() then
        return A.MortalStrike:Show(icon)
    end

    -- Execute : sous 20 %, prioritaire sur Whirlwind (toute la rage y passe)
    if executePhase and A.Execute:IsReady(isTarget) and A.Execute:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Execute:Show(icon)
    end

    -- Bloodthirst (fallback spec Fury)
    if isFury and A.Bloodthirst:IsReady(isTarget) and A.Bloodthirst:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.Bloodthirst:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() then
        return A.Bloodthirst:Show(icon)
    end

    -- Rampage : upkeep (fallback spec Fury)
    if isFury and A.Rampage:GetTalentRank() > 0 and Unit("player"):HasBuffs(A.Rampage.ID, true) <= 5 + GetGCD() + GetCurrentGCD() and A.Rampage:IsReady("player") then
        return A.Rampage:Show(icon)
    end

    -- Whirlwind : Berserker Stance, en reservant la rage d'un MortalStrike
    -- imminent, jamais si un CC cassable (sheep/sap) est a portee
    if not executePhase and inStance == 3 and A.Whirlwind:IsReady(isTarget, true) and A.Whirlwind:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.Whirlwind:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() + ((A.MortalStrike:GetCooldown() <= GetGCD() and not A.MortalStrike:IsBlockedBySpellBook()) and A.MortalStrike:GetSpellPowerCostCache() or 0) and (not A.IsInPvP or not EnemyTeam():IsBreakAble(8)) then
        return A.Whirlwind:Show(icon)
    end

    -- VictoryRush
    if ToggleOr("UseVictoryRush", true) and A.VictoryRush:IsReady(isTarget) and A.VictoryRush:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.VictoryRush:Show(icon)
    end

    -- Hamstring : uptime du snare sur les joueurs, en reservant la rage
    -- d'un MortalStrike imminent
    if ToggleOr("UseHamstring", true) and Unit(isTarget):IsPlayer() and A.Hamstring:IsReady(isTarget) and myRage >= A.Hamstring:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() + ((A.MortalStrike:GetCooldown() <= GetGCD() and not A.MortalStrike:IsBlockedBySpellBook()) and A.MortalStrike:GetSpellPowerCostCache() or 0) and Unit(isTarget):HasDeBuffs(A.Hamstring.ID) <= GetGCD() + GetCurrentGCD() and Unit(isTarget):IsControlAble("snare") and A.Hamstring:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Hamstring:Show(icon)
    end

    -- Cleave : rage dump AoE (jamais si CC cassable autour)
    if inAoE and not IsCurrentAttack() and MultiUnits:GetBySpell(A.Hamstring, 7) >= 2 and A.Cleave:IsReady(isTarget, true) and A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("Cleave-PWR", 50) and (not A.IsInPvP or not EnemyTeam():IsBreakAble(5)) then
        return A.Cleave:Show(icon)
    end

    -- HeroicStrike : rage dump
    if not executePhase and not IsCurrentAttack() and A.HeroicStrike:IsReady(isTarget) and A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("HeroicStrike-PWR", 60) then
        return A.HeroicStrike:Show(icon)
    end

    -- Stance par defaut : retour en Berserker si la rage ne se perd pas
    if inStance ~= 3 and not IsOverPowerUP(isTarget) and A.BerserkerStance:IsReady("player") and myRage <= StanceKeepRage() then
        return A.BerserkerStance:Show(icon)
    end
end

--------------------------------------------------------------------------
-- [[ META 5 : passif (Loss of Control) ]]
--------------------------------------------------------------------------
A[5] = function(icon)
    if GetStance() == 3 and (LoC:Get("FEAR") > 0 or LoC:Get("INCAPACITATE") > 0) and A.BerserkerRage:IsReadyP("player") then
        return A.BerserkerRage:Show(icon)
    end
end

-- Nil (metas non utilisees par ce profil)
A[1] = nil
A[2] = nil
A[4] = nil
A[6] = nil
A[7] = nil
A[8] = nil
