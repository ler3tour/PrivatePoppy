/*
 * Module Rapport : génère un rapport HTML autonome de l'opération
 * (téléchargeable, imprimable en PDF depuis le navigateur).
 */
(function () {
  const fmtEur = function (v) {
    return v.toLocaleString("fr-FR", { style: "currency", currency: "EUR", maximumFractionDigits: 0 });
  };
  const fmtPct = function (v) {
    return (v * 100).toLocaleString("fr-FR", { maximumFractionDigits: 2 }) + " %";
  };
  const esc = function (s) {
    return String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;");
  };
  // Le rapport est rédigé sans cadratins ; on nettoie aussi les libellés repris de l'app.
  const sansCadratin = function (s) {
    return String(s).replace(/\s*—\s*/g, " ");
  };

  function ligne(label, valeur) {
    return "<tr><td>" + esc(label) + "</td><td>" + esc(valeur) + "</td></tr>";
  }

  function blocZone() {
    // Reprend les prix de zone si une commune a été consultée dans l'onglet dédié.
    const resultats = document.getElementById("prix-resultats");
    if (!resultats || resultats.hidden) return "";
    const commune = document.getElementById("prix-commune").textContent;
    const appartLabel = sansCadratin(document.getElementById("prix-appart-label").textContent);
    const appart = document.getElementById("prix-appart").textContent;
    const maisonLabel = sansCadratin(document.getElementById("prix-maison-label").textContent);
    const maison = document.getElementById("prix-maison").textContent;
    return "<h2>Prix sur zone</h2><table>" +
      ligne("Commune consultée", commune) +
      ligne(appartLabel, appart) +
      ligne(maisonLabel, maison) +
      "</table>";
  }

  function construireHTML() {
    const etat = window.PoppyCalc && PoppyCalc.etat();
    if (!etat || !etat.r) return null;
    const f = etat.f, r = etat.r;
    const date = new Date().toLocaleDateString("fr-FR", { day: "numeric", month: "long", year: "numeric" });
    const regimeLabel = sansCadratin(document.querySelector("#in-regime option:checked").textContent);
    // Références vérifiées sur Légifrance (versions en vigueur).
    const REFS_CGI = {
      "micro-foncier": "art. 32 du CGI (abattement 30 %, plafond 15 000 €)",
      "micro-bic": "art. 50-0 du CGI (abattement 50 %, plafond 83 600 € en meublé de longue durée)",
      "sci-is": "art. 219 du CGI (IS 15 % jusqu'à 42 500 € de bénéfice, puis 25 %)",
      "sarl-ir": "art. 239 bis AA du CGI (option des SARL de famille pour l'IR)"
    };
    const refCGI = REFS_CGI[f.regime];
    const typeLabel = document.querySelector("#in-neuf option:checked").textContent;

    let projRows = "";
    r.projection.forEach(function (p) {
      projRows += "<tr><td>Année " + p.annee + "</td><td>" + fmtEur(p.capitalRestant) +
        "</td><td>" + fmtEur(p.cashflowCumule) + "</td></tr>";
    });

    return "<!DOCTYPE html>\n<html lang=\"fr\"><head><meta charset=\"UTF-8\">" +
      "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">" +
      "<title>Rapport SECAAimmo du " + date + "</title><style>" +
      "body{font-family:system-ui,-apple-system,'Segoe UI',sans-serif;color:#0b0b0b;background:#fff;" +
      "max-width:760px;margin:0 auto;padding:28px 22px;line-height:1.5;font-size:14px}" +
      "header{display:flex;justify-content:space-between;align-items:baseline;border-bottom:2px solid #2a78d6;" +
      "padding-bottom:10px;margin-bottom:18px;flex-wrap:wrap;gap:6px}" +
      "h1{font-size:20px;margin:0;color:#1c5cab}h2{font-size:15px;margin:22px 0 8px;color:#1c5cab}" +
      ".marque{font-size:11px;letter-spacing:0.08em;text-transform:uppercase;color:#52514e;margin:0 0 2px}" +
      ".date{color:#52514e;font-size:13px}" +
      ".kpis{display:flex;gap:10px;flex-wrap:wrap;margin:14px 0}" +
      ".kpi{flex:1;min-width:150px;border:1px solid #e1e0d9;border-radius:10px;padding:10px 12px}" +
      ".kpi b{display:block;font-size:19px;margin-top:2px}" +
      ".kpi span{font-size:12px;color:#52514e}" +
      ".pos{color:#006300}.neg{color:#d03b3b}" +
      "table{width:100%;border-collapse:collapse;font-size:13px;margin:6px 0}" +
      "td,th{padding:5px 8px;border-bottom:1px solid #e1e0d9;text-align:left}" +
      "td:last-child,th:last-child,td:nth-child(2),th:nth-child(2){text-align:right;font-variant-numeric:tabular-nums}" +
      "tr:nth-child(even){background:#f9f9f7}" +
      "footer{margin-top:26px;padding-top:12px;border-top:1px solid #e1e0d9;color:#898781;font-size:11px}" +
      ".print-btn{position:fixed;top:14px;right:14px;background:#2a78d6;color:#fff;border:none;border-radius:8px;" +
      "padding:10px 16px;font:inherit;font-weight:600;cursor:pointer}" +
      "@media print{.print-btn{display:none}body{padding:0}}" +
      "</style></head><body>" +
      "<button class=\"print-btn\" onclick=\"window.print()\">Imprimer / PDF</button>" +
      "<header><div><p class=\"marque\">SECAAimmo</p><h1>Rapport de rentabilité locative</h1></div>" +
      "<span class=\"date\">" + date + "</span></header>" +

      "<div class=\"kpis\">" +
      "<div class=\"kpi\"><span>Rentabilité brute</span><b>" + fmtPct(r.brute) + "</b></div>" +
      "<div class=\"kpi\"><span>Nette de charges</span><b>" + fmtPct(r.nette) + "</b></div>" +
      "<div class=\"kpi\"><span>Nette-nette (après impôts)</span><b>" + fmtPct(r.netteNette) + "</b></div>" +
      "<div class=\"kpi\"><span>Cash-flow mensuel</span><b class=\"" + (r.cashflowMensuel >= 0 ? "pos" : "neg") + "\">" +
      (r.cashflowMensuel >= 0 ? "+" : "") + fmtEur(r.cashflowMensuel) + "</b></div>" +
      "</div>" +

      "<h2>Le bien</h2><table>" +
      ligne("Prix d'achat", fmtEur(f.prix)) +
      ligne("Surface", f.surface + " m² (" + fmtEur(r.prixM2) + " / m²)") +
      ligne("Type", typeLabel) +
      ligne("Frais de notaire", fmtEur(f.notaire)) +
      ligne("Travaux", fmtEur(f.travaux)) +
      ligne("Mobilier", fmtEur(f.mobilier)) +
      ligne("Coût total de l'opération", fmtEur(r.coutTotal)) +
      "</table>" +

      "<h2>Revenus et charges annuelles</h2><table>" +
      ligne("Loyer mensuel hors charges", fmtEur(f.loyer)) +
      ligne("Vacance locative", f.vacanceSemaines + " semaine(s) / an") +
      ligne("Loyer annuel (vacance déduite)", fmtEur(r.loyerAnnuel)) +
      ligne("Charges copropriété non récupérables", fmtEur(f.copro)) +
      ligne("Taxe foncière", fmtEur(f.tf)) +
      ligne("Assurance PNO", fmtEur(f.pno)) +
      ligne("Entretien / provisions", fmtEur(f.entretien)) +
      ligne("Gestion locative", (f.gestionPct * 100).toLocaleString("fr-FR") + " % du loyer") +
      ligne("Garantie loyers impayés", (f.gliPct * 100).toLocaleString("fr-FR") + " % du loyer") +
      ligne("Total charges annuelles", fmtEur(r.chargesAnnuelles)) +
      "</table>" +

      "<h2>Financement</h2><table>" +
      ligne("Apport", fmtEur(f.apport)) +
      ligne("Montant emprunté", fmtEur(r.emprunt)) +
      ligne("Taux du crédit", (f.taux * 100).toLocaleString("fr-FR") + " % / an sur " + f.duree + " ans") +
      ligne("Assurance emprunteur", (f.assu * 100).toLocaleString("fr-FR") + " % / an") +
      ligne("Mensualité (assurance incluse)", fmtEur(r.mensualite) + " / mois") +
      ligne("dont crédit / dont assurance", fmtEur(r.mensualiteHorsAssu) + " / " + fmtEur(r.mensualiteAssu)) +
      ligne("Coût total du crédit (intérêts + assurance)", fmtEur(r.coutCredit)) +
      "</table>" +

      "<h2>Fiscalité (estimation, année 1)</h2><table>" +
      ligne("Régime", regimeLabel) +
      ligne("Tranche marginale d'imposition", (f.tmi * 100).toLocaleString("fr-FR") + " %") +
      (r.regimeAmorti ? ligne(
        f.amortMode === "composants"
          ? "Amortissement annuel (par composants, détail ci-dessous)"
          : "Amortissement annuel estimé (bâti 85 % du prix sur 30 ans, travaux sur 15 ans, mobilier sur 7 ans)",
        fmtEur(r.amortissement) + " / an") : "") +
      ligne("Impôts + prélèvements sociaux", fmtEur(r.impots)) +
      ligne("Effort d'épargne annuel", r.cashflowMensuel >= 0 ? "0 €" : fmtEur(-r.cashflowMensuel * 12) + " / an") +
      (refCGI ? ligne("Référence", refCGI) : "") +
      "</table>" +

      (r.regimeAmorti && r.amortDetail.length ?
        "<h2>Détail de l'amortissement par composants</h2><table>" +
        r.amortDetail.map(function (d) { return ligne(d.label, fmtEur(d.dotation) + " / an"); }).join("") +
        ligne("Total", fmtEur(r.amortissement) + " / an") +
        "</table>" : "") +

      blocZone() +

      "<h2>Projection sur la durée du prêt</h2>" +
      "<table><tr><th></th><th>Capital restant dû</th><th>Cash-flow cumulé</th></tr>" + projRows + "</table>" +

      "<footer>Rapport généré par SECAAimmo le " + date + ". Hypothèses constantes (loyer, charges, fiscalité) ; " +
      "fiscalité simplifiée, amortissements estimés. Ce document est une estimation d'aide à la décision et ne " +
      "constitue pas un conseil financier, fiscal ou immobilier.</footer>" +
      "</body></html>";
  }

  function nomFichier() {
    const d = new Date();
    const pad = function (n) { return String(n).padStart(2, "0"); };
    return "rapport-secaaimmo-" + d.getFullYear() + "-" + pad(d.getMonth() + 1) + "-" + pad(d.getDate()) + ".html";
  }

  function telecharger() {
    const html = construireHTML();
    if (!html) return;
    const blob = new Blob([html], { type: "text/html;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = nomFichier();
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(function () { URL.revokeObjectURL(url); }, 10000);
  }

  function apercu() {
    const html = construireHTML();
    if (!html) return;
    const blob = new Blob([html], { type: "text/html;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const w = window.open(url, "_blank");
    if (!w) {
      // Pop-up bloquée (ou mode standalone restrictif) : repli sur le téléchargement.
      URL.revokeObjectURL(url);
      telecharger();
    }
  }

  document.addEventListener("DOMContentLoaded", function () {
    const btnDl = document.getElementById("rapport-telecharger");
    const btnApercu = document.getElementById("rapport-apercu");
    if (btnDl) btnDl.addEventListener("click", telecharger);
    if (btnApercu) btnApercu.addEventListener("click", apercu);
  });

  window.PoppyRapport = { html: construireHTML };
})();
