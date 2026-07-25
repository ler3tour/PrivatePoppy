# Rotation Guerrier Fureur — TBC (2.4.3)

Script Lua de rotation DPS pour guerrier Fureur, à charger via GGL (ou tout
unlocker Lua compatible client 2.4.3). Objectif : maximiser les dégâts
mono-cible en raid, avec un mode AoE optionnel.

## Spec visée

**17/44/0 Fury** (dual-wield), le build DPS de référence en TBC :
Rampage, Bloodthirst, Flurry 5/5, Improved Berserker Stance, Death Wish.

## Priorité implémentée

| # | Action | Condition |
|---|--------|-----------|
| 1 | Bloodrage | dispo et > 50 % PV |
| 2 | Berserker Rage | rage < 30 |
| 3 | Death Wish + Recklessness | si cooldowns autorisés (`/fury cd`) |
| 4 | Rampage | buff absent ou < 5 s restantes |
| 5 | Bloodthirst | dès que disponible |
| 6 | Whirlwind | dès que disponible |
| 7 | Execute | cible < 20 % PV (vidange de rage) |
| 8 | Victory Rush | si utilisable |
| 9 | Heroic Strike / Cleave | rage ≥ 60 (HS) ou ≥ 50 (Cleave, mode AoE) |

Bloodthirst passe toujours avant Whirlwind, et le script garde une réserve de
rage pour ne jamais retarder Bloodthirst à cause d'un Heroic Strike.

## Commandes

- `/fury` — active / désactive la rotation
- `/fury aoe` — bascule Heroic Strike ↔ Cleave
- `/fury cd` — autorise / bloque Death Wish et Recklessness

## Réglages

Tous les seuils (rage pour Heroic Strike, seuil Execute, fréquence de la
boucle…) sont dans la table `CONFIG` en tête de `FuryWarrior_TBC.lua`.

## Adapter à l'API de GGL

Le script n'utilise que l'API WoW 2.4.3 standard. Si GGL expose sa propre
fonction de cast, modifiez uniquement le helper `Cast(name)` en tête du
fichier — tout le reste de la rotation passe par lui.

## Notes DPS

- La rotation suppose que vous restez en **Berserker Stance** (elle y
  rebascule automatiquement si besoin).
- Sous 20 % PV de la cible, Heroic Strike est coupé au profit d'Execute.
- Avec une arme lente en main droite et Windfury, montez
  `hsRageThreshold` (70–75) pour ne pas étouffer les procs Windfury.
