# Rotation Guerrier — TBC, dégâts max (GGL / Action)

Rotations guerrier pour WoW TBC au format GGL (TellMeWhen + framework
[Action](https://github.com/MisterCrab/Action)).

| Fichier | Rôle |
|---------|------|
| `GGL_Action_Warrior_TBC_PvP.lua` | **Profil PvP** — rotation (snippet Order 1) |
| `GGL_Action_Warrior_TBC_PvP_UI.lua` | **Profil PvP** — UI in-game `/action` (snippet Order 2) |
| `GGL_Action_Warrior_TBC_Fury.lua` | Profil PvE Fury dégâts max (snippet unique) |
| `FuryWarrior_TBC.lua` | Version Lua autonome (sans TMW/Action) |

## Profil PvP : spé visée — Arms 33/28/0

Le profil PvP est construit pour la spé des guerriers les mieux classés en
arène TBC : **Arms Mortal Strike**. Le standard est **33/28/0** —
côté Armes : Mortal Strike, Death Wish (talent Armes en TBC), Second Wind,
Improved Overpower/Impale, Improved Hamstring ; côté Fureur : Cruelty,
**Piercing Howl**, Enrage et **Flurry 5/5**. La variante **41/20/0
Endless Rage** (rage contre les cibles full résilience) fonctionne sans
rien changer : la rotation détecte les talents appris.

Ce que ça change dans la rotation par rapport à un profil Fury :
Mortal Strike passe au cœur de la priorité (uptime du débuff -50 % soins),
Overpower sur esquive est revalorisé (Impale), Whirlwind et Hamstring
réservent toujours la rage d'un Mortal Strike imminent, et Execute prime
sur Whirlwind sous 20 %. Piercing Howl est activé par défaut.

## Profil PvP : compos visées — 2v2 Warrior/Rdruid, 3v3 WLD

Le profil intègre le support des deux compos :

- **Intervene automatique sur le druide** : le druide est auto-détecté
  (party1/party2), et quand il encaisse sous le seuil de PV réglable
  (60 % par défaut), la rotation bascule en Posture défensive et
  Intervene sur lui (toggle `Intervene-Healer`).
- **Kick @focus** : mettez le healer ou le caster adverse en focus —
  Pummel l'interrompt sans jamais changer de cible (toggle
  `Interrupt-Focus`). Indispensable en WLD pour rester sur la kill target
  pendant que le lock fear/dot.
- **Cri au choix** : dropdown Battle Shout / Commanding Shout / OFF —
  Commanding Shout est utile contre les doubles DPS.
- Le Spell Reflection surveille aussi le focus (fears du démoniste
  adverse, cyclones, polymorphes…).

## Améliorations issues des guides arène

- **Berserker Rage préventif** : quand un Fear ou Hurlement de terreur est
  *en cours de cast* sur vous, Rage berserker part avant l'impact
  (immunité 10 s), avec stance dance d'urgence si besoin. Le Spell
  Reflection reste prioritaire quand il est disponible (renvoyer le Fear
  vaut mieux que l'immunité).
- **Rend anti-restealth** : Pourfendre est maintenu en permanence sur les
  Voleurs et Druides pour interdire le retour en camouflage, avec bascule
  en Posture de combat quand Tactical Mastery conserve la rage.
- **Filtre Spell Reflection** : par défaut, le swap bouclier ne se
  déclenche que pour les sorts qui le valent (Fear, Polymorphe, Cyclone,
  Sarments, gros nukes…) — liste localisée via `GetSpellInfo`, donc
  compatible client français. Désactivable pour renvoyer n'importe quel
  cast.

## Profil PvP : installation

1. Dans TellMeWhen, dupliquer un profil `[GGL]` existant (pour récupérer
   les groupes d'icônes) ou créer un profil vide.
2. `/tmw` → **Profile** → **Code Snippets** :
   - Snippet 1 (« Warrior », **Order 1**) : coller `GGL_Action_Warrior_TBC_PvP.lua`
   - Snippet 2 (« Profile UI », **Order 2**) : coller `GGL_Action_Warrior_TBC_PvP_UI.lua`
3. `/reload`, puis `/action` pour ouvrir le panneau de réglages.

## UI in-game : activer/désactiver des sorts à la volée

Tout se pilote depuis l'onglet classe du panneau `/action`, **sans reload**,
en plein combat :

- **Interrupts** : kick auto Pummel (et Shield Bash si bouclier équipé)
- **Spell Reflection** : renvoi auto des sorts castés sur vous
  (target/mouseover/arena1-5), avec **swap 1M+bouclier automatique**
  puis re-swap vers les armes
- **Disarm** : déclencheur `OFF` / `On cooldown` / `Sur burst ennemi`
- **Intimidating Shout** : toggle « à la demande » (on l'active quand on
  veut le fear, la rotation le place dès que possible)
- **Piercing Howl**, **Hamstring** (uptime du snare), **Intercept**,
  **Overpower sur esquive**, **Victory Rush**, Berserker Rage…
- Sliders : seuils de rage Heroic Strike / Cleave, limite PV Bloodrage

Chaque toggle est aussi bindable en macro pour un vrai contrôle à la volée :

```
/run Action.SetToggle({2, "Interrupt-Pummel"})
/run Action.SetToggle({2, "UseSpellReflection"})
/run Action.SetToggle({2, "UseIntimidatingShout"})
```

(Le `2` désigne l'onglet classe ; la clé est le champ `DB` du toggle.)

## Profil PvP : logique de rotation

Priorité (méta 3) : StopCast (HS/Cleave en file si Execute prêt ou cible
immune) → anti-CC (Berserker Rage / Death Wish / racial sur fear) →
**Spell Reflection** (swap bouclier → stance → reflect, étapes rejouées à
chaque tick) → **kicks** → **Disarm** (bascule Posture défensive si la
rage le permet) → Charge/Intercept → fear/howl à la demande → burst
(Death Wish → Recklessness → trinkets, via le toggle Burst) →
**Overpower sur esquive** (log de combat + stance dance Tactical Mastery)
→ Rampage (si Fury) → Mortal Strike / Bloodthirst → Whirlwind (jamais si
un CC cassable est à portée) → Execute → Victory Rush → Hamstring →
Heroic Strike. Retour en Berserker Stance quand la rage ne se perd pas.

Notes :
- IDs TBC : Death Wish = `12292`, Sweeping Strikes = `12328` (inversés par
  rapport à Classic Era), Rampage `29801`, Victory Rush `34428`,
  Spell Reflection `23920`, Intervene `3411`.
- Le swap d'arme nécessite la macro **SwapWeapon** générée par le
  framework (clic droit sur l'icône dans `/action`) et un bouclier dans
  les sacs.
- Whirlwind/Cleave sont bloqués si `EnemyTeam():IsBreakAble()` détecte un
  CC cassable à portée (pas de mouton/sap cassé).

## Profil PvE Fury (dégâts max raid)

### Spec visée

**17/44/0 Fury** (dual-wield), le build dégâts max de TBC :
Rampage, Bloodthirst, Flurry 5/5, Improved Berserker Stance, Death Wish.
Un fallback Mortal Strike est inclus si le personnage est spec Arms.

### Priorité implémentée (méta 3)

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

### Réglages

Avec le « Profile UI » GGL : tout se règle dans `/action` comme d'habitude.
Sans lui, les défauts sont : Heroic Strike à 60 rage, Cleave à 50,
refresh Rampage à 5 s, Bloodrage bloqué sous 35 % PV, Haste Potion active.
Montez `HeroicStrike-PWR` vers 70–75 avec une MH lente + Windfury pour ne
pas étouffer les procs.

### Version Lua autonome

`FuryWarrior_TBC.lua` implémente la même priorité avec l'API WoW 2.4.3
brute (`CastSpellByName`, scan du grimoire pour les cooldowns…).
Commandes : `/fury` (on/off), `/fury aoe`, `/fury cd`. Le point d'entrée
du cast est le helper `Cast(name)` en tête de fichier.
