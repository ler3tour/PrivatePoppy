/*
 * Module Prix sur zone :
 * - autocomplétion des communes via geo.api.gouv.fr (API officielle, CORS ouvert) ;
 * - ventes réelles via l'API DVF ouverte (api.cquest.org) quand elle répond ;
 * - repli sur les prix indicatifs départementaux embarqués (data-prix.js).
 */
(function () {
  const $ = function (id) { return document.getElementById(id); };
  const fmtEur = function (v) {
    return v.toLocaleString("fr-FR", { style: "currency", currency: "EUR", maximumFractionDigits: 0 });
  };

  let debounceTimer = null;
  let communeCourante = null;
  let dvfCourant = null;

  function mediane(valeurs) {
    if (!valeurs.length) return null;
    const tri = valeurs.slice().sort(function (a, b) { return a - b; });
    const mid = Math.floor(tri.length / 2);
    return tri.length % 2 ? tri[mid] : (tri[mid - 1] + tri[mid]) / 2;
  }

  /* ---------- Autocomplétion communes ---------- */
  async function chercherCommunes(nom) {
    const url = "https://geo.api.gouv.fr/communes?nom=" + encodeURIComponent(nom) +
      "&fields=nom,code,codeDepartement,codesPostaux,population&boost=population&limit=8";
    const res = await fetch(url);
    if (!res.ok) throw new Error("geo.api.gouv.fr : " + res.status);
    return res.json();
  }

  function afficherSuggestions(communes) {
    const box = $("commune-suggestions");
    box.innerHTML = "";
    if (!communes.length) { box.hidden = true; return; }
    communes.forEach(function (c) {
      const btn = document.createElement("button");
      btn.type = "button";
      const cp = (c.codesPostaux && c.codesPostaux[0]) || c.codeDepartement;
      btn.innerHTML = "<span>" + c.nom + "</span><span class='sugg-meta'>" + cp +
        (c.population ? " · " + c.population.toLocaleString("fr-FR") + " hab." : "") + "</span>";
      btn.addEventListener("click", function () {
        box.hidden = true;
        $("commune-input").value = c.nom;
        selectionnerCommune(c);
      });
      box.appendChild(btn);
    });
    box.hidden = false;
  }

  /* ---------- DVF ---------- */
  async function chargerDVF(codeInsee) {
    const url = "https://api.cquest.org/dvf?code_commune=" + encodeURIComponent(codeInsee);
    const controller = new AbortController();
    const timer = setTimeout(function () { controller.abort(); }, 8000);
    try {
      const res = await fetch(url, { signal: controller.signal });
      if (!res.ok) throw new Error("DVF : " + res.status);
      const data = await res.json();
      return (data.resultats || data.features || []).map(normaliserMutation).filter(Boolean);
    } finally {
      clearTimeout(timer);
    }
  }

  function normaliserMutation(m) {
    const src = m.properties || m;
    const valeur = parseFloat(src.valeur_fonciere);
    const surface = parseFloat(src.surface_relle_bati || src.surface_reelle_bati);
    const type = src.type_local;
    const date = src.date_mutation;
    if (!isFinite(valeur) || !isFinite(surface) || !type || !date) return null;
    if (type !== "Appartement" && type !== "Maison") return null;
    if (surface < 9 || valeur < 5000) return null;
    const prixM2 = valeur / surface;
    if (prixM2 < 200 || prixM2 > 25000) return null; // aberrations (ventes en bloc, erreurs de saisie)
    return { date: date, type: type, surface: surface, valeur: valeur, prixM2: prixM2 };
  }

  /* ---------- Affichage ---------- */
  function selectionnerCommune(commune) {
    communeCourante = commune;
    dvfCourant = null;
    $("prix-resultats").hidden = false;
    $("prix-commune").textContent = commune.nom + " (" + commune.codeDepartement + ")";
    $("prix-population").textContent = commune.population
      ? commune.population.toLocaleString("fr-FR") + " habitants" : "";

    afficherFallbackDepartement(commune);
    $("dvf-note").textContent = "Chargement des ventes DVF…";

    chargerDVF(commune.code).then(function (mutations) {
      if (!mutations.length) throw new Error("aucune mutation exploitable");
      dvfCourant = mutations;
      afficherDVF(commune, mutations);
    }).catch(function () {
      $("dvf-note").textContent = "Base DVF injoignable pour cette commune — prix indicatifs du département affichés à la place.";
      afficherGraphiqueFallback(commune);
    });
  }

  function afficherFallbackDepartement(commune) {
    const dep = PRIX_DEPARTEMENTS[commune.codeDepartement];
    if (!dep) return;
    $("prix-appart-label").textContent = "Appartement — prix indicatif (" + dep.nom + ")";
    $("prix-maison-label").textContent = "Maison — prix indicatif (" + dep.nom + ")";
    $("prix-appart").textContent = fmtEur(dep.appartement) + " / m²";
    $("prix-maison").textContent = fmtEur(dep.maison) + " / m²";
    $("prix-appart-src").textContent = "Moyenne départementale, indicatif 2025";
    $("prix-maison-src").textContent = "Moyenne départementale, indicatif 2025";
    $("dvf-table").querySelector("tbody").innerHTML = "";
  }

  function afficherDVF(commune, mutations) {
    const apparts = mutations.filter(function (m) { return m.type === "Appartement"; });
    const maisons = mutations.filter(function (m) { return m.type === "Maison"; });
    const medAppart = mediane(apparts.map(function (m) { return m.prixM2; }));
    const medMaison = mediane(maisons.map(function (m) { return m.prixM2; }));

    if (medAppart) {
      $("prix-appart-label").textContent = "Appartement — prix médian (" + commune.nom + ")";
      $("prix-appart").textContent = fmtEur(medAppart) + " / m²";
      $("prix-appart-src").textContent = apparts.length + " ventes DVF";
    }
    if (medMaison) {
      $("prix-maison-label").textContent = "Maison — prix médian (" + commune.nom + ")";
      $("prix-maison").textContent = fmtEur(medMaison) + " / m²";
      $("prix-maison-src").textContent = maisons.length + " ventes DVF";
    }

    // Tableau des dernières transactions.
    const tbody = $("dvf-table").querySelector("tbody");
    tbody.innerHTML = "";
    mutations.slice().sort(function (a, b) { return b.date.localeCompare(a.date); })
      .slice(0, 40)
      .forEach(function (m) {
        const tr = document.createElement("tr");
        tr.innerHTML = "<td>" + m.date + "</td><td>" + m.type + "</td><td>" +
          Math.round(m.surface) + " m²</td><td>" + fmtEur(m.valeur) + "</td><td>" +
          fmtEur(m.prixM2) + "</td>";
        tbody.appendChild(tr);
      });
    $("dvf-note").textContent = mutations.length + " ventes exploitables (source : DVF, données publiques).";

    // Graphique : médiane € / m² appartement par année.
    const parAnnee = {};
    apparts.forEach(function (m) {
      const annee = m.date.slice(0, 4);
      (parAnnee[annee] = parAnnee[annee] || []).push(m.prixM2);
    });
    const annees = Object.keys(parAnnee).sort();
    const serieType = annees.length ? "Appartement" : "Maison";
    let items;
    if (annees.length) {
      items = annees.map(function (a) { return { label: a, value: Math.round(mediane(parAnnee[a])) }; });
    } else {
      const parAnneeM = {};
      maisons.forEach(function (m) {
        const annee = m.date.slice(0, 4);
        (parAnneeM[annee] = parAnneeM[annee] || []).push(m.prixM2);
      });
      items = Object.keys(parAnneeM).sort().map(function (a) {
        return { label: a, value: Math.round(mediane(parAnneeM[a])) };
      });
    }
    $("prix-chart-titre").textContent = "Prix médian par année — " + serieType.toLowerCase() + " (" + commune.nom + ")";
    $("prix-chart-note").textContent = "Médiane € / m² calculée sur les ventes DVF de la commune.";
    if (items.length) {
      PoppyCharts.barChart($("chart-prix"), {
        items: items,
        color: getComputedStyle(document.documentElement).getPropertyValue("--series-1").trim(),
        formatV: function (v) { return fmtEur(v) + " / m²"; }
      });
    }
  }

  function afficherGraphiqueFallback(commune) {
    const dep = PRIX_DEPARTEMENTS[commune.codeDepartement];
    if (!dep) return;
    $("prix-chart-titre").textContent = "Repères — " + dep.nom + " vs France";
    $("prix-chart-note").textContent = "Prix indicatifs € / m² (2025).";
    const franceAppart = 3100, franceMaison = 2400;
    PoppyCharts.barChart($("chart-prix"), {
      items: [
        { label: "Appart. — " + dep.nom, value: dep.appartement, highlight: true },
        { label: "Appart. — France", value: franceAppart },
        { label: "Maison — " + dep.nom, value: dep.maison, highlight: true },
        { label: "Maison — France", value: franceMaison }
      ],
      color: getComputedStyle(document.documentElement).getPropertyValue("--series-1").trim(),
      formatV: function (v) { return fmtEur(v) + " / m²"; }
    });
  }

  function dessinerVilles() {
    const host = $("chart-villes");
    if (!host || !host.clientWidth) return;
    PoppyCharts.barChart(host, {
      items: PRIX_VILLES.map(function (v) {
        return {
          label: v.nom,
          value: v.prix,
          highlight: !!(communeCourante && communeCourante.nom === v.nom)
        };
      }),
      color: getComputedStyle(document.documentElement).getPropertyValue("--series-1").trim(),
      formatV: function (v) { return fmtEur(v) + " / m²"; }
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    const input = $("commune-input");
    input.addEventListener("input", function () {
      clearTimeout(debounceTimer);
      const q = input.value.trim();
      if (q.length < 2) { $("commune-suggestions").hidden = true; return; }
      debounceTimer = setTimeout(function () {
        chercherCommunes(q).then(afficherSuggestions).catch(function () {
          $("commune-suggestions").hidden = true;
        });
      }, 250);
    });
    document.addEventListener("click", function (evt) {
      if (!evt.target.closest(".search-row")) $("commune-suggestions").hidden = true;
    });
  });

  window.PoppyPrix = {
    // Appelé à l'activation de l'onglet : les graphiques ont besoin d'une largeur mesurable.
    onShow: function () {
      dessinerVilles();
      if (communeCourante) {
        if (dvfCourant) afficherDVF(communeCourante, dvfCourant);
        else afficherGraphiqueFallback(communeCourante);
      }
    },
    redessiner: dessinerVilles
  };
})();
