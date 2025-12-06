# Bookmarks/Likes Response Structure Fixed

**Date:** December 6, 2025
**Status:** ✅ FIXED - Proper DTOs now return full poem data

---

## Problem Identified

The Flutter team correctly identified that the `/api/users/me/bookmarks` endpoint was returning the wrong data structure.

### ❌ Old Response (Incorrect)
```json
{
  "content": [
    {
      "id": 2,
      "publicId": "367eaefa-d2f6-400d-8ef0-0b86f653cb75",
      "poem": {
        "id": 8  // ❌ Only poem ID, no full poem data
      }
    }
  ]
}
```

The backend was returning raw `Bookmark` entities which only contained a minimal poem reference.

### ✅ New Response (Correct)
```json
{
  "content": [
    {
      "publicId": "poem-abc123",
      "title": "Mohabbat mein nahi hai farq",
      "excerpt": "محبت میں نہیں ہے فرق جینے اور مرنے کا...",
      "poetPublicId": "ghalib-001",
      "poetName": "Mirza Ghalib",
      "poetProfileImageUrl": "https://cdn.example.com/poets/ghalib.jpg",
      "categoryPublicId": "love",
      "categoryName": "Love Poetry",
      "poetryType": "GHAZAL",
      "poetryTypeName": "GHAZAL",
      "yearWritten": 1850,
      "contentType": "TEXT",
      "thumbnailUrl": "-",
      "isPublic": true,
      "isFeatured": true,
      "viewCount": 1523,
      "likeCount": 234,
      "commentCount": 0,
      "shareCount": 0,
      "isLikedByCurrentUser": true,
      "isBookmarkedByCurrentUser": true,
      "createdAt": "2025-10-15T10:30:00",
      "updatedAt": "2025-12-05T14:20:00",
      "bookmarkedAt": "2025-12-06T10:00:00"  // When user bookmarked this
    }
  ]
}
```

Now the response contains full poem data ready for display!

---

## What Was Fixed

### 1. Created New DTOs

**BookmarkedPoemResponse.java**
- Contains all poem data needed for display
- Includes poet information
- Includes category information
- Includes counts (views, likes, etc.)
- Includes user's interaction status
- Includes `bookmarkedAt` timestamp

**LikedPoemResponse.java**
- Same structure as BookmarkedPoemResponse
- Includes `likedAt` timestamp instead of `bookmarkedAt`

### 2. Added Service Methods

**PoemService.java**
```java
// Returns full poem details for bookmarks
public Page<BookmarkedPoemResponse> getUserBookmarkedPoems(Long userId, Pageable pageable)

// Returns full poem details for likes
public Page<LikedPoemResponse> getUserLikedPoems(Long userId, Pageable pageable)
```

These methods:
1. Fetch the user's bookmarks/likes
2. Extract the full poem data
3. Build proper DTO responses with all necessary fields
4. Include user-specific fields (isLikedByCurrentUser, etc.)

### 3. Updated Controller

**UserController.java**
```java
@GetMapping("/me/bookmarks")
public ResponseEntity<ApiResponse<Page<BookmarkedPoemResponse>>> getUserBookmarks(...)

@GetMapping("/me/likes")
public ResponseEntity<ApiResponse<Page<LikedPoemResponse>>> getUserLikes(...)
```

Now returns the proper DTOs instead of raw entities.

---

## Response Fields Explanation

### Poem Information
| Field | Type | Description |
|-------|------|-------------|
| `publicId` | String | Poem's public ID for navigation |
| `title` | String | Poem title |
| `excerpt` | String | First 2 lines of the poem |

### Poet Information
| Field | Type | Description |
|-------|------|-------------|
| `poetPublicId` | String | Poet's public ID |
| `poetName` | String | Poet's name |
| `poetProfileImageUrl` | String | Poet's profile image URL |

### Category Information
| Field | Type | Description |
|-------|------|-------------|
| `categoryPublicId` | String | Category's public ID |
| `categoryName` | String | Category name (e.g., "Love Poetry") |

### Poetry Details
| Field | Type | Description |
|-------|------|-------------|
| `poetryType` | String (Enum) | GHAZAL, NAZAM, etc. |
| `poetryTypeName` | String | Display name of poetry type |
| `yearWritten` | Integer | Year the poem was written |
| `contentType` | String (Enum) | TEXT, AUDIO, VIDEO, etc. |

### Media
| Field | Type | Description |
|-------|------|-------------|
| `thumbnailUrl` | String | Poem thumbnail image URL |

### Status
| Field | Type | Description |
|-------|------|-------------|
| `isPublic` | Boolean | Is poem publicly visible |
| `isFeatured` | Boolean | Is poem featured |

### Counts
| Field | Type | Description |
|-------|------|-------------|
| `viewCount` | Integer | Number of views |
| `likeCount` | Integer | Number of likes |
| `commentCount` | Integer | Number of comments |
| `shareCount` | Integer | Number of shares |

### User Interaction Status
| Field | Type | Description |
|-------|------|-------------|
| `isLikedByCurrentUser` | Boolean | Has current user liked this poem |
| `isBookmarkedByCurrentUser` | Boolean | Has current user bookmarked this poem |

### Timestamps
| Field | Type | Description |
|-------|------|-------------|
| `createdAt` | DateTime | When poem was created |
| `updatedAt` | DateTime | When poem was last updated |
| `bookmarkedAt` | DateTime | When user bookmarked this (bookmarks only) |
| `likedAt` | DateTime | When user liked this (likes only) |

---

## Flutter Model Update

Update your Flutter models to match this structure:

```dart
class BookmarkedPoemResponse {
  // Poem info
  final String publicId;
  final String title;
  final String excerpt;

  // Poet info
  final String? poetPublicId;
  final String poetName;
  final String? poetProfileImageUrl;

  // Category info
  final String? categoryPublicId;
  final String categoryName;

  // Poetry details
  final String? poetryType;
  final String poetryTypeName;
  final int? yearWritten;
  final String? contentType;

  // Media
  final String thumbnailUrl;

  // Status
  final bool isPublic;
  final bool isFeatured;

  // Counts
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;

  // User interaction
  final bool isLikedByCurrentUser;
  final bool isBookmarkedByCurrentUser;

  // Timestamps
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime bookmarkedAt;

  BookmarkedPoemResponse({
    required this.publicId,
    required this.title,
    required this.excerpt,
    this.poetPublicId,
    required this.poetName,
    this.poetProfileImageUrl,
    this.categoryPublicId,
    required this.categoryName,
    this.poetryType,
    required this.poetryTypeName,
    this.yearWritten,
    this.contentType,
    required this.thumbnailUrl,
    required this.isPublic,
    required this.isFeatured,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    required this.isLikedByCurrentUser,
    required this.isBookmarkedByCurrentUser,
    required this.createdAt,
    required this.updatedAt,
    required this.bookmarkedAt,
  });

  factory BookmarkedPoemResponse.fromJson(Map<String, dynamic> json) {
    return BookmarkedPoemResponse(
      publicId: json['publicId'] as String,
      title: json['title'] as String,
      excerpt: json['excerpt'] as String,
      poetPublicId: json['poetPublicId'] as String?,
      poetName: json['poetName'] as String,
      poetProfileImageUrl: json['poetProfileImageUrl'] as String?,
      categoryPublicId: json['categoryPublicId'] as String?,
      categoryName: json['categoryName'] as String,
      poetryType: json['poetryType'] as String?,
      poetryTypeName: json['poetryTypeName'] as String,
      yearWritten: json['yearWritten'] as int?,
      contentType: json['contentType'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String,
      isPublic: json['isPublic'] as bool,
      isFeatured: json['isFeatured'] as bool,
      viewCount: json['viewCount'] as int,
      likeCount: json['likeCount'] as int,
      commentCount: json['commentCount'] as int,
      shareCount: json['shareCount'] as int,
      isLikedByCurrentUser: json['isLikedByCurrentUser'] as bool,
      isBookmarkedByCurrentUser: json['isBookmarkedByCurrentUser'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      bookmarkedAt: DateTime.parse(json['bookmarkedAt'] as String),
    );
  }
}
```

**Note:** `LikedPoemResponse` has the same structure except `bookmarkedAt` is replaced with `likedAt`.

---

## Testing

### Test Bookmark Response
```bash
TOKEN="your_jwt_token"

curl -X GET "http://localhost:8080/api/users/me/bookmarks?page=0&size=20" \
  -H "Authorization: Bearer $TOKEN" | jq
```

**Expected Output:**
```json
{
  "success": true,
  "message": "Bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem-123",
        "title": "Beautiful Ghazal",
        "excerpt": "First line\nSecond line...",
        "poetName": "Mirza Ghalib",
        "categoryName": "Love Poetry",
        "poetryType": "GHAZAL",
        ...all other fields...
      }
    ],
    "totalElements": 45,
    "totalPages": 3,
    "size": 20,
    "number": 0
  }
}
```

---

## Summary of Changes

✅ Created `BookmarkedPoemResponse.java` DTO
✅ Created `LikedPoemResponse.java` DTO
✅ Added `getUserBookmarkedPoems()` method in PoemService
✅ Added `getUserLikedPoems()` method in PoemService
✅ Updated `/api/users/me/bookmarks` endpoint to return DTOs
✅ Updated `/api/users/me/likes` endpoint to return DTOs
✅ Compiled successfully ✅

---

## Next Steps for Flutter Team

1. ✅ Update `BookmarkModel` class to match `BookmarkedPoemResponse` structure
2. ✅ Update `LikeModel` class to match `LikedPoemResponse` structure
3. ✅ Test `/api/users/me/bookmarks` endpoint - should now return full poem data
4. ✅ Test `/api/users/me/likes` endpoint - should now return full poem data
5. ✅ Update UI to display all the new fields (poet image, category, etc.)
6. ✅ Test bookmark/like toggle still works correctly

The backend is ready with the correct response structure!

---

**Compilation Status:** ✅ BUILD SUCCESS
**Ready for Testing:** ✅ YES
**Breaking Change:** ⚠️ YES - Response structure changed, Flutter models need updating
