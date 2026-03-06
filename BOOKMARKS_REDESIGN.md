# Bookmarks Feature — UI/UX Audit & Redesign Specification

---

## A) UI/UX Audit — Top 10 Issues

### 1. Duplicate Screens, Fragmented Experience
**Current**: `BookmarksTab` (bottom nav tab) and `UnifiedBookmarksScreen` are nearly identical screens with different navigation entry points. Two separate implementations of the same feature.
**Impact**: Maintenance burden, inconsistent behavior, user confusion about "View All" going to a different screen that looks almost the same.

### 2. "Recent" Section is Vertically Wasteful
**Current**: The "Recent" section shows 2 full-height cards stacked vertically, each ~120px tall, before "All Bookmarks" begins. On a 390pt-wide screen, these two cards consume ~300px — nearly 40% of viewport — before the user sees their actual bookmark list.
**Impact**: Users must scroll past content they may have just seen to reach their full collection. First-time impression is that the screen is "empty" (only 2 items visible above fold).

### 3. No Delete/Unbookmark from the List
**Current**: Cards have no swipe action, no long-press menu, no context menu. The only way to remove a bookmark is to navigate into the content and toggle the bookmark button there.
**Impact**: Multi-step removal (tap card → wait for load → find bookmark button → toggle → go back) creates friction. Users with 50+ bookmarks cannot efficiently organize.

### 4. English-Only Labels in an Urdu-First App
**Current**: Header says "My Bookmarks", section headers say "Recent" and "All Bookmarks", filter buttons say "All", "Poems", "Couplets", "Images", empty state says "No bookmarks yet". Chip labels are "Poem", "UR", "HI".
**Impact**: Breaks the Urdu-first brand promise. Urdu users see English UI chrome wrapping Urdu content — a jarring disconnect.

### 5. Mixed-Language Card Layout Does Not Adapt
**Current**: All cards use the same layout structure regardless of language. Urdu titles render LTR-aligned with `Directionality` wrapper, but the metadata chips ("Poem", "UR") and poet name always render LTR at bottom-left. For an Urdu poem card, the title reads RTL but the attribution reads LTR — the eye zigzags.
**Impact**: Cognitive load increases. RTL users expect the entire card to flow RTL when content is Urdu.

### 6. No Search Debouncing + No Highlight
**Current**: `_onSearchChanged` fires on every keystroke (with 3-char minimum). No debounce timer. No visual highlighting of matched text in results.
**Impact**: Excessive API calls on typing. Users cannot confirm why a result matched their query.

### 7. 190px of Sticky Headers Steal Scroll Space
**Current**: `UnifiedBookmarksScreen` stacks 4 sticky persistent headers: AppBar (56px) + SearchBar (80px) + TypeFilter (60px) + LanguageFilter (50px) = **246px pinned**. On a 844px iPhone 14, this leaves only ~500px for content after safe area — barely 4 compact cards visible.
**Impact**: Users feel claustrophobic. The "filter" UI dominates the content it's supposed to help find.

### 8. Sort Bug — Both Options Identical
**Current**: In `bookmarks_tab.dart`, the sort logic sets `sortBy: 'bookmarkedAt'` for BOTH "NEWEST" and "OLDEST". Only `sortDir` changes, but `sortBy` appears intentionally branched yet produces identical values.
**Impact**: The sort button gives users false confidence that sorting works. Technically it does work (via sortDir), but the code suggests an unfinished feature.

### 9. No Empty State Illustration or CTA
**Current**: Empty state shows a 80px `bookmark_border_rounded` icon, English text "No bookmarks yet", and a subtitle. No actionable button, no illustration, no guidance on WHERE to bookmark content.
**Impact**: Dead-end screen for new users. No pathway to discover content worth bookmarking.

### 10. Card Tap Target Uses GestureDetector Without Feedback
**Current**: Cards use `GestureDetector` instead of `InkWell` or `Material`. No ripple, no press state, no haptic feedback.
**Impact**: Cards feel unresponsive. Users tap and see no visual confirmation until navigation completes — feels laggy even when fast.

---

## B) Redesigned Information Architecture + Screen Structure

### Single Screen Approach
Replace both `BookmarksTab` and `UnifiedBookmarksScreen` with one unified `AppBookmarksScreen` that serves as the bottom nav tab AND the full experience. No "View All" navigation — the tab IS the full view.

### State Machine — 5 States

```
enum BookmarksMode {
  empty,      // Zero bookmarks (first-time user)
  normal,     // Has bookmarks — default feed
  search,     // Search field active, showing filtered results
  filtered,   // Type/language filter active (collapsed into normal view)
  selecting,  // Multi-select mode for bulk actions
}
```

### Layout Blueprints Per State

#### State 1: Empty (Zero Bookmarks)

```
┌─────────────────────────────────┐
│  Scaffold(bg: #FFFBF7)         │
│                                 │
│  ┌───────────────────────────┐  │
│  │ AppBar: "نشان زدہ"         │  │  ← Urdu title, dark green bg
│  └───────────────────────────┘  │
│                                 │
│         (centered)              │
│                                 │
│    ┌─────────────────────┐      │
│    │  📖 Illustration     │      │  ← Custom poetry book illustration
│    │  (120x120)           │      │     SVG/Lottie, brand green tint
│    └─────────────────────┘      │
│                                 │
│    "ابھی تک کوئی نشان نہیں"      │  ← Nastaliq, 20px, primary text
│    "اپنی پسندیدہ شاعری محفوظ     │  ← Nastaliq, 14px, secondary text
│     کرنے کے لیے بُک مارک         │
│     بٹن دبائیں"                  │
│                                 │
│    ┌─────────────────────┐      │
│    │  شاعری دریافت کریں    │      │  ← Filled button, primary green
│    └─────────────────────┘      │     Navigates to Discover tab
│                                 │
└─────────────────────────────────┘
```

#### State 2: Normal (Has Bookmarks)

```
┌─────────────────────────────────┐
│  Scaffold(bg: #FFFBF7)         │
│                                 │
│  ┌───────────────────────────┐  │
│  │ AppBar: "نشان زدہ" [🔍][⋮] │  │  ← Search icon + overflow menu
│  └───────────────────────────┘  │     (sort, select mode)
│                                 │
│  ┌───────────────────────────┐  │
│  │ Filter Row (scrollable)    │  │  ← Single row: سب | غزلیں | اشعار | تصاویر
│  │ [سب ✓] [غزلیں] [اشعار] [تصاویر]│    Pill chips, horizontally scrollable
│  └───────────────────────────┘  │
│                                 │
│  حالیہ ←─────── 3 دن پہلے       │  ← Section header "Recent" with relative time
│  ┌──┐ ┌──┐ ┌──┐ ┌──┐           │
│  │  │ │  │ │  │ │  │           │  ← Horizontal scroll, compact cards
│  │  │ │  │ │  │ │  │           │     Width: 160px, height: ~100px
│  └──┘ └──┘ └──┘ └──┘           │
│                                 │
│  سب نشان زدہ (18) ────────────  │  ← "All Bookmarks" with total count
│                                 │
│  ┌───────────────────────────┐  │
│  │ Compact List Item 1        │  │  ← Dense row: type icon + title + poet
│  ├───────────────────────────┤  │     Height: ~64-72px per item
│  │ Compact List Item 2        │  │
│  ├───────────────────────────┤  │
│  │ Compact List Item 3        │  │
│  ├───────────────────────────┤  │
│  │ ...infinite scroll...      │  │
│  └───────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

#### State 3: Search Mode

```
┌─────────────────────────────────┐
│  ┌───────────────────────────┐  │
│  │ [←] Search TextField [✕]  │  │  ← Replaces AppBar, auto-focused
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ Filter Row (same chips)    │  │  ← Filters remain active during search
│  └───────────────────────────┘  │
│                                 │
│  "غزل" کے لیے 7 نتائج          │  ← Result count header
│                                 │
│  ┌───────────────────────────┐  │
│  │ Highlighted result item 1  │  │  ← Same compact list items
│  ├───────────────────────────┤  │     with query text highlighted
│  │ Highlighted result item 2  │  │
│  ├───────────────────────────┤  │
│  │ ...                        │  │
│  └───────────────────────────┘  │
│                                 │
│  ─── OR if empty ───            │
│                                 │
│    🔍 (48px, muted)             │
│    "غزل" کے لیے کوئی نشان       │
│    نہیں ملے                     │
│                                 │
└─────────────────────────────────┘
```

#### State 4: Filter Active (visual overlay on Normal)

No separate state screen — filters are inline in the Normal view. When a filter other than "سب" is active:

```
Filter Row: [سب] [غزلیں ✓ (12)] [اشعار] [تصاویر]
                    ↑ active chip gets filled bg + count badge
```

The "Recent" horizontal section hides when a specific type filter is active (showing only filtered "All" list). This maximizes content density.

#### State 5: Multi-Select / Edit Mode

```
┌─────────────────────────────────┐
│  ┌───────────────────────────┐  │
│  │ [✕ منسوخ] 3 منتخب [🗑️][📤] │  │  ← Cancel + count + delete + share
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ [☑] Compact List Item 1    │  │  ← Leading checkboxes appear
│  ├───────────────────────────┤  │     Selected items get subtle
│  │ [☐] Compact List Item 2    │  │     primary tint background
│  ├───────────────────────────┤  │
│  │ [☑] Compact List Item 3    │  │
│  ├───────────────────────────┤  │
│  │ [☑] Compact List Item 4    │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │ Bottom Action Bar           │  │  ← Slides up from bottom
│  │ [حذف کریں] [شیئر کریں]      │  │     Delete + Share actions
│  └───────────────────────────┘  │
│                                 │
└─────────────────────────────────┘
```

Entry: Long-press any item OR tap "⋮" menu → "انتخاب کریں"
Exit: Tap "✕ منسوخ" or complete action

---

## C) Interaction Model

### Tap Actions

| Gesture | Target | Action |
|---------|--------|--------|
| Tap | Bookmark card (any type) | Navigate: POEM → poem detail, COUPLET → poem detail scrolled to couplet, IMAGE → image viewer |
| Tap | Search icon (AppBar) | Transition to search mode: AppBar animates into TextField |
| Tap | Filter chip | Toggle filter; if same chip tapped again → deselect (back to "سب") |
| Tap | "شاعری دریافت کریں" (empty state) | Switch to Discover tab (index 1) |

### Swipe Actions (RTL-Aware)

**Critical RTL consideration**: In RTL layouts, "leading" swipe is right-to-left, and "trailing" swipe is left-to-right. Destructive actions go on the trailing (far) side.

| Swipe Direction | Action | Visual |
|----------------|--------|--------|
| Swipe leading (R→L in RTL) | **Share** | Green (#1F6F5E) background, share icon, "شیئر" label |
| Swipe trailing (L→R in RTL) | **Remove bookmark** | Warm red (#C75B5B) background, delete icon, "حذف" label |

Implementation: Use `Dismissible` with `confirmDismiss` for delete (show confirmation snackbar with undo, not a dialog). Share triggers native share sheet immediately.

### Long-Press → Multi-Select

1. Long-press any card → haptic feedback (medium impact) → card scales to 0.97 → enters selecting mode
2. Subsequent taps toggle selection (no long-press needed once in mode)
3. Top bar shows: `[✕] N منتخب` with delete and share icons
4. Bottom action bar slides up with: `حذف کریں (N)` | `شیئر کریں (N)`
5. Delete: Confirmation bottom sheet "N نشان حذف کریں؟" with "حذف" (red) + "منسوخ" buttons
6. After action: Exit select mode, show success snackbar with undo (for delete)

### "View All" Behavior

**Remove entirely**. The BookmarksTab IS the full view. No secondary screen. The "Recent" section is a horizontal preview (last 5 bookmarks within 72 hours). Scrolling past it reveals the complete chronological list.

### Pull-to-Refresh + Pagination

| Mechanism | Trigger | Behavior |
|-----------|---------|----------|
| Pull-to-refresh | Overscroll at top | Reset to page 0, refetch. Show `RefreshIndicator` with gold accent. |
| Infinite scroll | 80% scroll position | Load next page (size=20). Show 2 shimmer skeleton rows at bottom. |
| Cache-first | Screen mount | Show cached data instantly, refresh in background. If >5min stale, show subtle "↻ تازہ ترین" chip at top. |

### Search Behavior

| Aspect | Specification |
|--------|--------------|
| Minimum chars | 2 characters (not 3 — Urdu words are shorter) |
| Debounce | 400ms after last keystroke |
| Query normalization | Apply `AppSearchUrduNormalizer` before API call |
| Highlight | Use `HighlightedText` widget (already built in search feature) on title and poet name |
| Empty results | Centered: search_off icon (48px) + "«query» کے لیے کوئی نشان نہیں ملے" |
| Clear | "✕" button in TextField clears and returns to normal mode |
| Back | "←" button exits search mode entirely |
| Active filters | Filters remain applied during search (search within filtered results) |

---

## D) Result Card System Redesign

### Design Principles
1. **Content-first**: Title/verse is the largest element, always
2. **Language-adaptive**: Entire card flows RTL for Urdu content, LTR for English/Hindi
3. **Consistent height**: All card variants target ~64-72px for "All Bookmarks" list density
4. **Brand-subtle**: No heavy colors on cards; primary green only on type indicators

---

### Variant 1: Compact List Item (for "All Bookmarks")

**Height target**: 64px (POEM/IMAGE) / 80px (COUPLET, needs 2 verse lines)

#### POEM Compact Item
```
┌─────────────────────────────────────────────────┐
│ ┌────┐                                          │
│ │ غ  │  غزل کا عنوان یہاں ──────── 2 دن پہلے   │  ← Title (Nastaliq 15px, w600, max 1 line)
│ │    │  شاعر کا نام                    UR ▸    │  ← Poet (12px, secondary) + lang chip + arrow
│ └────┘                                          │
└─────────────────────────────────────────────────┘
  ↑ Type icon (36x36, rounded 8px)
    bg: primary@8%, icon: auto_stories (20px, primary)
```

#### COUPLET Compact Item
```
┌─────────────────────────────────────────────────┐
│ ┌────┐                                          │
│ │ ❝  │  پہلا مصرع یہاں لکھا جائے گا ──────────  │  ← Verse 1 (Nastaliq 14px, max 1 line)
│ │    │  دوسرا مصرع یہاں لکھا جائے گا            │  ← Verse 2 (Nastaliq 14px, max 1 line)
│ └────┘  شاعر کا نام              UR ▸          │  ← Poet (11px, secondary)
└─────────────────────────────────────────────────┘
  ↑ Type icon (36x36, rounded 8px)
    bg: primary@8%, icon: format_quote (20px, primary)
```

#### IMAGE Compact Item
```
┌─────────────────────────────────────────────────┐
│ ┌────┐                                          │
│ │ 🖼 │  Template Name ──────────── 5 دن پہلے   │  ← Template name (14px, max 1 line)
│ │    │  Image Poetry                   UR ▸    │  ← Subtext + lang chip + arrow
│ └────┘                                          │
└─────────────────────────────────────────────────┘
  ↑ Thumbnail (36x36, rounded 8px, cover fit)
    Fallback: image icon on primary@8% bg
```

#### Typography Spec (Compact Items)

| Element | Urdu | English/Hindi | Color |
|---------|------|---------------|-------|
| Title / Verse 1 | Jameel Noori Nastaleeq, 15px, w600, height 1.7 | System, 14px, w600, height 1.4 | textPrimary |
| Verse 2 | Jameel Noori Nastaleeq, 14px, w400, height 1.7 | System, 13px, w400, height 1.4 | textPrimary @80% |
| Poet name | Jameel Noori Nastaleeq, 12px, w400, height 1.5 | System, 11px, w400, height 1.3 | textSecondary |
| Time ago | System, 10px, w400 | same | textDisabled |
| Lang chip | System, 9px, w600, letterSpacing 0.5 | same | primary @60% |

#### Spacing Spec (Compact Items)

| Property | Value |
|----------|-------|
| Card margin horizontal | 16px (AppSpacing.md) |
| Card margin vertical | 2px (tight stacking) |
| Card padding horizontal | 12px |
| Card padding vertical | 10px |
| Icon-to-content gap | 12px |
| Title-to-poet gap | 2px |
| Card border radius | 10px |
| Card background | #FFFBF7 light / #1E1E1E dark |
| Card border | 0.5px, black@3% light / white@4% dark |
| Card shadow | 0,1,3 black@2% light / black@10% dark |

#### Language-Adaptive Layout

```dart
// Detect content language and set card directionality
final isRtl = bookmark.languageCode == 'ur';

Directionality(
  textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
  child: Row(
    children: [
      typeIcon,        // Always leading (adapts with Directionality)
      SizedBox(width: 12),
      Expanded(content),
      langChip,
      Icon(Icons.arrow_forward_ios, size: 12), // Mirrors in RTL automatically
    ],
  ),
)
```

---

### Variant 2: Compact Horizontal Card (for "Recent" Carousel)

**Size**: Width 160px, Height ~100px (POEM) / ~120px (COUPLET)

#### POEM Horizontal Card
```
┌────────────────────────┐
│  غ   Poem · UR         │  ← Row: type icon (16px) + "Poem" + lang
│                        │
│  غزل کا عنوان           │  ← Title: Nastaliq 14px, w600, max 2 lines
│  یہاں لکھا جائے گا     │
│                        │
│  شاعر کا نام            │  ← Poet: 11px, secondary, max 1 line
└────────────────────────┘
```

#### COUPLET Horizontal Card
```
┌────────────────────────┐
│  ❝  Couplet · UR       │  ← Row: type icon + "Couplet" + lang
│                        │
│  پہلا مصرع              │  ← Verse 1: Nastaliq 13px, centered, max 1 line
│  ───── (separator)     │
│  دوسرا مصرع             │  ← Verse 2: Nastaliq 13px, centered, max 1 line
│                        │
│  شاعر کا نام            │  ← Poet: 11px, secondary
└────────────────────────┘
```

#### Horizontal Card Specs

| Property | Value |
|----------|-------|
| Width | 160px |
| Height | intrinsic (min 96px, max ~130px) |
| Padding | 12px all sides |
| Border radius | 12px |
| Background | same as compact items |
| Gap between cards | 10px |
| Carousel padding | 16px start, 16px end |
| Carousel height | 140px (including margins) |

---

## E) Filters, Sorting, and Organization

### Filter System

#### Type Filters (single row of pills, scrollable)

| Value | Urdu Label | Icon | Count Badge |
|-------|-----------|------|-------------|
| ALL | سب | — | total |
| POEM | غزلیں | auto_stories | poemCount |
| COUPLET | اشعار | format_quote | coupletCount |
| IMAGE | تصاویر | image | imageCount |

**Behavior**:
- Counts come from `BookmarkStats` API (fetched once on screen mount, cached)
- Active chip: filled primary green bg, white text, w600
- Inactive chip: transparent bg, primary@50% border, primary text
- Pill shape: borderRadius 999
- Tap toggles; re-tap deselects back to "سب"
- When filter is active, "Recent" horizontal section hides

#### Language Filters

**Remove as a separate row**. Instead, integrate into the overflow menu ("⋮") as a bottom sheet option:

```
┌─────────────────────────────────┐
│  زبان منتخب کریں                 │  ← Sheet title
│                                 │
│  [●] سب زبانیں                   │
│  [○] اردو                       │
│  [○] English                    │
│  [○] हिंदी                      │
│                                 │
│  ┌─────────────────────────┐    │
│  │       لاگو کریں          │    │  ← Apply button
│  └─────────────────────────┘    │
└─────────────────────────────────┘
```

**Rationale**: Language filter is a secondary filter used infrequently. Promoting it to a permanent sticky header wastes 50px of prime viewport space for most users who bookmark in one language only.

When a language filter IS active, show a dismissible chip below the type filter row:
```
Filter Row: [سب] [غزلیں] [اشعار] [تصاویر]
Active:     [اردو ✕]  ← dismissible chip, gold accent border
```

### Sorting

Available via overflow menu ("⋮") → "ترتیب":

| Sort Option | Urdu Label | API params |
|------------|-----------|------------|
| Newest first (default) | تازہ ترین | sortBy=bookmarkedAt, sortDir=desc |
| Oldest first | پرانے پہلے | sortBy=bookmarkedAt, sortDir=asc |

**Nice-to-have** (requires backend):
| Sort Option | Urdu Label | API params |
|------------|-----------|------------|
| Most liked | سب سے مقبول | sortBy=likeCount, sortDir=desc |
| Most shared | سب سے زیادہ شیئر | sortBy=shareCount, sortDir=desc |

### Organization — Notes (Lightweight, No Folders)

The `notes` field already exists in the model. Enable it as a lightweight annotation:

**Add Note Flow**:
1. Long-press card → menu appears with "نوٹ شامل کریں" option
2. Bottom sheet opens with a text field (max 200 chars, Nastaliq keyboard)
3. Save → PATCH `/api/bookmarks/{type}/{bookmarkId}/notes` (new endpoint needed)
4. Cards with notes show a small "📝" indicator next to the type chip

**Why Not Folders/Tags**: Folders add significant complexity (new data model, new screens, drag-and-drop, empty folder states). Notes provide 80% of the organizational value with 10% of the complexity. Reassess after user feedback.

---

## F) Animation / Motion Specs

| # | Trigger | Property | Duration | Curve | Notes |
|---|---------|----------|----------|-------|-------|
| 1 | Screen enter | List items: opacity 0→1 + translateY(8→0) | 250ms | easeOut | Stagger 30ms/item, max 8 items animated (rest instant) |
| 2 | Search icon tap | AppBar → TextField morph: width expansion + opacity crossfade | 300ms | easeInOut | Use `AnimatedSwitcher` with `SizeTransition` |
| 3 | Search dismiss | TextField → AppBar morph: width contraction + opacity | 200ms | easeIn | Faster exit for snappy feel |
| 4 | Filter chip tap | Container bg + border color + text color | 200ms | easeInOut | `AnimatedContainer` — no layout shift |
| 5 | Filter sheet open | BottomSheet: translateY(100%→0) + opacity | 300ms | easeOutCubic | Standard `showModalBottomSheet` with custom animation |
| 6 | Filter sheet close | translateY(0→100%) | 250ms | easeIn | Slightly faster close |
| 7 | Swipe action reveal | Background color + icon opacity | — (gesture-driven) | linear | Use `Dismissible` with `background`/`secondaryBackground` |
| 8 | Multi-select entry | Leading checkbox: scale(0→1) + opacity | 200ms | easeOutBack | Cards already rendered; checkbox animates in |
| 9 | Multi-select bottom bar | translateY(100→0) + shadow | 250ms | easeOutCubic | `AnimatedPositioned` or `SlideTransition` |
| 10 | Card delete (swipe) | Card height → 0 + opacity → 0 | 300ms | easeInOut | `AnimatedList.removeItem` for smooth collapse |
| 11 | Recent carousel scroll | Standard `ListView` physics | — | — | `BouncingScrollPhysics` for iOS feel |
| 12 | Pull-to-refresh | Standard `RefreshIndicator` spring | — | — | Gold accent color indicator |
| 13 | Skeleton shimmer | Gradient position loop | 1200ms | linear | `shimmer` package, same as search feature |
| 14 | Card press state | Scale 1.0→0.98 | 100ms | easeOut | Via `AnimatedScale` or `Transform.scale` in `onTapDown`/`onTapUp` |

**Performance guardrails**:
- All cards wrapped in `RepaintBoundary`
- Skeleton shimmer: max 6 items rendered
- `ListView.builder` for all lists (never `Column` + `.map()`)
- `cacheExtent: 400.0` on main list
- Animations use `vsync` from `TickerProviderStateMixin`
- No `Opacity` widget on large subtrees — use `FadeTransition` with `AnimationController`

---

## G) Backend Contract Improvements

### G1. Replace "-" Placeholders with `null`, Omit Irrelevant Fields

**Current problem**: Every bookmark returns ALL fields with "-" for non-applicable ones:
```json
{
  "type": "POEM",
  "coupletFirstVerse": "-",
  "coupletSecondVerse": "-",
  "parentPoemTitle": "-",
  "imageUrl": "-",
  "thumbnailUrl": "-",
  "templateName": "-"
}
```

**Proposed**: Return only fields relevant to the type. Use `null` (not "-") for genuinely missing optional values:

```json
// POEM bookmark — omit couplet/image fields entirely
{
  "type": "POEM",
  "bookmarkId": "uuid",
  "contentId": "uuid",
  "languageCode": "ur",
  "bookmarkedAt": "2024-01-15T10:30:00Z",
  "notes": null,
  "poemTitle": "غزل کا عنوان",
  "poetName": "شاعر کا نام",
  "poetId": "uuid"
}

// COUPLET bookmark — omit poem/image fields
{
  "type": "COUPLET",
  "bookmarkId": "uuid",
  "contentId": "uuid",
  "languageCode": "ur",
  "bookmarkedAt": "2024-01-15T10:30:00Z",
  "notes": null,
  "coupletFirstVerse": "پہلا مصرع",
  "coupletSecondVerse": "دوسرا مصرع",
  "parentPoemTitle": "غزل کا عنوان",
  "parentPoemId": "uuid",
  "poetName": "شاعر کا نام",
  "poetId": "uuid"
}
```

**Client impact**: Remove the `cleanString("-")` hack in `UnifiedBookmark.fromJson`. Use standard null handling.

### G2. Add Display-Ready Fields

Add pre-computed display strings so the client doesn't need to guess:

```json
{
  "display": {
    "title": "غزل کا عنوان",              // Best available title for this bookmark
    "titleScript": "ur",                  // Script of the title (ur/en/hi)
    "subtitle": "شاعر کا نام",             // Poet name or template name
    "excerpt": "پہلا مصرع یہاں لکھا...",    // First 80 chars of content (for search preview)
    "contentTypeName": "غزل",              // Urdu name of content type (غزل, نظم, رباعی...)
    "contentTypeNameEn": "Ghazal"          // English fallback
  }
}
```

**Priority**: HIGH for `title` and `subtitle`. NICE-TO-HAVE for `excerpt` and `contentTypeName`.

### G3. Add Poet Profile Image URL

```json
{
  "poetProfileImageUrl": "https://cdn.../poet-avatar.jpg"
}
```

**Impact**: Enables poet avatar in cards (currently no avatar shown in bookmarks, unlike search results). Significantly improves scanability for users who recognize poets visually.

### G4. Add Content Subtype

```json
{
  "contentType": "POEM",
  "contentSubType": "GHAZAL"   // GHAZAL, NAZM, RUBAI, MARSIYA, QITA, etc.
}
```

**Impact**: Enables more specific type chips ("غزل" instead of generic "Poem"). Helps users distinguish between poem types in their bookmarks.

### G5. Stats Response — Add Language Breakdown Per Type

**Current** `GET /api/bookmarks/stats`:
```json
{
  "totalBookmarks": 18,
  "poemCount": 12,
  "coupletCount": 5,
  "imageCount": 1
}
```

**Proposed** — add counts for filter chip badges:
```json
{
  "totalBookmarks": 18,
  "poemCount": 12,
  "coupletCount": 5,
  "imageCount": 1,
  "byLanguage": {
    "ur": 14,
    "en": 3,
    "hi": 1
  }
}
```

### G6. Pagination — Keep page/size, Add Timestamp Cursor (Optional)

Current page/size pagination is fine for typical bookmark collections (<500 items). For future-proofing:

```json
{
  "data": {
    "content": [...],
    "cursor": "2024-01-15T10:30:00Z",  // bookmarkedAt of last item
    "hasNext": true                     // simpler than computing totalPages
  }
}
```

**Priority**: LOW. Current page-based approach works. Only implement if bookmark counts per user exceed 500+ and page-skip becomes slow.

### G7. Ensure Boolean Consistency

All boolean fields must be explicit `true`/`false`, never `null`:
- `first`, `last`, `empty` — already correct
- Any future `isLiked`, `isBookmarkedByCurrentUser` — enforce non-null

### G8. New Endpoint — Update Bookmark Notes

```
PATCH /api/bookmarks/{type}/{bookmarkId}/notes
Body: { "notes": "string (max 200 chars)" }
Response: { "success": true, "data": { ...updated bookmark } }
```

---

## H) Acceptance Checklist (10/10)

### Performance

| # | Criterion | Target | How to Measure |
|---|-----------|--------|----------------|
| 1 | Time to first content (cached) | < 100ms | Screen mount → first card painted (from SharedPrefs/memory cache) |
| 2 | Time to first content (network) | < 800ms | Screen mount → first card painted (API response applied) |
| 3 | Scroll FPS (50+ items) | 60fps sustained | Flutter DevTools timeline, no frames >16ms |
| 4 | Skeleton-to-content swap | < 50ms | Shimmer visible → real data renders (after API response received) |
| 5 | Search debounce + response | < 900ms total | Keystroke → results painted (400ms debounce + <500ms API) |
| 6 | Infinite scroll load-more | Shimmer appears within 1 frame of trigger | No blank gap at bottom while loading |

### Layout & RTL

| # | Criterion | Target |
|---|-----------|--------|
| 7 | Urdu card full RTL flow | Title, poet, arrow icon, swipe directions all mirror correctly |
| 8 | English card full LTR flow | Same card layout but LTR when `languageCode == 'en'` |
| 9 | Mixed-language list | Adjacent UR and EN cards render independently correct, no layout bleed |
| 10 | Nastaliq line height | No clipping on descenders (ی, ے, ر, ں) — verified at 15px, 14px, 13px sizes |
| 11 | All UI labels in Urdu mode | Zero English text in headers, filters, empty states, snackbars when app language is Urdu |

### Interaction

| # | Criterion | Target |
|---|-----------|--------|
| 12 | Tap target size | All interactive elements ≥ 44x44pt (WCAG 2.5.8) |
| 13 | Tap feedback | InkWell ripple or scale animation on every tappable card, visible within 1 frame |
| 14 | Swipe-to-delete | Confirm via undo snackbar, NOT a blocking dialog. Undo window: 5 seconds |
| 15 | Multi-select entry | Long-press → haptic → mode change in < 200ms |
| 16 | Pull-to-refresh | Indicator visible, data refreshes, stale indicator clears |

### Visual & Contrast

| # | Criterion | Target |
|---|-----------|--------|
| 17 | Text contrast ratio | Primary text ≥ 7:1 (WCAG AAA), secondary ≥ 4.5:1 (WCAG AA) |
| 18 | Dark mode parity | Every color from AppColors, no hardcoded values |
| 19 | Empty state | Illustration + Urdu message + actionable CTA button present |
| 20 | Error state | Urdu error message + retry button + no raw exception text |

### Search

| # | Criterion | Target |
|---|-----------|--------|
| 21 | Search highlight accuracy | Query substring highlighted in title and poet name with correct normalization |
| 22 | Search empty state | Shows query-specific "no results" message in Urdu |
| 23 | Search + filter combo | Searching while a type filter is active returns correctly filtered results |
| 24 | Search clear | "✕" returns to normal mode with original unfiltered data visible |

### Data Integrity

| # | Criterion | Target |
|---|-----------|--------|
| 25 | Pagination no duplicates | Scrolling through all pages produces zero duplicate `bookmarkId` values |
| 26 | Delete reflects immediately | After swipe-delete, item removed from list without full refetch |
| 27 | Filter counts match content | Badge count on "غزلیں (12)" matches actual number of poem bookmarks |
| 28 | Offline graceful | If API fails, show cached data (if available) + subtle error banner, not blank screen |

---

## Implementation Priority

| Priority | Items | Effort |
|----------|-------|--------|
| **P0 — Must Have** | Unified screen (replace both), compact card redesign, swipe-to-delete, Urdu labels, search debounce + highlight, filter consolidation (remove language row) | ~3-4 days |
| **P1 — Should Have** | Multi-select mode, empty state with illustration + CTA, horizontal "Recent" carousel, press feedback (InkWell), skeleton loading | ~2 days |
| **P2 — Nice to Have** | Notes feature, backend contract changes (G1-G5), stagger animations, cache-first strategy | ~2-3 days |
| **P3 — Future** | Cursor pagination, folders/tags, offline caching, related bookmarks | Backlog |
