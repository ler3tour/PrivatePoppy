--------------------------------------------------------------------------
-- [Storm] Warrior TBC PvP - Rotation CodeSnippet (Order 1)
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
local GetSpellInfo                                   = _G.GetSpellInfo
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
    PummelFocus               = Create({ Type = "Spell", ID = 6552,  useMaxRank = true, Desc = "Focus",
                                         Macro = "/cast [@focus]spell:thisID"                                  }),
    ShieldBash                = Create({ Type = "Spell", ID = 72,    useMaxRank = true                         }),
    SpellReflection           = Create({ Type = "Spell", ID = 23920                                            }), -- TBC only
    Disarm                    = Create({ Type = "Spell", ID = 676,                Click = { macrobefore = "/stopcasting" } }),
    IntimidatingShout         = Create({ Type = "Spell", ID = 5246,               Click = { macrobefore = "/stopcasting" } }),
    PiercingHowl              = Create({ Type = "Spell", ID = 12323, isTalent = true                           }),
    Hamstring                 = Create({ Type = "Spell", ID = 1715,  useMaxRank = true                         }),
    Charge                    = Create({ Type = "Spell", ID = 100,   useMaxRank = true                         }),
    Intercept                 = Create({ Type = "Spell", ID = 20252, useMaxRank = true                         }),
    Intervene                 = Create({ Type = "Spell", ID = 3411                                             }), -- TBC only
    InterveneParty1           = Create({ Type = "Spell", ID = 3411,  Desc = "@party1",
                                         Macro = "/cast [@party1]spell:thisID"                                 }),
    InterveneParty2           = Create({ Type = "Spell", ID = 3411,  Desc = "@party2",
                                         Macro = "/cast [@party2]spell:thisID"                                 }),
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
    ReflectUnits              = { "target", "focus", "mouseover", "arena1", "arena2", "arena3", "arena4", "arena5" },
    -- Tables de TOUS les rangs : les debuffs appliques sont au rang max,
    -- un check sur l'ID de base seul peut ne pas matcher
    AuraHamstring             = { 1715, 7372, 7373, 25212 },
    AuraPiercingHowl          = { 12323 },
    AuraRend                  = { 772, 6546, 6547, 6548, 11572, 11573, 11574, 25208 },
    ShoutAuras                = {
        BattleShout           = { 6673, 5242, 6192, 11549, 11550, 11551, 25289, 2048 },
        CommandingShout       = { 469 },
    },
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

-- Sorts prioritaires pour le Spell Reflection et fears a anticiper
-- (noms localises via GetSpellInfo, compatibles client FR)
local ReflectImportant = {}
local FearCasts        = {}
do
    -- Fear, Howl of Terror, Polymorph, Cyclone, Entangling Roots,
    -- Frostbolt, Fireball, Pyroblast, Shadow Bolt, Soul Fire, Immolate,
    -- Mind Control, Mind Blast, Starfire, Wrath, Lightning Bolt, Chain Lightning
    local reflectIDs = { 5782, 5484, 118, 33786, 339, 116, 133, 11366, 686, 6353, 348, 605, 8092, 2912, 5176, 403, 421 }
    for i = 1, #reflectIDs do
        local name = GetSpellInfo(reflectIDs[i])
        if name then
            ReflectImportant[name] = true
        end
    end

    -- Fear, Howl of Terror
    local fearIDs = { 5782, 5484 }
    for i = 1, #fearIDs do
        local name = GetSpellInfo(fearIDs[i])
        if name then
            FearCasts[name] = true
        end
    end
end

-- Sorts a kicker en priorite (heals, CC, resurrections) pour le mode
-- "economiser le Pummel pour le heal"
local KickImportant = {}
do
    -- Heals : Healing Touch, Regrowth, Flash of Light, Holy Light,
    -- Greater Heal, Flash Heal, Heal, Lesser Heal, Prayer of Healing,
    -- Binding Heal, Chain Heal, Healing Wave, Lesser Healing Wave
    -- CC : Fear, Howl of Terror, Polymorph, Cyclone, Entangling Roots,
    -- Mind Control, Hibernate
    -- Rez : Rebirth, Resurrection, Redemption, Ancestral Spirit
    local kickIDs = { 5185, 8936, 19750, 635, 2060, 2061, 2054, 2050, 596, 32546, 1064, 331, 8004,
                      5782, 5484, 118, 33786, 339, 605, 2637,
                      20484, 2006, 7328, 2008 }
    for i = 1, #kickIDs do
        local name = GetSpellInfo(kickIDs[i])
        if name then
            KickImportant[name] = true
        end
    end
end

-- Trouve le soigneur du groupe (le druide en 2v2/3v3), retourne
-- l'unitID party et l'objet Intervene correspondant
local function GetHealerUnit()
    if Unit("party1"):Class() == "DRUID" then
        return "party1", A.InterveneParty1
    end
    if Unit("party2"):Class() == "DRUID" then
        return "party2", A.InterveneParty2
    end
end

-- Cherche un ennemi en train de caster SUR NOUS (pour Spell Reflection)
-- Avec le toggle SpellReflection-OnlyImportant : uniquement les sorts
-- qui valent le swap (CC et gros nukes)
local function GetReflectUnit()
    local onlyImportant = GetToggle(2, "SpellReflection-OnlyImportant")
    for _, unitID in ipairs(Temp.ReflectUnits) do
        if IsUnitEnemy(unitID) and UnitIsUnit(unitID .. "target", "player") then
            local castLeft, _, _, castName = Unit(unitID):IsCastingRemains()
            if castLeft and castLeft > GetPing() + 0.1 and (not onlyImportant or (castName and ReflectImportant[castName])) then
                return unitID, castLeft
            end
        end
    end
end

-- Validation d'un kick sur unitID : cast en cours, kickable, filtre
-- "sorts importants", anti-fake (laisse le cast avancer) et anti-overlap
-- avec un Spell Reflection deja actif
local function KickIsValid(unitID)
    local castLeft, castDone, _, castName, notInterruptAble = Unit(unitID):IsCastingRemains()
    if not castLeft or castLeft <= GetPing() + 0.1 or notInterruptAble then
        return
    end

    -- Anti-overlap : ce cast nous cible et va etre renvoye par le reflect
    if UnitIsUnit(unitID .. "target", "player") and Unit("player"):HasBuffs(A.SpellReflection.ID, true) > 0 then
        return
    end

    -- Pro : ne kicker que les heals/CC/rez (economise le kick pour le heal)
    if ToggleOr("Interrupt-OnlyImportant", false) and not (castName and KickImportant[castName]) then
        return
    end

    -- Anti-fake : ne kicker qu'apres X % du cast ecoule
    local atCastDone = ToggleOr("Interrupt-AtCastDone", 30)
    if atCastDone > 0 and castDone then
        if castDone <= 1 then
            castDone = castDone * 100 -- normalise l'echelle 0-1
        end
        if castDone < atCastDone then
            return
        end
    end

    return true
end

-- Fear en cours de cast sur nous : Fear (cible) ou Howl of Terror (zone)
local function GetIncomingFearUnit()
    for _, unitID in ipairs(Temp.ReflectUnits) do
        if IsUnitEnemy(unitID) then
            local castLeft, _, _, castName = Unit(unitID):IsCastingRemains()
            if castLeft and castLeft > GetPing() + 0.1 and castName and FearCasts[castName] and (UnitIsUnit(unitID .. "target", "player") or Unit(unitID):GetRange() <= 10) then
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
    -- [[ POSTURE DEFENSIVE FORCEE ]] (bouton de la barre)
    -- ON : bascule en Def et Y RESTE tant que le toggle est actif —
    -- tous les stance dances automatiques sont suspendus. Les kicks
    -- passent sur Shield Bash, Reflect/Disarm restent disponibles.
    ----------------------------------------------------------------------
    local forceDef = ToggleOr("ForceDefStance", false)
    if forceDef and inStance ~= 2 and A.DefensiveStance:IsReady("player") then
        return A.DefensiveStance:Show(icon)
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

    -- Retour dual-wield / 2H apres le reflect (hors fenetre de cast
    -- ennemie) — uniquement si une arme est disponible en sac, sinon le
    -- bloc tournerait en boucle et gelerait toute la rotation
    if ToggleOr("SpellReflection-AutoSwap", true) and Player:HasShield(true) and ((not Player:HasWeaponTwoHand(true) and Player:HasWeaponTwoHand()) or (not Player:HasWeaponOffHand(true) and Player:HasWeaponOffHand())) and not GetReflectUnit() and (A.SpellReflection:GetCooldown() > 3 or Unit("player"):HasBuffs(A.SpellReflection.ID, true) > 0 or not ToggleOr("UseSpellReflection", true)) then
        return A.SwapWeapon:Show(icon)
    end

    ----------------------------------------------------------------------
    -- [[ BERSERKER RAGE PREVENTIF ]]
    -- Un Fear/Howl of Terror part sur nous : immunite AVANT l'impact
    -- (les guides : "use Berserker Rage BEFORE they cast Fear")
    ----------------------------------------------------------------------
    if ToggleOr("UseBerserkerRage-PreFear", true) and A.BerserkerRage:GetCooldown() == 0 and Unit("player"):HasBuffs(A.BerserkerRage.ID, true) == 0 and Unit("player"):HasBuffs(A.DeathWish.ID, true) == 0 then
        local fearUnit, fearCastLeft = GetIncomingFearUnit()
        if fearUnit then
            if inStance == 3 and A.BerserkerRage:IsReadyByPassCastGCD("player") then
                return A.BerserkerRage:Show(icon)
            end

            -- Stance dance d'urgence : etre feared coute plus cher que la rage
            if not forceDef and inStance ~= 3 and fearCastLeft > 0.8 and A.BerserkerStance:IsReady("player") then
                return A.BerserkerStance:Show(icon)
            end
        end
    end

    ----------------------------------------------------------------------
    -- [[ INTERRUPTS ]]
    -- Toggle a la volee : /run Action.SetToggle({2, "Interrupt-Pummel"})
    ----------------------------------------------------------------------
    local kickUnit = isMouse or isTarget
    if kickUnit and KickIsValid(kickUnit) then
        -- Pummel (Berserker Stance uniquement, pas de switch auto)
        if ToggleOr("Interrupt-Pummel", true) and inStance == 3 and A.Pummel:IsReady(kickUnit) and A.Pummel:AbsentImun(kickUnit, Temp.AuraForKick) then
            return A.Pummel:Show(icon)
        end

        -- ShieldBash (Battle/Def + bouclier deja equipe)
        if ToggleOr("Interrupt-ShieldBash", false) and (inStance == 1 or inStance == 2) and Player:HasShield(true) and A.ShieldBash:IsReady(kickUnit) and A.ShieldBash:AbsentImun(kickUnit, Temp.AuraForKick) then
            return A.ShieldBash:Show(icon)
        end
    end

    -- Pummel @focus : kick le focus sans changer de cible (WLD : mettre
    -- le healer/caster adverse en focus)
    if ToggleOr("Interrupt-Focus", true) and inStance == 3 and IsUnitEnemy("focus") and InMelee("focus") and KickIsValid("focus") then
        if A.PummelFocus:IsReadyByPassCastGCD("focus") and A.Pummel:GetCooldown() == 0 and myRage >= A.Pummel:GetSpellPowerCostCache() and A.Pummel:AbsentImun("focus", Temp.AuraForKick) then
            return A.PummelFocus:Show(icon)
        end
    end

    ----------------------------------------------------------------------
    -- [[ INTERVENE : proteger le druide ]]
    -- 2v2/3v3 : Intervene sur le heal quand il encaisse (Def Stance requise)
    ----------------------------------------------------------------------
    if ToggleOr("Intervene-Healer", true) and inCombat and A.Intervene:GetCooldown() == 0 then
        local healerUnit, interveneObject = GetHealerUnit()
        if healerUnit and not Unit(healerUnit):IsDead() and Unit(healerUnit):GetRange() <= 25 and Unit(healerUnit):HealthPercent() <= ToggleOr("Intervene-HealerHP", 60) and Unit(healerUnit):GetRealTimeDMG() > 0 then
            if inStance == 2 and myRage >= A.Intervene:GetSpellPowerCostCache() then
                return interveneObject:Show(icon)
            end

            if inStance ~= 2 and A.DefensiveStance:IsReady("player") then
                return A.DefensiveStance:Show(icon)
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

    -- Shout : Battle ou Commanding selon le dropdown UI
    local shoutToUse = ToggleOr("ShoutToUse", "BattleShout")
    if shoutToUse ~= "OFF" and A[shoutToUse] and (not inCombat or (not isTarget and not isMouse)) and A[shoutToUse]:IsReady("player") and Unit("player"):HasBuffs(Temp.ShoutAuras[shoutToUse] or A[shoutToUse].ID) <= GetGCD() + GetCurrentGCD() then
        return A[shoutToUse]:Show(icon)
    end

    -- Return : pas de cible primaire
    if not isTarget and not isMouse then
        return -- nil
    end

    -- [[ NO COMBAT - PRE COMBAT ]]
    if not inCombat then
        if ToggleOr("UseBloodrage", true) and myRage <= 80 and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 70) then
            return A.Bloodrage:Show(icon)
        end

        -- Charge (BattleStance requis)
        if not forceDef and ToggleOr("UseCharge", true) and A.Charge:IsReady(isMouse or isTarget, nil, nil, nil, true) then
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
        if not forceDef and inStance ~= 3 and A.BerserkerStance:IsReady("player") and StanceKeepRage() >= A.Intercept:GetSpellPowerCostCache() then
            return A.BerserkerStance:Show(icon)
        end
        if inStance == 3 and A.Intercept:IsReady(isMouse or isTarget) then
            return A.Intercept:Show(icon)
        end
    end

    -- Hors melee : d'abord revenir en Berserker — posture de poursuite
    -- (Intercept, Berserker Rage), la rage ne sert a rien hors de portee
    if not isTargetInMelee then
        if not forceDef and inStance ~= 3 and A.BerserkerStance:IsReady("player") then
            return A.BerserkerStance:Show(icon)
        end
        return -- nil
    end

    ----------------------------------------------------------------------
    -- [[ CC A LA VOLEE ]]
    ----------------------------------------------------------------------
    -- IntimidatingShout : active le toggle quand tu veux le fear
    if ToggleOr("UseIntimidatingShout", false) and A.IntimidatingShout:IsReady(isTarget) and Unit(isTarget):GetRange() <= 8 and Unit(isTarget):IsControlAble("fear") and A.IntimidatingShout:AbsentImun(isTarget, Temp.AuraForFear) then
        return A.IntimidatingShout:Show(icon)
    end

    -- PiercingHowl : snare AoE COMPLEMENTAIRE — Hamstring reste le snare
    -- principal (15 s, root Imp Hamstring). Le howl ne part que si la
    -- cible n'est NI entravee NI dazee (check tous rangs) ET qu'il y a
    -- 2+ ennemis NON ralentis a toucher (ou Hamstring bloque)
    if ToggleOr("UsePiercingHowl", true) and A.PiercingHowl:IsTalentLearned() and A.PiercingHowl:IsReady("player") and myRage >= A.PiercingHowl:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() and Unit(isTarget):GetRange() <= 10 and Unit(isTarget):HasDeBuffs(Temp.AuraPiercingHowl) == 0 and Unit(isTarget):HasDeBuffs(Temp.AuraHamstring) == 0 and Unit(isTarget):IsControlAble("snare") and (MultiUnits:GetByRangeMissedDoTs(10, 2, A.PiercingHowl.ID, 6) >= 2 or A.Hamstring:IsBlocked() or A.Hamstring:IsBlockedBySpellBook()) then
        return A.PiercingHowl:Show(icon)
    end

    -- [[ BURST ]]
    if inCombat and BurstIsON(isTarget) and A.AbsentImun(nil, isTarget, Temp.AttackTypes) then
        local timetouseall = (DetermineCountGCDs(A.BloodFury, A.Berserking, A.Recklessness, A.DeathWish) * (GetGCD() * 3)) + GetCurrentGCD() + GetPing() + ACTION_CONST_CACHE_DEFAULT_TIMER + (TMW.UPD_INTV or 0)

        if ToggleOr("UseRacials", true) and A.Berserking:AutoRacial(isTarget) then
            return A.Berserking:Show(icon)
        end

        if ToggleOr("UseRacials", true) and A.BloodFury:AutoRacial(isTarget) then
            return A.BloodFury:Show(icon)
        end

        if ToggleOr("UseDeathWish", true) and A.DeathWish:IsReady("player") and myRage >= A.DeathWish:GetSpellPowerCostCache() + 30 then
            return A.DeathWish:Show(icon)
        end

        if ToggleOr("UseRecklessness", true) and inStance == 3 and A.Recklessness:IsReady("player") and (A.DeathWish:GetCooldown() > 30 or Unit("player"):HasBuffs(A.DeathWish.ID) > 0 or A.DeathWish:GetTalentRank() == 0) then
            return A.Recklessness:Show(icon)
        end

        if ToggleOr("UseTrinket1", true) and A.Trinket1:IsReady(isTarget) and A.Trinket1:IsItemDamager() then
            return A.Trinket1:Show(icon)
        end

        if ToggleOr("UseTrinket2", true) and A.Trinket2:IsReady(isTarget) and A.Trinket2:IsItemDamager() then
            return A.Trinket2:Show(icon)
        end

        -- MightyRagePotion : dans la fenetre de burst si la rage manque
        if ToggleOr("MightyRagePotion", true) and myRage < 25 and A.MightyRagePotion:IsReady("player") then
            return A.MightyRagePotion:Show(icon)
        end
    end

    -- Bloodrage : rage quasi gratuite
    if ToggleOr("UseBloodrage", true) and inCombat and myRage < (80 - HeroicStrikeAdjustedPower()) and A.Bloodrage:IsReady("player") and Unit("player"):HealthPercent() >= ToggleOr("Bloodrage-LimitHP", 70) then
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

        if not forceDef and inStance ~= 1 and A.BattleStance:IsReady("player") and myRage - StanceKeepRage() <= 10 + A.Overpower:GetSpellPowerCostCache() then
            return A.BattleStance:Show(icon)
        end
    end

    -- MortalStrike : coeur du build Arms (debuff soins -50% a maintenir)
    if ToggleOr("UseMortalStrike", true) and A.MortalStrike:IsReady(isTarget) and A.MortalStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.MortalStrike:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() then
        return A.MortalStrike:Show(icon)
    end

    -- Execute : sous 20 %, prioritaire sur Whirlwind (toute la rage y passe)
    if ToggleOr("UseExecute", true) and executePhase and A.Execute:IsReady(isTarget) and A.Execute:AbsentImun(isTarget, Temp.AttackTypes) then
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

    -- VictoryRush : gratuit et gros hit — meilleurs degats par point de
    -- rage du kit, toujours avant Whirlwind
    if ToggleOr("UseVictoryRush", true) and A.VictoryRush:IsReady(isTarget) and A.VictoryRush:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.VictoryRush:Show(icon)
    end

    -- Whirlwind : Berserker Stance, en reservant la rage d'un MortalStrike
    -- imminent, jamais si un CC cassable (sheep/sap) est a portee
    if ToggleOr("UseWhirlwind", true) and not executePhase and inStance == 3 and A.Whirlwind:IsReady(isTarget, true) and A.Whirlwind:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.Whirlwind:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() + ((A.MortalStrike:GetCooldown() <= GetGCD() and not A.MortalStrike:IsBlockedBySpellBook()) and A.MortalStrike:GetSpellPowerCostCache() or 0) and (not A.IsInPvP or not EnemyTeam():IsBreakAble(8)) then
        return A.Whirlwind:Show(icon)
    end

    -- Hamstring : uptime du snare sur les joueurs, en reservant la rage
    -- d'un MortalStrike imminent (avant Rend : une cible qui s'echappe
    -- coute plus cher qu'un restealth potentiel)
    if ToggleOr("UseHamstring", true) and Unit(isTarget):IsPlayer() and A.Hamstring:IsReady(isTarget) and myRage >= A.Hamstring:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() + ((A.MortalStrike:GetCooldown() <= GetGCD() and not A.MortalStrike:IsBlockedBySpellBook()) and A.MortalStrike:GetSpellPowerCostCache() or 0) and Unit(isTarget):HasDeBuffs(Temp.AuraHamstring) <= GetGCD() + GetCurrentGCD() and Unit(isTarget):IsControlAble("snare") and A.Hamstring:AbsentImun(isTarget, Temp.AttackTypes) then
        return A.Hamstring:Show(icon)
    end

    -- Rend : anti-restealth sur Rogue/Druide ("keep Rend up 100%"),
    -- stance dance vers Battle si la rage ne se perd pas
    if ToggleOr("UseRend", true) and Unit(isTarget):IsPlayer() and Unit(isTarget):CombatTime() > 0 then
        local targetClass = Unit(isTarget):Class()
        if (targetClass == "ROGUE" or targetClass == "DRUID") and Unit(isTarget):HasDeBuffs(Temp.AuraRend, true) <= GetGCD() + GetCurrentGCD() and myRage >= A.Rend:GetSpellPowerCostCache() + HeroicStrikeAdjustedPower() and A.Rend:AbsentImun(isTarget, Temp.AttackTypes) then
            if (inStance == 1 or inStance == 2) and A.Rend:IsReady(isTarget) then
                return A.Rend:Show(icon)
            end

            if not forceDef and inStance == 3 and A.Rend:GetCooldown() == 0 and A.BattleStance:IsReady("player") and myRage - StanceKeepRage() <= 10 + A.Rend:GetSpellPowerCostCache() then
                return A.BattleStance:Show(icon)
            end
        end
    end

    -- Cleave : rage dump AoE (jamais si CC cassable autour)
    if ToggleOr("UseCleave", true) and inAoE and not IsCurrentAttack() and MultiUnits:GetBySpell(A.Hamstring, 7) >= 2 and A.Cleave:IsReady(isTarget, true) and A.Cleave:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("Cleave-PWR", 50) and (not A.IsInPvP or not EnemyTeam():IsBreakAble(5)) then
        return A.Cleave:Show(icon)
    end

    -- HeroicStrike : rage dump
    if ToggleOr("UseHeroicStrike", true) and not executePhase and not IsCurrentAttack() and A.HeroicStrike:IsReady(isTarget) and A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= ToggleOr("HeroicStrike-PWR", 60) then
        return A.HeroicStrike:Show(icon)
    end

    -- Stance par defaut : retour en Berserker Stance, TOUJOURS (posture
    -- de croisiere Arms : Whirlwind, Pummel, Intercept, Berserker Rage).
    -- Les actions exigeant Battle/Def (Overpower, Rend, Disarm, Reflect)
    -- ont deja eu leur chance plus haut dans la priorite. On vide la
    -- rage excedentaire puis on bascule — jamais de blocage en Battle.
    if not forceDef and inStance ~= 3 and not (ToggleOr("UseOverpower", true) and IsOverPowerUP(isTarget)) then
        -- bascule directe si la perte de rage est faible
        if myRage <= StanceKeepRage() + 25 and A.BerserkerStance:IsReady("player") then
            return A.BerserkerStance:Show(icon)
        end

        -- dump rapide (un MortalStrike + un Heroic Strike en file) puis
        -- bascule QUOI QU'IL ARRIVE : en PvP la rage entrante depasse
        -- souvent ce qu'un dump evacue — attendre d'etre "pauvre en rage"
        -- bloquerait la posture Berserker (Whirlwind/Pummel/Intercept)
        -- pour tout le combat
        if isTargetInMelee then
            if A.MortalStrike:IsReady(isTarget) and A.MortalStrike:AbsentImun(isTarget, Temp.AttackTypes) and myRage >= A.MortalStrike:GetSpellPowerCostCache() then
                return A.MortalStrike:Show(icon)
            end

            if not IsCurrentAttack() and A.HeroicStrike:IsReady(isTarget) and A.HeroicStrike:AbsentImun(isTarget, Temp.AttackTypes) then
                return A.HeroicStrike:Show(icon)
            end
        end

        -- bascule inconditionnelle (la rage au-dela de Tactical Mastery
        -- est perdue : assume, c'est le jeu du guerrier Arms)
        if A.BerserkerStance:IsReady("player") then
            return A.BerserkerStance:Show(icon)
        end
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
