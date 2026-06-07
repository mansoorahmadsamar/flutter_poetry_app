# Poetry Backend API - Flutter Mobile App Documentation

**Version:** 1.8.0
**Last Updated:** May 15, 2026
**Base URL (Production):** `https://api.poetry.com`
**Base URL (Development):** `https://dev-api.poetry.com`
**Base URL (Local):** `http://localhost:8081`

---

## Recent Updates (December 2025 - May 2026)

### Sign in with Apple (via Firebase) ⭐ NEW (May 15, 2026)

Required for **App Store guideline 4.8** — any app offering a third-party login
must offer Sign in with Apple as an equivalent option. The backend already
supports this **with no new endpoint**: Flutter swaps the Apple credential for
a Firebase ID token (using `firebase_auth`) and posts it to the existing
`POST /api/auth/firebase/verify` endpoint, exactly like the Google flow.

**What changed on the backend:**
- `User.provider` now stores the actual underlying provider — `"apple"`,
  `"google"`, `"password"` — instead of a generic `"firebase"`. Existing rows
  get upgraded the next time they sign in.
- The Firebase token's `firebase.sign_in_provider` claim is logged on every
  verify so you can audit Apple vs. Google traffic in server logs.

**Account linking by email:** if a user previously signed in with Google using
`mansoor@gmail.com` and later signs in with Apple choosing **Share My Email**,
they land on the **same account** (no duplicate created). If they pick
**Hide My Email**, Apple returns a private relay address
(`xyz@privaterelay.appleid.com`) — that gets a **separate account** (this is by
Apple's design, not a bug).

**Flutter side:** see [§1.6 Sign in with Apple (via Firebase)](#16-sign-in-with-apple-via-firebase)
for the complete integration: Apple Developer Portal + Firebase Console +
Xcode + Dart code + Apple's UI prominence requirements.

---

### Guest Browsing API (Anonymous, No Login Required) ⭐ NEW (May 15, 2026)

Required for **App Store guideline 5.1.1(v)** — apps may not force users to
register before browsing non-account features. New `/api/guest/**` namespace
that exposes a **read-only**, **rate-limited**, **cached** subset of the
catalog with no authentication required.

**Endpoints (all GET, all anonymous):**
- `GET /api/guest/discover` — featured + trending bundle, single call
- `GET /api/guest/poems` / `GET /api/guest/poems/{publicId}` — list + detail
- `GET /api/guest/poems/search?q=` — Elasticsearch search
- `GET /api/guest/poets` / `GET /api/guest/poets/{publicId}` — list + detail
- `GET /api/guest/poets/search?q=` — Elasticsearch search
- `GET /api/guest/couplets/trending` — windowed trending couplets

**What guests can NOT do:** like, bookmark, follow, comment, react, generate
images, save to collections, see personalized "For You" feed. Tapping any of
those should prompt sign-in. Any non-GET method on `/api/guest/**` returns 403.

**Hardening (matters because the catalog is the business):**
- Pagination is **clamped to max 5 pages × 20 items** per call → no deep scrape
- IP rate limit: **60 req/min + 1000 req/hour per IP** (Bucket4j, behind nginx
  via `X-Forwarded-For`). 429 + `Retry-After` header on exceed.
- Discover bundle is **cached on Redis for 15 min per language**; trending
  couplets cached 5 min. Repeated scraper sweeps hit cache, not Postgres.
- Slim DTOs strip `isLiked`, `isBookmarked`, `reactions.userReaction` and any
  "for you" personalization signal — anonymous responses can't leak the
  shape of authenticated features.

**Flutter side:** see [§21 Guest Browsing API](#21-guest-browsing-api-anonymous)
for endpoint contracts, response shapes, and the "Sign in to continue" prompt
pattern for gated actions.

---

### In-App Account Deletion ⭐ NEW (May 7, 2026)

New endpoint `DELETE /api/users/me` for App Store Guideline 5.1.1(v) compliance.
Body: `{"confirmation":"DELETE"}`. Hard-deletes the user, all personal engagement
(bookmarks, likes, follows, reactions, notifications, comments) and the Firebase
user; **retains** uploaded poems, claimed poet personas, and generated poetry
images by setting their owner FK to `null`. See [§3.4 Delete User Profile](#34-delete-user-profile)
for the full contract and Flutter integration checklist.

### Poem Detail: Clean Response + Live Reaction Counts ⭐ BREAKING (March 30, 2026)

**What changed in `GET /api/poems/{publicId}`:**

| Change | Before | After |
|---|---|---|
| `isLikedByCurrentUser` field | ✅ present | ❌ **removed** — use `reactions.userReaction != null` |
| `couplets[n].isLiked` field | ✅ present | ❌ **removed** — use `couplets[n].reactions.userReaction != null` |
| `contents` array | All 3 languages always | **Filtered to requested `?lang=`** — `?lang=ur` returns only Urdu content |
| `reactions.total` / `reactions.byType` | Always `0` / `null` (stale denormalized) | ✅ **Live counts from DB** |
| Duplicate contents bug | ×3 duplicates per language | ✅ Fixed — each content appears once |

**Migration:**
```dart
// Before
final liked = poem.isLikedByCurrentUser == true;
final coupletLiked = couplet.isLiked == true;

// After
final liked = poem.reactions.userReaction != null;
final coupletLiked = couplet.reactions.userReaction != null;
```

**`?lang=` now filters `contents[]`:**
- `?lang=ur` → only `[{languageCode: "ur", script: "ARABIC", ...}]`
- `?lang=en` → only `[{languageCode: "en", script: "ROMAN", ...}]`
- No `lang` param → all 3 language variants returned (original behavior)

**Couplets are unchanged** — `couplets[]` always contains Urdu/ARABIC verses regardless of `?lang=`. Only `contents[]` is filtered.

---

### Poem Detail: Full Poet Card + Per-Couplet Engagement ⭐ NEW (March 29, 2026)

**What's New in `GET /api/poems/{publicId}`:**
- **Full poet profile card** — `data.poet` now contains the complete `PoetSummaryResponse` object: profile image, short bio, birth/death years, poem count, view count, gender, era, country with flag emoji + CDN URL, featured/trending flags, and tag slugs. The flat `poetName` / `poetPublicId` fields are still present for backward compatibility.
- **Per-couplet engagement data** — `data.couplets` array is now populated for all structured poetry types (`requiresStructuredParsing: true`, e.g. GHAZAL). Each couplet includes:
  - `reactions.total` + `reactions.byType` (live counts from DB)
  - `reactions.userReaction` — which of the 10 reactions the authenticated user has left (`null` for anonymous)
  - `isBookmarked` — `true`/`false`/`null` (null = anonymous user)
  - `likeCount`, `bookmarkCount`, `shareCount`
  - `verses` — the two verse lines of the couplet
  - `coupletType` — MATLA / MAQTA / REGULAR with localized `coupletTypeName`

**Performance:** Couplet engagement uses 3 batch queries regardless of couplet count (user reactions, live reaction counts, bookmarks) — no N+1.

**Breaking Changes:** None at this point. Fields were additive. See March 30, 2026 entry for breaking changes.

**See updated Section 4.2 for the complete response shape.**

---

### Unified Reactions System (Replaces Likes) ⭐ NEW (March 2026)

**What's New:**
- **10 culturally-relevant reaction types** including Urdu mushaira reactions: WAH_WAH, SUBHAN_ALLAH, MAZA_AA_GAYA, KYA_BAAT_HAI + universal reactions: LOVE, FIRE, SAD, DEEP, RELATABLE, BEAUTIFUL
- **Unified API**: Single `POST /api/{targetType}/{publicId}/react` endpoint works for poems, couplets, poet images, and generated images
- **Toggle behavior**: Same reaction = remove, different reaction = change, no reaction = add
- **Rich reaction data**: Every content response now includes `reactions: { total, byType, userReaction }` breakdown
- **Backward compatible**: Old `/like` endpoints still work (send LOVE reaction internally). `likeCount` field preserved. `isLiked` has been removed — use `reactions.userReaction != null` instead.
- **Reaction types endpoint**: `GET /api/reactions/types` returns all 10 types with emoji, Urdu label, and English label

**Breaking Changes:** `isLiked` and `isLikedByCurrentUser` removed (March 30, 2026). Use `reactions.userReaction != null` instead.

**Migration recommended:** Update Flutter to use the new reaction endpoints and display reaction picker instead of simple like button.

**See Section 19 for full documentation.**

---

### Feed Engine v2 — 9 Behavior-Design Improvements ⭐ NEW (March 2026)

**What's New:**
- ✅ **Following Feed Source**: Content from followed poets now appears in feed with `reason: "FOLLOWING"` (20% weight, capped at 40% of page)
- ✅ **Engagement Velocity Scoring**: Recent viral content now outranks old high-count content. Items created in last 24h with rapid engagement get boosted
- ✅ **Negative Signal Learning**: `skip_fast` and `hide` events now persistently reduce a poet's content in the user's feed across sessions
- ✅ **Variable Rewards (Delighter)**: Unexpected "hidden gem" content injected at positions 8-12 to prevent feed predictability
- ✅ **Display Hints (reserved)**: FeedItem fields `displayMode`, `primaryAction`, `autoExpandFirstVerse` are defined but **not currently sent** — reserved for future Flutter integration. When enabled, they will drive content-type-specific card rendering
- ✅ **Session Momentum**: Feed scoring weights shift as users scroll deeper (WARMUP → EXPLORATION → DEEP phases)
- ✅ **Social Proof Layer**: New `socialContext` object on FeedItem with `trendingLabel`, `velocityLabel`, `totalReactions` — only appears on items with 10+ likes (null for low-engagement content)
- ✅ **Smart Pull-to-Refresh**: New `refresh=true` param returns only new items without reshuffling the feed. New `newCount` field in response
- ✅ **Content Exhaustion Prevention**: After 200+ items viewed, hidden gem sources and time capsule sources (resurfaced bookmarks) activate progressively

**Breaking Changes:** None. All changes are additive. Existing Flutter code works without modification.

**New fields to handle:** See updated Section 17.3 for `socialContext`, `newCount`. Display hint fields (`displayMode`, `primaryAction`, `autoExpandFirstVerse`) are reserved and not currently sent.

**See Section 17 for full documentation.**

---

### Personalized Feed ("For You" Tab) (February 2026)

**What's New:**
- ✅ **Infinite-scroll personalized feed**: `GET /api/feed?lang=ur&cursor=<cursor>&limit=20`
- ✅ **Mixed content types in one response**: Couplets, Poems, Poet Spotlights, and Poet Gallery Images interleaved intelligently
- ✅ **Cursor-based pagination**: No offset drift, stable ordering per session, tamper-proof HMAC-signed cursor
- ✅ **Pull-to-refresh creates a new session**: New ordering on every fresh open — never feels stale
- ✅ **Feed events endpoint**: `POST /api/events/batch` — send impressions, dwell time, likes, skips to improve personalization
- ✅ **Session-aware deduplication**: Items shown on page 1 never reappear on page 2+ within the same session
- ✅ **Event idempotency**: Include an `eid` UUID on each event to safely retry without duplicates
- ✅ **Authentication required** — the feed is fully personalized; pass your JWT `Authorization` header

**See Section 17 for full documentation.**

---

### App Content (About App, Privacy Policy, etc.) ⭐ NEW (February 2026)

**What's New:**
- ✅ **List content pages**: `GET /api/app-content?lang=en` — all active content for a language (for Flutter settings screen)
- ✅ **Single page by key**: `GET /api/app-content/{contentKey}?lang=en` — load e.g. `PRIVACY_POLICY` on demand
- ✅ **No auth required** — public endpoints, call without a token
- ✅ **Multilingual** — same keys available in `en`, `ur`, `hi` etc., controlled by `?lang=` param
- ✅ **Admin-managed** — content updated via admin portal without a code deployment

**Standard content keys**: `ABOUT_APP`, `PRIVACY_POLICY`, `TERMS_OF_SERVICE`, `CONTACT_US`, `FAQ`

**See Section 16 for full documentation.**

---

### Poet Gallery Image Engagement ⭐ NEW (February 2026)

**What's New:**
- ✅ **Like / Unlike**: `POST /api/poetry-images/{imageId}/like` — toggle like on poet gallery images
- ✅ **Share Tracking**: `POST /api/poetry-images/{imageId}/share?lang=ur` — record share event, returns `shareCount` + `shareText` + `shareImageUrl` for native share sheet
- ✅ **Status Check**: `GET /api/poetry-images/{imageId}/status` — single call for all engagement state (isLiked, isBookmarked, counts)
- ✅ **Unified Bookmark**: `POST /api/poetry-images/{imageId}/bookmark` — now works for both `PoetImage` (gallery) and `GeneratedPoetryImage` publicIds

**See Sections 7.5.10–7.5.12 for full documentation.**

---

### Discover Functionality Enhancement ⭐ NEW (February 2026)

**What's New:**
- ✅ **Unified Discover Bundle Endpoint**: Single API call replaces 6-7 separate calls for discover screen
- ✅ **UI-Ready Responses**: No more placeholder values ("Unknown", "Untitled") - strict null handling
- ✅ **Search Result De-duplication**: Eliminates duplicate verses with different romanizations
- ✅ **Enhanced Autocomplete**: New structured `/api/search/suggest` endpoint with flat sorted responses
- ✅ **Result Counts**: Instant count display ("Poets (5)") without client-side array counting
- ✅ **Score Sanitization**: No more NaN values in search results
- ✅ **Performance Optimization**: 15-minute caching, database indexes, and optimized queries

**Key Benefits:**
1. **Faster Load Times**: Discover screen loads in single API call (500ms with cache, <2s without)
2. **Better UX**: No flicker from placeholder text, smooth loading experience
3. **Cleaner Code**: Single endpoint for all discover content, unified response format
4. **Improved Search**: De-duplicated results, structured autocomplete, trending searches

**New Endpoints:**
- `GET /api/discover?lang=ur` - Complete discover bundle (trending, featured, recommended, poets, categories)
- `GET /api/search/suggest?q=na&lang=ur&limit=10` - Structured autocomplete suggestions

**See Section 10 for detailed documentation.**

---

### Bookmark System Enhancement (Phase 1, 2 & 3) ⭐ NEW

**What's New:**
- ✅ **Phase 1 & 2**: Language-aware bookmarks for poems, couplets, and images
- ✅ **Phase 3**: Unified Bookmark API - Single interface for all bookmark types

#### Phase 1 & 2: Language Context Preservation

**Key Features:**
1. **Language-Aware Bookmarks**: All bookmark endpoints (poems, couplets, images) now accept a `lang` query parameter
2. **Multi-Language Bookmark Display**: Bookmarks preserve the language context in which they were created
3. **Image Poetry Bookmarks**: New bookmark system for generated poetry images (separate from collections)
4. **Cross-Language Filtering**: Filter bookmarks by language or view all in mixed languages

**Endpoints Added (Phase 1 & 2):**
- `POST /api/poetry-images/{imageId}/bookmark?lang=ur` - Bookmark generated image
- `GET /api/users/me/image-bookmarks?lang=ur` - Get bookmarked images with language filter
- `GET /api/poetry-images/{imageId}/is-bookmarked` - Check bookmark status
- `POST /api/poems/{publicId}/bookmark?lang=ur` - Updated with language parameter
- `POST /api/couplets/{coupletPublicId}/bookmark?lang=ur` - Updated with language parameter

#### Phase 3: Unified Bookmark API ⭐ NEW

**What is it?**
A single, consolidated API that provides access to all bookmark types (poems, couplets, images) through unified endpoints. No more switching between different endpoints for different content types!

**Key Features:**
1. **Unified Response Format**: All bookmarks return the same structure with type-specific fields
2. **Mixed Content Streams**: Get recent bookmarks across all types in a single call
3. **Type Filtering**: Filter by specific content type (poems-only, couplets-only, images-only)
4. **Cross-Content Search**: Search across all bookmarked content in one query
5. **Aggregated Statistics**: Get comprehensive stats across all bookmark types

**New Unified Endpoints (Phase 3):**
- `GET /api/bookmarks/recent` - Recent bookmarks across all types (mixed feed)
- `GET /api/bookmarks/poems` - Poem bookmarks only (filtered view)
- `GET /api/bookmarks/couplets` - Couplet bookmarks only (filtered view)
- `GET /api/bookmarks/images` - Image bookmarks only (filtered view)
- `GET /api/bookmarks/search?query=محبت` - Search across all bookmarks
- `GET /api/bookmarks/stats` - Comprehensive bookmark statistics

**Why Use Unified API?**
- **Simpler App Architecture**: One controller for all bookmark screens
- **Better UX**: Show users all their bookmarks in one feed
- **Efficient**: Fewer API calls, better performance
- **Flexible**: Easy to add new content types in the future

**Migration Notes for Flutter Developers:**
- All existing bookmark calls will continue to work (backward compatible)
- To support multi-language bookmarks, pass the current app language when calling bookmark endpoints
- Use Phase 3 unified endpoints for new bookmark screens (recommended)
- Legacy endpoints (`/api/users/me/couplets/bookmarked`, etc.) still work but unified API is preferred

---

## Table of Contents

### 1. Overview & Getting Started
- [1.1 Introduction](#11-introduction)
- [1.2 Architecture Overview](#12-architecture-overview)
- [1.3 Authentication Flow](#13-authentication-flow)
- [1.4 Response Format](#14-response-format)
- [1.5 Environment Configuration](#15-environment-configuration)
- [1.6 Error Handling](#16-error-handling)

### 2. Authentication & Authorization
- [2.1 Overview](#21-overview-authentication)
- [2.2 Firebase Authentication](#22-firebase-authentication)
- [2.3 Admin Login](#23-admin-login)
- [2.4 Token Refresh](#24-token-refresh)
- [2.5 Logout](#25-logout)
- [2.6 Get Current User](#26-get-current-user)
- [2.7 Sign in with Apple (via Firebase)](#16-sign-in-with-apple-via-firebase) ⭐ NEW

### 3. User Profile Management
- [3.1 Overview](#31-overview-user-profile)
- [3.2 Get User Profile](#32-get-user-profile)
- [3.3 Update User Profile](#33-update-user-profile)
- [3.4 Delete User Profile](#34-delete-user-profile)
- [3.5 User Interests](#35-user-interests)
  - [3.5.1 Get User Interests](#351-get-user-interests)
  - [3.5.2 Add Interest](#352-add-interest)
  - [3.5.3 Remove Interest](#353-remove-interest)
  - [3.5.4 Update Interests](#354-update-interests)
- [3.6 User Engagement](#36-user-engagement)
  - [3.6.1 Track Activity](#361-track-activity)
  - [3.6.2 Get User Statistics](#362-get-user-statistics)
  - [3.6.3 Get Reading Analytics](#363-get-reading-analytics)
  - [3.6.4 Get Recommendations](#364-get-recommendations)

### 4. Poet Discovery & Browse
- [4.1 Overview](#41-overview-poets)
- [4.2 Browse Poets](#42-browse-poets)
  - [4.2.1 Get All Poets](#421-get-all-poets)
  - [4.2.2 Get Featured Poets](#422-get-featured-poets)
  - [4.2.3 Get Trending Poets](#423-get-trending-poets)
  - [4.2.4 Get Poets by Gender](#424-get-poets-by-gender)
  - [4.2.5 Get Poets by Era](#425-get-poets-by-era)
  - [4.2.6 Get Poets by Tag](#426-get-poets-by-tag)
  - [4.2.7 Search Poets](#427-search-poets)
- [4.3 Poet Rankings](#43-poet-rankings)
  - [4.3.1 Top Poets by Poem Count](#431-top-poets-by-poem-count)
  - [4.3.2 Most Viewed Poets](#432-most-viewed-poets)
- [4.4 Poet Profile](#44-poet-profile)
  - [4.4.1 Get Complete Profile](#441-get-complete-profile)
  - [4.4.2 Get Poet Gallery](#442-get-poet-gallery)
  - [4.4.3 Get Poet Books](#443-get-poet-books)
  - [4.4.4 Get Poet Videos](#444-get-poet-videos)
  - [4.4.5 Get Poet Facts](#445-get-poet-facts)
- [4.5 Poet Follow System](#45-poet-follow-system)
  - [4.5.1 Follow Poet](#451-follow-poet)
  - [4.5.2 Unfollow Poet](#452-unfollow-poet)
  - [4.5.3 Get Following List](#453-get-following-list)
  - [4.5.4 Check Follow Status](#454-check-follow-status)
- [4.6 Use Cases & Workflows](#46-use-cases-workflows)

### 5. Poem Discovery & Content
- [5.1 Overview](#51-overview-poems)
- [5.2 Browse Poems](#52-browse-poems)
  - [5.2.1 Get All Poems](#521-get-all-poems)
  - [5.2.2 Get Poems by Poet](#522-get-poems-by-poet)
  - [5.2.3 Get Poems by Category](#523-get-poems-by-category)
  - [5.2.4 Get Poems by Language](#524-get-poems-by-language)
- [5.3 Search](#53-search)
  - [5.3.1 Search Poems](#531-search-poems)
  - [5.3.2 Search Verses](#532-search-verses)
- [5.4 Poem Details](#54-poem-details)
  - [5.4.1 Get Poem by ID](#541-get-poem-by-id) ⭐ UPDATED
  - [5.4.1.1 Field Reference — poet Object](#4211-field-reference--poet-object)
  - [5.4.1.2 Field Reference — couplets Array](#4212-field-reference--couplets-array)
  - [5.4.1.3 Reacting to a Couplet](#4213-flutter--reacting-to-a-couplet)
  - [5.4.1.4 Dart Model Additions](#4214-flutter--dart-model-additions)
  - [5.4.2 Get Poem Content](#542-get-poem-content)
- [5.5 Engagement](#55-engagement)
  - [5.5.1 Like Poem](#551-like-poem)
  - [5.5.2 Bookmark Poem](#552-bookmark-poem)
  - [5.5.3 Get Like/Bookmark Status](#553-get-likebookmark-status)
- [5.6 User Collections](#56-user-collections)
  - [5.6.1 Get Bookmarked Poems](#561-get-bookmarked-poems)
- [5.7 Use Cases & Workflows](#57-use-cases-workflows)

### 6. Couplet Engagement System
- [6.1 Overview](#61-overview-couplets)
- [6.2 Couplet Retrieval](#62-couplet-retrieval)
  - [6.2.1 Get Couplets by Poem](#621-get-couplets-by-poem)
  - [6.2.2 Get Couplet Detail](#622-get-couplet-detail)
- [6.3 Engagement Actions](#63-engagement-actions)
  - [6.3.1 Like Couplet](#631-like-couplet)
  - [6.3.2 Bookmark Couplet](#632-bookmark-couplet)
  - [6.3.3 Share Couplet](#633-share-couplet)
  - [6.3.4 Get Public Share Link](#634-get-public-share-link)
- [6.4 User Collections](#64-user-collections)
  - [6.4.1 Get Liked Couplets](#641-get-liked-couplets)
  - [6.4.2 Get Bookmarked Couplets](#642-get-bookmarked-couplets)
- [6.5 Analytics & Discovery](#65-analytics-discovery)
  - [6.5.1 Most Liked Couplets](#651-most-liked-couplets)
  - [6.5.2 Most Shared Couplets](#652-most-shared-couplets)
  - [6.5.3 Trending Couplets](#653-trending-couplets)
  - [6.5.4 Couplet Analytics (NEW)](#654-couplet-analytics-new)
- [6.6 Use Cases & Workflows](#66-use-cases-workflows)

### 7. Image Poetry Generation
- [7.1 Overview](#71-overview-image-poetry)
- [7.2 Template Management](#72-template-management)
  - [7.2.1 Get Templates](#721-get-templates)
  - [7.2.2 Get Template by ID](#722-get-template-by-id)
  - [7.2.3 Get Popular Templates (NEW)](#723-get-popular-templates-new)
  - [7.2.4 Get Template Statistics (NEW)](#724-get-template-statistics-new)
- [7.3 Image Generation](#73-image-generation)
  - [7.3.1 Generate Image for Couplet](#731-generate-image-for-couplet)
  - [7.3.2 Upload Custom Background](#732-upload-custom-background)
  - [7.3.3 Get Couplet Images](#733-get-couplet-images)
- [7.4 Upload Custom Background](#74-upload-custom-background)
- [7.5 User Collections & Bookmarks](#75-user-collections-bookmarks)
  - [7.5.1 Save Image to Collection](#751-save-image-to-collection)
  - [7.5.2 Get Saved Images](#752-get-saved-images)
  - [7.5.3 Toggle Favorite](#753-toggle-favorite)
  - [7.5.4 Remove from Collection](#754-remove-from-collection)
  - [7.5.5 Get Collection Names](#755-get-collection-names)
  - [7.5.6 Get Collection Statistics](#756-get-collection-statistics)
  - [7.5.7 Toggle Image Bookmark (NEW)](#757-toggle-image-bookmark-new)
  - [7.5.8 Get Bookmarked Images (NEW)](#758-get-bookmarked-images-new)
  - [7.5.9 Check Image Bookmark Status (NEW)](#759-check-image-bookmark-status-new)
  - [7.5.10 Like / Unlike Poet Gallery Image (NEW)](#7510-like--unlike-poet-gallery-image-new)
  - [7.5.11 Share Poet Gallery Image (NEW)](#7511-share-poet-gallery-image-new)
  - [7.5.12 Get Poet Gallery Image Status (NEW)](#7512-get-poet-gallery-image-status-new)

### 8. Book Management
- [8.1 Overview](#81-overview-books)
- [8.2 Book Search & Discovery](#82-book-search-discovery)
  - [8.2.1 Global Book Search](#821-global-book-search)
  - [8.2.2 Get Book Statistics](#822-get-book-statistics)
  - [8.2.3 Search Books by Poet](#823-search-books-by-poet)
  - [8.2.4 Download Book](#824-download-book)
- [8.3 Use Cases & Workflows](#83-use-cases-workflows)

### 8.5 Unified Bookmark API (Phase 3) ⭐ UPDATED
- [8.5.1 Overview - Unified Bookmarks](#851-overview-unified-bookmarks)
- [8.5.2 UnifiedBookmarkResponse — Field Reference](#852-unifiedbookmarkresponse--complete-field-reference)
- [8.5.3 Get Recent Bookmarks (All Types)](#853-get-recent-bookmarks-all-types)
- [8.5.4 Get Poem Bookmarks](#854-get-poem-bookmarks)
- [8.5.5 Get Couplet Bookmarks](#855-get-couplet-bookmarks)
- [8.5.6 Get Image Bookmarks](#856-get-image-bookmarks)
- [8.5.7 Update Bookmark Notes ⭐ NEW](#857-update-bookmark-notes--new)
- [8.5.8 Search Bookmarks](#858-search-bookmarks)
- [8.5.9 Get Bookmark Statistics](#859-get-bookmark-statistics)
- [8.5.10 Flutter Implementation Guide](#8510-flutter-implementation-guide)

### 9. Comments System
- [9.1 Overview](#91-overview-comments)
- [9.2 Comment Operations](#92-comment-operations)
  - [9.2.1 Create Comment](#921-create-comment)
  - [9.2.2 Get Comments](#922-get-comments)
  - [9.2.3 Delete Comment](#923-delete-comment)
  - [9.2.4 Get Comment Count](#924-get-comment-count)
- [9.3 Use Cases & Workflows](#93-use-cases-workflows)

### 10. Global Search
- [10.1 Overview](#101-overview-search)
- [10.2 Unified Search](#102-unified-search)
- [10.3 Quick Search](#103-quick-search)
- [10.4 Couplet Search](#104-couplet-search)
- [10.5 Autocomplete](#105-autocomplete)
  - [10.5.1 Structured Autocomplete (Suggest) ⭐ NEW](#1051-structured-autocomplete-suggest-new)
  - [10.5.2 Discover Bundle ⭐ NEW](#1052-discover-bundle-new)
- [10.6 Recommendations](#106-recommendations)
- [10.7 Search Analytics (NEW)](#107-search-analytics-new)
  - [10.7.1 Related Searches (NEW)](#1071-related-searches-new)
  - [10.7.2 Trending Searches (NEW)](#1072-trending-searches-new)
- [10.8 Use Cases & Workflows](#108-use-cases-workflows)

### 11. Categories, Tags & Metadata
- [11.1 Categories](#111-categories)
  - [11.1.1 Get All Categories](#1111-get-all-categories)
  - [11.1.2 Get Root Categories](#1112-get-root-categories)
  - [11.1.3 Get Category by ID](#1113-get-category-by-id)
  - [11.1.4 Get Category by Slug](#1114-get-category-by-slug)
  - [11.1.5 Get Category Children](#1115-get-category-children)
- [11.2 Tags](#112-tags)
  - [11.2.1 Get All Tags](#1121-get-all-tags)
  - [11.2.2 Get Tags by Type](#1122-get-tags-by-type)
  - [11.2.3 Get Tag by Slug](#1123-get-tag-by-slug)
  - [11.2.4 Get Tag by Public ID](#1124-get-tag-by-public-id)
- [11.3 Geography](#113-geography)
  - [11.3.1 Get Countries](#1131-get-countries)
  - [11.3.2 Get Cities](#1132-get-cities)
  - [11.3.3 Get Cities by Country](#1133-get-cities-by-country)
- [11.4 Languages](#114-languages)
  - [11.4.1 Get All Languages](#1141-get-all-languages)
  - [11.4.2 Get Language by Code](#1142-get-language-by-code)
  - [11.4.3 Get Active Languages (NEW)](#1143-get-active-languages-new)
  - [11.4.4 Dictionary Sync & Stats (NEW)](#1144-dictionary-sync-stats-new)

### 12. System & Health
- [12.1 Health Check](#121-health-check)
- [12.2 Detailed Health Check](#122-detailed-health-check)
- [12.3 Readiness Check](#123-readiness-check)
- [12.4 Liveness Check](#124-liveness-check)

### 13. Reference
- [13.1 Enum Values](#131-enum-values)
- [13.2 HTTP Status Codes](#132-http-status-codes)
- [13.3 Pagination Format](#133-pagination-format)
- [13.4 Error Response Format](#134-error-response-format)

### 14. Best Practices & Guidelines
- [14.1 Authentication Best Practices](#141-authentication-best-practices)
- [14.2 Pagination Best Practices](#142-pagination-best-practices)
- [14.3 Search Best Practices](#143-search-best-practices)
- [14.4 Image Handling](#144-image-handling)
- [14.5 Multi-Language Support](#145-multi-language-support)
- [14.6 Error Handling](#146-error-handling)
- [14.7 Performance Optimization](#147-performance-optimization)

### 15. Complete Workflows
- [15.1 User Onboarding Flow](#151-user-onboarding-flow)
- [15.2 Content Discovery Flow](#152-content-discovery-flow)
- [15.3 Image Poetry Creation Flow](#153-image-poetry-creation-flow)
- [15.4 Sharing & Social Flow](#154-sharing-social-flow)

### 16. App Content (Settings Pages) ⭐ NEW
- [16.1 Overview](#161-overview-app-content)
- [16.2 Get All Active Content](#162-get-all-active-content)
- [16.3 Get Single Page by Key](#163-get-single-page-by-key)
- [16.4 AppContentResponse — Field Reference](#164-appcontentresponse--field-reference)
- [16.5 Flutter Implementation Guide](#165-flutter-implementation-guide)

### 17. Personalized Feed ("For You" Tab) ⭐ UPDATED
- [17.1 Overview](#171-overview-personalized-feed)
- [17.2 Get Feed Page](#172-get-feed-page)
- [17.3 FeedItem — Field Reference](#173-feeditem--field-reference)
- [17.3a Display Hints](#173a-display-hints)
- [17.3b Social Context](#173b-social-context)
- [17.4 Content Type Data Fields](#174-content-type-data-fields)
  - [17.4.1 COUPLET](#1741-couplet-contentdata)
  - [17.4.2 POEM](#1742-poem-contentdata)
  - [17.4.3 POET_SPOTLIGHT](#1743-poet_spotlight-contentdata)
  - [17.4.4 POET_IMAGE](#1744-poet_image-contentdata)
- [17.5 Report Feed Events (POST /api/events/batch)](#175-report-feed-events)
- [17.6 Cursor Pagination Guide](#176-cursor-pagination-guide)
- [17.7 Flutter Implementation Guide](#177-flutter-implementation-guide)

### 18. Hashtags & Discovery ⭐ NEW
- [18.1 Tags vs Hashtags](#181-tags-vs-hashtags)
- [18.2 All Hashtags (Paginated List)](#182-all-hashtags-paginated-list)
- [18.3 Trending Hashtags](#183-trending-hashtags)
- [18.4 Hashtag Stats](#184-hashtag-stats)
- [18.5 Single Hashtag Metadata](#185-single-hashtag-metadata)
- [18.6 Poems by Hashtag](#186-poems-by-hashtag)
- [18.7 Couplets by Hashtag](#187-couplets-by-hashtag)
- [18.8 Images by Hashtag](#188-images-by-hashtag)
- [18.9 Poets by Hashtag](#189-poets-by-hashtag)
- [18.10 Books by Hashtag](#1810-books-by-hashtag)
- [18.11 Videos by Hashtag](#1811-videos-by-hashtag)
- [18.12 Filter Search by Hashtag](#1812-filter-search-by-hashtag)
- [18.13 HashtagDto Reference](#1813-hashtagdto-reference)
- [18.11 Flutter Implementation Guide](#1811-flutter-implementation-guide)

### 19. Unified Reactions System ⭐ NEW
- [19.1 Overview — Reactions vs Likes](#191-overview--reactions-vs-likes)
- [19.2 Available Reaction Types](#192-available-reaction-types)
- [19.3 Get Reaction Types (Public)](#193-get-reaction-types-public)
- [19.4 React to Content](#194-react-to-content)
- [19.5 Remove Reaction](#195-remove-reaction)
- [19.6 Reaction Data in Responses](#196-reaction-data-in-responses)
  - [19.6.1 ReactionSummaryDto Reference](#1961-reactionsummarydto-reference)
  - [19.6.2 Poems](#1962-poems)
  - [19.6.3 Couplets](#1963-couplets)
  - [19.6.4 Poet Images](#1964-poet-images)
  - [19.6.5 Feed Items](#1965-feed-items)
- [19.7 Backward Compatibility](#197-backward-compatibility)
- [19.8 Flutter Implementation Guide](#198-flutter-implementation-guide)
  - [19.8.1 Reaction Picker Widget](#1981-reaction-picker-widget)
  - [19.8.2 Reaction Summary Display](#1982-reaction-summary-display)
  - [19.8.3 API Service Integration](#1983-api-service-integration)
  - [19.8.4 Migration from Likes](#1984-migration-from-likes)

### 21. Guest Browsing API (Anonymous) ⭐ NEW
- [21.1 Why It Exists & What's Different](#211-why-it-exists--whats-different)
- [21.2 Endpoint Summary](#212-endpoint-summary)
- [21.3 Pagination Caps, Rate Limits, Caching](#213-pagination-caps-rate-limits-caching)
- [21.4 GET /api/guest/discover](#214-get-apiguestdiscover)
- [21.5 GET /api/guest/poems](#215-get-apiguestpoems)
- [21.6 GET /api/guest/poems/{publicId}](#216-get-apiguestpoemspublicid)
- [21.7 GET /api/guest/poems/search](#217-get-apiguestpoemssearch)
- [21.8 GET /api/guest/poets](#218-get-apiguestpoets)
- [21.9 GET /api/guest/poets/{publicId}](#219-get-apiguestpoetspublicid)
- [21.10 GET /api/guest/poets/search](#2110-get-apiguestpoetssearch)
- [21.11 GET /api/guest/couplets/trending](#2111-get-apiguestcoupletstrending)
- [21.12 Response DTO Reference](#2112-response-dto-reference)
- [21.13 Flutter Integration Guide](#2113-flutter-integration-guide)

### Appendix
- [A. Flutter Code Examples](#appendix-a-flutter-code-examples)
- [B. API Endpoints Summary](#appendix-b-api-endpoints-summary)
- [C. Changelog](#appendix-c-changelog)

---

## 1. Overview & Getting Started

### 1.1 Introduction

Welcome to the Poetry Backend API documentation for Flutter mobile applications. This API provides comprehensive access to a rich collection of Urdu, Persian, and Hindi poetry, along with poet biographies, image generation capabilities, and social engagement features.

**Key Features:**
- 📚 **Extensive Poetry Collection**: Browse thousands of poems across multiple languages and genres
- 👤 **Poet Profiles**: Comprehensive biographies, images, books, and videos
- 🔍 **Advanced Search**: Full-text search with Elasticsearch across poems, verses, poets, and categories
- 🎨 **Image Poetry Generation**: Create beautiful poetry images with customizable templates
- 💝 **Couplet-Level Engagement**: Like, bookmark, and share individual couplets
- 📖 **Book Management**: Search and download poetry books with tracking
- 💬 **Comments & Social**: Threaded comments on poems
- 🌍 **Multi-Language**: Urdu, English, Hindi, Arabic, Persian, Punjabi support
- 🔐 **Secure Authentication**: Firebase Auth + JWT tokens

**API Statistics:**
- **120+ Endpoints** across 16 major categories
- **Multi-language support** for UI and content (6 languages)
- **Real-time analytics** and recommendations
- **CloudFront CDN** for fast global delivery
- **Comprehensive social features** (follow, like, bookmark, share)

---

### 1.2 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  ┌────────────┐  ┌────────────┐  ┌─────────────────────┐   │
│  │   Auth     │  │   Home     │  │   Poet Profile      │   │
│  │  Service   │  │  Discovery │  │   Poem Reader       │   │
│  └──────┬─────┘  └──────┬─────┘  └──────────┬──────────┘   │
│         │               │                     │              │
└─────────┼───────────────┼─────────────────────┼──────────────┘
          │               │                     │
          ▼               ▼                     ▼
    ┌─────────────────────────────────────────────────┐
    │         Spring Boot REST API (Port 8080)        │
    │                                                  │
    │  ┌──────────────┐  ┌──────────────────────┐   │
    │  │ Auth Filter  │  │  JWT Validation      │   │
    │  └──────────────┘  └──────────────────────┘   │
    │                                                  │
    │  ┌────────────────────────────────────────┐   │
    │  │         Controllers Layer               │   │
    │  │  - PoetController                       │   │
    │  │  - PoemController                       │   │
    │  │  - CoupletController (NEW)              │   │
    │  │  - ImagePoetryController (NEW)          │   │
    │  │  - BookController (NEW)                 │   │
    │  │  - CommentController (NEW)              │   │
    │  └────────────────────────────────────────┘   │
    │                                                  │
    │  ┌────────────────────────────────────────┐   │
    │  │         Service Layer                   │   │
    │  │  - Business Logic                       │   │
    │  │  - Data Transformation                  │   │
    │  │  - Caching (Redis - future)             │   │
    │  └────────────────────────────────────────┘   │
    │                                                  │
    │  ┌────────────────────────────────────────┐   │
    │  │         Repository Layer                │   │
    │  │  - JPA Repositories                     │   │
    │  │  - Custom Queries (JPQL/Native SQL)     │   │
    │  └────────────────────────────────────────┘   │
    └───────────┬──────────────┬──────────┬──────────┘
                │              │          │
                ▼              ▼          ▼
    ┌──────────────┐  ┌───────────────┐  ┌──────────────┐
    │  PostgreSQL  │  │ Elasticsearch │  │  AWS S3 +    │
    │   Database   │  │  Search Index │  │  CloudFront  │
    │              │  │               │  │  (Images)    │
    └──────────────┘  └───────────────┘  └──────────────┘
```

**Technology Stack:**
- **Backend**: Java 21 + Spring Boot 3.5.5
- **Database**: PostgreSQL 15+ with JSONB support
- **Search**: Elasticsearch (with PostgreSQL fallback)
- **Storage**: AWS S3 + CloudFront CDN
- **Authentication**: Firebase Auth + JWT
- **API Style**: RESTful with standardized responses

---

### 1.3 Authentication Flow

All endpoints (except `/api/auth/**` and `/api/health/**`) require authentication.

**Firebase Authentication Flow:**

```
┌──────────────┐
│ Flutter App  │
└──────┬───────┘
       │
       │ 1. User signs in with Firebase
       │    (Google, Email, Phone, etc.)
       ▼
┌──────────────────┐
│  Firebase Auth   │
│  Returns ID Token│
└──────┬───────────┘
       │
       │ 2. Send Firebase ID Token to backend
       │    POST /api/auth/firebase/verify
       ▼
┌─────────────────────────────────────────┐
│  Backend Verifies Token with Firebase  │
│  Creates/Updates User in Database      │
│  Generates JWT Access + Refresh Tokens │
└──────────┬──────────────────────────────┘
           │
           │ 3. Returns JWT tokens
           ▼
     ┌─────────────────┐
     │ Flutter App     │
     │ Stores Tokens   │
     │ in Secure Store │
     └─────────┬───────┘
               │
               │ 4. Include in all API calls
               │    Authorization: Bearer <access_token>
               ▼
        ┌──────────────────┐
        │  API Endpoints   │
        │  JWT Validation  │
        └──────────────────┘
```

**Token Lifecycle:**
- **Access Token**: Valid for 24 hours
- **Refresh Token**: Valid for 30 days
- When access token expires, use refresh token to get new access token

---

### 1.4 Response Format

All API responses follow a standardized format:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description here",
  "data": null
}
```

**Paginated Response:**
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": {
    "content": [...],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 150,
    "totalPages": 8,
    "last": false,
    "first": true
  }
}
```

---

### 1.5 Environment Configuration

**Base URLs by Environment:**

| Environment | Base URL | Description |
|------------|----------|-------------|
| **Local Development** | `http://localhost:8081` | Your local machine |
| **Android Emulator** | `http://10.0.2.2:8081` | Special IP for Android emulator |
| **iOS Simulator** | `http://localhost:8081` | iOS simulator uses localhost |
| **Development Server** | `https://dev-api.poetry.com` | Development environment |
| **Production** | `https://api.poetry.com` | Live production API |

**Flutter Environment Setup:**

```dart
// lib/config/environment.dart
class Environment {
  static const String dev = 'development';
  static const String prod = 'production';
  
  static String get baseUrl {
    switch (const String.fromEnvironment('ENV', defaultValue: dev)) {
      case prod:
        return 'https://api.poetry.com';
      case dev:
        return 'https://dev-api.poetry.com';
      default:
        // For local development
        return Platform.isAndroid
            ? 'http://10.0.2.2:8081'
            : 'http://localhost:8081';
    }
  }
}
```

---

### 1.6 Error Handling

**Common Error Scenarios:**

| Status Code | Scenario | Recommended Action |
|------------|----------|-------------------|
| **401 Unauthorized** | Token expired or invalid | Refresh token or re-authenticate |
| **403 Forbidden** | Insufficient permissions | Show appropriate message |
| **404 Not Found** | Resource doesn't exist | Handle gracefully in UI |
| **400 Bad Request** | Invalid input data | Show validation errors |
| **500 Server Error** | Backend issue | Retry with exponential backoff |

**Flutter Error Handling Example:**

```dart
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  
  ApiException(this.statusCode, this.message);
  
  @override
  String toString() => message;
}

Future<T> handleApiCall<T>(Future<Response> apiCall) async {
  try {
    final response = await apiCall;
    
    if (response.statusCode == 401) {
      // Token expired - try to refresh
      await refreshToken();
      // Retry the original call
      return handleApiCall(apiCall);
    }
    
    if (response.statusCode >= 400) {
      final error = jsonDecode(response.body);
      throw ApiException(
        response.statusCode,
        error['message'] ?? 'Unknown error'
      );
    }
    
    final data = jsonDecode(response.body);
    return data['data'] as T;
    
  } on SocketException {
    throw ApiException(null, 'No internet connection');
  } on TimeoutException {
    throw ApiException(null, 'Request timed out');
  }
}
```

---

---

### Test Data Available - Poem Migration Completed
**Date:** November 25, 2025

The backend now has comprehensive test data ready for Flutter UI development and testing:

**📊 Available Test Data:**
- **374 Poems** with real Urdu poetry content from famous poets
- **50 Poets** processed (can be expanded to all 1,993 poets later)
- **1,792 Verses** automatically parsed from Ghazals for verse-level search
- **1,110 Poem-Tag associations** (average 3 tags per poem)

**📝 Poetry Type Distribution:**
```
GHAZAL       224 poems (60%)  - Couplet-based poetry with verse parsing
NAZAM         74 poems (20%)  - Continuous poetry
VERSE         48 poems (13%)  - Standalone verses
RUBAI         11 poems (3%)   - Quatrains
AZAD_NAZAM     5 poems (1%)   - Free verse
QATTA          4 poems (1%)   - Fragment poetry
MARSIYA        4 poems (1%)   - Elegy
HAMD           3 poems (1%)   - Praise poetry
NAAT           1 poem  (<1%)  - Prophet's praise
```

**✨ Real Urdu Poetry Content From:**
- Mirza Ghalib (ہزاروں خواہشیں ایسی، دل کی ویرانی کا کیا مذکور ہے)
- Allama Iqbal (لب پہ آتی ہے دعا، شکوہ)
- Faiz Ahmed Faiz (مجھ سے پہلی سی محبت، بول کہ لب آزاد ہیں)
- Mir Taqi Mir, Momin Khan Momin, Josh Malihabadi

**🏷️ Tag Distribution:**
```
romantic-poet     283 poems
classical-poet    280 poems
ghazal-master     228 poems
patriotic-poet     79 poems
progressive-poet   79 poems
nazm-writer        79 poems
nature-poet        48 poems
sufi-mystic        15 poems
```

**✅ Ready to Test:**
1. Poem browsing and listing endpoints
2. Poem search with Elasticsearch (or PostgreSQL fallback)
3. Verse-level search for Ghazals
4. Filtering by poet, category, poetry type, tags
5. Multilingual content (Urdu poetry in Arabic script)
6. Pagination across all endpoints

**🚀 Next Steps for Flutter Team:**
- Start building UI with real data
- Test search functionality with real Urdu queries (e.g., محبت، دل، عشق)
- Test verse-level search for Ghazals (returns specific couplets)
- Test pagination and filtering
- Verify tag-based discovery

**📖 Reference:**
- See `DATA_MIGRATION_GUIDE.md` for migration details
- To expand data: Change `.limit(50)` in `PoemDataMigration.java` and re-run

---

## Response Format

All endpoints return responses in the following format:
```json
{
  "success": true,
  "message": "Operation message",
  "data": { ... }
}
```

## Authentication

**IMPORTANT:** All endpoints require JWT authentication except `/api/auth/**` and `/api/health/**`.

Include the access token in the Authorization header for all protected endpoints:

```
Authorization: Bearer <access_token>
```

### Common Authentication Issues & Solutions

#### Issue 1: Getting 302 Redirect Instead of 401/403
**Symptom:** API returns redirect to OAuth2 login page instead of JSON error response
**Cause:** Old backend code with misconfigured security filters
**Solution:** Ensure backend is running the latest code (restart required after Nov 20, 2025 fixes)

#### Issue 2: 404 "User not found" on `/api/auth/me`
**Symptom:** Valid JWT token but `/api/auth/me` returns 404
**Possible Causes:**
- JWT token contains email that doesn't exist in database (token from different environment)
- User was deleted from database but token is still valid
- Token was issued before user record was created
**Solution:**
- Check backend logs for detailed error message
- Verify user exists in database with the email in JWT token
- Generate fresh token by logging in again

#### Issue 3: Redirect Loop on Protected Endpoints
**Symptom:** App gets stuck in redirect loop when calling `/api/poets` or other protected endpoints
**Cause:** Fixed in backend update (Nov 20, 2025)
**Solution:** Ensure backend server is restarted with latest code

#### Expected Error Response Format
When authentication fails, the backend returns:
```json
{
  "success": false,
  "message": "User not authenticated",
  "data": null
}
```
**Status Codes:**
- `401 Unauthorized`: No token or invalid token
- `403 Forbidden`: Valid token but insufficient permissions
- `404 Not Found`: Token valid but user record not found

---

## 1. Authentication Endpoints

Base Path: `/api/auth`

### 1.1 Firebase Login/Register

**Endpoint:** `POST /api/auth/firebase/verify`

**Authentication Required:** No

**Description:** Authenticate user with Firebase ID token. Creates new user if doesn't exist.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "firebaseToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE5ZjE3...",
  "email": "user@example.com",
  "deviceType": "android",
  "deviceId": "unique-device-id"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Firebase authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
    "type": "Bearer",
    "publicId": "usr_abc123def456",
    "username": "user123",
    "email": "user@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid Firebase token",
  "data": null
}
```

---

### 1.2 Admin Login

**Endpoint:** `POST /api/auth/admin/login`

**Authentication Required:** No

**Description:** Authenticate admin user with email and password. Returns JWT tokens in the same format as Firebase authentication, allowing admin users to access all APIs.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "admin@system.com",
  "password": "12345678"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Admin authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
    "type": "Bearer",
    "publicId": "usr_abc123def456",
    "username": "admin",
    "email": "admin@system.com",
    "fullName": "System Admin",
    "profileImageUrl": null
  }
}
```

**Error Response (401 - Invalid Credentials):**
```json
{
  "success": false,
  "message": "Invalid credentials",
  "data": null
}
```

**Error Response (403 - Account Inactive):**
```json
{
  "success": false,
  "message": "Account is not active",
  "data": null
}
```

**Notes:**
- Only users with password authentication enabled can use this endpoint
- Firebase users cannot use this endpoint (they don't have passwords)
- Default admin user: `admin@system.com` / `12345678`
- Admin users can access all API endpoints after authentication
- Same token format as Firebase authentication for consistency

---

### 1.3 Get Current User

**Endpoint:** `GET /api/auth/me`

**Authentication Required:** Yes

**Description:** Get currently authenticated user information

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": "6e0b7476-f877-4e0b-b8e6-1bf7de7a2e6c",  // UUID public ID
    "userId": 2,  // Database ID - use this for X-User-Id header in personalized requests
    "email": "user@example.com",
    "fullName": "John Doe",
    "username": "john_doe",
    "profileImageUrl": "https://example.com/profile.jpg",
    "provider": "firebase",
    "isActive": true
  }
}
```

**Important Notes:**
- `id`: UUID public ID (use for general display/reference)
- `userId`: Database ID (Long) - **Required for personalized discover requests via X-User-Id header**

---

### 1.4 Refresh Token

**Endpoint:** `POST /api/auth/refresh`

**Authentication Required:** No

**Description:** Refresh access token using refresh token

**Request Body:**
```json
{
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token refreshed successfully!",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "660e8400-e29b-41d4-a716-446655440111",
    "type": "Bearer",
    "publicId": "usr_abc123def456",
    "username": "john_doe",
    "email": "user@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg"
  }
}
```

---

### 1.5 Logout

**Endpoint:** `POST /api/auth/logout`

**Authentication Required:** No

**Description:** Logout user and invalidate refresh token

**Request Body:**
```json
{
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully!",
  "data": null
}
```

---

### 1.6 Sign in with Apple (via Firebase)

**Endpoint:** `POST /api/auth/firebase/verify` *(reuses the existing endpoint — no new backend route)*

**Authentication Required:** No

**Why Apple goes through Firebase:** the backend already verifies Firebase ID
tokens. Flutter signs in with Apple natively, swaps the Apple credential for
a Firebase credential via `firebase_auth`, then posts the resulting Firebase
ID token to the same endpoint Google sign-ins use. The backend extracts the
underlying provider (`apple.com`) from the token and stores it on
`User.provider` as `"apple"`.

**Required for App Store guideline 4.8** — every app offering a third-party
login (Google in our case) must offer Sign in with Apple as an equivalent
option, with at least equal UI prominence.

---

#### 1.6.1 One-Time Setup — Apple Developer Portal

You need a paid Apple Developer account. Go to https://developer.apple.com/account/resources

**a) Enable Sign in with Apple on your App ID**
- **Identifiers** → click your iOS app's App ID
- Scroll to **Sign in with Apple** → check the box → **Save** → **Continue** → **Register**
- If you see "Edit" instead of just a checkbox, click **Edit** and select **Enable as a primary App ID**

**b) Create a Services ID** (Firebase needs this for the OAuth backchannel)
- **Identifiers** → **+** → **Services IDs** → Continue
- Description: `Jahan-e-Sukhan Web Sign-In` (or any human-readable label)
- Identifier: must be **different** from your iOS bundle ID. Convention: `<bundleid>.signin` (e.g. `com.techhikes.poetry.signin`)
- **Save** → click the new Services ID → check **Sign in with Apple** → **Configure**
  - **Primary App ID**: pick your iOS App ID
  - **Domains**: `<firebase-project-id>.firebaseapp.com` (find this in Firebase Console → Authentication → Settings → Authorized domains; for this project: `poetry-world-eaf6c.firebaseapp.com`)
  - **Return URLs**: `https://<firebase-project-id>.firebaseapp.com/__/auth/handler`
  - **Save** → **Continue** → **Register**

**c) Generate a Sign in with Apple key**
- **Keys** → **+** → Name: `Sign in with Apple Key` → check **Sign in with Apple** → **Configure** → pick your App ID → Save → **Continue** → **Register**
- **Download the `.p8` file** — you can only download it ONCE. Save it somewhere safe.
- Note the **Key ID** (10 chars, shown on the page after registration)

**d) Find your Team ID**
- Top right of the developer portal → **Membership** → **Team ID** (10 chars)

You now have four artifacts to feed into Firebase:
- **Services ID** (e.g. `com.techhikes.poetry.signin`)
- **Apple Team ID** (10 chars)
- **Key ID** (10 chars)
- **`.p8` private key file** contents

---

#### 1.6.2 One-Time Setup — Firebase Console

Go to https://console.firebase.google.com/project/poetry-world-eaf6c/authentication/providers

- Click **Apple** in the providers list
- Toggle **Enable**
- **Services ID**: paste the value from step (b) above
- **Apple Team ID**: paste from (d)
- **Key ID**: paste from (c)
- **Private key**: open the `.p8` file in a text editor, paste the entire
  contents (including the `-----BEGIN PRIVATE KEY-----` / `-----END PRIVATE KEY-----` lines)
- **Save**

That's all — your existing `/api/auth/firebase/verify` endpoint will now
accept Apple-originated Firebase tokens automatically.

---

#### 1.6.3 One-Time Setup — Xcode Capability

The native Apple Sign-In SDK on iOS needs an entitlement that Xcode adds for
you when you enable the capability:

- Open `ios/Runner.xcworkspace` in Xcode
- Select the **Runner** target → **Signing & Capabilities** tab
- Click **+ Capability** → **Sign in with Apple**
- Save and close — Xcode regenerates the entitlement file

---

#### 1.6.4 Flutter — Dependencies

```yaml
# pubspec.yaml
dependencies:
  sign_in_with_apple: ^6.1.0
  firebase_auth: ^4.20.0   # already present in this project
  crypto: ^3.0.3            # for nonce hashing — required by Firebase + Apple
```

Then `flutter pub get`.

---

#### 1.6.5 Flutter — Sign-In Handler

```dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Generates a cryptographic nonce. Used to prevent replay attacks against
/// Apple's identity_token. The HASH is sent to Apple, the RAW value is sent
/// to Firebase. Firebase recomputes the hash on its side to match.
String _generateNonce([int length = 32]) {
  const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)]).join();
}

String _sha256(String input) => sha256.convert(utf8.encode(input)).toString();

/// Returns the JWT response from /api/auth/firebase/verify on success.
/// Throws on user cancel or any verification failure.
Future<Map<String, dynamic>> signInWithApple({required String backendBaseUrl}) async {
  // 1. Generate nonce — raw is sent to Firebase, hashed is sent to Apple
  final rawNonce = _generateNonce();
  final hashedNonce = _sha256(rawNonce);

  // 2. Trigger native Apple Sign-In sheet
  final appleCredential = await SignInWithApple.getAppleIDCredential(
    scopes: [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    nonce: hashedNonce,
  );

  // 3. Convert Apple credential → Firebase credential
  final oauthCredential = OAuthProvider('apple.com').credential(
    idToken: appleCredential.identityToken,
    rawNonce: rawNonce,
  );

  // 4. Sign in to Firebase with the Apple-backed credential
  final firebaseUser = await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  final firebaseIdToken = await firebaseUser.user!.getIdToken();
  final email = firebaseUser.user!.email;
  if (email == null) {
    throw StateError('Firebase did not return an email — Apple sign-in cannot proceed.');
  }

  // 5. CRITICAL: Apple only returns givenName/familyName on the FIRST sign-in.
  //    Capture it now or you will never get it again. Firebase's displayName
  //    will also be null on first sign-in until we explicitly set it.
  String? fullName;
  if (appleCredential.givenName != null || appleCredential.familyName != null) {
    fullName = [appleCredential.givenName, appleCredential.familyName]
        .where((s) => s != null && s.isNotEmpty)
        .join(' ');
    // Persist the name on the Firebase user so subsequent sign-ins have it
    await firebaseUser.user!.updateDisplayName(fullName);
  } else {
    fullName = firebaseUser.user!.displayName;
  }

  // 6. Hand the Firebase ID token to your backend — same endpoint as Google
  final response = await http.post(
    Uri.parse('$backendBaseUrl/api/auth/firebase/verify'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'firebaseToken': firebaseIdToken,
      'email': email,                    // may be ...@privaterelay.appleid.com
      'deviceType': 'IOS',
      'deviceId': '<your-device-id>',
      // fullName is not part of the contract today, but harmless to send;
      // you can use it locally to seed the profile if backend returns null.
    }),
  );

  if (response.statusCode != 200) {
    throw StateError('Backend rejected Apple sign-in: ${response.body}');
  }
  final body = jsonDecode(response.body) as Map<String, dynamic>;
  return body['data'] as Map<String, dynamic>;
}
```

---

#### 1.6.6 Flutter — UI Requirements (Don't Skip)

Apple is strict about button design and prominence. They reject apps that:

- Hide the Apple button below the fold while showing Google above
- Render the Apple button smaller than other social-sign-in buttons
- Use a non-standard button style (custom colors, custom font)

**Do this:**
```dart
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Use the official widget — never roll your own
SignInWithAppleButton(
  onPressed: () => _handleAppleSignIn(),
  style: SignInWithAppleButtonStyle.black,   // or .white, .whiteOutlined
  borderRadius: BorderRadius.circular(8),
  height: 48,                                // match your Google button height EXACTLY
)
```

**Layout rule of thumb:** Apple button **at or above** the Google button,
**same width**, **same height**. If the Google button is the most prominent
sign-in option on screen, Apple must be at least as prominent.

---

#### 1.6.7 "Hide My Email" Behavior

When the user picks Apple Sign-In, Apple shows them two choices:

| Choice | What Apple sends as email | Account linking with existing Google account on same email |
|---|---|---|
| **Share My Email** | Real email (e.g. `mansoor@gmail.com`) | ✅ Auto-links — backend finds existing user by email |
| **Hide My Email** | Private relay (e.g. `xyz@privaterelay.appleid.com`) | ❌ Creates a new account — no match on email |

Both behaviors are **correct**. The backend stores the relay address as-is;
Apple guarantees it's stable per (user, app), so it works as a login key.
Apple also relays mail you send to the relay address back to the user's real
inbox, so you can still email them transactional notifications.

**Don't try to "fix" the no-link case** — there is no way to map a relay
address back to a real email without the user's involvement. Some apps offer
a manual "merge accounts" flow in settings; we don't have that today.

---

#### 1.6.8 Account Linking by Email (Backend Behavior)

The backend's existing logic in `/api/auth/firebase/verify` handles linking
automatically:

1. Verify the Firebase ID token (works for any provider).
2. Look up `User` by `email`.
3. If found → use that row, just refresh login timestamps. Provider field
   gets upgraded from `"google"` to `"apple"` if the new sign-in is the
   richer claim. (Or vice-versa — last-writer wins.)
4. If not found → create a new `User` row with `provider = "apple"`.

So a user who originally signed in with Google and later signs in with Apple
**Share My Email** keeps the same `publicId`, same bookmarks, same likes,
same follows. From their perspective: they "added Apple Sign-In" to their
existing account.

---

#### 1.6.9 Testing Checklist Before App Store Resubmission

- [ ] Test on a **real iPhone** (Apple Sign-In is unreliable on the simulator).
- [ ] Test **Share My Email**: tap Apple button → "Continue with [your name]" → "Share My Email" → backend returns a JWT. Check DB: new user has `provider = "apple"` and your real email.
- [ ] Test **Hide My Email**: same flow but pick "Hide My Email" → backend returns a JWT. Check DB: a separate user row with `email LIKE '%@privaterelay.appleid.com'` and `provider = "apple"`.
- [ ] Test **the link case**: sign in with Google as `you@gmail.com` → bookmark something → sign out → sign in with Apple → "Share My Email" → verify same `publicId` in `/api/auth/me` and your bookmark is still there.
- [ ] Test **second sign-in**: sign in with Apple, sign out, sign in again. Verify `appleCredential.givenName` is **null** the second time (this is by design — only first sign-in has the name) and that the user's name from the first sign-in is still preserved on Firebase.
- [ ] Verify the Apple button is **at least as prominent** as the Google button on every screen that shows social sign-in.
- [ ] Confirm `/api/auth/me` after Apple sign-in returns `"provider": "apple"`.

---

#### 1.6.10 Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| `SignInWithAppleAuthorizationException(code: canceled)` | User dismissed the sheet | Treat as cancel, no error UI needed |
| `invalid_client` from Firebase | Services ID / Team ID / Key ID mismatch in Firebase Console | Re-paste from Apple Developer Portal exactly |
| Firebase returns `auth/invalid-credential` | Nonce mismatch (you sent the raw nonce to Apple instead of the hashed one, or vice versa) | Send `hashedNonce` to Apple, `rawNonce` to Firebase — see §1.6.5 |
| Apple button shows but tap does nothing | Capability not enabled in Xcode | Re-do §1.6.3 Xcode setup; clean build folder; rebuild |
| User name is null on first sign-in | You requested only `email` scope, not `fullName` | Include both scopes in `getAppleIDCredential` call |
| User created twice with different emails | One sign-in was "Share", the other "Hide My Email" | Expected behavior — these are different identities to Apple |

---

## 2. User Profile Endpoints

Base Path: `/api/profile`

All endpoints require authentication.

### 2.1 Get Current User Profile

**Endpoint:** `GET /api/profile`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg",
    "dateOfBirth": "1990-01-15",
    "gender": "male",
    "location": "Karachi",
    "country": "Pakistan",
    "bio": "Poetry enthusiast",
    "preferredLanguage": "ur",
    "readingLevel": "INTERMEDIATE",
    "onboardingCompleted": true,
    "profileVisibility": "PUBLIC",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-15T14:30:00"
  }
}
```

---

### 2.2 Update Profile

**Endpoint:** `PUT /api/profile`

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "fullName": "John Smith",
  "username": "john_smith",
  "dateOfBirth": "1990-01-15",
  "gender": "male",
  "location": "Karachi",
  "country": "Pakistan",
  "bio": "Passionate about Urdu poetry",
  "preferredLanguage": "ur",
  "readingLevel": "ADVANCED",
  "profileVisibility": "PUBLIC"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_smith",
    "fullName": "John Smith",
    "profileImageUrl": "https://example.com/profile.jpg",
    "dateOfBirth": "1990-01-15",
    "gender": "male",
    "location": "Karachi",
    "country": "Pakistan",
    "bio": "Passionate about Urdu poetry",
    "preferredLanguage": "ur",
    "readingLevel": "ADVANCED",
    "onboardingCompleted": true,
    "profileVisibility": "PUBLIC"
  }
}
```

---

### 2.3 Complete Onboarding

**Endpoint:** `POST /api/profile/complete-onboarding`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Onboarding completed successfully",
  "data": {
    "onboardingCompleted": true
  }
}
```

---

### 2.4 Get User Interests

**Endpoint:** `GET /api/profile/interests`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User interests retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "int_xyz789",
      "interestType": "POET",
      "interestId": 5,
      "interestName": "Mirza Ghalib",
      "strength": 0.8,
      "explicitPreference": true,
      "engagementScore": 12.5,
      "createdAt": "2024-01-01T10:00:00"
    },
    {
      "id": 2,
      "publicId": "int_xyz790",
      "interestType": "CATEGORY",
      "interestId": 3,
      "interestName": "Ghazal",
      "strength": 0.7,
      "explicitPreference": true,
      "engagementScore": 8.3,
      "createdAt": "2024-01-02T11:00:00"
    }
  ]
}
```

---

### 2.5 Get User Interests by Type

**Endpoint:** `GET /api/profile/interests/{interestType}`

**Path Parameters:**
- `interestType`: CATEGORY, POET, TAG, LANGUAGE, CONTENT_TYPE

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/profile/interests/POET`

**Success Response (200):**
```json
{
  "success": true,
  "message": "User interests retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "int_xyz789",
      "interestType": "POET",
      "interestId": 5,
      "interestName": "Mirza Ghalib",
      "strength": 0.8,
      "explicitPreference": true,
      "engagementScore": 12.5
    }
  "activityType": "VIEW",
  "targetType": "POEM",
  "targetId": 123,
  "durationSeconds": 45,
  "sessionId": "session_abc123",
  "deviceType": "android",
  "metadata": "{\"scrollDepth\": 100}"
}
```

**Activity Types:** VIEW, LIKE, UNLIKE, BOOKMARK, UNBOOKMARK, SHARE, SEARCH, FOLLOW_POET, UNFOLLOW_POET, COLLECT, COMMENT, DOWNLOAD

**Target Types:** POEM, POET, CATEGORY, TAG, COLLECTION, USER

**Success Response (200):**
```json
{
  "success": true,
  "message": "Engagement tracked successfully",
  "data": {
    "id": 456,
    "publicId": "eng_abc123",
    "activityType": "VIEW",
    "targetType": "POEM",
    "targetId": 123,
    "durationSeconds": 45,
    "interactionStrength": 1.0,
    "activityTimestamp": "2024-01-15T14:30:00",
    "sessionId": "session_abc123",
    "deviceType": "android"
  }
}
```

---

### 2.9 Get Recent Engagement

**Endpoint:** `GET /api/profile/engagement/recent?days=30`

**Query Parameters:**
- `days` (optional): Number of days to look back (default: 30)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Recent activities retrieved successfully",
  "data": [
    {
      "id": 456,
      "publicId": "eng_abc123",
      "activityType": "VIEW",
      "targetType": "POEM",
      "targetId": 123,
      "durationSeconds": 45,
      "activityTimestamp": "2024-01-15T14:30:00"
    }
  ]
}
```

---

### 2.10 Get Top Engaged Content

**Endpoint:** `GET /api/profile/engagement/top/{targetType}?days=30`

**Path Parameters:**
- `targetType`: POEM, POET, CATEGORY, TAG, COLLECTION, USER

**Query Parameters:**
- `days` (optional): Number of days to look back (default: 30)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/profile/engagement/top/POEM?days=30`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Top engaged content retrieved successfully",
  "data": [
    [123, 15],
    [456, 12],
    [789, 8]
  ]
}
```
Note: Data is array of [targetId, engagementCount]

---

## 3. User Endpoints

Base Path: `/api/user`

### 3.1 Get Current User (Alternative)

**Endpoint:** `GET /api/user/me`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg"
  }
}
```

---

### 3.2 Get User Bookmarks

**Endpoint:** `GET /api/user/bookmarks?page=0&size=10`

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "id": 1,
        "publicId": "bkm_abc123",
        "poem": {
          "id": 123,
          "publicId": "poem_xyz789",
          "title": "Shikwa",
          "content": "کیوں زیاں کار بندوں میں...",
          "poet": {
            "name": "Allama Iqbal"
          }
        },
        "createdAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 25,
    "totalPages": 3,
    "last": false
  }
}
```

---

### 3.3 Update User Profile

**Endpoint:** `PUT /api/user/profile`

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "fullName": "John Updated",
  "username": "john_updated"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_updated",
    "fullName": "John Updated"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Username is already taken!",
  "data": null
}
```

---

### 3.4 Delete User Profile

Hard-deletes the authenticated user's account. Required for App Store submission under
Guideline 5.1.1(v) — Apple rejects apps that don't offer in-app account deletion.

**Endpoint:** `DELETE /api/users/me`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "confirmation": "DELETE"
}
```

The `confirmation` field is a deliberate-action guard. The server rejects the request
unless the value is the literal string `"DELETE"`. Pair this with a "Type DELETE to
confirm" dialog on the client.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Account deleted",
  "data": null
}
```

**Error Response (400) — missing or wrong confirmation:**
```json
{
  "success": false,
  "message": "Confirmation must be the literal string \"DELETE\"",
  "data": null
}
```

**Error Response (401) — no/expired token:**
```json
{
  "success": false,
  "message": "Unauthorized",
  "data": null
}
```

#### What gets deleted vs. retained

**Hard-deleted (rows go away):**
- The `users` row itself
- Personal engagement: bookmarks, likes, follows, reactions, content preferences,
  notifications, image collections, all couplet-level likes/bookmarks/shares,
  refresh tokens, user interests, engagement activities
- Comments authored by the user (current schema requires this; see note below)

**Retained but disowned (content stays public, ownership cleared):**
- Poems uploaded by the user → `uploadedBy` set to `null`
- Claimed poet persona → `ownerUser` set to `null`, `claimStatus` reset to `UNCLAIMED`
- Poetry images the user generated → `user` set to `null`
- Book download history → `user` set to `null` (analytics only)

**Firebase:** the user's Firebase Authentication record is also deleted (best-effort,
runs after the DB transaction commits). If the Firebase delete fails, the local
account is still gone.

> **Note on comments:** Comments are currently hard-deleted because `comments.user_id`
> is `NOT NULL` in the schema. If you later want comment threads to survive account
> deletion (with the author shown as "[deleted]"), the FK needs a Flyway migration to
> become nullable.

#### Flutter implementation checklist

1. Add a "Delete Account" item under **Settings → Account**.
2. Show a confirmation dialog requiring the user to type `DELETE`.
3. Call `DELETE /api/users/me` with body `{"confirmation":"DELETE"}` and the user's
   Bearer token.
4. On 200 success:
   - Clear local secure storage (JWT, refresh token, cached user profile).
   - Call `FirebaseAuth.instance.signOut()`.
   - Navigate to the login/onboarding screen and prevent back-navigation.
5. On 400/401, surface the server's `message` and stay on the settings screen.

#### Flutter — Dart example

```dart
Future<void> deleteAccount() async {
  final response = await dio.delete(
    '/api/users/me',
    data: {'confirmation': 'DELETE'},
    options: Options(headers: {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
    }),
  );

  if (response.statusCode == 200) {
    await secureStorage.deleteAll();
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  } else {
    throw Exception(response.data['message'] ?? 'Failed to delete account');
  }
}
```

> ⚠️ **Irreversible.** There is no undo and no grace period. Once the 200 response
> comes back, the account, all personal engagement data, and the Firebase user are
> gone. Re-registering with the same email creates a brand-new account with no
> history.

---

## 4. Poem Endpoints

Base Path: `/api/poems`

### 4.1 Get All Poems

**Endpoint:** `GET /api/poems?page=0&size=10&sortBy=createdAt&sortDir=desc`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `sortBy` (optional): Sort field (default: createdAt)
- `sortDir` (optional): Sort direction - asc/desc (default: desc)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "شکوہ",
        "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا\nکچھ تو ہے جس کی پردہ داری ہے ضروری",
        "poetPublicId": "poet_abc123",
        "poetName": "علامہ اقبال",
        "poetProfileImageUrl": "https://example.com/iqbal.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "نظم",
        "poetryType": "NAZM",
        "poetryTypeUrduName": "نظم",
        "poetryTypeEnglishName": "Nazm",
        "yearWritten": 1909,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "pageNumber": 0,
      "pageSize": 10,
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalElements": 374,
    "totalPages": 38,
    "last": false,
    "size": 10,
    "number": 0,
    "numberOfElements": 10,
    "first": true,
    "empty": false
  }
}
```

---

### 4.2 Get Poem by ID ⭐ UPDATED (March 30, 2026)

**Endpoint:** `GET /api/poems/{publicId}?lang=ur`

**Authentication Required:** No (anonymous works; pass token to get personalized `reactions.userReaction` and `isBookmarkedByCurrentUser`)

**Request Headers:**
```
Authorization: Bearer <access_token>   // optional — omit for anonymous
```

**Path Parameters:**
- `publicId`: Public ID of the poem

**Query Parameters:**
- `lang` (optional): `ur` | `en` | `hi` — filters `contents[]` to that language AND localizes poet name, poetry type name (default: all languages)

**Example:** `GET /api/poems/25c9e91e-e432-4e9c-ad94-ff67e2e1a4c2?lang=ur`

**Field history:**
| Field | v1.5 | v1.6 (Mar 29) | v1.7 (Mar 30) |
|---|---|---|---|
| `poet` | ❌ | ✅ Full `PoetSummaryResponse` | ✅ unchanged |
| `couplets[]` | ❌ | ✅ per-couplet reactions | ✅ unchanged |
| `isLikedByCurrentUser` | ✅ | ✅ | ❌ **removed** |
| `couplets[n].isLiked` | ❌ | ✅ | ❌ **removed** |
| `reactions.total/byType` | 0 / null (stale) | 0 / null (stale) | ✅ **live counts** |
| `contents[]` | all 3 langs | all 3 langs | **filtered to `?lang=`** |

---

**Success Response (200) — `GET /api/poems/{publicId}?lang=ur` (authenticated):**
```json
{
  "success": true,
  "message": "Poem retrieved successfully",
  "data": {

    "publicId": "25c9e91e-e432-4e9c-ad94-ff67e2e1a4c2",
    "createdAt": "2026-01-24T03:55:17.648335",
    "updatedAt": "2026-03-30T01:53:06.634544",

    "poetPublicId": "744f7569-610f-40ea-ba65-50f7cee93c3b",
    "poetName": "فیض احمد فیض",

    "poet": {
      "publicId": "744f7569-610f-40ea-ba65-50f7cee93c3b",
      "name": "فیض احمد فیض",
      "shortBio": "فیض احمد فیض (1911–1984) پاکستان کے عظیم ترقی پسند شاعر تھے۔ ان کی شاعری میں محبت، سیاسی شعور اور انسانی حقوق کا بیان ملتا ہے۔",
      "birthYear": 1911,
      "deathYear": 1984,
      "profileImageUrl": "https://rekhta.pc.cdn.bitgravity.com//images/shayar/round/faiz-ahmed-faiz.png",
      "gender": "MALE",
      "era": "MODERN",
      "poemCount": 174,
      "viewCount": 48320,
      "isFeatured": true,
      "isTrending": false,
      "birthPlace": "نارووال",
      "country": "پاکستان",
      "countryFlag": "🇵🇰",
      "countryFlagUrl": "https://flagcdn.com/w40/pk.png",
      "isActive": true,
      "topTags": ["ترقی پسند", "سیاسی", "رومانوی"],
      "tagSlugs": ["taraqqi-pasand", "siyasi", "romanvi"]
    },

    "categoryPublicId": "-",
    "categoryName": "-",

    "poetryType": "GHAZAL",
    "poetryTypeName": "غزل",
    "requiresStructuredParsing": true,

    "contentType": "TEXT",
    "imageUrl": "-",
    "thumbnailUrl": "-",

    "yearWritten": 0,
    "source": "https://www.rekhta.org/ghazals/qand-e-dahan-kuchh-is-se-ziyaada-faiz-ahmad-faiz-ghazals?lang=ur",
    "license": "public_domain",
    "uploadedByUsername": "-",

    "isPublic": true,
    "isFeatured": false,

    "viewCount": 142,
    "likeCount": 17,
    "commentCount": 3,
    "shareCount": 8,

    // reactions.total and byType are LIVE counts from the reactions table.
    // userReaction = the authenticated user's current reaction key, null if none.
    "reactions": {
      "total": 17,
      "byType": {
        "LOVE": 7,
        "WAH_WAH": 5,
        "SUBHAN_ALLAH": 3,
        "FIRE": 2
      },
      "userReaction": "WAH_WAH"
    },

    // isLikedByCurrentUser REMOVED — use reactions.userReaction != null
    "isBookmarkedByCurrentUser": false,

    "tagSlugs": ["ishq", "ghazal", "taraqqi-pasand"],

    // contents[] contains ONLY the ?lang=ur entry when lang=ur is requested.
    // For lang=en → only ROMAN entry. No lang param → all 3 languages.
    "contents": [
      {
        "publicId": "731171bf-d13a-4654-a4fa-edc718599326",
        "languageCode": "ur",
        "languageName": "Urdu",
        "languageNativeName": "اردو",
        "script": "ARABIC",
        "scriptUrduName": "عربی",
        "scriptEnglishName": "ARABIC",
        "scriptDirection": "rtl",
        "title": "قند دہن کچھ اس سے زیادہ",
        "fullText": "قند دہن کچھ اس سے زیادہ\nلطف سخن کچھ اس سے زیادہ\n\nفصل خزاں میں لطف بہاراں\nبرگ سمن کچھ اس سے زیادہ\n\nیاد کرتے ہیں تمہیں آج بھی اہل دل\nمرگ ناگاہ پہ ماتم کچھ اس سے زیادہ",
        "isOriginal": true,
        "translatedBy": "-",
        "notes": "-",
        "verses": [],
        "totalVerses": 0,
        "totalCouplets": 0
      }
    ],

    // originalContent mirrors the first isOriginal=true entry in contents[].
    "originalContent": {
      "publicId": "731171bf-d13a-4654-a4fa-edc718599326",
      "languageCode": "ur",
      "languageName": "Urdu",
      "languageNativeName": "اردو",
      "script": "ARABIC",
      "scriptUrduName": "عربی",
      "scriptEnglishName": "ARABIC",
      "scriptDirection": "rtl",
      "title": "قند دہن کچھ اس سے زیادہ",
      "fullText": "قند دہن کچھ اس سے زیادہ\nلطف سخن کچھ اس سے زیادہ\n\n...",
      "isOriginal": true,
      "translatedBy": "-",
      "notes": "-",
      "verses": [],
      "totalVerses": 0,
      "totalCouplets": 0
    },

    // couplets[] is ALWAYS Urdu/ARABIC verses regardless of ?lang= filter.
    // Only populated when requiresStructuredParsing = true (GHAZAL, RUBAI, etc.)
    // reactions.userReaction = null for anonymous users or no reaction.
    // isLiked REMOVED — use reactions.userReaction != null
    "couplets": [
      {
        "publicId": "94c0993e-9cb4-4bc5-adef-9219702a4307",
        "coupletNumber": 1,
        "coupletType": "MATLA",
        "coupletTypeName": "مطلع",
        "likeCount": 9,
        "bookmarkCount": 4,
        "shareCount": 2,
        "reactions": {
          "total": 9,
          "byType": {
            "WAH_WAH": 5,
            "LOVE": 3,
            "SUBHAN_ALLAH": 1
          },
          "userReaction": "WAH_WAH"
        },
        "isBookmarked": false,
        "verses": [
          {
            "publicId": "c1ecc2b6-aae3-41a9-a4c8-8e2cc247aad8",
            "verseNumber": 1,
            "coupletNumber": 1,
            "verseType": "MATLA",
            "verseText": "قند دہن کچھ اس سے زیادہ",
            "romanizedText": "qand dahan kuchh us se ziyada",
            "translation": "-"
          },
          {
            "publicId": "a69f4039-29b3-4789-aa46-0f811ef254f6",
            "verseNumber": 2,
            "coupletNumber": 1,
            "verseType": "MATLA",
            "verseText": "لطف سخن کچھ اس سے زیادہ",
            "romanizedText": "lutf sukhan kuchh us se ziyada",
            "translation": "-"
          }
        ],
        "tagSlugs": null,
        "createdAt": "2026-01-24T03:55:17.648335"
      },
      {
        "publicId": "a82b2d9f-01ac-41bd-81f2-123564979093",
        "coupletNumber": 2,
        "coupletType": "REGULAR",
        "coupletTypeName": "عام شعر",
        "likeCount": 5,
        "bookmarkCount": 2,
        "shareCount": 1,
        "reactions": {
          "total": 5,
          "byType": {
            "BEAUTIFUL": 3,
            "LOVE": 2
          },
          "userReaction": null
        },
        "isBookmarked": true,
        "verses": [
          {
            "publicId": "5a94a537-bd69-408d-8701-29253c9f31f7",
            "verseNumber": 3,
            "coupletNumber": 2,
            "verseType": "REGULAR",
            "verseText": "فصل خزاں میں لطف بہاراں",
            "romanizedText": "fasl-e-khazan mein lutf-e-baharan",
            "translation": "-"
          },
          {
            "publicId": "26b017bc-0085-400b-ad4c-877b9bb04677",
            "verseNumber": 4,
            "coupletNumber": 2,
            "verseType": "REGULAR",
            "verseText": "برگ سمن کچھ اس سے زیادہ",
            "romanizedText": "barg saman kuchh us se ziyada",
            "translation": "-"
          }
        ],
        "tagSlugs": null,
        "createdAt": "2026-01-24T03:55:17.648335"
      },
      {
        "publicId": "52f63e50-22f1-4b10-82a4-bf6bb83ab3b2",
        "coupletNumber": 3,
        "coupletType": "MAQTA",
        "coupletTypeName": "مقطع",
        "likeCount": 3,
        "bookmarkCount": 1,
        "shareCount": 0,
        "reactions": {
          "total": 3,
          "byType": {
            "FIRE": 2,
            "WAH_WAH": 1
          },
          "userReaction": "FIRE"
        },
        "isBookmarked": false,
        "verses": [
          {
            "publicId": "6fc38af6-0d3d-4e53-9d6b-304fe3ea762c",
            "verseNumber": 5,
            "coupletNumber": 3,
            "verseType": "MAQTA",
            "verseText": "یاد کرتے ہیں تمہیں آج بھی اہل دل",
            "romanizedText": "yaad karte hain tumhein aaj bhi ahl-e-dil",
            "translation": "-"
          },
          {
            "publicId": "c40c59af-99e8-48ee-9263-1260eb216b22",
            "verseNumber": 6,
            "coupletNumber": 3,
            "verseType": "MAQTA",
            "verseText": "مرگ ناگاہ پہ ماتم کچھ اس سے زیادہ",
            "romanizedText": "marg-e-nagah pe matam kuchh us se ziyada",
            "translation": "-"
          }
        ],
        "tagSlugs": null,
        "createdAt": "2026-01-24T03:55:17.648335"
      }
    ]
  }
}
```

---

#### 4.2.1 Field Reference — `poet` Object

The `poet` field is a full `PoetSummaryResponse`. All fields may be `null` if data is not yet populated.

| Field | Type | Description |
|---|---|---|
| `publicId` | String | Poet's public UUID |
| `name` | String | Poet's name in requested `?lang=` |
| `shortBio` | String? | Short biography in requested `?lang=` |
| `birthYear` | Int? | Birth year (null if unknown) |
| `deathYear` | Int? | Death year (null if still living or unknown) |
| `profileImageUrl` | String? | CDN URL to profile photo (null if no image) |
| `gender` | String? | `MALE` \| `FEMALE` \| `OTHER` |
| `era` | String? | `CLASSICAL` \| `MODERN` \| `CONTEMPORARY` \| `MEDIEVAL` \| `ROMANTIC` \| `SUFI` |
| `poemCount` | Int? | Total poems by this poet in the database |
| `viewCount` | Int? | Total profile views |
| `isFeatured` | Bool? | Whether curator-featured |
| `isTrending` | Bool? | Whether currently trending |
| `birthPlace` | String? | Birth city name in requested `?lang=` |
| `country` | String? | Country name in requested `?lang=` |
| `countryFlag` | String? | Unicode flag emoji e.g. `"🇵🇰"` |
| `countryFlagUrl` | String? | CDN flag image URL e.g. `"https://flagcdn.com/w40/pk.png"` |
| `isActive` | Bool | `true` unless poet record is soft-deleted |
| `topTags` | List\<String\> | Up to 3 tag names for display |
| `tagSlugs` | List\<String\> | All tag slugs for navigation |

**Flutter usage — poet card:**
```dart
// Show poet profile card below the poem header
if (poem.poet != null) {
  PoetCard(
    imageUrl: poem.poet!.profileImageUrl,
    name: poem.poet!.name,
    shortBio: poem.poet!.shortBio,
    birthYear: poem.poet!.birthYear,
    deathYear: poem.poet!.deathYear,
    poemCount: poem.poet!.poemCount,
    countryFlag: poem.poet!.countryFlag,
    onTap: () => Navigator.push(PoetDetailScreen(poem.poet!.publicId)),
  )
}
```

---

#### 4.2.2 Field Reference — `couplets[]` Array

Each element in `couplets` is a `CoupletDto`. The array is **only populated when `requiresStructuredParsing = true`** (GHAZAL and other structured types). It is an empty array `[]` for NAZAM, AZAD_NAZAM, and other free-verse types.

| Field | Type | Description |
|---|---|---|
| `publicId` | String | Couplet's unique public UUID — use for react/bookmark calls |
| `coupletNumber` | Int | 1-indexed position in the poem |
| `coupletType` | String | `MATLA` \| `MAQTA` \| `REGULAR` \| `CHORUS` \| `REFRAIN` |
| `coupletTypeName` | String | Urdu label: `مطلع` / `مقطع` / `شعر` |
| `likeCount` | Int | Total LOVE reactions (legacy field, mirrors totalReactionCount for LOVE type) |
| `bookmarkCount` | Int | Total bookmarks |
| `shareCount` | Int | Total shares |
| `reactions.total` | Int | Live total reactions across all 10 types |
| `reactions.byType` | Map\<String,Int\>? | Live breakdown by reaction type; `null` when total = 0 |
| `reactions.userReaction` | String? | Authenticated user's reaction key, e.g. `"WAH_WAH"`; `null` if unauthenticated or no reaction. **Use this instead of the removed `isLiked` field.** |
| `isBookmarked` | Bool? | `true` if user has bookmarked this couplet; `null` for anonymous |
| `verses` | List\<VerseDto\> | The two verse lines of the couplet (ordered by verseNumber) |
| `createdAt` | DateTime | When the couplet record was created |

**`coupletType` display guide:**
| Value | Urdu | Display treatment |
|---|---|---|
| `MATLA` | مطلع | Opening couplet — both lines rhyme. Highlight with subtle badge. |
| `MAQTA` | مقطع | Closing couplet — contains poet's pen name (takhallus). Highlight. |
| `REGULAR` | شعر | Standard couplet. No badge needed. |
| `CHORUS` | نعرہ | Refrain/chorus (Nazam). |
| `REFRAIN` | ردیف | Repeated ending pattern. |

---

#### 4.2.3 Flutter — Reacting to a Couplet

Use the unified reactions endpoint. The `publicId` from `couplets[n].publicId` is the target.

```dart
// React to couplet
POST /api/couplets/{coupletPublicId}/react
Body: { "reactionType": "WAH_WAH" }

// Remove reaction (same reactionType as current = toggle off)
POST /api/couplets/{coupletPublicId}/react
Body: { "reactionType": "WAH_WAH" }  // same type → removes it

// Bookmark/unbookmark couplet
POST /api/couplets/{coupletPublicId}/bookmark?lang=ur
```

After reacting, update the local couplet state from the reaction response without re-fetching the full poem.

---

#### 4.2.4 Flutter — Dart Model Additions

```dart
class PoemDetailResponse {
  // ... existing fields ...

  final PoetSummaryResponse? poet;           // full poet card
  final List<CoupletDto> couplets;           // per-couplet engagement
  // isLikedByCurrentUser REMOVED — use reactions.userReaction != null
  final bool? isBookmarkedByCurrentUser;
  final ReactionSummaryDto reactions;        // live counts from DB
}

class PoetSummaryResponse {
  final String publicId;
  final String name;
  final String? shortBio;
  final int? birthYear;
  final int? deathYear;
  final String? profileImageUrl;
  final String? gender;
  final String? era;
  final int? poemCount;
  final int? viewCount;
  final bool? isFeatured;
  final bool? isTrending;
  final String? birthPlace;
  final String? country;
  final String? countryFlag;
  final String? countryFlagUrl;
  final bool? isActive;
  final List<String> topTags;
  final List<String> tagSlugs;

  factory PoetSummaryResponse.fromJson(Map<String, dynamic> json) => PoetSummaryResponse(
    publicId: json['publicId'] as String,
    name: json['name'] as String? ?? '',
    shortBio: json['shortBio'] as String?,
    birthYear: json['birthYear'] as int?,
    deathYear: json['deathYear'] as int?,
    profileImageUrl: json['profileImageUrl'] as String?,
    gender: json['gender'] as String?,
    era: json['era'] as String?,
    poemCount: json['poemCount'] as int?,
    viewCount: json['viewCount'] as int?,
    isFeatured: json['isFeatured'] as bool?,
    isTrending: json['isTrending'] as bool?,
    birthPlace: json['birthPlace'] as String?,
    country: json['country'] as String?,
    countryFlag: json['countryFlag'] as String?,
    countryFlagUrl: json['countryFlagUrl'] as String?,
    isActive: json['isActive'] as bool?,
    topTags: (json['topTags'] as List<dynamic>?)?.cast<String>() ?? [],
    tagSlugs: (json['tagSlugs'] as List<dynamic>?)?.cast<String>() ?? [],
  );
}

class CoupletDto {
  final String publicId;
  final int coupletNumber;
  final String coupletType;         // MATLA | MAQTA | REGULAR | CHORUS | REFRAIN
  final String? coupletTypeName;    // Urdu label
  final int likeCount;
  final int bookmarkCount;
  final int shareCount;
  final ReactionSummaryDto reactions; // .userReaction replaces the old isLiked field
  // isLiked REMOVED — use reactions.userReaction != null
  final bool? isBookmarked;         // null = anonymous
  final List<VerseDto> verses;
  final List<String>? tagSlugs;
  final DateTime createdAt;

  // Convenience getter — true if user has left any reaction
  bool get isReacted => reactions.userReaction != null;

  factory CoupletDto.fromJson(Map<String, dynamic> json) => CoupletDto(
    publicId: json['publicId'] as String,
    coupletNumber: json['coupletNumber'] as int,
    coupletType: json['coupletType'] as String,
    coupletTypeName: json['coupletTypeName'] as String?,
    likeCount: json['likeCount'] as int? ?? 0,
    bookmarkCount: json['bookmarkCount'] as int? ?? 0,
    shareCount: json['shareCount'] as int? ?? 0,
    reactions: ReactionSummaryDto.fromJson(json['reactions'] as Map<String, dynamic>),
    isBookmarked: json['isBookmarked'] as bool?,
    verses: (json['verses'] as List<dynamic>?)
        ?.map((v) => VerseDto.fromJson(v as Map<String, dynamic>))
        .toList() ?? [],
    tagSlugs: (json['tagSlugs'] as List<dynamic>?)?.cast<String>(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
```

---

**Notes:**
- View count is automatically incremented when fetching a poem.
- `?lang=ur` filters `contents[]` to only the Urdu entry AND localizes `poetryTypeName`, poet `name`, `shortBio`, `birthPlace`, `country`. Omit `lang` to receive all 3 language variants in `contents[]`.
- `couplets[]` always contains Urdu/ARABIC verse text regardless of `?lang=`. The `romanizedText` field on each verse provides the Roman transliteration.
- `reactions.total` and `reactions.byType` are **live counts** queried directly from the reactions table — never stale.
- `isLikedByCurrentUser` is removed. Check `reactions.userReaction != null` to know if the user has reacted.
- `poet` is `null` only in the rare case the poet entity could not be loaded; handle gracefully in Flutter.

---

### 4.3 Search Poems (Enhanced with Elasticsearch)

**Endpoint:** `GET /api/poems/search?query=محبت&lang=ur&script=ARABIC&page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Description:**
Enhanced search with Elasticsearch and PostgreSQL fallback. Searches across poem titles, content, and poet names with multilingual support.

**Query Parameters:**
- `query` (required): Search query (supports fuzzy matching for typos)
- `lang` (optional): Language code - `ur`, `en`, `hi` (default: `ur`)
- `script` (optional): Script filter - `ARABIC`, `ROMAN`, `DEVANAGARI`, `LATIN`
- `poetId` (optional): Filter by poet publicId
- `categoryId` (optional): Filter by category publicId
- `poetryType` (optional): Filter by poetry type - `GHAZAL`, `NAZM`, `RUBAI`, etc.
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Examples:**
```
GET /api/poems/search?query=محبت
GET /api/poems/search?query=dil&lang=ur&script=ROMAN
GET /api/poems/search?query=love&poetId=ghalib-123
GET /api/poems/search?query=ghazal&poetryType=GHAZAL&lang=ur
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "محبت کی باتیں",
        "excerpt": "محبت میں دل کی دھڑکن سنائی دے\nہر لمحہ تیری یاد ستائی دے",
        "poetPublicId": "poet_faiz123",
        "poetName": "فیض احمد فیض",
        "poetProfileImageUrl": "https://example.com/faiz.jpg",
        "categoryPublicId": "cat_ghazal",
        "categoryName": "غزل",
        "poetryType": "GHAZAL",
        "poetryTypeUrduName": "غزل",
        "poetryTypeEnglishName": "Ghazal",
        "yearWritten": 1965,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": false,
        "viewCount": 856,
        "likeCount": 127,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2025-11-15T09:20:00",
        "updatedAt": "2025-11-25T16:45:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "offset": 0
    },
    "totalElements": 45,
    "totalPages": 5,
    "last": false,
    "size": 10,
    "number": 0,
    "first": true,
    "empty": false
  }
}
```

**Notes:**
- Uses Elasticsearch for fast, relevant search with BM25 scoring
- Falls back to PostgreSQL LIKE queries if Elasticsearch is unavailable
- Supports fuzzy matching with AUTO fuzziness for typo tolerance
- Searches across multilingual content simultaneously
- Returns PoemSummaryResponse objects (lightweight poem data)

---

### 4.3.1 Search Verses (Verse-Level Search)

**Endpoint:** `GET /api/poems/verses/search?query=دل&lang=ur&page=0&size=20`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Description:**
Search for specific verses within poems (critical for Ghazal poetry). Returns individual verses with poem and poet context.

**Query Parameters:**
- `query` (required): Search query
- `lang` (optional): Language code - `ur`, `en`, `hi` (default: `ur`)
- `verseType` (optional): Filter by verse type - `MATLA`, `MAQTA`, `REGULAR`
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 20)

**Examples:**
```
GET /api/poems/verses/search?query=دل
GET /api/poems/verses/search?query=mohabbat&verseType=MATLA
GET /api/poems/verses/search?query=love&lang=en
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 23 verses matching 'دل'",
  "data": {
    "content": [
      {
        "verse": {
          "publicId": "verse_123",
          "verseNumber": 1,
          "coupletNumber": 1,
          "verseType": "MATLA",
          "verseText": "دل ہی تو ہے نہ سنگ و خشت",
          "romanizedText": "Dil hi to hai na sang-o-khisht",
          "translation": "It's only a heart, not stone and brick"
        },
        "poemPublicId": "poem_001",
        "poemTitle": "دل ہی تو ہے",
        "poetryType": "GHAZAL",
        "poetPublicId": "ghalib_001",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://example.com/ghalib.jpg",
        "score": 8.5,
        "highlightedText": "<em>دل</em> ہی تو ہے نہ سنگ و خشت",
        "coupletNumber": 1,
        "verseNumber": 1,
        "positionInCouplet": 1
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20,
      "offset": 0
    },
    "totalElements": 23,
    "totalPages": 2,
    "last": false,
    "size": 20,
    "number": 0,
    "first": true,
    "empty": false
  }
}
```

**Notes:**
- Returns verses with full poem and poet context
- Ideal for finding specific couplets or verses in Ghazals
- Uses Elasticsearch for precise verse-level matching with relevance scoring
- Falls back to PostgreSQL verse search if needed
- Includes highlighted text showing matched terms
- Returns VerseSearchResult objects with complete context

---

### 4.4 Get Featured Poems

**Endpoint:** `GET /api/poems/featured?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Featured poems retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "شکوہ",
        "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا\nکچھ تو ہے جس کی پردہ داری ہے ضروری",
        "poetPublicId": "poet_abc123",
        "poetName": "علامہ اقبال",
        "poetProfileImageUrl": "https://example.com/iqbal.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "نظم",
        "poetryType": "NAZM",
        "poetryTypeUrduName": "نظم",
        "poetryTypeEnglishName": "Nazm",
        "yearWritten": 1909,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 25,
    "totalPages": 3,
    "last": false
  }
}
```

---

### 4.5 Get Poems by Poet

**Endpoint:** `GET /api/poems/poet/{poetPublicId}?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `poetPublicId`: Public ID of the poet

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poems/poet/poet_abc123?page=0&size=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems by poet retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "شکوہ",
        "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا",
        "poetPublicId": "poet_abc123",
        "poetName": "علامہ اقبال",
        "poetProfileImageUrl": "https://example.com/iqbal.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "نظم",
        "poetryType": "NAZM",
        "poetryTypeUrduName": "نظم",
        "poetryTypeEnglishName": "Nazm",
        "yearWritten": 1909,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 89,
    "totalPages": 9,
    "last": false
  }
}
```

---

### 4.6 Get Poems by Category

**Endpoint:** `GET /api/poems/category/{categoryPublicId}?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `categoryPublicId`: Public ID of the category

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poems/category/cat_def456?page=0&size=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems by category retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "دل کی باتیں",
        "excerpt": "دل کی باتیں دل ہی جانے\nپیار کی باتیں پیار جانے",
        "poetPublicId": "poet_ghalib",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://example.com/ghalib.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "غزل",
        "poetryType": "GHAZAL",
        "poetryTypeUrduName": "غزل",
        "poetryTypeEnglishName": "Ghazal",
        "yearWritten": 1850,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": false,
        "viewCount": 2341,
        "likeCount": 589,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": true,
        "createdAt": "2024-01-10T12:00:00",
        "updatedAt": "2024-01-20T18:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 224,
    "totalPages": 23,
    "last": false
  }
}
```

---

### 4.7 Get Poems by Language

**Endpoint:** `GET /api/poems/language/{language}?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `language`: Language code (e.g., ur, en, ar)

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poems/language/ur?page=0&size=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems by language retrieved successfully",
  "data": {
    "content": [
      {
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "Shikwa",
        "language": "ur"
      }
    ]
  }
}
```

---

### 4.8 Toggle Bookmark

**Endpoint:** `POST /api/poems/{publicId}/bookmark?lang=ur`

**Description:** Bookmark or unbookmark a poem (toggles). The language parameter preserves the language context in which the user bookmarked the content.

**Path Parameters:**
- `publicId`: Public ID of the poem

**Query Parameters:**
- `lang` (optional, default: "ur"): Language code when bookmarking (ur, en, hi, etc.). This is stored with the bookmark so the content can be displayed in the bookmarked language later.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem bookmarked successfully",
  "data": {
    "bookmarked": true
  }
}
```

OR

```json
{
  "success": true,
  "message": "Bookmark removed successfully",
  "data": {
    "bookmarked": false
  }
}
```

---

### 4.9 Toggle Like

**Endpoint:** `POST /api/poems/{publicId}/like`

**Description:** Like or unlike a poem (toggles)

**Path Parameters:**
- `publicId`: Public ID of the poem

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem liked successfully",
  "data": {
    "liked": true
  }
}
```

OR

```json
{
  "success": true,
  "message": "Like removed successfully",
  "data": {
    "liked": false
  }
}
```

---

### 4.10 Get Poem Status

**Endpoint:** `GET /api/poems/{publicId}/status`

**Description:** Get bookmark and like status for a poem

**Path Parameters:**
- `publicId`: Public ID of the poem

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem status retrieved successfully",
  "data": {
    "bookmarked": true,
    "liked": false
  }
}
```

---

### 4.11 Upload Poem

**Endpoint:** `POST /api/poems/add-poem`

**Description:** Upload a new poem with automatic Ghazal parsing (requires authentication)

**⚠️ BREAKING CHANGES (Updated November 2025):**
- `language` → `languageCode` (string)
- `script` → Script enum value (ARABIC/ROMAN/DEVANAGARI/LATIN)
- `form` → `poetryType` enum (GHAZAL/NAZAM/VERSE/NASAR/AFSANA/etc.)
- `categoryId` is now optional
- Ghazals are automatically parsed into verses

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "New Poem Title",
  "poetId": "poet_abc123",
  "categoryId": "cat_def456",
  "content": "یہ ایک نئی نظم ہے...",
  "poetryType": "GHAZAL",
  "contentType": "TEXT",
  "imageUrl": null,
  "thumbnailUrl": null,
  "languageCode": "ur",
  "script": "ARABIC",
  "yearWritten": 2024,
  "source": "Original",
  "license": "public_domain",
  "isPublic": true,
  "tagIds": ["tag_123", "tag_456"]
}
```

**Poetry Types:**
- `GHAZAL` - Couplet-based poetry (automatically parsed into MATLA/MAQTA/REGULAR verses)
- `NAZAM` - Continuous poetry (stored as-is, no parsing)
- `AZAD_NAZAM` - Free verse (no parsing)
- `VERSE` - Single verse or couplet (no parsing)
- `NASAR` - Prose (no parsing)
- `AFSANA` - Story/Fiction (no parsing)
- `QATTA`, `RUBAI`, `MASNAVI`, `QASIDA`, `MARSIYA`, `HAMD`, `NAAT`, `MANQABAT`, `DOHA`, `FREE_VERSE`

**Script Values:**
- `ARABIC` - Arabic script (RTL) - عربی
- `ROMAN` - Roman/Latin script (LTR)
- `DEVANAGARI` - Devanagari script (LTR) - देवनागरी
- `LATIN` - Latin script (LTR)

**Success Response (201):**
```json
{
  "success": true,
  "message": "Poem uploaded successfully",
  "data": {
    "publicId": "poem_new123",
    "createdAt": "2025-11-26T10:30:00",
    "updatedAt": "2025-11-26T10:30:00",
    "poetPublicId": "poet_abc123",
    "poetName": "مرزا غالب",
    "categoryPublicId": "cat_def456",
    "categoryName": "غزل",
    "poetryType": "GHAZAL",
    "poetryTypeUrduName": "غزل",
    "poetryTypeEnglishName": "Ghazal",
    "requiresStructuredParsing": true,
    "contentType": "TEXT",
    "imageUrl": null,
    "thumbnailUrl": null,
    "yearWritten": 2024,
    "source": "Original",
    "license": "public_domain",
    "uploadedByUsername": "admin",
    "isPublic": true,
    "isFeatured": false,
    "viewCount": 0,
    "likeCount": 0,
    "tags": [
      {
        "publicId": "tag_123",
        "urduName": "عشق",
        "englishName": "Love"
      }
    ],
    "contents": [
      {
        "publicId": "content_new001",
        "languageCode": "ur",
        "languageName": "Urdu",
        "languageNativeName": "اردو",
        "script": "ARABIC",
        "scriptUrduName": "عربی",
        "scriptEnglishName": "Arabic",
        "scriptDirection": "rtl",
        "title": "New Poem Title",
        "fullText": "یہ ایک نئی نظم ہے...",
        "isOriginal": true,
        "translatedBy": null,
        "notes": null,
        "verses": [
          {
            "publicId": "verse_new001",
            "verseNumber": 1,
            "coupletNumber": 1,
            "verseType": "MATLA",
            "verseText": "یہ ایک نئی نظم ہے",
            "romanizedText": null,
            "translation": null
          }
        ],
        "totalVerses": 8,
        "totalCouplets": 4
      }
    ]
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Poet not found",
  "data": null
}
```

**Note:** For Ghazals, the backend automatically:
- Parses content into individual verses
- Creates couplets (2 verses each)
- Identifies first couplet as MATLA (opening)
- Identifies last couplet as MAQTA (closing with poet's name)
- Tags all other couplets as REGULAR

---

## 4.12 Poem Content Architecture (November 2025 Update)

### Multilingual Poem System

**Overview:**
The poem system now supports **multilingual content** and **automatic Ghazal parsing** for verse-level search.

**Key Features:**
1. **Multilingual Support**: Same poem can exist in multiple languages and scripts
   - Example: Urdu (Arabic script), Roman Urdu, English translation, Hindi translation
2. **Verse-Level Granularity**: Ghazals are parsed into individual verses for precise search
   - Searching "dil" returns specific verses, not just full poems
3. **Schema-Based Parsing**: Only Ghazals are parsed initially (other types stored as-is)

**Database Structure:**

```
poems                 (Metadata only)
  ├── id, publicId
  ├── poet_id
  ├── poetry_type (GHAZAL, NAZAM, etc.)
  ├── category_id (optional)
  └── view_count, like_count, etc.

poem_contents         (Multilingual text storage)
  ├── id, publicId
  ├── poem_id (FK → poems)
  ├── language_id (FK → languages)
  ├── script (ARABIC, ROMAN, DEVANAGARI, LATIN)
  ├── title (translated title)
  ├── full_text (complete poem)
  ├── is_original (boolean)
  └── translated_by, notes

poem_verses           (Parsed verses for Ghazals)
  ├── id, publicId
  ├── content_id (FK → poem_contents)
  ├── verse_number (1, 2, 3...)
  ├── couplet_number (1, 2, 3...)
  ├── verse_type (MATLA, MAQTA, REGULAR)
  └── verse_text (individual verse)
```

**Unique Constraints:**
- `poem_contents`: (poem_id, language_id, script) - One entry per language+script combination
- Full text always preserved even after parsing

**Example Data Flow:**
```
Upload Ghazal:
  Title: "Har Ek Baat Pe"
  Content: "ہر ایک بات پہ کہتے ہو تم کہ تو کیا ہے\n..."
  Poetry Type: GHAZAL
  Language: ur, Script: ARABIC

Backend Processing:
  1. Creates Poem record (metadata only)
  2. Creates PoemContent record (Urdu Arabic)
  3. Parses 6 couplets = 12 verses:
     - Verses 1-2: MATLA (opening couplet)
     - Verses 3-10: REGULAR (middle couplets)
     - Verses 11-12: MAQTA (closing with "Ghalib")
```

---

## 4.13 Breaking Changes Summary (November 2025)

### Removed Endpoints:
- ❌ `GET /api/poems/language/{language}` - Removed (language filtering handled differently)

### Modified Endpoints:

**POST /api/poems/add-poem:**
| Old Field | New Field | Type | Notes |
|-----------|-----------|------|-------|
| `language` | `languageCode` | String | Same values: "ur", "en", "hi" |
| `script` | `script` | Enum | Now: "ARABIC", "ROMAN", "DEVANAGARI", "LATIN" |
| `form` | `poetryType` | Enum | Now: "GHAZAL", "NAZAM", "VERSE", etc. |
| `categoryId` | `categoryId` | String | Now optional (can be null) |

**GET /api/poems/search:**
- ❌ Removed `language` query parameter
- Now searches across all poem content (all languages/scripts)
- Will be replaced with Elasticsearch for verse-level search

**Future Enhancements (Coming Soon):**
- Enhanced DTOs with multilingual content
- Verse-level search using Elasticsearch + BM25
- Translation management endpoints
- Script transliteration support

---

## 5. Enhanced Poet Endpoints

Base Path: `/api/poets`

**IMPORTANT:** All poet endpoints support multi-language responses. Use the `lang` query parameter to get poet information in your preferred language (ur, en, or hi). Default is Urdu (ur).

### Multi-Language Support

All poet data (names, biographies, locations) are stored in 3 languages:
- **ur** (Urdu) - اردو
- **en** (English)
- **hi** (Hindi) - हिंदी

Example: `GET /api/poets?lang=en` will return poet names and bios in English.

---

## 5.1 Browse & Discovery Endpoints

### 5.1.1 Get All Poets

**Endpoint:** `GET /api/poets?page=0&size=10&lang=ur&sortBy=viewCount&sortDir=desc`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)
- `sortBy` (optional): Sort field (default: viewCount)
  - Valid values: `viewCount`, `poemCount`, `followerCount`, `birthYear`, `deathYear`, `createdAt`, `updatedAt`
  - **Note:** Cannot sort by `name` directly as names are stored in multiple languages
- `sortDir` (optional): Sort direction - asc/desc (default: desc)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_abc123",
        "name": "علامہ اقبال",
        "shortBio": "شاعر مشرق، فلسفی اور مفکر",
        "birthYear": 1877,
        "deathYear": 1938,
        "profileImageUrl": "https://example.com/iqbal.jpg",
        "gender": "MALE",
        "era": "MODERN",
        "poemCount": 234,
        "viewCount": 15234,
        "isFeatured": true,
        "isTrending": false,
        "topTags": ["فلسفہ", "قومی شاعری", "مذہبی"]
      },
      {
        "publicId": "poet_def456",
        "name": "پروین شاکر",
        "shortBio": "معاصر اردو کی مشہور خاتون شاعرہ",
        "birthYear": 1952,
        "deathYear": 1994,
        "profileImageUrl": "https://example.com/parveen.jpg",
        "gender": "FEMALE",
        "era": "CONTEMPORARY",
        "poemCount": 156,
        "viewCount": 8932,
        "isFeatured": true,
        "isTrending": true,
        "topTags": ["رومانوی", "جدید غزل", "عصری"]
      }
    ],
    "totalElements": 234,
    "totalPages": 24,
    "last": false
  }
}
```

---

### 5.1.2 Get Featured Poets

**Endpoint:** `GET /api/poets/featured?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets marked as featured (prominent poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Featured poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East, philosopher and thinker",
        "birthYear": 1877,
        "deathYear": 1938,
        "profileImageUrl": "https://example.com/iqbal.jpg",
        "gender": "MALE",
        "era": "MODERN",
        "poemCount": 234,
        "viewCount": 15234,
        "isFeatured": true,
        "topTags": ["Philosophy", "National Poetry", "Religious"]
      }
    ],
    "totalElements": 25,
    "totalPages": 3
  }
}
```

---

### 5.1.3 Get Trending Poets

**Endpoint:** `GET /api/poets/trending?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets currently trending or popular

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Trending poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_xyz789",
        "name": "Ahmad Faraz",
        "shortBio": "Contemporary romantic poet",
        "birthYear": 1931,
        "deathYear": 2008,
        "profileImageUrl": "https://example.com/faraz.jpg",
        "gender": "MALE",
        "era": "CONTEMPORARY",
        "poemCount": 189,
        "viewCount": 12456,
        "isTrending": true,
        "topTags": ["Romantic", "Ghazal", "Modern"]
      }
    ],
    "totalElements": 15,
    "totalPages": 2
  }
}
```

---

### 5.1.4 Get Poets by Gender

**Endpoint:** `GET /api/poets/gender/{gender}?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Filter poets by gender (for example, women poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `gender`: MALE, FEMALE, OTHER

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/gender/FEMALE?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_def456",
        "name": "Parveen Shakir",
        "shortBio": "Famous contemporary Urdu poetess",
        "birthYear": 1952,
        "deathYear": 1994,
        "gender": "FEMALE",
        "era": "CONTEMPORARY",
        "poemCount": 156,
        "viewCount": 8932,
        "topTags": ["Romantic", "Modern Ghazal", "Contemporary"]
      },
      {
        "publicId": "poet_ghi789",
        "name": "Ada Jafri",
        "shortBio": "Leading Urdu poetess of modern era",
        "birthYear": 1924,
        "deathYear": 2015,
        "gender": "FEMALE",
        "era": "MODERN",
        "poemCount": 98,
        "viewCount": 5432,
        "topTags": ["Progressive", "Feminist", "Social"]
      }
    ],
    "totalElements": 42,
    "totalPages": 5
  }
}
```

---

### 5.1.5 Get Poets by Era

**Endpoint:** `GET /api/poets/era/{era}?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Filter poets by historical era

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `era`: CLASSICAL, MODERN, CONTEMPORARY, EMERGING

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/era/CLASSICAL?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "One of the most influential Urdu poets",
        "birthYear": 1797,
        "deathYear": 1869,
        "era": "CLASSICAL",
        "gender": "MALE",
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      }
    ],
    "totalElements": 67,
    "totalPages": 7
  }
}
```

**Era Values:**
- `CLASSICAL` - Classical era poets (pre-1900)
- `MODERN` - Modern era poets (1900-1980)
- `CONTEMPORARY` - Contemporary poets (1980-present)
- `EMERGING` - Emerging new poets

---

### 5.1.6 Get Poets by Tag

**Endpoint:** `GET /api/poets/tags/{tagSlug}?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Filter poets by tag/category (e.g., ghazal-masters, romantic-poets, sufi-poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `tagSlug`: Slug of the tag (e.g., "ghazal-masters", "women-poets", "sufi-poets")

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/tags/ghazal-masters?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "Master of Ghazal poetry",
        "birthYear": 1797,
        "deathYear": 1869,
        "era": "CLASSICAL",
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      },
      {
        "publicId": "poet_mir",
        "name": "Mir Taqi Mir",
        "shortBio": "God of Urdu Ghazal",
        "birthYear": 1723,
        "deathYear": 1810,
        "era": "CLASSICAL",
        "poemCount": 245,
        "viewCount": 18923,
        "topTags": ["Ghazal", "Classical", "Love Poetry"]
      }
    ],
    "totalElements": 15,
    "totalPages": 2
  }
}
```

---

### 5.1.7 Search Poets (Enhanced with Elasticsearch)

**Endpoint:** `GET /api/poets/search?query=iqbal&lang=ur&page=0&size=10`

**Authentication Required:** Yes

**Description:**
Enhanced search with Elasticsearch and PostgreSQL fallback. Searches across poet names, biographies, and details in multiple languages and scripts.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `query` (required): Search query (supports fuzzy matching)
- `lang` (optional): Language code - `ur`, `en`, `hi` (default: `ur`)
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Examples:**
```
GET /api/poets/search?query=غالب
GET /api/poets/search?query=mirza&lang=en
GET /api/poets/search?query=ghalib&lang=ur
GET /api/poets/search?query=iqbal&page=0&size=20
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East, philosopher and thinker",
        "birthYear": 1877,
        "deathYear": 1938,
        "era": "MODERN",
        "gender": "MALE",
        "poemCount": 234,
        "viewCount": 15234,
        "topTags": ["Philosophy", "Nationalism", "Ghazal"]
      }
    ],
    "totalElements": 1,
    "totalPages": 1
  }
}
```

**Notes:**
- Uses Elasticsearch for fast, relevant search with BM25 scoring
- Searches across poet names, biographies, and short bios
- Falls back to PostgreSQL if Elasticsearch is unavailable
- Supports fuzzy matching for typo tolerance
- Multi-field search with boosted name field (highest relevance)

---

## 5.2 Top & Ranking Endpoints

### 5.2.1 Get Top Poets by Poem Count

**Endpoint:** `GET /api/poets/top/by-poems?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets ranked by number of poems (most prolific poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Top poets by poem count retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "One of the most influential Urdu poets",
        "birthYear": 1797,
        "deathYear": 1869,
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      },
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East",
        "birthYear": 1877,
        "deathYear": 1938,
        "poemCount": 234,
        "viewCount": 15234,
        "topTags": ["Philosophy", "National", "Religious"]
      }
    ],
    "totalElements": 234,
    "totalPages": 24
  }
}
```

---

### 5.2.2 Get Top Poets by Views

**Endpoint:** `GET /api/poets/top/by-views?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets ranked by view count (most popular poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Top poets by views retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "One of the most influential Urdu poets",
        "birthYear": 1797,
        "deathYear": 1869,
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      },
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East",
        "birthYear": 1877,
        "deathYear": 1938,
        "poemCount": 234,
        "viewCount": 15234,
        "topTags": ["Philosophy", "National", "Religious"]
      }
    ],
    "totalElements": 234,
    "totalPages": 24
  }
}
```

---

## 5.3 Poet Profile Endpoints

### 5.3.1 Get Complete Poet Profile

**Endpoint:** `GET /api/poets/{publicId}/profile?lang=ur`

**Authentication Required:** Yes

**Description:** Get complete poet profile with all information including gallery, books, videos, and facts. **View count is automatically incremented.**

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/poet_abc123/profile?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet profile retrieved successfully",
  "data": {
    "publicId": "poet_abc123",
    "name": "Allama Iqbal",
    "biography": "Muhammad Iqbal was a poet, philosopher, and politician. Born in Sialkot, British India (now in Pakistan), he is widely regarded as having inspired the Pakistan Movement. He is considered one of the most important figures in Urdu and Persian literature...",
    "shortBio": "Poet of the East, philosopher and thinker",
    "gender": "MALE",
    "era": "MODERN",
    "birthYear": 1877,
    "deathYear": 1938,
    "birthDate": "1877-11-09",
    "deathDate": "1938-04-21",
    "birthPlace": "Sialkot",
    "country": "Pakistan",
    "primaryLanguageCode": "ur",
    "primaryLanguageName": "Urdu",
    "isFeatured": true,
    "isTrending": false,
    "isVerified": true,
    "viewCount": 15235,
    "followerCount": 4532,
    "poemCount": 234,
    "gallery": [
      {
        "publicId": "img_123",
        "imageUrl": "https://example.com/iqbal-portrait.jpg",
        "thumbnailUrl": "https://example.com/iqbal-portrait-thumb.jpg",
        "caption": "Portrait of Allama Iqbal",
        "altText": "Allama Iqbal portrait",
        "displayOrder": 1,
        "isProfileImage": true,
        "imageType": "PROFILE"
      },
      {
        "publicId": "img_124",
        "imageUrl": "https://example.com/iqbal-young.jpg",
        "thumbnailUrl": "https://example.com/iqbal-young-thumb.jpg",
        "caption": "Young Iqbal in Cambridge",
        "altText": "Young Allama Iqbal",
        "displayOrder": 2,
        "isProfileImage": false,
        "imageType": "HISTORICAL"
      }
    ],
    "books": [
      {
        "publicId": "book_123",
        "languageCode": "ur",
        "languageName": "Urdu",
        "title": "Bang-e-Dara",
        "subtitle": "The Call of the Marching Bell",
        "description": "A collection of patriotic poetry",
        "yearPublished": 1924,
        "publisher": "Taj Company",
        "isbn": "978-1234567890",
        "isbn13": "978-1234567890123",
        "pageCount": 234,
        "coverImageUrl": "https://example.com/bang-e-dara.jpg",
        "isAvailable": true,
        "bookType": "POETRY_COLLECTION"
      },
      {
        "publicId": "book_124",
        "languageCode": "fa",
        "languageName": "Persian",
        "title": "Asrar-e-Khudi",
        "subtitle": "The Secrets of the Self",
        "description": "Philosophical poetry in Persian",
        "yearPublished": 1915,
        "publisher": "Dar al-Kutub",
        "isbn": "978-9876543210",
        "pageCount": 189,
        "coverImageUrl": "https://example.com/asrar.jpg",
        "isAvailable": true,
        "bookType": "POETRY_COLLECTION"
      }
    ],
    "videos": [
      {
        "publicId": "vid_123",
        "title": "Shikwa - Recitation by Mehdi Hassan",
        "description": "Beautiful rendition of Iqbal's Shikwa",
        "videoUrl": "https://youtube.com/watch?v=xyz",
        "thumbnailUrl": "https://img.youtube.com/vi/xyz/0.jpg",
        "duration": 1240,
        "yearRecorded": 1982,
        "videoType": "RECITATION"
      },
      {
        "publicId": "vid_124",
        "title": "Documentary: Life of Allama Iqbal",
        "description": "Complete biography documentary",
        "videoUrl": "https://youtube.com/watch?v=abc",
        "thumbnailUrl": "https://img.youtube.com/vi/abc/0.jpg",
        "duration": 3600,
        "yearRecorded": 2015,
        "videoType": "DOCUMENTARY"
      }
    ],
    "facts": [
      "Studied at Government College Lahore, Cambridge, and Munich",
      "Knighted by King George V in 1922",
      "Delivered the famous Allahabad Address in 1930",
      "Wrote poetry in both Urdu and Persian",
      "Considered the spiritual father of Pakistan"
    ],
    "tags": [
      {
        "publicId": "tag_123",
        "name": "National Poetry",
        "slug": "national-poetry",
        "color": "#FF5733",
        "tagType": "POEM_GENRE",
        "description": "Poetry with national and patriotic themes"
      },
      {
        "publicId": "tag_124",
        "name": "Philosophy",
        "slug": "philosophy",
        "color": "#33C4FF",
        "tagType": "POEM_GENRE",
        "description": "Philosophical and intellectual poetry"
      },
      {
        "publicId": "tag_125",
        "name": "Modern Era",
        "slug": "modern-era",
        "color": "#85FF33",
        "tagType": "ERA",
        "description": "Poets of the modern era"
      }
    ],
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-15T14:30:00"
  }
}
```

---

### 5.3.2 Get Poet Gallery

**Endpoint:** `GET /api/poets/{publicId}/gallery`

**Authentication Required:** Yes

**Description:** Get all images in poet's gallery

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Example:** `GET /api/poets/poet_abc123/gallery`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet gallery retrieved successfully",
  "data": [
    {
      "publicId": "img_123",
      "imageUrl": "https://example.com/iqbal-portrait.jpg",
      "thumbnailUrl": "https://example.com/iqbal-portrait-thumb.jpg",
      "caption": "Portrait of Allama Iqbal",
      "altText": "Allama Iqbal portrait",
      "displayOrder": 1,
      "isProfileImage": true,
      "imageType": "PROFILE"
    },
    {
      "publicId": "img_124",
      "imageUrl": "https://example.com/iqbal-young.jpg",
      "thumbnailUrl": "https://example.com/iqbal-young-thumb.jpg",
      "caption": "Young Iqbal in Cambridge",
      "altText": "Young Allama Iqbal",
      "displayOrder": 2,
      "isProfileImage": false,
      "imageType": "HISTORICAL"
    }
  ]
}
```

**Image Types:**
- `PROFILE` - Profile/main image
- `PORTRAIT` - Portrait photograph
- `HISTORICAL` - Historical photograph
- `EVENT` - Event or occasion photo
- `OTHER` - Other type

---

### 5.3.3 Get Poet Books

**Endpoint:** `GET /api/poets/{publicId}/books?lang=ur`

**Authentication Required:** Yes

**Description:** Get all books/publications by the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `lang` (optional): Filter by book language (ur/en/fa/ar/hi)

**Example:** `GET /api/poets/poet_abc123/books?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet books retrieved successfully",
  "data": [
    {
      "publicId": "book_123",
      "languageCode": "ur",
      "languageName": "Urdu",
      "title": "Bang-e-Dara",
      "subtitle": "The Call of the Marching Bell",
      "description": "A collection of patriotic poetry written during the independence movement",
      "yearPublished": 1924,
      "publisher": "Taj Company",
      "isbn": "978-1234567890",
      "isbn13": "978-1234567890123",
      "pageCount": 234,
      "coverImageUrl": "https://example.com/bang-e-dara.jpg",
      "isAvailable": true,
      "bookType": "POETRY_COLLECTION"
    },
    {
      "publicId": "book_125",
      "languageCode": "ur",
      "languageName": "Urdu",
      "title": "Bal-e-Jibril",
      "subtitle": "Gabriel's Wing",
      "description": "One of the most celebrated collections",
      "yearPublished": 1935,
      "publisher": "Shaikh Ghulam Ali",
      "isbn": "978-1234567891",
      "pageCount": 189,
      "coverImageUrl": "https://example.com/bal-e-jibril.jpg",
      "isAvailable": true,
      "bookType": "POETRY_COLLECTION"
    }
  ]
}
```

**Book Types:**
- `POETRY_COLLECTION` - Collection of poems
- `ANTHOLOGY` - Anthology or compiled works
- `BIOGRAPHY` - Biographical book
- `CRITICISM` - Literary criticism
- `OTHER` - Other type

**Note:** Books are stored in their original language only (not translated)

---

### 5.3.4 Get Poet Videos

**Endpoint:** `GET /api/poets/{publicId}/videos?type=RECITATION`

**Authentication Required:** Yes

**Description:** Get videos related to the poet (mushairas, recitations, documentaries)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `type` (optional): Filter by video type (MUSHAIRA, INTERVIEW, DOCUMENTARY, RECITATION, BIOGRAPHY, OTHER)

**Example:** `GET /api/poets/poet_abc123/videos?type=DOCUMENTARY`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet videos retrieved successfully",
  "data": [
    {
      "publicId": "vid_123",
      "title": "Documentary: Life of Allama Iqbal",
      "description": "Complete biography documentary covering his life, philosophy, and contribution to Urdu literature",
      "videoUrl": "https://youtube.com/watch?v=abc123",
      "thumbnailUrl": "https://img.youtube.com/vi/abc123/maxresdefault.jpg",
      "duration": 3600,
      "yearRecorded": 2015,
      "videoType": "DOCUMENTARY"
    },
    {
      "publicId": "vid_124",
      "title": "Iqbal: The Visionary",
      "description": "Documentary on Iqbal's political vision",
      "videoUrl": "https://youtube.com/watch?v=def456",
      "thumbnailUrl": "https://img.youtube.com/vi/def456/maxresdefault.jpg",
      "duration": 2700,
      "yearRecorded": 2018,
      "videoType": "DOCUMENTARY"
    }
  ]
}
```

**Video Types:**
- `MUSHAIRA` - Poetry gathering/mushaira
- `INTERVIEW` - Interview about the poet
- `DOCUMENTARY` - Documentary film
- `RECITATION` - Poetry recitation
- `BIOGRAPHY` - Biographical video
- `OTHER` - Other type

**Note:** Duration is in seconds

---

### 5.3.5 Get Poet Facts

**Endpoint:** `GET /api/poets/{publicId}/facts?lang=ur`

**Authentication Required:** Yes

**Description:** Get interesting facts about the poet in specified language

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/poet_abc123/facts?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet facts retrieved successfully",
  "data": [
    "Studied at Government College Lahore, Cambridge, and Munich",
    "Knighted by King George V in 1922",
    "Delivered the famous Allahabad Address in 1930",
    "Wrote poetry in both Urdu and Persian",
    "Considered the spiritual father of Pakistan",
    "His poetry inspired the Pakistan Movement",
    "Specialized in philosophy and Islamic revival"
  ]
}
```

**Note:** Facts are stored and returned in all 3 languages (ur, en, hi)

---

## 5.4 Admin CRUD Endpoints

**IMPORTANT:** These endpoints are for admin use only. In production, add proper role-based access control.

### 5.4.1 Create Poet

**Endpoint:** `POST /api/poets`

**Authentication Required:** Yes (Admin only)

**Description:** Create a new poet with initial translation

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "gender": "MALE",
  "era": "MODERN",
  "birthYear": 1877,
  "deathYear": 1938,
  "birthDate": "1877-11-09",
  "deathDate": "1938-04-21",
  "birthPlaceId": "city_sialkot",
  "countryId": "country_pakistan",
  "primaryLanguageCode": "ur",
  "isFeatured": true,
  "isTrending": false,
  "languageCode": "ur",
  "name": "علامہ اقبال",
  "biography": "علامہ محمد اقبال ایک شاعر، فلسفی اور سیاست دان تھے...",
  "shortBio": "شاعر مشرق، فلسفی اور مفکر"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Poet created successfully",
  "data": {
    "id": 123,
    "publicId": "poet_abc123",
    "gender": "MALE",
    "era": "MODERN",
    "birthYear": 1877,
    "deathYear": 1938,
    "isFeatured": true,
    "viewCount": 0,
    "followerCount": 0,
    "poemCount": 0,
    "createdAt": "2024-01-15T14:30:00"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Error creating poet: Birth place not found",
  "data": null
}
```

---

### 5.4.2 Update Poet

**Endpoint:** `PUT /api/poets/{publicId}`

**Authentication Required:** Yes (Admin only)

**Description:** Update poet's basic information (NOT translations)

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body (all fields optional):**
```json
{
  "gender": "MALE",
  "era": "MODERN",
  "birthYear": 1877,
  "deathYear": 1938,
  "birthDate": "1877-11-09",
  "deathDate": "1938-04-21",
  "birthPlaceId": "city_sialkot",
  "countryId": "country_pakistan",
  "primaryLanguageCode": "ur",
  "isFeatured": true,
  "isTrending": false,
  "isVerified": true
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet updated successfully",
  "data": {
    "id": 123,
    "publicId": "poet_abc123",
    "gender": "MALE",
    "era": "MODERN",
    "birthYear": 1877,
    "deathYear": 1938,
    "isFeatured": true,
    "isTrending": false,
    "isVerified": true,
    "updatedAt": "2024-01-15T14:30:00"
  }
}
```

---

### 5.4.3 Add Poet Translation

**Endpoint:** `POST /api/poets/{publicId}/details`

**Authentication Required:** Yes (Admin only)

**Description:** Add or update poet's name and biography in another language

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "languageCode": "en",
  "name": "Allama Iqbal",
  "biography": "Muhammad Iqbal was a poet, philosopher, and politician...",
  "shortBio": "Poet of the East, philosopher and thinker"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Translation added successfully",
  "data": null
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Error adding translation: Language not found",
  "data": null
}
```

---

### 5.4.4 Add Poet Image

**Endpoint:** `POST /api/poets/{publicId}/images`

**Authentication Required:** Yes (Admin only)

**Description:** Add image to poet's gallery

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "imageUrl": "https://example.com/iqbal-portrait.jpg",
  "thumbnailUrl": "https://example.com/iqbal-portrait-thumb.jpg",
  "caption": "Portrait of Allama Iqbal",
  "altText": "Allama Iqbal portrait",
  "displayOrder": 1,
  "isProfileImage": true,
  "imageType": "PROFILE"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image added successfully",
  "data": null
}
```

**Note:** If `isProfileImage` is true, any existing profile image will be automatically unset.

---

### 5.4.5 Add Poet Book

**Endpoint:** `POST /api/poets/{publicId}/books`

**Authentication Required:** Yes (Admin only)

**Description:** Add book/publication to poet's bibliography

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "languageCode": "ur",
  "title": "Bang-e-Dara",
  "subtitle": "The Call of the Marching Bell",
  "description": "A collection of patriotic poetry",
  "yearPublished": 1924,
  "publisher": "Taj Company",
  "isbn": "978-1234567890",
  "isbn13": "978-1234567890123",
  "pageCount": 234,
  "coverImageUrl": "https://example.com/bang-e-dara.jpg",
  "displayOrder": 1,
  "isAvailable": true,
  "bookType": "POETRY_COLLECTION"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Book added successfully",
  "data": null
}
```

---

### 5.4.6 Add Poet Video

**Endpoint:** `POST /api/poets/{publicId}/videos`

**Authentication Required:** Yes (Admin only)

**Description:** Add video (mushaira, documentary, etc.) to poet's media

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "title": "Documentary: Life of Allama Iqbal",
  "description": "Complete biography documentary",
  "videoUrl": "https://youtube.com/watch?v=abc123",
  "thumbnailUrl": "https://img.youtube.com/vi/abc123/maxresdefault.jpg",
  "duration": 3600,
  "yearRecorded": 2015,
  "videoType": "DOCUMENTARY",
  "displayOrder": 1
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Video added successfully",
  "data": null
}
```

**Note:** Duration is in seconds

---

### 5.4.7 Add Poet Fact

**Endpoint:** `POST /api/poets/{publicId}/facts`

**Authentication Required:** Yes (Admin only)

**Description:** Add interesting fact about poet in all 3 languages at once

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "factsByLanguage": {
    "ur": "انہوں نے کیمبرج، لاہور اور میونخ میں تعلیم حاصل کی",
    "en": "Studied at Government College Lahore, Cambridge, and Munich",
    "hi": "लाहौर, कैम्ब्रिज और म्यूनिख में शिक्षा प्राप्त की"
  },
  "displayOrder": 1
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Fact added successfully",
  "data": null
}
```

**Note:** Must provide fact in all 3 languages. They are linked internally by a factGroupId.

---

### 5.4.8 Add Tag to Poet

**Endpoint:** `POST /api/poets/{publicId}/tags/{tagId}`

**Authentication Required:** Yes (Admin only)

**Description:** Associate a tag with the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `tagId`: Public ID of the tag

**Example:** `POST /api/poets/poet_abc123/tags/tag_ghazal123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tag added successfully",
  "data": null
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Error adding tag: Tag not found",
  "data": null
}
```

---

### 5.4.9 Delete Poet Image

**Endpoint:** `DELETE /api/poets/{publicId}/images/{imageId}`

**Authentication Required:** Yes (Admin only)

**Description:** Remove image from poet's gallery

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `imageId`: Public ID of the image

**Example:** `DELETE /api/poets/poet_abc123/images/img_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image deleted successfully",
  "data": null
}
```

---

### 5.4.10 Delete Poet Video

**Endpoint:** `DELETE /api/poets/{publicId}/videos/{videoId}`

**Authentication Required:** Yes (Admin only)

**Description:** Remove video from poet's media

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `videoId`: Public ID of the video

**Example:** `DELETE /api/poets/poet_abc123/videos/vid_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Video deleted successfully",
  "data": null
}
```

---

### 5.4.11 Delete Poet Book

**Endpoint:** `DELETE /api/poets/{publicId}/books/{bookId}`

**Authentication Required:** Yes (Admin only)

**Description:** Remove book from poet's bibliography

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `bookId`: Public ID of the book

**Example:** `DELETE /api/poets/poet_abc123/books/book_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Book deleted successfully",
  "data": null
}
```

---

### 5.4.12 Remove Tag from Poet

**Endpoint:** `DELETE /api/poets/{publicId}/tags/{tagId}`

**Authentication Required:** Yes (Admin only)

**Description:** Dissociate a tag from the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `tagId`: Public ID of the tag

**Example:** `DELETE /api/poets/poet_abc123/tags/tag_ghazal123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tag removed successfully",
  "data": null
}
```

---

## 5.5 Poet Follow System

**Base Path:** `/api/poets`

The Poet Follow System allows users to follow their favorite poets and receive personalized content recommendations.

### 5.5.1 Follow Poet {#451-follow-poet}

**Endpoint:** `POST /api/poets/{publicId}/follow`

**Authentication Required:** Yes

**Description:** Follow a poet to get personalized recommendations and updates.

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `POST /api/poets/poet_iqbal123/follow`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Now following poet",
  "data": {
    "following": true,
    "followerCount": 1523
  }
}
```

**Error Response (404):**
```json
{
  "success": false,
  "message": "Poet not found",
  "data": null
}
```

---

### 5.5.2 Unfollow Poet {#452-unfollow-poet}

**Endpoint:** `DELETE /api/poets/{publicId}/follow`

**Authentication Required:** Yes

**Description:** Unfollow a poet.

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `DELETE /api/poets/poet_iqbal123/follow`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Unfollowed poet",
  "data": {
    "following": false,
    "followerCount": 1522
  }
}
```

---

### 5.5.3 Get Following List {#453-get-following-list}

**Endpoint:** `GET /api/users/me/following?page=0&size=20`

**Authentication Required:** Yes

**Description:** Get list of poets the current user is following.

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 20)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Following list retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_iqbal123",
        "name": "علامہ اقبال",
        "profileImageUrl": "https://cdn.example.com/iqbal.jpg",
        "poemCount": 234,
        "followerCount": 1523,
        "followedAt": "2026-01-15T10:00:00"
      },
      {
        "publicId": "poet_faiz456",
        "name": "فیض احمد فیض",
        "profileImageUrl": "https://cdn.example.com/faiz.jpg",
        "poemCount": 189,
        "followerCount": 2341,
        "followedAt": "2026-01-20T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 12,
    "totalPages": 1,
    "last": true
  }
}
```

**Flutter Usage:**
```dart
Future<List<Poet>> getFollowingPoets() async {
  final response = await dio.get(
    '/api/users/me/following',
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );

  final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
  final content = apiResponse.data!['content'] as List;
  return content.map((json) => Poet.fromJson(json)).toList();
}
```

---

### 5.5.4 Check Follow Status {#454-check-follow-status}

**Endpoint:** `GET /api/poets/{publicId}/is-following`

**Authentication Required:** Yes

**Description:** Check if the current user is following a specific poet.

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/poets/poet_iqbal123/is-following`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Follow status retrieved",
  "data": {
    "isFollowing": true,
    "followedAt": "2026-01-15T10:00:00"
  }
}
```

**Use Cases:**
1. **Poet Profile Screen:** Show follow/unfollow button based on status
2. **Personalized Feed:** Display content from followed poets
3. **Following List:** Manage poets user is following

**Flutter Integration:**
```dart
class PoetProfileScreen extends StatefulWidget {
  final String poetId;

  Future<void> toggleFollow() async {
    if (isFollowing) {
      await dio.delete('/api/poets/$poetId/follow');
    } else {
      await dio.post('/api/poets/$poetId/follow');
    }
    setState(() => isFollowing = !isFollowing);
  }
}
```

---

## 5.6 Enum Values for Poet Endpoints

### Gender
- `MALE` - Male poet
- `FEMALE` - Female poet
- `OTHER` - Other/Non-binary

### Era
- `CLASSICAL` - Classical era (pre-1900)
- `MODERN` - Modern era (1900-1980)
- `CONTEMPORARY` - Contemporary (1980-present)
- `EMERGING` - Emerging/new poets

### VideoType
- `MUSHAIRA` - Poetry gathering
- `INTERVIEW` - Interview
- `DOCUMENTARY` - Documentary film
- `RECITATION` - Poetry recitation
- `BIOGRAPHY` - Biographical video
- `OTHER` - Other type

### BookType
- `POETRY_COLLECTION` - Collection of poems
- `ANTHOLOGY` - Anthology/compiled works
- `BIOGRAPHY` - Biographical book
- `CRITICISM` - Literary criticism
- `OTHER` - Other type

### ImageType
- `PROFILE` - Profile/main image
- `PORTRAIT` - Portrait photograph
- `HISTORICAL` - Historical photograph
- `EVENT` - Event/occasion photo
- `OTHER` - Other type

### TagType
- `POET_CATEGORY` - Poet categorization (e.g., "women-poets", "emerging-poets")
- `POEM_GENRE` - Poetry genre (e.g., "ghazal", "nazm")
- `GENERAL` - General tag
- `LANGUAGE` - Language-based tag
- `ERA` - Era-based tag

---

## 5.7 Notes for Poet Endpoints

1. **Multi-Language Support:**
   - All text fields (name, biography, shortBio) are stored separately for ur/en/hi
   - Use `?lang=ur` or `?lang=en` or `?lang=hi` to get data in specific language
   - Default language is Urdu (ur)
   - Geographic data (cities, countries) also have translations

2. **View Count Tracking:**
   - View count is automatically incremented when fetching poet profile
   - Use top/by-views endpoint to get most popular poets

3. **Profile Image:**
   - Only one image can be marked as profile image
   - When adding a new profile image, old one is automatically unset
   - Use gallery endpoint to get all images

4. **Books vs Translations:**
   - Books are stored in their ORIGINAL language only
   - Use `?lang=ur` parameter to filter books by language
   - No translation of book content

5. **Facts in Multiple Languages:**
   - Facts must be provided in all 3 languages when adding
   - They are internally linked by factGroupId
   - Use `?lang=ur` to get facts in specific language

6. **Tags for Categorization:**
   - Use tags to categorize poets (e.g., "ghazal-masters", "women-poets", "sufi-poets")
   - Filter poets by tag using `/api/poets/tags/{tagSlug}`
   - Tags have types (POET_CATEGORY, POEM_GENRE, etc.)

7. **Pagination:**
   - All list endpoints support pagination
   - Use standard `page` and `size` parameters
   - Default: page=0, size=10

8. **Sorting:**
   - Most endpoints support sorting via `sortBy` and `sortDir`
   - Common sort fields: name, birthYear, poemCount, viewCount
   - Sort direction: asc or desc

---

---

## 5.8 Global Search Endpoint (NEW)

### 5.8.1 Unified Search

**Endpoint:** `GET /api/search?q=محبت&type=all&lang=ur&page=0&size=10`

**Authentication Required:** Yes

**Description:**
Unified search across ALL content types: poems, verses, poets, and categories simultaneously.
This is the primary search endpoint for the application - provides comprehensive search results in a single request.

**Base Path:** `/api/search`

**Request Headers:**

---

## 6. Couplet Engagement System

### 6.1 Overview {#61-overview-couplets}

The Couplet Engagement System allows users to interact with individual couplets (verses) from Ghazals and other poetry. This fine-grained engagement enables users to like, bookmark, and share specific couplets rather than entire poems.

**Key Features:**
- ✅ **Couplet-Level Engagement**: Like, bookmark individual couplets
- 🔗 **Deep Linking**: Share specific couplets with shareable URLs
- 📊 **Analytics**: Track most liked, most shared, trending couplets
- 📱 **User Collections**: Personal collections of liked/bookmarked couplets
- 🎯 **Discovery**: Find popular couplets by poet or globally

**What is a Couplet?**
In Ghazal poetry, each two-line verse (sher) is called a couplet. The system automatically parses Ghazals into couplets for fine-grained interaction.

**Base Path:** `/api/couplets`, `/api/poems/{poemPublicId}/couplets`

**Authentication:** Required for all endpoints

---

### 6.2 Couplet Retrieval

#### 6.2.1 Get Couplets by Poem {#621-get-couplets-by-poem}

**Endpoint:** `GET /api/poems/{poemPublicId}/couplets?lang=ur`

**Authentication Required:** Yes

**Description:**
Get all couplets for a specific poem in the requested language. For Ghazals, this returns all verses parsed as couplets. For other poetry types, returns verses grouped by stanza.

**Path Parameters:**
- `poemPublicId` (required): Public ID of the poem

**Query Parameters:**
- `lang` (optional): Language code - `ur`, `en`, `hi` (defaults to poem's original language)

**Example:** `GET /api/poems/poem_xyz789/couplets?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplets retrieved successfully",
  "data": [
    {
      "publicId": "couplet_abc123",
      "coupletNumber": 1,
      "verses": [
        {
          "publicId": "verse_111",
          "verseText": "دل کی ویرانی کا کیا مذکور ہے",
          "verseNumber": 1,
          "verseType": "MATLA"
        },
        {
          "publicId": "verse_112",
          "verseText": "یہ نگر سو مرتبہ لوٹا گیا",
          "verseNumber": 2,
          "verseType": "MATLA"
        }
      ],
      "poemPublicId": "poem_xyz789",
      "contentPublicId": "content_ur_123",
      "likeCount": 45,
      "bookmarkCount": 23,
      "shareCount": 12,
      "createdAt": "2024-12-01T10:00:00"
    },
    {
      "publicId": "couplet_abc124",
      "coupletNumber": 2,
      "verses": [
        {
          "publicId": "verse_113",
          "verseText": "کوئی ویرانہ سا ویرانہ بنا کے",
          "verseNumber": 3,
          "verseType": null
        },
        {
          "publicId": "verse_114",
          "verseText": "دل کا صحرا بھی گلستاں بنا دیتے ہیں",
          "verseNumber": 4,
          "verseType": null
        }
      ],
      "likeCount": 67,
      "bookmarkCount": 34,
      "shareCount": 18
    }
  ]
}
```

**Flutter Usage:**
```dart
Future<List<Couplet>> getCoupletsByPoem(String poemId, String lang) async {
  final response = await dio.get(
    '/api/poems/$poemId/couplets',
    queryParameters: {'lang': lang},
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  
  final apiResponse = ApiResponse<List<dynamic>>.fromJson(response.data);
  return apiResponse.data!.map((json) => Couplet.fromJson(json)).toList();
}
```

---

#### 6.2.2 Get Couplet Detail {#622-get-couplet-detail}

**Endpoint:** `GET /api/couplets/{coupletPublicId}`

**Authentication Required:** Yes

**Description:**
Get detailed information about a specific couplet, including the user's like/bookmark status, poem context, and poet information.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Example:** `GET /api/couplets/couplet_abc123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet retrieved successfully",
  "data": {
    "couplet": {
      "publicId": "couplet_abc123",
      "coupletNumber": 1,
      "verses": [
        {
          "publicId": "verse_111",
          "verseText": "دل کی ویرانی کا کیا مذکور ہے",
          "verseNumber": 1,
          "verseType": "MATLA"
        },
        {
          "publicId": "verse_112",
          "verseText": "یہ نگر سو مرتبہ لوٹا گیا",
          "verseNumber": 2,
          "verseType": "MATLA"
        }
      ],
      "likeCount": 45,
      "bookmarkCount": 23,
      "shareCount": 12
    },
    "poem": {
      "publicId": "poem_xyz789",
      "title": "دل کی ویرانی",
      "poetryType": "GHAZAL"
    },
    "poet": {
      "publicId": "poet_ghalib123",
      "name": "Mirza Ghalib",
      "profileImageUrl": "https://cdn.example.com/ghalib.jpg"
    },
    "userStatus": {
      "isLiked": true,
      "isBookmarked": false
    }
  }
}
```

**Use Case:** Detail page when user taps on a shared couplet link

---

### 6.3 Engagement Actions

#### 6.3.1 Like Couplet {#631-like-couplet}

**Endpoint:** `POST /api/couplets/{coupletPublicId}/like`

**Authentication Required:** Yes

**Description:**
Toggle like status on a couplet. If already liked, it will unlike. Returns updated couplet details with new like count.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Example:** `POST /api/couplets/couplet_abc123/like`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet liked successfully",
  "data": {
    "couplet": {
      "publicId": "couplet_abc123",
      "coupletNumber": 1,
      "verses": [...],
      "likeCount": 46,
      "bookmarkCount": 23,
      "shareCount": 12
    },
    "userStatus": {
      "isLiked": true,
      "isBookmarked": false
    }
  }
}
```

**Flutter Usage:**
```dart
Future<CoupletDetail> toggleLikeCouplet(String coupletId) async {
  final response = await dio.post(
    '/api/couplets/$coupletId/like',
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  
  final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
  return CoupletDetail.fromJson(apiResponse.data!);
}

// UI Example
IconButton(
  icon: Icon(
    couplet.userStatus.isLiked ? Icons.favorite : Icons.favorite_border,
    color: couplet.userStatus.isLiked ? Colors.red : Colors.grey,
  ),
  onPressed: () async {
    final updated = await toggleLikeCouplet(couplet.publicId);
    setState(() {
      couplet = updated;
    });
  },
)
```

**Note:** Creates engagement activity record for personalization

---

#### 6.3.2 Bookmark Couplet {#632-bookmark-couplet}

**Endpoint:** `POST /api/couplets/{coupletPublicId}/bookmark?lang=ur`

**Authentication Required:** Yes

**Description:**
Toggle bookmark status on a couplet for later reference. Bookmarked couplets appear in user's collection. The language parameter preserves the language context in which the user bookmarked the content.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Query Parameters:**
- `lang` (optional, default: "ur"): Language code when bookmarking (ur, en, hi, etc.). This is stored with the bookmark so the content can be displayed in the bookmarked language later.

**Example:** `POST /api/couplets/couplet_abc123/bookmark?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet bookmarked successfully",
  "data": {
    "couplet": {
      "publicId": "couplet_abc123",
      "verses": [...],
      "likeCount": 46,
      "bookmarkCount": 24,
      "shareCount": 12
    },
    "userStatus": {
      "isLiked": true,
      "isBookmarked": true
    }
  }
}
```

---

#### 6.3.3 Share Couplet {#633-share-couplet}

**Endpoint:** `POST /api/couplets/{coupletPublicId}/share`

**Authentication Required:** Yes

**Description:**
Generate shareable link for a couplet with Open Graph metadata for social media sharing. Tracks share action for analytics.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Request Body:**
```json
{
  "shareType": "WHATSAPP"
}
```

**Share Types:**
- `WHATSAPP` - WhatsApp sharing
- `FACEBOOK` - Facebook sharing
- `TWITTER` - Twitter/X sharing
- `INSTAGRAM` - Instagram sharing (image required)
- `COPY_LINK` - Generic link copy
- `SMS` - SMS sharing
- `EMAIL` - Email sharing

**Success Response (200):**
```json
{
  "success": true,
  "message": "Share link created successfully",
  "data": {
    "shareUrl": "https://poetry.com/c/abc123-short",
    "deepLink": "poetry://couplet/couplet_abc123",
    "shareToken": "abc123xyz",
    "coupletPublicId": "couplet_abc123",
    "coupletNumber": 1,
    "coupletTypeBadge": "Matla (Opening Couplet)",
    "poemContext": "From 'دل کی ویرانی' by Mirza Ghalib",
    "poetName": "Mirza Ghalib",
    "poemPublicId": "poem_xyz789",
    "poemTitle": "دل کی ویرانی",
    "verseTexts": [
      "دل کی ویرانی کا کیا مذکور ہے",
      "یہ نگر سو مرتبہ لوٹا گیا"
    ],
    "ogTitle": "Mirza Ghalib - دل کی ویرانی",
    "ogDescription": "دل کی ویرانی کا کیا مذکور ہے\nیہ نگر سو مرتبہ لوٹا گیا",
    "ogImage": "https://cdn.poetry.com/couplets/abc123.jpg",
    "ogUrl": "https://poetry.com/c/abc123-short",
    "shareText": "دل کی ویرانی کا کیا مذکور ہے\nیہ نگر سو مرتبہ لوٹا گیا\n\n— Mirza Ghalib\nhttps://poetry.com/c/abc123-short"
  }
}
```

**Flutter Share Example:**
```dart
Future<void> shareCouplet(String coupletId, ShareType type) async {
  // Create share link
  final response = await dio.post(
    '/api/couplets/$coupletId/share',
    data: {'shareType': type.name},
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  
  final shareData = ShareLinkResponse.fromJson(response.data['data']);
  
  // Use Flutter Share package
  await Share.share(
    shareData.shareText,
    subject: shareData.ogTitle,
  );
  
  // Or use platform-specific sharing
  switch (type) {
    case ShareType.WHATSAPP:
      await launchUrl(Uri.parse('whatsapp://send?text=${Uri.encodeComponent(shareData.shareText)}'));
      break;
    case ShareType.COPY_LINK:
      await Clipboard.setData(ClipboardData(text: shareData.shareUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link copied to clipboard')),
      );
      break;
  }
}
```

**Use Case:** Share button in couplet card or detail view

---

#### 6.3.4 Get Public Share Link {#634-get-public-share-link}

**Endpoint:** `GET /api/couplets/{coupletPublicId}/share/public`

**Authentication Required:** No (Public endpoint)

**Description:**
Generate public share link without authentication. Used for generating share links in web views or when user is not logged in.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Example:** `GET /api/couplets/couplet_abc123/share/public`

**Success Response (200):**
Same as authenticated share endpoint

---

### 6.4 User Collections

#### 6.4.1 Get Liked Couplets {#641-get-liked-couplets}

**Endpoint:** `GET /api/users/me/couplets/liked?page=0&size=20&sortBy=createdAt&sortDir=desc`

**Authentication Required:** Yes

**Description:**
Get user's liked couplets with pagination and sorting. Returns couplets with full context (poem, poet).

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size
- `sortBy` (optional, default: `createdAt`): Sort field - `createdAt`, `likeCount`, `coupletNumber`
- `sortDir` (optional, default: `desc`): Sort direction - `asc`, `desc`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Liked couplets retrieved successfully",
  "data": {
    "content": [
      {
        "couplet": {
          "publicId": "couplet_abc123",
          "coupletNumber": 1,
          "verses": [
            {
              "verseText": "دل کی ویرانی کا کیا مذکور ہے",
              "verseNumber": 1
            },
            {
              "verseText": "یہ نگر سو مرتبہ لوٹا گیا",
              "verseNumber": 2
            }
          ],
          "likeCount": 46,
          "bookmarkCount": 24
        },
        "poem": {
          "publicId": "poem_xyz789",
          "title": "دل کی ویرانی",
          "poetryType": "GHAZAL"
        },
        "poet": {
          "publicId": "poet_ghalib123",
          "name": "Mirza Ghalib"
        },
        "likedAt": "2024-12-15T14:30:00",
        "isBookmarked": true
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 45,
    "totalPages": 3,
    "last": false
  }
}
```

**Flutter Widget Example:**
```dart
class LikedCoupletsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liked Couplets')),
      body: FutureBuilder<Page<CoupletLike>>(
        future: apiService.getUserLikedCouplets(page: 0),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final couplets = snapshot.data!.content;
          return ListView.builder(
            itemCount: couplets.length,
            itemBuilder: (context, index) {
              final item = couplets[index];
              return CoupletCard(
                couplet: item.couplet,
                poet: item.poet,
                poem: item.poem,
                isLiked: true,
                isBookmarked: item.isBookmarked,
              );
            },
          );
        },
      ),
    );
  }
}
```

---

#### 6.4.2 Get Bookmarked Couplets {#642-get-bookmarked-couplets}

**Endpoint:** `GET /api/users/me/couplets/bookmarked?page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get user's bookmarked couplets. Similar to liked couplets but for bookmarks.

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size  
- `sortBy` (optional, default: `createdAt`): Sort field
- `sortDir` (optional, default: `desc`): Sort direction

**Success Response (200):**
Same structure as liked couplets

---

### 6.5 Analytics & Discovery

#### 6.5.1 Most Liked Couplets {#651-most-liked-couplets}

**Endpoint:** `GET /api/analytics/couplets/most-liked?poetId={optional}&page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get most liked couplets globally or filtered by poet. Useful for discovery and "Popular Couplets" sections.

**Query Parameters:**
- `poetId` (optional): Filter by poet's public ID
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Example:** 
- Global: `GET /api/analytics/couplets/most-liked`
- By Poet: `GET /api/analytics/couplets/most-liked?poetId=poet_ghalib123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Most liked couplets retrieved",
  "data": {
    "content": [
      {
        "couplet": {
          "publicId": "couplet_xyz999",
          "coupletNumber": 5,
          "verses": [
            {
              "verseText": "ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے",
              "verseNumber": 9
            },
            {
              "verseText": "بہت نکلے مرے ارمان لیکن پھر بھی کم نکلے",
              "verseNumber": 10
            }
          ],
          "likeCount": 1234,
          "bookmarkCount": 567,
          "shareCount": 234
        },
        "poem": {
          "publicId": "poem_abc123",
          "title": "نقش فریادی"
        },
        "poet": {
          "publicId": "poet_ghalib123",
          "name": "Mirza Ghalib"
        },
        "ranking": 1
      }
    ],
    "totalElements": 100,
    "totalPages": 5
  }
}
```

**Use Case:** "Most Loved Couplets" section on home page

---

#### 6.5.2 Most Shared Couplets {#652-most-shared-couplets}

**Endpoint:** `GET /api/analytics/couplets/most-shared?poetId={optional}&page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get most shared couplets globally or by poet. Indicates viral/popular couplets.

**Query Parameters:**
Same as most liked couplets

**Success Response (200):**
Same structure as most liked couplets, sorted by `shareCount`

---

#### 6.5.3 Trending Couplets {#653-trending-couplets}

**Endpoint:** `GET /api/analytics/couplets/trending?days=7&page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get couplets that are trending based on recent engagement (likes + shares + bookmarks) in the specified time window.

**Query Parameters:**
- `days` (optional, default: 7): Number of days for trend calculation (7, 14, 30)
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Example:** `GET /api/analytics/couplets/trending?days=7`

**Success Response (200):**
Same structure as most liked couplets, with additional `trendScore` field

**Use Case:** "Trending This Week" section

---

#### 6.5.4 Couplet Analytics (NEW) {#654-couplet-analytics-new}

**Base Path:** `/api/analytics/couplets`

**Description:**
Comprehensive analytics endpoints for discovering popular and trending couplets. These endpoints power discovery features, trending sections, and personalized recommendations.

##### Most Liked Couplets

**Endpoint:** `GET /api/analytics/couplets/most-liked?poetId={optional}&page=0&size=20`

**Authentication Required:** No (Public endpoint)

**Description:**
Get the most liked couplets globally or filtered by specific poet. Perfect for "Popular Couplets" sections.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `poetId` | string | No | Filter by specific poet's public ID |
| `page` | number | No | Page number (default: 0) |
| `size` | number | No | Items per page (default: 20, max: 100) |

**Example Requests:**
```http
# Global most liked couplets
GET /api/analytics/couplets/most-liked?page=0&size=20

# Most liked couplets by Faiz
GET /api/analytics/couplets/most-liked?poetId=poet_faiz123&size=10
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Most liked couplets retrieved successfully",
  "data": {
    "content": [
      {
        "couplet": {
          "publicId": "couplet_abc123",
          "coupletNumber": 1,
          "verses": [
            {
              "verseText": "مجھ سے پہلی سی محبت مری محبوب نہ مانگ",
              "verseNumber": 1
            },
            {
              "verseText": "میں نے سمجھا تھا کہ تو ہے تو درخشاں ہے حیات",
              "verseNumber": 2
            }
          ],
          "likeCount": 2847,
          "bookmarkCount": 1234,
          "shareCount": 589
        },
        "poem": {
          "publicId": "poem_xyz789",
          "title": "مجھ سے پہلی سی محبت",
          "poetryType": "GHAZAL"
        },
        "poet": {
          "publicId": "poet_faiz123",
          "name": "فیض احمد فیض",
          "profileImageUrl": "https://cdn.example.com/faiz.jpg"
        },
        "engagementScore": 4670,
        "rank": 1
      }
    ],
    "totalElements": 1523,
    "totalPages": 77,
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    }
  }
}
```

**Flutter Usage:**
```dart
Future<List<CoupletWithContext>> getMostLikedCouplets({
  String? poetId,
  int page = 0,
  int size = 20,
}) async {
  final queryParams = {
    'page': page,
    'size': size,
    if (poetId != null) 'poetId': poetId,
  };

  final response = await dio.get(
    '/api/analytics/couplets/most-liked',
    queryParameters: queryParams,
  );

  final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
  final content = apiResponse.data!['content'] as List;
  return content.map((json) => CoupletWithContext.fromJson(json)).toList();
}
```

---

##### Most Shared Couplets

**Endpoint:** `GET /api/analytics/couplets/most-shared?poetId={optional}&page=0&size=20`

**Authentication Required:** No (Public endpoint)

**Description:**
Get the most shared couplets. Useful for identifying viral content and popular couplets for sharing.

**Query Parameters:**
Same as Most Liked endpoint.

**Example Requests:**
```http
# Global most shared couplets
GET /api/analytics/couplets/most-shared?page=0&size=20

# Most shared couplets by Iqbal
GET /api/analytics/couplets/most-shared?poetId=poet_iqbal123&size=10
```

**Success Response (200):**
Same structure as Most Liked, with `shareCount` being the primary sort field.

**Use Cases:**
1. **Viral Content Section:** "Most Shared Couplets This Month"
2. **Poet Profile:** Show most shared couplets on poet's profile page
3. **Share Suggestions:** Suggest popular couplets when user wants to share

---

##### Trending Couplets (with Timeframe)

**Endpoint:** `GET /api/analytics/couplets/trending?poetId={optional}&days=30&page=0&size=20`

**Authentication Required:** No (Public endpoint)

**Description:**
Get trending couplets based on recent engagement within a specified timeframe. Calculates trend score from likes, shares, and bookmarks weighted by recency.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `poetId` | string | No | Filter by specific poet |
| `days` | number | No | Timeframe for trending calculation (7, 14, 30) - default: 30 |
| `page` | number | No | Page number (default: 0) |
| `size` | number | No | Items per page (default: 20) |

**Example Requests:**
```http
# Trending in last 7 days
GET /api/analytics/couplets/trending?days=7&size=20

# Trending Ghalib couplets this month
GET /api/analytics/couplets/trending?poetId=poet_ghalib123&days=30&size=10
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Trending couplets retrieved successfully",
  "data": {
    "content": [
      {
        "couplet": {
          "publicId": "couplet_def456",
          "verses": [...],
          "likeCount": 456,
          "bookmarkCount": 234,
          "shareCount": 128
        },
        "poem": {...},
        "poet": {...},
        "trendScore": 892.5,
        "trendRank": 1,
        "periodDays": 7
      }
    ],
    "totalElements": 234,
    "totalPages": 12
  }
}
```

**Trend Score Calculation:**
```
trendScore = (likesInPeriod * 1.0) +
             (sharesInPeriod * 2.5) +
             (bookmarksInPeriod * 1.5)

With recency boost for very recent engagements
```

**Use Cases:**
1. **Home Screen:** "Trending This Week" widget
2. **Discovery:** Help users discover currently popular couplets
3. **Notifications:** Alert users about trending content from followed poets
4. **Poet Profile:** Show trending couplets on poet's page

**Flutter Integration Example:**
```dart
class DiscoveryScreen extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Trending this week
        TrendingCoupletsWidget(days: 7),

        // Most liked all time
        MostLikedCoupletsWidget(),

        // Most shared this month
        MostSharedCoupletsWidget(),
      ],
    );
  }
}

class TrendingCoupletsWidget extends StatelessWidget {
  final int days;

  Future<List<CoupletWithContext>> loadTrendingCouplets() async {
    final response = await dio.get(
      '/api/analytics/couplets/trending',
      queryParameters: {'days': days, 'size': 10},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
    final content = apiResponse.data!['content'] as List;
    return content.map((json) => CoupletWithContext.fromJson(json)).toList();
  }
}
```

**Performance Notes:**
- Analytics endpoints are cached for 5-15 minutes
- No authentication required - safe for public discovery
- Optimized queries with database indices
- Response times < 200ms for most queries

---

### 6.6 Use Cases & Workflows {#66-use-cases-workflows}

**1. Display Poem with Couplets:**
```
GET /api/poems/{poemId}/couplets?lang=ur
→ Display each couplet with like/bookmark buttons
→ User can engage with individual couplets
```

**2. Like a Couplet:**
```
User taps ❤️ button
→ POST /api/couplets/{coupletId}/like
→ Update UI with new like count and status
→ Show animation feedback
```

**3. Share Couplet to WhatsApp:**
```
User taps Share → WhatsApp
→ POST /api/couplets/{coupletId}/share (shareType: WHATSAPP)
→ Get shareText and shareUrl
→ Open WhatsApp with pre-filled text
```

**4. View User's Favorite Couplets:**
```
Navigate to "My Favorites" tab
→ GET /api/users/me/couplets/liked
→ Display paginated list with infinite scroll
→ Show poem/poet context for each couplet
```

**5. Discover Popular Couplets:**
```
Home screen "Most Loved" section
→ GET /api/analytics/couplets/most-liked?size=10
→ Display top 10 most liked couplets
→ User can tap to view poem context
```

**Complete Example - Couplet Card Widget:**
```dart
class CoupletCard extends StatefulWidget {
  final Couplet couplet;
  final Poet poet;
  final Poem poem;
  
  @override
  _CoupletCardState createState() => _CoupletCardState();
}

class _CoupletCardState extends State<CoupletCard> {
  late bool isLiked;
  late bool isBookmarked;
  late int likeCount;
  
  @override
  void initState() {
    super.initState();
    isLiked = widget.couplet.userStatus?.isLiked ?? false;
    isBookmarked = widget.couplet.userStatus?.isBookmarked ?? false;
    likeCount = widget.couplet.likeCount;
  }
  
  Future<void> _toggleLike() async {
    final updated = await apiService.toggleLikeCouplet(widget.couplet.publicId);
    setState(() {
      isLiked = updated.userStatus.isLiked;
      likeCount = updated.couplet.likeCount;
    });
  }
  
  Future<void> _shareCouplet() async {
    final shareData = await apiService.shareCouplet(
      widget.couplet.publicId, 
      ShareType.WHATSAPP
    );
    
    await Share.share(shareData.shareText);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Couplet verses (RTL for Urdu)
            ...widget.couplet.verses.map((verse) => 
              Text(
                verse.verseText,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18, fontFamily: 'NotoNastaliq'),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Poet and poem context
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.poet.profileImageUrl),
                  radius: 12,
                ),
                SizedBox(width: 8),
                Text(
                  '${widget.poet.name} - ${widget.poem.title}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                // Like button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$likeCount'),
                
                SizedBox(width: 16),
                
                // Bookmark button
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () async {
                    final updated = await apiService.toggleBookmarkCouplet(
                      widget.couplet.publicId
                    );
                    setState(() {
                      isBookmarked = updated.userStatus.isBookmarked;
                    });
                  },
                ),
                
                SizedBox(width: 16),
                
                // Share button
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey),
                  onPressed: _shareCouplet,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

**Notes:**
- Couplets are automatically created for Ghazals during poem creation/update
- Each couplet has its own engagement counters (likes, bookmarks, shares)
- Sharing creates deep links that work in web and mobile app
- Analytics endpoints are useful for discovery features
- All engagement actions create activity records for personalization

---


## 7. Image Poetry Generation

### 7.1 Overview

Create beautiful poetry images from couplets using pre-designed templates or custom backgrounds.

**Base Path:** `/api/image-templates`, `/api/couplets/{coupletId}/generate-image`

---

### 7.2 Browse Templates

**Endpoint:** `GET /api/image-templates?page=0&size=20`

Get available templates for image generation.

**Success Response:**
```json
{
  "success": true,
  "data": {
    "content": [{
      "publicId": "tmpl_abc123",
      "name": "Floral Elegance",
      "thumbnailUrl": "https://cdn.poetry.com/templates/thumbs/floral-001.jpg",
      "isPremium": false
    }]
  }
}
```

---

#### 7.2.3 Get Popular Templates (NEW) {#723-get-popular-templates-new}

**Endpoint:** `GET /api/image-templates/popular?limit=10`

**Authentication Required:** No (Public endpoint)

**Description:**
Get most popular templates based on usage count. Perfect for featuring trending templates in the app.

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `limit` | number | No | Number of templates to return (default: 10, max: 50) |

**Example Request:**
```http
GET /api/image-templates/popular?limit=10
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Popular templates retrieved successfully",
  "data": [
    {
      "publicId": "tmpl_abc123",
      "name": "Floral Elegance",
      "description": "Beautiful floral design with Urdu calligraphy",
      "thumbnailUrl": "https://cdn.poetry.com/templates/thumbs/floral-001.jpg",
      "imageUrl": "https://cdn.poetry.com/templates/floral-001.jpg",
      "isPremium": false,
      "usageCount": 2847,
      "rank": 1,
      "tags": ["floral", "elegant", "traditional"]
    },
    {
      "publicId": "tmpl_def456",
      "name": "Modern Minimalist",
      "description": "Clean and modern design for contemporary poetry",
      "thumbnailUrl": "https://cdn.poetry.com/templates/thumbs/modern-002.jpg",
      "imageUrl": "https://cdn.poetry.com/templates/modern-002.jpg",
      "isPremium": true,
      "usageCount": 1923,
      "rank": 2,
      "tags": ["modern", "minimalist", "clean"]
    }
  ]
}
```

**Flutter Usage:**
```dart
Future<List<ImageTemplate>> getPopularTemplates({int limit = 10}) async {
  final response = await dio.get(
    '/api/image-templates/popular',
    queryParameters: {'limit': limit},
  );

  final apiResponse = ApiResponse<List<dynamic>>.fromJson(response.data);
  return apiResponse.data!
      .map((json) => ImageTemplate.fromJson(json))
      .toList();
}

// UI Implementation
class PopularTemplatesSection extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<List<ImageTemplate>>(
      future: getPopularTemplates(limit: 5),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final template = snapshot.data![index];
            return TemplateCard(
              template: template,
              showUsageCount: true,
            );
          },
        );
      },
    );
  }
}
```

**Use Cases:**
1. **Template Selection Screen:** Show popular templates first
2. **Onboarding:** Display most popular templates to new users
3. **Homepage Widget:** "Popular Templates This Week"
4. **A/B Testing:** Compare usage patterns between templates

---

#### 7.2.4 Get Template Statistics (NEW) {#724-get-template-statistics-new}

**Endpoint:** `GET /api/image-templates/stats`

**Authentication Required:** No (Public endpoint)

**Description:**
Get comprehensive statistics about image templates, including total count, premium vs free breakdown, and usage metrics.

**Example Request:**
```http
GET /api/image-templates/stats
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Template statistics retrieved successfully",
  "data": {
    "totalTemplates": 156,
    "freeTemplates": 98,
    "premiumTemplates": 58,
    "totalUsage": 45678,
    "averageUsagePerTemplate": 293,
    "mostPopularTemplate": {
      "publicId": "tmpl_abc123",
      "name": "Floral Elegance",
      "usageCount": 2847
    },
    "recentlyAdded": 12,
    "categories": [
      {
        "category": "Traditional",
        "count": 45
      },
      {
        "category": "Modern",
        "count": 38
      },
      {
        "category": "Minimalist",
        "count": 32
      }
    ],
    "usageByMonth": [
      {
        "month": "2026-01",
        "totalUsage": 5634
      },
      {
        "month": "2025-12",
        "totalUsage": 4821
      }
    ]
  }
}
```

**Flutter Usage:**
```dart
class TemplateStatsResponse {
  final int totalTemplates;
  final int freeTemplates;
  final int premiumTemplates;
  final int totalUsage;
  final int averageUsagePerTemplate;

  TemplateStatsResponse.fromJson(Map<String, dynamic> json)
    : totalTemplates = json['totalTemplates'],
      freeTemplates = json['freeTemplates'],
      premiumTemplates = json['premiumTemplates'],
      totalUsage = json['totalUsage'],
      averageUsagePerTemplate = json['averageUsagePerTemplate'];
}

Future<TemplateStatsResponse> getTemplateStats() async {
  final response = await dio.get('/api/image-templates/stats');

  final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
  return TemplateStatsResponse.fromJson(apiResponse.data!);
}

// Analytics Dashboard
class TemplateAnalyticsDashboard extends StatelessWidget {
  Widget build(BuildContext context) {
    return FutureBuilder<TemplateStatsResponse>(
      future: getTemplateStats(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final stats = snapshot.data!;
        return Column(
          children: [
            StatCard(
              title: "Total Templates",
              value: stats.totalTemplates.toString(),
              subtitle: "${stats.freeTemplates} free, ${stats.premiumTemplates} premium",
            ),
            StatCard(
              title: "Total Usage",
              value: stats.totalUsage.toString(),
              subtitle: "Avg ${stats.averageUsagePerTemplate} per template",
            ),
          ],
        );
      },
    );
  }
}
```

**Use Cases:**
1. **Admin Dashboard:** Monitor template library health
2. **Product Analytics:** Track which template categories are popular
3. **Content Strategy:** Identify gaps in template offerings
4. **User Insights:** Understand user preferences for template styles

**Performance Notes:**
- Statistics are cached for 1 hour
- Lightweight query optimized for dashboard loading
- No authentication required for public stats

---

### 7.3 Generate Image

**Endpoint:** `POST /api/couplets/{coupletId}/generate-image`

Generate poetry image with template or custom background.

**Request (Template):**
```json
{
  "generationType": "SYSTEM",
  "templateId": "tmpl_abc123",
  "languageCode": "ur"
}
```

**Request (Custom):**
```json
{
  "generationType": "CUSTOM",
  "customBackgroundUrl": "https://s3.../user-bg.jpg",
  "languageCode": "ur"
}
```

**Success Response:**
```json
{
  "success": true,
  "data": {
    "publicId": "img_xyz789",
    "imageUrl": "https://cdn.poetry.com/generated/img_xyz789.jpg",
    "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_xyz789.jpg"
  }
}
```

---

### 7.4 Upload Custom Background

**Endpoint:** `POST /api/users/me/upload-background`

Upload custom image (multipart/form-data, max 5MB).

---

### 7.5 User Collections & Bookmarks

This section covers both traditional collections (save/favorite) and the new bookmark system for generated poetry images.

---

#### 7.5.1 Save Image to Collection

**Endpoint:** `POST /api/poetry-images/{imageId}/save`

**Authentication Required:** Yes

**Description:** Save a generated poetry image to user's collection with optional collection name and favorite flag.

**Path Parameters:**
- `imageId` (required): Public ID of the generated image

**Request Body:**
```json
{
  "collectionName": "My Favorites",
  "isFavorite": true
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image saved to collection"
}
```

---

#### 7.5.2 Get Saved Images

**Endpoint:** `GET /api/users/me/saved-images?page=0&size=20&collectionName=My%20Favorites&favoritesOnly=true`

**Authentication Required:** Yes

**Description:** Retrieve user's saved images with optional filtering by collection name or favorites.

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size
- `collectionName` (optional): Filter by specific collection name
- `favoritesOnly` (optional): If true, only return favorite images

**Success Response (200):**
```json
{
  "success": true,
  "message": "Saved images retrieved",
  "data": {
    "content": [{
      "publicId": "img_xyz789",
      "imageUrl": "https://cdn.poetry.com/generated/img_xyz789.jpg",
      "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_xyz789.jpg",
      "createdAt": "2024-01-15T10:30:00Z"
    }],
    "totalElements": 45,
    "totalPages": 3
  }
}
```

---

#### 7.5.3 Toggle Favorite

**Endpoint:** `POST /api/poetry-images/{imageId}/toggle-favorite`

**Authentication Required:** Yes

**Description:** Toggle favorite status on a saved image.

**Path Parameters:**
- `imageId` (required): Public ID of the generated image

**Success Response (200):**
```json
{
  "success": true,
  "message": "Favorite toggled",
  "data": true
}
```

---

#### 7.5.4 Remove from Collection

**Endpoint:** `DELETE /api/users/me/saved-images/{imageId}`

**Authentication Required:** Yes

**Description:** Remove a saved image from user's collection.

**Path Parameters:**
- `imageId` (required): Public ID of the generated image

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image removed from collection"
}
```

---

#### 7.5.5 Get Collection Names

**Endpoint:** `GET /api/users/me/collection-names`

**Authentication Required:** Yes

**Description:** Get list of all collection names created by the user.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Collection names retrieved",
  "data": [
    "My Favorites",
    "Ghalib Special",
    "Love Poetry"
  ]
}
```

---

#### 7.5.6 Get Collection Statistics

**Endpoint:** `GET /api/users/me/collection-stats`

**Authentication Required:** Yes

**Description:** Get statistics about user's image collections.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Stats retrieved",
  "data": {
    "totalImages": 45,
    "favoriteCount": 12,
    "collectionCount": 3,
    "collectionNames": [
      "My Favorites",
      "Ghalib Special",
      "Love Poetry"
    ]
  }
}
```

---

#### 7.5.7 Toggle Image Bookmark (NEW)

**Endpoint:** `POST /api/poetry-images/{imageId}/bookmark?lang=ur`

**Authentication Required:** Yes

**Description:**
Bookmark or unbookmark a poetry image (toggles). Works for **both** generated poetry images (`GeneratedPoetryImage`) and poet gallery images (`PoetImage`). The backend automatically detects the image type from the publicId. Similar to poem and couplet bookmarks, this preserves the language context in which the user bookmarked the image.

**Path Parameters:**
- `imageId` (required): Public ID of the generated poetry image OR poet gallery image

**Query Parameters:**
- `lang` (optional, default: "ur"): Language code when bookmarking (ur, en, hi, etc.). This is stored with the bookmark so the image can be displayed with the correct language context later.

**Example:** `POST /api/poetry-images/img_xyz789/bookmark?lang=ur`

**Success Response (200) - Bookmarked:**
```json
{
  "success": true,
  "message": "Image bookmarked successfully",
  "data": { "isBookmarked": true }
}
```

**Success Response (200) - Unbookmarked:**
```json
{
  "success": true,
  "message": "Bookmark removed successfully",
  "data": { "isBookmarked": false }
}
```

**Note:** Creates engagement activity record for personalization and analytics. The `bookmarkCount` on the image is updated automatically.

---

#### 7.5.8 Get Bookmarked Images (NEW)

**Endpoint:** `GET /api/users/me/image-bookmarks?page=0&size=20&lang=ur`

**Authentication Required:** Yes

**Description:**
Retrieve user's bookmarked images with optional language filtering. Bookmarks are returned in their original bookmarked language to preserve context.

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size
- `lang` (optional): Filter bookmarks by language code. If omitted, returns all bookmarked images regardless of language.

**Example:** `GET /api/users/me/image-bookmarks?page=0&size=20&lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmarked images retrieved successfully",
  "data": {
    "content": [{
      "publicId": "img_xyz789",
      "imageUrl": "https://cdn.poetry.com/generated/img_xyz789.jpg",
      "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_xyz789.jpg",
      "bookmarkedAt": "2024-01-15T10:30:00Z",
      "languageCode": "ur"
    }],
    "totalElements": 25,
    "totalPages": 2
  }
}
```

**Usage Notes:**
- Mixed language bookmarks: If a user has bookmarked images in multiple languages (Urdu, English, Hindi), omitting the `lang` parameter returns all bookmarks, each displaying in its original bookmarked language.
- Language filtering: Use `lang=ur` to see only Urdu bookmarks, `lang=en` for English, etc.
- This is separate from the collection system - an image can be both bookmarked AND saved to a collection.

---

#### 7.5.9 Check Image Bookmark Status (NEW)

**Endpoint:** `GET /api/poetry-images/{imageId}/is-bookmarked`

**Authentication Required:** Optional (returns false if not authenticated)

**Description:**
Check if a specific image is bookmarked by the current user. Works for both generated poetry images and poet gallery images.

**Path Parameters:**
- `imageId` (required): Public ID of the generated poetry image OR poet gallery image

**Example:** `GET /api/poetry-images/img_xyz789/is-bookmarked`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmark status",
  "data": true
}
```

**Note:** If user is not authenticated, returns `false` instead of 401 error.

---

#### 7.5.10 Like / Unlike Poet Gallery Image (NEW)

**Endpoint:** `POST /api/poetry-images/{imageId}/like`

**Authentication Required:** Yes

**Description:**
Toggle like/unlike on a poet gallery image (`PoetImage`). Each call flips the state — if not liked, it likes; if already liked, it unlikes. The `likeCount` on the image is updated automatically.

**Path Parameters:**
- `imageId` (required): Public ID of the poet gallery image

**Example:** `POST /api/poetry-images/img_gallery_abc/like`

**Success Response (200) - Liked:**
```json
{
  "success": true,
  "message": "Image liked successfully",
  "data": { "isLiked": true }
}
```

**Success Response (200) - Unliked:**
```json
{
  "success": true,
  "message": "Like removed successfully",
  "data": { "isLiked": false }
}
```

---

#### 7.5.11 Share Poet Gallery Image (NEW)

**Endpoint:** `POST /api/poetry-images/{imageId}/share?lang=ur`

**Authentication Required:** No (optional — tracks userId if authenticated)

**Description:**
Record a share event for a poet gallery image. Increments `shareCount`, tracks engagement, and returns pre-formatted content for the native share sheet — so Flutter can open the share sheet with no extra API calls beforehand.

Call this endpoint **after** the user taps the share button (before the share sheet opens) to get the share text and image URL. Do NOT call it before you have confirmed the user intends to share, but calling it to populate the share sheet is the intended use case.

**Path Parameters:**
- `imageId` (required): Public ID of the poet gallery image

**Query Parameters:**
- `lang` (optional, default `ur`): Language code for poet name in `shareText`

**Example:** `POST /api/poetry-images/img_gallery_abc/share?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Share recorded",
  "data": {
    "shareCount": 43,
    "shareImageUrl": "https://cdn.example.com/poets/faiz/gallery-abc.jpg",
    "shareText": "کچھ دن سے انتظار سوال بن گیا ہے\n\n— فیض احمد فیض"
  }
}
```

**Notes:**
- `shareText` is only present if the image has `contentText` set. If absent, build your own caption from `contentData` in the feed item.
- `shareImageUrl` is always the full-resolution image URL. Download it and pass to `share_plus` as a file attachment for rich sharing.
- If the image has no `contentText`, share `shareImageUrl` alone.

---

#### 7.5.12 Get Poet Gallery Image Status (NEW)

**Endpoint:** `GET /api/poetry-images/{imageId}/status`

**Authentication Required:** No (optional — `isLiked`/`isBookmarked` are false if not authenticated)

**Description:**
Get the full engagement status for a poet gallery image in a single call. Useful for initializing the UI state when opening the gallery viewer without making three separate calls.

**Path Parameters:**
- `imageId` (required): Public ID of the poet gallery image

**Example:** `GET /api/poetry-images/img_gallery_abc/status`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Status retrieved",
  "data": {
    "isLiked": true,
    "isBookmarked": false,
    "likeCount": 127,
    "bookmarkCount": 34,
    "shareCount": 42
  }
}
```

**Flutter Usage Pattern:**
```dart
// On gallery page open — fetch status once
final status = await api.getPoetImageStatus(imagePublicId);
setState(() {
  _isLiked = status['isLiked'];
  _isBookmarked = status['isBookmarked'];
  _likeCount = status['likeCount'];
});

// On like button tap
final result = await api.togglePoetImageLike(imagePublicId);
setState(() {
  _isLiked = result['isLiked'];
});

// On bookmark tap
final result = await api.togglePoetImageBookmark(imagePublicId);
setState(() {
  _isBookmarked = result['isBookmarked'];
});

// After share sheet is dismissed
await api.recordPoetImageShare(imagePublicId);
```

---

## 8. Book Management

### 8.1 Search Books

**Endpoint:** `GET /api/books/search?query=diwan&page=0&size=20`

Search poetry books across all poets.

**Success Response:**
```json
{
  "success": true,
  "data": {
    "content": [{
      "publicId": "book_abc123",
      "title": "Diwan-e-Ghalib",
      "poet": {"name": "Mirza Ghalib"},
      "downloadCount": 1234,
      "hasPdf": true,
      "hasEpub": false
    }]
  }
}
```

---

### 8.2 Download Book

**Endpoint:** `GET /api/poets/{poetId}/books/{bookId}/download?fileType=PDF`

Download book file (tracks download count).

**File Types:** `PDF`, `EPUB`, `EXTERNAL`

Returns CloudFront URL or redirects to external link.

---

## 8.5 Unified Bookmark API (Phase 3) ⭐ UPDATED

### 8.5.1 Overview - Unified Bookmarks

The Unified Bookmark API provides a single, consolidated interface for accessing bookmarks across all content types (poems, couplets, generated images).

**Key Features:**
- **Single Interface**: One API for all bookmark types
- **Mixed Content Feed**: All bookmarked content together, sorted by recency
- **Type Filtering**: Filter by specific content type
- **Sorting**: Sort poem/couplet lists by `likeCount` or `shareCount`
- **Poet Avatars**: `poetProfileImageUrl` for 36×36 poet thumbnails on cards
- **Content Sub-type Labels**: `contentSubType` / `contentSubTypeUrdu` badge text (e.g., "GHAZAL" / "غزل")
- **Bookmark Notes**: Add/update/clear personal notes on any bookmark
- **Cross-Content Search**: Search across all bookmarks in one call
- **Comprehensive Stats**: Aggregated stats with per-language breakdown

**Base Path:** `/api/bookmarks`

**All Endpoints Require Authentication (Bearer token)**

> **Null Field Behavior:** Fields that do not apply to a bookmark type, or have no value, are **omitted from the JSON response entirely**. Never send a placeholder like `"-"`. Check for field presence (or null-safety in Dart) rather than checking for `-`.

---

### 8.5.2 UnifiedBookmarkResponse — Complete Field Reference

All list/search endpoints return a `Page<UnifiedBookmarkResponse>`. The table below describes every field. Fields marked "omitted when null" are absent from the JSON when they have no value.

| Field | Type | Present for | Notes |
|-------|------|-------------|-------|
| `type` | String | All | `"POEM"`, `"COUPLET"`, or `"IMAGE"` |
| `bookmarkId` | String | All | Public ID of the bookmark (use in PATCH notes endpoint) |
| `contentId` | String | All | Public ID of the bookmarked content item |
| `languageCode` | String | All | `"ur"`, `"en"`, `"hi"` |
| `bookmarkedAt` | ISO 8601 | All | When the user bookmarked this item |
| `notes` | String | All | User's personal note — **omitted when null/empty** |
| `poetName` | String | POEM, COUPLET | Poet display name — omitted when null |
| `poetId` | String | POEM, COUPLET | Poet's public ID — omitted when null |
| `poetProfileImageUrl` | String | POEM, COUPLET | URL for poet's 36×36 avatar thumbnail — **omitted when null** |
| `contentSubType` | String | POEM, COUPLET | English sub-type enum name, e.g. `"GHAZAL"`, `"NAZM"` — omitted when null |
| `contentSubTypeUrdu` | String | POEM, COUPLET | Urdu display label, e.g. `"غزل"`, `"نظم"` — omitted when null |
| `poemTitle` | String | POEM | Poem title — omitted when null |
| `coupletFirstVerse` | String | COUPLET | First verse text — omitted when null |
| `coupletSecondVerse` | String | COUPLET | Second verse text — omitted when null |
| `parentPoemTitle` | String | COUPLET | Title of the poem containing this couplet — omitted when null |
| `parentPoemId` | String | COUPLET | Public ID of the parent poem — omitted when null |
| `imageUrl` | String | IMAGE | Full-size generated image URL |
| `thumbnailUrl` | String | IMAGE | Thumbnail URL |
| `templateName` | String | IMAGE | Name of the design template — **omitted when null** (custom/no template) |
| `likeCount` | Integer | All | Total likes on the content item |
| `bookmarkCount` | Integer | COUPLET, IMAGE | Total times bookmarked — omitted when null |
| `shareCount` | Integer | POEM, COUPLET | Total shares — omitted when null |

**Content Sub-type Values (`contentSubType`):**

| contentSubType | contentSubTypeUrdu |
|----------------|--------------------|
| `GHAZAL` | `غزل` |
| `NAZM` | `نظم` |
| `QASIDA` | `قصیدہ` |
| `RUBAI` | `رباعی` |
| `MARSIYA` | `مرثیہ` |
| `MASNAVI` | `مثنوی` |
| `HAMD` | `حمد` |
| `NAAT` | `نعت` |
| `SHER` | `شعر` |

---

### 8.5.3 Get Recent Bookmarks (All Types)

**Endpoint:** `GET /api/bookmarks/recent`

**Description:**
Mixed feed across ALL content types (poems, couplets, images), sorted by most recently bookmarked.

**Query Parameters:**

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `page` | No | `0` | Page number (0-based) |
| `size` | No | `20` | Items per page |
| `lang` | No | — | Filter by language code (`ur`, `en`, `hi`). Omit for all languages. |

**Example:** `GET /api/bookmarks/recent?page=0&size=20`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Recent bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "COUPLET",
        "bookmarkId": "bkmk_abc123",
        "contentId": "couplet_xyz789",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T14:30:00Z",
        "poetName": "Mirza Ghalib",
        "poetId": "poet_ghalib",
        "poetProfileImageUrl": "https://cdn.poetry.com/poets/ghalib_thumb.jpg",
        "contentSubType": "GHAZAL",
        "contentSubTypeUrdu": "غزل",
        "coupletFirstVerse": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
        "coupletSecondVerse": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
        "parentPoemTitle": "دیوان غالب",
        "parentPoemId": "poem_abc123",
        "likeCount": 145,
        "bookmarkCount": 89,
        "shareCount": 34
      },
      {
        "type": "POEM",
        "bookmarkId": "bkmk_def456",
        "contentId": "poem_pqr567",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T12:15:00Z",
        "notes": "My favourite Iqbal poem",
        "poetName": "Allama Iqbal",
        "poetId": "poet_iqbal",
        "poetProfileImageUrl": "https://cdn.poetry.com/poets/iqbal_thumb.jpg",
        "contentSubType": "NAZM",
        "contentSubTypeUrdu": "نظم",
        "poemTitle": "شکوہ",
        "likeCount": 892,
        "shareCount": 234
      },
      {
        "type": "IMAGE",
        "bookmarkId": "bkmk_ghi789",
        "contentId": "img_uvw890",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T10:00:00Z",
        "imageUrl": "https://cdn.poetry.com/generated/img_uvw890.jpg",
        "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_uvw890.jpg",
        "templateName": "Floral Elegance",
        "likeCount": 5,
        "bookmarkCount": 23
      }
    ],
    "totalElements": 45,
    "totalPages": 3,
    "number": 0,
    "size": 20
  }
}
```

> **Note:** The `notes` field appears only when the user has saved a note. The `poetProfileImageUrl` appears only when a photo exists for the poet. The `templateName` appears only when the image was created from a named template. Fields absent from JSON are equivalent to `null` in Dart.

---

### 8.5.4 Get Poem Bookmarks

**Endpoint:** `GET /api/bookmarks/poems`

**Description:**
POEM bookmarks only. Supports `sortBy` for custom ordering.

**Query Parameters:**

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `page` | No | `0` | Page number |
| `size` | No | `20` | Items per page |
| `lang` | No | — | Language filter |
| `sortBy` | No | `bookmarkedAt` | Sort order: `bookmarkedAt` \| `likeCount` \| `shareCount` |

**Examples:**
```bash
# Default (most recently bookmarked first)
GET /api/bookmarks/poems?lang=ur

# Most liked poems first
GET /api/bookmarks/poems?sortBy=likeCount

# Most shared poems first
GET /api/bookmarks/poems?sortBy=shareCount&lang=ur
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "POEM",
        "bookmarkId": "bkmk_def456",
        "contentId": "poem_pqr567",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T12:15:00Z",
        "poetName": "Allama Iqbal",
        "poetId": "poet_iqbal",
        "poetProfileImageUrl": "https://cdn.poetry.com/poets/iqbal_thumb.jpg",
        "contentSubType": "NAZM",
        "contentSubTypeUrdu": "نظم",
        "poemTitle": "شکوہ",
        "likeCount": 892,
        "shareCount": 234
      }
    ],
    "totalElements": 15,
    "totalPages": 1,
    "number": 0,
    "size": 20
  }
}
```

---

### 8.5.5 Get Couplet Bookmarks

**Endpoint:** `GET /api/bookmarks/couplets`

**Description:**
COUPLET bookmarks only. Supports `sortBy` for custom ordering.

**Query Parameters:**

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `page` | No | `0` | Page number |
| `size` | No | `20` | Items per page |
| `lang` | No | — | Language filter |
| `sortBy` | No | `bookmarkedAt` | Sort order: `bookmarkedAt` \| `likeCount` \| `shareCount` |

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "COUPLET",
        "bookmarkId": "bkmk_abc123",
        "contentId": "couplet_xyz789",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T14:30:00Z",
        "poetName": "Mirza Ghalib",
        "poetId": "poet_ghalib",
        "poetProfileImageUrl": "https://cdn.poetry.com/poets/ghalib_thumb.jpg",
        "contentSubType": "GHAZAL",
        "contentSubTypeUrdu": "غزل",
        "coupletFirstVerse": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
        "coupletSecondVerse": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
        "parentPoemTitle": "دیوان غالب",
        "parentPoemId": "poem_abc123",
        "likeCount": 145,
        "bookmarkCount": 89,
        "shareCount": 34
      }
    ],
    "totalElements": 20,
    "totalPages": 1,
    "number": 0,
    "size": 20
  }
}
```

---

### 8.5.6 Get Image Bookmarks

**Endpoint:** `GET /api/bookmarks/images`

**Description:**
Generated poetry image bookmarks only. Supports `sortBy` for custom ordering.

**Query Parameters:**

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `page` | No | `0` | Page number |
| `size` | No | `20` | Items per page |
| `lang` | No | — | Language filter |
| `sortBy` | No | `bookmarkedAt` | Sort order: `bookmarkedAt` \| `likeCount` \| `shareCount` |

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "IMAGE",
        "bookmarkId": "bkmk_ghi789",
        "contentId": "img_uvw890",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T10:00:00Z",
        "imageUrl": "https://cdn.poetry.com/generated/img_uvw890.jpg",
        "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_uvw890.jpg",
        "templateName": "Floral Elegance",
        "likeCount": 5,
        "bookmarkCount": 23
      },
      {
        "type": "IMAGE",
        "bookmarkId": "bkmk_jkl012",
        "contentId": "img_rst345",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-02T09:00:00Z",
        "imageUrl": "https://cdn.poetry.com/generated/img_rst345.jpg",
        "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_rst345.jpg",
        "likeCount": 2,
        "bookmarkCount": 7
      }
    ],
    "totalElements": 10,
    "totalPages": 1,
    "number": 0,
    "size": 20
  }
}
```

> **Note:** `templateName` is absent when the image was generated without a named template (custom composition). Do not show a template label if this field is missing.

---

### 8.5.7 Update Bookmark Notes ⭐ NEW

**Endpoint:** `PATCH /api/bookmarks/{type}/{bookmarkId}/notes`

**Description:**
Add, update, or clear the personal note on any bookmark. The `notes` field is user-only — it is never shared.

**Path Parameters:**

| Parameter | Required | Values |
|-----------|----------|--------|
| `type` | Yes | `poems` \| `couplets` \| `images` |
| `bookmarkId` | Yes | The `bookmarkId` string from the list response |

**Request Body:**
```json
{
  "notes": "This reminds me of my grandmother"
}
```

- `notes` (string, optional): Max 200 characters. Send `null` or `""` (empty string) to **clear** existing notes.

**Examples:**
```bash
# Add a note to a poem bookmark
PATCH /api/bookmarks/poems/bkmk_def456/notes
{ "notes": "My favourite Iqbal poem" }

# Add a note to a couplet bookmark
PATCH /api/bookmarks/couplets/bkmk_abc123/notes
{ "notes": "Perfect for morning reflection" }

# Clear notes from an image bookmark
PATCH /api/bookmarks/images/bkmk_ghi789/notes
{ "notes": null }
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmark notes updated successfully",
  "data": {
    "bookmarkId": "bkmk_def456",
    "notes": "My favourite Iqbal poem",
    "updatedAt": "2026-02-01T10:30:00Z"
  }
}
```

When notes are cleared (set to null/empty), `notes` is omitted from the response:
```json
{
  "success": true,
  "message": "Bookmark notes updated successfully",
  "data": {
    "bookmarkId": "bkmk_def456",
    "updatedAt": "2026-02-01T10:35:00Z"
  }
}
```

**Error Responses:**

| Status | Condition |
|--------|-----------|
| 400 | Invalid `type` path param (not poems/couplets/images) |
| 400 | Bookmark not found for given `bookmarkId` |
| 400 | Notes exceed 200 characters |
| 401 | Not authenticated |
| 403 | Bookmark belongs to a different user |
| 500 | Server error |

---

### 8.5.8 Search Bookmarks

**Endpoint:** `GET /api/bookmarks/search`

**Description:**
Search across ALL bookmarked content (poems, couplets, images) in one call. Searches:
- Poem titles and poet names
- Couplet verse text and parent poem titles
- Image template names and bookmark notes

**Query Parameters:**

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `query` | Yes | — | Search term (minimum 2 characters) |
| `page` | No | `0` | Page number |
| `size` | No | `20` | Items per page |
| `lang` | No | — | Filter by language code |

**Example:** `GET /api/bookmarks/search?query=دل&page=0`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 8 bookmarks matching 'دل'",
  "data": {
    "content": [
      {
        "type": "COUPLET",
        "bookmarkId": "bkmk_abc123",
        "contentId": "couplet_xyz789",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T14:30:00Z",
        "poetName": "Mirza Ghalib",
        "poetId": "poet_ghalib",
        "poetProfileImageUrl": "https://cdn.poetry.com/poets/ghalib_thumb.jpg",
        "contentSubType": "GHAZAL",
        "contentSubTypeUrdu": "غزل",
        "coupletFirstVerse": "دل کو تو آرام ہے فریاد کا موقع ہے",
        "coupletSecondVerse": "یہ دونوں باتیں تھیں اب کچھ کہنے کو باقی ہے",
        "parentPoemTitle": "دیوان غالب",
        "likeCount": 145,
        "shareCount": 34
      },
      {
        "type": "POEM",
        "bookmarkId": "bkmk_def456",
        "contentId": "poem_pqr567",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T12:00:00Z",
        "poetName": "Mir Taqi Mir",
        "poetId": "poet_mir",
        "contentSubType": "GHAZAL",
        "contentSubTypeUrdu": "غزل",
        "poemTitle": "دل کی ویرانی کا کیا مذکور ہے",
        "likeCount": 220,
        "shareCount": 60
      }
    ],
    "totalElements": 8,
    "totalPages": 1,
    "number": 0,
    "size": 20
  }
}
```

**Error Response (400) — Query too short:**
```json
{
  "success": false,
  "message": "Search query must be at least 2 characters"
}
```

---

### 8.5.9 Get Bookmark Statistics

**Endpoint:** `GET /api/bookmarks/stats`

**Description:**
Aggregated statistics about user's bookmarks across all types.

**Authentication:** Required

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmark statistics retrieved successfully",
  "data": {
    "totalBookmarks": 45,
    "poemBookmarks": 15,
    "coupletBookmarks": 20,
    "imageBookmarks": 10,
    "byLanguage": {
      "ur": 30,
      "en": 12,
      "hi": 3
    },
    "topPoets": [
      {
        "poetId": "poet_ghalib",
        "poetName": "Mirza Ghalib",
        "bookmarkCount": 18
      },
      {
        "poetId": "poet_iqbal",
        "poetName": "Allama Iqbal",
        "bookmarkCount": 12
      },
      {
        "poetId": "poet_faiz",
        "poetName": "Faiz Ahmed Faiz",
        "bookmarkCount": 8
      }
    ],
    "recentBookmarks": 7
  }
}
```

**Response Fields:**

| Field | Type | Description |
|-------|------|-------------|
| `totalBookmarks` | Integer | Total count across all types |
| `poemBookmarks` | Integer | Poem bookmark count |
| `coupletBookmarks` | Integer | Couplet bookmark count |
| `imageBookmarks` | Integer | Image bookmark count |
| `byLanguage` | Map\<String, Long\> | Breakdown by language code key |
| `topPoets` | Array | Top 5 poets by combined poem+couplet bookmarks |
| `recentBookmarks` | Integer | Bookmarks added in last 7 days |

> **Breaking change from previous version:** The language breakdown field was renamed from `bookmarksByLanguage` to `byLanguage`. Update any existing references.

---

### 8.5.10 Flutter Implementation Guide

#### Model Class

```dart
class UnifiedBookmark {
  final String type;           // "POEM" | "COUPLET" | "IMAGE"
  final String bookmarkId;
  final String contentId;
  final String languageCode;
  final DateTime bookmarkedAt;
  final String? notes;

  // POEM + COUPLET
  final String? poetName;
  final String? poetId;
  final String? poetProfileImageUrl;  // Use for 36x36 poet avatar
  final String? contentSubType;       // e.g. "GHAZAL"
  final String? contentSubTypeUrdu;   // e.g. "غزل"

  // POEM only
  final String? poemTitle;

  // COUPLET only
  final String? coupletFirstVerse;
  final String? coupletSecondVerse;
  final String? parentPoemTitle;
  final String? parentPoemId;

  // IMAGE only
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? templateName;   // null when custom — don't show template label

  // Engagement
  final int likeCount;
  final int? bookmarkCount;
  final int? shareCount;

  const UnifiedBookmark({
    required this.type,
    required this.bookmarkId,
    required this.contentId,
    required this.languageCode,
    required this.bookmarkedAt,
    required this.likeCount,
    this.notes,
    this.poetName,
    this.poetId,
    this.poetProfileImageUrl,
    this.contentSubType,
    this.contentSubTypeUrdu,
    this.poemTitle,
    this.coupletFirstVerse,
    this.coupletSecondVerse,
    this.parentPoemTitle,
    this.parentPoemId,
    this.imageUrl,
    this.thumbnailUrl,
    this.templateName,
    this.bookmarkCount,
    this.shareCount,
  });

  factory UnifiedBookmark.fromJson(Map<String, dynamic> json) {
    return UnifiedBookmark(
      type: json['type'] as String,
      bookmarkId: json['bookmarkId'] as String,
      contentId: json['contentId'] as String,
      languageCode: json['languageCode'] as String,
      bookmarkedAt: DateTime.parse(json['bookmarkedAt'] as String),
      likeCount: (json['likeCount'] as int?) ?? 0,
      notes: json['notes'] as String?,
      poetName: json['poetName'] as String?,
      poetId: json['poetId'] as String?,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      contentSubType: json['contentSubType'] as String?,
      contentSubTypeUrdu: json['contentSubTypeUrdu'] as String?,
      poemTitle: json['poemTitle'] as String?,
      coupletFirstVerse: json['coupletFirstVerse'] as String?,
      coupletSecondVerse: json['coupletSecondVerse'] as String?,
      parentPoemTitle: json['parentPoemTitle'] as String?,
      parentPoemId: json['parentPoemId'] as String?,
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      templateName: json['templateName'] as String?,
      bookmarkCount: json['bookmarkCount'] as int?,
      shareCount: json['shareCount'] as int?,
    );
  }
}
```

#### Use Case 1: Unified Bookmark Screen with Type-Based Rendering

```dart
Widget buildBookmarkCard(UnifiedBookmark bookmark) {
  switch (bookmark.type) {
    case 'POEM':
      return PoemBookmarkCard(
        title: bookmark.poemTitle,
        poetName: bookmark.poetName,
        poetAvatar: bookmark.poetProfileImageUrl,   // nullable — show placeholder if null
        subTypeBadge: bookmark.contentSubTypeUrdu,  // e.g. "غزل"
        notes: bookmark.notes,
        likeCount: bookmark.likeCount,
      );
    case 'COUPLET':
      return CoupletBookmarkCard(
        verse1: bookmark.coupletFirstVerse,
        verse2: bookmark.coupletSecondVerse,
        poemTitle: bookmark.parentPoemTitle,
        poetName: bookmark.poetName,
        poetAvatar: bookmark.poetProfileImageUrl,
        subTypeBadge: bookmark.contentSubTypeUrdu,
        notes: bookmark.notes,
      );
    case 'IMAGE':
      return ImageBookmarkCard(
        imageUrl: bookmark.imageUrl!,
        thumbnail: bookmark.thumbnailUrl,
        // Only show template label when it's not null/custom
        templateLabel: bookmark.templateName,
        notes: bookmark.notes,
      );
    default:
      return const SizedBox.shrink();
  }
}
```

#### Use Case 2: Dedicated Tabs with Sort

```
Bookmarks Screen
├── Tab "All"      → GET /api/bookmarks/recent
├── Tab "Poems"    → GET /api/bookmarks/poems?sortBy=bookmarkedAt
├── Tab "Couplets" → GET /api/bookmarks/couplets?sortBy=bookmarkedAt
└── Tab "Images"   → GET /api/bookmarks/images
```

```dart
// Sort dropdown inside Poems tab
DropdownButton<String>(
  value: _sortBy,
  items: const [
    DropdownMenuItem(value: 'bookmarkedAt', child: Text('Recently Added')),
    DropdownMenuItem(value: 'likeCount',    child: Text('Most Liked')),
    DropdownMenuItem(value: 'shareCount',   child: Text('Most Shared')),
  ],
  onChanged: (value) {
    setState(() => _sortBy = value!);
    _loadPoemBookmarks();
  },
);

Future<void> _loadPoemBookmarks() async {
  final response = await apiClient.get(
    '/api/bookmarks/poems?sortBy=$_sortBy&page=$_page&size=20',
  );
  // ...
}
```

#### Use Case 3: Add / Update / Clear Bookmark Notes

```dart
Future<void> saveBookmarkNote({
  required String type,        // "poems" | "couplets" | "images"
  required String bookmarkId,
  required String? notes,      // null to clear
}) async {
  final response = await apiClient.patch(
    '/api/bookmarks/$type/$bookmarkId/notes',
    body: jsonEncode({'notes': notes}),
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body)['data'];
    // data.notes may be absent if notes were cleared
    final savedNote = data['notes'] as String?;
    // update local state
  } else if (response.statusCode == 400) {
    showError('Notes too long (max 200 characters)');
  } else if (response.statusCode == 403) {
    showError('Cannot update another user\'s bookmark');
  }
}

// Add note
await saveBookmarkNote(
  type: 'poems',
  bookmarkId: bookmark.bookmarkId,
  notes: 'My favourite Iqbal poem',
);

// Clear note
await saveBookmarkNote(
  type: 'poems',
  bookmarkId: bookmark.bookmarkId,
  notes: null,
);
```

#### Use Case 4: Bookmark Statistics Dashboard

```dart
// BookmarkStats model
class BookmarkStats {
  final int totalBookmarks;
  final int poemBookmarks;
  final int coupletBookmarks;
  final int imageBookmarks;
  final Map<String, int> byLanguage;  // renamed from bookmarksByLanguage
  final List<TopPoet> topPoets;
  final int recentBookmarks;

  factory BookmarkStats.fromJson(Map<String, dynamic> json) {
    return BookmarkStats(
      totalBookmarks: json['totalBookmarks'] as int,
      poemBookmarks: json['poemBookmarks'] as int,
      coupletBookmarks: json['coupletBookmarks'] as int,
      imageBookmarks: json['imageBookmarks'] as int,
      byLanguage: Map<String, int>.from(
        (json['byLanguage'] as Map? ?? {}),  // key: byLanguage (not bookmarksByLanguage)
      ),
      topPoets: (json['topPoets'] as List? ?? [])
          .map((e) => TopPoet.fromJson(e as Map<String, dynamic>))
          .toList(),
      recentBookmarks: json['recentBookmarks'] as int? ?? 0,
    );
  }
}
```

#### Use Case 5: Language Filter

```dart
// Show only Urdu bookmarks
final response = await apiClient.get('/api/bookmarks/recent?lang=ur');

// Show only English bookmarks
final response = await apiClient.get('/api/bookmarks/recent?lang=en');

// Language counts from stats (for filter chip badges)
final stats = await apiClient.get('/api/bookmarks/stats');
final urduCount = stats.byLanguage['ur'] ?? 0;
```

---

**Summary of Changes vs. Previous Version**

| Change | Details |
|--------|---------|
| New fields | `poetProfileImageUrl`, `contentSubType`, `contentSubTypeUrdu` on POEM/COUPLET |
| Null behavior | All optional fields **omitted from JSON** when null — no more `"-"` placeholders |
| `templateName` | Now `null` (absent) when no template — was `"Custom"` before |
| Stats key rename | `bookmarksByLanguage` → `byLanguage` (**breaking change**) |
| New `sortBy` param | Added to `/poems`, `/couplets`, `/images` — values: `bookmarkedAt` \| `likeCount` \| `shareCount` |
| New endpoint | `PATCH /api/bookmarks/{type}/{bookmarkId}/notes` — add/update/clear personal notes |

---

## 9. Comments

### 9.1 Create Comment

**Endpoint:** `POST /api/poems/{poemId}/comments`

```json
{
  "commentText": "Beautiful ghazal!",
  "parentCommentPublicId": null
}
```

---

### 9.2 Get Comments

**Endpoint:** `GET /api/poems/{poemId}/comments?page=0&size=10`

Returns threaded comments with replies.

---

### 9.3 Delete Comment

**Endpoint:** `DELETE /api/poems/{poemId}/comments/{commentId}`

Soft delete (shows as "[deleted]").

---

### 9.4 Get Comment Count

**Endpoint:** `GET /api/poems/{poemId}/comments/count`

---

## 10. Global Search

### 10.1 Unified Search

**Endpoint:** `GET /api/search?q={query}&type={type}&lang={lang}&page={page}&size={size}`

**Description:** Search across all content types (poems, verses, poets, couplets, categories, tags) with a unified interface. Powered by Elasticsearch with PostgreSQL fallback. Returns paginated results **per content type** with full metadata needed for "load more" and tab counts.

**Query Parameters:**

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `q` | Yes | — | Search query |
| `type` | No | `all` | `all`, `poems_only`, `verses_only`, `poets_only`, `couplets_only`, `tags_only`, `categories_only` |
| `lang` | No | `ur` | Language code: `ur`, `en`, `hi` |
| `script` | No | auto-detected | Script: `ARABIC`, `ROMAN`, `DEVANAGARI`, `LATIN` |
| `page` | No | `0` | Page number (0-based) |
| `size` | No | `10` | Items per page **per content type** |

> **Important:** `page` and `size` apply independently to each content type. A request with `size=10` and `type=all` can return up to 60 items total (10 per type).

**Example Requests:**

```bash
# Initial search — page 0
curl "http://localhost:8081/api/search?q=duniya&type=all&lang=ur&page=0&size=10"

# Load more poems — page 1
curl "http://localhost:8081/api/search?q=duniya&type=poems_only&lang=ur&page=1&size=10"

# Load more verses — page 2
curl "http://localhost:8081/api/search?q=duniya&type=verses_only&lang=ur&page=2&size=10"

# Search poets only
curl "http://localhost:8081/api/search?q=غالب&type=poets_only&lang=ur"
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 23 total results (5 poems, 10 verses, 3 poets)",
  "data": {
    "poems": [ /* up to `size` PoemSummaryResponse objects */ ],
    "verses": [ /* up to `size` VerseSearchResult objects (deduplicated) */ ],
    "poets": [ /* up to `size` PoetSummaryResponse objects */ ],
    "couplets": [ /* up to `size` CoupletDto objects */ ],
    "tags": [ /* up to `size` TagDto objects */ ],
    "categories": [ /* up to `size` CategoryDto objects */ ],

    "poemCount": 5,
    "verseCount": 10,
    "poetCount": 3,
    "coupletCount": 5,
    "tagCount": 0,
    "categoryCount": 0,
    "totalResults": 23,

    "totalPoems": 847,
    "totalVerses": 1243,
    "totalPoets": 12,
    "totalCouplets": 98,
    "totalTags": 0,
    "totalCategories": 2,

    "hasMorePoems": true,
    "hasMoreVerses": true,
    "hasMorePoets": false,
    "hasMoreCouplets": true,
    "hasMoreTags": false,
    "hasMoreCategories": false,

    "currentPage": 0,
    "pageSize": 10,

    "counts": {
      "poems": 5,
      "verses": 10,
      "poets": 3,
      "couplets": 5,
      "tags": 0,
      "categories": 0,
      "total": 23,
      "totalPoems": 847,
      "totalVerses": 1243,
      "totalPoets": 12,
      "totalCouplets": 98,
      "totalTags": 0,
      "totalCategories": 2
    }
  }
}
```

**Response Field Reference:**

| Field | Type | Description |
|-------|------|-------------|
| `poems/verses/poets/...` | Array | Items in the **current page** |
| `poemCount` / `verseCount` / ... | Integer | Count of items in current page (= array length) |
| `totalPoems` / `totalVerses` / ... | Long | **Total matching records in DB/ES** — use for tab labels like "Poems (847)" |
| `hasMorePoems` / `hasMoreVerses` / ... | Boolean | `true` if more pages exist for that type — use to show/hide "Load More" button |
| `currentPage` | Integer | Current page number (0-based, echoed from request) |
| `pageSize` | Integer | Page size used (echoed from request) |
| `totalResults` | Integer | Sum of all items in the **current page** (not the grand total) |
| `counts` | Object | Structured version of the counts above — convenient for tab UI |

**Pagination Workflow:**

```
Step 1: Initial search (type=all, page=0, size=10)
  → Shows first 10 results of each type
  → Use `totalPoems`, `totalVerses` etc. for tab labels: "Poems (847)"
  → Use `hasMorePoems`, `hasMoreVerses` etc. to show "Load More" per tab

Step 2: User taps "Load More" on Poems tab
  → GET /api/search?q=duniya&type=poems_only&page=1&size=10
  → Append to existing poems list

Step 3: User taps "Load More" again
  → GET /api/search?q=duniya&type=poems_only&page=2&size=10
  → Stop when hasMorePoems = false
```

**Flutter Implementation:**

```dart
class SearchResult {
  final List<dynamic> items;
  final int totalInDb;     // e.g. totalPoems
  final bool hasMore;      // e.g. hasMorePoems
  final int currentPage;

  const SearchResult({
    required this.items,
    required this.totalInDb,
    required this.hasMore,
    required this.currentPage,
  });
}

class SearchService {
  final Dio _dio;

  // Initial search — fetches all content types at once
  Future<Map<String, dynamic>> searchAll({
    required String query,
    String lang = 'ur',
    int size = 10,
  }) async {
    final response = await _dio.get('/api/search', queryParameters: {
      'q': query,
      'type': 'all',
      'lang': lang,
      'page': 0,
      'size': size,
    });
    return response.data['data'];
  }

  // Load more for a specific type — call when user taps "Load More"
  Future<Map<String, dynamic>> loadMore({
    required String query,
    required String type,   // 'poems_only', 'verses_only', 'poets_only', etc.
    required int page,      // increment this each call
    String lang = 'ur',
    int size = 10,
  }) async {
    final response = await _dio.get('/api/search', queryParameters: {
      'q': query,
      'type': type,
      'lang': lang,
      'page': page,
      'size': size,
    });
    return response.data['data'];
  }
}

// In your search state/provider:
class SearchState extends ChangeNotifier {
  List<dynamic> poems = [];
  int totalPoems = 0;
  bool hasMorePoems = false;
  int nextPoemsPage = 1;

  Future<void> initialSearch(String query) async {
    final data = await searchService.searchAll(query: query);

    poems = List.from(data['poems']);
    totalPoems = data['totalPoems'] ?? 0;
    hasMorePoems = data['hasMorePoems'] ?? false;
    nextPoemsPage = 1;
    notifyListeners();
  }

  Future<void> loadMorePoems(String query) async {
    if (!hasMorePoems) return;

    final data = await searchService.loadMore(
      query: query,
      type: 'poems_only',
      page: nextPoemsPage,
    );

    poems.addAll(data['poems']);
    hasMorePoems = data['hasMorePoems'] ?? false;
    nextPoemsPage++;
    notifyListeners();
  }
}

// Tab label widget:
Text('Poems (${totalPoems > 0 ? totalPoems : ''})');

// Load More button:
if (hasMorePoems)
  ElevatedButton(
    onPressed: () => state.loadMorePoems(query),
    child: const Text('Load More Poems'),
  )
```

**Type Values Reference:**

| `type` param | Searches |
|---|---|
| `all` | All 6 content types simultaneously |
| `poems_only` | Poems only |
| `verses_only` | Verses only |
| `poets_only` | Poets only |
| `couplets_only` | Couplets only |
| `tags_only` | Tags only |
| `categories_only` | Categories only |

**Use Cases:**
- Main search bar showing all results grouped by type
- Tabbed search results UI (Poems tab, Poets tab, Verses tab)
- "Load More" per tab without re-searching other types
- Tab labels showing total DB count: "Poems (847)"

---

### 10.2 Quick Search

**Endpoint:** `GET /api/search/quick?q={query}&lang={lang}`

**Description:** Simplified search endpoint — searches all content types at page 0, size 10. Shorthand for `/api/search?type=all&page=0&size=10`. Returns the same response format as Unified Search including all pagination metadata.

**Query Parameters:**
- `q` (required) - Search query
- `lang` (optional, default: `ur`) - Language code

**Example Request:**
```bash
curl "http://localhost:8081/api/search/quick?q=love&lang=en"
```

**Success Response (200):**
Same format as Unified Search — includes `totalPoems`, `hasMorePoems`, `currentPage`, etc.

> Use Quick Search only for initial discovery. For "load more", switch to the full `/api/search` endpoint with explicit `type` and `page` parameters.

---

### 10.3 Couplet Search

**Endpoint:** `GET /api/search/couplets?q={query}&sort={sort}&lang={lang}`

**Description:** Search specifically for couplets (شعر/اشعار) with advanced filtering and sorting options. Supports multilingual search across Urdu (Arabic/Roman), English, and Hindi. Returns individual couplets with engagement metrics.

**Query Parameters:**
- `q` (required) - Search query text
- `poet` (optional) - Filter by poet public ID
- `poem` (optional) - Filter by poem public ID
- `category` (optional) - Filter by category public ID
- `tags` (optional, repeatable) - Filter by hashtag slugs (AND logic — all must be present). E.g. `tags=ishq&tags=ghazal`
- `sort` (optional, default: `relevance`) - Sort order
  - `relevance` - Best match based on BM25 scoring
  - `likes` - Most liked couplets
  - `shares` - Most shared couplets
  - `bookmarks` - Most bookmarked couplets
  - `trending` - Highest engagement score
  - `recent` - Most recently created
- `lang` (optional, default: `ur`) - Language code (ur, en, hi)
- `script` (optional) - Script filter (ARABIC, ROMAN, DEVANAGARI, LATIN)
- `page` (optional, default: `0`) - Page number (zero-indexed)
- `size` (optional, default: `10`, max: 50) - Results per page

**Example Requests:**

**Search all couplets:**
```bash
curl "http://localhost:8081/api/search/couplets?q=love&lang=en&sort=relevance"
```

**Search by poet:**
```bash
curl "http://localhost:8081/api/search/couplets?q=محبت&poet=mirza-ghalib&sort=likes&lang=ur"
```

**Trending couplets:**
```bash
curl "http://localhost:8081/api/search/couplets?q=*&sort=trending&size=20"
```

**Most liked couplets:**
```bash
curl "http://localhost:8081/api/search/couplets?q=*&sort=likes&size=20"
```

**Response Format:**
```json
{
  "success": true,
  "message": "Couplets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "abc123",
        "coupletNumber": 3,
        "coupletType": "MISRA",
        "verses": [
          {
            "verseText": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
            "verseNumber": 1,
            "languageCode": "ur"
          },
          {
            "verseText": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
            "verseNumber": 2,
            "languageCode": "ur"
          }
        ],
        "poem": {
          "publicId": "poem123",
          "title": "غزل نمبر ۱",
          "poetName": "مرزا غالب"
        },
        "poet": {
          "publicId": "mirza-ghalib",
          "name": "مرزا غالب",
          "profileImageUrl": "https://cdn.example.com/poets/ghalib.jpg"
        },
        "likeCount": 245,
        "shareCount": 89,
        "bookmarkCount": 156,
        "engagementScore": 623.5,
        "isLiked": false,
        "isBookmarked": true
      }
    ],
    "totalElements": 45,
    "totalPages": 5,
    "pageNumber": 0,
    "pageSize": 10,
    "last": false,
    "first": true
  }
}
```

**Engagement Score Calculation:**
`engagementScore = (likes × 1.0) + (shares × 2.0) + (bookmarks × 1.5)`

**Search Features:**
- **Multilingual:** Automatically detects script (Arabic, Roman, Devanagari)
- **Fuzzy Matching:** Handles typos and variations (AUTO fuzziness)
- **Field Boosting:** Verse text gets higher relevance boost
- **Hybrid Fallback:** Automatically falls back to PostgreSQL if Elasticsearch unavailable

**Use Cases:**
1. **Trending Couplets:** `?sort=trending&size=20`
2. **Poet's Popular Couplets:** `?poet=faiz-ahmed-faiz&sort=likes`
3. **Search by Theme:** `?q=عشق&sort=relevance`
4. **Most Bookmarked:** `?sort=bookmarks&page=0`

---

### 10.5 Autocomplete

**Endpoint:** `GET /api/search/autocomplete?q={query}&lang={lang}`

**Description:** Real-time search suggestions across multiple content types (poets, poems, tags, categories). Designed for instant search-as-you-type experiences with minimal latency (<200ms).

**Query Parameters:**
- `q` (required) - Search query (minimum 2 characters)
- `lang` (optional, default: `ur`) - Language code

**Example Requests:**

**English Query:**
```bash
curl "http://localhost:8081/api/search/autocomplete?q=gha&lang=en"
```

**Urdu Query:**
```bash
curl "http://localhost:8081/api/search/autocomplete?q=love&lang=en"
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 5 suggestions",
  "data": {
    "poets": [
      {
        "publicId": "cc44d698-c4e2-4375-839b-f5ddfa05b167",
        "name": "Mirza Ghalib",
        "profileImageUrl": "-",
        "era": "CLASSICAL",
        "score": 2.0
      }
    ],
    "poems": [],
    "tags": [],
    "categories": [
      {
        "publicId": "efb77fbf-2937-46a0-97f9-8d9a49ddd575",
        "name": "Love Poetry",
        "slug": "love-poetry",
        "parentCategoryName": "Thematic Poetry",
        "poemCount": 0,
        "score": 3.0
      }
    ],
    "totalCount": 5
  }
}
```

**Error Response (400) - Query too short:**
```json
{
  "success": false,
  "message": "Query must be at least 2 characters",
  "data": null
}
```

**Result Limits:**
- Poets: 3 results
- Poems: 5 results
- Tags: 3 results
- Categories: 3 results
- **Total:** Maximum 14 suggestions per query

**Technical Features:**
- **Edge N-gram Tokenizer:** min_gram: 2, max_gram: 15
- **Prefix Matching:** Optimized for partial word matching
- **Relevance Scoring:** Higher scores for exact prefix matches
- **Caching:** Redis cache (TTL: 5 minutes)

**Flutter Implementation Example:**
```dart
// Debounce search input (300-500ms)
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 300), () {
    if (query.length >= 2) {
      _searchService.getAutocompleteSuggestions(query);
    }
  });
}
```

**UI Rendering:**
- Display results grouped by type (Poets, Poems, Tags, Categories)
- Show avatar/icon for each type
- Highlight matching text
- Handle navigation to appropriate detail screen on tap

---

### 10.5.1 Structured Autocomplete (Suggest) ⭐ NEW

**Endpoint:** `GET /api/search/suggest?q={query}&lang={lang}&limit={limit}`

**Description:** Enhanced autocomplete endpoint with flat, sorted suggestion list. Returns unified suggestions across all content types in a single sorted array (by score), making it easier to render in UI. This is the **recommended** endpoint for new implementations.

**Query Parameters:**
- `q` (required) - Search query (minimum 2 characters)
- `lang` (optional, default: `ur`) - Language code (ur, en, hi)
- `limit` (optional, default: `10`, max: `20`) - Maximum number of suggestions

**Example Requests:**

**English Query:**
```bash
curl "http://localhost:8081/api/search/suggest?q=love&lang=en&limit=5"
```

**Urdu Query:**
```bash
curl "http://localhost:8081/api/search/suggest?q=غالب&lang=ur&limit=10"
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 3 suggestions",
  "data": {
    "suggestions": [
      {
        "text": "Love Poetry",
        "type": "CATEGORY",
        "publicId": "efb77fbf-2937-46a0-97f9-8d9a49ddd575",
        "score": 3.0,
        "icon": "📁",
        "subtitle": "Poetry expressing romantic and divine love"
      },
      {
        "text": "Mirza Ghalib",
        "type": "POET",
        "publicId": "cc44d698-c4e2-4375-839b-f5ddfa05b167",
        "score": 2.5,
        "icon": "👤",
        "subtitle": "Classical Era · 1797-1869"
      },
      {
        "text": "Dil Ki Basti",
        "type": "POEM",
        "publicId": "xyz789",
        "score": 2.0,
        "icon": "📜",
        "subtitle": "Nasir Kazmi"
      }
    ],
    "totalCount": 3,
    "query": "love"
  }
}
```

**Response Format:**

Each suggestion includes:
- `text` - Display text (poet name, poem title, category name, etc.)
- `type` - Content type: `POET`, `POEM`, `CATEGORY`, `TAG`, `VERSE`
- `publicId` - Unique identifier for navigation
- `score` - Relevance score (higher = more relevant)
- `icon` - Emoji icon for UI display
  - 👤 Poet
  - 📜 Poem
  - 📁 Category
  - 🏷️ Tag
  - 📝 Verse
- `subtitle` - Context information (null if not applicable)
  - Poet: "Classical Era · 1797-1869"
  - Poem: "Poet Name"
  - Category: Description
  - Verse: Poem title

**Key Improvements over `/autocomplete`:**
1. **Flat Structure:** Single sorted array instead of grouped by type
2. **UI-Ready:** Includes icons and subtitles for instant rendering
3. **Strict Null Handling:** No placeholder values ("Unknown", "Untitled") - uses null instead
4. **Score-Sorted:** Results sorted by relevance score (highest first)
5. **Simpler Parsing:** No need to iterate through multiple arrays

**Flutter Implementation Example:**
```dart
class SearchSuggestion {
  final String text;
  final String type;
  final String publicId;
  final double score;
  final String icon;
  final String? subtitle;

  // Navigate based on type
  void navigate(BuildContext context) {
    switch (type) {
      case 'POET':
        Navigator.push(context, PoetDetailScreen(poetId: publicId));
        break;
      case 'POEM':
        Navigator.push(context, PoemDetailScreen(poemId: publicId));
        break;
      case 'CATEGORY':
        Navigator.push(context, CategoryScreen(categoryId: publicId));
        break;
      // ... handle other types
    }
  }
}

// Simple ListView rendering
ListView.builder(
  itemCount: suggestions.length,
  itemBuilder: (context, index) {
    final suggestion = suggestions[index];
    return ListTile(
      leading: Text(suggestion.icon, style: TextStyle(fontSize: 24)),
      title: Text(suggestion.text),
      subtitle: suggestion.subtitle != null
        ? Text(suggestion.subtitle!)
        : null,
      onTap: () => suggestion.navigate(context),
    );
  },
)
```

**Performance:**
- **Cache TTL:** 5 minutes (Redis/In-memory)
- **Response Time:** <100ms
- **Rate Limiting:** 60 requests/minute per IP

---

### 10.5.2 Discover Bundle ⭐ NEW

**Endpoint:** `GET /api/discover?lang={lang}`

**Description:** **Single endpoint that replaces 6-7 separate API calls** for the discover/home screen. Returns a complete bundle including trending searches, featured poems, recommended content, featured poets, and categories. Optimized with 15-minute caching for fast load times.

**Authentication:** Required (JWT token via Authorization header)

**Query Parameters:**
- `lang` (optional, default: `ur`) - Language code (ur, en, hi)

**Headers:**
- `Authorization` (required) - Bearer token from login
- `X-User-Id` (optional) - User's database ID for personalized recommendations (get from `/api/auth/me` response's `userId` field)

**Example Request:**
```bash
# Authenticated request
curl -H "Authorization: Bearer eyJhbGci..." \
  "http://localhost:8081/api/discover?lang=ur"

# With user ID for personalization
curl -H "Authorization: Bearer eyJhbGci..." \
     -H "X-User-Id: 12345" \
  "http://localhost:8081/api/discover?lang=ur"
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Discover bundle retrieved successfully",
  "data": {
    "trendingSearches": {
      "daily": [
        {
          "query": "غالب",
          "searchCount": 21,
          "rank": 1
        },
        {
          "query": "فیض",
          "searchCount": 20,
          "rank": 2
        }
      ],
      "weekly": [
        {
          "query": "غالب",
          "searchCount": 45,
          "rank": 1
        }
      ]
    },
    "editorsPicks": {
      "sectionTitle": "Editor's Picks",
      "sectionKey": "discover.editors_picks",
      "items": [
        {
          "type": "POEM",
          "publicId": "abc123",
          "primaryText": "دل کی بستی",
          "secondaryText": "ناصر کاظمی",
          "badge": "غزل",
          "badgeKey": "poetry.type.ghazal",
          "metrics": {
            "likeCount": 250,
            "shareCount": 50,
            "bookmarkCount": 100,
            "viewCount": 1000
          },
          "language": "ur",
          "direction": "rtl",
          "score": null,
          "imageUrl": "https://example.com/thumbnails/poem_abc123.jpg",
          "poetInfo": {
            "publicId": "poet789",
            "name": "ناصر کاظمی",
            "profileImageUrl": "https://example.com/poets/nasir_kazmi.jpg",
            "era": "MODERN"
          }
        }
      ],
      "totalCount": 10
    },
    "recommended": {
      "sectionTitle": "Recommended for You",
      "sectionKey": "discover.recommended",
      "items": [],
      "totalCount": 0
    },
    "featuredPoets": {
      "sectionTitle": "Featured Poets",
      "sectionKey": "discover.featured_poets",
      "items": [
        {
          "type": "POET",
          "publicId": "poet123",
          "primaryText": "مرزا غالب",
          "secondaryText": "Classical Era · 1797-1869",
          "badge": "شاعر",
          "badgeKey": "content.type.poet",
          "metrics": {
            "viewCount": 5000
          },
          "language": "ur",
          "direction": "rtl",
          "score": null,
          "imageUrl": "https://example.com/poets/mirza_ghalib.jpg",
          "poetInfo": null
        }
      ],
      "totalCount": 6
    },
    "categories": {
      "sectionTitle": "Browse by Category",
      "sectionKey": "discover.categories",
      "items": [
        {
          "type": "CATEGORY",
          "publicId": "cat123",
          "primaryText": "Classical Poetry",
          "secondaryText": "-",
          "badge": "Category",
          "badgeKey": "content.type.category",
          "metrics": null,
          "language": "ur",
          "direction": "rtl",
          "score": null
        }
      ],
      "totalCount": 8
    },
    "trendingHashtags": [
      {
        "slug": "ishq",
        "name": "عشق",
        "color": "#E91E63",
        "languageCode": "ur",
        "tagType": "THEME",
        "coupletCount": 1240,
        "poemCount": 320,
        "imageCount": 45,
        "totalUsage": 1605
      },
      {
        "slug": "ghazal",
        "name": "غزل",
        "color": "#9C27B0",
        "languageCode": "ur",
        "tagType": "POEM_GENRE",
        "coupletCount": 980,
        "poemCount": 510,
        "imageCount": 12,
        "totalUsage": 1502
      }
    ],
    "language": "ur",
    "personalized": true,
    "timestamp": 1738961505210
  }
}
```

**Bundle Sections:**

1. **trendingSearches** - Trending queries (daily + weekly top 4 each)
2. **editorsPicks** - Featured poems sorted by engagement (10 items)
3. **recommended** - Personalized or trending content (10 items)
   - Personalized if `X-User-Id` provided
   - Trending content for guests
4. **featuredPoets** - Mix of featured + trending poets (6 items)
5. **categories** - Top 8 categories
6. **trendingHashtags** - Top 10 hashtags ranked by couplet usage (see [Section 18](#18-hashtags-discovery))

**Unified ContentCardDto Format:**

All content items use the same structure:
```typescript
{
  type: "POET" | "POEM" | "VERSE" | "COUPLET" | "CATEGORY" | "TAG",
  publicId: string,
  primaryText: string,           // Main text (name/title/verse text)
  secondaryText: string | null,   // Context (poet name, era, etc.)
  badge: string | null,           // Display badge text
  badgeKey: string | null,        // i18n key for badge
  metrics: {                      // Engagement metrics (null if not applicable)
    likeCount?: number,
    shareCount?: number,
    bookmarkCount?: number,
    viewCount?: number
  } | null,
  language: string,               // ur, en, hi
  direction: "rtl" | "ltr",      // Text direction
  score: number | null,           // Relevance score (search results only)
  imageUrl: string | null,        // Profile image for poets, thumbnail for poems
  poetInfo: {                     // Poet information (for poems, verses, couplets)
    publicId: string,
    name: string | null,
    profileImageUrl: string | null,
    era: string | null            // CLASSICAL, MODERN, CONTEMPORARY, etc.
  } | null
}
```

**Key Benefits:**

1. **Single API Call:** Replaces:
   - `/api/poems/featured`
   - `/api/poets/featured`
   - `/api/search/recommendations`
   - `/api/search/trending`
   - `/api/categories`
   - `/api/search/related`
   - And more...

2. **Fast Performance:**
   - **With cache:** <500ms
   - **Without cache:** <2s
   - **Cache duration:** 15 minutes
   - **Cache key:** Per language + user

3. **UI-Ready Data:**
   - No placeholder values ("Unknown", "Untitled")
   - Consistent format across all content types
   - Pre-calculated metrics
   - RTL/LTR direction included

4. **Personalization:**
   - Personalized recommendations for authenticated users
   - Trending content for guests
   - Language-aware content filtering

**Flutter Implementation Example:**
```dart
class DiscoverScreen extends StatefulWidget {
  @override
  _DiscoverScreenState createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  Future<DiscoverBundle>? _bundleFuture;

  @override
  void initState() {
    super.initState();
    _bundleFuture = _loadDiscoverBundle();
  }

  Future<DiscoverBundle> _loadDiscoverBundle() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/discover?lang=${AppLocalizations.currentLocale}'),
      headers: {
        'Authorization': 'Bearer ${AuthService.token}',
        'X-User-Id': '${AuthService.userId}',
      },
    );
    return DiscoverBundle.fromJson(jsonDecode(response.body)['data']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<DiscoverBundle>(
        future: _bundleFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final bundle = snapshot.data!;
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _bundleFuture = _loadDiscoverBundle();
                });
              },
              child: ListView(
                children: [
                  TrendingSearchesWidget(bundle.trendingSearches),
                  ContentSectionWidget(bundle.editorsPicks),
                  ContentSectionWidget(bundle.recommended),
                  ContentSectionWidget(bundle.featuredPoets),
                  ContentSectionWidget(bundle.categories),
                ],
              ),
            );
          }
          return LoadingWidget();
        },
      ),
    );
  }
}
```

**Cache Strategy:**
- Cached per language and user combination
- 15-minute TTL (time to live)
- Automatic invalidation on content updates
- In-memory cache (SimpleCacheManager) or Redis

**Error Handling:**
- Graceful fallbacks for empty sections
- Individual section errors don't break entire bundle
- Each section wrapped in try-catch

---

### 10.6 Recommendations

**Endpoint:** `GET /api/search/recommendations?type={type}&limit={limit}`

**Description:** Intelligent content recommendations using multiple strategies: personalized based on user behavior, similar content using More Like This, trending content, and hybrid approaches.

**Query Parameters:**
- `type` (optional, default: `hybrid`) - Recommendation type
  - `personalized` - Based on user's bookmarks and likes
  - `similar` - Similar to currently viewing content
  - `trending` - Popular content in timeframe
  - `hybrid` - Combined strategies (40% personalized + 60% trending)
- `contentType` (required for `similar` type) - POEM or COUPLET or ALL
- `contentId` (required for `similar` type) - Public ID of content
- `timeframe` (optional for `trending`, default: `week`) - day, week, month
- `limit` (optional, default: `10`, max: 20) - Number of recommendations

**Header:**
- `X-User-Id` (optional) - User ID for personalized recommendations

**Example Requests:**

**1. Hybrid Recommendations (Default):**
```bash
curl "http://localhost:8081/api/search/recommendations?type=hybrid&limit=10"
```

**2. Trending Content:**
```bash
curl "http://localhost:8081/api/search/recommendations?type=trending&timeframe=week&limit=5"
```

**3. Personalized Recommendations:**
```bash
curl -H "X-User-Id: 12345" \
  "http://localhost:8081/api/search/recommendations?type=personalized&limit=10"
```

**4. Similar Content:**
```bash
curl "http://localhost:8081/api/search/recommendations?type=similar&contentType=POEM&contentId=poem-xyz&limit=10"
```

**Success Response (200) - Hybrid:**
```json
{
  "success": true,
  "message": "Curated recommendations",
  "data": {
    "type": "HYBRID",
    "items": [
      {
        "contentType": "POEM",
        "publicId": "6feeaf84-3d73-4a90-8f50-b14579bd95ad",
        "title": "ایک آرزو",
        "poetName": "Shoaib Ahmad Shajar",
        "poetPublicId": "e9cd0914-9ae7-4271-bfd6-60b3ca1dad4c",
        "poetryType": "NAZAM",
        "categoryName": "Classical Poetry",
        "likeCount": 1,
        "shareCount": 0,
        "bookmarkCount": 0,
        "viewCount": 14,
        "score": "NaN",
        "reason": "Curated for you"
      },
      {
        "contentType": "COUPLET",
        "publicId": "b92370ce-ca56-49a5-8a8d-28774a93cbd3",
        "title": "द्नीअ की म्ह्फ़्लूञ् सॆ अक्त गीअ हुउञ् ईअ र्ब्...",
        "poetName": "شعیب احمد شجر ",
        "poetPublicId": "e9cd0914-9ae7-4271-bfd6-60b3ca1dad4c",
        "poetryType": "NAZAM",
        "categoryName": "Classical Poetry",
        "likeCount": 0,
        "shareCount": 0,
        "bookmarkCount": 0,
        "viewCount": 0,
        "score": 0.0,
        "reason": "Curated for you"
      }
    ],
    "totalCount": 8,
    "message": "Curated recommendations",
    "isPersonalized": false,
    "count": 8
  }
}
```

**Success Response (200) - Trending:**
```json
{
  "success": true,
  "message": "Trending content for week",
  "data": {
    "type": "TRENDING",
    "items": [
      {
        "contentType": "POEM",
        "publicId": "c4b95980-1b7a-47bd-93a8-9c0ce9cff10c",
        "title": "سارے عالم کا یہی ارمان ہونا چاہئے",
        "poetName": "Mansoor Ahmad Samar",
        "poetPublicId": "32aa606d-435f-4536-9c8b-99003bf8c1d8",
        "poetryType": "GHAZAL",
        "categoryName": "Ghazal",
        "likeCount": 1,
        "shareCount": 0,
        "bookmarkCount": 0,
        "viewCount": 25,
        "score": "NaN",
        "reason": "Trending this week"
      }
    ],
    "totalCount": 10,
    "message": "Trending content for week",
    "isPersonalized": false,
    "count": 10
  }
}
```

**Recommendation Strategies:**

**1. Personalized (personalized):**
- Analyzes user's bookmarks, likes, and reading history
- Uses Elasticsearch More Like This query
- Finds content similar to user's preferences
- **Reason:** "Based on your bookmarks", "Similar to poems you've liked"

**2. Similar Content (similar):**
- Uses More Like This query on specific content
- Parameters: `minTermFreq: 1`, `maxQueryTerms: 12`
- Matches: title, full text, poet, tags
- **Reason:** "Similar to what you're reading"

**3. Trending (trending):**
- High engagement in specified timeframe
- Sorts by: `likeCount`, `viewCount`, `engagementScore`
- Timeframes: day (24h), week (7d), month (30d)
- **Reason:** "Trending this week", "Most popular today"

**4. Hybrid (hybrid):**
- 40% personalized + 30% trending + 30% more trending
- Removes duplicates by publicId
- Falls back to trending for anonymous users
- **Reason:** "Curated for you", "Popular in your interests"

**Use Cases:**

**For Home Feed:**
```http
GET /api/search/recommendations?type=hybrid&limit=20
Header: X-User-Id: 12345
```

**For Poem Detail Screen (Similar Poems):**
```http
GET /api/search/recommendations?type=similar&contentType=POEM&contentId=current-poem-id&limit=5
```

**For Discover Tab:**
```http
GET /api/search/recommendations?type=trending&timeframe=week&limit=30
```

**For Personalized Section:**
```http
GET /api/search/recommendations?type=personalized&limit=15
Header: X-User-Id: 12345
```

**Flutter Implementation:**
```dart
// Home feed with mixed recommendations
Future<List<RecommendedItem>> loadHomeFeed() async {
  final response = await dio.get(
    '/api/search/recommendations',
    queryParameters: {'type': 'hybrid', 'limit': 20},
    options: Options(headers: {'X-User-Id': userId}),
  );
  return parseRecommendations(response.data);
}

// Similar poems carousel
Future<List<RecommendedItem>> loadSimilarPoems(String poemId) async {
  final response = await dio.get(
    '/api/search/recommendations',
    queryParameters: {
      'type': 'similar',
      'contentType': 'POEM',
      'contentId': poemId,
      'limit': 5
    },
  );
  return parseRecommendations(response.data);
}
```

---

### 10.7 Search Analytics

Analytics endpoints for tracking search behavior and providing "People also searched" features.

#### 10.7.1 Related Searches

**Endpoint:** `GET /api/search/related?q={query}&limit={limit}`

**Description:** Returns related search queries based on session co-occurrence analysis. Shows what other users searched for in the same session (30-day window). Perfect for "People also searched" features.

**Query Parameters:**
- `q` (required) - Original search query
- `limit` (optional, default: `5`, max: 10) - Number of related searches

**Example Requests:**

**Related searches for "love":**
```bash
curl "http://localhost:8081/api/search/related?q=love&limit=5"
```

**Related searches for "غالب":**
```bash
curl "http://localhost:8081/api/search/related?q=غالب&limit=5"
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 5 related searches",
  "data": {
    "query": "love",
    "relatedSearches": [
      {
        "query": "فیض",
        "normalizedQuery": "فیض",
        "count": 20,
        "score": 100.0
      },
      {
        "query": "غالب",
        "normalizedQuery": "غالب",
        "count": 19,
        "score": 100.0
      },
      {
        "query": "نظم",
        "normalizedQuery": "نظم",
        "count": 18,
        "score": 100.0
      },
      {
        "query": "عشق",
        "normalizedQuery": "عشق",
        "count": 17,
        "score": 100.0
      },
      {
        "query": "غزل",
        "normalizedQuery": "غزل",
        "count": 16,
        "score": 100.0
      }
    ],
    "totalCount": 5,
    "timeWindow": "last 30 days",
    "count": 5
  }
}
```

**Empty Response (200) - No related searches:**
```json
{
  "success": true,
  "message": "No related searches found",
  "data": {
    "query": "xyz123",
    "relatedSearches": [],
    "totalCount": 0,
    "timeWindow": "last 30 days",
    "count": 0
  }
}
```

**Algorithm:**
1. Find all sessions containing the original query
2. Aggregate other queries from those sessions
3. Rank by co-occurrence frequency
4. Exclude the original query

**Score Calculation:**
`score = min(100, count × 10)` - Normalized to 0-100 range

**Use Cases:**

**People Also Searched UI:**
```dart
// Display as horizontal chip list below search results
Widget buildRelatedSearches(String query) {
  return FutureBuilder<RelatedSearchesResponse>(
    future: searchService.getRelatedSearches(query),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('People also searched:', style: TextStyle(fontSize: 14)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: snapshot.data!.relatedSearches.map((search) {
              return ActionChip(
                label: Text(search.query),
                onPressed: () => performSearch(search.query),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}
```

**Zero Results Suggestion:**
```http
GET /api/search?q=غالیب  # User typo - no results
GET /api/search/related?q=غالیب  # Suggests "غالب" (correct spelling)
```

---

#### 10.7.2 Trending Searches

**Endpoint:** `GET /api/search/trending?timeframe={timeframe}&limit={limit}`

**Description:** Returns most popular search queries within a specified timeframe, ranked by search frequency. Perfect for discovery sections showing "What's trending".

**Query Parameters:**
- `timeframe` (optional, default: `week`) - Time window
  - `day` - Last 24 hours
  - `week` - Last 7 days
  - `month` - Last 30 days
- `limit` (optional, default: `10`, max: 20) - Number of trending searches

**Example Requests:**

**Trending this week:**
```bash
curl "http://localhost:8081/api/search/trending?timeframe=week&limit=10"
```

**Trending today:**
```bash
curl "http://localhost:8081/api/search/trending?timeframe=day&limit=5"
```

**Trending this month:**
```bash
curl "http://localhost:8081/api/search/trending?timeframe=month&limit=20"
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 10 trending searches for last 7 days",
  "data": {
    "searches": [
      {
        "query": "غالب",
        "normalizedQuery": "غالب",
        "count": 21,
        "score": 100.0
      },
      {
        "query": "فیض",
        "normalizedQuery": "فیض",
        "count": 20,
        "score": 100.0
      },
      {
        "query": "نظم",
        "normalizedQuery": "نظم",
        "count": 20,
        "score": 100.0
      },
      {
        "query": "عشق",
        "normalizedQuery": "عشق",
        "count": 18,
        "score": 90.0
      },
      {
        "query": "غزل",
        "normalizedQuery": "غزل",
        "count": 18,
        "score": 90.0
      },
      {
        "query": "poetry",
        "normalizedQuery": "poetry",
        "count": 18,
        "score": 90.0
      },
      {
        "query": "محبت",
        "normalizedQuery": "محبت",
        "count": 17,
        "score": 85.0
      },
      {
        "query": "love",
        "normalizedQuery": "love",
        "count": 17,
        "score": 85.0
      },
      {
        "query": "اقبال",
        "normalizedQuery": "اقبال",
        "count": 17,
        "score": 85.0
      },
      {
        "query": "دل",
        "normalizedQuery": "دل",
        "count": 16,
        "score": 80.0
      }
    ],
    "totalCount": 10,
    "timeframe": "week",
    "period": "last 7 days",
    "count": 10
  }
}
```

**Empty Response (200) - No trending data:**
```json
{
  "success": true,
  "message": "No trending searches found",
  "data": {
    "searches": [],
    "totalCount": 0,
    "timeframe": "week",
    "period": "last 7 days",
    "count": 0
  }
}
```

**Score Calculation:**
`score = min(100, count × 5)` - Normalized to 0-100 range

**Use Cases:**

**1. Trending Searches Widget (Home Screen):**
```dart
Widget buildTrendingSearches() {
  return FutureBuilder<TrendingSearchesResponse>(
    future: searchService.getTrendingSearches('week'),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trending This Week 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...snapshot.data!.searches.asMap().entries.map((entry) {
            int index = entry.key;
            var search = entry.value;
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(search.query),
              subtitle: Text('${search.count} searches'),
              trailing: Icon(Icons.trending_up),
              onTap: () => performSearch(search.query),
            );
          }).toList(),
        ],
      );
    },
  );
}
```

**2. Discovery Tab (Daily/Weekly/Monthly Tabs):**
```dart
TabBarView(
  children: [
    TrendingSearchList(timeframe: 'day'),
    TrendingSearchList(timeframe: 'week'),
    TrendingSearchList(timeframe: 'month'),
  ],
);
```

**3. Search Suggestions (Empty State):**
```http
# When search box is empty, show trending searches
GET /api/search/trending?timeframe=day&limit=5
```

**Implementation Notes:**
- All search queries are logged asynchronously (non-blocking)
- Session tracking uses client-generated session IDs
- Related searches use Elasticsearch terms aggregations
- Trending searches cached for 1 hour (Redis)
- **Dummy test data is available**: Run `./scripts/populate-search-analytics.sh` to populate test data (282 search queries)

---

### 10.8 Search Endpoints Quick Reference

**Complete list of all search endpoints with test data available:**

| Endpoint | Purpose | Curl Example | Test Data |
|----------|---------|--------------|-----------|
| `/api/search` | Unified search across all content | `curl "localhost:8081/api/search?q=love&type=all&lang=en"` | ✅ Working |
| `/api/search/quick` | Simplified unified search | `curl "localhost:8081/api/search/quick?q=love&lang=en"` | ✅ Working |
| `/api/search/couplets` | Advanced couplet search | `curl "localhost:8081/api/search/couplets?q=love&sort=relevance"` | ✅ Working |
| `/api/search/autocomplete` | Real-time suggestions | `curl "localhost:8081/api/search/autocomplete?q=gha&lang=en"` | ✅ Working |
| `/api/search/recommendations` | Content recommendations | `curl "localhost:8081/api/search/recommendations?type=hybrid&limit=10"` | ✅ Working with data |
| `/api/search/trending` | Trending searches | `curl "localhost:8081/api/search/trending?timeframe=week&limit=10"` | ✅ Working with 282 queries |
| `/api/search/related` | Related searches | `curl "localhost:8081/api/search/related?q=love&limit=5"` | ✅ Working with data |

**Sample Test Queries (from dummy data):**
- Popular queries: `محبت`, `عشق`, `دل`, `غزل`, `نظم`, `love`, `poetry`, `romantic`
- Poet names: `غالب`, `اقبال`, `فیض`, `میر تقی میر`
- Related searches work for queries that appear in same sessions

**To Regenerate Test Data:**
```bash
# Delete and recreate index
curl -X DELETE "http://localhost:9200/search_queries"
./scripts/create-search-index.sh

# Populate with dummy data (282 queries)
./scripts/populate-search-analytics.sh
```

---

### 10.9 Use Cases & Workflows

### 11.1 Categories

**Get All:** `GET /api/categories`

**Get Root:** `GET /api/categories/root`

**By ID:** `GET /api/categories/{publicId}`

**By Slug:** `GET /api/categories/slug/{slug}`

**Get Children:** `GET /api/categories/{publicId}/children`

---

### 11.2 Tags (Admin Reference Library)

> **Tags vs Hashtags** — There are two related but distinct systems:
> - **Tags** (this section) are admin-curated reference entries with metadata (color, type, language). They define the canonical vocabulary. There are currently ~108 admin tags.
> - **Hashtags** (see [Section 18](#18-hashtags-discovery)) are the free-form slugs stored on content (`tagSlugs` field on poems, couplets, images). Any slug used on content automatically becomes a discoverable hashtag page — like Instagram. Hashtags are the public-facing system Flutter uses for discovery.

**Get All Tags (admin reference):** `GET /api/tags`

**By Type:** `GET /api/tags/type/{type}` (ERA, POET_CATEGORY, POEM_GENRE, etc.)

**By Slug:** `GET /api/tags/slug/{slug}`

**By ID:** `GET /api/tags/{publicId}`

For hashtag discovery (trending, per-slug content pages), see **[Section 18: Hashtags](#18-hashtags-discovery)**.

---

### 11.3 Geography

**Countries:** `GET /api/geography/countries?lang=en`

**Cities:** `GET /api/geography/cities?lang=en&countryCode=PK`

**Cities by Country:** `GET /api/geography/countries/{countryCode}/cities?lang=en`

---

### 11.4 Languages

#### 11.4.1 Get All Languages {#1141-get-all-languages}

**Endpoint:** `GET /api/languages`

**Authentication Required:** No

**Description:** Get all languages in the system, including both active and inactive ones.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Languages retrieved successfully",
  "data": [
    {
      "code": "ur",
      "name": "Urdu",
      "nativeName": "اردو",
      "direction": "RTL",
      "isActive": true,
      "displayOrder": 1
    },
    {
      "code": "en",
      "name": "English",
      "nativeName": "English",
      "direction": "LTR",
      "isActive": true,
      "displayOrder": 2
    },
    {
      "code": "hi",
      "name": "Hindi",
      "nativeName": "हिन्दी",
      "direction": "LTR",
      "isActive": true,
      "displayOrder": 3
    },
    {
      "code": "ar",
      "name": "Arabic",
      "nativeName": "العربية",
      "direction": "RTL",
      "isActive": true,
      "displayOrder": 4
    },
    {
      "code": "fa",
      "name": "Persian",
      "nativeName": "فارسی",
      "direction": "RTL",
      "isActive": true,
      "displayOrder": 5
    },
    {
      "code": "pa",
      "name": "Punjabi",
      "nativeName": "ਪੰਜਾਬੀ",
      "direction": "LTR",
      "isActive": true,
      "displayOrder": 6
    }
  ]
}
```

---

#### 11.4.2 Get Language by Code {#1142-get-language-by-code}

**Endpoint:** `GET /api/languages/{code}`

**Authentication Required:** No

**Path Parameters:**
- `code`: Language code (ur, en, hi, ar, fa, pa)

**Example:** `GET /api/languages/ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Language retrieved successfully",
  "data": {
    "code": "ur",
    "name": "Urdu",
    "nativeName": "اردو",
    "direction": "RTL",
    "isActive": true,
    "displayOrder": 1
  }
}
```

---

#### 11.4.3 Get Active Languages (NEW) {#1143-get-active-languages-new}

**Endpoint:** `GET /api/languages/active`

**Authentication Required:** No

**Description:**
Get only active languages (those enabled in the system). This is the recommended endpoint for mobile apps to populate language selection menus.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Active languages retrieved successfully",
  "data": [
    {
      "code": "ur",
      "name": "Urdu",
      "nativeName": "اردو",
      "direction": "RTL",
      "isActive": true,
      "displayOrder": 1
    },
    {
      "code": "en",
      "name": "English",
      "nativeName": "English",
      "direction": "LTR",
      "isActive": true,
      "displayOrder": 2
    },
    {
      "code": "hi",
      "name": "Hindi",
      "nativeName": "हिन्दी",
      "direction": "LTR",
      "isActive": true,
      "displayOrder": 3
    }
  ]
}
```

**Flutter Usage:**
```dart
class LanguageSelectionScreen extends StatelessWidget {
  Future<List<Language>> getActiveLanguages() async {
    final response = await dio.get('/api/languages/active');

    final apiResponse = ApiResponse<List<dynamic>>.fromJson(response.data);
    return apiResponse.data!
        .map((json) => Language.fromJson(json))
        .toList();
  }

  Widget build(BuildContext context) {
    return FutureBuilder<List<Language>>(
      future: getActiveLanguages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        return ListView.builder(
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final lang = snapshot.data![index];
            return ListTile(
              title: Text(lang.name),
              subtitle: Text(lang.nativeName),
              trailing: Icon(
                lang.direction == 'RTL'
                  ? Icons.format_textdirection_r_to_l
                  : Icons.format_textdirection_l_to_r
              ),
              onTap: () => setAppLanguage(lang.code),
            );
          },
        );
      },
    );
  }
}
```

**Use Cases:**
1. **Language Selector:** Show available languages in settings
2. **Content Filter:** Allow filtering content by language
3. **Multi-Language UI:** Support RTL and LTR layouts based on language direction
4. **Localization:** Dynamically load language-specific resources

**Supported Languages:**
- **Urdu (ur)** - اردو - RTL - Primary language
- **English (en)** - English - LTR - International
- **Hindi (hi)** - हिन्दी - LTR - Regional
- **Arabic (ar)** - العربية - RTL - Classical poetry
- **Persian (fa)** - فارسی - RTL - Persian poetry
- **Punjabi (pa)** - ਪੰਜਾਬੀ - LTR - Regional

---

#### 11.4.4 Dictionary Sync & Stats (NEW) {#1144-dictionary-sync-stats-new}

**Base Path:** `/api/dictionary`

**Description:**
Endpoints for syncing transliteration dictionary and viewing dictionary statistics. Useful for offline dictionary downloads and app health monitoring.

##### Dictionary Sync

**Endpoint:** `GET /api/dictionary/sync`

**Authentication Required:** No (Public endpoint)

**Description:**
Download the latest Urdu transliteration dictionary for offline use. Returns dictionary entries with Urdu words, Roman transliterations, and Hindi scripts.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Dictionary synchronized successfully",
  "data": {
    "version": "2.0.1",
    "lastUpdated": "2026-01-28T10:00:00Z",
    "totalEntries": 12456,
    "entries": [
      {
        "word": "محبت",
        "roman": "muhabbat",
        "hindi": "मुहब्बत",
        "meaning": "love",
        "confidence": "HIGH"
      },
      {
        "word": "دل",
        "roman": "dil",
        "hindi": "दिल",
        "meaning": "heart",
        "confidence": "HIGH"
      },
      {
        "word": "شعر",
        "roman": "sher",
        "hindi": "शेर",
        "meaning": "poetry/couplet",
        "confidence": "HIGH"
      }
    ],
    "checksum": "a3c4e7f9..."
  }
}
```

**Flutter Usage:**
```dart
class DictionaryService {
  Future<void> syncDictionary() async {
    final response = await dio.get('/api/dictionary/sync');
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
    final data = apiResponse.data!;

    // Save to local database for offline transliteration
    await localDatabase.saveDictionary(
      version: data['version'],
      entries: data['entries'],
      checksum: data['checksum'],
    );
  }

  // Check if dictionary needs update
  Future<bool> needsUpdate() async {
    final localVersion = await localDatabase.getDictionaryVersion();
    final response = await dio.get('/api/dictionary/stats');
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
    final remoteVersion = apiResponse.data!['version'];

    return localVersion != remoteVersion;
  }
}
```

---

##### Dictionary Statistics

**Endpoint:** `GET /api/dictionary/stats`

**Authentication Required:** No (Public endpoint)

**Description:**
Get comprehensive statistics about the transliteration dictionary. Useful for app health monitoring and displaying dictionary coverage information.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Dictionary statistics retrieved successfully",
  "data": {
    "version": "2.0.1",
    "lastUpdated": "2026-01-28T10:00:00Z",
    "totalEntries": 12456,
    "validatedEntries": 11234,
    "validationCoverage": 90.2,
    "entriesBySource": {
      "manual": 8934,
      "automated": 3522
    },
    "entriesByConfidence": {
      "high": 9821,
      "medium": 2145,
      "low": 490
    },
    "hindiScriptCoverage": 95.6,
    "romanScriptCoverage": 100.0,
    "recentAdditions": {
      "last7Days": 45,
      "last30Days": 189
    }
  }
}
```

**Use Cases:**
1. **Offline Mode:** Download dictionary for offline transliteration
2. **App Health:** Monitor dictionary coverage and quality
3. **User Info:** Display dictionary version in app settings
4. **Smart Sync:** Only sync when dictionary version changes
5. **Quality Metrics:** Show transliteration accuracy to users

**Performance Notes:**
- Dictionary sync response cached for 1 hour
- Gzipped response for efficient transfer
- Incremental sync planned for future versions
- Checksum verification for data integrity

---

## 12. System & Health

**Health Check:** `GET /api/health` (No auth required)

**Detailed:** `GET /api/health/detailed`

**Readiness:** `GET /api/health/ready`

**Liveness:** `GET /api/health/live`

---

## 13. Reference

### 13.1 Enum Values

**PoetryType:** GHAZAL, NAZM, RUBAI, QASIDA, MARSIYA, HAMD, NAAT, MANQABAT, SALAM, QITA, MUSADDAS, MASNAVI

**Gender:** MALE, FEMALE, OTHER

**Era:** CLASSICAL, MODERN, CONTEMPORARY, EMERGING

**ReadingLevel:** BEGINNER, INTERMEDIATE, ADVANCED

**InterestType:** CATEGORY, POET, TAG, LANGUAGE, CONTENT_TYPE

**ActivityType:** VIEW, LIKE, UNLIKE, BOOKMARK, UNBOOKMARK, SHARE, SEARCH, FOLLOW_POET, UNFOLLOW_POET, COLLECT, COMMENT, DOWNLOAD

**TargetType:** POEM, POET, CATEGORY, TAG, COLLECTION, USER, BOOK

**ShareType:** WHATSAPP, FACEBOOK, TWITTER, INSTAGRAM, COPY_LINK, SMS, EMAIL

**TagType:** ERA, POET_CATEGORY, POEM_GENRE, GENERAL, LANGUAGE, TEMPLATE_STYLE, TEMPLATE_CATEGORY

---

### 13.2 HTTP Status Codes

- **200 OK** - Success
- **201 Created** - Resource created
- **400 Bad Request** - Invalid input
- **401 Unauthorized** - Auth required/failed
- **403 Forbidden** - Not authorized
- **404 Not Found** - Resource not found
- **500 Internal Server Error** - Server error

---

### 13.3 Pagination Format

All paginated responses include:
```json
{
  "content": [...],
  "pageable": {"pageNumber": 0, "pageSize": 20},
  "totalElements": 150,
  "totalPages": 8,
  "last": false,
  "first": true
}
```

---

### 13.4 Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "data": null
}
```

---

## 14. Best Practices & Guidelines

### 14.1 Authentication

- Store tokens in secure storage (flutter_secure_storage)
- Refresh token when access token expires (401 response)
- Include Authorization header in ALL authenticated endpoints
- Handle token expiry gracefully with automatic retry

### 14.2 Pagination

- Use `page=0` for first page (zero-indexed)
- Default `size=20` for most lists
- Check `last` field to know if more pages exist
- Implement infinite scroll for better UX

### 14.3 Search

- Minimum query length: 2 characters
- Debounce search input (300-500ms)
- Use Elasticsearch endpoints for better performance
- Falls back to PostgreSQL automatically if ES unavailable

### 14.4 Image Handling

- All image URLs are CloudFront CDN URLs (permanent)
- Cache images locally using cached_network_image package
- Handle null image URLs gracefully with placeholders
- Compress images before upload (max 5MB for backgrounds)

### 14.5 Multi-Language Support

- Default language: Urdu (ur)
- Use `?lang=ur|en|hi` parameter consistently
- Handle RTL text for Urdu/Arabic (TextDirection.rtl)
- Use NotoNastaliqUrdu font for Urdu poetry

**Bookmark Language Context Preservation:**
- When users bookmark content (poems, couplets, or images), the `lang` parameter is stored with the bookmark
- This allows displaying bookmarks in their original language context regardless of current app language
- Example: If a user bookmarks a poem in Urdu (`lang=ur`) and another in English (`lang=en`), their bookmark screen will show mixed languages - each bookmark in its original language
- When fetching bookmarks, you can optionally filter by language:
  - `/api/users/me/bookmarks?lang=ur` - Only Urdu bookmarks
  - `/api/users/me/image-bookmarks?lang=en` - Only English image bookmarks
  - `/api/users/me/bookmarks` - All bookmarks (mixed languages)
- This feature enables a more natural user experience where content is preserved as the user first encountered it

### 14.6 Error Handling

```dart
try {
  final response = await apiCall();
  return response;
} on DioError catch (e) {
  if (e.response?.statusCode == 401) {
    await refreshToken();
    return apiCall(); // Retry
  }
  throw ApiException(e.response?.data['message'] ?? 'Unknown error');
} on SocketException {
  throw NetworkException('No internet connection');
}
```

### 14.7 Performance Optimization

- Use pagination for all lists
- Implement caching for frequently accessed data
- Lazy load images
- Use const constructors where possible
- Minimize API calls (batch requests when possible)

---

## 15. Complete Workflows

### 15.1 User Onboarding Flow

```
1. Firebase Auth (Google/Email/Phone)
   → POST /api/auth/firebase/verify
   → Store access + refresh tokens
   
2. Update Profile
   → PUT /api/profile/update (name, city, preferences)
   
3. Select Interests
   → POST /api/profile/interests (favorite poets, categories)
   
4. Start Exploring
   → GET /api/search/quick?q=محبت
```

---

### 15.2 Content Discovery Flow

```
Home Screen:
  → GET /api/poets/featured (Featured Poets)
  → GET /api/analytics/couplets/trending (Trending Couplets)
  → GET /api/profile/recommendations (Personalized)

Browse Poets:
  → GET /api/poets?page=0
  → Tap poet → GET /api/poets/{id}?lang=ur
  → View poems → GET /api/poems?poetId={id}

Read Poem:
  → GET /api/poems/{id}?lang=ur
  → GET /api/poems/{id}/couplets?lang=ur
  → Like couplet → POST /api/couplets/{id}/like
  → Generate image → POST /api/couplets/{id}/generate-image
```

---

### 15.3 Image Poetry Creation Flow

```
1. Select Couplet from poem

2. Choose Template
   → GET /api/image-templates
   → OR upload custom → POST /api/users/me/upload-background

3. Generate
   → POST /api/couplets/{id}/generate-image

4. Save, Bookmark & Share
   → POST /api/poetry-images/{id}/save (Save to collection)
   → POST /api/poetry-images/{id}/bookmark?lang=ur (Quick bookmark)
   → Share.share(imageUrl)

5. View Later
   → GET /api/users/me/saved-images (Collections)
   → GET /api/users/me/image-bookmarks?lang=ur (Bookmarks in specific language)
   → GET /api/users/me/image-bookmarks (All bookmarks, mixed languages)
```

---

### 15.4 Sharing & Social Flow

```
Share Couplet:
  → POST /api/couplets/{id}/share (shareType: WHATSAPP)
  → Get shareUrl + shareText
  → Share via platform

Comment on Poem:
  → POST /api/poems/{id}/comments
  → GET /api/poems/{id}/comments (view all)

View User Activity:
  → GET /api/users/me/couplets/liked (Liked couplets)
  → GET /api/users/me/couplets/bookmarked (Bookmarked couplets)
  → GET /api/users/me/saved-images (Saved image collections)
  → GET /api/users/me/image-bookmarks (Bookmarked images)
  → GET /api/users/me/image-bookmarks?lang=ur (Urdu bookmarked images)

Bookmark Content in Different Languages:
  → Reading Urdu poem → POST /api/poems/{id}/bookmark?lang=ur
  → Reading English translation → POST /api/poems/{id}/bookmark?lang=en
  → Viewing Hindi couplet → POST /api/couplets/{id}/bookmark?lang=hi
  → Generated Urdu image → POST /api/poetry-images/{id}/bookmark?lang=ur
  → All bookmarks preserved in their original language context
```

---

## Appendix A: Flutter Code Examples

### API Service Setup

```dart
class ApiService {
  final Dio dio;
  String? accessToken;
  String? refreshToken;
  
  ApiService() : dio = Dio(BaseOptions(
    baseUrl: Environment.baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _refreshToken();
          return handler.resolve(await _retry(error.requestOptions));
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  Future<void> _refreshToken() async {
    final response = await dio.post('/api/auth/refresh', 
      data: {'refreshToken': refreshToken}
    );
    accessToken = response.data['data']['accessToken'];
    await _saveTokens();
  }
}
```

---

### Model Classes

```dart
class Poet {
  final String publicId;
  final String name;
  final String? profileImageUrl;
  final String? birthYear;
  final int poemCount;
  
  Poet.fromJson(Map<String, dynamic> json) 
    : publicId = json['publicId'],
      name = json['name'],
      profileImageUrl = json['profileImageUrl'],
      birthYear = json['birthYear']?.toString(),
      poemCount = json['poemCount'] ?? 0;
}

class Couplet {
  final String publicId;
  final int coupletNumber;
  final List<Verse> verses;
  final int likeCount;
  final int bookmarkCount;
  final CoupletUserStatus? userStatus;
  
  Couplet.fromJson(Map<String, dynamic> json)
    : publicId = json['publicId'],
      coupletNumber = json['coupletNumber'],
      verses = (json['verses'] as List)
          .map((v) => Verse.fromJson(v))
          .toList(),
      likeCount = json['likeCount'] ?? 0,
      bookmarkCount = json['bookmarkCount'] ?? 0,
      userStatus = json['userStatus'] != null 
          ? CoupletUserStatus.fromJson(json['userStatus'])
          : null;
}
```

---

## Appendix B: API Endpoints Summary

**Total Endpoints:** 115+

**By Category:**
- Authentication: 5
- User Profile: 10
- Poets: 12
- Poems: 13
- Couplets: 13
- Image Poetry: 11
- Books: 4
- Comments: 4
- Search: 4
- Categories: 5
- Tags: 4
- Geography: 3
- Languages: 3
- Health: 4
- Analytics: 15+
- **Feed: 2** ⭐ NEW
  - `GET /api/feed` — personalized infinite-scroll feed
  - `POST /api/events/batch` — ingest feed engagement events

**Public Endpoints (No Auth):** 8
- Authentication endpoints (4)
- Health checks (4)

**Protected Endpoints:** 105+

---

## Appendix C: Changelog

### March 20, 2026 — Feed Engine v2 (9 Improvements)
- **Following Feed Source** — Content from followed poets now surfaces in feed with `reason: "FOLLOWING"`. New `sourceId: "poet_following"` with 20% default weight, capped at 40% of any page to ensure source diversity
- **Engagement Velocity Scoring** — Recent content with rapid engagement outranks old high-count content. Items created in last 24h with any engagement get significant score boost
- **Negative Signal Learning** — `skip_fast` and `hide` events now persist as `UserContentPreference` entities. Poet content score is gradually reduced (-0.1 per skip, -1.0 on hide). Preferences decay 10% weekly
- **Variable Rewards (Delighter Source)** — New `sourceId: "delighter"` injects hidden gem content at positions 8-12 in the feed to prevent predictability
- **Display Hints (reserved, not yet sent)** — FeedItem fields `displayMode`, `primaryAction`, `autoExpandFirstVerse`, `previewDurationMs` are defined in the schema but not currently populated. They will be enabled in a future release when Flutter cards are ready to consume them
- **Session Momentum** — Scoring weights shift by page: WARMUP (page 1: 60% personalization), EXPLORATION (pages 2-3: balanced), DEEP (page 4+: 50% personalization). Streak breaker places high-confidence item at last position of each page
- **Social Proof Layer** — New `socialContext` object on FeedItem with `trendingLabel` ("Popular"/"Rising"), `velocityLabel` ("Trending now"/"Shared 5x this week"), `totalReactions`. **Only appears on items with 10+ likes** — null for low-engagement content
- **Smart Pull-to-Refresh** — New `refresh=true` query parameter returns only new items without reshuffling. Session stays the same. New `newCount` field in FeedResponse (only present when `refresh=true`)
- **Content Exhaustion Prevention** — New sources `deep_cuts` (activates at 200+ items viewed) and `time_capsule` (activates at 500+ items, resurfaces old bookmarks with `reason: "TIME_CAPSULE"`)
- **Per-source diversity cap** — No single source can fill more than 40% of a feed page, ensuring a healthy mix of trending, following, discovery, and image content
- **New query param**: `GET /api/feed?refresh=true` — smart pull-to-refresh
- **New FeedItem field**: `socialContext` (only on items with 10+ likes)
- **New FeedResponse field**: `newCount` (only present when `refresh=true`)
- **Reserved FeedItem fields (not yet sent)**: `displayMode`, `primaryAction`, `autoExpandFirstVerse`, `previewDurationMs`
- **New reason values**: `FOLLOWING`, `TIME_CAPSULE`
- **Updated Flutter models**: `FeedResponse`, `FeedItem`, new `SocialContext` class
- **No breaking changes** — all additions are backward-compatible (new fields are nullable)

### March 2026
- **Feed `POET_IMAGE` — consistent poet fields** — `poetName`, `poetProfileImageUrl`, `poetBirthYear`, `poetDeathYear`, and `bookmarkCount` added to `POET_IMAGE` `contentData`. `lang` field is now populated (was previously `null`). All four feed item types now return the same set of poet identity fields.

### February 2026 ⭐ NEW
- **Added Personalized Feed Engine ("Silk Road")** — Section 17
  - `GET /api/feed` — infinite-scroll personalized feed with cursor-based pagination
  - `POST /api/events/batch` — feed engagement events (impression, dwell, skip_fast, etc.)
  - Mixed content types: COUPLET, POEM, POET_SPOTLIGHT, POET_IMAGE in a single response
  - HMAC-signed cursor (tamper-proof), session deduplication, pull-to-refresh support
  - Event idempotency via `eid` field — safe to retry on network failure
  - Full Flutter integration guide: infinite scroll, pull-to-refresh, event batching, visibility tracking
- **Added App Content endpoints** (Section 16)
  - `GET /api/app-content?lang=en` — list all active content pages
  - `GET /api/app-content/{contentKey}?lang=en` — get single page by key

### January 2026 ⭐ NEW
- **Added Poet Follow System** (4 endpoints)
  - Follow/unfollow poets
  - Get following list
  - Check follow status
- **Added Couplet Analytics Endpoints** (3 endpoints)
  - Most liked couplets (global and by poet)
  - Most shared couplets
  - Trending couplets with timeframe filtering
- **Added Image Template Endpoints** (2 endpoints)
  - Get popular templates
  - Get template statistics
- **Enhanced Language Endpoints**
  - Get active languages (optimized for mobile apps)
- **Added Dictionary Sync System** (2 endpoints)
  - Dictionary sync for offline transliteration
  - Dictionary statistics and health metrics
- **Documentation Improvements**
  - Comprehensive Flutter code examples
  - Use case scenarios for all new features
  - Performance notes and best practices

### December 2025
- Added Couplet Engagement System (13 endpoints)
- Added Image Poetry Generation (11 endpoints)
- Added Book Management with download tracking
- Added Comments System (4 endpoints)
- Enhanced search with unified multi-type search
- Added comprehensive documentation with Flutter examples

### November 2025
- Added Image Template Management
- Enhanced Poet endpoints with multi-language support
- Added Tag-based poet filtering
- Improved pagination across all endpoints

### October 2025
- Initial API release
- Basic authentication with Firebase
- Poet and Poem CRUD operations
- User profile management

---

---

## 16. App Content (Settings Pages) ⭐ NEW

### 16.1 Overview — App Content

Static content pages (About App, Privacy Policy, Terms of Service, FAQ, Contact Us) displayed in the app settings screen. Content is managed by admins via the admin portal — no app update needed when content changes.

**Key Design Points:**
- **No authentication required** — public endpoints, no `Authorization` header needed
- **Language-aware** — pass `?lang=ur` to get Urdu content, `?lang=en` for English
- **Ordered** — results are sorted by `displayOrder` ascending (admin controls the order)
- **Standard content keys**: `ABOUT_APP`, `PRIVACY_POLICY`, `TERMS_OF_SERVICE`, `CONTACT_US`, `FAQ`

---

### 16.2 Get All Active Content

Returns all active content entries for a language. Use this on the **settings screen** to build the list of tappable items (About, Privacy Policy, etc.).

**Endpoint**: `GET /api/app-content?lang=en`

**Authentication Required**: No

**Query Parameters**:
- `lang` (optional, default: `"en"`): Language code — `en`, `ur`, `hi`

**Example**: `GET /api/app-content?lang=ur`

**Success Response (200)**:
```json
{
  "success": true,
  "message": "App content retrieved successfully",
  "data": [
    {
      "publicId": "abc-123",
      "contentKey": "ABOUT_APP",
      "title": "ہمارے بارے میں",
      "content": "جہانِ سخن ایک شاعری پلیٹ فارم ہے...",
      "languageCode": "ur",
      "isActive": true,
      "displayOrder": 1,
      "updatedAt": "2026-02-27T10:00:00"
    },
    {
      "publicId": "def-456",
      "contentKey": "PRIVACY_POLICY",
      "title": "رازداری کی پالیسی",
      "content": "...",
      "languageCode": "ur",
      "isActive": true,
      "displayOrder": 2,
      "updatedAt": "2026-02-27T10:00:00"
    }
  ]
}
```

**Notes**:
- Only entries with `isActive = true` and `isDeleted = false` are returned
- Sorted by `displayOrder` ascending
- Returns an empty list `[]` if no content exists for the requested language (handle gracefully)

---

### 16.3 Get Single Page by Key

Load the full content of a single page when the user taps an item (e.g. tap "Privacy Policy" → load full text).

**Endpoint**: `GET /api/app-content/{contentKey}?lang=en`

**Authentication Required**: No

**Path Parameters**:
- `contentKey`: One of `ABOUT_APP`, `PRIVACY_POLICY`, `TERMS_OF_SERVICE`, `CONTACT_US`, `FAQ` (case-insensitive)

**Query Parameters**:
- `lang` (optional, default: `"en"`): Language code

**Example**: `GET /api/app-content/PRIVACY_POLICY?lang=en`

**Success Response (200)**:
```json
{
  "success": true,
  "message": "App content retrieved successfully",
  "data": {
    "publicId": "def-456",
    "contentKey": "PRIVACY_POLICY",
    "title": "Privacy Policy",
    "content": "Your privacy is important to us. This Privacy Policy explains how Jahane Sukhan collects, uses, and protects your information...",
    "languageCode": "en",
    "isActive": true,
    "displayOrder": 2,
    "updatedAt": "2026-02-27T10:00:00"
  }
}
```

**Error (404) — key not found or inactive**:
```json
{
  "success": false,
  "message": "Content not found for key: PRIVACY_POLICY",
  "data": null
}
```

**Notes**:
- Returns 404 if no active, non-deleted entry exists for the given key + language
- Fall back to English (`?lang=en`) if the requested language is not available

---

### 16.4 AppContentResponse — Field Reference

| Field | Type | Description |
|-------|------|-------------|
| `publicId` | String | Unique identifier for the entry |
| `contentKey` | String | Logical key (e.g. `PRIVACY_POLICY`) |
| `title` | String | Display title shown in settings list and page header |
| `content` | String | Full body text — may contain markdown or plain text |
| `languageCode` | String | Language of this entry (`en`, `ur`, `hi`) |
| `isActive` | Boolean | Always `true` in public API responses |
| `displayOrder` | Integer | Sort order (lower = first); may be `null` |
| `updatedAt` | LocalDateTime | Last modified timestamp (use for cache invalidation) |

---

### 16.5 Flutter Implementation Guide

#### Settings List Screen

```dart
// Fetch all content pages for current app language
Future<List<AppContentItem>> fetchAppContent(String lang) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/app-content?lang=$lang'),
    // No Authorization header needed
  );

  final body = jsonDecode(response.body);
  if (body['success'] == true) {
    return (body['data'] as List)
        .map((item) => AppContentItem.fromJson(item))
        .toList();
  }
  return []; // Return empty list on failure — do not crash
}
```

#### Content Detail Screen (on tap)

```dart
Future<AppContentItem?> fetchContentByKey(String key, String lang) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/app-content/$key?lang=$lang'),
  );

  final body = jsonDecode(response.body);
  if (body['success'] == true) {
    return AppContentItem.fromJson(body['data']);
  }
  return null; // Handle null gracefully (show error or fallback)
}
```

#### AppContentItem Model

```dart
class AppContentItem {
  final String publicId;
  final String contentKey;
  final String title;
  final String content;
  final String languageCode;
  final int? displayOrder;
  final String updatedAt;

  AppContentItem({
    required this.publicId,
    required this.contentKey,
    required this.title,
    required this.content,
    required this.languageCode,
    this.displayOrder,
    required this.updatedAt,
  });

  factory AppContentItem.fromJson(Map<String, dynamic> json) {
    return AppContentItem(
      publicId: json['publicId'],
      contentKey: json['contentKey'],
      title: json['title'],
      content: json['content'],
      languageCode: json['languageCode'],
      displayOrder: json['displayOrder'],
      updatedAt: json['updatedAt'],
    );
  }
}
```

#### Language Fallback Strategy

```dart
Future<AppContentItem?> fetchWithFallback(String key, String lang) async {
  // Try requested language first
  var item = await fetchContentByKey(key, lang);

  // Fall back to English if not found
  if (item == null && lang != 'en') {
    item = await fetchContentByKey(key, 'en');
  }

  return item;
}
```

#### Rendering Markdown Content

The `content` field may contain markdown. Use a markdown rendering widget:

```dart
// pubspec.yaml: flutter_markdown: ^0.6.0
import 'package:flutter_markdown/flutter_markdown.dart';

Scaffold(
  appBar: AppBar(title: Text(item.title)),
  body: Markdown(
    data: item.content,
    styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
  ),
);
```

---

## 17. Personalized Feed ("For You" Tab) ⭐ NEW

### 17.1 Overview — Personalized Feed

The feed is an infinite-scroll, personalized stream of mixed poetry content. It powers the **"For You"** tab and assembles couplets, poems, poet spotlights, and poet gallery images into a single ranked list — different on every session, improving as the user engages.

**Key Design Points:**
- **Authentication required** — every request needs a valid JWT `Authorization: Bearer <token>` header
- **Cursor-based pagination** — pass the `nextCursor` from the previous response as the `cursor` param on the next request
- **Pull-to-refresh = `refresh=true`** — keeps existing session, returns only new items (no reshuffle). Omit cursor entirely to start a brand new session
- **No duplicates within a session** — items shown on page 1 are excluded from page 2+
- **Mixed content types** — one response contains couplets, poems, poet spotlights, and images
- **Following content** — content from followed poets surfaces with `reason: "FOLLOWING"` (20% weight, max 40% of page)
- **Events improve personalization** — send `POST /api/events/batch` after each page to make the next page smarter
- **Negative signal learning** — `skip_fast` and `hide` events persistently reduce unwanted poet content across sessions
- **Social proof** — FeedItem includes `socialContext` with trending labels and reaction counts (only on items with 10+ likes)
- **Display hints (reserved)** — `displayMode`, `primaryAction`, `autoExpandFirstVerse` fields are defined but not currently sent; reserved for future Flutter integration
- **Session momentum** — scoring weights shift as the user scrolls deeper (familiar content first, then exploration, then hyper-personalized)
- **Content exhaustion prevention** — after 200+ items, hidden gem poets and resurfaced bookmarks activate
- **Strict language filtering** — `COUPLET` and `POEM` items are strictly filtered to the requested `lang`; items with no content in that language are silently dropped. `POET_IMAGE` items are not filtered by language but do use `lang` to return `poetName` in the correct language

---

### 17.2 Get Feed Page

Fetch the next page of the personalized feed.

**Endpoint**: `GET /api/feed`

**Authentication Required**: Yes (`Authorization: Bearer <jwt>`)

**Query Parameters**:

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `lang` | String | No | `ur` | Content language: `ur`, `en`, `hi`, `fa`, `ar`, `pa` |
| `cursor` | String | No | — | Opaque cursor from previous response. Omit for first page or full reset |
| `limit` | Integer | No | `20` | Items per page (max: 20) |
| `refresh` | Boolean | No | `false` | **Smart pull-to-refresh mode.** When `true` with an existing cursor, returns only new items without reshuffling the feed. Session stays the same. Response includes `newCount`. See Section 17.6 |

**Debug Header** (development only):
- `X-Feed-Debug: true` — adds `debugInfo` to the response (sources used, cache hit, build time)

**Example — First page:**
```
GET /api/feed?lang=ur
Authorization: Bearer <jwt>
```

**Example — Next page:**
```
GET /api/feed?lang=ur&cursor=eyJzaWQiOiI1NTBlODQwMCIsInAiOjIsImxhbmciOiJ1ciJ9...
Authorization: Bearer <jwt>
```

**Success Response (200)**:
```json
{
  "success": true,
  "message": "Feed loaded successfully",
  "data": {
    "items": [
      {
        "type": "COUPLET",
        "publicId": "couplet_abc123",
        "reason": "FOLLOWING",
        "sourceId": "poet_following",
        "lang": "ur",
        "contentData": {
          "versesTextArabic": "ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے\nبہت نکلے مرے ارمان لیکن پھر بھی کم نکلے",
          "versesTextRoman": "Hazaron khwahishen aisi ke har khwahish pe dam nikle\nBahut nikle mere armaan lekin phir bhi kam nikle",
          "poetPublicId": "poet_mirza_ghalib",
          "poetProfileImageUrl": "https://cdn.example.com/ghalib.jpg",
          "poetBirthYear": 1797,
          "poetDeathYear": 1869,
          "poetName": "مرزا غالب",
          "poemPublicId": "poem_xyz789",
          "likeCount": 1823,
          "shareCount": 441,
          "bookmarkCount": 287
        },
        "socialContext": {
          "totalReactions": 1823,
          "trendingLabel": "Popular"
        }
      },
      {
        "type": "POEM",
        "publicId": "poem_def456",
        "reason": "TRENDING",
        "sourceId": "poem_trending_7d",
        "lang": "ur",
        "contentData": {
          "title": "شکوہ",
          "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا...",
          "poetPublicId": "poet_iqbal",
          "poetProfileImageUrl": "https://cdn.example.com/iqbal.jpg",
          "poetBirthYear": 1877,
          "poetDeathYear": 1938,
          "poetName": "علامہ اقبال",
          "poetryType": "NAZAM",
          "likeCount": 456,
          "viewCount": 12340,
          "thumbnailUrl": null
        },
        "socialContext": {
          "totalReactions": 456,
          "trendingLabel": "Popular",
          "velocityLabel": "Trending now"
        }
      },
      {
        "type": "POET_SPOTLIGHT",
        "publicId": "poet_faiz_ahmed",
        "reason": "DISCOVERY",
        "sourceId": "poet_discovery",
        "lang": "ur",
        "contentData": {
          "poetName": "فیض احمد فیض",
          "bio": "فیض احمد فیض ایک ممتاز پاکستانی شاعر تھے جن کی شاعری میں انقلاب اور محبت کا حسین امتزاج ملتا ہے...",
          "poetPublicId": "poet_faiz_ahmed",
          "profileImageUrl": "https://cdn.example.com/faiz.jpg",
          "birthYear": 1911,
          "deathYear": 1984,
          "poemCount": 89,
          "followerCount": 4201,
          "viewCount": 98500,
          "featuredCouplet": {
            "coupletPublicId": "coup-def-456",
            "verses": [
              "ہم پرورشِ لوح و قلم کرتے رہیں گے",
              "جو دل پہ گزرتی ہے رقم کرتے رہیں گے"
            ],
            "likeCount": 42,
            "script": "ARABIC"
          }
        },
        "socialContext": {
          "totalReactions": 4201,
          "trendingLabel": "Followed by 4201+ readers"
        }
      },
      {
        "type": "POET_IMAGE",
        "publicId": "poet_image_ghi789",
        "reason": "DISCOVERY",
        "sourceId": "poet_image_gallery",
        "lang": "ur",
        "contentData": {
          "imageUrl": "https://cdn.example.com/poets/ghalib-portrait.jpg",
          "thumbnailUrl": "https://cdn.example.com/poets/ghalib-portrait-thumb.jpg",
          "contentText": "مرزا غالب",
          "likeCount": 312,
          "shareCount": 87,
          "bookmarkCount": 14,
          "poetPublicId": "poet_mirza_ghalib",
          "poetProfileImageUrl": "https://cdn.example.com/poets/ghalib-round.png",
          "poetBirthYear": 1797,
          "poetDeathYear": 1869,
          "poetName": "مرزا غالب"
        },
        "socialContext": {
          "totalReactions": 312,
          "trendingLabel": "Popular"
        }
      }
    ],
    "nextCursor": "eyJzaWQiOiI1NTBlODQwMC1lMjliLTQxZDQtYTcxNi00NDY2NTU0NDAwMDAiLCJwIjoyLCJsYW5nIjoidXIiLCJzZWVkIjoxNzA5MDAwMDAwLCJzaWciOiJITUFDLVNIQTI1Ni4uLiJ9",
    "hasMore": true,
    "isPersonalized": true,
    "sessionId": "550e8400-e29b-41d4-a716-446655440000",
    "itemCount": 20,
    "debugInfo": null
  }
}
```

**Error — Not Authenticated (401)**:
```json
{
  "success": false,
  "message": "Authentication required to access the feed",
  "data": null
}
```

**Invalid Cursor (no error):**
A missing, expired, or tampered cursor is silently ignored — the server starts a new feed session and returns fresh content. No error is returned to the client.

**Notes:**
- `hasMore` is **always `true`** — the feed never ends. When all fresh content is exhausted the dedup filter relaxes and content recycles.
- `itemCount: 0` with `hasMore: true` can occur when the cross-session seen history covers all candidates; pass `nextCursor` to continue and content will appear on the next page.
- The cursor is opaque (Base64-encoded HMAC-signed JSON) — treat it as a string, never parse it.
- An invalid or tampered cursor is silently treated as a new session (no error returned).
- `isPersonalized: false` means the feed ran in guest mode (only trending content, no personalization) — this should not happen as auth is required, but handle it defensively.
- **NEW:** `newCount` — only present when `refresh=true` was used. Indicates how many genuinely new items were returned. **Omitted entirely** (not present in JSON) on normal pagination requests.

---

### 17.3 FeedItem — Field Reference

Every item in the `items` array has these top-level fields:

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `type` | String | No | Content type: `COUPLET`, `POEM`, `POET_SPOTLIGHT`, `POET_IMAGE` |
| `publicId` | String | No | The public ID of the content item |
| `reason` | String | No | Why this item was included: `TRENDING`, `PERSONALIZED`, `DISCOVERY`, `CURATED`, `FOLLOWING`, `TIME_CAPSULE` |
| `sourceId` | String | No | Internal source identifier (e.g., `couplet_trending_7d`, `poet_following`, `delighter`, `deep_cuts`, `time_capsule`) — useful for A/B analytics |
| `lang` | String | No | Language of the content (`ur`, `en`, `hi`, …). Always set for all types |
| `contentData` | Object | No | Type-specific fields — see Section 17.4 |
| `socialContext` | Object | Yes | **NEW.** Social proof data. Only present on items with 10+ likes. `null` (omitted) for low-engagement items. See Section 17.3b |
| `displayMode` | String | Yes | **RESERVED.** Not currently sent. Will contain UI layout hint: `"compact"` or `"expanded"` when enabled |
| `primaryAction` | String | Yes | **RESERVED.** Not currently sent. Will contain CTA hint: `"react"`, `"read_more"`, `"follow"`, `"share"` when enabled |
| `autoExpandFirstVerse` | Boolean | Yes | **RESERVED.** Not currently sent. Will be `true` for POEM items when enabled |
| `previewDurationMs` | Integer | Yes | **RESERVED.** Not currently sent. For future audio auto-play duration |

**New `reason` values (March 2026):**
- `FOLLOWING` — content from a poet the user follows. Highest priority source
- `TIME_CAPSULE` — resurfaced bookmark ("You saved this 2 months ago"). Only appears after extensive scrolling (500+ items viewed)

**New `sourceId` values (March 2026):**
| sourceId | Description | When Active |
|----------|-------------|-------------|
| `poet_following` | Couplets/poems from followed poets | When user follows at least 1 poet |
| `delighter` | Hidden gem — unexpected quality content | Always (low weight, injected strategically) |
| `deep_cuts` | Undiscovered poets with quality content | After 200+ items viewed in session |
| `time_capsule` | Resurfaced old bookmarks | After 500+ items viewed in session |

---

### 17.3a Display Hints (Reserved — Not Currently Sent)

> **Note:** These fields are defined in the schema and Flutter models but are **not currently populated** by the backend. They will always be `null` (omitted from JSON) until a future release enables them. Parse them defensively in your models but do not rely on them yet.

When enabled in a future release, they will contain:

| `displayMode` | Used by | Description |
|---------------|---------|-------------|
| `"compact"` | COUPLET, POET_SPOTLIGHT | Small card layout — shows content inline without expanding |
| `"expanded"` | POEM, POET_IMAGE | Larger card — shows more content, image-forward |

| `primaryAction` | Used by | Suggested CTA |
|-----------------|---------|---------------|
| `"react"` | COUPLET | Show heart/wah-wah reaction button prominently |
| `"read_more"` | POEM | Show "Read Full Poem" button |
| `"follow"` | POET_SPOTLIGHT | Show "Follow" button prominently |
| `"share"` | POET_IMAGE | Show share button prominently |

| Field | When Set | Purpose |
|-------|----------|---------|
| `autoExpandFirstVerse: true` | POEM items only | Show the matla (opening couplet) of the poem expanded by default |

**Flutter: define the fields but don't use them yet:**
```dart
// These fields are parsed from JSON but will always be null until backend enables them
final String? displayMode;          // future: "compact" | "expanded"
final String? primaryAction;        // future: "react" | "read_more" | "follow" | "share"
final bool? autoExpandFirstVerse;   // future: true for POEM
```

---

### 17.3b Social Context

The `socialContext` object provides social proof data to make the feed feel alive. It is **`null` (omitted from JSON) for items with fewer than 10 likes**. Most items in a new platform will not have socialContext — it activates as engagement grows.

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `reactedByNames` | String[] | Yes | First 2-3 names of users who reacted (reserved for future — currently `null`) |
| `totalReactions` | Integer | Yes | Total like count. `null` if 0 |
| `trendingLabel` | String | Yes | Badge text: `"Popular"` (100+ likes), `"Rising"` (50+ likes), or poet-specific like `"Followed by 500+ readers"` |
| `velocityLabel` | String | Yes | Recency signal: `"Trending now"` (created < 24h, 10+ likes) or `"Shared 5x this week"` |
| `activityLabel` | String | Yes | Social signal (reserved for future — currently `null`): `"3 people you follow reacted"` |

**Flutter rendering guidance:**
- Show `trendingLabel` as a badge/chip on the card (e.g., colored pill with "Popular")
- Show `velocityLabel` as a subtle line below the content (e.g., flame icon + "Trending now")
- Both are `null` for most items — only render when present
- `socialContext` itself is `null` for low-engagement items — always null-check before accessing fields

```dart
if (item.socialContext != null) {
  if (item.socialContext!.trendingLabel != null) {
    // Show badge: "Popular", "Rising", "Followed by 500+ readers"
  }
  if (item.socialContext!.velocityLabel != null) {
    // Show: 🔥 "Trending now"
  }
}

---

### 17.4 Content Type Data Fields

#### 17.4.1 COUPLET contentData

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `versesTextArabic` | String | Yes | Couplet text in original Arabic/Urdu script (Nastaliq) |
| `versesTextRoman` | String | Yes | Romanized transliteration |
| `poetPublicId` | String | Yes | Poet's public ID — navigate to poet profile |
| `poetProfileImageUrl` | String | Yes | Poet's profile image URL |
| `poetBirthYear` | Integer | Yes | Poet's birth year (e.g. `1797`) |
| `poetDeathYear` | Integer | Yes | Poet's death year (e.g. `1869`). `null` if still living or unknown |
| `poetName` | String | Yes | Poet's name in requested language |
| `poemPublicId` | String | Yes | Parent poem's public ID — navigate to full poem |
| `likeCount` | Integer | No | Total likes |
| `shareCount` | Integer | No | Total shares |
| `bookmarkCount` | Integer | No | Total bookmarks |

#### 17.4.2 POEM contentData

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `title` | String | Yes | Poem title in requested language |
| `excerpt` | String | Yes | First 150 characters of the poem content |
| `poetPublicId` | String | Yes | Poet's public ID |
| `poetProfileImageUrl` | String | Yes | Poet's profile image URL |
| `poetBirthYear` | Integer | Yes | Poet's birth year (e.g. `1877`) |
| `poetDeathYear` | Integer | Yes | Poet's death year (e.g. `1938`). `null` if still living or unknown |
| `poetName` | String | Yes | Poet's name in requested language |
| `poetryType` | String | Yes | Poetry form: `GHAZAL`, `NAZAM`, `RUBAI`, etc. |
| `likeCount` | Integer | No | Total likes |
| `viewCount` | Integer | No | Total views |
| `thumbnailUrl` | String | Yes | Cover image URL (may be null) |

#### 17.4.3 POET_SPOTLIGHT contentData

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `poetName` | String | Yes | Poet's name in requested language |
| `bio` | String | Yes | Short biography (up to 200 characters + "…"). Null if no bio. |
| `poetPublicId` | String | No | Poet's public ID |
| `profileImageUrl` | String | Yes | Poet's profile image URL |
| `birthYear` | Integer | Yes | Poet's birth year (e.g. `1911`) |
| `deathYear` | Integer | Yes | Poet's death year (e.g. `1984`). `null` if still living or unknown |
| `poemCount` | Integer | Yes | Number of poems by this poet |
| `followerCount` | Integer | Yes | Number of followers |
| `viewCount` | Integer | Yes | Total profile views |
| `featuredCouplet` | Object | Yes | The poet's most-liked couplet in the requested script. `null` if no couplets exist. |
| `featuredCouplet.coupletPublicId` | String | Yes | Public ID of the couplet |
| `featuredCouplet.verses` | String[] | Yes | Array of verse lines (usually 2). Render each on its own line. |
| `featuredCouplet.likeCount` | Integer | Yes | Like count on this couplet |
| `featuredCouplet.script` | String | Yes | Script of the verses: `ARABIC` (ur/RTL), `ROMAN` (en/LTR), `DEVANAGARI` (hi/LTR) |

**Rendering notes for `featuredCouplet`:**
- Show verses below the bio as a preview of the poet's finest work.
- `script = "ARABIC"` → RTL, Nastaliq font. `script = "ROMAN"` or `"DEVANAGARI"` → LTR.
- If `featuredCouplet` is `null`, render the poet card without the sher section.

#### 17.4.4 POET_IMAGE contentData

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `imageUrl` | String | Yes | Full-size image URL (CDN) |
| `thumbnailUrl` | String | Yes | Thumbnail image URL |
| `contentText` | String | Yes | Caption or associated poetry text |
| `likeCount` | Integer | No | Total likes on this image |
| `shareCount` | Integer | No | Total shares |
| `bookmarkCount` | Integer | No | Total bookmarks |
| `poetPublicId` | String | Yes | Associated poet's public ID |
| `poetProfileImageUrl` | String | Yes | Poet's profile image URL |
| `poetBirthYear` | Integer | Yes | Poet's birth year (e.g. `1797`) |
| `poetDeathYear` | Integer | Yes | Poet's death year (e.g. `1869`). `null` if still living or unknown |
| `poetName` | String | Yes | Poet's name in the requested language |

---

### 17.5 Report Feed Events

Send engagement signals after rendering each page. These events make the next page smarter: high dwell time boosts similar content; skip_fast demotes it.

**Endpoint**: `POST /api/events/batch`

**Authentication Required**: Yes (`Authorization: Bearer <jwt>`)

**Request Body**: Array of event objects

```json
[
  {
    "eid": "550e8400-e29b-41d4-a716-446655440001",
    "t": "impression",
    "itemKey": "COUPLET:couplet_abc123",
    "sid": "550e8400-e29b-41d4-a716-446655440000",
    "ts": 1709000000
  },
  {
    "eid": "550e8400-e29b-41d4-a716-446655440002",
    "t": "dwell_ms",
    "itemKey": "COUPLET:couplet_abc123",
    "sid": "550e8400-e29b-41d4-a716-446655440000",
    "ts": 1709000001,
    "v": 4200
  },
  {
    "eid": "550e8400-e29b-41d4-a716-446655440003",
    "t": "open_item",
    "itemKey": "POEM:poem_def456",
    "sid": "550e8400-e29b-41d4-a716-446655440000",
    "ts": 1709000002
  },
  {
    "eid": "550e8400-e29b-41d4-a716-446655440004",
    "t": "skip_fast",
    "itemKey": "POET_SPOTLIGHT:poet_faiz_ahmed",
    "sid": "550e8400-e29b-41d4-a716-446655440000",
    "ts": 1709000003
  }
]
```

**Event Fields:**

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `eid` | String (UUID) | Recommended | Client-generated UUID for idempotency. Include to safely retry without duplicate processing |
| `t` | String | Yes | Event type (see table below) |
| `itemKey` | String | Yes | `"TYPE:publicId"` — e.g., `"COUPLET:couplet_abc123"`, `"POET_SPOTLIGHT:poet_xyz"` |
| `sid` | String | Yes | Feed session ID from `sessionId` in the feed response |
| `ts` | Long | Yes | Unix timestamp in seconds when the event occurred |
| `v` | Long | No | Numeric value — only used for `dwell_ms` (value = milliseconds) |

**Event Types:**

| Type | Signal | When to Send |
|------|--------|-------------|
| `impression` | Item appeared on screen | When item enters the visible viewport |
| `dwell_ms` | Milliseconds spent viewing | When item leaves viewport; `v` = time in ms |
| `open_item` | Tapped to view full content | User navigated to poem detail or poet profile |
| `bookmark` | Bookmarked from feed | Triggered by bookmark action in feed |
| `share` | Shared externally | Triggered by share action in feed |
| `follow` | Followed a poet from feed | Triggered by follow button in POET_SPOTLIGHT card |
| `skip_fast` | Scrolled past in < 500ms | Item shown for less than 500ms (negative signal) |
| `hide` | "Not interested" | User explicitly dismissed the item |
| `report` | Reported content | User reported inappropriate content |

**Success Response (202 Accepted)**:
```
HTTP 202 Accepted
(empty body)
```

**Notes:**
- The response is always `202` — processing happens asynchronously
- The `eid` field enables safe retries: sending the same event twice with the same `eid` + `sid` is idempotent
- Send events in batches (not one by one) — batch at minimum when the user scrolls to the next page
- `itemKey` format: `"CONTENT_TYPE:publicId"` using the `type` field from the FeedItem uppercased
- For `share` events: the backend automatically increments `share_count` on the entity (COUPLET, POEM, POET_IMAGE). No separate share endpoint call is needed for count tracking from the feed.

---

### 17.5a Feed Share Pattern (Native Share Sheet)

The feed share button uses Flutter's native system share sheet (no deeplinks). The pattern varies by feed item type:

| Feed Type | Share Text | Share Image | Backend call |
|-----------|------------|-------------|--------------|
| `COUPLET` | `versesTextArabic + "\n\n— " + poetName` | none | none before share |
| `POEM` | `title + "\n" + firstLineExcerpt + "\n\n— " + poetName` | `thumbnailUrl` (optional) | none before share |
| `POET_IMAGE` | returned by API | `shareImageUrl` (download first) | `POST /api/poetry-images/{id}/share?lang=ur` |
| `POET_SPOTLIGHT` | `poetName + "\n\n" + shortBio` | `profileImageUrl` (optional) | none |

**For COUPLET / POEM / POET_SPOTLIGHT** — build content from `contentData` already in the feed item and open the share sheet directly. Zero latency.

**For POET_IMAGE** — call `POST /api/poetry-images/{id}/share?lang=ur` first to get pre-formatted `shareText` and `shareImageUrl`. Download the image, then open the share sheet.

**After every successful share** (share sheet returned a result, user did not cancel), fire a feed event:

```json
POST /api/events/batch
[{
  "eid": "550e8400-e29b-41d4-a716-446655440001",
  "t": "share",
  "itemKey": "COUPLET:couplet_abc123",
  "sid": "550e8400-e29b-41d4-a716-446655440000",
  "ts": 1709000010
}]
```

This single event handles both personalization (session interest weight +4) and `share_count` increment on the entity. For POET_IMAGE, the `POST /api/poetry-images/{id}/share` call already increments `share_count`, so the feed event provides the personalization signal only.

**Flutter share_plus example for COUPLET:**
```dart
Future<void> shareFeedCouplet(FeedItem item) async {
  final data = item.contentData;
  final text = '${data['versesTextArabic']}\n\n— ${data['poetName']}';
  final result = await Share.share(text);
  if (result.status == ShareResultStatus.success) {
    feedEventsQueue.add(FeedEvent(t: 'share', itemKey: 'COUPLET:${item.publicId}', sid: sessionId));
  }
}
```

**Flutter share_plus example for POET_IMAGE:**
```dart
Future<void> shareFeedPoetImage(FeedItem item) async {
  // Get formatted share text + image URL from backend
  final resp = await api.post('/poetry-images/${item.publicId}/share?lang=$lang');
  final shareInfo = resp.data['data'];

  // Download image to temp file
  final tmpFile = await downloadToTemp(shareInfo['shareImageUrl']);
  final result = await Share.shareXFiles(
    [XFile(tmpFile.path)],
    text: shareInfo['shareText'] ?? '',
  );
  if (result.status == ShareResultStatus.success) {
    feedEventsQueue.add(FeedEvent(t: 'share', itemKey: 'POET_IMAGE:${item.publicId}', sid: sessionId));
  }
}
```

---

### 17.6 Cursor Pagination Guide

#### First Page (App Opens / Pull-to-Refresh)
```
GET /api/feed?lang=ur
Authorization: Bearer <jwt>
```
- No `cursor` param → server starts a new session
- Save `data.sessionId` and `data.nextCursor` from the response

#### Next Page (User Scrolls to Bottom)
```
GET /api/feed?lang=ur&cursor=<nextCursor from previous response>
Authorization: Bearer <jwt>
```
- Pass the exact `nextCursor` string — do not parse or modify it
- Keep updating `nextCursor` with the new value from each response

#### End of Feed
- `hasMore` is **always `true`** — the feed never ends; it recycles content when the pool is exhausted.
- `itemCount: 0` with `hasMore: true` means cross-session seen history temporarily covered all candidates — pass `nextCursor` as-is and fresh items will appear on the next page.
- There is no `hasMore == false` end signal. Never stop polling based on `hasMore`; stop only when the user leaves the feed screen.

#### Pull-to-Refresh (Smart — Recommended) ⭐ NEW
Use `refresh=true` with the existing cursor to get only new items without losing the user's place:
```
GET /api/feed?lang=ur&cursor=<existingCursor>&refresh=true
Authorization: Bearer <jwt>
```
- Session stays the same (same seed, same seen set)
- Only items created since the last fetch are returned
- Response includes `newCount` — the number of genuinely new items
- **Prepend** new items to the top of your list (don't replace)
- Keep using the new `nextCursor` for subsequent pagination

```dart
Future<void> smartRefresh() async {
  final response = await api.getFeed(
    lang: lang,
    cursor: _nextCursor,  // keep existing cursor
    refresh: true,
  );
  if (response != null && response.items.isNotEmpty) {
    _items.insertAll(0, response.items);  // prepend to top
    _nextCursor = response.nextCursor;
    notifyListeners();
  }
}
```

#### Pull-to-Refresh (Full Reset — Legacy)
To completely reshuffle the feed (new session, new ordering):
- Clear your local cursor (`nextCursor = null`)
- Send `GET /api/feed?lang=ur` with no cursor
- Replace the entire item list with the new response

**When to use which:**
- **Smart refresh** (`refresh=true`): User pulls to check for new content. Fast, preserves context
- **Full reset** (no cursor): User explicitly wants a fresh experience, or cold app start

---

### 17.7 Flutter Implementation Guide

#### Data Models

```dart
class FeedResponse {
  final List<FeedItem> items;
  final String? nextCursor;
  final bool hasMore;
  final bool isPersonalized;
  final String sessionId;
  final int itemCount;
  final int? newCount;        // NEW: only set on refresh=true — number of genuinely new items

  FeedResponse({
    required this.items,
    this.nextCursor,
    required this.hasMore,
    required this.isPersonalized,
    required this.sessionId,
    required this.itemCount,
    this.newCount,
  });

  factory FeedResponse.fromJson(Map<String, dynamic> json) {
    return FeedResponse(
      items: (json['items'] as List)
          .map((i) => FeedItem.fromJson(i))
          .toList(),
      nextCursor: json['nextCursor'],
      hasMore: json['hasMore'] ?? true,
      isPersonalized: json['isPersonalized'] ?? false,
      sessionId: json['sessionId'] ?? '',
      itemCount: json['itemCount'] ?? 0,
      newCount: json['newCount'],
    );
  }
}

class FeedItem {
  final String type;        // COUPLET | POEM | POET_SPOTLIGHT | POET_IMAGE
  final String publicId;
  final String reason;      // TRENDING | PERSONALIZED | DISCOVERY | CURATED | FOLLOWING | TIME_CAPSULE
  final String sourceId;
  final String? lang;
  final Map<String, dynamic> contentData;

  // Social proof (v2) — only present on items with 10+ likes
  final SocialContext? socialContext;

  // Display hints (RESERVED — not currently sent by backend, always null for now)
  final String? displayMode;          // future: "compact" | "expanded"
  final String? primaryAction;        // future: "react" | "read_more" | "follow" | "share"
  final bool? autoExpandFirstVerse;   // future: true for POEM — show matla expanded
  final int? previewDurationMs;       // future: audio auto-play duration

  FeedItem({
    required this.type,
    required this.publicId,
    required this.reason,
    required this.sourceId,
    this.lang,
    required this.contentData,
    this.socialContext,
    this.displayMode,
    this.primaryAction,
    this.autoExpandFirstVerse,
    this.previewDurationMs,
  });

  factory FeedItem.fromJson(Map<String, dynamic> json) {
    return FeedItem(
      type: json['type'],
      publicId: json['publicId'],
      reason: json['reason'] ?? '',
      sourceId: json['sourceId'] ?? '',
      lang: json['lang'],
      contentData: Map<String, dynamic>.from(json['contentData'] ?? {}),
      socialContext: json['socialContext'] != null
          ? SocialContext.fromJson(json['socialContext'])
          : null,
      // Reserved fields — not currently sent by backend, always null for now
      displayMode: json['displayMode'],
      primaryAction: json['primaryAction'],
      autoExpandFirstVerse: json['autoExpandFirstVerse'],
      previewDurationMs: json['previewDurationMs'],
    );
  }
}

class SocialContext {
  final List<String>? reactedByNames;
  final int? totalReactions;
  final String? trendingLabel;
  final String? velocityLabel;
  final String? activityLabel;

  SocialContext({
    this.reactedByNames,
    this.totalReactions,
    this.trendingLabel,
    this.velocityLabel,
    this.activityLabel,
  });

  factory SocialContext.fromJson(Map<String, dynamic> json) {
    return SocialContext(
      reactedByNames: json['reactedByNames'] != null
          ? List<String>.from(json['reactedByNames'])
          : null,
      totalReactions: json['totalReactions'],
      trendingLabel: json['trendingLabel'],
      velocityLabel: json['velocityLabel'],
      activityLabel: json['activityLabel'],
    );
  }
}

class FeedEvent {
  final String eid;         // UUID — generate one per event for idempotency
  final String t;           // event type
  final String itemKey;     // "COUPLET:publicId"
  final String sid;         // feed session ID
  final int ts;             // unix timestamp (seconds)
  final int? v;             // optional value (dwell_ms)

  FeedEvent({
    required this.eid,
    required this.t,
    required this.itemKey,
    required this.sid,
    required this.ts,
    this.v,
  });

  Map<String, dynamic> toJson() => {
    'eid': eid,
    't': t,
    'itemKey': itemKey,
    'sid': sid,
    'ts': ts,
    if (v != null) 'v': v,
  };
}
```

#### Feed Service (API Calls)

```dart
class FeedApiService {
  final String baseUrl;
  final String? authToken;

  FeedApiService({required this.baseUrl, this.authToken});

  Future<FeedResponse?> getFeed({
    String lang = 'ur',
    String? cursor,
    int limit = 20,
    bool refresh = false,
  }) async {
    final uri = Uri.parse('$baseUrl/api/feed').replace(queryParameters: {
      'lang': lang,
      'limit': '$limit',
      if (cursor != null) 'cursor': cursor,
      if (refresh) 'refresh': 'true',
    });

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $authToken',
      'Content-Type': 'application/json',
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['success'] == true) {
        return FeedResponse.fromJson(body['data']);
      }
    }
    return null;
  }

  Future<void> sendEvents(List<FeedEvent> events) async {
    if (events.isEmpty) return;
    try {
      await http.post(
        Uri.parse('$baseUrl/api/events/batch'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(events.map((e) => e.toJson()).toList()),
      );
      // 202 = success; ignore other status codes (best-effort)
    } catch (_) {
      // Events are non-critical — never let this crash the UI
    }
  }
}
```

#### Feed State Controller (infinite scroll + event batching)

```dart
class FeedController extends ChangeNotifier {
  final FeedApiService api;
  final String lang;

  List<FeedItem> _items = [];
  String? _nextCursor;
  String? _sessionId;
  bool _hasMore = true;
  bool _loading = false;
  bool _error = false;

  // Event buffer — flushed on page load and dispose
  final List<FeedEvent> _pendingEvents = [];
  final Map<String, int> _impressionStartTimes = {};

  List<FeedItem> get items => _items;
  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get error => _error;

  FeedController({required this.api, this.lang = 'ur'});

  /// Load first page (call on init or full reset)
  Future<void> loadFirstPage() async {
    await _flushEvents();           // flush events from previous session
    _items = [];
    _nextCursor = null;
    _sessionId = null;
    _hasMore = true;
    _error = false;
    await _loadPage();
  }

  /// Smart pull-to-refresh — returns only new items, preserves session context
  Future<void> smartRefresh() async {
    if (_nextCursor == null) {
      // No existing session — fall back to full reset
      await loadFirstPage();
      return;
    }
    final response = await api.getFeed(
      lang: lang,
      cursor: _nextCursor,
      refresh: true,
    );
    if (response != null && response.items.isNotEmpty) {
      _items.insertAll(0, response.items); // prepend new items to top
      _nextCursor = response.nextCursor;
      _sessionId = response.sessionId;
      notifyListeners();
    }
  }

  /// Load next page (call when user scrolls near bottom)
  Future<void> loadNextPage() async {
    if (_loading || !_hasMore) return;
    await _flushEvents();           // send events from current page before fetching next
    await _loadPage();
  }

  Future<void> _loadPage() async {
    _loading = true;
    _error = false;
    notifyListeners();

    final response = await api.getFeed(
      lang: lang,
      cursor: _nextCursor,
    );

    _loading = false;
    if (response == null) {
      _error = true;
    } else {
      _items.addAll(response.items);
      _nextCursor = response.nextCursor;
      _sessionId = response.sessionId;
      _hasMore = response.hasMore;
    }
    notifyListeners();
  }

  // ─── Event tracking ──────────────────────────────────────────────────────

  void onItemVisible(FeedItem item) {
    _impressionStartTimes[item.publicId] = DateTime.now().millisecondsSinceEpoch;
    _addEvent(FeedEvent(
      eid: _uuid(),
      t: 'impression',
      itemKey: '${item.type}:${item.publicId}',
      sid: _sessionId ?? '',
      ts: _nowSec(),
    ));
  }

  void onItemHidden(FeedItem item) {
    final start = _impressionStartTimes.remove(item.publicId);
    if (start != null) {
      final dwellMs = DateTime.now().millisecondsSinceEpoch - start;
      if (dwellMs < 500) {
        // Scrolled past too fast — negative signal
        _addEvent(FeedEvent(
          eid: _uuid(),
          t: 'skip_fast',
          itemKey: '${item.type}:${item.publicId}',
          sid: _sessionId ?? '',
          ts: _nowSec(),
        ));
      } else {
        _addEvent(FeedEvent(
          eid: _uuid(),
          t: 'dwell_ms',
          itemKey: '${item.type}:${item.publicId}',
          sid: _sessionId ?? '',
          ts: _nowSec(),
          v: dwellMs,
        ));
      }
    }
  }

  void onItemOpened(FeedItem item) {
    _addEvent(FeedEvent(
      eid: _uuid(),
      t: 'open_item',
      itemKey: '${item.type}:${item.publicId}',
      sid: _sessionId ?? '',
      ts: _nowSec(),
    ));
  }

  void onPoetFollowed(FeedItem item) {
    _addEvent(FeedEvent(
      eid: _uuid(),
      t: 'follow',
      itemKey: '${item.type}:${item.publicId}',
      sid: _sessionId ?? '',
      ts: _nowSec(),
    ));
  }

  void _addEvent(FeedEvent event) {
    _pendingEvents.add(event);
  }

  Future<void> _flushEvents() async {
    if (_pendingEvents.isEmpty || _sessionId == null) return;
    final batch = List<FeedEvent>.from(_pendingEvents);
    _pendingEvents.clear();
    await api.sendEvents(batch);
  }

  @override
  void dispose() {
    _flushEvents(); // best-effort flush on screen exit
    super.dispose();
  }

  int _nowSec() => DateTime.now().millisecondsSinceEpoch ~/ 1000;
  String _uuid() => DateTime.now().microsecondsSinceEpoch.toString() +
      (1000 + (DateTime.now().millisecond % 1000)).toString();
}
```

> **Note:** For production use, replace the `_uuid()` helper with a proper UUID library (e.g., `package:uuid`).

#### Rendering Feed Items

```dart
Widget buildFeedItem(FeedItem item) {
  switch (item.type) {
    case 'COUPLET':
      return CoupletFeedCard(item: item);
    case 'POEM':
      return PoemFeedCard(item: item);
    case 'POET_SPOTLIGHT':
      return PoetSpotlightCard(item: item);
    case 'POET_IMAGE':
      return PoetImageCard(item: item);
    default:
      return const SizedBox.shrink(); // unknown future type — skip silently
  }
}

// Example: Couplet card with social proof + following badge
class CoupletFeedCard extends StatelessWidget {
  final FeedItem item;
  const CoupletFeedCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final data = item.contentData;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Social proof badge (only present on items with 10+ likes)
            if (item.socialContext?.trendingLabel != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(item.socialContext!.trendingLabel!,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            // "Following" reason badge (v2)
            if (item.reason == 'FOLLOWING')
              const Text('From a poet you follow',
                  style: TextStyle(fontSize: 11, color: Colors.blue)),
            if (data['versesTextArabic'] != null)
              Text(data['versesTextArabic'],
                  style: const TextStyle(fontSize: 20, fontFamily: 'NotoNastaliqUrdu')),
            if (data['versesTextRoman'] != null)
              Text(data['versesTextRoman'],
                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 8),
            if (data['poetName'] != null)
              Text('— ${data['poetName']}',
                  style: const TextStyle(fontStyle: FontStyle.italic)),
            // Velocity label (only on trending content with recent engagement)
            if (item.socialContext?.velocityLabel != null)
              Text('${item.socialContext!.velocityLabel!}',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700)),
            Row(
              children: [
                const Icon(Icons.favorite_border, size: 16),
                Text(' ${data['likeCount'] ?? 0}'),
                const SizedBox(width: 12),
                const Icon(Icons.share, size: 16),
                Text(' ${data['shareCount'] ?? 0}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

#### Infinite Scroll ListView

```dart
class FeedScreen extends StatefulWidget {
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late FeedController _controller;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = FeedController(api: FeedApiService(
      baseUrl: AppConfig.baseUrl,
      authToken: AuthService.instance.token,
    ));
    _controller.loadFirstPage();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      _controller.loadNextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => RefreshIndicator(
        onRefresh: _controller.smartRefresh, // smart refresh (preserves session)
        child: ListView.builder(
          controller: _scrollController,
          itemCount: _controller.items.length + 1,
          itemBuilder: (context, index) {
            if (index == _controller.items.length) {
              return _controller.hasMore
                  ? const Center(child: CircularProgressIndicator())
                  : const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('آپ نے سب کچھ دیکھ لیا')),
                    );
            }
            final item = _controller.items[index];
            return VisibilityDetector(
              key: Key(item.publicId),
              onVisibilityChanged: (info) {
                if (info.visibleFraction > 0.5) {
                  _controller.onItemVisible(item);
                } else {
                  _controller.onItemHidden(item);
                }
              },
              child: GestureDetector(
                onTap: () {
                  _controller.onItemOpened(item);
                  // Navigate to detail screen
                },
                child: buildFeedItem(item),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }
}
```

> Use `package:visibility_detector` for `VisibilityDetector`. Add to `pubspec.yaml`:
> ```yaml
> visibility_detector: ^0.4.0+2
> ```

---

---

## 18. Hashtags & Discovery {#18-hashtags-discovery}

### 18.1 Tags vs Hashtags

The platform has two related but distinct systems:

| Concept | Tags | Hashtags |
|---------|------|----------|
| **What it is** | Admin-curated reference library (~108 entries) | Free-form slugs stored on content |
| **Who creates them** | Admin portal only | Created automatically when slugs are added to poems, images, etc. |
| **Where stored** | `tags` DB table | `tagSlugs` JSON array on `poems`, `couplets`, `poet_images`, `poets`, `poet_books`, `poet_videos` |
| **Purpose** | Canonical vocabulary, filtering in admin | Public discovery pages (like Instagram hashtags) |
| **API** | `/api/tags/**` | `/api/hashtags/**` |

**Key insight:** When an admin tags a poem with slug `"ishq"`, that slug automatically becomes a hashtag page at `GET /api/hashtags/ishq/poems`. No separate hashtag creation needed — it's emergent from the content tagging system.

Couplets inherit `tagSlugs` from their parent poem. All `CoupletDto` and `CoupletDetailResponse` objects now include a `tagSlugs` field.

---

### 18.2 All Hashtags (Paginated List) {#182-all-hashtags-paginated-list}

**Endpoint:** `GET /api/hashtags?page=0&size=20&search=ishq&sort=totalUsage,desc`

**Authentication:** Not required

**Description:** Paginated, searchable, filterable list of all distinct hashtags. Use this for a hashtag browser/directory screen. Unlike the trending endpoint, this covers **all** hashtags with full pagination.

**Query Parameters:**
- `page` (optional, default: `0`) - Page number (zero-based)
- `size` (optional, default: `20`, max: `100`) - Results per page
- `search` (optional) - Partial match on slug OR display name
- `sort` (optional, default: `totalUsage,desc`) - Sort field + direction
  - `totalUsage,desc` — most used overall (default)
  - `poemCount,desc` — most used on poems
  - `imageCount,desc` — most used on images
  - `poetCount,desc` — most used on poets
  - `bookCount,desc` — most used on books
  - `videoCount,desc` — most used on videos
  - `slug,asc` — alphabetical
  - `name,asc` — alphabetical by display name
- `languageCode` (optional) - Only hashtags with a matching admin Tag in this language (`ur`, `en`, `hi`)
- `tagType` (optional) - Only hashtags with a matching admin Tag of this type (`THEME`, `POEM_GENRE`, `ERA`, `MOOD`, etc.)

> **Note:** `coupletCount` is not in the list response (not scalable per-slug from ES). Use `GET /api/hashtags/{slug}` for full counts including couplets.

**Example:**
```bash
curl "http://localhost:8081/api/hashtags?page=0&size=20&search=ishq&sort=totalUsage,desc"
```

**Response:**
```json
{
  "success": true,
  "message": "Found 320 hashtags",
  "data": {
    "content": [
      {
        "slug": "ishq",
        "name": "عشق",
        "color": "#E91E63",
        "languageCode": "ur",
        "tagType": "THEME",
        "poemCount": 320,
        "imageCount": 45,
        "totalUsage": 365
      },
      {
        "slug": "dillagi",
        "name": "dillagi",
        "poemCount": 80,
        "imageCount": 12,
        "totalUsage": 92
      }
    ],
    "totalElements": 320,
    "totalPages": 16,
    "number": 0,
    "size": 20,
    "first": true,
    "last": false,
    "empty": false
  }
}
```

---

### 18.3 Trending Hashtags {#183-trending-hashtags}

**Endpoint:** `GET /api/hashtags/trending?limit=20`

**Authentication:** Not required

**Description:** Returns the most-used hashtags ranked by couplet count (via Elasticsearch aggregation). Falls back to poem tag counts if ES is unavailable.

**Query Parameters:**
- `limit` (optional, default: `20`, max: `50`) - Number of hashtags to return

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/trending?limit=10"
```

**Response:**
```json
{
  "success": true,
  "message": "Found 10 trending hashtags",
  "data": [
    {
      "slug": "ishq",
      "name": "عشق",
      "color": "#E91E63",
      "languageCode": "ur",
      "tagType": "THEME",
      "coupletCount": 1240,
      "poemCount": null,
      "imageCount": null,
      "totalUsage": 1240
    },
    {
      "slug": "ghazal",
      "name": "غزل",
      "color": "#9C27B0",
      "languageCode": "ur",
      "tagType": "POEM_GENRE",
      "coupletCount": 980,
      "poemCount": null,
      "imageCount": null,
      "totalUsage": 980
    }
  ]
}
```

> **Note:** The trending endpoint ranks by `coupletCount` only. Use `/api/hashtags/{slug}` to get full counts across all content types.

---

### 18.4 Hashtag Stats {#184-hashtag-stats}

**Endpoint:** `GET /api/hashtags/stats?topLimit=10`

**Authentication:** Not required

**Description:** Platform-wide hashtag statistics. Useful for an analytics or admin overview.

**Query Parameters:**
- `topLimit` (optional, default: `10`, max: `50`) - Number of top hashtags to include

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/stats"
```

**Response:**
```json
{
  "success": true,
  "message": "Hashtag statistics",
  "data": {
    "totalDistinctHashtags": 320,
    "totalPoemTagUsage": 4820,
    "totalImageTagUsage": 1205,
    "adminTagCount": 108,
    "topHashtags": [
      {
        "slug": "ishq",
        "name": "عشق",
        "color": "#E91E63",
        "languageCode": "ur",
        "tagType": "THEME",
        "coupletCount": 1240,
        "poemCount": null,
        "imageCount": null,
        "totalUsage": 1240
      }
    ]
  }
}
```

---

### 18.5 Single Hashtag Metadata {#185-single-hashtag-metadata}

**Endpoint:** `GET /api/hashtags/{slug}`

**Authentication:** Not required

**Description:** Full metadata for a single hashtag — counts across poems, couplets, and images. Use this to render a hashtag page header.

**Path Parameters:**
- `slug` - The hashtag slug (e.g., `ishq`, `ghazal`, `mohabbat`)

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/ishq"
```

**Response:**
```json
{
  "success": true,
  "message": "Hashtag: #ishq",
  "data": {
    "slug": "ishq",
    "name": "عشق",
    "color": "#E91E63",
    "languageCode": "ur",
    "tagType": "THEME",
    "coupletCount": 1240,
    "poemCount": 320,
    "imageCount": 45,
    "totalUsage": 1605
  }
}
```

> **Tip:** If the slug does not have a matching admin `Tag` entry, `name` defaults to the slug itself, and `color`, `languageCode`, `tagType` will be `null`.

---

### 18.6 Poems by Hashtag {#186-poems-by-hashtag}

**Endpoint:** `GET /api/hashtags/{slug}/poems?lang=ur&page=0&size=10`

**Authentication:** Not required

**Description:** Paginated list of poems tagged with this hashtag, ordered by engagement (share count + like count).

**Path Parameters:**
- `slug` - Hashtag slug

**Query Parameters:**
- `lang` (optional, default: `ur`) - Language code for poem content (ur, en, hi)
- `page` (optional, default: `0`) - Page number
- `size` (optional, default: `10`, max: `50`) - Results per page

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/ishq/poems?lang=ur&page=0&size=10"
```

**Response:** Same as `PoemDetailResponse` paginated — see Section 5 for field reference.

---

### 18.7 Couplets by Hashtag {#187-couplets-by-hashtag}

**Endpoint:** `GET /api/hashtags/{slug}/couplets?lang=ur&page=0&size=10`

**Authentication:** Not required

**Description:** Paginated list of couplets tagged with this hashtag (via Elasticsearch). Falls back to empty page if ES is unavailable.

**Path Parameters:**
- `slug` - Hashtag slug

**Query Parameters:**
- `lang` (optional, default: `ur`) - Language code for verse text
- `page` (optional, default: `0`) - Page number
- `size` (optional, default: `10`, max: `50`) - Results per page

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/ishq/couplets?lang=ur&page=0&size=20"
```

**Response:** Paginated `CoupletDto` — see Section 6 for field reference. Each couplet now includes `tagSlugs`.

---

### 18.8 Images by Hashtag {#188-images-by-hashtag}

**Endpoint:** `GET /api/hashtags/{slug}/images?page=0&size=20`

**Authentication:** Not required

**Description:** Paginated list of poet gallery images (POETRY type) tagged with this hashtag, ordered by engagement.

**Path Parameters:**
- `slug` - Hashtag slug

**Query Parameters:**
- `page` (optional, default: `0`) - Page number
- `size` (optional, default: `20`, max: `50`) - Results per page

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/ishq/images?page=0&size=20"
```

**Response:** Paginated `PoetImageDto` — includes `tagSlugs`, `likeCount`, `bookmarkCount`, `shareCount`.

---

### 18.9 Poets by Hashtag {#189-poets-by-hashtag}

**Endpoint:** `GET /api/hashtags/{slug}/poets?lang=ur&page=0&size=20`

**Authentication:** Not required

**Description:** Paginated list of poets tagged with this hashtag slug (via `tagSlugs` JSONB field on poets), ordered by follower count then poem count.

**Path Parameters:**
- `slug` - Hashtag slug

**Query Parameters:**
- `lang` (optional, default: `ur`) - Language code for poet name/bio
- `page` (optional, default: `0`) - Page number
- `size` (optional, default: `20`, max: `50`) - Results per page

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/classical/poets?lang=ur&page=0&size=20"
```

**Response:** Paginated `PoetSummaryResponse` — same structure as poet list endpoints (Section 3).

---

### 18.10 Books by Hashtag {#1810-books-by-hashtag}

**Endpoint:** `GET /api/hashtags/{slug}/books?page=0&size=20`

**Authentication:** Not required

**Description:** Paginated list of poet books tagged with this hashtag slug, ordered by creation date descending.

**Path Parameters:**
- `slug` - Hashtag slug

**Query Parameters:**
- `page` (optional, default: `0`) - Page number
- `size` (optional, default: `20`, max: `50`) - Results per page

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/classical/books?page=0&size=20"
```

**Response:** Paginated `PoetBookDto` — same structure as book list endpoints (Section 3).

---

### 18.11 Videos by Hashtag {#1811-videos-by-hashtag}

**Endpoint:** `GET /api/hashtags/{slug}/videos?page=0&size=20`

**Authentication:** Not required

**Description:** Paginated list of poet videos tagged with this hashtag slug, ordered by creation date descending.

**Path Parameters:**
- `slug` - Hashtag slug

**Query Parameters:**
- `page` (optional, default: `0`) - Page number
- `size` (optional, default: `20`, max: `50`) - Results per page

**Example:**
```bash
curl "http://localhost:8081/api/hashtags/classical/videos?page=0&size=20"
```

**Response:** Paginated `PoetVideoDto` — same structure as video list endpoints (Section 3).

---

### 18.12 Filter Search by Hashtag {#1812-filter-search-by-hashtag}

Both the couplet search and poem search endpoints support filtering by hashtag slugs.

**Couplet Search with hashtag filter:**
```bash
# Couplets about "ishq" AND "ghazal"
GET /api/search/couplets?q=*&tags=ishq&tags=ghazal&sort=likes&lang=ur
```

**Poem Search with hashtag filter (via PoemSearchRequest body or query params):**
```bash
# Poems tagged with "mohabbat"
GET /api/search/poems?q=*&tagSlugs=mohabbat
```

**Filter logic:** All provided slugs must be present on the content (AND logic). This matches how multi-tag filtering works on content platforms.

---

### 18.13 HashtagDto Reference {#1813-hashtagdto-reference}

All hashtag endpoints return `HashtagDto` objects with this structure:

```typescript
interface HashtagDto {
  slug: string;           // URL-safe slug (e.g. "ishq")
  name: string | null;   // Display name — from admin Tag if exists, else the slug itself
  color: string | null;  // Hex color for UI pill (e.g. "#E91E63") — null if no admin Tag
  languageCode: string | null; // Primary language of this tag (ur, en, hi) — null if no admin Tag
  tagType: string | null; // One of: THEME, POEM_GENRE, ERA, POET_CATEGORY, MOOD, LANGUAGE — null if no admin Tag
  coupletCount: number | null; // Count of couplets with this tag
  poemCount: number | null;    // Count of poems with this tag
  imageCount: number | null;   // Count of poet images with this tag
  poetCount: number | null;    // Count of poets with this tag
  bookCount: number | null;    // Count of poet books with this tag
  videoCount: number | null;   // Count of poet videos with this tag
  totalUsage: number;          // Sum of all content counts (poem + couplet + image + poet + book + video)
}
```

> **Null fields:** Fields sourced from the admin `Tag` table (`color`, `languageCode`, `tagType`) will be `null` for hashtags that have no matching admin entry. The `name` field falls back to the slug string. Thanks to `@JsonInclude(NON_NULL)`, null fields are omitted from the response.

---

### 18.14 Flutter Implementation Guide {#1814-flutter-implementation-guide}

#### Hashtag Pill Widget

```dart
/// Renders a single hashtag pill. Tapping navigates to the hashtag page.
class HashtagPill extends StatelessWidget {
  final HashtagDto hashtag;
  const HashtagPill({required this.hashtag, super.key});

  @override
  Widget build(BuildContext context) {
    final color = hashtag.color != null
        ? Color(int.parse(hashtag.color!.replaceAll('#', '0xFF')))
        : Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HashtagPage(slug: hashtag.slug),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Text(
          '#${hashtag.name ?? hashtag.slug}',
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
```

#### Hashtag Page (content tabs)

```dart
/// Full hashtag page with poems/couplets/images tabs.
class HashtagPage extends StatefulWidget {
  final String slug;
  const HashtagPage({required this.slug, super.key});
  @override
  State<HashtagPage> createState() => _HashtagPageState();
}

class _HashtagPageState extends State<HashtagPage> with SingleTickerProviderStateMixin {
  late TabController _tab;
  HashtagDto? _meta;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 6, vsync: this); // poems, couplets, images, poets, books, videos
    _loadMeta();
  }

  Future<void> _loadMeta() async {
    final res = await http.get(Uri.parse('/api/hashtags/${widget.slug}'));
    if (res.statusCode == 200) {
      setState(() => _meta = HashtagDto.fromJson(jsonDecode(res.body)['data']));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('#${_meta?.name ?? widget.slug}'),
        bottom: TabBar(
          controller: _tab,
          tabs: [
            Tab(text: 'Couplets ${_meta != null ? "(${_meta!.coupletCount})" : ""}'),
            Tab(text: 'Poems ${_meta != null ? "(${_meta!.poemCount})" : ""}'),
            Tab(text: 'Images ${_meta != null ? "(${_meta!.imageCount})" : ""}'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          HashtagCoupletsTab(slug: widget.slug),
          HashtagPoemsTab(slug: widget.slug),
          HashtagImagesTab(slug: widget.slug),
        ],
      ),
    );
  }
}
```

#### Trending Hashtags on Discover Screen

```dart
// In discover screen, after loading the bundle:
// bundle.trendingHashtags is already included in GET /api/discover response

Widget _buildHashtagSection(List<HashtagDto> hashtags) {
  return SizedBox(
    height: 40,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: hashtags.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, i) => HashtagPill(hashtag: hashtags[i]),
    ),
  );
}
```

---

## 19. Unified Reactions System {#19-unified-reactions-system}

### 19.1 Overview — Reactions vs Likes

The reactions system **replaces** the old binary like/unlike with 10 expressive reaction types inspired by Urdu mushaira culture. Users can now react with WAH_WAH, SUBHAN_ALLAH, and more — making engagement richer and more culturally authentic.

**Key Concepts:**
- **One reaction per user per content** — a user can have only one active reaction on any piece of content
- **Toggle behavior** — tapping the same reaction removes it; tapping a different one changes it
- **Unified API** — one endpoint works for all content types (poems, couplets, poet images, generated images)
- **Backward compatible** — old `/like` endpoints still work, `likeCount`/`isLiked` fields preserved

**Target Content Types:**

| Path Segment | Target Type | Description |
|---|---|---|
| `poems` | POEM | Full poems |
| `couplets` | COUPLET | Individual couplets (sher) |
| `poetry-images` | POET_IMAGE | Poet gallery images |
| `generated-images` | GENERATED_IMAGE | User-created poetry images |

---

### 19.2 Available Reaction Types

| Key | Emoji | Urdu Label | English Label | When to Use |
|---|---|---|---|---|
| `LOVE` | ❤️ | پسند | Love | Default/general appreciation |
| `WAH_WAH` | 👏 | واہ واہ | Wah Wah | Classic mushaira response — "bravo!" |
| `SUBHAN_ALLAH` | 🤲 | سبحان اللہ | Subhan Allah | When poetry feels divine/sublime |
| `MAZA_AA_GAYA` | 🤩 | مزا آ گیا | Maza Aa Gaya | Thoroughly enjoyed — pure delight |
| `KYA_BAAT_HAI` | 💯 | کیا بات ہے | Kya Baat Hai | Impressive craft/wordplay |
| `FIRE` | 🔥 | لاجواب | Fire | Powerful/hard-hitting verse |
| `SAD` | 😢 | دل ٹوٹ گیا | Sad | Moved to tears/melancholy |
| `DEEP` | 🤔 | گہری بات | Deep | Thought-provoking/philosophical |
| `RELATABLE` | 🥹 | دل کی بات | Relatable | "This is my story" |
| `BEAUTIFUL` | ✨ | خوبصورت | Beautiful | Aesthetic beauty of words |

---

### 19.3 Get Reaction Types (Public)

**Endpoint:** `GET /api/reactions/types`

**Authentication:** Not required (public endpoint)

**Description:** Returns all available reaction types with emoji and multilingual labels. Cache this response — it rarely changes.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Reaction types retrieved",
  "data": [
    {
      "key": "LOVE",
      "emoji": "❤️",
      "urduLabel": "پسند",
      "englishLabel": "Love"
    },
    {
      "key": "WAH_WAH",
      "emoji": "👏",
      "urduLabel": "واہ واہ",
      "englishLabel": "Wah Wah"
    },
    {
      "key": "SUBHAN_ALLAH",
      "emoji": "🤲",
      "urduLabel": "سبحان اللہ",
      "englishLabel": "Subhan Allah"
    },
    {
      "key": "MAZA_AA_GAYA",
      "emoji": "🤩",
      "urduLabel": "مزا آ گیا",
      "englishLabel": "Maza Aa Gaya"
    },
    {
      "key": "KYA_BAAT_HAI",
      "emoji": "💯",
      "urduLabel": "کیا بات ہے",
      "englishLabel": "Kya Baat Hai"
    },
    {
      "key": "FIRE",
      "emoji": "🔥",
      "urduLabel": "لاجواب",
      "englishLabel": "Fire"
    },
    {
      "key": "SAD",
      "emoji": "😢",
      "urduLabel": "دل ٹوٹ گیا",
      "englishLabel": "Sad"
    },
    {
      "key": "DEEP",
      "emoji": "🤔",
      "urduLabel": "گہری بات",
      "englishLabel": "Deep"
    },
    {
      "key": "RELATABLE",
      "emoji": "🥹",
      "urduLabel": "دل کی بات",
      "englishLabel": "Relatable"
    },
    {
      "key": "BEAUTIFUL",
      "emoji": "✨",
      "urduLabel": "خوبصورت",
      "englishLabel": "Beautiful"
    }
  ]
}
```

**Flutter Usage:**
```dart
// Fetch once at app start and cache
final response = await dio.get('/api/reactions/types');
final reactionTypes = (response.data['data'] as List)
    .map((e) => ReactionType.fromJson(e))
    .toList();
```

---

### 19.4 React to Content

**Endpoint:** `POST /api/{targetType}/{publicId}/react`

**Authentication:** Required (Bearer token)

**Path Parameters:**

| Parameter | Type | Description |
|---|---|---|
| `targetType` | String | One of: `poems`, `couplets`, `poetry-images`, `generated-images` |
| `publicId` | String | Public ID of the content item |

**Request Body:**
```json
{
  "reactionType": "WAH_WAH"
}
```

**Valid `reactionType` values:** `LOVE`, `WAH_WAH`, `SUBHAN_ALLAH`, `MAZA_AA_GAYA`, `KYA_BAAT_HAI`, `FIRE`, `SAD`, `DEEP`, `RELATABLE`, `BEAUTIFUL`

**Behavior:**

| Current State | Action | Result |
|---|---|---|
| No reaction exists | Send `WAH_WAH` | Reaction added |
| User has `WAH_WAH` | Send `WAH_WAH` | Reaction **removed** (toggle off) |
| User has `LOVE` | Send `WAH_WAH` | Reaction **changed** to WAH_WAH |

**Response — Reaction Added (200):**
```json
{
  "success": true,
  "message": "Reaction added",
  "data": {
    "userReaction": "WAH_WAH",
    "totalReactionCount": 143,
    "reactionCounts": null,
    "message": "Reaction added"
  }
}
```

**Response — Reaction Changed (200):**
```json
{
  "success": true,
  "message": "Reaction changed",
  "data": {
    "userReaction": "FIRE",
    "totalReactionCount": 143,
    "reactionCounts": null,
    "message": "Reaction changed"
  }
}
```

**Response — Reaction Removed / Toggle Off (200):**
```json
{
  "success": true,
  "message": "Reaction removed",
  "data": {
    "userReaction": null,
    "totalReactionCount": 142,
    "reactionCounts": null,
    "message": "Reaction removed"
  }
}
```

**Error — Not Authenticated (401):**
```json
{
  "success": false,
  "message": "Authentication required"
}
```

**Error — Invalid Target Type (400):**
```json
{
  "success": false,
  "message": "Invalid target type: unknown-type"
}
```

**Examples:**

```bash
# React to a poem with WAH_WAH
curl -X POST http://localhost:8081/api/poems/abc-123/react \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"reactionType": "WAH_WAH"}'

# React to a couplet with SUBHAN_ALLAH
curl -X POST http://localhost:8081/api/couplets/def-456/react \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"reactionType": "SUBHAN_ALLAH"}'

# React to a poet image with FIRE
curl -X POST http://localhost:8081/api/poetry-images/ghi-789/react \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"reactionType": "FIRE"}'

# React to a generated image with BEAUTIFUL
curl -X POST http://localhost:8081/api/generated-images/jkl-012/react \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"reactionType": "BEAUTIFUL"}'
```

---

### 19.5 Remove Reaction

**Endpoint:** `DELETE /api/{targetType}/{publicId}/react`

**Authentication:** Required (Bearer token)

**Description:** Explicitly removes the user's reaction from a content item. This is an alternative to the toggle behavior in the POST endpoint.

**Path Parameters:** Same as Section 19.4.

**Response (200):**
```json
{
  "success": true,
  "message": "Reaction removed",
  "data": {
    "userReaction": null,
    "totalReactionCount": 142,
    "reactionCounts": null,
    "message": "Reaction removed"
  }
}
```

**Example:**
```bash
curl -X DELETE http://localhost:8081/api/poems/abc-123/react \
  -H "Authorization: Bearer <token>"
```

---

### 19.6 Reaction Data in Responses

All content DTOs now include a `reactions` field alongside the existing `likeCount`/`isLiked` fields.

#### 19.6.1 ReactionSummaryDto Reference

| Field | Type | Nullable | Description |
|---|---|---|---|
| `total` | Integer | No | Total number of reactions across all types |
| `byType` | Map<String, Integer> | Yes | Reaction counts grouped by type. `null` if no reactions |
| `userReaction` | String | Yes | Current user's reaction type. `null` if not reacted or not authenticated |

**Example:**
```json
{
  "total": 342,
  "byType": {
    "LOVE": 156,
    "WAH_WAH": 89,
    "FIRE": 45,
    "SUBHAN_ALLAH": 22,
    "MAZA_AA_GAYA": 15,
    "SAD": 10,
    "DEEP": 5
  },
  "userReaction": "WAH_WAH"
}
```

**When no reactions exist:**
```json
{
  "total": 0,
  "byType": null,
  "userReaction": null
}
```

#### 19.6.2 Poems

Both `PoemDetailResponse` and `PoemSummaryResponse` now include the `reactions` field:

```json
{
  "publicId": "abc-123",
  "title": "غزل",
  "poetName": "مرزا غالب",
  "viewCount": 1250,
  "likeCount": 342,
  "commentCount": 15,
  "shareCount": 28,
  "reactions": {
    "total": 342,
    "byType": {
      "LOVE": 156,
      "WAH_WAH": 89,
      "FIRE": 45,
      "SUBHAN_ALLAH": 22,
      "KYA_BAAT_HAI": 15,
      "BEAUTIFUL": 10,
      "DEEP": 5
    },
    "userReaction": "WAH_WAH"
  },
  "isLikedByCurrentUser": true,
  "isBookmarkedByCurrentUser": false,
  "contents": [...]
}
```

> **Note:** `likeCount` now equals `totalReactionCount` (not just LOVE count). `isLikedByCurrentUser` is `true` if the user has ANY reaction (not just LOVE).

#### 19.6.3 Couplets

Both `CoupletDto` and `CoupletDetailResponse` include the `reactions` field:

```json
{
  "publicId": "def-456",
  "coupletNumber": 1,
  "coupletType": "MATLA",
  "verses": [
    {"verseText": "دل ہی تو ہے نہ سنگ و خشت درد سے بھر نہ آئے کیوں"},
    {"verseText": "روئیں گے ہم ہزار بار کوئی ہمیں ستائے کیوں"}
  ],
  "likeCount": 89,
  "bookmarkCount": 34,
  "shareCount": 12,
  "reactions": {
    "total": 89,
    "byType": {
      "LOVE": 45,
      "WAH_WAH": 22,
      "DEEP": 12,
      "SAD": 10
    },
    "userReaction": "DEEP"
  },
  "isLiked": true,
  "isBookmarked": false
}
```

#### 19.6.4 Poet Images

`PoetImageDto` and the status endpoint both include reactions:

```json
{
  "publicId": "ghi-789",
  "imageUrl": "https://cdn.example.com/images/ghalib-1.jpg",
  "contentText": "دل ہی تو ہے نہ سنگ و خشت",
  "likeCount": 56,
  "bookmarkCount": 18,
  "shareCount": 7,
  "reactions": {
    "total": 56,
    "byType": {
      "LOVE": 30,
      "BEAUTIFUL": 15,
      "WAH_WAH": 11
    },
    "userReaction": null
  },
  "isLiked": false,
  "isBookmarked": true
}
```

#### 19.6.5 Feed Items

Feed items include reactions in the `contentData` map:

```json
{
  "type": "COUPLET",
  "publicId": "def-456",
  "reason": "TRENDING",
  "contentData": {
    "verses": [...],
    "poetName": "مرزا غالب",
    "poetPublicId": "poet-123",
    "likeCount": 89,
    "shareCount": 12,
    "bookmarkCount": 34,
    "reactions": {
      "total": 89,
      "byType": {
        "LOVE": 45,
        "WAH_WAH": 22,
        "DEEP": 12,
        "SAD": 10
      }
    }
  },
  "socialContext": {
    "totalReactions": 89,
    "trendingLabel": "Popular"
  }
}
```

> **Note:** Feed item reactions now include `userReaction` for authenticated users. The feed batch-fetches user reactions efficiently (one query per content type). For anonymous users, `userReaction` will be absent from the response.

---

### 19.7 Backward Compatibility

The old like endpoints continue to work and internally send a `LOVE` reaction:

| Old Endpoint | Still Works? | Internal Behavior |
|---|---|---|
| `POST /api/poems/{id}/like` | Yes | Calls `react(LOVE)` — toggles LOVE reaction |
| `POST /api/couplets/{id}/like` | Yes | Calls `react(LOVE)` — toggles LOVE reaction |
| `POST /api/poetry-images/{id}/like` | Yes | Calls `react(LOVE)` — toggles LOVE reaction |
| `GET /api/poems/{id}/status` | Yes | `liked: true` if user has ANY reaction |

**DTO backward compatibility:**

| Old Field | Still Present? | New Meaning |
|---|---|---|
| `likeCount` | Yes | Now equals `totalReactionCount` (all reaction types) |
| `isLiked` / `isLikedByCurrentUser` | Yes | `true` if user has ANY reaction (not just LOVE) |
| `reactions` | New field | Full breakdown with `total`, `byType`, `userReaction` |

**Migration timeline:**
- **Phase 1 (current):** Both old and new APIs work. Existing Flutter code is unaffected.
- **Phase 2 (future):** Old `/like` endpoints will be deprecated. `likeCount` and `isLiked` fields will be removed from DTOs.

---

### 19.8 Flutter Implementation Guide

#### 19.8.1 Reaction Picker Widget

```dart
/// Model class for reaction types (from GET /api/reactions/types)
class ReactionType {
  final String key;
  final String emoji;
  final String urduLabel;
  final String englishLabel;

  const ReactionType({
    required this.key,
    required this.emoji,
    required this.urduLabel,
    required this.englishLabel,
  });

  factory ReactionType.fromJson(Map<String, dynamic> json) => ReactionType(
    key: json['key'],
    emoji: json['emoji'],
    urduLabel: json['urduLabel'],
    englishLabel: json['englishLabel'],
  );
}

/// Reaction picker — shows on long-press of the reaction button
class ReactionPicker extends StatelessWidget {
  final List<ReactionType> reactionTypes;
  final String? currentReaction;
  final ValueChanged<String> onReactionSelected;

  const ReactionPicker({
    super.key,
    required this.reactionTypes,
    this.currentReaction,
    required this.onReactionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: reactionTypes.map((type) {
          final isSelected = currentReaction == type.key;
          return GestureDetector(
            onTap: () => onReactionSelected(type.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).primaryColor.withOpacity(0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    type.emoji,
                    style: TextStyle(fontSize: isSelected ? 32 : 24),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.urduLabel,  // or type.englishLabel based on app locale
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
```

**Usage — Long-press to show picker, tap to quick-react:**
```dart
class ReactionButton extends StatefulWidget {
  final String targetType;  // "poems", "couplets", etc.
  final String publicId;
  final String? currentReaction;
  final int totalReactions;
  final Map<String, int>? reactionsByType;

  const ReactionButton({
    super.key,
    required this.targetType,
    required this.publicId,
    this.currentReaction,
    this.totalReactions = 0,
    this.reactionsByType,
  });

  @override
  State<ReactionButton> createState() => _ReactionButtonState();
}

class _ReactionButtonState extends State<ReactionButton> {
  String? _currentReaction;
  int _totalReactions = 0;
  OverlayEntry? _pickerOverlay;

  @override
  void initState() {
    super.initState();
    _currentReaction = widget.currentReaction;
    _totalReactions = widget.totalReactions;
  }

  Future<void> _react(String reactionType) async {
    _pickerOverlay?.remove();
    _pickerOverlay = null;

    // Optimistic UI update
    setState(() {
      if (_currentReaction == reactionType) {
        // Toggle off
        _currentReaction = null;
        _totalReactions--;
      } else {
        if (_currentReaction == null) _totalReactions++;
        _currentReaction = reactionType;
      }
    });

    try {
      final response = await dio.post(
        '/api/${widget.targetType}/${widget.publicId}/react',
        data: {'reactionType': reactionType},
      );
      final data = response.data['data'];
      setState(() {
        _currentReaction = data['userReaction'];
        _totalReactions = data['totalReactionCount'];
      });
    } catch (e) {
      // Revert optimistic update
      setState(() {
        _currentReaction = widget.currentReaction;
        _totalReactions = widget.totalReactions;
      });
    }
  }

  void _showPicker(BuildContext context) {
    // Show the reaction picker overlay near this button
    final renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    _pickerOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: offset.dx - 20,
        top: offset.dy - 80,
        child: ReactionPicker(
          reactionTypes: ReactionTypesCache.types,  // cached from API
          currentReaction: _currentReaction,
          onReactionSelected: _react,
        ),
      ),
    );
    Overlay.of(context).insert(_pickerOverlay!);
  }

  @override
  Widget build(BuildContext context) {
    final emoji = _currentReaction != null
        ? ReactionTypesCache.emojiFor(_currentReaction!)
        : '❤️';

    return GestureDetector(
      onTap: () => _react(_currentReaction ?? 'LOVE'),  // Quick tap = toggle LOVE
      onLongPress: () => _showPicker(context),           // Long press = show picker
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 4),
          Text(
            _totalReactions > 0 ? '$_totalReactions' : '',
            style: TextStyle(
              color: _currentReaction != null
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 19.8.2 Reaction Summary Display

Display grouped reactions under content (like Facebook/LinkedIn):

```dart
/// Shows: ❤️👏🔥 342
class ReactionSummaryBar extends StatelessWidget {
  final int total;
  final Map<String, int>? byType;

  const ReactionSummaryBar({
    super.key,
    required this.total,
    this.byType,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    // Get top 3 reaction types by count
    final sorted = (byType?.entries.toList() ?? [])
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEmojis = sorted.take(3).map((e) {
      return ReactionTypesCache.emojiFor(e.key);
    }).toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Overlapping emoji badges
        SizedBox(
          width: topEmojis.length * 18.0,
          height: 24,
          child: Stack(
            children: [
              for (int i = 0; i < topEmojis.length; i++)
                Positioned(
                  left: i * 14.0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(topEmojis[i], style: const TextStyle(fontSize: 12)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _formatCount(total),
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
```

#### 19.8.3 API Service Integration

```dart
class ReactionService {
  final Dio _dio;

  ReactionService(this._dio);

  /// React to content. Returns updated reaction state.
  Future<ReactionResponse> react({
    required String targetType,  // "poems", "couplets", "poetry-images", "generated-images"
    required String publicId,
    required String reactionType,
  }) async {
    final response = await _dio.post(
      '/api/$targetType/$publicId/react',
      data: {'reactionType': reactionType},
    );
    return ReactionResponse.fromJson(response.data['data']);
  }

  /// Remove reaction from content.
  Future<ReactionResponse> removeReaction({
    required String targetType,
    required String publicId,
  }) async {
    final response = await _dio.delete(
      '/api/$targetType/$publicId/react',
    );
    return ReactionResponse.fromJson(response.data['data']);
  }

  /// Fetch available reaction types (cache this!)
  Future<List<ReactionType>> getReactionTypes() async {
    final response = await _dio.get('/api/reactions/types');
    return (response.data['data'] as List)
        .map((e) => ReactionType.fromJson(e))
        .toList();
  }
}

/// Response model
class ReactionResponse {
  final String? userReaction;
  final int totalReactionCount;
  final Map<String, int>? reactionCounts;
  final String message;

  ReactionResponse({
    this.userReaction,
    required this.totalReactionCount,
    this.reactionCounts,
    required this.message,
  });

  factory ReactionResponse.fromJson(Map<String, dynamic> json) {
    return ReactionResponse(
      userReaction: json['userReaction'],
      totalReactionCount: json['totalReactionCount'] ?? 0,
      reactionCounts: json['reactionCounts'] != null
          ? Map<String, int>.from(json['reactionCounts'])
          : null,
      message: json['message'] ?? '',
    );
  }
}

/// Reaction summary model (parsed from content DTOs)
class ReactionSummary {
  final int total;
  final Map<String, int>? byType;
  final String? userReaction;

  ReactionSummary({required this.total, this.byType, this.userReaction});

  factory ReactionSummary.fromJson(Map<String, dynamic>? json) {
    if (json == null) return ReactionSummary(total: 0);
    return ReactionSummary(
      total: json['total'] ?? 0,
      byType: json['byType'] != null
          ? Map<String, int>.from(json['byType'])
          : null,
      userReaction: json['userReaction'],
    );
  }

  bool get hasUserReacted => userReaction != null;
}
```

#### 19.8.4 Migration from Likes

**Step 1: Cache reaction types at app start**
```dart
// In your app initialization (e.g., main.dart or splash screen)
await ReactionTypesCache.initialize(reactionService);
```

**Step 2: Update your content models to parse the `reactions` field**
```dart
// Before (old like system):
class PoemModel {
  final int likeCount;
  final bool isLiked;
  // ...
}

// After (reactions system):
class PoemModel {
  final int likeCount;           // Still available (= total reactions)
  final bool isLiked;            // Still available (= has any reaction)
  final ReactionSummary? reactions;  // NEW: full breakdown
  // ...

  factory PoemModel.fromJson(Map<String, dynamic> json) {
    return PoemModel(
      likeCount: json['likeCount'] ?? 0,
      isLiked: json['isLikedByCurrentUser'] ?? false,
      reactions: json['reactions'] != null
          ? ReactionSummary.fromJson(json['reactions'])
          : null,
    );
  }
}
```

**Step 3: Replace like button with reaction button**
```dart
// Before:
IconButton(
  icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
  onPressed: () => toggleLike(poemId),
)

// After:
ReactionButton(
  targetType: 'poems',
  publicId: poem.publicId,
  currentReaction: poem.reactions?.userReaction,
  totalReactions: poem.reactions?.total ?? poem.likeCount,
  reactionsByType: poem.reactions?.byType,
)
```

**Step 4: Replace like count display with reaction summary**
```dart
// Before:
Text('${poem.likeCount} likes')

// After:
ReactionSummaryBar(
  total: poem.reactions?.total ?? poem.likeCount,
  byType: poem.reactions?.byType,
)
```

**Step 5: Update feed item parsing**
```dart
// Feed items have reactions in contentData:
final reactions = feedItem['contentData']['reactions'];
if (reactions != null) {
  final total = reactions['total'] as int;
  final byType = Map<String, int>.from(reactions['byType'] ?? {});
  // Use for display
}
```

---

**Reaction Types Cache Helper:**
```dart
class ReactionTypesCache {
  static List<ReactionType> types = [];

  static Future<void> initialize(ReactionService service) async {
    types = await service.getReactionTypes();
  }

  static String emojiFor(String key) {
    return types.firstWhere(
      (t) => t.key == key,
      orElse: () => const ReactionType(
        key: 'LOVE', emoji: '❤️', urduLabel: 'پسند', englishLabel: 'Love',
      ),
    ).emoji;
  }

  static String labelFor(String key, {bool urdu = true}) {
    final type = types.firstWhere(
      (t) => t.key == key,
      orElse: () => const ReactionType(
        key: 'LOVE', emoji: '❤️', urduLabel: 'پسند', englishLabel: 'Love',
      ),
    );
    return urdu ? type.urduLabel : type.englishLabel;
  }
}
```

---

## 20. User↔Poet Identity (Claim Your Profile) ⭐ NEW (April 2026) {#20-user-poet-identity}

### 20.1 Concept Overview

Sukhan now lets any signed-in user become a **publishing poet** without merging the User and Poet entities. Two flows are supported:

| Flow | When | Outcome |
|---|---|---|
| **Create own poet profile** | The user is a living poet, not yet on Sukhan | Auto-VERIFIED. New `Poet` row created. User immediately gains `ROLE_POET`. |
| **Claim existing poet** | The user is the same person as one of the historical scraped poets (rare — most are deceased) OR an heir/estate holder | Status becomes `PENDING`. Awaits admin review. On approval: VERIFIED + `ROLE_POET`. |

**Identity rules (locked):**
- **One poet per user.** A user can own at most one Poet at any time. A pending claim counts as ownership.
- **Most historical poets stay admin-managed** (`owner_user_id = NULL`) — Ghalib, Meer, Iqbal etc. are not claimable in practice; the pathway is reserved for legitimate identity matches.
- **Public attribution:** any future post/poem the user publishes will be attributed to the Poet persona, not the User account.

### 20.2 Claim Status Values

| Value | Meaning | UI |
|---|---|---|
| `UNCLAIMED` | Default for all scraped historical poets. No owner. | No ownership badge |
| `PENDING` | Claim submitted, awaiting admin review. | "Claim under review" banner + `claimedAt` relative time |
| `VERIFIED` | Admin approved (or auto-approved for self-created profiles). | "Verified Owner" badge |
| `REJECTED` | Admin rejected. User can resubmit with different proof. | "Claim rejected" banner + `claimRejectionReason` + "Resubmit" button |

**`claimStatus` vs `isVerified` — they are orthogonal:**

| | `isVerified = true` | `isVerified = false` |
|---|---|---|
| `claimStatus = UNCLAIMED` | Editorial blue-check (e.g. Ghalib — notable, no owner) | Plain historical poet |
| `claimStatus = VERIFIED` | Owner-verified AND editorially notable | Owner-verified, not yet curated |
| `claimStatus = PENDING` | Notable poet, ownership under review | Regular claim pending |
| `claimStatus = REJECTED` | Notable poet, rejected claim | Rejected claim |

**New fields on every `PoetProfileResponse`** (both `GET /api/me/poet-profile` and `GET /api/poets/{id}/profile`):

| Field | Type | Notes |
|---|---|---|
| `claimStatus` | string enum | Always present |
| `claimedAt` | ISO datetime \| `"-"` | Last claim action timestamp |
| `ownerUserId` | string \| `"-"` | `publicId` of owning User; `"-"` = unclaimed |
| `claimRejectionReason` | string \| `"-"` | Populated on `REJECTED`; cleared when re-approved |
| `claimReviewerNote` | string \| `"-"` | Optional note from admin on approve or reject |

> **`"-"` means null/not-set** throughout this API (global Jackson convention). Check with `value != "-"` in Dart.

### 20.3 Create My Own Poet Profile

**Endpoint:**
```
POST /api/me/poet-profile
Authorization: Bearer <user JWT>
Content-Type: application/json
```

**Request body:**
```json
{
  "primaryLanguageCode": "ur",
  "name": "Mansoor Ahmad",
  "penName": "Mansoor",
  "biography": "Karachi-based poet; ghazal and nazm.",
  "shortBio": "Ghazal poet from Karachi",
  "slug": "mansoor-ahmad"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `primaryLanguageCode` | string | ✅ | One of: `ur`, `en`, `hi`, `fa`, `ar`, `pa` |
| `name` | string (≤500) | ✅ | Display name in the primary language |
| `penName` | string (≤500) | ❌ | Takhallus / pen name |
| `biography` | string | ❌ | Full bio (long-form) |
| `shortBio` | string (≤500) | ❌ | One-line bio for cards |
| `slug` | string (≤100) | ❌ | URL slug. Auto-derived from `name` if omitted; collision-safe (hash suffix added) |

**Response 201:**
```json
{
  "success": true,
  "message": "Poet profile created",
  "data": {
    "publicId": "afe7a8da-2557-4eb6-9824-bd8238332a1b",
    "name": "Mansoor Ahmad",
    "shortBio": "Ghazal poet from Karachi",
    "era": "EMERGING",
    "primaryLanguageCode": "ur",
    "primaryLanguageName": "Urdu",
    "isVerified": false,
    "viewCount": 1,
    "followerCount": 0,
    "claimStatus": "VERIFIED",
    "claimedAt": "2026-05-01T14:22:00",
    "ownerUserId": "dd3903f6-935a-48ea-ab36-3a4c85960302",
    "claimRejectionReason": "-",
    "claimReviewerNote": "-"
  }
}
```

**Side effects on success:**
- New `Poet` row created with `claim_status = VERIFIED`, `owner_user_id = current user id`, `era = EMERGING`
- `ROLE_POET` granted to the user — they will need to **re-login** for the new role to appear in their JWT
- The user is now visible as a poet on the platform (search, discover, etc.)

**Error responses:**
| HTTP | When | `message` |
|---|---|---|
| 400 | Missing required fields, language code unknown | Validation error per Spring conventions |
| 409 | User already owns a poet profile | `"User already owns a poet profile: {publicId}"` |

### 20.4 Get My Poet Profile

**Endpoint:**
```
GET /api/me/poet-profile?lang=ur
Authorization: Bearer <user JWT>
```

**Query params:**
| Field | Default | Description |
|---|---|---|
| `lang` | `ur` | Language code for localized fields (`ur`, `en`, `hi`) |

**Response 200:** same `PoetProfileResponse` shape as section 5.3 (Poet Profile Endpoints).

**Response 404:** user has not created/claimed a poet yet.
```json
{ "success": false, "message": "You have not created a poet profile yet" }
```

### 20.5 Claim an Existing Poet

**Endpoint:**
```
POST /api/poets/{publicId}/claim
Authorization: Bearer <user JWT>
Content-Type: application/json
```

`{publicId}` = the poet's publicId (e.g. obtained from search or poet listing).

**Request body:**
```json
{
  "proofUrl": "https://twitter.com/handle/status/1234567890"
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `proofUrl` | string (≤500) | ✅ | Public URL proving identity — verified social handle, video selfie link, identity document hosted on a private link, etc. |

**Response 200:**
```json
{
  "success": true,
  "message": "Claim submitted; pending admin review",
  "data": {
    "publicId": "910b91e2-f5b4-48e0-b047-325b4147b2f2",
    "claimStatus": "PENDING",
    "claimedAt": "2026-04-28T00:50:19.762399"
  }
}
```

**Error responses:**
| HTTP | When | `message` |
|---|---|---|
| 404 | Poet `{publicId}` not found | `"Poet not found: {publicId}"` |
| 409 | User already owns/claimed a poet | `"User already owns a poet profile; cannot claim another"` |
| 409 | Poet already claimed by someone else | `"Poet is already claimed"` |

### 20.6 Flutter Implementation Guide

#### Data model (Dart)

```dart
enum PoetClaimStatus { UNCLAIMED, PENDING, VERIFIED, REJECTED }

/// Helper — API returns "-" for null strings (global Jackson convention).
String? nullableStr(dynamic v) => (v == null || v == '-') ? null : v as String;

class PoetProfileOwnership {
  final PoetClaimStatus claimStatus;
  final DateTime? claimedAt;
  final String? ownerUserId;        // publicId of owning User
  final String? claimRejectionReason;
  final String? claimReviewerNote;
  final bool isVerified;            // editorial badge — independent of claimStatus

  factory PoetProfileOwnership.fromJson(Map<String, dynamic> j) =>
      PoetProfileOwnership(
        claimStatus: PoetClaimStatus.values.firstWhere(
            (e) => e.name == j['claimStatus'],
            orElse: () => PoetClaimStatus.UNCLAIMED),
        claimedAt: nullableStr(j['claimedAt']) != null
            ? DateTime.parse(j['claimedAt']) : null,
        ownerUserId:           nullableStr(j['ownerUserId']),
        claimRejectionReason:  nullableStr(j['claimRejectionReason']),
        claimReviewerNote:     nullableStr(j['claimReviewerNote']),
        isVerified: j['isVerified'] ?? false,
      );
}
```

#### Rendering claim state banners

```dart
Widget claimBanner(PoetProfileOwnership ownership, {required VoidCallback onResubmit}) {
  switch (ownership.claimStatus) {
    case PoetClaimStatus.PENDING:
      final ago = _relativeTime(ownership.claimedAt);
      return InfoBanner(
        icon: Icons.hourglass_top,
        color: Colors.orange,
        text: 'Claim under review · submitted $ago',
      );
    case PoetClaimStatus.REJECTED:
      return InfoBanner(
        icon: Icons.cancel_outlined,
        color: Colors.red,
        text: ownership.claimRejectionReason != null
            ? 'Claim rejected: ${ownership.claimRejectionReason}'
            : 'Claim rejected by admin',
        action: TextButton(onPressed: onResubmit, child: const Text('Resubmit')),
      );
    case PoetClaimStatus.VERIFIED:
      return const SizedBox.shrink(); // No banner for owner — show creator UI
    case PoetClaimStatus.UNCLAIMED:
    default:
      return const SizedBox.shrink();
  }
}
```

#### Verified owner badge vs editorial badge

```dart
// Editorial badge (isVerified) — shown on public poet pages
// e.g. Ghalib has isVerified=true, claimStatus=UNCLAIMED
if (poet.isVerified)
  const Icon(Icons.verified, color: Colors.blue, size: 16);

// Ownership badge — shown only when VERIFIED owner views their own page
if (poet.ownership.claimStatus == PoetClaimStatus.VERIFIED &&
    poet.ownership.ownerUserId == currentUser.publicId)
  const Icon(Icons.lock_person, color: Colors.green, size: 16);
```

#### Admin portal — approve/reject with optional notes

```
POST /api/admin/poet-claims/{publicId}/approve?reviewerNote=Verified+via+LinkedIn
POST /api/admin/poet-claims/{publicId}/reject?reason=No+sufficient+proof&reviewerNote=Needs+official+ID
```

`reason` (shown to the user in `claimRejectionReason`) and `reviewerNote` (internal, not shown to user) are both optional query params.

---

#### Original service stubs

```dart
class CreatePoetProfileRequest {
  final String primaryLanguageCode; // 'ur' | 'en' | 'hi' | ...
  final String name;
  final String? penName;
  final String? biography;
  final String? shortBio;
  final String? slug;
  // toJson() ...
}

class ClaimPoetRequest {
  final String proofUrl;
  Map<String, dynamic> toJson() => {'proofUrl': proofUrl};
}
```

#### Service stub

```dart
class IdentityApi {
  final Dio _dio;
  IdentityApi(this._dio);

  Future<PoetProfile> createMyPoetProfile(CreatePoetProfileRequest req) async {
    final r = await _dio.post('/api/me/poet-profile', data: req.toJson());
    return PoetProfile.fromJson(r.data['data']);
  }

  Future<PoetProfile?> getMyPoetProfile({String lang = 'ur'}) async {
    try {
      final r = await _dio.get('/api/me/poet-profile',
          queryParameters: {'lang': lang});
      return PoetProfile.fromJson(r.data['data']);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> claimPoet(String poetPublicId, String proofUrl) async {
    await _dio.post('/api/poets/$poetPublicId/claim',
        data: {'proofUrl': proofUrl});
  }
}
```

#### Suggested UX flows

**Onboarding "Are you a poet?" flow:**
1. After signup, ask: "Do you write poetry?" → if yes, show two options:
   - **"Create my poet page"** → form (name, penName, primary language, short bio) → `POST /api/me/poet-profile` → success screen with "Visit my poet page"
   - **"I'm an existing poet on Sukhan"** → search by name → user picks a Poet → proof-URL input → `POST /api/poets/{publicId}/claim` → "Submitted — we'll review within 48h"
2. After **VERIFIED** (poll `GET /api/me/poet-profile` or surface via push later), unlock "Publish a poem" UI.

**Profile screen — three states:**
- No owned poet → "Become a poet" CTA → flow above
- Poet `claimStatus = PENDING` → banner: "Your claim is pending review"
- Poet `claimStatus = VERIFIED` → standard poet-profile screen plus an "Edit my poet" button

**Don't forget to refresh the JWT** after a successful create or admin-approve event so the new `ROLE_POET` claim appears (the user must logout/login or call your refresh-token endpoint).

---

### 20.7 Edit My Poet Profile ⭐ NEW (PR #4)

**Endpoint:**
```
PUT /api/me/poet-profile?lang=ur
Authorization: Bearer <user JWT>
Content-Type: application/json
```

All fields are **optional** — only the fields you send are touched. `null` or omitted = leave unchanged.

**Request body:**
```json
{
  "name": "Mansoor Ahmad",
  "penName": "Mansoor",
  "biography": "Long-form bio...",
  "shortBio": "Ghazal poet from Karachi",
  "era": "CONTEMPORARY",
  "gender": "MALE",
  "birthYear": 1990,
  "deathYear": null,
  "birthDate": "1990-06-15",
  "deathDate": null
}
```

| Field | Type | Notes |
|---|---|---|
| `name` | string (≤500) | Localized — writes to `poet_details.name` for the poet's primary language |
| `penName` | string (≤500) | Localized |
| `biography` | string | Localized — long-form |
| `shortBio` | string (≤500) | Localized — one-line for cards |
| `era` | enum | `CLASSICAL` / `MODERN` / `CONTEMPORARY` / `EMERGING` |
| `gender` | enum | `MALE` / `FEMALE` / `OTHER` |
| `birthYear`, `deathYear` | int | Year only |
| `birthDate`, `deathDate` | ISO date | Optional precision |

**Response 200:** full `PoetProfileResponse` (same shape as `GET /api/me/poet-profile`) with all updated values applied. Returns the **localized** version for the `lang` query param (defaults to `ur`).

**Errors:**
| HTTP | When |
|---|---|
| 400 | Validation error (e.g. `shortBio > 500`) |
| 404 | User does not own a poet profile |

---

### 20.8 My Image Gallery — CRUD ⭐ NEW (PR #4)

All endpoints below resolve the caller's poet from `user.ownedPoet` — **no `{publicId}` in the path**. Cross-user attempts (touching an image owned by a different poet) return `403 Forbidden`.

#### 20.8.1 List My Images

```
GET /api/me/poet/images?type=PROFILE
Authorization: Bearer <user JWT>
```

Optional `type` filter: `PROFILE` / `BANNER` / `GALLERY` / `PORTRAIT` / `HISTORICAL` / `EVENT` / `POETRY` / `OTHER`. Soft-deleted images are excluded.

**Response 200:**
```json
{
  "success": true,
  "message": "Images retrieved",
  "data": [
    {
      "publicId": "909c4912-45f6-4720-a945-ccc253080248",
      "imageUrl": "https://d20k90pcdbo704.cloudfront.net/poets/mansoor/profile/profile-xyz.jpg",
      "thumbnailUrl": "https://d20k90pcdbo704.cloudfront.net/...",
      "caption": "Studio portrait",
      "altText": "Mansoor",
      "displayOrder": 1,
      "isProfileImage": true,
      "imageType": "PROFILE",
      "likeCount": 0,
      "bookmarkCount": 0,
      "shareCount": 0
    }
  ]
}
```

#### 20.8.2 Add Image by URL

Use this when the image is already hosted somewhere (you only need to register it).

```
POST /api/me/poet/images
Authorization: Bearer <user JWT>
Content-Type: application/json
```

```json
{
  "imageUrl": "https://example.com/portrait.jpg",
  "thumbnailUrl": "https://example.com/portrait_thumb.jpg",
  "caption": "Studio portrait",
  "altText": "Mansoor in studio",
  "imageType": "PROFILE",
  "isProfileImage": true,
  "displayOrder": 1
}
```

**Response 201:** `PoetImageDto` (same shape as 20.8.1 entries). Setting `isProfileImage: true` automatically demotes any prior PROFILE on the same poet to `false`.

#### 20.8.3 Upload Image File (multipart)

Pushes the file to S3, generates a thumbnail for `PROFILE`/`GALLERY`, and creates the `poet_images` row.

```
POST /api/me/poet/images/upload
Authorization: Bearer <user JWT>
Content-Type: multipart/form-data
```

**Form fields:**
| Field | Type | Required | Notes |
|---|---|---|---|
| `file` | file | ✅ | JPEG/PNG/WebP only |
| `imageType` | enum | optional (default `GALLERY`) | See list above |
| `isProfileImage` | bool | optional (default false) | If true, demotes prior PROFILE |
| `caption`, `altText` | string | optional | |
| `displayOrder` | int | optional | |
| `contentText`, `tagSlugs[]`, `categoryId`, `languageCode` | misc | optional | For poetry-overlay images |

**Response 201:** `PoetImageDto` with the resolved CloudFront URLs.

```dart
// Dart upload example
Future<PoetImageDto> uploadMyImage(File file, {required ImageType type, bool profile = false}) async {
  final form = FormData.fromMap({
    'file': await MultipartFile.fromFile(file.path),
    'imageType': type.name,
    'isProfileImage': profile,
  });
  final r = await _dio.post('/api/me/poet/images/upload', data: form);
  return PoetImageDto.fromJson(r.data['data']);
}
```

#### 20.8.4 Update Image Metadata

```
PUT /api/me/poet/images/{publicId}
Authorization: Bearer <user JWT>
Content-Type: application/json
```

All fields optional; `null`/omitted = leave unchanged.

```json
{
  "caption": "Updated caption",
  "altText": "Updated alt",
  "displayOrder": 2,
  "imageType": "PROFILE",
  "isProfileImage": true
}
```

**Response 200:** updated `PoetImageDto`.

**Errors:**
| HTTP | When |
|---|---|
| 404 | Image not found, OR caller does not own a poet |
| 403 | Image belongs to a different poet (cross-user attempt) |

#### 20.8.5 Delete Image

```
DELETE /api/me/poet/images/{publicId}
Authorization: Bearer <user JWT>
```

Soft-delete only — sets `is_deleted=true` so the image disappears from gallery responses. Same 404/403 errors as update.

---

### 20.9 Suggested Profile-Edit UX

```
Profile screen
├── [Edit profile] → form with fields:
│   ├── Name (localized, primary lang)
│   ├── Pen name
│   ├── Short bio (1-line, max 500)
│   ├── Biography (long-form)
│   ├── Era (dropdown)
│   ├── Gender (dropdown)
│   └── Birth year / date
│   → PUT /api/me/poet-profile  (only changed fields in body)
│
├── [Manage images] → gallery grid:
│   ├── (per image) [Edit caption] [Set as profile] [Delete]
│   │   → PUT or DELETE /api/me/poet/images/{publicId}
│   └── [+ Add image]:
│       ├── [Pick from gallery]  → upload via /upload (multipart)
│       └── [Paste URL]          → POST /api/me/poet/images
```

**Profile-image promotion behavior**: setting `isProfileImage: true` on any image automatically clears the flag on the previous one — UI doesn't need to do this manually.

---

### 20.10 Compose & Manage My Poems ⭐ NEW (PR #5)

All poem endpoints below are scoped to `user.ownedPoet`. No `poetId` in the body — it's inferred server-side.

#### 20.10.1 List My Poems

```
GET /api/me/poet/poems?page=0&size=20&sortBy=date
Authorization: Bearer <token>
```

| `sortBy` | Description |
|---|---|
| `date` (default) | Newest first |
| `likes` | Most liked first |
| `views` | Most viewed first |

Includes **both public and private** poems (unlike the public `/api/poets/{id}/poems` which hides private ones). Returns paginated `PoemSummaryResponse` with `viewCount`, `likeCount`, `commentCount`, `shareCount`, `isPublic`.

**`firstMisra` (string, nullable)** — first non-empty line of the primary-language content body, trimmed and truncated to 80 chars. Provided as a fallback display title for poems whose `title` is missing or a literal `"-"` (common for scraped Ghazals where the source had no title). Client logic:

```dart
String resolveTitle(PoemSummaryResponse p) {
  final t = p.title?.trim();
  if (t != null && t.isNotEmpty && t != '-') return t;
  if (p.firstMisra != null && p.firstMisra!.isNotEmpty) return p.firstMisra!;
  return 'بے عنوان · ${p.poetryTypeName}';
}
```

`firstMisra` is `null` only when the poem has no original content row (rare/defensive). Excluded soft-deleted poems do not appear in this list.

**Count semantics:** `totalElements` from this endpoint equals `poemCount` from `GET /api/me/poet-profile` — both count poems that are not soft-deleted (public + private + drafts). The hero card and list header will not disagree.

#### 20.10.2 Compose a Poem

```
POST /api/me/poet/poems
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
  "title": "میری پہلی غزل",
  "content": "دل کی بات کہنا ہے\nیہی میرا ارادہ ہے",
  "poetryType": "GHAZAL",
  "languageCode": "ur",
  "script": "ARABIC",
  "categoryId": "optional-category-public-id",
  "tagSlugs": ["ghazal", "ishq"],
  "yearWritten": 2026,
  "isPublic": true
}
```

| Field | Type | Required | Notes |
|---|---|---|---|
| `title` | string | ✅ | |
| `content` | string | ✅ | Full text in the specified script |
| `poetryType` | enum | ✅ | `GHAZAL`, `NAZAM`, `AZAD_NAZAM`, `RUBAI`, `QASIDA`, `MARSIYA`, `NAAT`, `HAMD`, `QATTA`, `VERSE`, `MASNAVI`, etc. |
| `languageCode` | string | default `ur` | `ur`, `en`, `hi`, `fa`, `ar`, `pa` |
| `script` | enum | default `ARABIC` | `ARABIC`, `ROMAN`, `DEVANAGARI`, `LATIN` |
| `isPublic` | bool | default `true` | `false` = draft mode (visible only to poet) |

**Response 201:** full `PoemDetailResponse`. Side effects:
- If Urdu Arabic script: Roman + Devanagari transliterations are auto-generated async
- If `GHAZAL` or other structured type: verse/couplet parsing runs automatically
- Poem is indexed to Elasticsearch immediately

**Error responses:**
| HTTP | When |
|---|---|
| 404 | User does not own a poet profile |
| 409 | Duplicate poem (same title + poet + language + script) |

#### 20.10.3 Edit My Poem

```
PUT /api/me/poet/poems/{publicId}
Authorization: Bearer <token>
Content-Type: application/json
```

All fields optional. `poetId` is ignored if supplied (ownership is fixed).

```json
{
  "isPublic": false,
  "yearWritten": 2025,
  "poetryType": "NAZAM",
  "tagSlugs": ["nazm", "watan"]
}
```

**Response 200:** updated `PoemDetailResponse`. **Response 403:** poem belongs to a different poet.

#### 20.10.4 Delete My Poem

```
DELETE /api/me/poet/poems/{publicId}
Authorization: Bearer <token>
```

Soft-delete only. Removes from Elasticsearch. **Response 200 / 403 / 404**.

#### 20.10.5 Security Note

`POST /api/poems/add-poem` (the older bulk-upload endpoint) now also validates ownership: if the target poet has `claimStatus = VERIFIED` and is owned by a different user, non-admin callers receive `403 Forbidden`. Admins (`MANAGE_POEMS` permission) are exempt.

---

### 20.11 Facts Management ⭐ NEW (PR #6)

```
GET    /api/me/poet/facts
POST   /api/me/poet/facts
DELETE /api/me/poet/facts/{publicId}
```
All require `Authorization: Bearer <token>`.

**GET** — returns list of `PoetFactDto` (all languages):
```json
[
  {
    "publicId": "abc123",
    "fact": "یہ ایک مشہور شاعر ہیں",
    "languageCode": "ur",
    "languageName": "Urdu",
    "displayOrder": 1,
    "factGroupId": "uuid-linking-translations"
  }
]
```

**POST body:**
```json
{
  "fact": "یہ ایک حقیقت ہے",
  "languageCode": "ur",
  "displayOrder": 1
}
```
**Response 201** on success.

**DELETE** — soft-delete by `publicId`. **403** if fact belongs to another poet.

---

### 20.12 Multi-Language Profile Translations ⭐ NEW (PR #7)

Lets a poet manage localized bios in multiple languages independently of their primary language profile.

#### 20.12.1 List Translations

```
GET /api/me/poet/translations
Authorization: Bearer <token>
```

```json
{
  "data": [
    {
      "languageCode": "ur",
      "languageName": "Urdu",
      "name": "منصور احمد",
      "penName": "منصور",
      "hasShortBio": false,
      "hasBiography": false,
      "isPrimary": true
    },
    {
      "languageCode": "en",
      "languageName": "English",
      "name": "Mansoor Ahmad",
      "penName": null,
      "hasShortBio": true,
      "hasBiography": false,
      "isPrimary": false
    }
  ]
}
```

Use `hasBiography: false` to show "Add English bio →" prompts in Flutter UI.

#### 20.12.2 Add a New Language Translation

```
POST /api/me/poet/translations
Authorization: Bearer <token>
Content-Type: application/json
```

```json
{
  "languageCode": "en",
  "name": "Mansoor Ahmad",
  "penName": "Mansoor",
  "shortBio": "Urdu poet from Karachi",
  "biography": "Long-form English biography..."
}
```

**Response 201** on success. **409** if translation for that language already exists — use PUT to update.

#### 20.12.3 Update Existing Translation

```
PUT /api/me/poet/translations/{langCode}
Authorization: Bearer <token>
Content-Type: application/json
```

All fields optional (null = leave unchanged). `langCode` path param: `ur`, `en`, `hi`, `fa`, etc.

```json
{
  "shortBio": "Updated one-liner",
  "biography": "Updated long bio"
}
```

**Response 200** / **404** if that language hasn't been added yet (use POST first).

#### 20.12.4 Multi-Language Update Semantics

| What you update | Where it goes |
|---|---|
| `PUT /api/me/poet-profile` fields (name, bio) | **Primary language only** |
| `PUT /api/me/poet/translations/en` | English translation only |
| `era`, `gender`, `birthYear` | All languages (stored on `poets` table) |

---

### 20.13 Books Self-Serve Upload ⭐ NEW (PR #8)

```
GET    /api/me/poet/books
POST   /api/me/poet/books                         (multipart or JSON)
PUT    /api/me/poet/books/{publicId}
DELETE /api/me/poet/books/{publicId}
POST   /api/me/poet/books/{publicId}/upload-pdf   (multipart)
POST   /api/me/poet/books/{publicId}/upload-epub  (multipart)
POST   /api/me/poet/books/{publicId}/upload-cover (multipart)
```

#### 20.13.1 Create a Book

Send as multipart form-data (supports optional simultaneous file upload):

```
POST /api/me/poet/books
Authorization: Bearer <token>
Content-Type: multipart/form-data

title          = "Kulliyat e Mansoor"        (required)
yearPublished  = 2026
description    = "My first diwan"
publisher      = "Sukhan Press"
languageCode   = ur
file           = <pdf binary>               (optional)
fileType       = PDF                        (required if file present: PDF | EPUB)
```

**Response 201:**
```json
{
  "success": true,
  "message": "Book created with file",
  "data": {
    "bookTitle": "Kulliyat e Mansoor",
    "hasPdf": true,
    "hasEpub": false,
    "isDownloadable": true,
    "pdfUrl": "https://d20k90pcdbo704.cloudfront.net/books/..."
  }
}
```

#### 20.13.2 Upload Files to Existing Book

```dart
// Upload PDF
final form = FormData.fromMap({
  'file': await MultipartFile.fromFile(pdfPath, contentType: MediaType.parse('application/pdf')),
});
await _dio.post('/api/me/poet/books/$bookPublicId/upload-pdf', data: form);

// Upload cover image
final form = FormData.fromMap({
  'file': await MultipartFile.fromFile(imagePath),
});
await _dio.post('/api/me/poet/books/$bookPublicId/upload-cover', data: form);
```

All file upload endpoints return `BookFileUploadResponse` with `pdfUrl`, `epubUrl`, `hasPdf`, `hasEpub`, `isDownloadable`. **403** if book belongs to different poet.

---

### 20.14 Creator Analytics Dashboard ⭐ NEW (PR #9)

Single endpoint — returns all key metrics for a creator's dashboard in one call.

```
GET /api/me/poet/analytics
Authorization: Bearer <token>
```

**Response 200:**
```json
{
  "success": true,
  "data": {
    "followerCount": 142,
    "profileViews": 3891,
    "poemCount": 47,
    "totalPoemViews": 28450,
    "totalPoemLikes": 1203,
    "totalPoemBookmarks": 876,
    "totalImageLikes": 234,
    "topPoems": [
      {
        "publicId": "abc123",
        "title": "دل کی بات",
        "poetryType": "GHAZAL",
        "viewCount": 1840,
        "likeCount": 312,
        "shareCount": 45,
        "createdAt": "2026-04-01T10:30:00"
      }
    ]
  }
}
```

**`topPoems`** — up to 5 poems sorted by `likeCount` descending. Full `PoemSummaryResponse` shape.

**Response 404** if user has no owned poet profile.

```dart
class PoetAnalytics {
  final int followerCount;
  final int profileViews;
  final int poemCount;
  final int totalPoemViews;
  final int totalPoemLikes;
  final int totalPoemBookmarks;
  final int totalImageLikes;
  final List<PoemSummary> topPoems;

  factory PoetAnalytics.fromJson(Map<String, dynamic> j) => PoetAnalytics(
    followerCount:       j['followerCount']       ?? 0,
    profileViews:        j['profileViews']        ?? 0,
    poemCount:           j['poemCount']           ?? 0,
    totalPoemViews:      j['totalPoemViews']      ?? 0,
    totalPoemLikes:      j['totalPoemLikes']      ?? 0,
    totalPoemBookmarks:  j['totalPoemBookmarks']  ?? 0,
    totalImageLikes:     j['totalImageLikes']     ?? 0,
    topPoems:            (j['topPoems'] as List? ?? [])
                           .map((p) => PoemSummary.fromJson(p)).toList(),
  );
}
```

---

### 20.15 Complete Creator Workflow Summary

```
User becomes a poet (§20.3 or §20.5 + admin approve)
    ↓
Edit profile (§20.7) + add translations (§20.12)
    ↓
Upload gallery images (§20.8)
    ↓
Compose poems (§20.10.2) — auto-transliterated, instant publish
    ↓
Add facts (§20.11) + upload books with PDF/EPUB (§20.13)
    ↓
Check analytics dashboard (§20.14)

All writes: 401 if unauthenticated, 404 if no owned poet, 403 if resource belongs to another poet.
```

---

## 21. Guest Browsing API (Anonymous) {#21-guest-browsing-api-anonymous}

Read-only endpoints for unauthenticated users. Required for **App Store
guideline 5.1.1(v)** — apps may not force users to register before browsing
non-account features.

Base Path: `/api/guest`
Authentication: **None** (no `Authorization` header)
Methods: **GET only** (any other method returns 403)

---

### 21.1 Why It Exists & What's Different {#211-why-it-exists--whats-different}

Rather than open the existing `/api/poems`, `/api/poets`, etc. to anonymous
callers, we ship a separate `/api/guest/**` surface. This is intentional —
the existing endpoints serve **personalized** responses (your bookmarks,
your reactions, your "for you" ranking) and writing engagement events to
your user id. None of that is appropriate for anonymous traffic.

| Aspect | `/api/guest/**` (anonymous) | `/api/poems` etc. (authenticated) |
|---|---|---|
| Auth header | Not required | JWT required |
| `isLiked` / `isBookmarked` | **Stripped from response** | Included |
| `reactions.userReaction` | **Stripped from response** | Included |
| Personalization ("for you") | None | Yes |
| Engagement tracking writes | None | Yes |
| Pagination | **Hard-capped** (5 pages × 20) | Unlimited |
| Rate limiting | **Tight** (60/min, 1000/hour per IP) | Per-user |
| Caching | **Aggressive** (Redis, 5–15 min) | Lighter |
| Response shape | Slim `Guest*Dto` types | Full `*Response` types |
| Write actions | All return 403 | Allowed |

**Use guest endpoints for:** browse-before-register experience, public landing
pages, share-link previews, screenshots for the App Store.

**Don't use guest endpoints for:** anything an authenticated user does. Once
the user signs in, switch to the authenticated endpoints to get
personalization back.

---

### 21.2 Endpoint Summary {#212-endpoint-summary}

| Method | Path | Purpose |
|---|---|---|
| GET | `/api/guest/discover` | Single-call bundle: featured poems + featured/trending poets + trending couplets |
| GET | `/api/guest/poems` | Paginated poem list, filterable by `poetryType` |
| GET | `/api/guest/poems/{publicId}` | Full poem detail, includes couplets for ghazals |
| GET | `/api/guest/poems/search?q=...` | Elasticsearch-backed poem search |
| GET | `/api/guest/poets` | Paginated poet directory |
| GET | `/api/guest/poets/{publicId}` | Single poet card |
| GET | `/api/guest/poets/search?q=...` | Elasticsearch-backed poet search |
| GET | `/api/guest/couplets/trending` | Trending couplets within a window (default 7 days) |

---

### 21.3 Pagination Caps, Rate Limits, Caching {#213-pagination-caps-rate-limits-caching}

**Pagination caps (hard, server-side):**
- `page` clamped to `[0, 4]` → max 5 pages
- `size` clamped to `[1, 20]` → max 20 items per page
- Net effect: at most **100 distinct items** returned per (filter, sort) combo
- Out-of-range values are silently clamped, not rejected — endpoint still
  returns 200, just with the clamped slice

**Rate limit (per IP):**
- **60 requests per minute** — burst protection
- **1000 requests per hour** — sustained-scrape protection
- Implementation: Bucket4j, in-memory per app container, `X-Forwarded-For`-aware behind nginx
- On exceed: HTTP **429 Too Many Requests**
  - `Retry-After: <seconds>` header — number of whole seconds until at least one token frees up
  - `X-RateLimit-Remaining: 0` header
  - Body: `{"success":false,"message":"Too many requests. Please slow down."}`
- On every successful response: `X-RateLimit-Remaining: <n>` header — tokens left in the per-minute window

**Caching (Redis-backed):**
- `/api/guest/discover` cached **15 min per `lang`** — same payload returned to all anonymous users in the window
- `/api/guest/couplets/trending` cached **5 min per (days, page, size)** — distinct calls don't stomp on each other but identical scraper sweeps hit cache
- `/api/guest/poems`, `/poets`, `/search` — not cached (Elasticsearch handles list queries efficiently). Subject to change.

**Flutter handling for 429:**
```dart
if (response.statusCode == 429) {
  final retryAfter = int.tryParse(response.headers['retry-after'] ?? '60') ?? 60;
  // Show a non-intrusive toast, NOT a modal
  showSnackBar('Too many requests, retry in ${retryAfter}s');
  // Optionally: schedule an automatic retry after retryAfter seconds
  return;
}
```

---

### 21.4 GET /api/guest/discover {#214-get-apiguestdiscover}

Single-call bundle for the unauthenticated landing screen. Combines featured
poems, featured/trending poets, and trending couplets so you don't make 4
separate requests.

**Query Parameters:**
- `lang` *(optional, default `ur`)* — one of `ur` / `en` / `hi`. Invalid values silently fall back to `ur`.

**Example:**
```bash
curl 'http://localhost:8081/api/guest/discover?lang=ur'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Guest discover bundle retrieved",
  "data": {
    "featuredPoems": [
      {
        "publicId": "pm_abc123",
        "title": "غزل",
        "excerpt": "دل ہی تو ہے نہ سنگ و خشت...",
        "poetPublicId": "pt_ghalib",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://cdn.../ghalib.jpg",
        "poetryType": "GHAZAL",
        "poetryTypeName": "غزل",
        "contentType": "TEXT",
        "thumbnailUrl": "-",
        "viewCount": 12453,
        "likeCount": 234,
        "shareCount": 12,
        "createdAt": "2026-01-12T10:00:00"
      }
    ],
    "featuredPoets": [
      {
        "publicId": "pt_faiz",
        "name": "فیض احمد فیض",
        "shortBio": "...",
        "profileImageUrl": "https://cdn.../faiz.jpg",
        "birthYear": 1911,
        "deathYear": 1984,
        "era": "MODERN",
        "country": "Pakistan",
        "countryFlag": "🇵🇰",
        "poemCount": 198
      }
    ],
    "trendingPoets": [ /* same shape as featuredPoets */ ],
    "trendingCouplets": [
      {
        "publicId": "cp_xyz",
        "coupletNumber": 1,
        "coupletType": "MATLA",
        "coupletTypeName": "مطلع",
        "verses": [
          {"publicId": "v1", "verseNumber": 1, "verseText": "..."},
          {"publicId": "v2", "verseNumber": 2, "verseText": "..."}
        ],
        "poemPublicId": "pm_abc123",
        "poetPublicId": "pt_ghalib",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://cdn.../ghalib.jpg",
        "likeCount": 87,
        "shareCount": 4
      }
    ],
    "language": "ur",
    "timestamp": 1747340000000
  }
}
```

**Notes:**
- Each section returns up to **6 items**; no pagination on the bundle itself.
- Bundle is cached for 15 minutes per language — clients don't need to cache further.
- `timestamp` is server epoch millis at bundle build time; useful for cache-validation UI.

---

### 21.5 GET /api/guest/poems {#215-get-apiguestpoems}

Paginated list of public poems, sorted by `createdAt DESC` (newest first).

**Query Parameters:**
- `poetryType` *(optional)* — filter by enum: `GHAZAL`, `NAZAM`, `AZAD_NAZAM`, `RUBAI`, `QASIDA`, `MARSIYA`, `NAAT`, `HAMD`, `QATTA`, `VERSE`, `MASNAVI`, etc.
- `lang` *(optional, default `ur`)* — `ur` / `en` / `hi`
- `page` *(optional, default `0`)* — clamped to `[0, 4]`
- `size` *(optional, default `10`)* — clamped to `[1, 20]`

**Example:**
```bash
curl 'http://localhost:8081/api/guest/poems?poetryType=GHAZAL&lang=ur&page=0&size=20'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Poems retrieved",
  "data": {
    "content": [
      { "publicId": "...", "title": "...", "excerpt": "...", "poetPublicId": "...",
        "poetName": "...", "poetProfileImageUrl": "...", "poetryType": "GHAZAL",
        "poetryTypeName": "غزل", "contentType": "TEXT", "thumbnailUrl": "-",
        "viewCount": 0, "likeCount": 0, "shareCount": 0,
        "createdAt": "2026-04-01T00:00:00" }
    ],
    "pageable": { "pageNumber": 0, "pageSize": 20, "sort": {...} },
    "totalElements": 100,
    "totalPages": 5,
    "first": true,
    "last": false,
    "numberOfElements": 20
  }
}
```

**Notes:**
- `totalElements` may **understate** real catalog size because of caps —
  don't display it as "X total poems" to the user. Use it only for has-next pagination.
- No `isLikedByCurrentUser`, no `reactions.userReaction`, no `isBookmarkedByCurrentUser` — guest DTOs strip these.

---

### 21.6 GET /api/guest/poems/{publicId} {#216-get-apiguestpoemspublicid}

Full poem detail for a single poem. For ghazals (and other structured poetry
types), the `couplets` array is populated with parsed verses.

**Path Parameters:**
- `publicId` — poem public ID

**Query Parameters:**
- `lang` *(optional, default `ur`)* — `ur` / `en` / `hi`. Filters `contents[]` to only that language.

**Example:**
```bash
curl 'http://localhost:8081/api/guest/poems/pm_abc123?lang=ur'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Poem retrieved",
  "data": {
    "publicId": "pm_abc123",
    "poetPublicId": "pt_ghalib",
    "poetName": "مرزا غالب",
    "poetProfileImageUrl": "https://cdn.../ghalib.jpg",
    "poetryType": "GHAZAL",
    "poetryTypeName": "غزل",
    "requiresStructuredParsing": true,
    "contentType": "TEXT",
    "imageUrl": "-",
    "thumbnailUrl": "-",
    "yearWritten": 1851,
    "viewCount": 12454,
    "likeCount": 234,
    "shareCount": 12,
    "commentCount": 0,
    "tagSlugs": ["love", "classical"],
    "contents": [
      {
        "publicId": "pc_ur",
        "languageCode": "ur",
        "languageName": "Urdu",
        "languageNativeName": "اردو",
        "script": "ARABIC",
        "scriptDirection": "rtl",
        "title": "غزل",
        "fullText": "دل ہی تو ہے...",
        "isOriginal": true,
        "verses": [ /* ... */ ],
        "totalVerses": 14,
        "totalCouplets": 7
      }
    ],
    "couplets": [
      {
        "publicId": "cp_1",
        "coupletNumber": 1,
        "coupletType": "MATLA",
        "coupletTypeName": "مطلع",
        "verses": [{...}, {...}],
        "poemPublicId": "pm_abc123",
        "poetPublicId": "pt_ghalib",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://cdn.../ghalib.jpg",
        "likeCount": 87,
        "shareCount": 4
      }
    ],
    "createdAt": "2026-01-12T10:00:00"
  }
}
```

**Error Responses:**
- **404 Not Found** — `publicId` doesn't exist or poem is not public

**Side Effect:**
- `viewCount` is incremented on every successful read. Don't poll this endpoint to refresh state — call once per "open" gesture.

---

### 21.7 GET /api/guest/poems/search {#217-get-apiguestpoemssearch}

Elasticsearch-backed full-text search across poems.

**Query Parameters:**
- `q` *(required)* — search query. **Returns 400 if missing.**
- `lang` *(optional, default `ur`)* — `ur` / `en` / `hi`
- `page` *(optional, default `0`)* — clamped to `[0, 4]`
- `size` *(optional, default `10`)* — clamped to `[1, 20]`

**Example:**
```bash
curl 'http://localhost:8081/api/guest/poems/search?q=محبت&lang=ur'
```

**Response (200):** Same `Page<GuestPoemSummaryDto>` shape as §21.5.

---

### 21.8 GET /api/guest/poets {#218-get-apiguestpoets}

Paginated poet directory, sorted alphabetically by slug.

**Query Parameters:**
- `lang` *(optional, default `ur`)* — name returned in this language
- `page` *(optional, default `0`)* — clamped to `[0, 4]`
- `size` *(optional, default `10`)* — clamped to `[1, 20]`

**Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved",
  "data": {
    "content": [
      {
        "publicId": "pt_faiz",
        "name": "فیض احمد فیض",
        "shortBio": "...",
        "profileImageUrl": "https://cdn.../faiz.jpg",
        "birthYear": 1911,
        "deathYear": 1984,
        "era": "MODERN",
        "country": "Pakistan",
        "countryFlag": "🇵🇰",
        "poemCount": 198
      }
    ],
    "totalElements": 100,
    "totalPages": 5
  }
}
```

---

### 21.9 GET /api/guest/poets/{publicId} {#219-get-apiguestpoetspublicid}

Single poet card. Same shape as the items in §21.8.

**Query Parameters:**
- `lang` *(optional, default `ur`)*

**Error Responses:**
- **404 Not Found** — poet doesn't exist or has been deleted

---

### 21.10 GET /api/guest/poets/search {#2110-get-apiguestpoetssearch}

Elasticsearch-backed poet search.

**Query Parameters:**
- `q` *(required)* — search query
- `lang` *(optional, default `ur`)*
- `page`, `size` — clamped as above

**Response (200):** Same `Page<GuestPoetSummaryDto>` shape as §21.8.

---

### 21.11 GET /api/guest/couplets/trending {#2111-get-apiguestcoupletstrending}

Trending couplets within a recent window.

**Query Parameters:**
- `days` *(optional, default `7`)* — window in days, clamped to `[1, 30]`
- `page` *(optional, default `0`)* — clamped to `[0, 4]`
- `size` *(optional, default `10`)* — clamped to `[1, 20]`

**Example:**
```bash
curl 'http://localhost:8081/api/guest/couplets/trending?days=7&page=0&size=10'
```

**Response (200):**
```json
{
  "success": true,
  "message": "Trending couplets retrieved",
  "data": [
    {
      "publicId": "cp_xyz",
      "coupletNumber": 3,
      "coupletType": "REGULAR",
      "coupletTypeName": "شعر",
      "verses": [{...}, {...}],
      "poemPublicId": "pm_abc",
      "poetPublicId": "pt_faiz",
      "poetName": "فیض احمد فیض",
      "poetProfileImageUrl": "https://cdn.../faiz.jpg",
      "likeCount": 412,
      "shareCount": 28
    }
  ]
}
```

**Note:** This endpoint returns a flat `List<GuestCoupletDto>`, not a `Page<>`.
Pagination is via `page`/`size` query params; you don't get a `totalElements`
back. Treat the response as "the next page of trending" and stop when an
empty array comes back.

---

### 21.12 Response DTO Reference {#2112-response-dto-reference}

#### `GuestPoemSummaryDto`
| Field | Type | Notes |
|---|---|---|
| `publicId` | string | |
| `title` | string | In requested `lang` |
| `excerpt` | string | First few lines, in requested `lang` |
| `poetPublicId` | string | |
| `poetName` | string | In requested `lang` |
| `poetProfileImageUrl` | string | CDN URL or `null` |
| `poetryType` | enum | `GHAZAL`, `NAZAM`, etc. |
| `poetryTypeName` | string | Localized name in requested `lang` |
| `contentType` | string | `TEXT` or `IMAGE` |
| `thumbnailUrl` | string | For image-based poems, else `"-"` |
| `viewCount` | int | |
| `likeCount` | int | Total reactions across all types |
| `shareCount` | int | |
| `createdAt` | ISO8601 string | |

#### `GuestPoemDetailDto`
All `GuestPoemSummaryDto` fields **except** `title`/`excerpt`/`thumbnailUrl`,
**plus**:
| Field | Type | Notes |
|---|---|---|
| `requiresStructuredParsing` | bool | True for ghazals etc. |
| `imageUrl` | string | For image poems |
| `yearWritten` | int | `0` if unknown |
| `commentCount` | int | |
| `tagSlugs` | string[] | Hashtag slugs |
| `contents` | `PoemContentDto[]` | Multilingual content; filtered to requested `lang` |
| `couplets` | `GuestCoupletDto[]` | Empty for non-structured poetry |

#### `GuestPoetSummaryDto`
| Field | Type | Notes |
|---|---|---|
| `publicId` | string | |
| `name` | string | In requested `lang` |
| `shortBio` | string | In requested `lang` |
| `profileImageUrl` | string | CDN URL |
| `birthYear` / `deathYear` | int / int? | `null` for living poets |
| `era` | enum | `CLASSICAL`, `MODERN`, etc. |
| `country` | string | |
| `countryFlag` | string | Unicode emoji, e.g. `"🇵🇰"` |
| `poemCount` | int | |

#### `GuestCoupletDto`
| Field | Type | Notes |
|---|---|---|
| `publicId` | string | |
| `coupletNumber` | int | 1-indexed within parent poem |
| `coupletType` | enum | `MATLA`, `MAQTA`, `REGULAR`, `CHORUS`, `REFRAIN` |
| `coupletTypeName` | string | Urdu name |
| `verses` | `VerseDto[]` | Typically 2 verses for ghazals |
| `poemPublicId` | string | Parent poem |
| `poetPublicId` | string | |
| `poetName` | string | |
| `poetProfileImageUrl` | string | |
| `likeCount` | int | |
| `shareCount` | int | |

#### `GuestDiscoverBundleDto`
| Field | Type | Notes |
|---|---|---|
| `featuredPoems` | `GuestPoemSummaryDto[]` | Up to 6 |
| `featuredPoets` | `GuestPoetSummaryDto[]` | Up to 6 |
| `trendingPoets` | `GuestPoetSummaryDto[]` | Up to 6 |
| `trendingCouplets` | `GuestCoupletDto[]` | Up to 6 |
| `language` | string | The `lang` actually used (after fallback) |
| `timestamp` | long | Epoch millis at bundle build time |

---

### 21.13 Flutter Integration Guide {#2113-flutter-integration-guide}

#### 21.13.1 Remove the Login Wall

Today the app likely shows the sign-in screen at launch and gates everything
behind it. Apple rejects this. Restructure as:

```
App launch
  ↓
Show home screen (uses /api/guest/discover)
  ↓
User browses freely
  ↓
User taps a gated action (like, bookmark, follow, comment, etc.)
  ↓
Show "Sign in to continue" sheet
  ↓
On success: switch to authenticated APIs and re-fetch personalized data
```

**Authentication state machine:**
```dart
enum AuthState { anonymous, authenticated }

class AuthController extends ChangeNotifier {
  AuthState _state = AuthState.anonymous;
  String? _token;

  AuthState get state => _state;
  String? get token => _token;
  bool get isAnonymous => _state == AuthState.anonymous;

  void setAuthenticated(String token) {
    _token = token;
    _state = AuthState.authenticated;
    notifyListeners();
  }

  void signOut() {
    _token = null;
    _state = AuthState.anonymous;
    notifyListeners();
  }
}
```

#### 21.13.2 API Client Switching

Use a single API client that picks the right base path based on auth state:

```dart
class PoetryApi {
  final AuthController auth;
  final http.Client http;
  final String baseUrl;

  PoetryApi(this.auth, this.http, this.baseUrl);

  /// Fetches the home/discover screen. Uses the guest endpoint when
  /// anonymous, the authenticated discover when signed in (which adds
  /// personalization).
  Future<Map<String, dynamic>> discover({String lang = 'ur'}) async {
    final path = auth.isAnonymous ? '/api/guest/discover' : '/api/discover';
    final headers = <String, String>{};
    if (!auth.isAnonymous) {
      headers['Authorization'] = 'Bearer ${auth.token}';
    }
    final r = await http.get(Uri.parse('$baseUrl$path?lang=$lang'), headers: headers);
    return _unwrap(r);
  }

  /// Lists poems. Anonymous gets the slim, capped list; authenticated gets
  /// full DTOs with engagement state.
  Future<Map<String, dynamic>> listPoems({
    String? poetryType,
    String lang = 'ur',
    int page = 0,
    int size = 10,
  }) async {
    final base = auth.isAnonymous ? '/api/guest/poems' : '/api/poems';
    final qp = <String, String>{
      'lang': lang,
      'page': '$page',
      'size': '$size',
      if (poetryType != null) 'poetryType': poetryType,
    };
    final uri = Uri.parse('$baseUrl$base').replace(queryParameters: qp);
    final headers = auth.isAnonymous
        ? const <String, String>{}
        : {'Authorization': 'Bearer ${auth.token}'};
    final r = await http.get(uri, headers: headers);
    return _unwrap(r);
  }

  Map<String, dynamic> _unwrap(http.Response r) {
    if (r.statusCode == 429) {
      throw RateLimitedException(
        retryAfter: int.tryParse(r.headers['retry-after'] ?? '60') ?? 60,
      );
    }
    if (r.statusCode != 200) {
      throw HttpException('${r.statusCode}: ${r.body}');
    }
    return jsonDecode(r.body) as Map<String, dynamic>;
  }
}

class RateLimitedException implements Exception {
  final int retryAfter;
  RateLimitedException({required this.retryAfter});
}
```

#### 21.13.3 Gated Action Pattern

Wrap any action that requires auth in this helper:

```dart
Future<void> requireSignIn(BuildContext context, VoidCallback ifSignedIn) async {
  final auth = context.read<AuthController>();
  if (auth.isAnonymous) {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SignInPromptSheet(),
    );
    if (result == true) ifSignedIn();
  } else {
    ifSignedIn();
  }
}

// Usage:
IconButton(
  icon: const Icon(Icons.favorite_border),
  onPressed: () => requireSignIn(context, () => _likePoem(poem)),
)
```

The sign-in sheet should show **both** Google and Apple options (Apple at
least as prominent — see §1.6.6) plus a "Continue browsing" dismiss button.

#### 21.13.4 After Sign-In: Re-Fetch Personalization

When the user signs in mid-browse, refresh whatever screen they're on so it
flips from guest data to personalized data:

```dart
auth.addListener(() {
  if (auth.state == AuthState.authenticated) {
    // Invalidate any in-memory caches keyed on guest data
    feedController.refresh();
    discoverController.refresh();
  }
});
```

#### 21.13.5 Handling 429 Rate-Limit Responses

```dart
try {
  final data = await api.discover();
  // ...
} on RateLimitedException catch (e) {
  // Don't show a modal — that's annoying. Show a non-blocking toast.
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text('Slow down a bit — retry in ${e.retryAfter}s'),
    duration: Duration(seconds: 3),
  ));
  // Schedule a single auto-retry
  Future.delayed(Duration(seconds: e.retryAfter), () {
    _refresh();
  });
}
```

In practice a real user will never hit the rate limit (60 req/min / 1000 per
hour leaves a lot of headroom). 429 means either a buggy client (infinite
loop) or a scraper. Defensive UI handling matters more than aggressive retry.

#### 21.13.6 Dart Models

```dart
class GuestPoemSummary {
  final String publicId;
  final String title;
  final String excerpt;
  final String poetPublicId;
  final String poetName;
  final String? poetProfileImageUrl;
  final String poetryType;
  final String poetryTypeName;
  final String contentType;
  final String thumbnailUrl;
  final int viewCount;
  final int likeCount;
  final int shareCount;
  final DateTime createdAt;

  GuestPoemSummary.fromJson(Map<String, dynamic> j)
      : publicId = j['publicId'],
        title = j['title'] ?? '',
        excerpt = j['excerpt'] ?? '',
        poetPublicId = j['poetPublicId'],
        poetName = j['poetName'] ?? '',
        poetProfileImageUrl = j['poetProfileImageUrl'],
        poetryType = j['poetryType'],
        poetryTypeName = j['poetryTypeName'] ?? '',
        contentType = j['contentType'] ?? 'TEXT',
        thumbnailUrl = j['thumbnailUrl'] ?? '-',
        viewCount = j['viewCount'] ?? 0,
        likeCount = j['likeCount'] ?? 0,
        shareCount = j['shareCount'] ?? 0,
        createdAt = DateTime.parse(j['createdAt']);
}

class GuestPoetSummary {
  final String publicId;
  final String name;
  final String? shortBio;
  final String? profileImageUrl;
  final int? birthYear;
  final int? deathYear;
  final String? era;
  final String? country;
  final String? countryFlag;
  final int poemCount;

  GuestPoetSummary.fromJson(Map<String, dynamic> j)
      : publicId = j['publicId'],
        name = j['name'] ?? '',
        shortBio = j['shortBio'],
        profileImageUrl = j['profileImageUrl'],
        birthYear = j['birthYear'],
        deathYear = j['deathYear'],
        era = j['era'],
        country = j['country'],
        countryFlag = j['countryFlag'],
        poemCount = j['poemCount'] ?? 0;
}

class GuestCouplet {
  final String publicId;
  final int coupletNumber;
  final String coupletType;
  final String? coupletTypeName;
  final List<dynamic> verses;
  final String? poemPublicId;
  final String? poetPublicId;
  final String? poetName;
  final String? poetProfileImageUrl;
  final int likeCount;
  final int shareCount;

  GuestCouplet.fromJson(Map<String, dynamic> j)
      : publicId = j['publicId'],
        coupletNumber = j['coupletNumber'] ?? 0,
        coupletType = j['coupletType'] ?? 'REGULAR',
        coupletTypeName = j['coupletTypeName'],
        verses = j['verses'] ?? const [],
        poemPublicId = j['poemPublicId'],
        poetPublicId = j['poetPublicId'],
        poetName = j['poetName'],
        poetProfileImageUrl = j['poetProfileImageUrl'],
        likeCount = j['likeCount'] ?? 0,
        shareCount = j['shareCount'] ?? 0;
}
```

#### 21.13.7 Anonymous Browsing Checklist for App Review

- [ ] App launches directly to a content screen — no sign-in required to see anything
- [ ] User can read a complete poem without signing in
- [ ] User can browse the poet directory without signing in
- [ ] User can search without signing in
- [ ] Tapping a write-action (like, bookmark, follow, comment, react, generate image, save to collection) prompts sign-in **only at that moment**, not preemptively
- [ ] Sign-in sheet has both **Google** and **Apple** options with Apple at least as prominent
- [ ] After sign-in, the user lands back on the screen they were on (not back to a "welcome" screen)
- [ ] No 429 errors in normal browsing (a healthy session stays well under 60 req/min)

---

## Support & Feedback

For issues or questions:
- GitHub: https://github.com/your-repo/issues
- Email: support@poetry.com

**Documentation Version:** 1.8.0
**Last Updated:** May 15, 2026

---
