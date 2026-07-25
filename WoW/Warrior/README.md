# Rotation Guerrier — TBC, dégâts max (GGL / Action)

Rotations DPS guerrier pour WoW TBC. Deux implémentations :

| Fichier | Format | Usage |
|---------|--------|-------|
| `GGL_Action_Warrior_TBC_Fury.lua` | **CodeSnippet TellMeWhen / framework [Action](https://github.com/MisterCrab/Action)** — le format des profils GGL | À importer dans TMW (recommandé) |
| `FuryWarrior_TBC.lua` | Lua autonome (API WoW 2.4.3 brute) | Pour un unlocker Lua générique, sans TMW/Action |

## Import du snippet GGL/Action

1. Copier un profil `[GGL]` existant dans TellMeWhen (pour récupérer les
   groupes d'icônes et le snippet « Profile UI »), ou créer un profil vide.
2. `/tmw` → **Profile** → **Code Snippets** → remplacer le contenu du
   snippet « Warrior » par `GGL_Action_Warrior_TBC_Fury.lua` (ou créer un
   nouveau snippet et coller le fichier).
3. Recharger l'interface (`/reload`).

Le snippet lit les toggles du « Profile UI » GGL quand ils existent
(`AoE`, `Burst`, `StopCast`, `HeroicStrike-PWR`, `Cleave-PWR`,
`Bloodrage-LimitHP`, …) et applique des valeurs par défaut saines sinon —
il fonctionne donc aussi sans le snippet UI d'origine.

## Spec visée

**17/44/0 Fury** (dual-wield), le build dégâts max de TBC :
Rampage, Bloodthirst, Flurry 5/5, Improved Berserker Stance, Death Wish.
Un fallback Mortal Strike est inclus si le personnage est spec Arms.

## Priorité implémentée (méta 3)

1. **Burst** (si le toggle Burst est actif) : Berserking / Blood Fury →
   Death Wish → Recklessness (couplé à Death Wish) → trinkets →
   Haste Potion (dans la fenêtre Death Wish, boss uniquement)
2. **Rage** : Bloodrage on cooldown, Berserker Rage si Improved Berserker
   Rage est talenté et rage basse
3. **Rampage** : upkeep permanent, refresh sous 5 s restantes, sans jamais
   retarder un Bloodthirst prêt
4. **Whirlwind** AoE 4+ cibles (mode AoE)
5. **Bloodthirst** dès que disponible
6. **Whirlwind** mono-cible, en réservant la rage d'un Bloodthirst imminent
7. **Execute** < 20 % PV en vidange de rage (Heroic Strike coupé, y compris
   un Heroic Strike déjà en file via StopCast)
8. **Victory Rush** si utilisable
9. **Heroic Strike** ≥ 60 rage (mono) / **Cleave** ≥ 50 rage (AoE)

Détails d'implémentation notables :

- **IDs TBC corrects** : Death Wish = `12292` et Sweeping Strikes = `12328`
  (les IDs sont inversés par rapport à Classic Era) ; Rampage `29801`,
  Victory Rush `34428`, Commanding Shout `469`, Spell Reflection `23920`.
- La rotation reste en **Berserker Stance** et n'y bascule que si la rage
  perdue est couverte par Tactical Mastery.
- Heroic Strike/Cleave en file sont annulés (`STOPCAST`) si la cible passe
  sous 20 % ou devient immunisée.
- Interrupts (Pummel), Intercept en gap-closer, Battle Shout hors combat,
  Berserker Rage / Death Wish anti-Fear en Loss of Control.

## Réglages

Avec le « Profile UI » GGL : tout se règle dans `/action` comme d'habitude.
Sans lui, les défauts sont : Heroic Strike à 60 rage, Cleave à 50,
refresh Rampage à 5 s, Bloodrage bloqué sous 35 % PV, Haste Potion active.
Montez `HeroicStrike-PWR` vers 70–75 avec une MH lente + Windfury pour ne
pas étouffer les procs.

## Version Lua autonome

`FuryWarrior_TBC.lua` implémente la même priorité avec l'API WoW 2.4.3
brute (`CastSpellByName`, scan du grimoire pour les cooldowns…).
Commandes : `/fury` (on/off), `/fury aoe`, `/fury cd`. Le point d'entrée
du cast est le helper `Cast(name)` en tête de fichier.
