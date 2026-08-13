/*
 * Navigation entre onglets et bascule de thème clair / sombre.
 */
(function () {
  const THEME_KEY = "immopoppy.theme";

  function activerOnglet(nom) {
    document.querySelectorAll(".tab").forEach(function (tab) {
      const actif = tab.dataset.tab === nom;
      tab.classList.toggle("is-active", actif);
      tab.setAttribute("aria-selected", actif ? "true" : "false");
    });
    document.querySelectorAll(".panel").forEach(function (panel) {
      const actif = panel.id === "panel-" + nom;
      panel.classList.toggle("is-active", actif);
      panel.hidden = !actif;
    });
    // Les graphiques SVG ont besoin d'un conteneur mesurable : on les (re)dessine
    // seulement une fois l'onglet visible.
    if (nom === "prix" && window.PoppyPrix) PoppyPrix.onShow();
    if (nom === "renta" && window.PoppyCalc) PoppyCalc.redessiner();
  }

  function themeCourant() {
    return document.documentElement.getAttribute("data-theme") ||
      (window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
  }

  function basculerTheme() {
    const suivant = themeCourant() === "dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", suivant);
    localStorage.setItem(THEME_KEY, suivant);
    // Les couleurs des graphiques sont lues au rendu : on redessine.
    if (window.PoppyCalc) PoppyCalc.redessiner();
    if (window.PoppyPrix && !document.getElementById("panel-prix").hidden) PoppyPrix.onShow();
  }

  document.addEventListener("DOMContentLoaded", function () {
    const sauvegarde = localStorage.getItem(THEME_KEY);
    if (sauvegarde) document.documentElement.setAttribute("data-theme", sauvegarde);

    document.querySelectorAll(".tab").forEach(function (tab) {
      tab.addEventListener("click", function () { activerOnglet(tab.dataset.tab); });
    });
    document.getElementById("theme-toggle").addEventListener("click", basculerTheme);
  });
})();
