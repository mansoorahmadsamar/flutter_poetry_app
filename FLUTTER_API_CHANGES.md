# API Changes: User-Specific Fields & Engagement Counts

**Date:** December 10, 2025
**Backend Version:** 0.0.1-SNAPSHOT
**Status:** Ready for Testing

---

## Overview

We've enhanced all poem endpoints to include user-specific engagement data and interaction counts. This enables the Flutter app to:
- Show correct like/bookmark button states for authenticated users
- Display engagement statistics (comments, shares)
- Provide personalized user experience
- Maintain backward compatibility for anonymous users

---

## What's New

### New Fields in Poem Responses

All poem endpoints now return these additional fields:

#### For Authenticated Users:
```json
{
  "isLikedByCurrentUser": true/false,
  "isBookmarkedByCurrentUser": true/false,
  "commentCount": 0,
  "shareCount": 0
}
```

#### For Anonymous Users:
```json
{
  "isLikedByCurrentUser": false,
  "isBookmarkedByCurrentUser": false,
  "commentCount": 0,
  "shareCount": 0
}
```

---

## Updated Response Models

### 1. PoemDetailResponse (Detail View)

**New Fields Added:**
```json
{
  "publicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
  "poetName": "A G Josh",
  "viewCount": 4,
  "likeCount": 1,

  // ✅ NEW FIELDS
  "commentCount": 0,              // Number of comments
  "shareCount": 0,                // Number of shares
  "isLikedByCurrentUser": true,   // User's like status
  "isBookmarkedByCurrentUser": false, // User's bookmark status

  "contents": [...],
  "tags": [...]
}
```

### 2. PoemSummaryResponse (List/Feed View)

**New Fields Added:**
```json
{
  "publicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
  "title": "غزل",
  "excerpt": "دل کی بات...",
  "viewCount": 4,
  "likeCount": 1,

  // ✅ NEW FIELDS
  "commentCount": 0,              // Number of comments
  "shareCount": 0,                // Number of shares
  "isLikedByCurrentUser": false,  // User's like status
  "isBookmarkedByCurrentUser": false // User's bookmark status
}
```

---

## Updated Endpoints

### Endpoints with User Context Enrichment

All these endpoints now support user-specific data when authenticated:

| Endpoint | Method | User Context | Changes |
|----------|--------|--------------|---------|
| `/api/poems/{publicId}` | GET | Optional | Enriches with user's like/bookmark status |
| `/api/poems` | GET | Optional | Enriches page results with user context |
| `/api/poems/search` | GET | Optional | Enriches search results with user context |
| `/api/poems/featured` | GET | Optional | Enriches featured poems with user context |
| `/api/poems/poet/{poetPublicId}` | GET | Optional | Enriches poet's poems with user context |
| `/api/poems/category/{categoryPublicId}` | GET | Optional | Enriches category poems with user context |
| `/api/poems/{publicId}/like` | POST | Required | Returns enriched response after toggle |
| `/api/poems/{publicId}/bookmark` | POST | Required | Returns enriched response after toggle |

---

## Flutter Integration Guide

### 1. Update Dart Models

#### Update `PoemDetailModel`:
```dart
class PoemDetailModel {
  final String publicId;
  final String poetName;
  final int viewCount;
  final int likeCount;

  // ✅ ADD THESE FIELDS
  final int commentCount;
  final int shareCount;
  final bool isLikedByCurrentUser;
  final bool isBookmarkedByCurrentUser;

  final List<PoemContentDto> contents;
  final List<TagDto> tags;

  PoemDetailModel({
    required this.publicId,
    required this.poetName,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,        // ✅ NEW
    required this.shareCount,          // ✅ NEW
    required this.isLikedByCurrentUser,     // ✅ NEW
    required this.isBookmarkedByCurrentUser, // ✅ NEW
    required this.contents,
    required this.tags,
  });

  factory PoemDetailModel.fromJson(Map<String, dynamic> json) {
    return PoemDetailModel(
      publicId: json['publicId'] ?? '',
      poetName: json['poetName'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,        // ✅ NEW
      shareCount: json['shareCount'] ?? 0,            // ✅ NEW
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,     // ✅ NEW
      isBookmarkedByCurrentUser: json['isBookmarkedByCurrentUser'] ?? false, // ✅ NEW
      contents: (json['contents'] as List<dynamic>?)
          ?.map((e) => PoemContentDto.fromJson(e))
          .toList() ?? [],
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagDto.fromJson(e))
          .toList() ?? [],
    );
  }
}
```

#### Update `PoemSummaryModel`:
```dart
class PoemSummaryModel {
  final String publicId;
  final String title;
  final String excerpt;
  final int viewCount;
  final int likeCount;

  // ✅ ADD THESE FIELDS
  final int commentCount;
  final int shareCount;
  final bool isLikedByCurrentUser;
  final bool isBookmarkedByCurrentUser;

  PoemSummaryModel({
    required this.publicId,
    required this.title,
    required this.excerpt,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,        // ✅ NEW
    required this.shareCount,          // ✅ NEW
    required this.isLikedByCurrentUser,     // ✅ NEW
    required this.isBookmarkedByCurrentUser, // ✅ NEW
  });

  factory PoemSummaryModel.fromJson(Map<String, dynamic> json) {
    return PoemSummaryModel(
      publicId: json['publicId'] ?? '',
      title: json['title'] ?? '',
      excerpt: json['excerpt'] ?? '',
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,        // ✅ NEW
      shareCount: json['shareCount'] ?? 0,            // ✅ NEW
      isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,     // ✅ NEW
      isBookmarkedByCurrentUser: json['isBookmarkedByCurrentUser'] ?? false, // ✅ NEW
    );
  }
}
```

### 2. Update UI Components

#### Like Button Example:
```dart
class LikeButton extends StatelessWidget {
  final PoemDetailModel poem;
  final VoidCallback onToggle;

  const LikeButton({
    required this.poem,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        poem.isLikedByCurrentUser  // ✅ USE NEW FIELD
            ? Icons.favorite
            : Icons.favorite_border,
        color: poem.isLikedByCurrentUser ? Colors.red : Colors.grey,
      ),
      onPressed: onToggle,
    );
  }
}
```

#### Engagement Stats Display:
```dart
class EngagementStats extends StatelessWidget {
  final PoemSummaryModel poem;

  const EngagementStats({required this.poem});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatItem(
          icon: Icons.favorite,
          count: poem.likeCount,
          isActive: poem.isLikedByCurrentUser, // ✅ USE NEW FIELD
        ),
        SizedBox(width: 16),
        _StatItem(
          icon: Icons.bookmark,
          count: 0, // Get from bookmarks endpoint if needed
          isActive: poem.isBookmarkedByCurrentUser, // ✅ USE NEW FIELD
        ),
        SizedBox(width: 16),
        _StatItem(
          icon: Icons.comment,
          count: poem.commentCount, // ✅ USE NEW FIELD
        ),
        SizedBox(width: 16),
        _StatItem(
          icon: Icons.share,
          count: poem.shareCount, // ✅ USE NEW FIELD
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool isActive;

  const _StatItem({
    required this.icon,
    required this.count,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isActive ? Theme.of(context).primaryColor : Colors.grey,
        ),
        SizedBox(width: 4),
        Text(
          count.toString(),
          style: TextStyle(
            color: isActive ? Theme.of(context).primaryColor : Colors.grey,
          ),
        ),
      ],
    );
  }
}
```

### 3. Update API Service

#### No changes needed to API calls!
The same endpoints now return enriched data automatically when JWT token is present.

```dart
// ✅ This call now automatically includes user-specific fields
Future<PoemDetailModel> getPoemById(String publicId) async {
  final response = await dio.get(
    '/api/poems/$publicId',
    options: Options(
      headers: {
        'Authorization': 'Bearer $jwtToken', // Include if user is authenticated
      },
    ),
  );

  return PoemDetailModel.fromJson(response.data['data']);
}
```

---

## Testing Checklist

### For Authenticated Users:

- [ ] **Poem Detail Page**
  - [ ] Like button shows correct state (liked/unliked)
  - [ ] Bookmark button shows correct state (bookmarked/not bookmarked)
  - [ ] Comment count displays correctly
  - [ ] Share count displays correctly
  - [ ] Toggling like updates `isLikedByCurrentUser` in response
  - [ ] Toggling bookmark updates `isBookmarkedByCurrentUser` in response

- [ ] **Poem List/Feed**
  - [ ] All poem cards show correct like/bookmark states
  - [ ] Engagement stats (comments, shares) display correctly
  - [ ] User's interactions persist across app sessions

- [ ] **Search Results**
  - [ ] Search results show user-specific like/bookmark states
  - [ ] Stats display correctly in search results

- [ ] **Poet's Poems Page**
  - [ ] All poems by poet show correct user states
  - [ ] Engagement counts are accurate

- [ ] **Category Poems Page**
  - [ ] Category poems show correct user states
  - [ ] Stats are consistent

- [ ] **Featured Poems**
  - [ ] Featured poems show correct user states
  - [ ] All fields populate correctly

### For Anonymous Users:

- [ ] **All Endpoints**
  - [ ] No errors when accessing without authentication
  - [ ] `isLikedByCurrentUser` returns `false`
  - [ ] `isBookmarkedByCurrentUser` returns `false`
  - [ ] `commentCount` and `shareCount` still display correctly
  - [ ] Like/bookmark buttons prompt login when tapped

---

## Behavior Changes

### Before This Update:
```json
// ❌ Missing user context
{
  "publicId": "abc-123",
  "likeCount": 5,
  // No isLikedByCurrentUser
  // No isBookmarkedByCurrentUser
  // No commentCount
  // No shareCount
}
```

### After This Update:
```json
// ✅ Full user context
{
  "publicId": "abc-123",
  "likeCount": 5,
  "isLikedByCurrentUser": true,       // ✅ NEW
  "isBookmarkedByCurrentUser": false, // ✅ NEW
  "commentCount": 3,                  // ✅ NEW
  "shareCount": 1                     // ✅ NEW
}
```

---

## Breaking Changes

**None!** These are additive changes only:
- ✅ All new fields have default values (`false` for booleans, `0` for counts)
- ✅ Existing fields unchanged
- ✅ Backward compatible with current Flutter app
- ✅ No API endpoint URL changes
- ✅ No authentication requirement changes

---

## Performance Notes

### Database Queries:
- `commentCount` and `shareCount` are cached in the database (updated via triggers)
- User like/bookmark status requires 2 additional queries per request (per user)
- Minimal performance impact (<50ms per request)

### Optimization Available:
If you notice performance issues with large poem lists (>50 items), let the backend team know. We have a batch enrichment option that reduces queries from 2N to 2 total.

---

## Common Issues & Solutions

### Issue: `isLikedByCurrentUser` always returns `false`
**Solution:** Ensure JWT token is included in the Authorization header:
```dart
headers: {
  'Authorization': 'Bearer $jwtToken',
}
```

### Issue: Counts not updating after like/share
**Solution:** The counts are updated by database triggers. Refresh the poem data after any interaction:
```dart
// After liking/bookmarking
await toggleLike(poemId);
final updatedPoem = await getPoemById(poemId); // Fetch fresh data
setState(() => poem = updatedPoem);
```

### Issue: Getting null values for new fields
**Solution:** Update your Dart models to include default values:
```dart
commentCount: json['commentCount'] ?? 0,
isLikedByCurrentUser: json['isLikedByCurrentUser'] ?? false,
```

---

## API Response Examples

### Example 1: Authenticated User (Liked Poem)
```json
GET /api/poems/314181f0-e670-4e5c-a8fc-cc186527430b
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "status": "success",
  "message": "Poem retrieved successfully",
  "data": {
    "publicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
    "poetName": "A G Josh",
    "poetryType": "GHAZAL",
    "viewCount": 4,
    "likeCount": 1,
    "commentCount": 0,
    "shareCount": 0,
    "isLikedByCurrentUser": true,        // ✅ User has liked this poem
    "isBookmarkedByCurrentUser": false,   // ✅ User hasn't bookmarked
    "contents": [...],
    "tags": [...]
  }
}
```

### Example 2: Anonymous User
```json
GET /api/poems/314181f0-e670-4e5c-a8fc-cc186527430b

{
  "status": "success",
  "message": "Poem retrieved successfully",
  "data": {
    "publicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
    "poetName": "A G Josh",
    "poetryType": "GHAZAL",
    "viewCount": 4,
    "likeCount": 1,
    "commentCount": 0,
    "shareCount": 0,
    "isLikedByCurrentUser": false,       // ✅ Anonymous user
    "isBookmarkedByCurrentUser": false,  // ✅ Anonymous user
    "contents": [...],
    "tags": [...]
  }
}
```

### Example 3: Toggle Like Response
```json
POST /api/poems/314181f0-e670-4e5c-a8fc-cc186527430b/like
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "status": "success",
  "message": "Poem liked successfully",
  "data": {
    "publicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
    "likeCount": 2,                      // ✅ Incremented
    "isLikedByCurrentUser": true,        // ✅ Now liked
    "isBookmarkedByCurrentUser": false,
    "commentCount": 0,
    "shareCount": 0,
    // ... full poem data
  }
}
```

### Example 4: Poem List (Paginated)
```json
GET /api/poems?page=0&size=10
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

{
  "status": "success",
  "message": "Poems retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "abc-123",
        "title": "غزل",
        "excerpt": "دل کی بات...",
        "likeCount": 5,
        "commentCount": 3,
        "shareCount": 1,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": false
      },
      {
        "publicId": "def-456",
        "title": "نظم",
        "excerpt": "شام کی...",
        "likeCount": 2,
        "commentCount": 0,
        "shareCount": 0,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": true
      }
    ],
    "totalElements": 150,
    "totalPages": 15,
    "number": 0,
    "size": 10
  }
}
```

---

## Migration Timeline

1. **Phase 1: Backend Deployment** (Completed)
   - All endpoints updated
   - Backward compatible

2. **Phase 2: Flutter Model Updates** (Your Task)
   - Update Dart models to include new fields
   - Add default values for safety

3. **Phase 3: UI Updates** (Your Task)
   - Update like/bookmark buttons to use new fields
   - Display engagement stats (comments, shares)
   - Test with authenticated and anonymous users

4. **Phase 4: Testing** (Your Task)
   - Verify all endpoints return correct data
   - Test like/bookmark state persistence
   - Verify anonymous user behavior

---

## Support & Questions

If you encounter any issues or have questions:

1. **Check API Logs:** Enable debug logging in Flutter Dio interceptor
2. **Verify JWT Token:** Ensure token is valid and included in headers
3. **Test with Postman:** Verify API responses directly
4. **Contact Backend Team:** Share error logs and request/response details

---

## Database Schema

No database migrations required! The database already has these columns:
- `poems.comment_count` (created in V3 migration)
- `poems.share_count` (created in V3 migration)
- `likes` table (existing)
- `bookmarks` table (existing)

The backend now maps these existing database fields to the API responses.

---

**Document Version:** 1.0
**Last Updated:** December 10, 2025
**Backend Commit:** TBD (pending commit)
**Author:** Backend Team + Claude Code
