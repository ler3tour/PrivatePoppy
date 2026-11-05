/*
 * Module Rentabilité : calculs locatifs (brute, nette, nette-nette),
 * financement (annuités), fiscalité simplifiée et projection annuelle.
 */
(function () {
  const PS = 0.172; // prélèvements sociaux

  const $ = function (id) { return document.getElementById(id); };

  const fmtEur = function (v) {
    return v.toLocaleString("fr-FR", { style: "currency", currency: "EUR", maximumFractionDigits: 0 });
  };
  const fmtPct = function (v) {
    return (v * 100).toLocaleString("fr-FR", { maximumFractionDigits: 2 }) + " %";
  };

  function num(id) {
    const v = parseFloat($(id).value);
    return isFinite(v) ? v : 0;
  }

  function lireFormulaire() {
    return {
      prix: num("in-prix"),
      surface: Math.max(1, num("in-surface")),
      notaire: num("in-notaire"),
      travaux: num("in-travaux"),
      mobilier: num("in-mobilier"),
      loyer: num("in-loyer"),
      vacanceSemaines: Math.min(52, num("in-vacance")),
      copro: num("in-copro"),
      tf: num("in-tf"),
      pno: num("in-pno"),
      entretien: num("in-entretien"),
      gestionPct: num("in-gestion") / 100,
      gliPct: num("in-gli") / 100,
      apport: num("in-apport"),
      taux: num("in-taux") / 100,
      duree: Math.max(1, Math.round(num("in-duree"))),
      assu: num("in-assu") / 100,
      regime: $("in-regime").value,
      tmi: num("in-tmi") / 100
    };
  }

  function calculerImpots(regime, tmi, loyerAnnuel, chargesDeductibles, interetsAn1, amortissement) {
    const resultatAmorti = Math.max(0, loyerAnnuel - chargesDeductibles - interetsAn1 - amortissement);
    switch (regime) {
      case "micro-foncier":
        return loyerAnnuel * 0.70 * (tmi + PS);
      case "micro-bic":
        return loyerAnnuel * 0.50 * (tmi + PS);
      case "foncier-reel":
        return Math.max(0, loyerAnnuel - chargesDeductibles - interetsAn1) * (tmi + PS);
      case "lmnp-reel":
      case "sarl-ir": // SARL de famille translucide : BIC réel amorti imposé à l'IR des associés
        return resultatAmorti * (tmi + PS);
      case "sci-is": // barème IS : 15 % jusqu'à 42 500 € de bénéfice, 25 % au-delà
        return Math.min(resultatAmorti, 42500) * 0.15 + Math.max(0, resultatAmorti - 42500) * 0.25;
      default:
        return loyerAnnuel * (tmi + PS);
    }
  }

  function calculer(f) {
    const coutTotal = f.prix + f.notaire + f.travaux + f.mobilier;
    const emprunt = Math.max(0, coutTotal - f.apport);
    const n = f.duree * 12;
    const tm = f.taux / 12;
    const mensualiteHorsAssu = emprunt === 0 ? 0
      : tm === 0 ? emprunt / n
      : emprunt * tm / (1 - Math.pow(1 + tm, -n));
    const mensualiteAssu = emprunt * f.assu / 12;
    const mensualite = mensualiteHorsAssu + mensualiteAssu;

    const tauxOccupation = 1 - f.vacanceSemaines / 52;
    const loyerAnnuel = f.loyer * 12 * tauxOccupation;
    const chargesAnnuelles = f.copro + f.tf + f.pno + f.entretien +
      loyerAnnuel * (f.gestionPct + f.gliPct);

    const interetsAn1 = emprunt * f.taux + emprunt * f.assu;
    // Amortissement comptable estimé (régimes amortis : LMNP réel, SARL IR, SCI IS) :
    // 85 % du prix (terrain exclu) sur 30 ans, travaux sur 15 ans, mobilier sur 7 ans.
    const amortissement = f.prix * 0.85 / 30 + f.travaux / 15 + f.mobilier / 7;
    const impots = calculerImpots(f.regime, f.tmi, loyerAnnuel, chargesAnnuelles, interetsAn1, amortissement);

    const brute = f.loyer * 12 / coutTotal;
    const nette = (loyerAnnuel - chargesAnnuelles) / coutTotal;
    const netteNette = (loyerAnnuel - chargesAnnuelles - impots) / coutTotal;
    const cashflowMensuel = (loyerAnnuel - chargesAnnuelles - impots) / 12 - mensualite;

    // Projection annuelle : capital restant dû + cash-flow cumulé (hypothèses constantes).
    const projection = [];
    let capital = emprunt;
    let cumul = 0;
    for (let annee = 1; annee <= f.duree; annee++) {
      for (let m = 0; m < 12; m++) {
        const interet = capital * tm;
        capital = Math.max(0, capital - (mensualiteHorsAssu - interet));
      }
      cumul += cashflowMensuel * 12;
      projection.push({ annee: annee, capitalRestant: capital, cashflowCumule: cumul });
    }

    const coutCredit = emprunt > 0 ? mensualite * n - emprunt : 0;
    const regimeAmorti = ["lmnp-reel", "sci-is", "sarl-ir"].indexOf(f.regime) !== -1;

    return {
      coutTotal, emprunt, mensualite, mensualiteHorsAssu, mensualiteAssu,
      coutCredit, loyerAnnuel, chargesAnnuelles, amortissement, regimeAmorti,
      impots, brute, nette, netteNette, cashflowMensuel, projection,
      prixM2: f.prix / f.surface
    };
  }

  function afficher(f, r) {
    $("out-brute").textContent = fmtPct(r.brute);
    $("out-nette").textContent = fmtPct(r.nette);
    $("out-nettenette").textContent = fmtPct(r.netteNette);

    const cf = $("out-cashflow");
    cf.textContent = (r.cashflowMensuel >= 0 ? "+" : "") + fmtEur(r.cashflowMensuel);
    cf.classList.toggle("is-good", r.cashflowMensuel >= 0);
    cf.classList.toggle("is-bad", r.cashflowMensuel < 0);
    $("out-cashflow-note").textContent = r.cashflowMensuel >= 0
      ? "L'opération s'autofinance."
      : "Effort d'épargne mensuel requis.";

    // Plafonds des régimes micro (art. 32 et 50-0 du CGI).
    const alerte = $("fiscal-alerte");
    if (alerte) {
      let message = "";
      if (f.regime === "micro-foncier" && r.loyerAnnuel > 15000) {
        message = "Loyers au-dessus de 15 000 € par an : le micro-foncier ne s'applique plus (art. 32 du CGI), le régime réel prend le relais.";
      } else if (f.regime === "micro-bic" && r.loyerAnnuel > 83600) {
        message = "Recettes au-dessus de 83 600 € par an : le micro-BIC ne s'applique plus en meublé de longue durée (art. 50-0 du CGI), le régime réel prend le relais.";
      }
      alerte.textContent = message;
      alerte.hidden = !message;
    }

    $("out-mensualite-tile").textContent = fmtEur(r.mensualite);
    $("out-mensualite-detail").textContent = r.emprunt > 0
      ? "dont assurance " + fmtEur(r.mensualiteAssu) + " · sur " + r.projection.length + " ans"
      : "Achat comptant, pas d'emprunt.";

    $("out-cout").textContent = fmtEur(r.coutTotal);
    $("out-prixm2").textContent = fmtEur(r.prixM2) + " / m²";
    $("out-emprunt").textContent = fmtEur(r.emprunt);
    $("out-mensualite").textContent = fmtEur(r.mensualite) + " / mois";
    $("out-mensualite-split").textContent = fmtEur(r.mensualiteHorsAssu) + " / " + fmtEur(r.mensualiteAssu);
    $("out-coutcredit").textContent = fmtEur(r.coutCredit);
    $("out-loyerannuel").textContent = fmtEur(r.loyerAnnuel);
    $("out-charges").textContent = fmtEur(r.chargesAnnuelles);
    $("out-impots").textContent = fmtEur(r.impots);
    $("out-amortissement").textContent = r.regimeAmorti
      ? fmtEur(r.amortissement) + " / an"
      : "sans objet pour ce régime";
    $("out-effort").textContent = r.cashflowMensuel >= 0 ? "0 €" : fmtEur(-r.cashflowMensuel * 12) + " / an";

    dessinerProjection(r);
  }

  let dernierResultat = null;
  let dernierFormulaire = null;

  function dessinerProjection(r) {
    dernierResultat = r;
    const host = document.getElementById("chart-projection");
    if (!host || !r) return;
    const styles = getComputedStyle(document.documentElement);
    PoppyCharts.lineChart(host, {
      series: [
        {
          name: "Capital restant dû",
          color: styles.getPropertyValue("--series-1").trim(),
          values: r.projection.map(function (p) { return { x: p.annee, y: p.capitalRestant }; })
        },
        {
          name: "Cash-flow cumulé",
          color: styles.getPropertyValue("--series-2").trim(),
          values: r.projection.map(function (p) { return { x: p.annee, y: p.cashflowCumule }; })
        }
      ],
      formatX: function (x) { return "Année " + x; },
      formatXTick: function (x) { return "An " + x; },
      formatY: fmtEur
    });
  }

  function recalculer() {
    const f = lireFormulaire();
    dernierFormulaire = f;
    afficher(f, calculer(f));
  }

  function majNotaireAuto() {
    const prix = num("in-prix");
    const taux = $("in-neuf").value === "neuf" ? 0.025 : 0.075;
    $("in-notaire").value = Math.round(prix * taux);
  }

  document.addEventListener("DOMContentLoaded", function () {
    ["in-prix", "in-neuf"].forEach(function (id) {
      $(id).addEventListener("input", function () { majNotaireAuto(); recalculer(); });
    });
    document.querySelectorAll("#panel-renta input, #panel-renta select").forEach(function (input) {
      input.addEventListener("input", recalculer);
    });
    let resizeTimer;
    window.addEventListener("resize", function () {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(function () { dessinerProjection(dernierResultat); }, 150);
    });
    recalculer();
  });

  window.PoppyCalc = {
    redessiner: function () { dessinerProjection(dernierResultat); },
    etat: function () { return { f: dernierFormulaire, r: dernierResultat }; }
  };
})();
