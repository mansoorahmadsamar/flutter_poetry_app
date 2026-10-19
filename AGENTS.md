# AI Contributor Rules — flutter_poetry_app (Sukhan)

These rules apply to **any AI assistant** (Claude Code, Cursor, Copilot, Codex, …) writing code in this repo, and to the developers driving them. Read [ARCHITECTURE.md](ARCHITECTURE.md) for how the app works today and [TESTING.md](TESTING.md) for how to test it (including the emulator + release-build rig).

## This is a live app — read this first

Sukhan (Jahan-e-Sukhan) is published on Google Play (`com.techhikes.poetry_app`) and the App Store, with real users and no staging backend.

- **Release workflows reach users.** `.github/workflows/play-store-release.yml` and `firebase-app-distribution.yml` ship builds; they have no analyze/test gate. Never trigger them, tag a release, or push/merge to `main` or `develop` without the owner's explicit OK. Work on a branch.
- **Debug builds do not talk to production.** `lib/core/config/app_config.dart` picks the environment by build mode: debug → `http://10.0.2.2:8081` (a local backend), release → `https://api.prod.jahanesukhan.com`. A "Could not load feed" in a debug build usually means no local backend, not an app bug. Verify against production only with a release build (see TESTING.md).
- **QA against production has side effects.** Signing in, searching, tapping a trending chip, opening a poem or poet all write analytics, counters or interests on the live backend. Use the owner's own account, keep actions minimal, never like/bookmark/follow/comment just to test, and report every side effect.
- **`flutter build` edits tracked files.** The Flutter migrator silently rewrote `android/app/build.gradle.kts` (`minSdk = 23` → `flutter.minSdkVersion`) and `android/gradle.properties` during a build. After any build, run `git status` and revert those edits unless the change is intended and reviewed — `minSdk` decides which phones can install the next release.

## The prime rule: code ships with tests — no exceptions

**Every code change an AI produces MUST include automated tests in the same commit/PR.** The definition of done is: code + tests + `flutter analyze` (no new errors) + `flutter test` green, with the output shown.

| Change | Required tests |
|---|---|
| Pure logic (formatting, text direction, normalisation, highlighting, scoring, parsing) | **Unit tests** in `test/` mirroring the `lib/` path |
| A widget or screen | **Widget test** with `ProviderScope` overrides and faked services; assert what renders in Urdu (RTL) and English (LTR) |
| Anything a user taps | A widget test that **taps it and asserts the navigation or action** — a visible card with no `onTap` is a bug |
| JSON model / API parsing | Model tests from real response fixtures, including missing fields, `null`, and the `"-"` placeholder |
| Networking, auth, retries | Tests with a faked Dio adapter for 200 / 401 / refresh failure / 5xx / timeout / offline |
| Bug fix | **Regression test first**: reproduce the bug in a failing test, then fix it. Both in the PR |
| Device-only behaviour (glyph shaping, platform channels, sign-in, real network speed) | A written check on the emulator with a release build (TESTING.md), reported with what you saw |
| Refactor | Existing tests stay green; add tests for behaviour you relied on if there were none |

Tests must not fetch fonts or touch the network: use `TestWidgetsFlutterBinding.ensureInitialized()` and `GoogleFonts.config.allowRuntimeFetching = false`.

### The edge cases are the test — the happy path is the easy half

Ask, every time, what happens when:

- **The text is Urdu** — right-to-left, Nastaliq line height, diacritics (اعراب), a long misra that must wrap or scale, mixed Urdu + English in one line (a title in Urdu, a poet name in English).
- **The query or content is in another script** — Roman (`dil`, `gham nahi uska`), Devanagari, or a mix. Spelling varies; test the variants.
- **A value is absent or a placeholder** — `null`, empty list, or the API's `"-"` (sent for `firstMisra`, `era`, `thumbnailUrl`, `profileImageUrl`, `color`). `"-"` is not null.
- **The user is a guest** — guest endpoints (`/api/guest/**`) are a subset; authenticated calls return 401 for guests.
- **The session has expired** — access token and refresh token both expired. The user must land on sign-in or guest mode, never on a permanent error.
- **The network is slow or gone** — 2G/EDGE, the 30 s timeout, offline, a 5xx. Show cached content where possible and the right message (offline vs server error).
- **The list is empty, huge, or paginated** — the last page, a duplicate item across pages, a type the app doesn't know (`UnknownContentData` must not crash).

Real faults this app has actually shipped, each of which a test would have caught first:
- the trending-hashtags row crashed on a `"-"` colour (`int.parse("-")` in `hashtag_pill.dart`);
- search result cards for poems, couplets, categories and tags were visible but did nothing when tapped;
- couplet search results could never open their poem;
- the search highlight drifted one character left for every preceding space;
- users with expired sessions saw "Could not load feed" forever;
- guests' feed cards showed only the title because the guest adapter dropped the excerpt;
- two helpers disagreed on which languages are right-to-left;
- poet search never loaded a second page (its scroll controller was never attached);
- guests got errors on the poet Gallery, Books and Videos tabs.

## Editing existing code = updating its tests

1. **Behaviour change** → update the assertions to the new intended behaviour, deliberately.
2. **Refactor** → tests pass unchanged; if they break, behaviour changed — stop and check.
3. **Touched code has no tests** → add them now. Most of this app is untested; the debt stops at whoever edits the file.
4. A red test is **never** fixed by loosening the assertion.

## Reuse before you write

- **Search first** in `lib/core/` (widgets, design system, utils, network, error) and the feature's own folder before creating anything.
- **There is dead code** (e.g. `features/main/tabs/search_tab.dart`, several unreachable routes and providers — see ARCHITECTURE.md). Don't build on it by accident; check that a screen or provider is actually reachable.
- **Extend, don't clone.** Two near-identical cards or services drift apart.

## No god widgets — small, single-responsibility, reusable

- A screen composes widgets; it doesn't hold every widget inline. Split large `build` methods into named widgets, and move logic out of widgets into providers/services/utils where it can be unit-tested.
- Rough smell: a `build` or method past ~60 lines with several branches, or a widget file past ~400 lines.

## Single source of truth — no magic values

- **One definition per rule.** Text direction, typography multipliers, placeholder handling, timeouts, page sizes, cache TTLs and API paths live in one place (`lib/core/...`) and are imported — never re-declared.
- **No magic numbers or strings** for domain values; name them.
- When you find a duplicated value or rule nearby, centralising it is in scope — with its test.

## State management (Riverpod)

- **Don't `watch` the whole `authProvider`** unless you need every field; watch a `select`ed field. Watching it wholesale makes token refreshes rebuild the router and re-run every dependent fetch.
- After a mutation (bookmark, reaction, follow), invalidate **every** provider that shows that state, including the Bookmarks tab.
- All five tabs build when `/main` opens (IndexedStack), so their initial loads all fire at once. Keep initial loads light.

## The API contract

- Parse defensively: unknown fields are ignored, missing fields default, `"-"` is treated as absent, unknown item types render nothing rather than crash.
- Pass the right id to the right route: a verse or couplet result opens its **poem** (`/main/poems/:poemPublicId`), never `/main/poems/:coupletId`.
- Coordinate any change that needs a backend change with the backend repo's AGENTS.md rules (released app versions keep calling old endpoints).

## Accessibility and Urdu UX

- Every tappable icon has a semantic label (`tooltip` or `Semantics(label: …)`); a bare icon button reads as "button" to TalkBack/VoiceOver.
- Urdu text uses the shared typography (`LanguageTypography` / design system) — never a hard-coded font or line height.

## Security rules

- No secrets in code, assets, tests or docs: `android/key.properties`, keystores, `*.p8`, `google-services.json`/`GoogleService-Info.plist` changes, API keys. The pre-commit hook (`.githooks/pre-commit`, gitleaks) enforces this — install it with `git config core.hooksPath .githooks`.
- Never log tokens. Request logging runs in debug builds only; keep it that way.

## Follow the existing pattern — or change every instance of it

If you deliberately drift from an established pattern, state why in the PR and apply it to the other instances.

## A flaky test is a defect

Fix the nondeterminism (real time, real network, animations not settled, shared state); never skip, retry-until-green or loosen. A flake that can't be fixed immediately gets a tracker row and an owner.

## Hard prohibitions

- Never delete, skip or weaken an existing test to make a build pass without explicit human confirmation.
- Never trigger a store release, tag, or push/merge to `main`/`develop` without the owner's explicit OK.
- Never like/bookmark/follow/comment on production just to test.
- Never commit secrets, or bypass the gitleaks hook without saying so in the commit message.
- Never leave the migrator's `android/` edits in a commit unreviewed.

## If test infrastructure is missing

Fakes, fixtures and device automation are still being built — see [TESTING.md](TESTING.md). That does not waive the prime rule; set up what your change needs as part of the change. Note: adding the `integration_test` package currently breaks the Android build until Gradle is wired (TESTING.md).

## Tracker first — rows before the work, every time

**Every request becomes granular tracker rows BEFORE the first tool call of the work.**

```bash
TRACKER=sukhan python3 /Users/mansoorahmadsamar/Documents/Development/dolce-ict/tools/tracker.py add \
  --area Search --task "..." --sub "Bug · App" --prio P1 --status "In progress" --start today --due +2
TRACKER=sukhan python3 /Users/mansoorahmadsamar/Documents/Development/dolce-ict/tools/tracker.py set T-009 status=Done release=Local
```

**`TRACKER=sukhan` is not optional** — the tool's default is a Dolce sheet. Sheet: *Sukhan — Urdu Poetry & Literature Tracker*.

**Why:** the owner uses the tracker to justify his time and effort **as it is spent**; rows reconstructed at the end defeat the purpose. **The trigger is a new request, not a new session** — if you are thinking *"this is just a follow-up"*, that is exactly when rows are due. **Chunk small**, and **bugs found mid-work get their own rows**.

**Areas:** Auth, Feed, Discover, Search, Engagement, Poets, Poems & Couplets, Image Poetry, Creator Mode, Admin Portal, Website, Backend Platform, Data Quality, Performance, Security, Testing, CI/CD & Deployment, Documentation, Localization & Accessibility.

If a tracker call fails with a dropped connection, retry it.

## Repo facts you need

- **Flutter 3.44 / Dart 3.12.** Riverpod, Dio (hand-written calls, no Retrofit), go_router, flutter_secure_storage, shared_preferences, cached_network_image, google_fonts (runtime fetching on; only Jameel Noori Nastaleeq is bundled), Firebase Auth + Google + Apple sign-in.
- **`pubspec.lock` is git-ignored**, so dependency resolution can differ between machines.
- **Release signing** uses `android/key.properties` + `android/keystore/release.keystore` (never commit or print them).
- **Android emulator:** `Pixel_7_Pro_API_35`; launch with `-dns-server 8.8.8.8,1.1.1.1` (otherwise the API host may not resolve) and remove a stale `~/.android/avd/Pixel_7_Pro_API_35.avd/multiinstance.lock` before relaunching. `adb shell uiautomator dump` exposes on-screen text for scripted checks.
- Older root-level `*.md` files are historical notes and may be wrong; [ARCHITECTURE.md](ARCHITECTURE.md) and the code are the source of truth.
