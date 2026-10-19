# Testing Strategy — flutter_poetry_app (Sukhan)

> **Status (2026-10-19): Phase 0 partly started.** What exists today: 24 unit tests in 2 files under `test/core/utils/`,
> all passing (`flutter test` → `+24: All tests passed!`, run 2026-10-19 on Flutter 3.44.4). There are no widget tests,
> no fakes for Dio or secure storage, no JSON fixtures, no golden tests and no automated device tests. Device QA is
> manual, on an emulator with a release build (§7). The release workflows (`play-store-release.yml`,
> `firebase-app-distribution.yml`) build and ship **without running `flutter analyze` or `flutter test`**.
>
> **Backlog:** everything in Phases 0–4 below. Untested today: networking/auth/refresh, every screen and widget, JSON
> models, search normalisation and highlighting, feed, discover, hashtags, image poetry, creator mode.
>
> This is the single source of truth for how this app is tested. AI assistants and developers: [AGENTS.md](AGENTS.md)
> holds the mandatory "code ships with tests" rule; this file tells you *how* to meet it.

## 1. What exists today (verified 2026-10-19)

| File | Tests | Covers |
|---|---|---|
| `test/core/utils/language_typography_test.dart` | 17 | RTL detection, size multipliers, Nastaliq font selection, verse style (`lib/core/utils/language_typography.dart`) |
| `test/core/utils/text_direction_helper_test.dart` | 7 | `TextDirectionHelper`, plus a **regression test** that both helpers agree on RTL languages (group at line 34) |

- `test/widget_test.dart` (the `flutter create` counter scaffold) was deleted on this branch. It compiled, but failed at
  runtime with `Bad state: No ProviderScope found` — `MyApp` is a `ConsumerWidget` (`lib/main.dart:47`) and the
  scaffold pumped it bare. It never tested anything in this app.
- Dev dependencies are only `flutter_test`, `flutter_lints` and code generators (`pubspec.yaml`, `dev_dependencies`).
  No `mocktail`, no Dio mock adapter, no `integration_test`.
- `analysis_options.yaml` includes `package:flutter_lints/flutter.yaml` with no extra rules.

### Three things every test must know

1. **Fonts.** The app uses `google_fonts`, which fetches fonts over HTTP at runtime. Every test file that can reach
   a `GoogleFonts.*` call must do what `language_typography_test.dart:8–11` does:
   ```dart
   TestWidgetsFlutterBinding.ensureInitialized();
   GoogleFonts.config.allowRuntimeFetching = false;
   ```
   Urdu uses the bundled `Jameel Noori Nastaleeq` font (`pubspec.yaml`, `fonts:`), so Urdu styles need no network.
2. **Config is a `late` global.** `appConfig` (`lib/core/config/app_config.dart:100`) is set by `initializeAppConfig()`.
   Tests run in debug mode, so it resolves to `AppConfig.dev()` (base URL `http://10.0.2.2:8081`, `:42`). Any test
   that touches code that reads `appConfig` must initialise it first, or it fails with `LateInitializationError`.
3. **No real network, ever.** Tests replace Dio's adapter and the storage plugins (Phase 0). A test that reaches
   `10.0.2.2` or production is a defect.

## 2. Test types — and when each is required

This mirrors the change-type table in [AGENTS.md](AGENTS.md). If the two disagree, AGENTS.md wins; fix this file.

| Type | Location | Runs with | Required when |
|---|---|---|---|
| **Unit** (pure Dart) | `test/<mirror of lib path>/*_test.dart` | `flutter test` | Formatting, text direction, Urdu normalisation, highlighting, scoring, parsing, adapters |
| **Model / JSON** | `test/.../models/*_test.dart` + `test/fixtures/*.json` | `flutter test` | Any `fromJson` change. Fixtures from real responses, plus variants with missing fields, `null`, and `"-"` |
| **Widget** | `test/.../widgets|screens/*_test.dart` | `testWidgets` + `ProviderScope(overrides: …)` + faked services | Any widget or screen. Assert the Urdu (RTL) **and** English (LTR) rendering |
| **Tap / navigation** | widget tests | tap → assert route or action | Anything a user taps. A visible card with no `onTap` is a bug |
| **Mocked network** | `test/core/network/*_test.dart` | Dio with a fake `HttpClientAdapter` | Networking, auth, retries: 200, 401 + refresh OK, 401 + refresh failed, 5xx, timeout, offline |
| **Golden** (optional) | `test/goldens/` | `matchesGoldenFile` | Layout-critical Urdu screens (couplet card, poem reader). Optional: goldens are platform-sensitive; generate on one OS only |
| **Device** | written checklist today; `integration_test/` after Phase 4 | release build on the emulator (§7) | Glyph shaping, platform channels, Google/Apple sign-in, real slow network |
| **Regression** | any of the above | — | **Every bug fix: the failing test first**, then the fix, both in the same PR |

## 3. Sukhan edge-case checklist

- **Urdu / RTL** — Nastaliq line height; text direction of the widget, not just the string; a long misra that must
  wrap or scale without overflow; mixed Urdu + English in one row (Urdu title, English poet name).
- **Diacritics** (اعراب) — highlight and search must treat `دِل` and `دل` as the same word.
  `AppSearchUrduNormalizer.normalize` strips diacritics and tatweel and maps Arabic → Urdu variants
  (`lib/features/search/utils/app_search_urdu_normalizer.dart:43–63`).
- **Mixed Urdu + Roman queries** — `dil دل`; neither half may be dropped.
- **Roman spelling variants** — `dil`/`dill`, `gham`/`ghum`, `mohabbat`/`muhabbat`, `gham nahi uska`.
- **Devanagari** — content in `hi` is LTR; verify it does not inherit RTL from the Urdu screen around it.
- **Very long verses** — a 600-character misra, a 40-couplet ghazal; no `RenderFlex overflowed` in widget tests.
- **`"-"` placeholders** — the API sends `"-"` for `firstMisra`, `era`, `thumbnailUrl`, `profileImageUrl`, `color`.
  `"-"` is not null: no `int.parse`, no `Image.network("-")`, no displaying a lone dash as content.
- **Empty / absent** — empty lists, a poet with no poems, a feed section with nothing in it.
- **Guest vs signed-in** — guests use `/api/guest/**`; authenticated calls 401 for guests. Every screen reachable as a
  guest gets a guest-mode widget test.
- **Expired session** — access and refresh tokens both expired. The 401 path (`lib/core/network/interceptors/auth_interceptor.dart:80–165`)
  must end on sign-in or guest mode, never a permanent "Could not load feed" (`lib/features/feed/screens/feed_screen.dart:266`).
- **Slow network** — connect/receive/send timeouts are 30 s (`lib/core/constants/app_constants.dart:34–36`, applied in
  `lib/core/network/dio_client.dart:21–23`). On 2G a request can legitimately take most of that: show progress, then
  the right message for timeout vs offline vs 5xx, and cached content where possible.
- **Pagination** — first page, last page, an empty next page, the same item on two pages (dedupe), a scroll
  controller that is actually attached (poet search once never loaded page 2).
- **Unknown content types** — the feed maps unknown types to `UnknownContentData`
  (`lib/features/feed/models/feed_content_data.dart:15`, `:124`); it must render nothing, not crash.
- **Duplicates** — the same poet twice in one list or section.

## 4. Phased roadmap

### Phase 0 — Infrastructure (~1 day)

1. **Layout:**
   ```
   test/
     core/ features/        # mirror lib/
     fixtures/              # real JSON responses (shared with backend contract tests)
     helpers/
       pump_app.dart        # ProviderScope + MaterialApp + localisation + Directionality, font setup
       fake_dio_adapter.dart  # HttpClientAdapter that returns queued responses / errors
       fake_secure_storage.dart
       test_config.dart     # initializeAppConfig() + GoogleFonts setup in one call
   ```
2. **Fakes, not plugins.** Override providers rather than mocking plugins:
   `dioClientProvider` (`lib/core/network/dio_client.dart:138`), `secureStorageProvider`
   (`lib/core/storage/secure_storage.dart:93`), `preferencesServiceProvider` (pattern: `lib/main.dart:39–41`),
   `routerProvider` (`lib/core/routing/app_router.dart:61`). For `SharedPreferences` use
   `SharedPreferences.setMockInitialValues({})`. `FlutterSecureStorage.setMockInitialValues` is available for code
   that constructs storage directly (UNVERIFIED on the pinned 9.x version — confirm before relying on it).
3. **Fake Dio adapter.** A small `HttpClientAdapter` in `test/helpers/` (no new dependency) that can return a status
   and body, throw `DioExceptionType.connectionTimeout`/`receiveTimeout`, or simulate offline
   (`DioExceptionType.connectionError`). Adding `http_mock_adapter` instead is acceptable; pick one and use it everywhere.
4. **`mocktail`** as a dev dependency for service-level mocks (no codegen).
5. **Analysis gate:** `flutter analyze` must report no new errors. Record today's baseline count in the PR that adds
   the gate, then ratchet it down; never add to it.

### Phase 1 — Regression tests for known shipped bugs (~1 week)

Each row is a test that must exist and pass. Whether each bug is already fixed is UNVERIFIED here; write the test first.

| # | Bug (as shipped) | Test | Type |
|---|---|---|---|
| 1 | **Login dead-end** — expired session showed "Could not load feed" forever | fake adapter: feed → 401, `/api/auth/refresh` (`auth_interceptor.dart:109`) → 401; assert tokens cleared and the user lands on sign-in/guest, not the error | Mocked network + widget |
| 2 | **Search tap targets** — poem, couplet, category and tag result cards did nothing when tapped; couplet results could not open their poem | for each card built in `app_search_preview_results.dart:143,174` and `app_search_filtered_results.dart:179–197`: tap → assert navigation. Cards take an optional `onTap` (e.g. `app_search_couplet_card.dart:19,39`), so a missing callback compiles silently | Widget |
| 3 | **Highlight drift** — highlight moved one character left per preceding space | `HighlightedText` with leading/double spaces, diacritics and tatweel before the match; assert the highlighted substring equals the query. Cause area: `normalize` collapses whitespace and trims (`app_search_urdu_normalizer.dart:61–63`) while `highlighted_text.dart:96` maps original → normalised indices | Unit |
| 4 | **Roman couplet search** returned no couplets | search screen with fixture: Roman query + `lang=ur` → couplet section populated (backend half lives in the backend's TESTING.md) | Widget + fixture |
| 5 | **Featured-poet dedupe** — the same poet appeared twice | The duplicate comes from the API (`poetry-backend/.../services/DiscoverService.java:201-226`) and is fixed there; the app test pins that a duplicated `publicId` in a fixture renders once, so a backend regression can't reappear on screen | Widget |
| 6 | **Hashtag `"-"` colour** crashed the trending row (`int.parse("-")`) | `color: "-"`, `null`, `"#zzz"`, `"#1A2B3C"` render without throwing. The same parse exists in three places: `hashtags/widgets/hashtag_pill.dart:29`, `hashtags/screens/hashtag_detail_screen.dart:70`, `main/tabs/poets/widgets/poet_overview_tab.dart:81` — extract one parser and test it | Unit + widget |
| 7 | **`poem_count`** showed 0 for most poets | poet card with `poemCount: 0`, absent and positive; the UI must not claim "0 poems" when the field is absent | Model + widget |
| 8 | Guest feed cards showed only the title (guest adapter dropped the excerpt) | guest fixture → adapter output keeps the excerpt | Unit |
| 9 | Poet search never loaded page 2 | scroll to end → second request made with the next page | Widget + mocked network |
| 10 | Guests got errors on poet Gallery/Books/Videos tabs | guest mode, each tab → no error state | Widget |

(The "two helpers disagreed on RTL" bug already has its regression test: `text_direction_helper_test.dart:34`.)

### Phase 2 — Feed, search and discover (~2–3 weeks)

| # | Area | Scenarios |
|---|---|---|
| 1 | **Search** (`lib/features/search/`) | normaliser table test (diacritics, variants, tatweel, spaces); suggestions; recent searches; Urdu/Roman/Devanagari/mixed queries; empty results state; RTL layout of results |
| 2 | **Feed** (`lib/features/feed/`) | guest vs signed-in; every `FeedContentData` type from fixtures; unknown type; empty feed; pagination and dedupe; pull-to-refresh; offline with cache |
| 3 | **Discover** (`lib/features/discover/`) | bundle parsing with `"-"` placeholders; empty sections; no duplicates across sections |
| 4 | **Auth** (`lib/core/auth/`, `AuthInterceptor`) | concurrent 401s queue behind one refresh; refresh success retries the queue; refresh failure clears the queue and signs out; guest paths never refresh (`auth_interceptor.dart:72–78`) |
| 5 | **Network errors** | timeout, offline, 5xx, malformed JSON → the right message per case, no crash |

**Performance budgets** (proposed, not yet measured; first measurement on the emulator becomes the baseline):
- Search results visible ≤ 1.5 s after typing stops on a normal connection (backend Urdu search target: p95 ≤ 800 ms).
- Feed first page visible ≤ 2 s on a normal connection; on `edge` a progress state within 300 ms and no frozen UI.
- No dropped-frame jank when scrolling a 40-couplet ghazal (check with the performance overlay on a profile build).

### Phase 3 — CI gates

Add a `test` job to `play-store-release.yml` and `firebase-app-distribution.yml` running `flutter pub get`,
`flutter analyze` (no new errors vs baseline) and `flutter test`, and make the build job `needs: test`. Also run it on
pull requests. Prove it with a green run on a branch — never by triggering a release.

### Phase 4 — Device automation

1. **Wire `integration_test`.** Adding the package currently breaks the Android build: `GeneratedPluginRegistrant`
   references `dev.flutter.plugins.integration_test`, which Gradle does not resolve (reported from earlier QA;
   not reproduced in this session — UNVERIFIED here). Fix the Gradle wiring on a branch, prove a debug **and** release
   build still succeed, then add `integration_test/`.
2. Automate the §7 checklist: cold start as guest, search Urdu/Roman, open poem, sign-in flow (where allowed), offline
   and `edge` runs. Against a **local** backend, not production.
3. Until then, device behaviour is a written check reported with what you saw (§7).

## 5. Commands

```bash
flutter test                                     # all tests (fast, offline)
flutter test test/core/utils/                    # one folder
flutter test --plain-name "Urdu is RTL"          # one test by name
flutter test --coverage                          # writes coverage/lcov.info
flutter test --update-goldens test/goldens/      # only when a golden change is intended; review the images
flutter analyze
```

`flutter test` does **not** trigger the Android migrator; `flutter build`/`flutter run` do (§7).

## 6. Conventions

- **Location** mirrors `lib/` under `test/`; file names end in `_test.dart`.
- **Naming:** `group('<Class or widget>.<member>')` and a sentence for each test that states the behaviour
  (`'Urdu is RTL'`, `'unknown language falls back to LTR'`). Bug regression tests name the bug:
  `'regression: "-" colour does not throw'`.
- **Widget tests** pump through `test/helpers/pump_app.dart`, never `MyApp` bare. Pump in both `ur` and `en`
  and assert `Directionality` / `TextDirection` where it matters.
- **Finders:** prefer `find.byKey` for interaction targets; `find.text` with the exact Urdu string from a fixture.
  Never retype Nastaliq by hand in a test — copy it from a fixture or a shared constant.
- **Fixtures:** real responses captured from a **local** backend (or from read-only production `GET`s you were allowed
  to make), with tokens, emails and user ids removed. One file per endpoint shape plus `_placeholders` and `_empty` variants.
- **Time:** no `DateTime.now()` in assertions; inject a clock or pass the time in. Use `tester.pump(duration)` and
  `fakeAsync`, never real delays. `pumpAndSettle` must settle — shimmer and infinite animations need a bounded `pump`.
- **No real I/O:** no network, no font fetching, no platform channels without a fake.
- **Flaky = broken.** Fix the cause (time, network, unsettled animation, shared state); never skip or loosen.

## 7. Device QA rig (manual today)

**Why release builds:** debug builds call `http://10.0.2.2:8081` (`app_config.dart:42`, chosen by `kDebugMode` at
`:106`), so with no local backend they show "Could not load feed" — not an app bug. Release builds
(`kReleaseMode`, `:108`) call production.

```bash
# 1. Emulator (remove a stale lock first, and force public DNS or the API host won't resolve)
rm -f ~/.android/avd/Pixel_7_Pro_API_35.avd/multiinstance.lock
~/Library/Android/sdk/emulator/emulator -avd Pixel_7_Pro_API_35 -dns-server 8.8.8.8,1.1.1.1 &

# 2. Release build (signed via android/key.properties — never commit it) and install
flutter build apk --release
adb install -r build/app/outputs/flutter-apk/app-release.apk

# 3. ALWAYS afterwards: the Flutter migrator rewrites tracked Android files on every build
git status
git diff android/app/build.gradle.kts android/gradle.properties   # e.g. minSdk 24 -> flutter.minSdkVersion
git checkout -- android/app/build.gradle.kts android/gradle.properties   # only if the diff is the migrator's

# 4. Read and drive the UI without screenshots (Flutter semantics text is exposed)
adb shell uiautomator dump /sdcard/ui.xml && adb pull /sdcard/ui.xml /tmp/ui.xml
adb shell input tap <x> <y>          # centre of a node's bounds from ui.xml

# 5. Slow / no network
adb emu network speed edge           # or gprs; reset with: adb emu network speed full
adb emu network delay gprs           # reset with: adb emu network delay none
adb shell svc wifi disable && adb shell svc data disable   # offline; re-enable afterwards
```

`minSdk = 24` in `android/app/build.gradle.kts` is deliberate: Google Play automatic protection rejects bundles below
API 24 (Firebase Auth needs 23+). It stays an explicit number because `flutter.minSdkVersion` differs between Flutter
versions; the migrator's rewrite must not be committed. CI and local both use Flutter 3.44.4.

## 8. Production QA, safely

A release build talks to the live backend with real users. When you test against it:

- **Read-only intent.** Browse, search, open. Never like, bookmark, follow, comment, react or upload just to test.
- **Use the owner's own account** for sign-in checks, keep actions minimal, and sign out afterwards if asked.
- **Report every side effect.** Searching logs an analytics row; tapping a trending chip or search result, opening a
  poem or poet, and signed-in browsing update counters and interests. List each one in your report.
- **No load or scripted repetition against production.** Performance budgets are measured against a local backend.
- **Verify, then claim.** Separate app bugs from environment problems (debug URL, emulator DNS, a stale lock). If a
  finding does not reproduce, retract it.
