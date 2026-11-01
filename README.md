# 🏠 ImmoPoppy — Studio d'investissement immobilier

Application web autonome (HTML / CSS / JavaScript pur, aucune installation) qui réunit trois outils :

## 📊 Rentabilité locative

- Coût total d'opération : prix, frais de notaire (auto : 7,5 % ancien / 2,5 % neuf, modifiable), travaux, mobilier.
- Financement : apport, taux, durée, assurance emprunteur → mensualité par annuités.
- Charges réelles : copropriété, taxe foncière, PNO, entretien, gestion locative, GLI, vacance locative.
- Fiscalité simplifiée : micro-foncier, foncier au réel, LMNP micro-BIC, LMNP réel (amortissement), avec TMI + 17,2 % de prélèvements sociaux.
- Résultats : rentabilité **brute**, **nette de charges**, **nette-nette** (après impôts), **cash-flow mensuel**, et projection graphique sur la durée du prêt (capital restant dû vs cash-flow cumulé).

## 📍 Prix sur zone

- Recherche de commune avec autocomplétion via l'API officielle [geo.api.gouv.fr](https://geo.api.gouv.fr).
- Ventes réelles issues de la base **DVF** (Demandes de valeurs foncières, données publiques) quand l'API ouverte répond : prix médians appartement / maison, médiane par année, tableau des dernières transactions.
- Repli automatique sur des **prix indicatifs par département** (embarqués) si la base DVF est injoignable, plus un baromètre des grandes villes.

## 🎨 Ambiances

- 10 styles prêts à l'emploi (scandinave, industriel, bohème, japandi, minimaliste, art déco, méditerranéen, campagne chic, vintage 70's, moderne luxe) présentés en **moodboards** avec palette, matériaux et **tags façon Pinterest**.
- Filtrage des ambiances par combinaison de tags.
- **Créateur d'ambiance personnalisée** : nom, description, palette de 5 couleurs, tags — sauvegardée dans le navigateur (localStorage).

## Lancer l'application

Aucun build : ouvrir `index.html` dans un navigateur, ou servir le dossier :

```bash
python3 -m http.server 8000
# puis http://localhost:8000
```

Thème clair / sombre automatique (réglage système) avec bascule manuelle 🌓.

## 📱 Installer sur iPhone (PWA)

L'application est une **Progressive Web App** : manifeste, icônes et service worker
(fonctionnement hors-ligne). Un workflow GitHub Actions la déploie sur GitHub Pages.

1. Ouvrir l'URL GitHub Pages du dépôt dans **Safari** sur l'iPhone
   (`https://<compte>.github.io/PrivatePoppy/`).
2. Toucher le bouton **Partager** (carré avec flèche vers le haut).
3. Choisir **« Sur l'écran d'accueil »** puis **Ajouter**.

L'app s'ouvre alors en plein écran avec sa propre icône, et les calculateurs comme
les ambiances fonctionnent même sans connexion (seules la recherche de commune et
les ventes DVF nécessitent internet ; sinon les prix indicatifs embarqués prennent
le relais).

## Avertissement

Outil d'aide à la décision : les résultats sont des estimations simplifiées (notamment la fiscalité) et les prix indicatifs des ordres de grandeur. Ils ne constituent pas un conseil financier, fiscal ou immobilier.
