/*
 * Service worker ImmoPoppy : met l'app en cache pour un usage hors-ligne.
 * - Fichiers de l'app : cache d'abord (mise à jour en arrière-plan).
 * - APIs externes (geo.api.gouv.fr, DVF) : réseau uniquement — jamais mises en
 *   cache, l'app a déjà son propre repli sur les données embarquées.
 */
const CACHE = "immopoppy-v1";

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

self.addEventListener("fetch", function (event) {
  const url = new URL(event.request.url);
  if (event.request.method !== "GET" || url.origin !== self.location.origin) return;

  event.respondWith(
    caches.match(event.request).then(function (cached) {
      const fetched = fetch(event.request).then(function (res) {
        if (res && res.ok) {
          const clone = res.clone();
          caches.open(CACHE).then(function (cache) { cache.put(event.request, clone); });
        }
        return res;
      }).catch(function () { return cached; });
      return cached || fetched;
    })
  );
});
