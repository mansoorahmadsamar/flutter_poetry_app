<!-- Copied read-only from the backend repo: poetry-backend `docs/contracts/guest-poets.md` (branch `fix/search-2`, 2026-10-19). The backend copy is the source of truth; update this one when it changes. App implementation: `GuestService.getFilteredPoets` + the guest branches of `PoetService.getFeaturedPoets / getTrendingPoets / getPoetsByEra / getPoetsByGender`. Until the endpoints are deployed, a 404/401/405 falls back to `GET /api/guest/poets`. -->

# Contract — guest poet filters (T-045)

Status: implemented on backend branch `fix/search-2` (not deployed). The app side is built from this file.
Code: `controllers/GuestPoetFiltersController.java`. Tests: `GuestPoetFiltersControllerTest` (unit),
`GuestPoetFiltersIT` (full security chain + Postgres, pins the JSON below).

## Why

The Poets tab offers featured / trending / era / gender filters. Signed-in users get them from
`/api/poets/featured`, `/api/poets/trending`, `/api/poets/era/{era}` and `/api/poets/gender/{gender}`.
Guests had no equivalent, so `PoetService.getFeaturedPoets / getTrendingPoets / getPoetsByEra /
getPoetsByGender` in the app (`lib/features/main/tabs/poets/services/poet_service.dart`) all fell back
to the unfiltered `GET /api/guest/poets`, and the discovery screen hid the era/gender sections for guests.

## Endpoints

Same paths and values as the signed-in endpoints, under `/api/guest/poets`. All are `GET`, need **no**
`Authorization` header (a stale or invalid token is ignored), and are rate-limited with the rest of
`/api/guest/**`.

| App method (guest branch) | Signed-in endpoint today | Guest endpoint |
|---|---|---|
| `getFeaturedPoets` | `GET /api/poets/featured` | `GET /api/guest/poets/featured` |
| `getTrendingPoets` | `GET /api/poets/trending` | `GET /api/guest/poets/trending` |
| `getPoetsByEra(era)` | `GET /api/poets/era/{era}` | `GET /api/guest/poets/era/{era}` |
| `getPoetsByGender(gender)` | `GET /api/poets/gender/{gender}` | `GET /api/guest/poets/gender/{gender}` |

`getAllPoets`, `getTopPoetsByViews` and `getPoetsByTag` are **not** part of this change; for guests they
keep using `GET /api/guest/poets`.

### Path values

| Parameter | Allowed values | Notes |
|---|---|---|
| `{era}` | `CLASSICAL`, `MODERN`, `CONTEMPORARY`, `EMERGING` | Case-insensitive (`classical` works). Send the upper-case name, as the app already does. |
| `{gender}` | `MALE`, `FEMALE`, `OTHER` | Case-insensitive. The "Women" chip is `FEMALE`. |

### Query parameters (same as `GET /api/guest/poets`)

| Name | Default | Rule |
|---|---|---|
| `lang` | `ur` | `ur`, `en` or `hi`; anything else is treated as `ur`. Selects the poet name/bio language. |
| `page` | `0` | Clamped to `0..4` (at most 5 pages). |
| `size` | `10` | Clamped to `1..20`. |

Ordering: most viewed first (`viewCount` desc), ties by internal id, so pages are stable. (The
signed-in endpoints have no defined order.) Soft-deleted poets are never returned.

## Response

`200`, the standard envelope with a Spring `Page` of `GuestPoetSummaryDto` — byte-for-byte the shape of
`GET /api/guest/poets`, so the app's existing `GuestService._pageFromEnvelope` + `PoetModel.fromJson`
parse it unchanged.

```json
{
  "success": true,
  "message": "Featured poets retrieved",
  "data": {
    "content": [
      {
        "publicId": "0d24be0d-4a51-4d33-8a16-4c3809c71155",
        "name": "Mirza Ghalib",
        "shortBio": "-",
        "profileImageUrl": "https://…/ghalib.jpg",
        "birthYear": 1797,
        "deathYear": 1869,
        "era": "CLASSICAL",
        "country": "-",
        "countryFlag": "-",
        "poemCount": 7
      }
    ],
    "totalElements": 2,
    "totalPages": 1,
    "number": 0,
    "size": 10,
    "first": true,
    "last": true,
    "numberOfElements": 2,
    "empty": false,
    "pageable": { "…": "as on every Spring page response" },
    "sort": { "…": "…" }
  }
}
```

Field rules (from the app-wide `JacksonConfig`, unchanged):

| Field | Type | When missing |
|---|---|---|
| `publicId` | string | never missing |
| `name` | string | `"N/A"` when the poet has no name in `lang` |
| `shortBio`, `profileImageUrl`, `country`, `countryFlag` | string | `"-"` (never `null`) |
| `birthYear`, `deathYear`, `poemCount` | integer | `0` (unknown years are `0`, never `null`) |
| `era` | string enum | `null` when the poet has no era |

`totalElements` / `totalPages` count every matching poet, but only pages `0..4` can be fetched.
**App rule:** treat a page as the last one when `last == true` **or** `number >= 4`; requesting page 5+
returns page 4 again (the server clamps), which would duplicate items.

## Errors

| Case | Status | Body |
|---|---|---|
| Unknown `{era}` / `{gender}` | `400` | `{"success": false, "message": "Unknown era 'ancient'. Allowed: CLASSICAL, MODERN, CONTEMPORARY, EMERGING"}` (same for gender) |
| Rate limit (60/min, 1000/h per IP, all `/api/guest/**`) | `429` | `Retry-After` header; the app's `GuestRateLimitException` already handles it |
| Any non-`GET` method | `401` | — |

## Compatibility

Additive: four new paths, no change to any existing endpoint or DTO. Released app versions keep calling
`GET /api/guest/poets` and see no difference. The new app version should call these paths only in the
`_isGuest` branches of the four methods above, and can then show the era/gender sections to guests in
`poets_discovery_provider.dart`.
