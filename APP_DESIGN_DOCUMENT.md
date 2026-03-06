# Sukhan - Flutter Poetry App Design Document

> Single source of truth for design system, architecture, navigation, screens, and conventions.

---

## Table of Contents

1. [App Overview](#1-app-overview)
2. [Design System](#2-design-system)
3. [Architecture](#3-architecture)
4. [Navigation & Routing](#4-navigation--routing)
5. [Features & Screens](#5-features--screens)
6. [State Management](#6-state-management)
7. [Networking](#7-networking)
8. [Data Models & Code Generation](#8-data-models--code-generation)
9. [RTL & Localization](#9-rtl--localization)
10. [Authentication](#10-authentication)
11. [Storage](#11-storage)
12. [Conventions & Patterns](#12-conventions--patterns)

---

## 1. App Overview

**App Name:** Sukhan (سخن — "Where Poetry Lives")
**Platform:** Flutter (Android & iOS)
**SDK:** Dart >=3.0.0 <4.0.0
**Material Design:** Material 3 enabled

**Core Stack:**
| Layer | Technology |
|-------|------------|
| State Management | Riverpod 2.6.1 |
| Networking | Dio 5.4.0 |
| Code Generation | Freezed 2.4.7 + json_serializable 6.7.1 |
| Navigation | GoRouter 14.8.1 |
| Authentication | Firebase Auth 5.3.4 + Google Sign-In 6.2.1 |
| Storage | FlutterSecureStorage 9.2.4 + SharedPreferences 2.5.3 |
| Images | CachedNetworkImage 3.4.1 |

---

## 2. Design System

### 2.1 Color Palette

**Active Theme:** Poetic Green

#### Primary Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `primary` | `#1B4D3E` | Deep Poetic Green — buttons, app bars, accents |
| `primaryLight` | `#2A6F5C` | Hover/lighter states |
| `primaryDark` | `#14392E` | Pressed/darker states |

#### Secondary Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `secondary` | `#C5A059` | Accent Gold — badges, highlights |
| `secondaryLight` | `#D4B374` | Subtle gold accents |
| `secondaryDark` | `#B08F42` | Emphasis gold |

#### Background Colors
| Token | Light | Dark |
|-------|-------|------|
| `background` | `#F5F5DC` (Soft Cream) | `#1A1A1A` (Warm Black) |
| `surface` | `#FFFFFF` | `#2C2C2C` |

#### Text Colors
| Token | Light | Dark |
|-------|-------|------|
| `textPrimary` | `#2C2C2C` (Charcoal) | `#F5F5DC` (Cream) |
| `textSecondary` | `#5C5C5C` | `#C5C5B4` |
| `textDisabled` | `#A8A8A8` | `#7C7C74` |

#### Semantic Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `success` | `#2D7A5A` | Harmonious green |
| `error` | `#C84B31` | Warm terracotta |
| `warning` | `#D4A259` | Warm amber-gold |
| `info` | `#4A7C8E` | Muted teal-blue |

#### Border & Divider
| Token | Light | Dark |
|-------|-------|------|
| `border` | `#D8D8C8` | `#3F3F3F` |
| `divider` | `#E8E8DC` | `#333333` |

#### Special Colors
| Token | Hex | Usage |
|-------|-----|-------|
| `overlay` | `#661B4D3E` (40%) | Modal overlays |
| `shimmerBase` | `#E8E8DC` | Shimmer loading base |
| `shimmerHighlight` | `#F5F5DC` | Shimmer loading highlight |
| `verseBackground` | `#FAFAED` | Very pale cream for verse areas |
| `urduTextAccent` | `#2A6F5C` | Urdu text emphasis |

**File:** `lib/core/design_system/app_colors.dart`

---

### 2.2 Typography

#### Font Families
| Language | Font | Source |
|----------|------|--------|
| English / Roman | Roboto | Google Fonts (dynamic) |
| Urdu / Arabic / Persian | Jameel Noori Nastaleeq | Bundled asset (`assets/fonts/`) |

#### English Text Scale (Roboto)

| Style | Size | Weight | Height | Spacing |
|-------|------|--------|--------|---------|
| Display Large | 57px | W400 | 1.12 | -0.25 |
| Display Medium | 45px | W400 | 1.15 | 0 |
| Display Small | 36px | W400 | 1.22 | 0 |
| Headline Large | 32px | W600 | 1.25 | 0 |
| Headline Medium | 28px | W600 | 1.28 | 0 |
| Headline Small | 24px | W600 | 1.33 | 0 |
| Title Large | 22px | W500 | 1.27 | 0 |
| Title Medium | 16px | W500 | 1.5 | 0.15 |
| Title Small | 14px | W500 | 1.42 | 0.1 |
| Body Large | 16px | W400 | 1.5 | 0.5 |
| Body Medium | 14px | W400 | 1.42 | 0.25 |
| Body Small | 12px | W400 | 1.33 | 0.4 |
| Label Large | 14px | W500 | 1.42 | 0.1 |
| Label Medium | 12px | W500 | 1.33 | 0.5 |
| Label Small | 11px | W500 | 1.45 | 0.5 |

#### Urdu Text Scale (Jameel Noori Nastaleeq)
Same sizes as English but with increased line heights for proper Nastaleeq ligature rendering:
- Display/Headline/Title: height 1.8
- Body: height 2.0 (poetry optimized)
- Label: height 1.6

#### Special Poetry Styles
| Style | Size | Weight | Height | Font |
|-------|------|--------|--------|------|
| `urduVerseStyle` | 20px | W400 | 2.2 | Jameel Noori Nastaleeq |
| `urduPoetNameStyle` | 18px | W600 | 1.8 | Jameel Noori Nastaleeq |

#### Language-Specific Adjustments
| Language | Size Multiplier | Line Height |
|----------|----------------|-------------|
| Urdu (ur) | 1.18x | 1.75 |
| English (en) | 1.00x | 1.4 |
| Hindi (hi) | 1.06x | 1.5 |
| Arabic (ar) | 1.18x | 1.75 |
| Persian (fa) | 1.18x | 1.75 |

**Files:** `lib/core/design_system/app_typography.dart`, `lib/core/utils/language_typography.dart`

---

### 2.3 Spacing Scale

Base unit: **4px**

| Token | Value | Usage |
|-------|-------|-------|
| `xs` | 4px | Tight gaps |
| `sm` | 8px | Small gaps, list item padding |
| `md` | 16px | Standard padding, card padding, screen padding |
| `lg` | 24px | Section margins |
| `xl` | 32px | Large gaps |
| `xxl` | 48px | Extra-large gaps |
| `xxxl` | 64px | Maximum gaps |

#### Icon Sizes
| Token | Value |
|-------|-------|
| `iconXs` | 16px |
| `iconSm` | 20px |
| `iconMd` | 24px |
| `iconLg` | 32px |
| `iconXl` | 48px |

#### Border Radius
| Token | Value | Usage |
|-------|-------|-------|
| `radiusXs` | 4px | Badges, chips |
| `radiusSm` | 8px | Buttons, small cards |
| `radiusMd` | 12px | Cards, inputs, dialogs |
| `radiusLg` | 16px | Large cards, sections |
| `radiusXl` | 24px | Hero elements |
| `radiusRound` | 999px | Circular/pill shapes |

#### Elevation
| Token | Value |
|-------|-------|
| `elevationNone` | 0 |
| `elevationXs` | 1 |
| `elevationSm` | 2 |
| `elevationMd` | 4 |
| `elevationLg` | 8 |
| `elevationXl` | 16 |

**File:** `lib/core/design_system/app_spacing.dart`

---

### 2.4 Theme Configuration

Both light and dark themes share the same structure:

| Component | Light | Dark |
|-----------|-------|------|
| Scaffold BG | `#F5F5DC` | `#1A1A1A` |
| AppBar BG | `#FFFFFF` | `#2C2C2C` |
| AppBar Icons | `#2C2C2C` | `#F5F5DC` |
| Card Color | `#FFFFFF` | `#2C2C2C` |
| Card Elevation | 2.0 | 2.0 |
| Card Radius | 12px | 12px |
| Input Fill | `#FFFFFF` | dark surface |
| Input Radius | 12px | 12px |
| Focus Border | `#1B4D3E` (2px) | `#1B4D3E` (2px) |
| Button Padding | 24px H x 16px V | 24px H x 16px V |
| Button Radius | 12px | 12px |
| Divider | `#E8E8DC` (1px) | `#333333` (1px) |

**Standard App Bar:** Green background (`#1B4D3E`), white text/icons, elevation 0, bold title.

**Current ThemeMode:** `ThemeMode.light` (hardcoded in `main.dart`)

**Files:** `lib/core/design_system/app_theme.dart`, `lib/core/design_system/theme_provider.dart`, `lib/core/design_system/theme_config.dart`

---

### 2.5 Animation Constants

| Constant | Duration |
|----------|----------|
| Short | 200ms |
| Medium | 300ms |
| Long | 500ms |

**File:** `lib/core/constants/app_constants.dart`

---

## 3. Architecture

### 3.1 Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── auth/                    # Firebase auth, auth state, auth provider
│   ├── config/                  # Environment config (dev/stage/prod)
│   ├── constants/               # App-wide constants
│   ├── design_system/           # Colors, typography, spacing, theme
│   ├── models/                  # Shared models (LanguageModel, UserModel)
│   ├── network/                 # DioClient, interceptors, API DTOs
│   │   ├── dto/                 # ApiResponse<T>, PaginatedResponse<T>
│   │   └── interceptors/        # AuthInterceptor, LoggingInterceptor
│   ├── providers/               # Core providers (language, user)
│   ├── routing/                 # GoRouter configuration
│   ├── services/                # Core services (language)
│   ├── storage/                 # SecureStorage, PreferencesService
│   ├── utils/                   # TextDirection, LanguageTypography helpers
│   ├── widgets/                 # Shared widgets (StandardAppBar, LocalizedText)
│   └── l10n/                    # Localization (placeholder)
├── features/
│   ├── splash/                  # Splash screen
│   ├── auth/                    # Login screen
│   ├── feed/                    # Personalized feed
│   ├── discover/                # Discovery & exploration
│   ├── search/                  # Global search
│   ├── engagement/              # Bookmarks, likes, services
│   ├── image_poetry/            # Image generation & editor
│   └── main/                    # Tab container + sub-features
│       ├── main_screen.dart     # Bottom navigation
│       └── tabs/
│           ├── poets/           # Poets list, detail, poems
│           ├── bookmarks/       # Unified bookmarks
│           └── profile/         # User profile & settings
```

### 3.2 Feature Structure Convention

Each feature follows this pattern:
```
feature_name/
├── models/       # Freezed/JSON data classes
├── services/     # API call wrappers (uses DioClient)
├── providers/    # Riverpod providers (StateNotifier, FutureProvider)
├── screens/      # Full-page widgets (ConsumerStatefulWidget)
└── widgets/      # Reusable UI components for this feature
```

### 3.3 Initialization Flow

```
main() →
  1. WidgetsFlutterBinding.ensureInitialized()
  2. Firebase.initializeApp()
  3. initializeAppConfig()          # dev/stage/prod
  4. SharedPreferences.getInstance()
  5. ProviderScope(overrides: [...])
  6. MyApp(MaterialApp.router)
       → routerProvider (GoRouter)
       → AppTheme.lightTheme / darkTheme
```

### 3.4 Environment Configuration

| Env | Base URL | Logging | Analytics |
|-----|----------|---------|-----------|
| dev | `http://10.0.2.2:8081` | true | false |
| stage | `https://stage-api.poetry.app` | true | true |
| prod | `https://134.199.243.167` | false | true |

Timeouts: 30s connect, 30s receive, 30s send (all environments).

**File:** `lib/core/config/app_config.dart`

---

## 4. Navigation & Routing

### 4.1 Route Map

```
/                                     → SplashScreen
/login                                → LoginScreen
/main                                 → MainScreen (5 tabs)
  ├── Tab 0: FeedScreen
  ├── Tab 1: DiscoverScreen
  ├── Tab 2: AppBookmarksScreen
  ├── Tab 3: PoetsTab (PoetsListScreen)
  └── Tab 4: ProfileTab
/main/poets-search                    → PoetsSearchScreen
/main/poets/:publicId                 → PoetDetailScreen
/main/poems/:publicId                 → PoemDetailScreen
/bookmarks/search                     → BookmarkSearchScreen
/bookmarks/couplets                   → BookmarkedCoupletsScreen
/image-poetry/templates               → TemplateSelectionScreen
/image-poetry/generate/:coupletId     → ImageGenerationScreen
/image-poetry/couplet/:coupletId/gallery → GeneratedImageGalleryScreen
/image-poetry/saved                   → SavedImagesScreen
/image-poetry/image/:imageId          → ImageDetailScreen
/image-poetry/:contentId              → ImageDetailScreen (bookmarks)
/poetry-editor                        → PoetryEditorScreen
/search                               → AppSearchScreen
/search/results/:category             → CategoryResultsScreen
```

### 4.2 Auth Guard

GoRouter redirect logic:
1. If loading → stay on splash
2. If splash & not loading → redirect based on auth state
3. If not authenticated → redirect to `/login`
4. If authenticated on `/login` → redirect to `/main`

### 4.3 Tab Configuration

| Index | Label | Icon (Inactive) | Icon (Active) | Screen |
|-------|-------|-----------------|---------------|--------|
| 0 | Feed | `home_outlined` | `home` | `FeedScreen` |
| 1 | Discover | `explore_outlined` | `explore` | `DiscoverScreen` |
| 2 | Bookmarks | `bookmark_border` | `bookmark` | `AppBookmarksScreen` |
| 3 | Poets | `person_outline` | `person` | `PoetsTab` |
| 4 | Profile | `account_circle_outlined` | `account_circle` | `ProfileTab` |

Tab persistence: `IndexedStack` + `AutomaticKeepAliveClientMixin`
Scroll-to-top: Double-tap Feed tab triggers `scrollToTop()` via `GlobalKey<FeedScreenState>`

**File:** `lib/core/routing/app_router.dart`, `lib/features/main/main_screen.dart`

---

## 5. Features & Screens

### 5.1 Splash

**SplashScreen** — Animated branding with Urdu calligraphy background, Sukhan logo, gradient tagline "جہانِ سخن", pulsing loading indicator. Entrance: fade + scale + shimmer animations.

### 5.2 Auth

**LoginScreen** — Google Sign-In via Firebase Auth. Animated branding, single sign-in button, error/loading handling via `authProvider`.

### 5.3 Feed

**FeedScreen** — Personalized "For You" feed with infinite scroll, pull-to-refresh, and engagement tracking.

| Component | Details |
|-----------|---------|
| Content Types | COUPLET, POEM, POET_SPOTLIGHT, POET_IMAGE |
| Pagination | Cursor-based (opaque HMAC-signed cursor) |
| Event Tracking | impression, dwell_ms, skip_fast, open_item, bookmark, share, follow |
| Events | Batched, fire-and-forget via `POST /api/events/batch` |
| Engagement | Optimistic UI overlay (instant like/bookmark/follow feedback) |
| Lifecycle | Flush events on app background, clear on refresh |
| Race Guard | Synchronous `_fetchLock` prevents duplicate pagination fetches |
| Impression Dedup | `_impressedItemKeys` Set prevents duplicate impression events |

Card widgets: `CoupletFeedCard`, `PoemFeedCard`, `PoetSpotlightFeedCard`, `PoetImageFeedCard`
Type dispatch: `FeedItemBuilder` with Dart 3 sealed class pattern matching
Loading: `FeedShimmer` with mixed card-shape skeleton

### 5.4 Discover

**DiscoverScreen** — Curated discovery with staggered entrance animations.

Sections:
1. Hero header with search button
2. Trending searches (chip list)
3. Editor's Picks (horizontal scrollable rail)
4. Recommended For You (horizontal scrollable rail)
5. Featured Poets (grid)
6. Categories (grid)

API: `GET /api/discover?lang=ur` → `DiscoverBundle`
Cache: Service-level 15-minute TTL

### 5.5 Search

**AppSearchScreen** — Unified global search with 4 display modes:

| Mode | Trigger | Shows |
|------|---------|-------|
| Idle | Initial | Recent searches + recommendations |
| Suggesting | User typing | Inline autocomplete suggestions |
| Preview | Search submitted, "All" selected | Grouped results (Couplet/Poem/Poet) |
| Filtered | Specific type selected | Paginated single-type list |

Features: Urdu text normalization, query highlighting, sorting (relevance/likes/shares/trending), segment control (All/Couplet/Poem/Poet).

### 5.6 Poets

**PoetsListScreen** — 3-column masonry grid with horizontal discovery sections (Trending, Featured, Top Read). Infinite scroll, filter chips, pull-to-refresh.

**PoetDetailScreen** — NestedScrollView with profile header + 5 tabs:

| Tab | Content |
|-----|---------|
| Overview | Biography, birth/death, era, stats, tags |
| Poetry | Poem list in grid |
| Gallery | Image uploads with engagement |
| Books | Published books |
| Videos | Video references |

**PoemDetailScreen** — Full poem with couplet list, per-couplet engagement (like/bookmark/share), image generation from couplet.

### 5.7 Bookmarks

**AppBookmarksScreen** — Unified bookmarks with type filter (ALL/POEM/COUPLET/IMAGE), search, sort, pagination. Swipe-to-delete, notes editing, stats display.

### 5.8 Image Poetry

**ImageGenerationScreen** — Generate decorative images for couplets via templates or custom backgrounds.

**PoetryEditorScreen** — Free-form canvas editor: add/style text layers, upload backgrounds, export to PNG/JPEG.

**Supporting screens:** TemplateSelectionScreen, GeneratedImageGalleryScreen, SavedImagesScreen, ImageDetailScreen.

### 5.9 Profile

**ProfileTab** — User info (from Firebase/Auth), language selector, dynamic "About" content pages (Privacy Policy, Terms, FAQ), logout.

---

## 6. State Management

### 6.1 Provider Types Used

| Type | When to Use | Example |
|------|-------------|---------|
| `Provider` | Stateless services/instances | `dioClientProvider`, `feedServiceProvider` |
| `StateNotifierProvider` | Mutable state with methods | `feedProvider`, `authProvider`, `discoverProvider` |
| `FutureProvider` | One-time async fetch | `userProfileProvider`, `availableLanguagesProvider` |
| `StateProvider` | Simple mutable value | `feedEngagementProvider`, `themeProvider` |
| `.family` | Parameterized providers | `unifiedBookmarksProvider(filters)` |
| `.autoDispose` | Cache cleared on unwatch | `userProfileProvider.autoDispose` |

### 6.2 Core Providers

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | StateNotifierProvider | Auth state (login, logout, refresh) |
| `dioClientProvider` | Provider | DioClient HTTP instance |
| `secureStorageProvider` | Provider | Encrypted token storage |
| `preferencesServiceProvider` | Provider | User preferences |
| `selectedLanguageProvider` | Provider<String> | Current language code |
| `selectedLanguageNotifierProvider` | StateNotifierProvider | Language selection with persistence |
| `userProfileProvider` | FutureProvider.autoDispose | Current user profile |
| `routerProvider` | Provider | GoRouter instance |

### 6.3 Provider Invalidation

- Language change: Providers watching `selectedLanguageProvider` are auto-recreated
- Logout: `userProfileProvider.autoDispose` clears cache
- Pull-to-refresh: Notifier methods reset state and refetch
- Manual: `ref.invalidate(provider)` forces refetch

### 6.4 StateNotifier Pattern

```dart
class FeedState {
  final List<FeedItem> items;
  final bool isLoading;
  final String? error;
  // ...copyWith()
}

class FeedNotifier extends StateNotifier<FeedState> {
  bool _fetchLock = false; // sync guard for race conditions

  Future<void> loadFirstPage() async { ... }
  Future<void> loadNextPage() async { ... }
}

final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final service = ref.watch(feedServiceProvider);
  final lang = ref.watch(selectedLanguageProvider); // auto-recreates on lang change
  return FeedNotifier(feedService: service, lang: lang, ref: ref);
});
```

---

## 7. Networking

### 7.1 DioClient

Central HTTP client wrapping Dio. All feature services use `dioClientProvider` to get the Dio instance.

**Configuration:**
- Base URL from `appConfig.baseApiUrl`
- Timeouts: 30s connect / 30s receive / 30s send
- Content-Type: `application/json`
- SSL: Custom certificate handling for production server

**Interceptors (in order):**
1. **AuthInterceptor** — Auto-attaches `Authorization: Bearer <token>` + `X-User-Id` header
2. **LoggingInterceptor** — Pretty-prints requests/responses (dev/stage only)

### 7.2 Auth Interceptor

- Reads access token from `SecureStorageService`
- On 401: Triggers token refresh via `/api/auth/refresh`
- Request queue: Concurrent requests wait during refresh, then retry with new token
- Lock mechanism prevents concurrent refresh attempts

### 7.3 API Response Wrapper

All backend responses follow:
```json
{
  "success": true,
  "message": "...",
  "data": { ... }
}
```

Dart: `ApiResponse<T>` with `genericArgumentFactories` for type-safe deserialization.

### 7.4 Pagination

Paginated endpoints return:
```json
{
  "content": [...],
  "totalElements": 100,
  "totalPages": 10,
  "currentPage": 0,
  "hasNext": true,
  "hasPrevious": false
}
```

Dart: `PaginatedResponse<T>` (page-based, zero-indexed).

Feed uses **cursor-based** pagination: `nextCursor` (opaque, HMAC-signed), never parse/modify.

### 7.5 Service Pattern

```dart
class FeedService {
  final Dio _dio;
  FeedService(this._dio);

  Future<FeedResponse> getFeed({String lang, String? cursor, int limit}) async {
    final response = await _dio.get('/api/feed', queryParameters: {...});
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data, (json) => json as Map<String, dynamic>,
    );
    return FeedResponse.fromJson(apiResponse.data!);
  }
}

final feedServiceProvider = Provider<FeedService>((ref) =>
  FeedService(ref.watch(dioClientProvider).dio),
);
```

**File:** `lib/core/network/dio_client.dart`, `lib/core/network/interceptors/`, `lib/core/network/dto/api_response.dart`

---

## 8. Data Models & Code Generation

### 8.1 Freezed Models

Used for immutable data classes with `copyWith()`, equality, and JSON serialization.

```dart
@freezed
class LanguageModel with _$LanguageModel {
  const factory LanguageModel({
    required String code,
    required String name,
    required String nativeName,
    required String direction,
    @Default(true) bool isActive,
  }) = _LanguageModel;

  factory LanguageModel.fromJson(Map<String, dynamic> json) =>
      _$LanguageModelFromJson(json);
}
```

Generated files: `.freezed.dart` (copyWith, equality) + `.g.dart` (JSON)

### 8.2 Custom fromJson (Polymorphic)

For models where deserialization depends on a sibling field (e.g., feed content type):

```dart
@Freezed(toJson: false)
class FeedItem with _$FeedItem {
  factory FeedItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return FeedItem(
      type: type,
      contentData: FeedContentData.fromJson(type, json['contentData']),
    );
  }
}
```

Use `@Freezed(toJson: false)` when the model is only deserialized, never serialized back.

### 8.3 Sealed Classes

Dart 3 sealed classes for type-safe polymorphism:

```dart
sealed class FeedContentData {
  factory FeedContentData.fromJson(String type, Map<String, dynamic> json) {
    return switch (type) {
      'COUPLET' => CoupletContentData.fromJson(json),
      'POEM' => PoemContentData.fromJson(json),
      'POET_SPOTLIGHT' => PoetSpotlightContentData.fromJson(json),
      'POET_IMAGE' => PoetImageContentData.fromJson(json),
      _ => UnknownContentData(rawData: json),
    };
  }
}
```

Pattern matching in widgets:
```dart
return switch (data) {
  CoupletContentData() => CoupletFeedCard(data: data),
  PoemContentData() => PoemFeedCard(data: data),
  UnknownContentData() => null, // graceful fallback
};
```

### 8.4 Plain Dart Classes

For models only serialized TO json (never deserialized), skip Freezed:

```dart
class FeedEvent {
  final String eid, t, itemKey, sid;
  final int ts;
  Map<String, dynamic> toJson() => { 'eid': eid, 't': t, ... };
}
```

### 8.5 Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

Generates `.freezed.dart` and `.g.dart` files. Run after creating/modifying Freezed models.

---

## 9. RTL & Localization

### 9.1 Language System

**Supported Languages:** Urdu (ur), English (en), Hindi (hi), Arabic (ar), Persian (fa), Pashto (ps)
**Default:** English (en)
**Primary Content Language:** Urdu (ur)

Language selection persists to `SharedPreferences` AND syncs to backend profile (`PUT /api/profile`).

### 9.2 Text Direction

| Language | Direction |
|----------|-----------|
| Urdu (ur) | RTL |
| Arabic (ar) | RTL |
| Persian (fa) | RTL |
| Pashto (ps) | RTL |
| English (en) | LTR |
| Hindi (hi) | LTR |

**Helper:** `TextDirectionHelper.getTextDirection(langCode)`

### 9.3 LocalizedText Widget

Smart text widget that auto-applies:
- **Font:** Jameel Noori Nastaleeq for Urdu, theme default for others
- **Direction:** RTL for Urdu/Arabic, LTR for English
- **Alignment:** Center for Urdu (if not explicitly set), start for others
- **Line Height:** Increased for Nastaleeq script

```dart
LocalizedText(
  'شاعری',
  style: TextStyle(fontSize: 18),
  maxLines: 2,
  overflow: TextOverflow.ellipsis,
)
```

### 9.4 Provider-Driven Language

Providers watching `selectedLanguageProvider` auto-recreate when language changes:
- Feed reloads with new language content
- Discover bundle refreshes
- Search results reflect language preference

**Files:** `lib/core/widgets/localized_text.dart`, `lib/core/utils/text_direction_helper.dart`, `lib/core/utils/language_typography.dart`, `lib/core/providers/language_provider.dart`

---

## 10. Authentication

### 10.1 Flow

```
User taps "Sign in with Google"
  → Native Google Sign-In dialog
  → Get Google credentials (accessToken, idToken)
  → Firebase signInWithCredential
  → Get Firebase ID token
  → POST /api/auth/firebase/verify (Firebase token)
  → Receive JWT (accessToken + refreshToken)
  → Store in SecureStorage
  → Navigate to /main
```

### 10.2 Token Management

| Token | Storage | Header |
|-------|---------|--------|
| Access Token | FlutterSecureStorage | `Authorization: Bearer <token>` |
| Refresh Token | FlutterSecureStorage | Used in `/api/auth/refresh` body |
| User ID | FlutterSecureStorage | `X-User-Id: <id>` |

### 10.3 Auto-Refresh

On 401 response:
1. Lock refresh mechanism
2. Call `POST /api/auth/refresh` with refresh token
3. Store new tokens
4. Retry original request with new access token
5. Retry all queued requests
6. Unlock refresh mechanism

### 10.4 Logout

1. Call `POST /api/auth/logout` (backend)
2. Firebase sign out
3. Google sign out
4. Clear all tokens from SecureStorage
5. Router redirects to `/login`

**Files:** `lib/core/auth/firebase_auth_service.dart`, `lib/core/auth/auth_provider.dart`, `lib/core/auth/auth_state.dart`

---

## 11. Storage

### 11.1 Secure Storage (Tokens)

`FlutterSecureStorage` for sensitive data:
- `access_token` — JWT access token
- `refresh_token` — JWT refresh token
- `user_id` — Numeric user ID
- `user_email` — User email

### 11.2 Shared Preferences (Settings)

`SharedPreferences` for non-sensitive data:
- `language_preference` — Selected language code (default: 'en')
- `theme_preference` — Theme mode (default: 'system')
- `onboarding_completed` — Boolean flag

**Files:** `lib/core/storage/secure_storage.dart`, `lib/core/storage/preferences_service.dart`

---

## 12. Conventions & Patterns

### 12.1 Shared Widgets

| Widget | File | Purpose |
|--------|------|---------|
| `StandardAppBar` | `lib/core/widgets/standard_app_bar.dart` | Consistent app bar (green bg, white text, elevation 0) |
| `StandardSliverAppBar` | Same file | Sliver variant (floating, snap by default) |
| `LocalizedText` | `lib/core/widgets/localized_text.dart` | Auto RTL/font/direction text |
| `FollowButton` | `lib/features/main/tabs/poets/widgets/follow_button.dart` | Follow/unfollow toggle (compact/full) |
| `FeedEngagementRow` | `lib/features/feed/widgets/feed_engagement_row.dart` | Like/bookmark/share buttons |
| `CoupletEngagementButtons` | `lib/features/main/tabs/poets/widgets/couplet_engagement_buttons.dart` | Couplet-specific engagement |

### 12.2 Shimmer Loading Pattern

```dart
Shimmer.fromColors(
  baseColor: isDark ? AppColors.surfaceDark : AppColors.shimmerBase,
  highlightColor: isDark ? AppColors.borderDark : AppColors.shimmerHighlight,
  child: // skeleton shapes matching real content
)
```

### 12.3 Error Handling

| Scenario | Handling |
|----------|----------|
| First page fails | Full-screen error with retry button |
| Next page fails | Inline retry widget, existing items stay |
| 401 Unauthorized | Auto token refresh + retry |
| 400 Invalid cursor | Silently reload from first page |
| Network offline | Error state with retry |
| Event send failure | Silently ignored (fire-and-forget) |

### 12.4 Naming Conventions

| Item | Convention | Example |
|------|-----------|---------|
| Files | snake_case | `feed_provider.dart` |
| Classes | PascalCase | `FeedNotifier` |
| Providers | camelCase | `feedProvider` |
| Constants | camelCase | `AppColors.primary` |
| Routes | kebab-case paths | `/main/poets/:publicId` |
| API field names | camelCase | `poetPublicId`, `versesTextArabic` |

### 12.5 Key API Endpoints

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/api/auth/firebase/verify` | POST | Verify Firebase token |
| `/api/auth/refresh` | POST | Refresh JWT |
| `/api/auth/logout` | POST | Logout |
| `/api/auth/me` | GET | Current user profile |
| `/api/feed` | GET | Personalized feed (cursor pagination) |
| `/api/events/batch` | POST | Engagement events |
| `/api/discover` | GET | Discovery bundle |
| `/api/poets` | GET | Poets list (page pagination) |
| `/api/poets/:id` | GET | Poet profile |
| `/api/poets/:id/follow` | POST | Follow poet |
| `/api/poems/:id` | GET | Poem detail |
| `/api/poems/:id/bookmark` | POST | Toggle bookmark |
| `/api/bookmarks/recent` | GET | Recent bookmarks |
| `/api/bookmarks/stats` | GET | Bookmark statistics |
| `/api/search/couplets` | GET | Search couplets |
| `/api/search/autocomplete` | GET | Autocomplete suggestions |
| `/api/languages/active` | GET | Active languages |
| `/api/couplets/:id/generate-image` | POST | Generate image |

### 12.6 Retry & Timeouts

| Config | Value |
|--------|-------|
| Connection Timeout | 30s |
| Receive Timeout | 30s |
| Send Timeout | 30s |
| Image Generation Timeout | 120s |
| Max Retry Attempts | 3 |
| Retry Delay | 2s |
| Discover Cache TTL | 15min |

---

## Assets

```
assets/
├── fonts/
│   └── Jameel Noori Nastaleeq Regular.ttf  (10MB)
├── images/
│   └── logo_image.png                       (118KB)
├── icons/                                    (empty, placeholder)
├── app_icon.png                             (233KB, 1024x1024)
└── sukhan_full_logo.png                     (331KB)
```

---

*Last updated: March 2026*
