# Personalized "For You" Feed — Implementation Plan (v2)

## Context

The app's Feed tab (tab index 0) is currently a placeholder with 5 static cards. The backend API (Section 17) is fully built — `GET /api/feed` returns mixed content (couplets, poems, poet spotlights, poet images) with cursor-based pagination and `POST /api/events/batch` accepts engagement signals for personalization. This plan implements the complete feed feature using the app's existing Riverpod + Dio + Freezed architecture.

**Post-review additions (v2):** Typed content models (sealed class), `_fetchLock` race condition guard, impression deduplication, optimistic engagement state overlay, scroll-to-top on tab re-tap.

---

## Step 1: Add Dependencies

**File:** `pubspec.yaml`

Add:
```yaml
uuid: ^4.5.1              # Idempotent event IDs
visibility_detector: ^0.4.0+2  # Impression/dwell tracking
```

Already present: `shimmer: ^3.0.0`, `cached_network_image: ^3.4.1`

---

## Step 2: Create Feed Feature Folder Structure

```
lib/features/feed/
├── models/
│   ├── feed_response.dart
│   ├── feed_item.dart
│   ├── feed_content_data.dart    ← NEW (sealed class + typed content models)
│   └── feed_event.dart
├── services/
│   ├── feed_service.dart
│   └── feed_event_tracker.dart
├── providers/
│   ├── feed_provider.dart
│   └── feed_engagement_provider.dart  ← NEW (optimistic engagement overlay)
├── screens/
│   └── feed_screen.dart
└── widgets/
    ├── feed_item_builder.dart
    ├── couplet_feed_card.dart
    ├── poem_feed_card.dart
    ├── poet_spotlight_feed_card.dart
    ├── poet_image_feed_card.dart
    ├── feed_shimmer.dart
    └── feed_engagement_row.dart
```

---

## Step 3: Data Models (Freezed)

### `feed_response.dart`
Freezed model for the API response's `data` field:
- `items` (List<FeedItem>), `nextCursor` (String?), `hasMore` (bool), `isPersonalized` (bool), `sessionId` (String), `itemCount` (int)
- Factory `fromJson` using json_serializable

### `feed_item.dart`
Freezed model for each feed item:
- `type` (String — COUPLET/POEM/POET_SPOTLIGHT/POET_IMAGE), `publicId`, `reason`, `sourceId`, `lang` (String?), `contentData` (FeedContentData — typed, not raw Map)
- Custom `fromJson` that passes `type` to `FeedContentData.fromJson(type, rawMap)`

### `feed_content_data.dart` ← NEW
Sealed class with Freezed typed models for compile-time safety:
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

@freezed class CoupletContentData ... implements FeedContentData
@freezed class PoemContentData ... implements FeedContentData
@freezed class PoetSpotlightContentData ... implements FeedContentData
@freezed class PoetImageContentData ... implements FeedContentData
class UnknownContentData implements FeedContentData  // graceful fallback
```
**Why:** Compile-time safety for 30+ field reads across 4 card types. Autocomplete. Unknown future types render as `SizedBox.shrink()` instead of crashing.

### `feed_event.dart`
Plain Dart class (no Freezed needed — this is only serialized TO json, never deserialized):
- `eid` (UUID string), `t` (event type), `itemKey` ("TYPE:publicId"), `sid` (session ID), `ts` (unix seconds), `v` (optional int for dwell_ms)
- `toJson()` method

Run `dart run build_runner build` after creating models.

---

## Step 4: Feed Service

**File:** `lib/features/feed/services/feed_service.dart`

Uses the app's existing `Dio` instance (from `dioClientProvider`) — NOT the `http` package from the API doc. Auth token is auto-attached by `AuthInterceptor`.

Methods:
- `getFeed({String lang, String? cursor, int limit = 20})` → `Future<FeedResponse>`
  - `GET /api/feed` with query params
  - Parse response with `ApiResponse<Map<String, dynamic>>` then `FeedResponse.fromJson(data)`
- `sendEvents(List<FeedEvent> events)` → `Future<void>`
  - `POST /api/events/batch` with JSON body
  - Fire-and-forget: catch all errors, never throw (events are non-critical)

Riverpod provider: `feedServiceProvider = Provider<FeedService>((ref) => FeedService(ref.watch(dioClientProvider).dio))`

---

## Step 5: Feed Event Tracker

**File:** `lib/features/feed/services/feed_event_tracker.dart`

Encapsulates all event buffering and impression/dwell logic:

- `_pendingEvents` list (buffer)
- `_impressionStartTimes` map (publicId → timestamp in ms)
- `_impressedItemKeys` Set<String> ← NEW — **deduplicates impressions** (VisibilityDetector fires multiple times per item during scroll; record only one impression per itemKey per session)
- `onItemVisible(FeedItem item, String sessionId)` — check `_impressedItemKeys` first, skip if already recorded; otherwise record impression event + start time + add to set
- `onItemHidden(FeedItem item, String sessionId)` — calculates dwell, emits `dwell_ms` (≥500ms) or `skip_fast` (<500ms)
- `trackAction(FeedItem item, String sessionId, String eventType)` — for open_item, bookmark, share, follow
- `flush(FeedService service)` → sends batch & clears buffer
- `reset()` — clears `_impressedItemKeys` + `_impressionStartTimes` (called on pull-to-refresh / new session)
- Uses `package:uuid` v4 for `eid` generation

---

## Step 6: Feed State (Riverpod StateNotifier)

**File:** `lib/features/feed/providers/feed_provider.dart`

### FeedState (Freezed)
```
- items: List<FeedItem>
- nextCursor: String?
- sessionId: String?
- hasMore: bool
- isLoading: bool
- isLoadingMore: bool   // separate flag for next-page loading (keeps existing items visible)
- error: String?
- isInitial: bool       // true before first load
```

### FeedNotifier (StateNotifier<FeedState>)
Holds a `FeedEventTracker` instance internally.
Uses a **synchronous `bool _fetchLock`** ← NEW — prevents race condition where scroll listener fires multiple times before Riverpod state propagates, avoiding duplicate fetches that corrupt cursor state.

Key methods:
- `loadFirstPage()` — flush events, reset tracker (`_impressedItemKeys`), clear state, fetch first page (no cursor)
- `loadNextPage()` — guard with **`_fetchLock || !state.hasMore`**, set `_fetchLock = true`, flush events, fetch with cursor, finally `_fetchLock = false`
- `refresh()` — alias for loadFirstPage (used by pull-to-refresh)
- `onItemVisible(FeedItem)` / `onItemHidden(FeedItem)` — delegate to tracker
- `trackAction(FeedItem, String eventType)` — delegate to tracker
- `flushEvents()` — public, called on dispose/background

Watches `selectedLanguageProvider` — when language changes, auto-reloads first page.

### Provider
```dart
final feedProvider = StateNotifierProvider<FeedNotifier, FeedState>((ref) {
  final feedService = ref.watch(feedServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);
  return FeedNotifier(feedService: feedService, lang: lang);
});
```
Using `ref.watch(selectedLanguageProvider)` means when language changes, the notifier is recreated → fresh feed.

---

## Step 6b: Optimistic Engagement State ← NEW

**File:** `lib/features/feed/providers/feed_engagement_provider.dart`

Lightweight overlay that tracks local like/bookmark/follow actions on feed items, providing instant UI feedback without waiting for API response.

```dart
class FeedEngagementOverlay {
  final bool? isLiked;        // null = use server value
  final bool? isBookmarked;
  final bool? isFollowed;
  final int likeCountDelta;   // +1 or -1 from server count
  final int bookmarkCountDelta;
}

final feedEngagementProvider = StateProvider<Map<String, FeedEngagementOverlay>>((ref) => {});
```

**How it works:**
- Card widgets read from overlay first, fall back to contentData server values
- On user action (like/bookmark/follow): update overlay instantly (optimistic) → fire API call → on failure, revert overlay + show snackbar
- Overlay is keyed by `"TYPE:publicId"` (same as itemKey)
- Overlay is cleared on pull-to-refresh (fresh data from server)

**Why:** User likes a couplet → count updates instantly. User goes to poem detail, bookmarks there, comes back → feed reflects it. Without this, engagement feels broken.

---

## Step 7: Feed Card Widgets

All cards follow the app's existing visual patterns (AppColors, AppSpacing, dark/light theme, LocalizedText for RTL).

### Common: `feed_engagement_row.dart`
Reusable row with like, bookmark, share buttons + counts. Takes counts as ints and callbacks. Styled like existing `CoupletEngagementButtons` but horizontal with icon+count layout.

### `couplet_feed_card.dart`
- Takes `CoupletContentData` (typed) + `FeedItem` for metadata (reason, publicId)
- Reads engagement overlay via `ref.watch(feedEngagementProvider)` for optimistic like/bookmark state
- **Header:** Poet avatar (CachedNetworkImage, 36px circle) + poet name (LocalizedText) + reason badge chip ("Trending"/"For You")
- **Body:** `data.versesTextArabic` rendered in Nastaliq font (center-aligned, RTL), `data.versesTextRoman` below in grey (only if non-Urdu lang)
- **Footer:** Engagement row (like, bookmark, share with counts — overlay-aware)
- **Tap:** Navigate to poem detail: `context.push('/main/poems/${data.poemPublicId}')`

### `poem_feed_card.dart`
- Takes `PoemContentData` (typed) + `FeedItem`
- **Header:** Poet avatar + name + poetry type badge (color-coded, reuse existing color map from PoemCard)
- **Body:** `data.title` (LocalizedText, bold) + `data.excerpt` (LocalizedText, maxLines: 3, ellipsis) + optional thumbnail (CachedNetworkImage)
- **Footer:** Engagement row (likes, views — overlay-aware)
- **Tap:** Navigate to poem detail via publicId

### `poet_spotlight_feed_card.dart`
- Takes `PoetSpotlightContentData` (typed) + `FeedItem`
- **Header:** "Discover" badge
- **Body:** Large poet profile image (CachedNetworkImage) + `data.poetName` + `data.bio` snippet (LocalizedText, maxLines: 3) + stats row (`data.poemCount`, `data.followerCount`, `data.viewCount`) + compact `FollowButton` (reuse existing widget, overlay-aware for follow state)
- **Tap:** Navigate to poet detail: `context.push('/main/poets/${data.poetPublicId}')`
- Track `follow` event when follow button tapped

### `poet_image_feed_card.dart`
- Takes `PoetImageContentData` (typed) + `FeedItem`
- **Header:** Poet name + "Gallery" label
- **Body:** `data.imageUrl` (CachedNetworkImage, aspect ratio ~4:3, rounded corners) + `data.contentText` caption (if any, in Nastaliq)
- **Footer:** Like + share with counts (overlay-aware)
- **Tap:** Open image fullscreen viewer (reuse existing `ImageFullscreenViewer` or navigate)

### `feed_item_builder.dart`
Switch on `item.type` → returns the correct card widget wrapped in VisibilityDetector + GestureDetector. Returns `SizedBox.shrink()` for unknown types.

---

## Step 8: Feed Shimmer

**File:** `lib/features/feed/widgets/feed_shimmer.dart`

Mixed skeleton: show 3-4 shimmer cards mimicking the variety of feed content (one tall card for couplet shape, one shorter for poem, one with image placeholder). Uses existing `shimmer` package with AppColors.shimmerBase/shimmerHighlight for light mode, surfaceDark/borderDark for dark mode (same pattern as `DiscoverShimmer`).

---

## Step 9: Feed Screen

**File:** `lib/features/feed/screens/feed_screen.dart`

A `ConsumerStatefulWidget` with `AutomaticKeepAliveClientMixin` (preserve scroll position when switching tabs) and `WidgetsBindingObserver` (flush events on app background).

Structure:
```
Scaffold(
  floatingActionButton: FAB for "Create Poetry Image" (preserved from current feed_tab.dart),
  body: RefreshIndicator(
    onRefresh: () => ref.read(feedProvider.notifier).refresh(),
    child: CustomScrollView(
      controller: _scrollController,
      slivers: [
        StandardSliverAppBar(title: 'For You', actions: [notification icon]),
        // Content based on state:
        if (isInitial || isLoading) → SliverFillRemaining with FeedShimmer
        if (error && items.empty) → SliverFillRemaining with full-screen error + retry
        else → SliverPadding(
          SliverList.builder(
            itemCount: items.length + 1,  // +1 for footer
            itemBuilder: builds each FeedItem via feed_item_builder
              + VisibilityDetector wrapper for each item
              + footer: shimmer cards if loadingMore, retry widget if error, "end" message if !hasMore
          )
        )
      ],
    ),
  ),
)
```

**Scroll listener:** `_scrollController.position.pixels >= maxScrollExtent - 600` triggers `loadNextPage()` (600px threshold for tall poetry cards).

**Lifecycle:**
- `initState`: load first page, add scroll listener, register WidgetsBindingObserver
- `didChangeAppLifecycleState(paused)`: flush events
- `dispose`: remove scroll listener, remove observer

---

## Step 10: Integration

### Update `MainScreen` (`lib/features/main/main_screen.dart`)
- Replace `FeedTab()` import/reference with new `FeedScreen()` from `lib/features/feed/screens/feed_screen.dart`
- **Add scroll-to-top on tab re-tap** ← NEW: In `onTap`, if tapped index == current index == 0 (feed tab), call `_feedScrollController.animateTo(0, duration: 300ms, curve: easeOut)`. Expose scroll controller from FeedScreen via a GlobalKey or callback.

### Update `app_router.dart`
- No new routes needed (feed uses existing poem/poet detail routes via `context.push`)

### Update old `feed_tab.dart`
- Can delete this file or keep it as a redirect — it's fully replaced

---

## Step 11: Error Handling

- **First page fails:** Full-screen error state with retry button (keeps the screen usable)
- **Next page fails:** Inline retry widget at bottom of list, existing items stay visible
- **401:** Handled automatically by AuthInterceptor (token refresh + retry)
- **400 (tampered/expired cursor):** Treat as new session — clear cursor, reload first page silently
- **Network offline:** Show error state, retry on tap
- **Event send failure:** Silently ignored (fire-and-forget, as per API spec)

---

## Step 12: Verification

1. `flutter pub get` — ensure new deps resolve
2. `dart run build_runner build` — generate Freezed/json_serializable code
3. Run app → Feed tab should show shimmer → then feed items
4. Scroll down → next page loads seamlessly at threshold
5. Pull-to-refresh → fresh session, new content order
6. Tap a couplet → navigates to poem detail screen
7. Tap a poet spotlight → navigates to poet detail screen
8. Check events: Add `X-Feed-Debug: true` header in dev to verify events are received
9. Switch language → feed reloads with new language content
10. Kill app mid-scroll → reopen → feed starts fresh (no stale state)
11. Dark mode → all cards render correctly with dark theme colors
12. Like a couplet in feed → count updates instantly (optimistic overlay)
13. Re-tap Feed tab → scrolls to top smoothly

---

## Files to Create (22 files, 8 generated by build_runner)

| # | File | Purpose |
|---|------|---------|
| 1 | `lib/features/feed/models/feed_response.dart` | Freezed response model |
| 2 | `lib/features/feed/models/feed_response.freezed.dart` | Generated |
| 3 | `lib/features/feed/models/feed_response.g.dart` | Generated |
| 4 | `lib/features/feed/models/feed_item.dart` | Freezed item model |
| 5 | `lib/features/feed/models/feed_item.freezed.dart` | Generated |
| 6 | `lib/features/feed/models/feed_item.g.dart` | Generated |
| 7 | `lib/features/feed/models/feed_content_data.dart` | **NEW** — Sealed class + 4 Freezed content models + UnknownContentData |
| 8 | `lib/features/feed/models/feed_content_data.freezed.dart` | Generated |
| 9 | `lib/features/feed/models/feed_content_data.g.dart` | Generated |
| 10 | `lib/features/feed/models/feed_event.dart` | Event model (plain Dart) |
| 11 | `lib/features/feed/services/feed_service.dart` | API calls |
| 12 | `lib/features/feed/services/feed_event_tracker.dart` | Event buffering + impression dedup |
| 13 | `lib/features/feed/providers/feed_provider.dart` | Riverpod state + _fetchLock |
| 14 | `lib/features/feed/providers/feed_engagement_provider.dart` | **NEW** — Optimistic engagement overlay |
| 15 | `lib/features/feed/screens/feed_screen.dart` | Main screen |
| 16 | `lib/features/feed/widgets/feed_item_builder.dart` | Type dispatcher |
| 17 | `lib/features/feed/widgets/couplet_feed_card.dart` | Couplet card |
| 18 | `lib/features/feed/widgets/poem_feed_card.dart` | Poem card |
| 19 | `lib/features/feed/widgets/poet_spotlight_feed_card.dart` | Spotlight card |
| 20 | `lib/features/feed/widgets/poet_image_feed_card.dart` | Image card |
| 21 | `lib/features/feed/widgets/feed_shimmer.dart` | Loading skeleton |
| 22 | `lib/features/feed/widgets/feed_engagement_row.dart` | Engagement buttons (overlay-aware) |

## Files to Modify (2 files)

| File | Change |
|------|--------|
| `pubspec.yaml` | Add `uuid` and `visibility_detector` |
| `lib/features/main/main_screen.dart` | Replace FeedTab → FeedScreen + scroll-to-top on tab re-tap |

## File to Delete (1 file)

| File | Reason |
|------|--------|
| `lib/features/main/tabs/feed_tab.dart` | Replaced by `feed_screen.dart` |

---

## Implementation Order

1. Dependencies (`pubspec.yaml`)
2. Models (feed_content_data sealed class, feed_response, feed_item, feed_event) → run build_runner
3. Service (feed_service)
4. Event tracker (feed_event_tracker — with impression dedup)
5. Providers (feed_provider with _fetchLock + feed_engagement_provider)
6. Widgets (engagement row → individual cards → item builder → shimmer)
7. Screen (feed_screen)
8. Integration (main_screen update with scroll-to-top, delete old feed_tab)
9. Test & verify
