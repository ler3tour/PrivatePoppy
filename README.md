# SECAAimmo

Application web pour l'investissement locatif : calcul de rentabilité, prix immobiliers par zone et planches d'ambiances déco. HTML, CSS et JavaScript purs, sans build ni dépendance.

## Rentabilité locative

- Coût d'opération : prix, frais de notaire (7,5 % dans l'ancien, 2,5 % dans le neuf, modifiables), travaux, mobilier.
- Financement par annuités : apport, taux, durée, assurance emprunteur. L'application affiche la mensualité, sa part d'assurance et le coût total du crédit.
- Charges : copropriété, taxe foncière, assurance PNO, entretien, gestion locative, garantie loyers impayés, vacance locative.
- Fiscalité simplifiée, avec TMI et 17,2 % de prélèvements sociaux pour les régimes à l'IR : micro-foncier (abattement 30 %, plafond 15 000 €, art. 32 du CGI), foncier au réel, micro-BIC en meublé de longue durée (abattement 50 %, plafond 83 600 €, art. 50-0 du CGI), LMNP au réel avec amortissement estimé, SARL de famille à l'IR (art. 239 bis AA du CGI) et SCI à l'IS (15 % jusqu'à 42 500 € de bénéfice puis 25 %, art. 219 du CGI). L'application signale le dépassement des plafonds micro.
- Résultats : rentabilité brute, nette de charges, nette d'impôts, cash-flow mensuel, et projection du capital restant dû et du cash-flow cumulé sur la durée du prêt.
- Rapport téléchargeable : un fichier HTML autonome reprend toute l'opération (avec les références fiscales du régime choisi) et s'imprime en PDF depuis le navigateur.

## Prix sur zone

- Recherche de commune avec autocomplétion via l'API officielle [geo.api.gouv.fr](https://geo.api.gouv.fr).
- Ventes réelles issues de la base DVF (Demandes de valeurs foncières, données publiques) quand l'API ouverte répond : prix médians appartement et maison, médiane par année, dernières transactions.
- Si la base DVF est injoignable, l'application affiche des prix indicatifs par département (embarqués) et un baromètre des grandes villes.

## Ambiances

- 10 styles prêts à l'emploi (scandinave, industriel, bohème, japandi, minimaliste, art déco, méditerranéen, campagne chic, vintage 70's, moderne luxe) présentés en moodboards avec palette, matériaux et tags à la manière de Pinterest.
- Filtrage des ambiances par combinaison de tags.
- Créateur d'ambiance personnalisée : nom, description, palette de 5 couleurs, tags. Les ambiances sont sauvegardées dans le navigateur (localStorage).

## Lancer l'application

Aucun build : ouvrir `index.html` dans un navigateur, ou servir le dossier :

```bash
python3 -m http.server 8000
# puis http://localhost:8000
```

Thème clair ou sombre selon le réglage système, avec bascule manuelle.

## Installer sur iPhone (PWA)

L'application est une Progressive Web App : manifeste, icônes et service worker (fonctionnement hors connexion). Un workflow GitHub Actions la déploie sur GitHub Pages.

1. Ouvrir l'URL GitHub Pages du dépôt dans Safari sur l'iPhone (`https://<compte>.github.io/SECAAimmo/`).
2. Toucher le bouton Partager (carré avec flèche vers le haut).
3. Choisir « Sur l'écran d'accueil », puis « Ajouter ».

L'application s'ouvre alors en plein écran avec sa propre icône. Les calculateurs et les ambiances fonctionnent sans connexion ; seules la recherche de commune et les ventes DVF demandent internet, sinon les prix indicatifs embarqués prennent le relais.

## Avertissement

Outil d'aide à la décision : les résultats sont des estimations simplifiées (notamment la fiscalité) et les prix indicatifs des ordres de grandeur. Ils ne constituent pas un conseil financier, fiscal ou immobilier.
