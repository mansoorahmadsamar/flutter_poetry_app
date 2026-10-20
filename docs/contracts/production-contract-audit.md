# App ↔ production backend contract audit (T-181, 2026-10-20)

Every app model that parses a backend response was compared with the DTO that **production** (backend `origin/main`)
returns. A row lists a field the app treated as required (a non-nullable cast, `required` in freezed, used as an id
or URL) that production can omit, send as `null`, or send as `"-"`. The app must work against both `main` (released)
and `develop` (not yet deployed).

## How production serialises absent values

`config/JacksonConfig.java` (`main`) applies to every bean **without** a class-level `@JsonInclude(NON_NULL)`:

| Java value | JSON sent |
|---|---|
| `null` `String` | `"-"` — not null; it shows as a dash or becomes a bad id/URL if read as present |
| `null` `Integer` / `Long` | `0` |
| any other `null` (`Boolean`, `Double`/`Float`, `List`, `Map`, enum, nested object, date) | `null` |
| field the DTO doesn't declare | absent |
| class with `@JsonInclude(NON_NULL)` | null fields omitted |
| hand-built `Map<String, Object>` (e.g. `/api/auth/me`) | raw `null`, no `"-"` |

Rule for app models: optional text uses `@PlaceholderStringConverter()` (`core/utils/api_placeholder.dart`);
booleans, enums-as-strings and lists get a default; ids are checked with `presentOrNull` before building a route.

## Findings

Status: **Fixed** = changed on `fix/app-qa-2026-10-20` with fixture tests; **Open** = not changed (reason given).
"UNVERIFIED" = depends on production rows that were not queried.

| # | App model / reader | Endpoint | Backend DTO (main) | Field | App treated as | Production can send | Effect before | Reachable | Status |
|---|---|---|---|---|---|---|---|---|---|
| 1 | `CoupletDetailResponse` (`poets/models/couplet_model.dart`) | `GET /api/hashtags/{slug}/couplets` | `Page<CoupletDto>` | `poemPublicId`, `poetPublicId`, `poetName`; `coupletType` (enum) | `required String` | absent (not in the DTO on main); `coupletType` null; develop sends `"-"` when unknown | whole Couplets tab fails ("لوڈ نہیں ہو سکا") | Hashtag screen | **Fixed** (T-177) |
| 2 | `UserModel` (`core/models/user_model.dart`) | `GET /api/auth/me` | hand-built `HashMap` (`AuthController`) | `fullName`, `username`, `provider`, `isActive` | `required String` / `bool` | `null` (nullable columns; Apple "hide my name" gives no name) | profile header shows the error state | Profile tab | **Fixed** (how many users have a NULL name: UNVERIFIED) |
| 3 | `poem.reactions['userReaction']` (poem detail, reading card, couplet buttons); `ReactionSummary`, `ReactionResponse` | `GET /api/poems/{id}`, react/unreact | `ReactionSummaryDto` (String `userReaction`) | `userReaction` | `!= null` ⇒ reacted | `"-"` when the user has not reacted (seen in the real search fixture) | every poem looks reacted, "Your reaction: -" | Poem detail | **Fixed** (`userReactionIn`) |
| 4 | `PoemModel` (`poets/models/poem_model.dart`) | `GET /api/poems/{id}`, like/bookmark, hashtag poems | `PoemDetailResponse` (`contentType` enum, passed raw) | `contentType` | `required String` | `null` if `poems.content_type` is NULL | poem detail fails | Poem detail | **Fixed** (defaults to `TEXT`; NULL rows UNVERIFIED) |
| 5 | `AutocompleteTag` (also `UnifiedSearchResponse.tags`) | `GET /api/search` | `TagDto` (`tagType` enum) | `tagType` | `required String` | `null` | the whole search response fails | Search | **Fixed** (T-181/T-182) |
| 6 | `AutocompletePoem`, `AutocompletePoet` | `GET /api/search/autocomplete` | `PoemSuggestion`, `PoetSuggestion` | `poetName`, `poetPublicId`, `poetryType`, `era`, `profileImageUrl` | `required String` / shown raw | `"-"` | `"-"` shown as a subtitle | Search suggestions | **Fixed** (T-182) |
| 7 | `PoetProfileModel` (`poets/models/poet_profile_model.dart`) | `GET /api/poets/{id}/profile` | `PoetProfileResponse` | `isFeatured`, `isTrending`, `isVerified` | `required bool` | `null` (nullable `Boolean` columns) | poet screen fails | Poet detail | **Fixed** (default false; NULL rows UNVERIFIED) |
| 8 | `PoetProfileModel` | same | same | `shortBio`, `era`, `primaryLanguageName`, `profileImageUrl`, … | shown raw / used as URL | `"-"` | "-" bio/chip; a "-" image skipped the gallery fallback | Poet detail | **Fixed** |
| 9 | `PoetImageModel` (gallery) | `/api/poets/{id}/profile`, `/gallery` | `PoetImageDto` | `isProfileImage`, `imageType`, `altText` | `required` | `null` if an admin request sent null | poet profile fails | Poet detail | **Fixed** (defaults) |
| 10 | hashtag image tile (`hashtags/widgets/hashtag_images_tab.dart`) | `GET /api/hashtags/{slug}/images` | `PoetImageDto` | `thumbnailUrl` | `thumbnailUrl ?? imageUrl` | `"-"` (so `??` never falls back) | broken tile | Hashtag screen | **Fixed** (`hashtagImageUrl`) |
| 11 | Discover rail tap (`discover/screens/discover_screen.dart`) | `/api/guest/discover`, `/api/discover` | `GuestCoupletDto` / `ContentCardDto` | id used for COUPLET/VERSE cards | `/main/poems/<card id>` (the couplet id) | — (app bug; `poemPublicId` was already parsed) | opens a non-existent poem | Discover | **Fixed** (`openDiscoverCard`) |
| 12 | `CoupletSearchResult` | `GET /api/search` couplets | `CoupletDto` (no poem/poet on main) | `poemPublicId`, `poetName` | nullable | absent | couplet results not tappable/unattributed | Search | Open — already handled (no tap handler without a poem id); fills in when backend develop (T-012) ships |
| 13 | `PoetModel` | poet lists, `/api/search` poets, hashtag poets | `PoetSummaryResponse` | `shortBio`, `birthYear` | `required` | `"-"` / `0` | "-" bio; hashtag poets tab shows "present" for `deathYear` 0 | Poets, hashtag | Open (P2, display only) |
| 14 | `LanguageModel` | `GET /api/languages/active` | hand-built map (`LanguageController`) | `direction` | `required String` | `null` if the column is NULL | language list fails | Profile language picker | Open (P3, NULL rows UNVERIFIED) |
| 15 | `PoetModel` via `PoetService.getFollowingPoets` | `GET /api/users/me/following` | `FollowedPoetResponse` (different shape) | `publicId`, `name`, … | `required` | absent | crash | No (`followingPoetsProvider` has no consumer) | Open (P3, dead) |
| 16 | `BookmarkedCoupletResponse` search | `/api/users/me/couplets/bookmarked/search` | — (endpoint not on main, 404) | — | — | 404 | broken search | No (`/bookmarks/couplets` has no caller) | Open (P3, dead) |
| 17 | `PaginatedResponse.pageable` | `/api/users/me/bookmarks`, `/likes` | `Page.empty()` when the user is not found | `pageable` | `Map` | the string `"INSTANCE"` | crash | Edge case only | Open (P3) |

Checked and safe (no row): `/api/feed` and `/api/discover` (+ guest) — per-item try/catch, hand parsing and `"-"`
guards; `UnifiedBookmark` (hand-parsed; DTO is `NON_NULL`); search unified/trending/related/recommendations other
than rows 5–6 (String fields become `"-"`, which doesn't crash); guest poems/poets/poem detail; poem couplets
(`verses` always a list, `coupletType` NOT NULL in the DB); `/api/reactions/types`; `/api/app-content`; creator and
image-poetry DTOs; Spring `Page` keys.

Tests for the fixed rows: `test/features/hashtags/`, `test/core/models/user_model_test.dart`,
`test/features/main/tabs/profile_tab_test.dart`, `test/features/engagement/models/reaction_models_test.dart`,
`test/features/main/tabs/poets/models/poet_profile_model_test.dart`,
`test/features/search/models/unified_search_tags_test.dart`,
`test/features/search/services/search_service_autocomplete_test.dart`,
`test/features/discover/utils/discover_navigation_test.dart`, `test/features/hashtags/widgets/hashtag_images_tab_test.dart`.
