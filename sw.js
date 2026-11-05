/*
 * Service worker SECAAimmo : met l'app en cache pour un usage hors-ligne.
 * - Fichiers de l'app : réseau d'abord (version toujours fraîche en ligne),
 *   repli sur le cache hors connexion ou si le réseau tarde.
 * - APIs externes (geo.api.gouv.fr, DVF) : réseau uniquement — jamais mises en
 *   cache, l'app a déjà son propre repli sur les données embarquées.
 */
const CACHE = "secaaimmo-v5";

const SHELL = [
  "./",
  "./index.html",
  "./manifest.webmanifest",
  "./css/styles.css",
  "./js/data-prix.js",
  "./js/data-ambiances.js",
  "./js/charts.js",
  "./js/calculator.js",
  "./js/prix.js",
  "./js/rapport.js",
  "./js/ambiances.js",
  "./js/app.js",
  "./icons/icon-192.png",
  "./icons/icon-512.png",
  "./icons/apple-touch-icon.png"
];

self.addEventListener("install", function (event) {
  event.waitUntil(
    caches.open(CACHE).then(function (cache) { return cache.addAll(SHELL); })
      .then(function () { return self.skipWaiting(); })
  );
});

self.addEventListener("activate", function (event) {
  event.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(keys.filter(function (k) { return k !== CACHE; })
        .map(function (k) { return caches.delete(k); }));
    }).then(function () { return self.clients.claim(); })
  );
});

function fetchAvecDelai(request, ms) {
  return new Promise(function (resolve, reject) {
    const timer = setTimeout(function () { reject(new Error("délai réseau dépassé")); }, ms);
    // cache: "no-cache" force la revalidation auprès du serveur (GitHub Pages
    // met un max-age de 10 min qui retardait sinon les mises à jour).
    fetch(request, { cache: "no-cache" }).then(
      function (res) { clearTimeout(timer); resolve(res); },
      function (err) { clearTimeout(timer); reject(err); }
    );
  });
}

self.addEventListener("fetch", function (event) {
  const url = new URL(event.request.url);
  if (event.request.method !== "GET" || url.origin !== self.location.origin) return;

  // Réseau d'abord : en ligne, l'utilisateur a toujours la dernière version ;
  // hors-ligne (ou réseau trop lent), le cache prend le relais.
  event.respondWith(
    fetchAvecDelai(event.request, 5000).then(function (res) {
      if (res && res.ok) {
        const clone = res.clone();
        caches.open(CACHE).then(function (cache) { cache.put(event.request, clone); });
      }
      return res;
    }).catch(function () {
      return caches.match(event.request).then(function (cached) {
        if (cached) return cached;
        return Response.error();
      });
    })
  );
});
