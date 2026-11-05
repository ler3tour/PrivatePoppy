/*
 * Module Annonce : colle l'URL ou le texte d'une annonce immobilière,
 * l'app en extrait prix, surface, type et code postal, estime le loyer
 * avec les loyers indicatifs au m² du département (data-loyers.js) et
 * remplit le calculateur pour une première idée de rentabilité.
 *
 * Limite assumée : les grands sites d'annonces bloquent la lecture de
 * leurs pages depuis un autre site (CORS, anti-robots). On tente quand
 * même la lecture de l'URL, puis on se rabat sur l'analyse du texte de
 * l'URL elle-même, et surtout sur le texte de l'annonce collé tel quel.
 */
(function () {
  const $ = function (id) { return document.getElementById(id); };
  const fmtEur = function (v) {
    return v.toLocaleString("fr-FR", { style: "currency", currency: "EUR", maximumFractionDigits: 0 });
  };

  function normaliser(texte) {
    return texte.replace(/ /g, " ").replace(/\s+/g, " ");
  }

  /* ---------- Extraction ---------- */
  function extrairePrix(texte) {
    const prix = [];
    // « 150 000 € », « 150.000 euros », « 150000€ »
    const re = /(\d{1,3}(?:[\s.]\d{3})+|\d{4,8})\s*(?:€|euros?\b)/gi;
    let m;
    while ((m = re.exec(texte)) !== null) {
      const v = parseInt(m[1].replace(/[\s.]/g, ""), 10);
      if (v >= 10000 && v <= 10000000) prix.push(v);
    }
    // Dans une URL : « 150000-euros », « prix-150000 »
    if (!prix.length) {
      const reUrl = /(?:prix|price)[^\d]{0,3}(\d{4,8})|(\d{5,8})\s*(?:-?euros?)/gi;
      while ((m = reUrl.exec(texte)) !== null) {
        const v = parseInt(m[1] || m[2], 10);
        if (v >= 10000 && v <= 10000000) prix.push(v);
      }
    }
    return prix.length ? Math.max.apply(null, prix) : null;
  }

  function extraireSurface(texte) {
    const re = /(\d{1,3}(?:[.,]\d{1,2})?)\s*m\s?(?:²|2\b)/gi;
    let m;
    while ((m = re.exec(texte)) !== null) {
      const v = parseFloat(m[1].replace(",", "."));
      if (v < 9 || v > 600) continue;
      // Écarte les surfaces de terrain ou de jardin.
      const avant = texte.slice(Math.max(0, m.index - 40), m.index).toLowerCase();
      if (/terrain|parcelle|jardin|ext[ée]rieur/.test(avant)) continue;
      return v;
    }
    return null;
  }

  function extraireType(texte) {
    const bas = texte.toLowerCase();
    if (/\bmaison|villa|pavillon|longère|fermette\b/.test(bas)) return "maison";
    return "appartement";
  }

  function extraireLocalisation(texte) {
    // Code postal : 5 chiffres isolés dont le département est connu.
    const re = /\b(\d{5})\b/g;
    let m;
    while ((m = re.exec(texte)) !== null) {
      const cp = m[1];
      let dept = cp.slice(0, 2);
      if (dept === "20") dept = parseInt(cp, 10) < 20200 ? "2A" : "2B";
      if (LOYERS_DEPARTEMENTS[dept]) {
        // Nom de ville juste avant ou après le code postal, si présent.
        const autour = texte.slice(Math.max(0, m.index - 40), m.index + 46);
        const ville =
          /([A-ZÀ-Ü][a-zà-ÿ'’-]{2,}(?:[\s-][A-ZÀ-Ü][a-zà-ÿ'’-]{2,})*)\s*[(,]?\s*\d{5}/.exec(autour) ||
          /\d{5}\s*[),]?\s*([A-ZÀ-Ü][a-zà-ÿ'’-]{2,}(?:[\s-][A-ZÀ-Ü][a-zà-ÿ'’-]{2,})*)/.exec(autour);
        return { cp: cp, dept: dept, ville: ville ? ville[1] : null };
      }
    }
    return null;
  }

  function analyserTexte(texte) {
    const t = normaliser(texte);
    return {
      prix: extrairePrix(t),
      surface: extraireSurface(t),
      type: extraireType(t),
      localisation: extraireLocalisation(t)
    };
  }

  /* ---------- Lecture d'une URL (au mieux) ---------- */
  async function lireURL(url) {
    const controller = new AbortController();
    const timer = setTimeout(function () { controller.abort(); }, 6000);
    try {
      const res = await fetch(url, { signal: controller.signal });
      if (!res.ok) throw new Error("HTTP " + res.status);
      const html = await res.text();
      // Texte brut de la page, balises retirées.
      const doc = new DOMParser().parseFromString(html, "text/html");
      return doc.body ? doc.body.textContent : html;
    } finally {
      clearTimeout(timer);
    }
  }

  function texteDepuisURL(url) {
    // Les adresses d'annonces portent souvent ville, surface et prix en clair.
    try {
      return decodeURIComponent(url).replace(/https?:\/\//, "").replace(/[-_/+.?=&#]/g, " ");
    } catch (e) {
      return url.replace(/[-_/+.?=&#]/g, " ");
    }
  }

  /* ---------- Remplissage du calculateur ---------- */
  function remplir(resultat) {
    const faits = [];
    const manques = [];

    if (resultat.prix) {
      $("in-prix").value = resultat.prix;
      faits.push("prix " + fmtEur(resultat.prix));
    } else {
      manques.push("le prix");
    }

    if (resultat.surface) {
      $("in-surface").value = resultat.surface;
      faits.push(resultat.surface + " m²");
    } else {
      manques.push("la surface");
    }

    faits.push(resultat.type);

    let loyerEstime = null;
    if (resultat.localisation && resultat.surface) {
      const loyers = LOYERS_DEPARTEMENTS[resultat.localisation.dept];
      const loyerM2 = resultat.type === "maison" ? loyers.maison : loyers.appartement;
      loyerEstime = Math.round(resultat.surface * loyerM2 / 10) * 10;
      $("in-loyer").value = loyerEstime;
      const nomDept = (typeof PRIX_DEPARTEMENTS !== "undefined" && PRIX_DEPARTEMENTS[resultat.localisation.dept])
        ? PRIX_DEPARTEMENTS[resultat.localisation.dept].nom : resultat.localisation.dept;
      faits.push((resultat.localisation.ville ? resultat.localisation.ville + " " : "") +
        "(" + resultat.localisation.cp + ") : loyer estimé " + fmtEur(loyerEstime) + " / mois (" +
        loyerM2.toLocaleString("fr-FR") + " € / m², indicatif " + nomDept + ")");
    } else if (!resultat.localisation) {
      manques.push("le code postal (nécessaire pour estimer le loyer)");
    }

    // Déclenche notaire automatique + recalcul complet.
    $("in-prix").dispatchEvent(new Event("input", { bubbles: true }));

    return { faits: faits, manques: manques, loyerEstime: loyerEstime };
  }

  function afficherResultat(bilan, prefixe) {
    const zone = $("annonce-resultat");
    let html = "";
    if (prefixe) html += "<p class=\"hint hint-alerte\">" + prefixe + "</p>";
    if (bilan.faits.length) {
      html += "<p class=\"hint annonce-ok\">Annonce analysée : " + bilan.faits.join(" · ") +
        ". Le calculateur est rempli, la rentabilité ci-contre est mise à jour.</p>";
    }
    if (bilan.manques.length) {
      html += "<p class=\"hint\">Non détecté : " + bilan.manques.join(", ") +
        ". Complète à la main, ou colle un extrait d'annonce plus complet.</p>";
    }
    zone.innerHTML = html;
    zone.hidden = false;
  }

  async function analyser() {
    const brut = $("annonce-input").value.trim();
    const zone = $("annonce-resultat");
    if (!brut) {
      zone.innerHTML = "<p class=\"hint\">Colle d'abord le lien ou le texte de l'annonce.</p>";
      zone.hidden = false;
      return;
    }

    const estURL = /^https?:\/\/\S+$/i.test(brut);
    if (!estURL) {
      afficherResultat(remplir(analyserTexte(brut)), null);
      return;
    }

    zone.innerHTML = "<p class=\"hint\">Lecture de la page en cours…</p>";
    zone.hidden = false;
    let prefixe = null;
    let resultat;
    try {
      const page = await lireURL(brut);
      resultat = analyserTexte(page);
      if (!resultat.prix && !resultat.surface) throw new Error("page illisible");
    } catch (e) {
      // Lecture bloquée (cas normal sur les grands sites) : on analyse l'URL elle-même.
      resultat = analyserTexte(texteDepuisURL(brut));
      prefixe = "Ce site bloque la lecture directe de ses pages. L'adresse du lien a été analysée à la place ; " +
        "pour un résultat complet, copie le texte de l'annonce (prix, surface, code postal) et colle-le ici.";
    }
    afficherResultat(remplir(resultat), prefixe);
  }

  document.addEventListener("DOMContentLoaded", function () {
    const btn = $("annonce-analyser");
    if (btn) btn.addEventListener("click", analyser);
  });

  window.PoppyAnnonce = { analyserTexte: analyserTexte };
})();
