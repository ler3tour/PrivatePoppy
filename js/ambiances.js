/*
 * Module Ambiances : moodboards par style, filtres par tags façon Pinterest,
 * et créateur d'ambiances personnalisées (persistées en localStorage).
 */
(function () {
  const STORAGE_KEY = "immopoppy.ambiances";
  const $ = function (id) { return document.getElementById(id); };

  let tagsActifs = new Set();

  /* ---------- Persistance ---------- */
  function chargerPerso() {
    try {
      return JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];
    } catch (e) {
      return [];
    }
  }

  function sauverPerso(liste) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(liste));
  }

  function toutesLesAmbiances() {
    return AMBIANCES_STYLES.concat(chargerPerso());
  }

  function tousLesTags() {
    const set = new Set();
    toutesLesAmbiances().forEach(function (a) {
      a.tags.forEach(function (t) { set.add(t); });
    });
    return Array.from(set).sort();
  }

  /* ---------- Contraste texte sur tuile colorée ---------- */
  function encreSur(hex) {
    const c = hex.replace("#", "");
    const r = parseInt(c.substr(0, 2), 16), g = parseInt(c.substr(2, 2), 16), b = parseInt(c.substr(4, 2), 16);
    const lum = (0.2126 * r + 0.7152 * g + 0.0722 * b) / 255;
    return lum > 0.55 ? "#1a1a19" : "#ffffff";
  }

  /* ---------- Rendu ---------- */
  function renduMoodboard(a) {
    const p = a.palette;
    const board = document.createElement("div");
    board.className = "moodboard";
    // Composition type masonry : grandes tuiles, dégradés et tuiles-tags.
    const tuiles = [
      { style: "background:" + p[0], cls: "tile-tall" },
      { style: "background:linear-gradient(135deg," + p[1] + "," + p[2] + ")", cls: "tile-wide" },
      { style: "background:" + p[3], cls: "" },
      { style: "background:" + p[4], cls: "tile-tall" },
      { style: "background:linear-gradient(45deg," + p[2] + "," + p[4] + ")", cls: "" },
      { style: "background:" + p[1], cls: "" },
      { style: "background:linear-gradient(135deg," + p[0] + "," + p[3] + ")", cls: "tile-wide" }
    ];
    tuiles.forEach(function (t) {
      const div = document.createElement("div");
      div.className = "tile " + t.cls;
      div.setAttribute("style", t.style);
      board.appendChild(div);
    });
    // Deux tuiles portant un tag, comme une épingle.
    a.tags.slice(0, 2).forEach(function (tag, i) {
      const div = document.createElement("div");
      const bg = p[i === 0 ? 2 : 3];
      div.className = "tile tile-label" + (i === 0 ? " tile-wide" : "");
      div.setAttribute("style", "background:" + bg + ";color:" + encreSur(bg));
      div.textContent = tag;
      board.appendChild(div);
    });
    return board;
  }

  function renduCarte(a) {
    const card = document.createElement("article");
    card.className = "ambiance-card";
    card.appendChild(renduMoodboard(a));

    const body = document.createElement("div");
    body.className = "ambiance-body";

    const titre = document.createElement("h3");
    titre.className = "ambiance-title";
    titre.innerHTML = (a.emoji || "🎨") + " " + a.nom +
      (a.perso ? ' <span class="badge-custom">perso</span>' : "");
    body.appendChild(titre);

    if (a.description) {
      const desc = document.createElement("p");
      desc.className = "ambiance-desc";
      desc.textContent = a.description;
      body.appendChild(desc);
    }

    if (a.materiaux && a.materiaux.length) {
      const mat = document.createElement("p");
      mat.className = "ambiance-materials";
      mat.textContent = "Matériaux : " + a.materiaux.join(" · ");
      body.appendChild(mat);
    }

    const tags = document.createElement("div");
    tags.className = "ambiance-tags";
    a.tags.forEach(function (t) {
      const chip = document.createElement("span");
      chip.className = "mini-tag";
      chip.textContent = t;
      tags.appendChild(chip);
    });
    body.appendChild(tags);

    if (a.perso) {
      const del = document.createElement("button");
      del.className = "ambiance-delete";
      del.textContent = "Supprimer";
      del.addEventListener("click", function () {
        sauverPerso(chargerPerso().filter(function (x) { return x.id !== a.id; }));
        toutRendre();
      });
      body.appendChild(del);
    }

    card.appendChild(body);
    return card;
  }

  function renduGrille() {
    const grid = $("ambiance-grid");
    grid.innerHTML = "";
    const actifs = Array.from(tagsActifs);
    const visibles = toutesLesAmbiances().filter(function (a) {
      return actifs.every(function (t) { return a.tags.indexOf(t) !== -1; });
    });
    if (!visibles.length) {
      const note = document.createElement("p");
      note.className = "empty-note";
      note.textContent = "Aucune ambiance ne combine ces tags — retire un filtre ou crée la tienne juste en dessous ✨";
      grid.appendChild(note);
      return;
    }
    visibles.forEach(function (a) { grid.appendChild(renduCarte(a)); });
  }

  function renduNuageTags() {
    const cloud = $("tag-cloud");
    cloud.innerHTML = "";
    tousLesTags().forEach(function (t) {
      const chip = document.createElement("button");
      chip.type = "button";
      chip.className = "tag-chip" + (tagsActifs.has(t) ? " is-on" : "");
      chip.textContent = t;
      chip.addEventListener("click", function () {
        if (tagsActifs.has(t)) tagsActifs.delete(t); else tagsActifs.add(t);
        renduNuageTags();
        renduGrille();
      });
      cloud.appendChild(chip);
    });
  }

  /* ---------- Créateur ---------- */
  function renduCreateur() {
    const select = $("amb-base");
    select.innerHTML = "";
    AMBIANCES_STYLES.forEach(function (s) {
      const opt = document.createElement("option");
      opt.value = s.id;
      opt.textContent = s.emoji + " " + s.nom;
      select.appendChild(opt);
    });

    const colorHost = $("amb-colors");
    colorHost.innerHTML = "";
    for (let i = 0; i < 5; i++) {
      const input = document.createElement("input");
      input.type = "color";
      colorHost.appendChild(input);
    }

    function appliquerBase() {
      const base = AMBIANCES_STYLES.find(function (s) { return s.id === select.value; }) || AMBIANCES_STYLES[0];
      Array.from(colorHost.children).forEach(function (input, i) {
        input.value = base.palette[i];
      });
      renduTagsCreateur(new Set(base.tags));
    }

    select.addEventListener("change", appliquerBase);
    appliquerBase();
  }

  let tagsCreateur = new Set();

  function renduTagsCreateur(preselection) {
    if (preselection) tagsCreateur = new Set(preselection);
    const host = $("amb-tags");
    host.innerHTML = "";
    tousLesTags().forEach(function (t) {
      const chip = document.createElement("button");
      chip.type = "button";
      chip.className = "tag-chip" + (tagsCreateur.has(t) ? " is-on" : "");
      chip.textContent = t;
      chip.addEventListener("click", function () {
        if (tagsCreateur.has(t)) tagsCreateur.delete(t); else tagsCreateur.add(t);
        renduTagsCreateur();
      });
      host.appendChild(chip);
    });
  }

  function enregistrerAmbiance() {
    const nom = $("amb-nom").value.trim();
    const feedback = $("amb-feedback");
    if (!nom) {
      feedback.textContent = "Donne un nom à ton ambiance.";
      return;
    }
    if (tagsCreateur.size === 0) {
      feedback.textContent = "Sélectionne au moins un tag.";
      return;
    }
    const palette = Array.from($("amb-colors").children).map(function (i) { return i.value; });
    const perso = chargerPerso();
    perso.push({
      id: "perso-" + nom.toLowerCase().replace(/[^a-z0-9]+/g, "-") + "-" + perso.length,
      nom: nom,
      emoji: "🧵",
      description: $("amb-desc").value.trim(),
      palette: palette,
      materiaux: [],
      tags: Array.from(tagsCreateur),
      perso: true
    });
    sauverPerso(perso);
    $("amb-nom").value = "";
    $("amb-desc").value = "";
    feedback.textContent = "Ambiance « " + nom + " » enregistrée ✔";
    toutRendre();
  }

  function toutRendre() {
    renduNuageTags();
    renduGrille();
    renduTagsCreateur();
  }

  document.addEventListener("DOMContentLoaded", function () {
    renduCreateur();
    toutRendre();
    $("amb-save").addEventListener("click", enregistrerAmbiance);
  });
})();
