'use strict';

// Offline support. Every same-origin GET inside this worker's scope goes to
// the network first, revalidating the HTTP cache, so an online visitor always
// runs the latest deployment; the response also refreshes this cache. The
// cache answers only when the network fails. After startup the page posts the
// URLs it has loaded, so a single online visit is enough to work offline.
// Responses are marked no-cache: otherwise the browser's in-memory cache may
// reuse a heuristically fresh script on reload without asking this worker.
//
// Bump CACHE when this file's caching logic changes; content updates need no
// bump because they are fetched from the network anyway.
const CACHE_PREFIX = 'matriks-offline-';
const CACHE = `${CACHE_PREFIX}v1`;

// Files the browser fetches outside the resource timeline (manifest, icons).
const SHELL = [
  './',
  'flutter_bootstrap.js',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-192.png',
  'icons/Icon-maskable-512.png',
];

const scope = self.registration.scope;
const inScope = (url) => url.startsWith(scope);

self.addEventListener('install', () => self.skipWaiting());

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      // Other apps on the same origin (GitHub Pages serves every project of
      // a user from one) keep their caches; only older Matriks ones go.
      for (const name of await caches.keys()) {
        if (name.startsWith(CACHE_PREFIX) && name !== CACHE) {
          await caches.delete(name);
        }
      }
      await self.clients.claim();
    })(),
  );
});

// Resolves to the network response and a promise that stores a copy of it.
// A storage failure (quota, disk) never stops the response being served.
async function fetchFresh(request) {
  const response = await fetch(request, { cache: 'no-cache' });
  if (response.status !== 200 || response.type !== 'basic' || response.redirected) {
    return { response, stored: Promise.resolve() };
  }
  const headers = new Headers(response.headers);
  headers.set('Cache-Control', 'no-cache');
  const fresh = new Response(response.body, { status: 200, statusText: response.statusText, headers });
  const copy = fresh.clone();
  const stored = caches
    .open(CACHE)
    .then((cache) => cache.put(request, copy))
    .catch(() => {});
  return { response: fresh, stored };
}

async function fromCache(request) {
  const cache = await caches.open(CACHE);
  const navigate = request.mode === 'navigate';
  return (
    (await cache.match(request, { ignoreSearch: navigate })) ||
    (navigate ? await cache.match(scope) : undefined)
  );
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET' || !inScope(request.url)) return;
  event.respondWith(
    (async () => {
      try {
        const { response, stored } = await fetchFresh(request);
        event.waitUntil(stored);
        return response;
      } catch (error) {
        const cached = await fromCache(request).catch(() => undefined);
        if (cached) return cached;
        throw error;
      }
    })(),
  );
});

// Caches what the page loaded before this worker controlled it. URLs already
// cached are skipped: the fetch handler keeps those current.
const storing = new Set();
self.addEventListener('message', (event) => {
  const urls = event.data && event.data.cacheUrls;
  if (!Array.isArray(urls)) return;
  const wanted = new Set(
    [...SHELL, ...urls].map((url) => new URL(url, scope).href.split('#')[0]).filter(inScope),
  );
  event.waitUntil(
    Promise.all(
      [...wanted].map(async (url) => {
        if (storing.has(url)) return;
        storing.add(url);
        try {
          if (!(await caches.match(url, { cacheName: CACHE }))) {
            await (await fetchFresh(new Request(url))).stored;
          }
        } catch (_) {
          // Offline or removed; the next visit tries again.
        } finally {
          storing.delete(url);
        }
      }),
    ),
  );
});
