--------------------------------------------------------------------------
-- [GGL] Warrior TBC Prot - Rotation CodeSnippet (Order 1)
--
-- Profil Protection oriente DPS/menace max, base sur le gameplay des
-- meilleurs parses mondiaux prot (top 10% Warcraft Logs, agrege par
-- wowtbc.gg) et les guides Wowhead / Icy Veins / Warcraft Tavern :
--
--   1. Shield Slam ON COOLDOWN (plus gros hit, 6 s de CD = 1 GCD sur 4)
--   2. Revenge des que le proc est disponible (dodge/parry/block subis)
--   3. Devastate en filler sur CHAQUE GCD libre (monte/refresh Sunder x5)
--   4. Heroic Strike hors-GCD en vidange de rage, sans jamais affamer
--      Shield Slam (les top parses spamment HS car la rage entrante
--      d'un tank est enorme)
--   5. Shield Block on cooldown : anti-crush + genere des procs Revenge
--   6. Thunder Clap / Demoralizing Shout en toggles (couts en GCD :
--      OFF si un autre guerrier les applique = plus de DPS)
--
-- Spec visee : 8/5/48 standard (Imp Heroic Strike, Deflection, Cruelty,
-- Devastate, Focused Rage, One-Handed Weapon Specialization).
-- La rotation vit en Posture defensive (Revenge/Devastate l'exigent).
--------------------------------------------------------------------------

local _G, setmetatable, ipairs                       = _G, setmetatable, ipairs

local GetShapeshiftForm                              = _G.GetShapeshiftForm

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
local MultiUnits                                     = Action.MultiUnits

local ACTION_CONST_STOPCAST                          = CONST.STOPCAST
local ACTION_CONST_AUTOTARGET                        = CONST.AUTOTARGET

--------------------------------------------------------------------------
-- [[ SPELLS - TBC IDs ]]
--------------------------------------------------------------------------
Action[Action.PlayerClass] = {
    -- Racials
    BloodFury                 = Create({ Type = "Spell", ID = 20572                                            }),
    Berserking                = Create({ Type = "Spell", ID = 20554                                            }),
    Stoneform                 = Create({ Type = "Spell", ID = 20594                                            }),
    -- Stances
    BattleStance              = Create({ Type = "Spell", ID = 2457,  isStance = 1                              }),
    DefensiveStance           = Create({ Type = "Spell", ID = 71,    isStance = 2                              }),
    BerserkerStance           = Create({ Type = "Spell", ID = 2458,  isStance = 3                              }),
    -- Core prot
    ShieldSlam                = Create({ Type = "Spell", ID = 23922, isTalent = true, useMaxRank = true        }),
    Revenge                   = Create({ Type = "Spell", ID = 6572,  useMaxRank = true                         }),
    Devastate                 = Create({ Type = "Spell", ID = 20243, isTalent = true, useMaxRank = true        }), -- TBC 41pt Prot
    SunderArmor               = Create({ Type = "Spell", ID = 7386,  useMaxRank = true                         }),
    HeroicStrike              = Create({ Type = "Spell", ID = 78,    useMaxRank = true                         }),
    Cleave                    = Create({ Type = "Spell", ID = 845,   useMaxRank = true                         }),
    ThunderClap               = Create({ Type = "Spell", ID = 6343,  useMaxRank = true                         }),
    DemoralizingShout         = Create({ Type = "Spell", ID = 1160,  useMaxRank = true                         }),
    ShieldBlock               = Create({ Type = "Spell", ID = 2565                                             }),
    -- Defensifs
    ShieldWall                = Create({ Type = "Spell", ID = 871                                              }),
    LastStand                 = Create({ Type = "Spell", ID = 12975, isTalent = true                           }),
    SpellReflection           = Create({ Type = "Spell", ID = 23920                                            }),
    -- Menace / utilitaire
    Taunt                     = Create({ Type = "Spell", ID = 355                                              }),
    MockingBlow               = Create({ Type = "Spell", ID = 694,   useMaxRank = true                         }),
    ChallengingShout          = Create({ Type = "Spell", ID = 1161                                             }),
    ShieldBash                = Create({ Type = "Spell", ID = 72,    useMaxRank = true                         }),
    ConcussionBlow            = Create({ Type = "Spell", ID = 12809, isTalent = true                           }),
    -- Rage / buffs
    Bloodrage                 = Create({ Type = "Spell", ID = 2687                                             }),
    BerserkerRage             = Create({ Type = "Spell", ID = 18499                                            }),
    BattleShout               = Create({ Type = "Spell", ID = 6673,  useMaxRank = true                         }),
    CommandingShout           = Create({ Type = "Spell", ID = 469                                              }),
    -- Consumables
    MightyRagePotion          = Create({ Type = "Potion", ID = 13442                                           }),
    -- Hidden (talents trackes)
    FocusedRage               = Create({ Type = "Spell", ID = 29787, Hidden = true, isTalent = true, useMaxRank = true }),
    TacticalMastery           = Create({ Type = "Spell", ID = 12295, Hidden = true, isTalent = true, useMaxRank = true }),
}

Player:RegisterShield()

local A = setmetatable(Action[Action.PlayerClass], { __index = Action })

--------------------------------------------------------------------------
-- [[ CONDITIONS ]]
--------------------------------------------------------------------------
local Temp = {
    AttackTypes               = { "TotalImun", "DamagePhysImun" },
    AuraForKick               = { "TotalImun", "DamagePhysImun", "KickImun" },
}

local function GetStance()
    return GetShapeshiftForm() or 0
end

local function InMelee(unitID)
    return A.ShieldSlam:IsInRange(unitID)
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

-- Rage a reserver pour ne jamais retarder Shield Slam (la regle n°1
-- des top parses : "only HS if Shield Slam stays on cooldown")
local function ShieldSlamReserve()
    if not A.ShieldSlam:IsBlockedBySpellBook() and A.ShieldSlam:GetCooldown() <= GetGCD() + GetCurrentGCD() then
        return A.ShieldSlam:GetSpellPowerCostCache()
    end
    return 0
end

--------------------------------------------------------------------------
-- [[ ROTATION : META 3 (Prot DPS max) ]]
--------------------------------------------------------------------------
A[3] = function(icon)
    local inStance                        = GetStance()
    local combatTime                      = Unit("player"):CombatTime()
    local inCombat                        = combatTime > 0
    local inAoE                           = ToggleOr("AoE", false)
    local myRage                          = Unit("player"):Power()
    local isTarget, isTargetInMelee

    if IsUnitEnemy("target") then
        isTarget                          = "target"
        isTargetInMelee                   = InMelee(isTarget)
    end

    -- StopCast : HS/Cleave en file sur cible devenue immunisee
    if ToggleOr("StopCast", true) and isTarget then
        if A.HeroicStrike:IsSpellCurrent() and not A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) then
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end
        if A.Cleave:IsSpellCurrent() and not A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) then
            return A:Show(icon, ACTION_CONST_STOPCAST)
        end
    end

    -- Shout : hors combat / pas de cible
    local shoutToUse = ToggleOr("ShoutToUse", "CommandingShout")
    if shoutToUse ~= "OFF" and A[shoutToUse] and (not inCombat or not isTarget) and A[shoutToUse]:IsReady("player") and Unit("player"):HasBuffs(A[shoutToUse].ID) <= GetGCD() + GetCurrentGCD() then
        return A[shoutToUse]:Show(icon)
    end

    -- Return : pas de cible
    if not isTarget then
        if inCombat and ToggleOr("AutoTarget", true) then
            return A:Show(icon, ACTION_CONST_AUTOTARGET)
        end
        return -- nil
    end

    -- Stance : tout le kit prot vit en Posture defensive
    if inStance ~= 2 and A.DefensiveStance:IsReady("player") and (myRage <= A.TacticalMastery:GetTalentRank() * 5 + 10 or not inCombat) then
        return A.DefensiveStance:Show(icon)
    end

    -- Bloodrage : on cooldown (la rage d'un tank ne doit jamais plafonner
    -- ni manquer), garde de PV reglable
    if myRage < (80 - HeroicStrikeAdjustedPower()) and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 35) then
        return A.Bloodrage:Show(icon)
    end

    -- [[ SELF DEFENSE ]]
    if inCombat then
        -- ShieldWall
        local swHP = ToggleOr("ShieldWallHP", 25)
        if swHP > 0 and Unit("player"):HealthPercent() <= swHP and A.ShieldWall:IsReadyByPassCastGCD("player", nil, nil, true) and inStance == 2 then
            return A.ShieldWall:Show(icon)
        end

        -- LastStand
        local lsHP = ToggleOr("LastStandHP", 35)
        if lsHP > 0 and Unit("player"):HealthPercent() <= lsHP and A.LastStand:IsReadyByPassCastGCD("player", nil, nil, true) then
            return A.LastStand:Show(icon)
        end
    end

    -- Interrupt : ShieldBash (5-mans / trash casteurs)
    if ToggleOr("Interrupt-ShieldBash", true) and isTargetInMelee and Player:HasShield(true) then
        local castLeft, _, _, _, notInterruptAble = Unit(isTarget):IsCastingRemains()
        if castLeft and castLeft > GetPing() + 0.1 and not notInterruptAble and A.ShieldBash:IsReady(isTarget) and A.ShieldBash:AbsentImun(isTarget, Temp.AuraForKick) then
            return A.ShieldBash:Show(icon)
        end
    end

    -- Return : rien a faire hors melee
    if not isTargetInMelee then
        return -- nil
    end

    -- [[ BURST ]] : racials + trinkets DPS (toggle Burst du core)
    if inCombat and BurstIsON(isTarget) and A.AbsentImun(nil, isTarget, Temp.AttackTypes) then
        if A.Berserking:AutoRacial(isTarget) then
            return A.Berserking:Show(icon)
        end

        if A.BloodFury:AutoRacial(isTarget) then
            return A.BloodFury:Show(icon)
        end

        if A.Trinket1:IsReady(isTarget) and A.Trinket1:IsItemDamager() then
            return A.Trinket1:Show(icon)
        end

        if A.Trinket2:IsReady(isTarget) and A.Trinket2:IsItemDamager() then
            return A.Trinket2:Show(icon)
        end

        if ToggleOr("MightyRagePotion", false) and myRage < 25 and A.MightyRagePotion:IsReady("player") then
            return A.MightyRagePotion:Show(icon)
        end
    end

    -- ShieldBlock : on cooldown en combat (hors GCD) — anti-crush ET
    -- generateur de procs Revenge (les blocks subis activent Revenge)
    if ToggleOr("ShieldBlock", true) and inCombat and inStance == 2 and Player:HasShield(true) and A.ShieldBlock:IsReadyByPassCastGCD("player", nil, nil, true) and myRage >= A.ShieldBlock:GetSpellPowerCostCache() + ShieldSlamReserve() + HeroicStrikeAdjustedPower() and Unit("player"):HasBuffs(A.ShieldBlock.ID, true) == 0 then
        return A.ShieldBlock:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ CORE : Shield Slam > Revenge > Devastate ]]
    ----------------------------------------------------------------------

    -- ThunderClap : maintien du debuff (toggle — OFF = plus de DPS si un
    -- autre guerrier l'applique)
    if ToggleOr("MaintainThunderClap", false) and A.ThunderClap:IsReady(isTarget, true) and myRage >= A.ThunderClap:GetSpellPowerCostCache() + ShieldSlamReserve() + HeroicStrikeAdjustedPower() and Unit(isTarget):HasDeBuffs(A.ThunderClap.ID) <= GetGCD() + GetCurrentGCD() and A.ThunderClap:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.ThunderClap:Show(icon)
    end

    -- DemoralizingShout : maintien (toggle, OFF par defaut = DPS)
    if ToggleOr("MaintainDemoShout", false) and A.DemoralizingShout:IsReady(isTarget, true) and myRage >= A.DemoralizingShout:GetSpellPowerCostCache() + ShieldSlamReserve() + HeroicStrikeAdjustedPower() and Unit(isTarget):HasDeBuffs(A.DemoralizingShout.ID) <= GetGCD() + GetCurrentGCD() and A.DemoralizingShout:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.DemoralizingShout:Show(icon)
    end

    -- ShieldSlam : ON COOLDOWN, priorite absolue (plus gros hit du kit)
    if A.ShieldSlam:IsReady(isTarget) and Player:HasShield(true) and myRage >= A.ShieldSlam:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() and A.ShieldSlam:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.ShieldSlam:Show(icon)
    end

    -- Revenge : sur proc (dodge/parry/block subi), quasi gratuit
    if inStance == 2 and A.Revenge:IsReady(isTarget) and myRage >= A.Revenge:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() and A.Revenge:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Revenge:Show(icon)
    end

    -- Devastate : filler sur chaque GCD libre (monte et refresh Sunder x5)
    -- Fallback SunderArmor si Devastate n'est pas talente
    if not A.Devastate:IsBlockedBySpellBook() and A.Devastate:GetTalentRank() > 0 then
        if inStance == 2 and A.Devastate:IsReady(isTarget) and Player:HasShield(true) and myRage >= A.Devastate:GetSpellPowerCostCache() + ShieldSlamReserve() + HeroicStrikeAdjustedPower() and A.Devastate:AbsentImun(isTarget, Temp.AttackTypes) then
            return A.Devastate:Show(icon)
        end
    else
        if A.SunderArmor:IsReady(isTarget) and myRage >= A.SunderArmor:GetSpellPowerCostCache() + ShieldSlamReserve() + HeroicStrikeAdjustedPower() and Unit(isTarget):HasDeBuffsStacks(A.SunderArmor.ID, true) < 5 and A.SunderArmor:AbsentImun(isTarget, Temp.AttackTypes) then
            return A.SunderArmor:Show(icon)
        end
    end

    -- Cleave : vidange de rage AoE (hors GCD)
    if inAoE and not IsCurrentAttack() and MultiUnits:GetBySpell(A.ShieldSlam, 7) >= 2 and A.Cleave:IsReady(isTarget, true) and A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("Cleave-PWR", 50) then
        return A.Cleave:Show(icon)
    end

    -- HeroicStrike : vidange de rage mono (hors GCD) — le seuil garantit
    -- que Shield Slam et Shield Block ne seront jamais affames
    if not inAoE and not IsCurrentAttack() and A.HeroicStrike:IsReady(isTarget) and A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("HeroicStrike-PWR", 50) then
        return A.HeroicStrike:Show(icon)
    end
end

--------------------------------------------------------------------------
-- [[ META 5 : defensifs passifs ]]
--------------------------------------------------------------------------
A[5] = function(icon)
    -- LastStand en catastrophe (icone passive)
    if Unit("player"):CombatTime() > 0 and Unit("player"):HealthPercent() <= 20 and A.LastStand:IsReadyP("player") then
        return A.LastStand:Show(icon)
    end
end

-- Nil (metas non utilisees par ce profil)
A[1] = nil
A[2] = nil
A[4] = nil
A[6] = nil
A[7] = nil
A[8] = nil
