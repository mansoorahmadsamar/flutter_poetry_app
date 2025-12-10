# User Endpoints API Documentation

**Base URL:** `http://localhost:8080/api`
**Production URL:** `https://your-domain.com/api`

This document covers all user-related endpoints including profile management, bookmarks, and likes.

---

## Table of Contents

1. [Authentication](#authentication)
2. [User Profile](#user-profile)
3. [Bookmarks](#bookmarks)
4. [Likes](#likes)

---

## Authentication

All endpoints except public endpoints require JWT authentication. Include the token in the `Authorization` header:

```bash
Authorization: Bearer YOUR_JWT_TOKEN
```

---

## User Profile

### 1. Get Current User Profile

Get the authenticated user's profile information.

**Endpoint:** `GET /api/users/me`

**Authentication:** Required

**Request:**
```bash
curl -X GET "http://localhost:8080/api/users/me" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "username": "ahmadmansoor",
    "email": "ahmad@example.com",
    "fullName": "Ahmad Mansoor",
    "provider": "LOCAL",
    "providerId": null,
    "imageUrl": null,
    "emailVerified": true,
    "createdAt": "2024-12-01T10:30:00",
    "updatedAt": "2024-12-09T15:45:00"
  }
}
```

**Response (404 Not Found):**
```json
{
  "success": false,
  "message": "User not found",
  "data": null
}
```

---

### 2. Update User Profile

Update the authenticated user's profile (fullName and username only).

**Endpoint:** `PUT /api/users/profile`

**Authentication:** Required

**Request Body:**
```json
{
  "fullName": "Ahmad Mansoor Samar",
  "username": "mansoor.ahmad"
}
```

**Request:**
```bash
curl -X PUT "http://localhost:8080/api/users/profile" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "Ahmad Mansoor Samar",
    "username": "mansoor.ahmad"
  }'
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "username": "mansoor.ahmad",
    "email": "ahmad@example.com",
    "fullName": "Ahmad Mansoor Samar",
    "provider": "LOCAL",
    "providerId": null,
    "imageUrl": null,
    "emailVerified": true,
    "createdAt": "2024-12-01T10:30:00",
    "updatedAt": "2024-12-10T11:20:00"
  }
}
```

**Response (400 Bad Request) - Username Already Taken:**
```json
{
  "success": false,
  "message": "Username is already taken!",
  "data": null
}
```

**Notes:**
- Only `fullName` and `username` can be updated
- Username must be unique across all users
- Email cannot be changed via this endpoint

---

## Bookmarks

### 3. Get All User Bookmarks

Get all poems bookmarked by the authenticated user (paginated).

**Endpoint:** `GET /api/users/me/bookmarks`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 0 | Page number (0-indexed) |
| `size` | integer | 10 | Items per page |
| `sortBy` | string | createdAt | Field to sort by (createdAt, title, etc.) |
| `sortDir` | string | desc | Sort direction (asc or desc) |

**Request:**
```bash
curl -X GET "http://localhost:8080/api/users/me/bookmarks?page=0&size=10&sortBy=createdAt&sortDir=desc" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "bookmarkId": "550e8400-e29b-41d4-a716-446655440000",
        "poemPublicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
        "title": "دل کی بستی",
        "excerpt": "دل کی بستی میں بسایا ہے تجھے\nروح کے گھر میں بلایا ہے تجھے...",
        "poetPublicId": "poet-123",
        "poetName": "احمد فراز",
        "poetProfileImageUrl": "https://example.com/images/poets/ahmad-faraz.jpg",
        "categoryPublicId": "cat-456",
        "categoryName": "رومانوی شاعری",
        "poetryType": "GHAZAL",
        "poetryTypeName": "غزل",
        "contentType": "TEXT",
        "thumbnailUrl": "-",
        "yearWritten": 1985,
        "viewCount": 1234,
        "likeCount": 567,
        "commentCount": 89,
        "shareCount": 45,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": true,
        "bookmarkedAt": "2024-12-09T14:30:00",
        "createdAt": "2024-11-15T10:00:00",
        "updatedAt": "2024-12-08T16:45:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalPages": 5,
    "totalElements": 47,
    "last": false,
    "size": 10,
    "number": 0,
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "numberOfElements": 10,
    "first": true,
    "empty": false
  }
}
```

---

### 4. Search User Bookmarks

Search through the authenticated user's bookmarked poems with filters.

**Endpoint:** `GET /api/users/me/bookmarks/search`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | **Yes** | - | Search query (searches in title, content, poet name) |
| `poetryType` | string | No | - | Filter by poetry type (GHAZAL, NAZM, RUBAI, QASIDA, etc.) |
| `poetId` | string | No | - | Filter by poet's publicId |
| `page` | integer | No | 0 | Page number (0-indexed) |
| `size` | integer | No | 10 | Items per page |
| `sortBy` | string | No | createdAt | Field to sort by |
| `sortDir` | string | No | desc | Sort direction (asc or desc) |

**Request (Basic Search):**
```bash
curl -X GET "http://localhost:8080/api/users/me/bookmarks/search?query=دل" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Request (Advanced Search with Filters):**
```bash
curl -X GET "http://localhost:8080/api/users/me/bookmarks/search?query=محبت&poetryType=GHAZAL&poetId=poet-123&page=0&size=20" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Bookmarks search results retrieved successfully",
  "data": {
    "content": [
      {
        "bookmarkId": "550e8400-e29b-41d4-a716-446655440000",
        "poemPublicId": "314181f0-e670-4e5c-a8fc-cc186527430b",
        "title": "دل کی بستی",
        "excerpt": "دل کی بستی میں بسایا ہے تجھے...",
        "poetPublicId": "poet-123",
        "poetName": "احمد فراز",
        "poetProfileImageUrl": "https://example.com/images/poets/ahmad-faraz.jpg",
        "categoryPublicId": "cat-456",
        "categoryName": "رومانوی شاعری",
        "poetryType": "GHAZAL",
        "poetryTypeName": "غزل",
        "contentType": "TEXT",
        "thumbnailUrl": "-",
        "yearWritten": 1985,
        "viewCount": 1234,
        "likeCount": 567,
        "commentCount": 89,
        "shareCount": 45,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": true,
        "bookmarkedAt": "2024-12-09T14:30:00",
        "createdAt": "2024-11-15T10:00:00",
        "updatedAt": "2024-12-08T16:45:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalPages": 1,
    "totalElements": 3,
    "last": true,
    "size": 10,
    "number": 0,
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "numberOfElements": 3,
    "first": true,
    "empty": false
  }
}
```

**Response (400 Bad Request) - Empty Query:**
```json
{
  "success": false,
  "message": "Search query cannot be empty",
  "data": null
}
```

**Frontend Implementation Notes:**
- Only call this endpoint when user has typed 3 or more characters
- Implement debouncing (300-500ms delay) to avoid excessive API calls
- The search is case-insensitive and searches across:
  - Poem title
  - Poem full text content
  - Poet name

**Example Frontend Logic:**
```dart
// Example: Only search when query length >= 3
if (searchQuery.length >= 3) {
  // Debounce and call API
  await searchUserBookmarks(searchQuery);
} else {
  // Show all bookmarks or show empty state
  await getUserBookmarks();
}
```

---

## Likes

### 5. Get All User Likes

Get all poems liked by the authenticated user (paginated).

**Endpoint:** `GET /api/users/me/likes`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | integer | 0 | Page number (0-indexed) |
| `size` | integer | 10 | Items per page |
| `sortBy` | string | createdAt | Field to sort by (createdAt, title, etc.) |
| `sortDir` | string | desc | Sort direction (asc or desc) |

**Request:**
```bash
curl -X GET "http://localhost:8080/api/users/me/likes?page=0&size=10&sortBy=createdAt&sortDir=desc" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Likes retrieved successfully",
  "data": {
    "content": [
      {
        "likeId": "660e8400-e29b-41d4-a716-446655440000",
        "poemPublicId": "414181f0-e670-4e5c-a8fc-cc186527430b",
        "title": "رات یوں دل میں تری",
        "excerpt": "رات یوں دل میں تری کھوئی ہوئی یاد آئی\nجیسے ویرانے میں چپکے سے بہار آ جائے...",
        "poetPublicId": "poet-456",
        "poetName": "فیض احمد فیض",
        "poetProfileImageUrl": "https://example.com/images/poets/faiz.jpg",
        "categoryPublicId": "cat-789",
        "categoryName": "انقلابی شاعری",
        "poetryType": "NAZM",
        "poetryTypeName": "نظم",
        "contentType": "TEXT",
        "thumbnailUrl": "-",
        "yearWritten": 1960,
        "viewCount": 2345,
        "likeCount": 890,
        "commentCount": 123,
        "shareCount": 67,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": false,
        "likedAt": "2024-12-08T09:15:00",
        "createdAt": "2024-10-20T14:30:00",
        "updatedAt": "2024-12-07T18:20:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalPages": 3,
    "totalElements": 28,
    "last": false,
    "size": 10,
    "number": 0,
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "numberOfElements": 10,
    "first": true,
    "empty": false
  }
}
```

---

### 6. Search User Likes

Search through the authenticated user's liked poems with filters.

**Endpoint:** `GET /api/users/me/likes/search`

**Authentication:** Required

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `query` | string | **Yes** | - | Search query (searches in title, content, poet name) |
| `poetryType` | string | No | - | Filter by poetry type (GHAZAL, NAZM, RUBAI, QASIDA, etc.) |
| `poetId` | string | No | - | Filter by poet's publicId |
| `page` | integer | No | 0 | Page number (0-indexed) |
| `size` | integer | No | 10 | Items per page |
| `sortBy` | string | No | createdAt | Field to sort by |
| `sortDir` | string | No | desc | Sort direction (asc or desc) |

**Request (Basic Search):**
```bash
curl -X GET "http://localhost:8080/api/users/me/likes/search?query=محبت" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Request (Advanced Search with Filters):**
```bash
curl -X GET "http://localhost:8080/api/users/me/likes/search?query=انقلاب&poetryType=NAZM&poetId=poet-456&page=0&size=15" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Likes search results retrieved successfully",
  "data": {
    "content": [
      {
        "likeId": "660e8400-e29b-41d4-a716-446655440000",
        "poemPublicId": "414181f0-e670-4e5c-a8fc-cc186527430b",
        "title": "رات یوں دل میں تری",
        "excerpt": "رات یوں دل میں تری کھوئی ہوئی یاد آئی...",
        "poetPublicId": "poet-456",
        "poetName": "فیض احمد فیض",
        "poetProfileImageUrl": "https://example.com/images/poets/faiz.jpg",
        "categoryPublicId": "cat-789",
        "categoryName": "انقلابی شاعری",
        "poetryType": "NAZM",
        "poetryTypeName": "نظم",
        "contentType": "TEXT",
        "thumbnailUrl": "-",
        "yearWritten": 1960,
        "viewCount": 2345,
        "likeCount": 890,
        "commentCount": 123,
        "shareCount": 67,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": false,
        "likedAt": "2024-12-08T09:15:00",
        "createdAt": "2024-10-20T14:30:00",
        "updatedAt": "2024-12-07T18:20:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 15,
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalPages": 1,
    "totalElements": 5,
    "last": true,
    "size": 15,
    "number": 0,
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "numberOfElements": 5,
    "first": true,
    "empty": false
  }
}
```

**Response (400 Bad Request) - Empty Query:**
```json
{
  "success": false,
  "message": "Search query cannot be empty",
  "data": null
}
```

**Frontend Implementation Notes:**
- Only call this endpoint when user has typed 3 or more characters
- Implement debouncing (300-500ms delay) to avoid excessive API calls
- The search is case-insensitive and searches across:
  - Poem title
  - Poem full text content
  - Poet name

**Example Frontend Logic:**
```dart
// Example: Only search when query length >= 3
if (searchQuery.length >= 3) {
  // Debounce and call API
  await searchUserLikes(searchQuery);
} else {
  // Show all likes or show empty state
  await getUserLikes();
}
```

---

## Common Response Fields

### BookmarkedPoemResponse / LikedPoemResponse Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `bookmarkId` / `likeId` | string (UUID) | Unique identifier for the bookmark/like | "550e8400-e29b-41d4-a716-446655440000" |
| `poemPublicId` | string (UUID) | Unique identifier for the poem | "314181f0-e670-4e5c-a8fc-cc186527430b" |
| `title` | string | Poem title | "دل کی بستی" |
| `excerpt` | string | First 2 lines or 100 characters of the poem | "دل کی بستی میں بسایا ہے تجھے..." |
| `poetPublicId` | string | Unique identifier for the poet | "poet-123" |
| `poetName` | string | Poet's name | "احمد فراز" |
| `poetProfileImageUrl` | string | URL to poet's profile image | "https://example.com/images/poets/ahmad-faraz.jpg" |
| `categoryPublicId` | string | Unique identifier for the category | "cat-456" |
| `categoryName` | string | Category name | "رومانوی شاعری" |
| `poetryType` | enum | Type of poetry (GHAZAL, NAZM, etc.) | "GHAZAL" |
| `poetryTypeName` | string | Localized poetry type name | "غزل" |
| `contentType` | enum | Content type (TEXT, IMAGE, AUDIO, VIDEO) | "TEXT" |
| `thumbnailUrl` | string | URL to thumbnail image (or "-" if none) | "-" |
| `yearWritten` | integer | Year the poem was written | 1985 |
| `viewCount` | integer | Number of views | 1234 |
| `likeCount` | integer | Number of likes | 567 |
| `commentCount` | integer | Number of comments | 89 |
| `shareCount` | integer | Number of shares | 45 |
| `isLikedByCurrentUser` | boolean | Whether current user liked this poem | true |
| `isBookmarkedByCurrentUser` | boolean | Whether current user bookmarked this poem | true |
| `bookmarkedAt` / `likedAt` | datetime (ISO 8601) | When the bookmark/like was created | "2024-12-09T14:30:00" |
| `createdAt` | datetime (ISO 8601) | When the poem was created | "2024-11-15T10:00:00" |
| `updatedAt` | datetime (ISO 8601) | When the poem was last updated | "2024-12-08T16:45:00" |

---

## Poetry Types

Available poetry type values:

| Value | Urdu Name | English Name | Hindi Name |
|-------|-----------|--------------|------------|
| `GHAZAL` | غزل | Ghazal | ग़ज़ल |
| `NAZM` | نظم | Nazm | नज़्म |
| `RUBAI` | رباعی | Rubai | रुबाई |
| `QASIDA` | قصیدہ | Qasida | क़सीदा |
| `MARSIYA` | مرثیہ | Marsiya | मर्सिया |
| `MASNAVI` | مثنوی | Masnavi | मसनवी |
| `QITA` | قطعہ | Qita | क़ित'आ |
| `MATHNAWI` | مثنوی | Mathnawi | मसनवी |
| `FREE_VERSE` | آزاد نظم | Free Verse | आज़ाद नज़्म |
| `DOHA` | دوہا | Doha | दोहा |
| `SHAYARI` | شاعری | Shayari | शायरी |

---

## Error Responses

### 401 Unauthorized
User is not authenticated or token is invalid/expired.

```json
{
  "success": false,
  "message": "Unauthorized: Authentication token is missing or invalid",
  "data": null
}
```

### 404 Not Found
Requested resource not found.

```json
{
  "success": false,
  "message": "User not found",
  "data": null
}
```

### 400 Bad Request
Invalid request parameters.

```json
{
  "success": false,
  "message": "Search query cannot be empty",
  "data": null
}
```

### 500 Internal Server Error
Server encountered an error.

```json
{
  "success": false,
  "message": "An error occurred while processing your request",
  "data": null
}
```

---

## Best Practices for Flutter Team

### 1. Search Implementation
```dart
// Implement debouncing for search
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 300), () {
    if (query.length >= 3) {
      // Call search API
      searchBookmarks(query);
    } else if (query.isEmpty) {
      // Show all bookmarks
      getAllBookmarks();
    }
  });
}
```

### 2. Pagination
```dart
// Load more items when user scrolls to bottom
ScrollController _scrollController = ScrollController();

_scrollController.addListener(() {
  if (_scrollController.position.pixels ==
      _scrollController.position.maxScrollExtent) {
    if (!isLastPage) {
      loadMoreBookmarks(currentPage + 1);
    }
  }
});
```

### 3. Error Handling
```dart
try {
  final response = await api.getUserBookmarks(page: 0, size: 10);
  if (response.success) {
    // Handle success
    updateBookmarksList(response.data.content);
  } else {
    // Handle error message
    showError(response.message);
  }
} on UnauthorizedException {
  // Token expired, redirect to login
  navigateToLogin();
} on NetworkException {
  // No internet connection
  showNetworkError();
} catch (e) {
  // Generic error
  showGenericError();
}
```

### 4. Caching Strategy
```dart
// Cache bookmarks locally
class BookmarkCache {
  static final _cache = <String, List<BookmarkedPoemResponse>>{};
  static DateTime? _lastFetch;

  static bool isExpired() {
    if (_lastFetch == null) return true;
    return DateTime.now().difference(_lastFetch!) > Duration(minutes: 5);
  }

  static void update(List<BookmarkedPoemResponse> bookmarks) {
    _cache['bookmarks'] = bookmarks;
    _lastFetch = DateTime.now();
  }
}
```

---

## Changelog

### Version 1.1.0 (2024-12-10)
- ✅ Added dedicated search endpoints for bookmarks and likes
- ✅ Removed unused query parameters from GET /me/bookmarks
- ✅ Removed unused query parameters from GET /me/likes
- ✅ Added query validation for search endpoints
- ✅ Implemented multi-field case-insensitive search

### Version 1.0.0 (2024-12-09)
- ✅ Initial user endpoints implementation
- ✅ Profile management
- ✅ Bookmark and like listing with pagination

---

## Support

For questions or issues, please contact the backend team or create an issue in the project repository.

**API Version:** 1.1.0
**Last Updated:** December 10, 2024
**Documentation Maintained By:** Backend Team
