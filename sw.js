const CACHE = "treino-web-v2";
const FILES = ["./", "index.html", "styles.css", "catalog.js", "videos.js", "app.js", "manifest.webmanifest", "icon.png"];

self.addEventListener("install", (event) => {
  event.waitUntil(caches.open(CACHE).then((cache) => cache.addAll(FILES)));
});

self.addEventListener("fetch", (event) => {
  event.respondWith(
    caches.match(event.request).then((hit) => hit || fetch(event.request))
  );
});
