--------------------------------------------------------------------------
-- FuryWarrior_TBC.lua
-- Rotation DPS Guerrier Fureur pour WoW TBC (client 2.4.3)
--
-- Ecrit pour un unlocker Lua type GGL : le script utilise uniquement
-- l'API WoW 2.4.3 standard (CastSpellByName, UnitBuff, UnitHealth...),
-- il fonctionne donc tel quel des que les fonctions protegees sont
-- deverrouillees. Si GGL expose sa propre fonction de cast, il suffit
-- de remplacer le corps de Cast() ci-dessous.
--
-- Priorite (spec 17/44/0, dual-wield) :
--   1. Bloodrage / Berserker Rage (generation de rage)
--   2. Cooldowns offensifs (Death Wish, Recklessness) si actives
--   3. Rampage : maintenir le buff (refresh < 5 s restantes)
--   4. Execute en phase < 20 % HP (vidange de rage)
--   5. Bloodthirst des que disponible
--   6. Whirlwind des que disponible
--   7. Victory Rush si utilisable
--   8. Heroic Strike (ou Cleave en mode AoE) au-dessus du seuil de rage
--
-- Commandes :
--   /fury          - active / desactive la rotation
--   /fury aoe      - bascule Heroic Strike <-> Cleave
--   /fury cd       - autorise / bloque Death Wish + Recklessness
--------------------------------------------------------------------------

local CONFIG = {
    enabled          = true,
    useCooldowns     = true,   -- Death Wish / Recklessness
    aoeMode          = false,  -- Cleave a la place de Heroic Strike
    hsRageThreshold  = 60,     -- rage mini avant de queue Heroic Strike
    cleaveThreshold  = 50,     -- rage mini avant de queue Cleave
    executeHealthPct = 20,     -- seuil de la phase Execute
    rampageRefresh   = 5,      -- refresh Rampage sous X secondes restantes
    bloodrageMinHp   = 50,     -- ne pas Bloodrage sous X % de vie
    pulseInterval    = 0.1,    -- frequence de la boucle (secondes)
}

local SPELLS = {
    bloodrage     = "Bloodrage",
    berserkerRage = "Berserker Rage",
    deathWish     = "Death Wish",
    recklessness  = "Recklessness",
    rampage       = "Rampage",
    execute       = "Execute",
    bloodthirst   = "Bloodthirst",
    whirlwind     = "Whirlwind",
    victoryRush   = "Victory Rush",
    heroicStrike  = "Heroic Strike",
    cleave        = "Cleave",
    berserkerStance = "Berserker Stance",
}

--------------------------------------------------------------------------
-- Helpers
--------------------------------------------------------------------------

-- Point d'entree unique vers le cast : adapter ici si GGL fournit
-- sa propre fonction (ex. GGL.Cast(name)).
local function Cast(name)
    CastSpellByName(name)
end

local function GetRage()
    return UnitMana("player")
end

-- Sur client 2.4.3, GetSpellCooldown attend un index de grimoire, pas un
-- nom : on scanne le spellbook une fois et on met les slots en cache.
local spellSlotCache = {}
local function GetSpellSlot(name)
    if spellSlotCache[name] then return spellSlotCache[name] end
    local i = 1
    while true do
        local spellName = GetSpellName(i, BOOKTYPE_SPELL or "spell")
        if not spellName then break end
        spellSlotCache[spellName] = i -- le rang max ecrase les precedents
        i = i + 1
    end
    return spellSlotCache[name]
end

local function SpellReady(name)
    local start, duration
    local slot = GetSpellSlot(name)
    if slot then
        start, duration = GetSpellCooldown(slot, BOOKTYPE_SPELL or "spell")
    else
        -- fallback pour les clients/unlockers acceptant le nom
        start, duration = GetSpellCooldown(name)
    end
    if not start then return false end
    -- duration <= 1.5 : uniquement le GCD, le sort est considere pret
    return start == 0 or duration <= 1.5
end

local function SpellUsable(name)
    local usable, noMana = IsUsableSpell(name)
    return usable == 1
end

-- Retourne le temps restant du buff, ou nil si absent.
-- Sur client 2.4.3 le timer passe par GetPlayerBuff/GetPlayerBuffTimeLeft ;
-- si l'unlocker expose l'API 3.0+ (UnitBuff avec duration/timeLeft),
-- le premier chemin fonctionne aussi.
local function PlayerBuffTimeLeft(buffName)
    -- chemin API >= 2.x avec retours etendus
    for i = 1, 32 do
        local name, _, _, _, _, timeLeft = UnitBuff("player", i)
        if not name then break end
        if name == buffName then
            if timeLeft then return timeLeft end
            -- fallback 2.4.3 : retrouver le timer via GetPlayerBuff
            if GetPlayerBuff and GetPlayerBuffTimeLeft and GameTooltip then
                for j = 0, 31 do
                    local buffIndex = GetPlayerBuff(j, "HELPFUL")
                    if buffIndex and buffIndex >= 0 then
                        GameTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                        GameTooltip:SetPlayerBuff(buffIndex)
                        local tipName = GameTooltipTextLeft1 and GameTooltipTextLeft1:GetText()
                        GameTooltip:Hide()
                        if tipName == buffName then
                            return GetPlayerBuffTimeLeft(buffIndex)
                        end
                    end
                end
            end
            return -1 -- buff present mais duree inconnue
        end
    end
    return nil
end

local function TargetHealthPct()
    local max = UnitHealthMax("target")
    if not max or max == 0 then return 100 end
    return UnitHealth("target") * 100 / max
end

local function InBerserkerStance()
    -- Stance 3 = Berserker
    local _, _, active = GetShapeshiftFormInfo(3)
    return active == 1
end

local function ValidTarget()
    return UnitExists("target")
        and not UnitIsDeadOrGhost("target")
        and UnitCanAttack("player", "target")
        and CheckInteractDistance("target", 3) -- ~10 m, portee melee large
end

--------------------------------------------------------------------------
-- Rotation
--------------------------------------------------------------------------

local lastRampageCast = 0

local function Pulse()
    if not CONFIG.enabled then return end
    if UnitIsDeadOrGhost("player") or UnitOnTaxi("player") then return end
    if not ValidTarget() then return end
    if UnitAffectingCombat("player") ~= 1 then return end

    local rage = GetRage()

    -- Stance : la rotation Fureur vit en Berserker Stance
    if not InBerserkerStance() then
        Cast(SPELLS.berserkerStance)
        return
    end

    -- 1. Generation de rage
    if SpellReady(SPELLS.bloodrage)
        and UnitHealth("player") * 100 / UnitHealthMax("player") > CONFIG.bloodrageMinHp then
        Cast(SPELLS.bloodrage)
    end
    if rage < 30 and SpellReady(SPELLS.berserkerRage) then
        Cast(SPELLS.berserkerRage)
    end

    -- 2. Cooldowns offensifs (hors GCD pour Recklessness -> on enchaine)
    if CONFIG.useCooldowns then
        if SpellReady(SPELLS.deathWish) and rage >= 10 then
            Cast(SPELLS.deathWish)
        end
        if SpellReady(SPELLS.recklessness) then
            Cast(SPELLS.recklessness)
        end
    end

    local executePhase = TargetHealthPct() <= CONFIG.executeHealthPct

    -- 3. Rampage : maintenir le buff en permanence
    local rampageLeft = PlayerBuffTimeLeft(SPELLS.rampage)
    if rampageLeft == -1 then
        -- duree exacte indisponible : on estime via notre propre timer
        -- (buff Rampage = 30 s a chaque application)
        rampageLeft = 30 - (GetTime() - lastRampageCast)
    end
    if SpellUsable(SPELLS.rampage) and SpellReady(SPELLS.rampage)
        and (not rampageLeft or rampageLeft < CONFIG.rampageRefresh)
        and rage >= 20 then
        lastRampageCast = GetTime()
        Cast(SPELLS.rampage)
        return
    end

    -- 4. Bloodthirst : toujours prioritaire sur Whirlwind
    if SpellReady(SPELLS.bloodthirst) and rage >= 30 then
        Cast(SPELLS.bloodthirst)
        return
    end

    -- 5. Whirlwind
    if SpellReady(SPELLS.whirlwind) and rage >= 25 then
        Cast(SPELLS.whirlwind)
        return
    end

    -- 6. Execute : vidange de rage sous 20 % (remplace Heroic Strike)
    if executePhase and SpellUsable(SPELLS.execute) and rage >= 15 then
        Cast(SPELLS.execute)
        return
    end

    -- 7. Victory Rush (gratuit, apres un kill)
    if SpellUsable(SPELLS.victoryRush) and SpellReady(SPELLS.victoryRush) then
        Cast(SPELLS.victoryRush)
        return
    end

    -- 8. Vidange de rage hors phase Execute : Heroic Strike / Cleave
    --    (on garde toujours >= 30 rage de reserve pour Bloodthirst)
    if not executePhase then
        if CONFIG.aoeMode then
            if rage >= CONFIG.cleaveThreshold then
                Cast(SPELLS.cleave)
            end
        else
            if rage >= CONFIG.hsRageThreshold then
                Cast(SPELLS.heroicStrike)
            end
        end
    end
end

--------------------------------------------------------------------------
-- Boucle + commandes
--------------------------------------------------------------------------

local frame = CreateFrame("Frame", "FuryRotationFrame")
local elapsedSince = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    -- client 2.4.3 : le temps ecoule arrive via le global arg1
    elapsedSince = elapsedSince + (elapsed or arg1 or 0.01)
    if elapsedSince < CONFIG.pulseInterval then return end
    elapsedSince = 0
    local ok, err = pcall(Pulse)
    if not ok then
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000FuryRotation error:|r " .. tostring(err))
    end
end)

SLASH_FURY1 = "/fury"
SlashCmdList["FURY"] = function(msg)
    msg = string.lower(msg or "")
    if msg == "aoe" then
        CONFIG.aoeMode = not CONFIG.aoeMode
        DEFAULT_CHAT_FRAME:AddMessage("FuryRotation: mode AoE " .. (CONFIG.aoeMode and "ON (Cleave)" or "OFF (Heroic Strike)"))
    elseif msg == "cd" then
        CONFIG.useCooldowns = not CONFIG.useCooldowns
        DEFAULT_CHAT_FRAME:AddMessage("FuryRotation: cooldowns " .. (CONFIG.useCooldowns and "ON" or "OFF"))
    else
        CONFIG.enabled = not CONFIG.enabled
        DEFAULT_CHAT_FRAME:AddMessage("FuryRotation: " .. (CONFIG.enabled and "|cff00ff00ACTIVE|r" or "|cffff0000STOP|r"))
    end
end

DEFAULT_CHAT_FRAME:AddMessage("|cffF5D76EFuryWarrior TBC rotation chargee.|r /fury pour activer/desactiver.")
