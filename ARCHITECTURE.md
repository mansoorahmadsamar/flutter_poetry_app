# Sukhan (Jahan-e-Sukhan) — Architecture

> How the Flutter app works **today**: a map for engineers and AI agents, linked from `AGENTS.md`.
> It supersedes `APP_ARCHITECTURE.md`, an older untracked overview that no longer matches the code (for example, it lists a `lib/shared/` folder that does not exist).
> Every claim cites `file:line` from branch `docs/engineering-setup` (Oct 2026). Anything not checked against the code or a live system is marked **UNVERIFIED**.
> When code and this document disagree, the code wins. Fix this document in the same PR.

---

## 1. Stack at a glance

| Concern | Choice | Notes |
|---|---|---|
| SDK | Flutter 3.44.4 / Dart 3.12.2 (local) | CI pins the same **Flutter 3.44.4** (`.github/workflows/play-store-release.yml`, "Setup Flutter") and `pubspec.lock` is committed, so CI builds the tested dependency set. Release target SDK 36, min SDK 24. |
| State | `flutter_riverpod` 2.x: `StateNotifierProvider`, `FutureProvider(.autoDispose/.family)`, `StateProvider`, `Provider` | No `@riverpod` code generation is used. `riverpod_annotation` and `riverpod_generator` are declared but never imported. |
| Models | `freezed` + `json_serializable` (`*.freezed.dart`, `*.g.dart` are committed) | `FeedEvent` is a hand-written class (`feed/models/feed_event.dart`). |
| HTTP | `dio` 5: one shared instance, calls written by hand in `*_service.dart` | `retrofit` and `retrofit_generator` are declared but unused. Firebase verify, refresh and logout use `package:http` instead (`core/auth/firebase_auth_service.dart`). |
| Routing | `go_router` 14 | `core/routing/app_router.dart` |
| Auth | Firebase Auth + `google_sign_in` + `sign_in_with_apple` → backend JWT | §3 |
| Storage | `flutter_secure_storage` (tokens), `shared_preferences` (preferences, search history) | §11 |
| Images/fonts | `cached_network_image`, `google_fonts` (runtime fetching **on**: `allowRuntimeFetching` is never set) | Only *Jameel Noori Nastaleeq* is bundled (`pubspec.yaml` `fonts:`). |
| Unused deps | `hive`, `hive_flutter`, `connectivity_plus`, `retrofit`, `riverpod_annotation`, `pretty_dio_logger`, `permission_handler`, `intl` | No `package:` import of any of these appears in `lib/`. |

App IDs: Android `com.techhikes.poetry_app` (`android/app/build.gradle.kts:44`, `minSdk = 24` (Android 7.0, required by Play automatic protection)), iOS `com.techhikes.poetryapp` (`ios/Runner.xcodeproj/project.pbxproj:505`). Version is `1.0.0+4` in `pubspec.yaml`; CI overrides it (§13).

---

## 2. Layering and folder conventions

```
lib/
  main.dart                 Firebase init → initializeAppConfig() → SharedPreferences → ProviderScope
  core/
    auth/                   AuthNotifier (authProvider), AuthState, FirebaseAuthService
    config/app_config.dart  environment selection (§4)
    constants/              AppConstants: storage keys, timeouts, page size
    design_system/          colors, spacing, theme, typography (+ unused theme_provider/theme_config)
    error/app_error.dart    AppError hierarchy (UNUSED; see §6)
    network/                DioClient, AuthInterceptor, LoggingInterceptor, GuestService, ApiResponse DTO
    providers/              language_provider, user_provider (/api/auth/me)
    routing/app_router.dart GoRouter + auth redirect
    services/               language_service (+ unused deep_link_service)
    storage/                SecureStorageService, PreferencesService
    utils/                  language_typography, text_direction_helper, platform_utils (unused)
    widgets/                StandardAppBar, LocalizedText, sukhan/* decorative widgets
  features/
    <feature>/{models,providers,services,screens,widgets}
```

Conventions, as practised in the code:

- **Service** = a plain class holding `Dio` (or `DioClient`) and usually `Ref`, exposed through a `Provider<XService>`. It builds paths by hand and unwraps the `{success, message, data}` envelope (`core/network/dto/api_response.dart`).
- **Provider/Notifier** = a `StateNotifier` for screens with paging or mutations (`FeedNotifier`, `DiscoverNotifier`, `GlobalSearchNotifier`, `UnifiedBookmarksNotifier`), and a `FutureProvider.autoDispose.family` for read-only detail data (`poetDetailProvider`, `poemDetailProvider`, …).
- **Guest branching happens inside services.** They read `authProvider.isGuest` and route to `GuestService` or return empty data (§5).
- The poets, poem-detail, bookmarks, creator and profile code lives under `features/main/tabs/…` rather than in top-level features. That is historical; keep new code consistent with its neighbours.

---

## 3. App start and auth flow

1. `main()` (`main.dart:12-45`) initializes Firebase (failures are logged and swallowed, `:25-28`), calls `initializeAppConfig()`, awaits `SharedPreferences`, and overrides `preferencesServiceProvider` (`:40`).
2. `MyApp` watches `routerProvider`. `themeMode` is hard-coded to `ThemeMode.light` (`main.dart:59`).
3. `authProvider` (`core/auth/auth_provider.dart:24`) → `AuthNotifier._checkAuthStatus()` (`:42-78`):
   - If an access token **and** a refresh token are stored, it reads the access token's `exp` (`core/auth/jwt_expiry.dart`). A valid token restores the session with no network call. An expired one is refreshed first (`TokenRefresher`): refused → signed out with `sessionExpired: true` (login screen shows "Your session has expired"); unreachable → stays signed in.
   - If `user_id` is missing or looks like a UUID, it backfills it from `GET /api/auth/me` in the background (`:62-66, 81-100`).
4. Router redirect (`appRedirect` in `app_router.dart`). The `GoRouter` is built once; it receives auth changes through `refreshListenable` (`authRouteStateProvider` = `isAuthenticated` + `isRestoringSession`) and navigates to `/login` whenever the user goes from signed in to signed out.
   - While `isRestoringSession` is true (app start only), every route is held on `/` (the splash screen).
   - Once loading finishes, `/` redirects to `/main` if authenticated and to `/login` otherwise.
   - A guest who opens a path under `_authRequiredPrefixes` = `/main/become-poet`, `/main/creator`, `/bookmarks` (`:51-55`) is sent to `/login`.
   - An authenticated user who opens `/login` is sent to `/main`.
5. `LoginScreen` offers Apple sign-in, Google sign-in, and **"Continue as guest"** (`features/auth/login_screen.dart:365-374` → `context.go('/main')`).
6. Sign-in (`AuthNotifier.signInWithGoogle/Apple`, `:104-259`) goes through `FirebaseAuthService`:
   1. Get a Firebase ID token.
   2. `POST {baseApiUrl}/api/auth/firebase/verify` with `package:http`. `deviceType` is `deviceTypeFor(defaultTargetPlatform)`: `ios`, `android` or `web`.
   3. Save `accessToken`, `refreshToken`, email, `userId` and `firebase_token` to secure storage (`:146-160`).
   4. `_invalidateGuestSurfaces()` clears the discover cache and invalidates the feed, discover and poets providers (`auth_provider.dart:265-276`).
7. Logout (`:303-355`):
   1. `POST /api/auth/logout` with the refresh token (`firebase_auth_service.dart:687`).
   2. Sign out of Firebase and Google, and delete the secure-storage keys.
   3. `PreferencesService.clearUserData()` removes only account keys (bookmark search history, creator compose variant). Language, theme, onboarding and search history stay; account deletion also clears search history.
   4. Invalidate about 13 providers and reset `AuthState`.
8. Account deletion: `DELETE /api/users/me` with `{"confirmation":"DELETE"}` (`auth_provider.dart:367-448`), then the same cleanup as logout.

`AuthState.isGuest => !isAuthenticated && !isLoading` (`core/auth/auth_state.dart:24`).

Auth-related quirks visible in the code:
- `AuthState.copyWith` uses `errorMessage ?? this.errorMessage` (`auth_state.dart:40`), so `clearError()` (`auth_provider.dart:358-360`) cannot clear an error.
- A refused refresh anywhere (startup, `AuthInterceptor`, `AuthNotifier.refreshAccessToken()`) ends in `AuthNotifier.expireSession()`: local sign-out (no backend call), user providers invalidated, `sessionExpired: true`. A network failure never signs the user out.

---

## 4. Environments and build modes

`initializeAppConfig()` (`core/config/app_config.dart:103-113`):

| Build mode | Config | `baseApiUrl` | Logging interceptor |
|---|---|---|---|
| `kDebugMode` (`flutter run`) | `AppConfig.dev()` `:38-52` | `http://10.0.2.2:8081`, the Android-emulator alias for the host Mac's localhost | on |
| `kReleaseMode` | `AppConfig.prod()` `:71-86` | `https://api.prod.jahanesukhan.com` | off |
| profile | `AppConfig.stage()` `:55-68` | `https://stage-api.poetry.app` (placeholder; Web Client ID is `null`) | on |

Consequences:
- **A debug build cannot show production data.** Without a backend on the host's port 8081, every screen errors. "Could not load feed" in debug almost always means there is no local backend.
- There are no flavors or `--dart-define`. Pointing a debug build at another server means editing `app_config.dart`.
- `feedTTL`, `poemTTL` and `enableAnalytics` are defined in the config but are not read anywhere in `lib/`.
- `DioClient` and `FirebaseAuthService` still carry a bad-certificate bypass for the old prod IP `134.199.243.167` (`dio_client.dart:39-48`, `firebase_auth_service.dart:30-40`). It is inert while the domain URL is in use.

---

## 5. Networking

**One Dio** (`core/network/dio_client.dart:17-56`), exposed as `dioClientProvider` (`:138`):
- `baseUrl = appConfig.baseApiUrl`.
- Connect, receive and send timeouts are 30 s each (`app_constants.dart:34-36`).
- `Content-Type: application/json`.
- The response decoder is lenient UTF-8 (`allowMalformed: true`, `:32-33`), because some database rows contain stray bytes.
- Interceptors: `AuthInterceptor`, then `LoggingInterceptor` when `enableLogging` is set.
- **No retry and no offline detection.** `AppConstants.maxRetryAttempts` and `retryDelay` (`:44-45`) are never read.

**AuthInterceptor** (`core/network/interceptors/auth_interceptor.dart`):

| Step | Behaviour | Lines |
|---|---|---|
| Guest path `/api/guest/**` | Removes `Authorization` and `X-User-Id`; skips refresh on error | `:22, 40-44, 75-78` |
| Other requests | Adds `Authorization: Bearer <access_token>` if stored and `X-User-Id: <user_id>` if stored | `:47-63` |
| 401 on a request that carried a token | If another request already stored a newer token, retry with it. Otherwise one shared `TokenRefresher.refresh()` (`core/auth/token_refresher.dart`: own Dio without the auth interceptor, no bearer header, single flight) and one retry. A retried request that 401s again is passed on. | |
| Refresh refused (no/expired refresh token, 4xx, or the 500 the backend throws for unknown/revoked refresh tokens) | Calls `onSessionExpired` → `AuthNotifier.expireSession()`; the request fails with its 401 | |
| Refresh unreachable (offline, timeout, 502/503/504) | The request fails with the network error (screens show "offline"); the user stays signed in | |
| 401 on a request without a token (guest) | Passed on; no refresh, no sign-out | |
| Other errors | Logged, then passed on | `:167-171` |

Known consequences:
- Fixed (T-008): users with an expired session used to stay "authenticated" with every call failing ("Could not load feed" forever), and a 401 from `/api/auth/refresh` hung the original request (verified in a test against the old interceptor). See `test/core/network/auth_interceptor_test.dart`.
- The feed's error copy comes from `classifyRequestFailure` (`core/network/request_failure.dart`): offline, slow, server error or expired session.

**Guest surface.** `GuestService` (`core/network/guest_service.dart`) is GET-only. It clamps `page` to 0–`GuestService.maxPage` (4) and `size` to 1–`maxPageSize` (20), as the backend does. Because a request past page 4 returns page 4 again, `GuestPage.isLast` is true at page 4 (or the server's `last`/last page) even when `totalPages` is larger; the poets list (`PoetsPaginationNotifier`) also skips poets it already shows and stops when a page adds nobody new; it also drops any response requested before the list last started over (new filter, first load, refresh), so a page of the previous filter can't land in the new one, and switching filter while the first page is loading is no longer ignored (`poets_pagination_filter_race_test.dart`) (T-122; it used to re-fetch page 4 and list it twice). Tests: `test/core/network/guest_page_test.dart`, `test/features/main/tabs/poets/providers/poets_pagination_guest_test.dart`. The backend rate limit is 60 requests/min per IP: a 429 becomes `GuestRateLimitException(retryAfter)` (`:219-233`).

| Guest endpoint | Used by |
|---|---|
| `/api/guest/discover` | Discover, **and the guest Feed** |
| `/api/guest/poems`, `/poems/{id}`, `/poems/search` | `PoetService.getPoemsByPoet/getPoemById`, `SearchService.searchUnified` |
| `/api/guest/poets`, `/poets/{id}`, `/poets/search` | `PoetService` list methods without a guest filter, profile, search; the fallback for the filters below |
| `/api/guest/poets/featured`, `/trending`, `/era/{era}`, `/gender/{gender}` | `PoetService.getFeaturedPoets / getTrendingPoets / getPoetsByEra / getPoetsByGender` via `GuestService.getFilteredPoets` (contract: `docs/contracts/guest-poets.md`, backend `fix/search-2`, **not deployed yet**) |
| `/api/guest/couplets/trending` | `GuestService.getTrendingCouplets` |

Services that branch on `isGuest`: `FeedService`, `DiscoverService`, `SearchService`, `PoetService`, `UnifiedBookmarksNotifier`, `PoetsDiscoveryNotifier`, `reaction_providers.dart:26`. Services with **no guest branch**, which therefore call authenticated endpoints for guests:
- `PoetService.getPoetGallery/Books/Videos/Facts` (`poet_service.dart:522-640`). The poet-detail **Gallery, Books and Videos** tabs would return 401 for guests, so those tabs show guests a sign-in prompt and never call them (`poets/widgets/poet_sign_in_prompt.dart`).
- `HashtagService` (all of `/api/hashtags/**`). Whether the backend allows anonymous access to these is **UNVERIFIED**.
- The image-poetry services and the like and bookmark services. Writes are gated in the UI by `ensureSignedIn()` (`features/auth/widgets/ensure_signed_in.dart`).

In guest mode, featured, trending, era and gender call the guest filter endpoints (T-045). This app version ships before those endpoints are deployed, so `GuestService.getFilteredPoets` falls back to the plain `/api/guest/poets` list when the backend answers **404, 401 or 405** (today's backend sends 404 "Poet not found" for `/featured` and `/trending`, which match `/poets/{publicId}`), and remembers that per filter family (`featured`, `trending`, `era`, `gender`) for the life of the service, so each costs one wasted request at most. Other errors (5xx, offline, 429) are thrown as before. Tag, top-by-views and top-by-poem-count still use the plain list and ignore their filter. The Poets tab still hides the era/gender sections for guests (`poets_discovery_provider.dart`): while the backend lacks the endpoints the fallback would show an unfiltered list under a "Classical" heading. Tests: `test/features/main/tabs/poets/services/poet_service_guest_filters_test.dart`.

---

**API contract.** Production (backend `main`) sends a null `String` as `"-"`, a null `Integer`/`Long` as `0` and every
other null (`Boolean`, enum, list, date) as JSON `null`; hand-built maps (e.g. `/api/auth/me`) send raw nulls. Optional
text in models uses `@PlaceholderStringConverter()`; flags and enum-strings get defaults. Field-by-field audit and what
is still open: `docs/contracts/production-contract-audit.md` (T-181).

---

## 6. Error model

- `core/error/app_error.dart` defines `AppError` → `NetworkError`, `AuthError`, `ValidationError`, `CacheError`, `GenericError`, plus `errorFromStatusCode()`. **Nothing imports this file.**
- In practice, services `throw Exception(apiResponse.message)` or rethrow `DioException`. Notifiers store `e.toString()` as the error (e.g. `feed_provider.dart:149-154`). Screens show generic copy, with no offline / timeout / server distinction.
- One special case: `FeedNotifier.loadNextPage` restarts the session when the error string contains `"Invalid or expired feed cursor"` (`feed_provider.dart:183-188`).

---

## 7. Routing

All routes are in `core/routing/app_router.dart`. `debugLogDiagnostics: true`.

| Path | Name | Screen | Guard / notes |
|---|---|---|---|
| `/` | — | `SplashScreen` | held here while auth loads |
| `/login` | — | `LoginScreen` | authenticated users → `/main` |
| `/main` | — | `MainScreen` (5 tabs) | |
| `/main/poets/:publicId` | `poet-detail` | `PoetDetailScreen` | |
| `/main/poems/:publicId` | `poem-detail` | `PoemDetailScreen` | optional `?couplet=<coupletNumber>` opens the poem at that couplet (§9.7); build links with `ContentLocations.poem` (`core/routing/content_locations.dart`) |
| `/main/poets-search` | — | `PoetsSearchScreen` | from the Poets tab |
| `/main/become-poet` (`/new`, `/claim`, `/claim/:publicId`) | `become-poet*` | creator onboarding | **auth required** |
| `/main/creator` (`/compose`, `/poems/:publicId/edit`, `/profile/edit`, `/translations/:lang`, `/books/new`, `/facts`, `/images/:id`) | `creator-*` | creator mode | **auth required**. `/images/:id` needs `extra: CreatorImage`, otherwise it shows "Image not available" (`:200-214`). |
| `/search` | `global-search` | `AppSearchScreen(initialQuery: extra['query'])` | |
| `/search/results/:category` | `category-results` | `CategoryResultsScreen` | **orphaned**: nothing navigates to it |
| `/hashtags/:slug` | `hashtag-detail` | `HashtagDetailScreen` | from `HashtagPill` (`hashtag_pill.dart:35`) and couplet theme chips (`ContentLocations.hashtag`, slug percent-encoded) |
| `/bookmarks/search`, `/bookmarks/couplets` | | bookmark search / couplets | **auth required**; no in-app caller found |
| `/image-poetry/templates`, `/generate/:coupletId`, `/image/:imageId`, `/:contentId` | | image poetry | §9.8 |
| `/image-poetry/saved`, `/image-poetry/couplet/:coupletId/gallery` | | | no in-app caller found |
| `/poetry-editor` | `poetry-editor` | `PoetryEditorScreen` | only caller is dead `feed_tab.dart:56` |

Navigation is mostly `context.push('/main/poems/$id')` with string paths. `pushNamed('poet-detail' | 'poem-detail')` is used in search. `Navigator.push(MaterialPageRoute)` appears in 4 files (generated-image gallery, creator dashboard, poet gallery tab, profile tab).

---

## 8. State-management conventions

- Language: `selectedLanguageProvider` (`core/providers/language_provider.dart:91`) is a `Provider<String>` derived from `selectedLanguageNotifierProvider`, which is persisted in prefs (default `'ur'`). `feedProvider` and `discoverProvider` **watch** it, so changing the language rebuilds those notifiers and refetches.
- Providers select only the auth fields they need (`isGuest` / `isAuthenticated`), so a token refresh re-runs nothing. The login screen, sign-in sheet and profile tab still watch `authProvider` whole for `isLoading`/`errorMessage`.
- Optimistic feed engagement: `feedEngagementProvider` (`feed/providers/feed_engagement_provider.dart:59`) is a `StateProvider<Map<itemKey, overlay>>` laid over server counts. It is cleared on feed reload.
- `imageCollectionServiceProvider` is defined twice: in `image_poetry/providers/image_collection_providers.dart` and in `image_bookmark_providers.dart`.

---

## 9. Features

### 9.1 Shell: `features/main/main_screen.dart`
An `IndexedStack` (`:75-78`) holds Feed, Discover, Bookmarks (`AppBookmarksScreen`), Poets (`PoetsTab` → `PoetsListScreen`) and Profile (`ProfileTab`). All five are built when `/main` is entered, so each fires its initial API calls immediately: feed, discover, bookmarks plus stats, poets discovery, and profile/owned-poet/languages/app-content. Re-tapping Feed scrolls it to the top (`:82-84`).

### 9.2 Feed: `features/feed/`
- `FeedNotifier` (`providers/feed_provider.dart:53-292`) does cursor pagination over `GET /api/feed?lang&limit=20&cursor&refresh` (`services/feed_service.dart:22-60`).
  - It de-duplicates by `TYPE:publicId` within a session (`:199-208`).
  - If the first page is empty but has a cursor, it automatically fetches the next page once (`:104-140`).
  - `smartRefresh()` prepends new items using `refresh=true` (`:215-246`).
  - `hideItem()` removes the item locally and emits a `hide` event (`:249-256`).
- Card types: `FeedContentData.fromJson` (`models/feed_content_data.dart:9-17`) maps `COUPLET`, `POEM`, `POET_SPOTLIGHT` and `POET_IMAGE` to typed models, and anything else to `UnknownContentData`. `FeedItemBuilder` renders nothing for unknown types (`widgets/feed_item_builder.dart:25, 95`).
- **Guest feed:** `FeedService.getFeed` returns `FeedResponse.fromGuestBundle(/api/guest/discover)` (`feed_service.dart:28-32`, `models/feed_response.dart:55-79`). The order is couplets from `recommended`, then poems from `editorsPicks`, then poet spotlights. It is a single page (`hasMore: false`) with `sessionId: 'guest'`. `ContentCard.excerpt` carries the guest API's `excerpt` (`"-"` reads as null via `PlaceholderStringConverter`, `core/utils/api_placeholder.dart`), so guest poem cards show the opening lines like signed-in cards; the title is never substituted for a missing excerpt.
- **Poet links on feed cards:** the avatar and poet name open `/main/poets/:publicId` through one rule, `FeedPoetAvatar.profileTap`, and are not tappable when the id is absent or `"-"` (a tap on the name then reaches the card itself). Signed-in items carry the id as `contentData.poetPublicId`; the guest API sends the same field name, `poetPublicId`, on `featuredPoems` and `trendingCouplets`, and `GuestService` → `ContentCard.poetPublicId` → `FeedResponse.fromGuestBundle` now keep it (it used to be dropped, so guest avatars and names did nothing). Tests: `test/features/feed/widgets/guest_feed_poet_tap_test.dart`.
- **Couplet cards open their poem:** a tap on the card or its "Open poem" / مزید پڑھیے link opens `/main/poems/:poemPublicId` (never the couplet id), with `?couplet=<coupletNumber>` when the item carries `coupletNumber` (guest couplets do, from `GuestCoupletDto`; the signed-in feed's `contentData` does not send it yet, so those links are unchanged). Guest couplets carry `poemPublicId` from `GuestCoupletDto` through `ContentCard.poemPublicId` (it used to be dropped, so guest couplet cards opened nothing). With no poem id (absent or `"-"`) the card has no tap handler and no link — before, a signed-in `"-"` pushed `/main/poems/-`. Tests: `test/features/feed/widgets/guest_feed_couplet_poem_tap_test.dart`.

### 9.3 Engagement events (feed only): `feed/services/feed_event_tracker.dart`
| Event `t` | Emitted when | Where |
|---|---|---|
| `impression` | an item becomes visible, once per item per session | `:19-37` (via `VisibilityDetector` in the feed screen) |
| `dwell_ms` (`v` = ms) / `skip_fast` | the item leaves the viewport after ≥500 ms / <500 ms | `:41-69` |
| `open_item`, `react`, `bookmark`, `share` | card actions | `couplet_feed_card.dart:377-492`, `poem_feed_card.dart`, `poet_image_feed_card.dart`, `poet_spotlight_feed_card.dart` |
| `hide` | "hide" menu | `feed_provider.dart:250` |

Payload: `{eid (uuid v4), t, itemKey "TYPE:publicId", sid, ts (sec), v?, sourceId?}` (`models/feed_event.dart:22-30`).

Flushing:
- Batches go to `POST /api/events/batch` (`feed_service.dart:65-77`).
- The tracker flushes before each page load (`feed_provider.dart:85, 166, 222`), on dispose (`:288-291`), and on `AppLifecycleState.paused` (`feed_screen.dart:40-42`).
- The buffer is cleared **before** sending, and send errors are swallowed (`feed_event_tracker.dart:85-90`, `feed_service.dart:73-76`). **A failed batch is lost.**
- Guests send nothing (`feed_service.dart:67`).
- Nothing is tracked outside the feed. Server-side counters (views, search analytics) come from ordinary API calls.

### 9.4 Discover: `features/discover/`
- `DiscoverNotifier` (`providers/discover_provider.dart:47+`) loads search history and `DiscoverService.getDiscoverBundle` in parallel.
- `DiscoverService` (`services/discover_service.dart`):
  - In-memory cache for **15 min** (`:30`), keyed by `(lang, isGuest)` (`:43-48`).
  - Authenticated users call `GET /api/discover?lang`; guests call `/api/guest/discover`.
  - On a `DioException` it returns the **stale** cache if the bucket matches (`:89-100`).
  - The cache is cleared on sign-in (`auth_provider.dart:267`) but not on logout; the `isGuest` key covers that case.
- Bundle sections: `trendingSearches`, `editorsPicks`, `recommended`, `featuredPoets`, `categories`, `trendingHashtags` (`models/discover_bundle_model.dart:11-17`). Section "see all" is a TODO no-op.
- **Rail taps** go through `utils/discover_navigation.dart` (`openDiscoverCard`): POET → `/main/poets/:id`, POEM → `/main/poems/:id`, COUPLET/VERSE → their **poem** (`card.poemPublicId`, plus `?couplet=` when the card has `coupletNumber`; nothing without a poem id — it used to push the couplet id), CATEGORY/TAG → `/search` with origin `browse`. Tests: `test/features/discover/utils/discover_navigation_test.dart`.
- **Trending-search chips** (T-180): the backend sends them by count, descending (ES `terms` aggregation; production 2026-10-20: Ghazal 85, Nazam 74, Naat 57, Rubai 37). The chips show **just the query** — no rank badge and no top-3 arrow (owner decision, 2026-10-20; the search screen's idle list never had one). `byCountDescending` (`utils/trending_order.dart`) re-sorts by `searchCount` (stable) for the chips and the search screen's idle list, in case the server order changes. A chip opens `/search` with origin `trending`.

### 9.5 Search: `features/search/`
- **Screen:** `AppSearchScreen` (`/search`, `screens/app_search_screen.dart`) switches between four modes: idle (`AppSearchIdleContent`), suggestions (`AppSearchSuggestions`), preview "All" results (`AppSearchPreviewResults`) and filtered tab results (`AppSearchFilteredResults`). Tabs: سب (All) · شعراء · غزلیں · اشعار (couplets) · مصرعے (verse lines) · زمرے.
- **State:** `globalSearchProvider` / `GlobalSearchNotifier` (`providers/global_search_provider.dart:669`) has a 300 ms debounce (`:222`) and an in-memory result cache.
- **Endpoints:** `/api/search`, `/api/search/couplets`, `/autocomplete`, `/recommendations`, `/related`, `/trending` (`services/search_service.dart:20`).
- **Guest behaviour:**
  - `searchUnified` calls only what the type needs: `all` → `/api/guest/poems/search` and `/api/guest/poets/search` in parallel; `poems_only` / `poets_only` → that one; any other type (`couplets_only`, `verses_only`, `categories_only`, `tags_only`) → empty, **no request** (it used to call both, against the 60/min guest limit). Couplets, verses, tags and categories are always empty for guests. Tests: `test/features/search/services/search_service_guest_test.dart`.
  - Autocomplete (`/api/search/autocomplete`) is called for guests too: `/api/search/**` is `permitAll` on the backend (main and develop). It used to return empty for guests, so they never saw live suggestions (T-182). Queries under 2 characters make no request.
  - Related searches return empty for guests (`:410`).
- **Autocomplete** (T-182): 300 ms debounce in `onQueryChanged`; the query is trimmed and Urdu-normalised (Roman passes through). A failure (network, 5xx, parse, `success:false`) is logged and leaves only the "Search for …" row; a failure for a query the user has typed past is ignored. Suggestion models read `"-"` as absent; rows without a label are not rendered. Tests: `test/features/search/screens/app_search_live_suggestions_test.dart`, `providers/global_search_autocomplete_test.dart`, `services/search_service_autocomplete_test.dart` (fixture `autocomplete_dil_main.json`, the backend `AutocompleteSuggestions` shape).
- **Search origin** (T-183, client half): every `/api/search` request carries `origin` (`models/search_origin.dart`): `typed` (keyboard submit, the "Search for …" row), `suggestion` (an autocomplete row that runs a text search), `history` (a recent search), `trending` (a trending chip), `browse` (category chips and results, related searches, Discover CATEGORY/TAG cards, and any `/search` route query without an origin). `/search` takes `extra: SearchRouteExtra.of(query, origin)`. Load-more pages, the error-screen retry and a tab switch that has to re-search reuse the origin of the search they belong to. Production's `SearchController` ignores the parameter. Guest search uses `/api/guest/*/search` and sends no origin. Tests: `test/features/search/screens/app_search_origin_test.dart`, `providers/global_search_origin_test.dart`.
- **"All" header** (T-179): shows `totalAcrossTabs` — the sum of the per-tab totals (`totalPoets + totalPoems + totalCouplets + totalVerses + totalCategories`), so it agrees with the tab labels. The backend's `totalResults` is the number of items on the current page (≤ 10 per type), e.g. 23 for "afsoos" while غزلیں showed 693. Tests: `test/features/search/screens/app_search_results_header_test.dart`.
- **Taps** (one helper, `utils/search_result_navigation.dart`; route names in `AppRoutes`):
  - Poet → `/main/poets/:publicId`; poem → `/main/poems/:publicId` — in "All", every tab and autocomplete.
  - Couplet → its parent poem, `/main/poems/:poemPublicId?couplet=<coupletNumber>` (`coupletNumberToOpen`; no parameter when the number is 0), from `CoupletSearchResult.poemIdToOpen` (the flat `poemPublicId` field, else the legacy nested `poem.publicId`). The backend is adding `poemPublicId`/`poemTitle`/`poetPublicId`/`poetName` (additive, nullable); until it ships, couplet results carry neither, so they render **without** a chevron or tap handler rather than as dead buttons.
  - Verse (a single matching line) → its parent poem, `/main/poems/:poemPublicId?couplet=<verse.coupletNumber>` (`VerseSearchResult.poemIdToOpen` / `coupletNumberToOpen`); not tappable without a poem id.
  - Tag → `/hashtags/:slug` (search tags are the `Tag` rows whose slugs are the hashtag slugs); a tag with a missing/`"-"` slug is not tappable.
  - Category → searches its name in "All" (there is no category screen; same as the Discover category grid).
  - Preview and filtered result widgets take **required** tap callbacks, so a result type cannot be added without one. Tests: `test/features/search/screens/`.
- **Tabs and paging:** the first `type=all` page carries every tab's first page, so `setActiveSegment` only switches tab and makes **no request** for a query whose results are loaded (each `/api/search` call is a `search_queries` row that feeds trending). It searches again only when nothing is loaded for the current query (e.g. the search failed). `loadMore` fetches the active tab's next page (`poems_only`, `couplets_only`, …) and merges it, so loaded pages survive tab switches. Every page uses one size, `GlobalSearchNotifier.pageSize` (10): the backend pages each type with `PageRequest.of(page, size)`, and page 1 used to ask for 20, skipping results 10–19. A search or page that returns after a newer search started is dropped. Tests: `test/features/search/providers/global_search_tab_switch_test.dart`.
- **Sort and poet filter:** `/api/search` accepts no sort or poet parameter (backend `SearchController`: `q`, `type`, `lang`, `script`, `page`, `size`), so `setSortBy`, `setPoetFilter` and `setCoupletSort` only record the choice and make **no request** (they used to re-run the search for identical results and another logged search). Nothing in the live UI reads them; their only caller, `CoupletSortDropdown`, is reachable only from the dead `search_tab.dart`. A real couplet sort would use `/api/search/couplets` (`sort` = relevance/likes/shares/bookmarks/trending/recent, `poet`), which the backend does not log as a search.
- **Highlighting:** `HighlightedText` (`utils/highlighted_text.dart`) highlights matches on the client after Urdu normalization, using `AppSearchUrduNormalizer.normalizeWithOffsets` to map normalized matches back to source characters (the old per-character mapping drifted one character left per preceding space). Diacritics inside or right after a matched word stay in the highlighted span.
- **Verse hits** (`UnifiedSearchResponse.verses`, single matching lines with `poemPublicId` and, from the backend's T-073 change, poet id/name/image): `AppSearchVerseCard` (`widgets/app_search_verse_card.dart`) shows the line in its script (Nastaliq RTL for Urdu, via `LanguageTypography.languageCodeForScript`) and its Roman transliteration, both highlighted, so a Roman query such as `jigar` highlights the Roman line. "All" shows up to 3 under **مصرعے / Lines**; the **مصرعے** tab (`DiscoverSegment.misras`, paged with `type=verses_only`, count `totalVerses`) lists them all. **اشعار** (`DiscoverSegment.verses`) stays the couplet list (`couplets_only`). A tap opens the parent poem (`VerseSearchResult.poemIdToOpen`, never the verse id); with no poem id (`null`/`"-"`) the card has no chevron and no tap handler. All parent fields are nullable and read `"-"` as absent, so one incomplete verse cannot fail the whole response. Per-tab type, counts, `hasMore` and page merging (de-duplicated by id; a page that adds nothing ends paging) live in one place, `utils/search_segment_results.dart`. Tests: `test/features/search/screens/app_search_verse_results_test.dart`, `models/verse_search_result_test.dart`, `utils/search_segment_results_test.dart`.
- **Related screens:**
  - `PoetsSearchScreen` (`/main/poets-search`) uses `poetSearchPaginationProvider`. `SearchResultsGrid` (a sliver) listens to the enclosing `CustomScrollView`'s position and calls `loadMore()` within 600 px of the end; the notifier de-duplicates poets across pages, stops when a page adds nothing new, and drops a page that was in flight when a new search started.
  - `CategoryResultsScreen` is orphaned (§7). `widgets/autocomplete_suggestions.dart` is used only by the dead `main/tabs/search_tab.dart`.

### 9.6 Poets and poet detail: `features/main/tabs/poets/`
- **Poets tab:** `PoetsListScreen` reads `poetsDiscoveryProvider` (classical, modern and women rails; guests get a reduced set, `poets_discovery_provider.dart:66-92`) and `poetsPaginationProvider`.
- **Service:** `PoetService` (`services/poet_service.dart`) covers `/api/poets`, `/featured`, `/trending`, `/gender/:g`, `/era/:e`, `/tags/:slug`, `/search`, `/top/by-poems`, `/top/by-views`, `/:id/profile`, `/:id/gallery|books|videos|facts`, `/:id/follow` (POST/DELETE), `/:id/is-following`, `/api/users/me/following`, `/api/poems/poet/:id` and `/api/poems/:id`.
- **Detail:** `PoetDetailScreen` (`/main/poets/:publicId`) has the tabs Overview, Gallery, Books, Videos and Poetry (`poet_detail_screen.dart:109-113, 696-700`).

| Tab | Provider |
|---|---|
| Header | `poetDetailProvider` (guest → `/api/guest/poets/:id`) |
| Gallery | `poetGalleryProvider` |
| Books | `poetBooksProvider` |
| Videos | `poetVideosProvider` |
| Poetry | `poetPoemsProvider` + `poemPagesProvider` |

  Gallery, Books and Videos have no guest endpoint; for guests each tab shows `PoetSignInPrompt` (`GuestLockedTab`) instead of building its provider. `ownedPoetProvider` also shows a claim affordance (`:313`).
- **Follow:** `FollowButton` uses the follow providers and is gated with `ensureSignedIn`.

### 9.7 Poem detail: `features/main/tabs/poets/screens/poem_detail_screen.dart`
- `poemDetailProvider(publicId)` → `PoetService.getPoemById` (guests use `/api/guest/poems/:id`).
- Reactions: `reactionTypesProvider` (`GET /api/reactions/types`) and `reactionActionProvider` (`POST /api/{type}/{id}/react`). The DTOs send `userReaction: "-"` when the user has not reacted; readers use `userReactionIn(reactions)` (`engagement/models/reaction_models.dart`), which treats `"-"` as no reaction (every poem used to look reacted). Bookmarks: `bookmarkActionProvider` (`/api/poems/:id/bookmark`). Both writes are gated by `ensureSignedIn`.
- Links to the poet (`:243`) and to a claim flow (`:146`).
- Couplet rows (`PoemReadingCard`, `CoupletEngagementButtons`) open `ShareOptionsSheet` → "Share as Image" (§9.8).
- **Open at a couplet:** the route reads `?couplet=<coupletNumber>` (`ContentLocations.coupletFrom`: positive whole numbers only) into `PoemDetailScreen.initialCoupletNumber`. When the poem's couplets first arrive, `CoupletDeepLink.targetIndex` (`utils/couplet_deep_link.dart`) finds the couplet **by number** (not position); the screen selects it with the existing `_selectedSherIndex` highlight (tinted block + action tray) and, after that frame, `Scrollable.ensureVisible` brings it a quarter of the way down the screen (350 ms). It runs once; the reader can deselect it. No parameter, `0`/junk, or a number the poem does not have → the poem opens at the top, as before. Couplet numbers are the same in every script, so one link works in Urdu, Roman and Devanagari. Tests: `test/features/main/tabs/poets/screens/poem_detail_deep_link_test.dart`, `utils/couplet_deep_link_test.dart`, `test/core/routing/content_locations_test.dart`.
- **Known gap:** `PoemReadingCard` shows its loading spinner whenever `couplets` is null, and the screen passes null for an **empty** couplet list, so a poem whose response has no couplets (e.g. the guest endpoint's couplet load failed) spins forever instead of showing `fullText` (reproduced in a widget test, 2026-10-20; not fixed here).

### 9.8 Image poetry: `features/image_poetry/`
- **Entry:** `ShareOptionsSheet` → `/image-poetry/generate/:coupletId` (`widgets/share_options_sheet.dart:83`). From there, `/image-poetry/templates` picks a template.
- **Endpoints:**
  - Server-side generation: `POST /api/couplets/:id/generate-image`, `GET /api/couplets/:id/images`, `POST /api/users/me/upload-background`.
  - Templates: `/api/image-templates`, `/popular`, `/:id`.
  - Collection and bookmarks: `/api/poetry-images/:id/{like,bookmark,save,share,status,is-bookmarked,toggle-favorite}`, `/api/users/me/{saved-images,image-bookmarks,collection-names,collection-stats}`.
- **Client-side canvas editor:** `editor/` (`PoetryEditorScreen`, `poetryCanvasProvider`, exports through `gal`). It is effectively unreachable (§7).
- **Bookmark navigation:** bookmarked images open `/image-poetry/:contentId` (`app_bookmarks_screen.dart:171`).

### 9.9 Hashtags: `features/hashtags/`
- `HashtagDetailScreen` (`/hashtags/:slug`) has the tabs Couplets, Poems, Images and Poets (`screens/hashtag_detail_screen.dart:146-149`).
- `HashtagService` calls `/api/hashtags/trending`, `/:slug` and `/:slug/{poems,couplets,images,poets}`.
- **Initial tab** (T-178): the screen opens on the first tab, in display order, whose metadata count is > 0 (`utils/hashtag_tabs.dart`), before any tab page is built, so an empty اشعار tab is never loaded; with every count 0 it stays on اشعار.
- **Couplets tab** (T-177): `/:slug/couplets` returns the plain `CoupletDto`. On production (`main`) it has no `poemPublicId`/`poetPublicId`/`poetName` and `coupletType` can be null; `CoupletDetailResponse` used to require them, so the whole tab failed ("لوڈ نہیں ہو سکا"). All context fields are optional now (`"-"` = absent). `HashtagCoupletTile` opens `/main/poems/:poemPublicId` only when there is a poem id (no tap handler or chevron otherwise) and hides an absent poet/title; couplets with no line text are skipped. Backend `develop` (T-012) adds the four fields. Tests: `test/features/hashtags/`.
- **Theme tags:** metadata may carry `nameUr`/`nameEn`/`nameHi` and `definition` (production sends none yet; `parent` is ignored). The app bar then shows `#<name>` in the app language (fallback Urdu, then English; `HashtagDto.localizedName`), styled for the name's script (`LanguageTypography.labelStyleFor`), and the definition sits under the app bar in its own script's direction. Without them the title is `name`, else the slug, as before (a `"-"` name now falls back to the slug instead of showing `#-`). Couplet tiles show the couplet's theme chips except the page's own; a tile with a couplet number opens its poem at the couplet. Tests: `screens/hashtag_detail_theme_meta_test.dart`, `widgets/hashtag_couplet_themes_test.dart`.
- Image tiles use `hashtagImageUrl`: the thumbnail, else the image URL (`"-"` thumbnails fell through to nothing).
- `HashtagPill`, `HashtagDetailScreen` and `PoetOverviewTab` parse API colours with `parseHexColor` (`core/utils/color_parser.dart`): `#RGB`, `#RRGGBB`, `#AARRGGBB`; `null`, `"-"` and junk fall back.

### 9.9a Couplet themes (app half)
- **Contract:** couplet objects may carry `themes: [{slug, nameUr, nameEn, nameHi, confidence}]`, at most 3, already filtered and ranked by the server. Production sends no `themes` anywhere yet, so the app must and does look exactly as before against it.
- **Parsing:** one tolerant reader, `parseCoupletThemes` / `@CoupletThemesConverter()` (`features/hashtags/models/couplet_theme.dart`): a non-list is no themes; entries that are not objects or lack a slug (absent, blank, `"-"`) are dropped; a repeated slug keeps its first entry; names read `"-"` as absent. It is on every model that parses a couplet: `CoupletModel` (poem detail couplets), `CoupletDetailResponse` (hashtag couplets, couplet detail), `BookmarkedCoupletResponse`, `CoupletSearchResult`, `VerseSearchResult`, `CoupletContentData` (feed) and `ContentCard` (Discover/guest couplets; `GuestService` passes `themes` and `coupletNumber` through to the guest feed). `UnifiedBookmark` (the Bookmarks tab DTO) is not a couplet DTO and does not read themes.
- **Chips:** `CoupletThemeChips` (`features/hashtags/widgets/couplet_theme_chips.dart`) shows up to `kMaxCoupletThemes` (3) `#name` chips in the app language (`selectedLanguageProvider`; fallback Urdu, then English; a theme with no name is hidden — the slug never shows), each in its name's script (Nastaliq RTL for Urdu, Noto Sans Devanagari for Hindi), laid out in the app language's direction, with a screen-reader label ("Theme: Separation" / "موضوع: ہجر" / "विषय: हिज्र") and a tap action. A tap pushes `/hashtags/:slug`. Nothing is rendered without themes. Placed on the feed couplet card, search couplet and verse cards, hashtag couplet tiles (minus the page's own theme) and poem-detail couplets. Tests: `test/features/hashtags/widgets/couplet_theme_chips_test.dart` plus one per placement.
- `GET /api/themes` (taxonomy tree) is not used yet.

### 9.10 Bookmarks tab: `features/main/tabs/bookmarks/screens/app_bookmarks_screen.dart`
- `unifiedBookmarksProvider(BookmarkFilters)` + `bookmarkStatsProvider` → `UnifiedBookmarkService`: `/api/bookmarks/{recent,poems,couplets,images,search,stats}`, `DELETE /api/bookmarks/{type}/{id}`, `/api/bookmarks/{type}/{id}/notes`.
- Guests get empty data and no API call (`unified_bookmark_provider.dart:55-60`). The tab does **not** show `GuestLockedTab`; that was only in the dead `bookmarks_tab.dart`.
- An older bookmark stack also exists (`engagement/services/bookmark_service.dart` → `/api/users/me/bookmarks…`; `couplet_service.dart` → `/api/users/me/couplets/bookmarked…`). It powers `bookmarkActionProvider` and the bookmark-search and couplets screens.

### 9.11 Creator ("Poet Mode"): `features/main/tabs/creator/`
- **Flag:** `kPoetModeEnabled = true` (`widgets/become_poet_card.dart:14`).
- **Owned poet:** `ownedPoetProvider` (`providers/creator_providers.dart:22-32`) returns `null` without auth or on 404, otherwise `GET /api/me/poet-profile`.
- **Onboarding:** `/main/become-poet` → new profile (`POST /api/me/poet-profile`) or claim an existing poet (`POST /api/poets/:id/claim`).
- **Profile tab:** shows `CreatorDashboardScreen` in place of the profile when the claim is `verified` (`profile_tab.dart:84-88`). Pending or rejected claims show `ClaimStatusBanner`.
- **Dashboard:** tabs My Poems, Gallery, Books and Stats. `CreatorService` (`services/creator_service.dart:23-25`) calls `/api/me/poet/{poems,images,images/upload,books,books/:id/upload-{kind},facts,translations,translations/:lang,analytics}`.
- **Compose:** the last-used variant is kept in prefs (§11).

### 9.12 Profile: `features/main/tabs/profile_tab.dart`
- Guests see `GuestLockedTab` (`:68-75`).
- `/api/auth/me` is a hand-built map, so `fullName`, `username`, `provider` and `isActive` can be JSON null; `UserModel` treats them as optional (`displayName` falls back to the email's local part, `handle` is null without a username). A null name used to put the header in its error state.
- Authenticated users see: `userProfileProvider` (`GET /api/auth/me`, `core/providers/user_provider.dart`), language picker (`GET /api/languages`, update via `/api/profile`, `core/services/language_service.dart:9-10`), app content pages (`GET /api/app-content`, `/:key`), logout, and delete account.

---

## 10. Urdu, RTL and typography

- **Fonts:**
  - The bundled family is declared as `'Jameel Noori Nastaleeq'` (with spaces) in `pubspec.yaml`, and about 114 call sites use that exact string.
  - `LanguageTypography.createStyle` uses `AppTypography.urduFontFamily` (fixed 2026-10-19; it previously used `'JameelNooriNastaleeq'`, which matched no declared family). About 113 other call sites still repeat the literal `'Jameel Noori Nastaleeq'` instead of the constant.
  - Everything else comes from `google_fonts` at runtime: Roboto (UI, `design_system/app_typography.dart`), `notoNastaliqUrdu`, `notoSansDevanagari`, `fraunces`, `inter`, `jetBrainsMono`. These need network access on first use.
- **Direction helpers disagree:**
  - `LanguageTypography.getTextDirection` treats `ur`, `ar`, `fa` and `ps` as RTL (`language_typography.dart:59-69`).
  - `TextDirectionHelper.isRTL` treats only `ur` as RTL (`core/utils/text_direction_helper.dart:30, 36-38`). Its only importer is the dead `unified_bookmarks_screen.dart`.
  - Most widgets hard-code `TextDirection.rtl` directly (about 165 occurrences) or use the API's `direction` field.
  - The tests in `test/core/utils/` document the disagreement.
- **Size and line height:** Urdu, Arabic and Persian use a 1.18× size and 1.75 line height; Hindi 1.06× and 1.5; English 1.0× and 1.4 (`language_typography.dart:7-18`).
- **Short labels in their own script:** `LanguageTypography.labelStyleFor(languageCode)` gives Nastaliq for Urdu, **Noto Sans Devanagari** for Hindi (`createStyle` uses Roboto for Hindi, which has no Devanagari glyphs) and Roboto otherwise. Used by theme chips and theme names on the hashtag page.
- **Script detection:** one definition, `LanguageTypography` (`core/utils/language_typography.dart`): `containsArabicScript` (any letter in U+0600–U+06FF), `isMostlyArabicScript` (more than a third of the text), and `languageCodeForScript` (`ur` / `hi` / `en`) for content without a language field. Search widgets used to carry 14 private `_isUrduText` copies in those two flavours; they now call these, with identical results (`test/core/utils/language_typography_test.dart`).
- **Search normalization:** `AppSearchUrduNormalizer` (`search/utils/app_search_urdu_normalizer.dart:43-64`) strips diacritics and tatweel, maps Arabic letter variants to Urdu, collapses whitespace, and trims.
- **Theme:** light only (`main.dart:59`). `themeNotifierProvider`/`themeProvider` and the `theme_preference` key are never read by the app.

---

## 11. Local storage keys

| Store | Key | Written by | Notes |
|---|---|---|---|
| Secure (`encryptedSharedPreferences` on Android, `secure_storage.dart:94-98`) | `access_token`, `refresh_token` | sign-in, refresh | presence alone means "logged in" at startup |
| Secure | `user_id` | sign-in, `/api/auth/me` backfill | sent as `X-User-Id` |
| Secure | `user_email` | sign-in | |
| Secure | `firebase_token` | sign-in (`firebase_auth_service.dart:25`) | |
| SharedPreferences | `language_preference` | language picker | default `'ur'` |
| SharedPreferences | `theme_preference`, `onboarding_completed` | — | defined in `AppConstants`, effectively unused |
| SharedPreferences | `global_search_history` | `search/services/search_history_service.dart:12` | `/search` and Discover recents |
| SharedPreferences | `search_history` | `search/providers/search_providers.dart:70` | older search stack |
| SharedPreferences | `bookmark_search_history` | `engagement/providers/bookmark_search_history_provider.dart:15` | |
| SharedPreferences | `creator.compose.variant` | `creator/screens/compose_poem_screen.dart:30` | |

Logout and account deletion clear **all** SharedPreferences. The `feed_cache`, `categories_cache` and `poets_cache` keys in `AppConstants` are unused, and there is no persistent content cache.

---

## 12. Dead or unreachable code

- **Files nothing imports:**
  - Shell and tabs: `main/tabs/search_tab.dart`, `main/tabs/feed_tab.dart`, `main/tabs/bookmarks_tab.dart`, `main/tabs/bookmarks/screens/unified_bookmarks_screen.dart`, `main/tabs/bookmarks/widgets/bookmark_poem_card.dart`.
  - Core: `core/error/app_error.dart`, `core/services/deep_link_service.dart`, `core/utils/platform_utils.dart`, `core/design_system/theme_config.dart`, `core/widgets/sukhan/{urdu_verse,sparkline}.dart`.
  - Discover widgets: `discover/widgets/{featured_poets_section,trending_section,discover_search_button,recommendation_section}.dart`.
  - Search widgets: `search/widgets/{search_bar_widget,coming_soon_state}.dart`, `search/widgets/skeleton_loaders/{poem,poet}_skeleton.dart`.
  - Other: `image_poetry/screens/bookmarked_images_screen.dart`, `poets/widgets/{hero_featured_poet_card,poetry_category_icons}.dart`.
- **Reachable only from dead code:** `search/widgets/autocomplete_suggestions.dart`, `TextDirectionHelper`, the `/poetry-editor` route.
- **Routes with no in-app caller:** `/search/results/:category`, `/bookmarks/search`, `/bookmarks/couplets`, `/image-poetry/saved`, `/image-poetry/couplet/:id/gallery`.
- **Unused declarations:** `AppError` (whole hierarchy), the retry constants, `feedTTL`/`poemTTL`, the theme provider, the unused dependencies in §1, and the duplicate `imageCollectionServiceProvider`.

---

## 13. Tests, CI and release

- **Tests:** 628 unit, model, mocked-network and widget tests under `test/` (2026-10-20); see `TESTING.md` for helpers and fixtures. No golden tests. There is no `integration_test/`: adding the `integration_test` package breaks the Android build until Gradle is wired for it.
- **CI** (`.github/workflows/`):
  - `play-store-release.yml` runs on **every push to `develop` or `main`**, and on manual dispatch with a choice of track.
    - Steps: Flutter **3.44.4** → `pub get` → decode secrets → `flutter build appbundle --release --build-name=MAJOR.MINOR.<run_number> --build-number=<run_number>` → upload to Play.
    - Track: `main` → **production**, `develop` → **alpha**.
    - `flutter analyze --no-fatal-infos --no-fatal-warnings` and `flutter test` run right after `pub get`, before any secret is decoded or anything is built.
  - `firebase-app-distribution.yml` is manual-only (its push trigger is commented out). It builds a release APK, uploads to the `testers` group, with the same analyze and test gate. Its iOS job is commented out.
  - The most recent Play Store Release run (2026-07-12, `develop`) **failed**. Its logs have expired, so the cause is **UNVERIFIED**. The previous three runs succeeded.
- **iOS releases** are not automated; how they are shipped is **UNVERIFIED**. Release signing is described in `docs/RELEASE_SIGNING.md`.

---

## 14. How to test against production

Production is the only backend with real data, and there is no staging (`stage-api.poetry.app` is a placeholder).

1. **Use a release build.** Only `kReleaseMode` selects `https://api.prod.jahanesukhan.com` (`app_config.dart:108-109`). A debug build always calls `http://10.0.2.2:8081`.
2. Install the release build on an emulator or device, following the release-build rig in `TESTING.md`.
3. **`flutter build` runs the Flutter migrator**, which has silently rewritten `android/app/build.gradle.kts` (`minSdk` → `flutter.minSdkVersion`) and `android/gradle.properties`. After any build, run `git status` and revert those edits unless they are intended.
4. Prod QA has side effects. Sign-in, search, opening poems and poets, and feed events all write analytics and counters. Use the owner's account and keep actions minimal.
5. Release builds turn off `LoggingInterceptor`. To see traffic, use a proxy or device logs. Which `Logger` output survives in release mode is **UNVERIFIED**.
6. To test locally against a debug build, run the backend on the host at port 8081. `10.0.2.2` works on the Android emulator only; iOS Simulator and physical devices need a code change.

---

## 15. Known gaps (one line each)

- Expired sessions are restored as logged-in, and a failed refresh never logs the user out → "Could not load feed" forever (`auth_provider.dart:51-59`, `auth_interceptor.dart:154-166`).
- A 401 from `/api/auth/refresh` may hang the original request in the refresh queue (**UNVERIFIED**, `auth_interceptor.dart:84-89`).
- Every `AuthState` change rebuilds `GoRouter` and resets navigation (`app_router.dart:62`; device behaviour **UNVERIFIED**).
- `clearError()` cannot clear `AuthState.errorMessage` (`auth_state.dart:40`).
- All five tabs fetch on `/main` entry because of the `IndexedStack` (`main_screen.dart:75`).
- No retries, no offline detection, single 30 s timeout; `AppError` is unused.
- Feed events are dropped when a batch POST fails (`feed_event_tracker.dart:85-90`).
- Guest poet lists for tag and top-by-views/poem-count ignore their filter; featured/trending/era/gender do too until the T-045 backend endpoints are deployed (the app falls back).
- Hashtag endpoints have no guest path.
- `/api/hashtags/{slug}/couplets` ignores `lang` on the backend (ES term query on `tagSlugs`, then an unordered `IN` fetch), so a page can mix scripts and lose the ES order (backend, UNVERIFIED on device).
- Search tab counts show ES totals capped at 10,000 (`track_total_hits` default), so "10000" means "10,000 or more".
- Search preview poem, couplet, category and tag cards have no `onTap` (`app_search_preview_results.dart:174-177`).
- Filtered couplet search results cannot open their poem (`couplet.poem` is null) (`app_search_screen.dart:250-258`).
- Search highlight drifts one character per preceding space (`highlighted_text.dart:144-150`).
- Two RTL helpers disagree (ur/ar/fa/ps vs ur only).
- Logout wipes the language preference along with search history (`preferences_service.dart:40-42`).
- The Google sign-in verify payload hard-codes `deviceType: 'android'` (`firebase_auth_service.dart:113-119`).
- (Fixed 2026-10-19) CI previously pinned Flutter 3.27.1 with an uncommitted `pubspec.lock`, so CI built different dependencies (dio 5.11 broke the build) and targeted SDK 35, which Google Play rejected.
- CI runs analyze (errors only) and tests before building, but there is no PR check, and a push to `main` releases straight to the Play **production** track.
- Several routes and screens are unreachable, and several dependencies are unused (§12).
- Section "see all" on Discover is a TODO no-op (`discover_screen.dart:489-496`).
- A poem with no couplets in its response shows an endless spinner instead of its text (`PoemReadingCard` treats `couplets == null` as loading; §9.7).
- The signed-in feed's couplet `contentData` has no `coupletNumber`, so signed-in feed couplets open their poem at the top (backend `FeedItemHydrator`).
