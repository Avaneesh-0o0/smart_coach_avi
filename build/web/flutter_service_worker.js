'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "56c6a512d1e343e918ae6b79b057e523",
"assets/AssetManifest.bin.json": "445c7b8256ab2d2d12ed6567fc725e10",
"assets/assets/images/pisolve.jpg": "5ec0e80c81342d7f73a3d97696d6d56f",
"assets/assets/images/pisolve_name.jpeg": "13a8e99eb2c5c574e64e8b2c408d399e",
"assets/assets/images/vasp.png": "7e9f60523d6c83005f1443c45b23f2dc",
"assets/assets/svgs/acp_coaches.svg": "872606dad658becac4d0136860c35aef",
"assets/assets/svgs/alert_icon.svg": "b95357ffddb1464a574e05df15a789e0",
"assets/assets/svgs/axel_green.svg": "fa855c02d63e5aba8b554f260f88ac04",
"assets/assets/svgs/bcgreen_indicate.svg": "f96cee88cce67774090de80c9f68f703",
"assets/assets/svgs/bcpressure.svg": "1bc8d27d46236d03cde45b0b3c7154cc",
"assets/assets/svgs/bcred_indicate.svg": "b84bc7ae518fbc4f2f40ad8157a3a4f3",
"assets/assets/svgs/bcyellow_indicate.svg": "3eb8786a2985fc7d583ce234a22f0d2b",
"assets/assets/svgs/blue_axle.svg": "f1e54500b808498ba9f2ccc44814a465",
"assets/assets/svgs/coaches.svg": "d76d1b8c79a71f0c13cb0d6dc6ca091b",
"assets/assets/svgs/emergency.svg": "b2e210de11c093dd9eea53e45405e9df",
"assets/assets/svgs/eye_icon.svg": "6fa8e349333da503514e7f3f47f94632",
"assets/assets/svgs/graph_icon.svg": "e5584355ce405d934cb27f1862af1065",
"assets/assets/svgs/grey_axle.svg": "f3834a52d3de4587e2da5448ed386888",
"assets/assets/svgs/ic_email.svg": "6951d266137072439b70966c8d6fc966",
"assets/assets/svgs/ic_eye.svg": "ff91b7640e96b4a77fe857318655e3f4",
"assets/assets/svgs/ic_lock.svg": "13ac11d3fbf0d514e0038ec7cf8e6058",
"assets/assets/svgs/ic_train.svg": "9e49c3a39c7e4d5f5a7a9da3424da6ef",
"assets/assets/svgs/red_axle.svg": "92098cce94144d827aca5813149457b4",
"assets/assets/svgs/red_chain.svg": "797f753cf0e19be1fedd3a3344f0d22f",
"assets/assets/svgs/refresh_icon.svg": "e7e629b9eef85d1d72f821bedace89f9",
"assets/assets/svgs/report_icon.svg": "48a0bb5ecfc68231f6edd9b5e3b9b44a",
"assets/assets/svgs/setting_icon.svg": "9e3b61118f45aaae8e00bb92d8e9ddab",
"assets/assets/svgs/train_icon.svg": "0951dcd19862a7589bba355cd4eb311c",
"assets/assets/svgs/waterdrop_icon.svg": "966e25dbdfe079219ed247ec0afe4312",
"assets/assets/svgs/yellow_axle.svg": "7479b9cfcfb499a5ab405f91c0d49f59",
"assets/FontManifest.json": "24318b0993e324608d4127c3bd9f02c4",
"assets/fonts/MaterialIcons-Regular.otf": "37995f559a815d843fb7d8bbaff9894e",
"assets/NOTICES": "b7e336d0ffd4a68af1915500dc3e25be",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/syncfusion_flutter_datagrid/assets/font/FilterIcon.ttf": "b8e5e5bf2b490d3576a9562f24395532",
"assets/packages/syncfusion_flutter_datagrid/assets/font/UnsortIcon.ttf": "acdd567faa403388649e37ceb9adeb44",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"assets/shaders/stretch_effect.frag": "40d68efbbf360632f614c731219e95f0",
"canvaskit/canvaskit.js": "8331fe38e66b3a898c4f37648aaf7ee2",
"canvaskit/canvaskit.js.symbols": "a3c9f77715b642d0437d9c275caba91e",
"canvaskit/canvaskit.wasm": "9b6a7830bf26959b200594729d73538e",
"canvaskit/chromium/canvaskit.js": "a80c765aaa8af8645c9fb1aae53f9abf",
"canvaskit/chromium/canvaskit.js.symbols": "e2d09f0e434bc118bf67dae526737d07",
"canvaskit/chromium/canvaskit.wasm": "a726e3f75a84fcdf495a15817c63a35d",
"canvaskit/skwasm.js": "8060d46e9a4901ca9991edd3a26be4f0",
"canvaskit/skwasm.js.symbols": "3a4aadf4e8141f284bd524976b1d6bdc",
"canvaskit/skwasm.wasm": "7e5f3afdd3b0747a1fd4517cea239898",
"canvaskit/skwasm_heavy.js": "740d43a6b8240ef9e23eed8c48840da4",
"canvaskit/skwasm_heavy.js.symbols": "0755b4fb399918388d71b59ad390b055",
"canvaskit/skwasm_heavy.wasm": "b0be7910760d205ea4e011458df6ee01",
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "24bc71911b75b5f8135c949e27a2984e",
"flutter_bootstrap.js": "c2ccdc5c91af2a1ea20919e351a0a2cd",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "8c734908f2767d418b77ab913acdee92",
"/": "8c734908f2767d418b77ab913acdee92",
"main.dart.js": "16026fa0b10ebbf265959c90018d0954",
"manifest.json": "cb94160d9c482d3aee983c51be052f90",
"version.json": "d19c810678b87702f5ba451de7b22ea8"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
