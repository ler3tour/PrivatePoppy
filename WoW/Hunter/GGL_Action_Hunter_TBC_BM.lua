--------------------------------------------------------------------------
-- [GGL] Hunter TBC BM - Rotation CodeSnippet (Order 1)
--
-- Chasseur Beast Mastery 41/20/0 oriente parse (PvE raid).
-- TOUT le parse BM repose sur le shot weaving : ne JAMAIS retarder un
-- Auto Shot. Cycle "1:1" : Auto -> Steady -> Auto -> Steady...
--
--   1. Auto Shot sacre : Steady Shot ne part que si son cast tient
--      AVANT le prochain auto (garde sur le swing timer ranged)
--   2. Kill Command a chaque proc (hors GCD, ne clippe rien)
--   3. Bestial Wrath + Rapid Fire + trinkets + Haste Potion groupes
--   4. Serpent Sting / Arcane / Multi-Shot en toggles (OFF par defaut :
--      a haut gear ils clippent les autos et font PERDRE du DPS)
--   5. Aspect du Faucon maintenu, bascule Vipere auto a mana basse
--
-- Pre-pull manuel : Hunter's Mark, Misdirection, pet envoye.
--------------------------------------------------------------------------

local _G, setmetatable, ipairs, pcall                = _G, setmetatable, ipairs, pcall

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

local ACTION_CONST_AUTOSHOOT                         = CONST.AUTOSHOOT
local ACTION_CONST_AUTOTARGET                        = CONST.AUTOTARGET

--------------------------------------------------------------------------
-- [[ SPELLS - TBC IDs ]]
--------------------------------------------------------------------------
Action[Action.PlayerClass] = {
    -- Racials
    BloodFury                 = Create({ Type = "Spell", ID = 20572                                            }),
    Berserking                = Create({ Type = "Spell", ID = 20554                                            }),
    -- Core BM
    AutoShot                  = Create({ Type = "Spell", ID = 75,    Hidden = true, QueueForbidden = true, BlockForbidden = true }),
    SteadyShot                = Create({ Type = "Spell", ID = 34120                                            }), -- TBC only
    KillCommand               = Create({ Type = "Spell", ID = 34026                                            }), -- TBC only
    BestialWrath              = Create({ Type = "Spell", ID = 19574, isTalent = true                           }),
    RapidFire                 = Create({ Type = "Spell", ID = 3045                                             }),
    Intimidation              = Create({ Type = "Spell", ID = 19577, isTalent = true                           }),
    -- Shots optionnels
    SerpentSting              = Create({ Type = "Spell", ID = 1978,  useMaxRank = true                         }),
    ArcaneShot                = Create({ Type = "Spell", ID = 3044,  useMaxRank = true                         }),
    MultiShot                 = Create({ Type = "Spell", ID = 2643,  useMaxRank = true                         }),
    -- Aspects / utilitaire
    AspectoftheHawk           = Create({ Type = "Spell", ID = 13165, useMaxRank = true                         }),
    AspectoftheViper          = Create({ Type = "Spell", ID = 34074                                            }), -- TBC only
    HuntersMark               = Create({ Type = "Spell", ID = 1130,  useMaxRank = true                         }),
    MendPet                   = Create({ Type = "Spell", ID = 136,   useMaxRank = true                         }),
    Misdirection              = Create({ Type = "Spell", ID = 34477                                            }), -- TBC only
    FeignDeath                = Create({ Type = "Spell", ID = 5384                                             }),
    -- Consumables
    HastePotion               = Create({ Type = "Potion", ID = 22838                                           }),
    SuperSapperCharge         = Create({ Type = "Item",   ID = 23827                                           }),
    -- Hidden (talents trackes)
    SerpentsSwiftness         = Create({ Type = "Spell", ID = 34466, Hidden = true, isTalent = true, useMaxRank = true }),
}

local A = setmetatable(Action[Action.PlayerClass], { __index = Action })

--------------------------------------------------------------------------
-- [[ CONDITIONS ]]
--------------------------------------------------------------------------
local Temp = {
    AttackTypes               = { "TotalImun", "DamagePhysImun" },
    -- Tables de TOUS les rangs
    AuraSerpentSting          = { 1978, 13549, 13550, 13551, 13552, 13553, 13554, 13555, 25295, 27016 },
    AuraHuntersMark           = { 1130, 14323, 14324, 14325 },
    AuraAspectHawk            = { 13165, 14318, 14319, 14320, 14321, 14322, 25296, 27044 },
    AuraAspectViper           = { 34074 },
}

local function ToggleOr(key, default)
    local value = GetToggle(2, key)
    if value == nil then
        return default
    end
    return value
end

-- Temps restant avant le prochain Auto Shot (0 = inconnu -> pas de garde)
-- Player:GetSwing(3) = ranged dans le framework ; pcall par securite
local function GetRangedSwing()
    local ok, value = pcall(function() return Player:GetSwing(3) end)
    if ok and type(value) == "number" and value > 0 then
        return value
    end
    return 0
end

-- Le cast tient-il avant le prochain auto ? (LA regle du weaving)
local function FitsBeforeAutoShot(castObject)
    local swing = GetRangedSwing()
    if swing <= 0 then
        return true -- timer indisponible : on ne bloque pas la rotation
    end
    local castTime = castObject:GetSpellCastTime() or 0
    return swing > castTime + GetPing() + 0.1
end

local function PetIsAlive()
    return Unit("pet"):IsExists() and not Unit("pet"):IsDead()
end

--------------------------------------------------------------------------
-- [[ ROTATION : META 3 (BM parse) ]]
--------------------------------------------------------------------------
A[3] = function(icon)
    local combatTime                      = Unit("player"):CombatTime()
    local inCombat                        = combatTime > 0
    local inAoE                           = ToggleOr("AoE", false)
    local manaPercent                     = Player:ManaPercentage()
    local isTarget

    if IsUnitEnemy("target") then
        isTarget                          = "target"
    end

    -- Cast en cours (Steady) : on ne propose rien, on laisse finir
    local myCastLeft = Unit("player"):IsCastingRemains()
    if myCastLeft and myCastLeft > 0 then
        return -- nil
    end

    -- Aspect : Vipere auto a mana basse, retour Faucon sinon (toggle)
    if ToggleOr("AutoViper", true) then
        if manaPercent <= ToggleOr("ViperMana", 10) and Unit("player"):HasBuffs(Temp.AuraAspectViper, true) == 0 and A.AspectoftheViper:IsReady("player") then
            return A.AspectoftheViper:Show(icon)
        end
        if manaPercent >= 60 and Unit("player"):HasBuffs(Temp.AuraAspectViper, true) > 0 and A.AspectoftheHawk:IsReady("player") then
            return A.AspectoftheHawk:Show(icon)
        end
    end

    -- Faucon : maintien hors combat
    if not inCombat and Unit("player"):HasBuffs(Temp.AuraAspectHawk, true) == 0 and Unit("player"):HasBuffs(Temp.AuraAspectViper, true) == 0 and A.AspectoftheHawk:IsReady("player") then
        return A.AspectoftheHawk:Show(icon)
    end

    -- Return : pas de cible
    if not isTarget then
        if inCombat and ToggleOr("AutoTarget", true) then
            return A:Show(icon, ACTION_CONST_AUTOTARGET)
        end
        return -- nil
    end

    -- MendPet : OFF par defaut (canalisation 5 s = grosse perte DPS)
    if ToggleOr("AutoMendPet", false) and PetIsAlive() and Unit("pet"):HealthPercent() <= ToggleOr("MendPetHP", 35) and A.MendPet:IsReady("pet") then
        return A.MendPet:Show(icon)
    end

    -- HuntersMark : pose si absent (toggle)
    if ToggleOr("UseHuntersMark", true) and Unit(isTarget):HasDeBuffs(Temp.AuraHuntersMark) == 0 and A.HuntersMark:IsReady(isTarget) then
        return A.HuntersMark:Show(icon)
    end

    -- KillCommand : HORS GCD, a chaque proc (crit du chasseur), ne
    -- clippe rien — priorite absolue
    if PetIsAlive() and A.KillCommand:IsReadyByPassCastGCD(isTarget, true) then
        return A.KillCommand:Show(icon)
    end

    -- [[ BURST ]] : Bestial Wrath + Rapid Fire + trinkets groupes
    if inCombat and BurstIsON(isTarget) and A.AbsentImun(nil, isTarget, Temp.AttackTypes) then
        if ToggleOr("UseBestialWrath", true) and PetIsAlive() and A.BestialWrath:IsReady("player") then
            return A.BestialWrath:Show(icon)
        end

        if ToggleOr("UseRapidFire", true) and A.RapidFire:IsReadyByPassCastGCD("player") and Unit("player"):HasBuffs(A.RapidFire.ID, true) == 0 then
            return A.RapidFire:Show(icon)
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

        if ToggleOr("HastePotion", true) and Unit(isTarget):IsBoss() and A.HastePotion:IsReady("player") and (Unit("player"):HasBuffs(A.RapidFire.ID, true) > 0 or A.RapidFire:GetCooldown() > 120) then
            return A.HastePotion:Show(icon)
        end
    end

    ----------------------------------------------------------------------
    -- [[ SHOT WEAVING ]] — l'Auto Shot est sacre
    ----------------------------------------------------------------------

    -- SerpentSting : toggle OFF par defaut (clippe le 1:1 a haut gear)
    if ToggleOr("UseSerpentSting", false) and Unit(isTarget):HasDeBuffs(Temp.AuraSerpentSting, true) == 0 and Unit(isTarget):TimeToDie() > 15 and A.SerpentSting:IsReady(isTarget) and A.SerpentSting:AbsentImun(isTarget, Temp.AttackTypes) and FitsBeforeAutoShot(A.SerpentSting) then
        return A.SerpentSting:Show(icon)
    end

    -- MultiShot : mode AoE (3+) ou toggle single (clippe le 1:1)
    if (inAoE and MultiUnits:GetByRange(10, 3) >= 3 or ToggleOr("UseMultiShot", false)) and A.MultiShot:IsReadyByPassCastGCD(isTarget, nil, nil, true) and A.MultiShot:AbsentImun(isTarget, Temp.AttackTypes) and FitsBeforeAutoShot(A.MultiShot) then
        return A.MultiShot:Show(icon)
    end

    -- ArcaneShot : toggle OFF par defaut (clippe le 1:1)
    if ToggleOr("UseArcaneShot", false) and A.ArcaneShot:IsReadyByPassCastGCD(isTarget, nil, nil, true) and A.ArcaneShot:AbsentImun(isTarget, Temp.AttackTypes) and FitsBeforeAutoShot(A.ArcaneShot) then
        return A.ArcaneShot:Show(icon)
    end

    -- SteadyShot : LE filler — seulement si son cast tient avant le
    -- prochain Auto Shot (jamais de clipping)
    if A.SteadyShot:IsReady(isTarget) and A.SteadyShot:AbsentImun(isTarget, Temp.AttackTypes) and FitsBeforeAutoShot(A.SteadyShot) then
        return A.SteadyShot:Show(icon)
    end

    -- Fenetre trop courte pour un Steady : on laisse l'Auto Shot partir
    return -- nil
end

--------------------------------------------------------------------------
-- [[ META 5 : passifs ]]
--------------------------------------------------------------------------
A[5] = function(icon)
    -- FeignDeath en catastrophe d'aggro (toggle, off par defaut)
    if ToggleOr("AutoFeignDeath", false) and Unit("player"):CombatTime() > 0 and Unit("player"):ThreatSituation() >= 2 and A.FeignDeath:IsReadyP("player") then
        return A.FeignDeath:Show(icon)
    end
end

-- Nil (metas non utilisees par ce profil)
A[1] = nil
A[2] = nil
A[4] = nil
A[6] = nil
A[7] = nil
A[8] = nil
