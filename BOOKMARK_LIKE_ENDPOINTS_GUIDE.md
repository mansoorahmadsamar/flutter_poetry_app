# Bookmark & Like Endpoints - Quick Reference for Flutter Team

**Date:** December 6, 2025
**Status:** ✅ Endpoints are LIVE and working

---

## Important Notice

The bookmark and like endpoints are **already implemented** in the backend. The Flutter team was calling the wrong endpoint URLs.

### ❌ Wrong Endpoints (Don't Use These)

```
POST /api/bookmarks                    ← WRONG!
DELETE /api/bookmarks/{poemId}         ← WRONG!
POST /api/likes                        ← WRONG!
DELETE /api/likes/{poemId}             ← WRONG!
```

### ✅ Correct Endpoints (Use These)

```
POST /api/poems/{poemPublicId}/bookmark    ← Correct!
POST /api/poems/{poemPublicId}/like        ← Correct!
GET  /api/poems/{poemPublicId}/status      ← Correct!
GET  /api/users/me/bookmarks               ← Correct!
GET  /api/users/me/likes                   ← Correct!
```

---

## 1. Toggle Bookmark

**Endpoint:** `POST /api/poems/{poemPublicId}/bookmark`

**Description:** This is a **toggle** endpoint. One endpoint handles both adding AND removing bookmarks.

**How it works:**
- If poem is NOT bookmarked → Adds bookmark, returns `{"bookmarked": true}`
- If poem IS bookmarked → Removes bookmark, returns `{"bookmarked": false}`

**Request:**

```http
POST http://localhost:8080/api/poems/abc123/bookmark
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

**No request body needed!**

**Response when adding bookmark:**

```json
{
  "success": true,
  "message": "Poem bookmarked successfully",
  "data": {
    "bookmarked": true
  },
  "timestamp": "2025-12-06T11:30:00"
}
```

**Response when removing bookmark:**

```json
{
  "success": true,
  "message": "Bookmark removed successfully",
  "data": {
    "bookmarked": false
  },
  "timestamp": "2025-12-06T11:30:00"
}
```

---

## 2. Toggle Like

**Endpoint:** `POST /api/poems/{poemPublicId}/like`

**Description:** This is a **toggle** endpoint. One endpoint handles both adding AND removing likes.

**How it works:**
- If poem is NOT liked → Adds like, returns `{"liked": true}`
- If poem IS liked → Removes like, returns `{"liked": false}`

**Request:**

```http
POST http://localhost:8080/api/poems/abc123/like
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json
```

**No request body needed!**

**Response when adding like:**

```json
{
  "success": true,
  "message": "Poem liked successfully",
  "data": {
    "liked": true
  },
  "timestamp": "2025-12-06T11:30:00"
}
```

**Response when removing like:**

```json
{
  "success": true,
  "message": "Like removed successfully",
  "data": {
    "liked": false
  },
  "timestamp": "2025-12-06T11:30:00"
}
```

---

## 3. Check Bookmark/Like Status

**Endpoint:** `GET /api/poems/{poemPublicId}/status`

**Description:** Check if the current user has bookmarked or liked a poem.

**Request:**

```http
GET http://localhost:8080/api/poems/abc123/status
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response:**

```json
{
  "success": true,
  "message": "Status retrieved successfully",
  "data": {
    "bookmarked": true,
    "liked": false
  },
  "timestamp": "2025-12-06T11:30:00"
}
```

---

## 4. Get User's Bookmarks

**Endpoint:** `GET /api/users/me/bookmarks`

**Description:** Get all poems bookmarked by the current user with pagination, search, and filters.

**Query Parameters:**
- `page` (int, default: 0)
- `size` (int, default: 20)
- `query` (string, optional) - Search by poem title or poet name
- `poetryType` (string, optional) - Filter by type (GHAZAL, NAZAM, etc.)
- `poetId` (string, optional) - Filter by poet
- `sortBy` (string, default: "createdAt")
- `sortDir` (string, default: "desc")

**Example Requests:**

```http
# Get all bookmarks
GET http://localhost:8080/api/users/me/bookmarks?page=0&size=20

# Search bookmarks
GET http://localhost:8080/api/users/me/bookmarks?query=mohabbat&page=0&size=20

# Filter by poetry type
GET http://localhost:8080/api/users/me/bookmarks?poetryType=GHAZAL&page=0&size=20
```

**Response:**

```json
{
  "success": true,
  "message": "Bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem-abc123",
        "title": "Mohabbat mein nahi hai farq",
        "excerpt": "محبت میں نہیں ہے فرق...",
        "poetPublicId": "ghalib-001",
        "poetName": "Mirza Ghalib",
        "poetryType": "GHAZAL",
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": true,
        "likeCount": 234,
        "viewCount": 1523
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

## 5. Get User's Likes

**Endpoint:** `GET /api/users/me/likes`

**Description:** Same as bookmarks endpoint, but returns liked poems.

**Parameters:** Same as bookmarks endpoint.

---

## Flutter Implementation

### BookmarkService.dart

```dart
import 'package:dio/dio.dart';

class BookmarkService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8080';

  BookmarkService(this._dio);

  /// Toggle bookmark for a poem (add if not bookmarked, remove if bookmarked)
  Future<bool> toggleBookmark(String poemPublicId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/poems/$poemPublicId/bookmark',
      );

      if (response.statusCode == 200) {
        return response.data['data']['bookmarked'] as bool;
      }
      throw Exception('Failed to toggle bookmark');
    } catch (e) {
      print('Error toggling bookmark: $e');
      rethrow;
    }
  }

  /// Get all bookmarked poems
  Future<PaginatedPoems> getBookmarks({
    int page = 0,
    int size = 20,
    String? query,
    String? poetryType,
    String? poetId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'size': size,
        if (query != null && query.isNotEmpty) 'query': query,
        if (poetryType != null) 'poetryType': poetryType,
        if (poetId != null) 'poetId': poetId,
      };

      final response = await _dio.get(
        '$baseUrl/api/users/me/bookmarks',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedPoems.fromJson(response.data['data']);
      }
      throw Exception('Failed to load bookmarks');
    } catch (e) {
      print('Error loading bookmarks: $e');
      rethrow;
    }
  }

  /// Check if poem is bookmarked
  Future<bool> isBookmarked(String poemPublicId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/poems/$poemPublicId/status',
      );

      if (response.statusCode == 200) {
        return response.data['data']['bookmarked'] as bool;
      }
      return false;
    } catch (e) {
      print('Error checking bookmark status: $e');
      return false;
    }
  }
}
```

### LikeService.dart

```dart
import 'package:dio/dio.dart';

class LikeService {
  final Dio _dio;
  final String baseUrl = 'http://localhost:8080';

  LikeService(this._dio);

  /// Toggle like for a poem (add if not liked, remove if liked)
  Future<bool> toggleLike(String poemPublicId) async {
    try {
      final response = await _dio.post(
        '$baseUrl/api/poems/$poemPublicId/like',
      );

      if (response.statusCode == 200) {
        return response.data['data']['liked'] as bool;
      }
      throw Exception('Failed to toggle like');
    } catch (e) {
      print('Error toggling like: $e');
      rethrow;
    }
  }

  /// Get all liked poems
  Future<PaginatedPoems> getLikes({
    int page = 0,
    int size = 20,
    String? query,
    String? poetryType,
    String? poetId,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'size': size,
        if (query != null && query.isNotEmpty) 'query': query,
        if (poetryType != null) 'poetryType': poetryType,
        if (poetId != null) 'poetId': poetId,
      };

      final response = await _dio.get(
        '$baseUrl/api/users/me/likes',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        return PaginatedPoems.fromJson(response.data['data']);
      }
      throw Exception('Failed to load likes');
    } catch (e) {
      print('Error loading likes: $e');
      rethrow;
    }
  }

  /// Check if poem is liked
  Future<bool> isLiked(String poemPublicId) async {
    try {
      final response = await _dio.get(
        '$baseUrl/api/poems/$poemPublicId/status',
      );

      if (response.statusCode == 200) {
        return response.data['data']['liked'] as bool;
      }
      return false;
    } catch (e) {
      print('Error checking like status: $e');
      return false;
    }
  }
}
```

### Usage in UI

```dart
class PoemDetailScreen extends StatefulWidget {
  final String poemPublicId;

  @override
  _PoemDetailScreenState createState() => _PoemDetailScreenState();
}

class _PoemDetailScreenState extends State<PoemDetailScreen> {
  final BookmarkService _bookmarkService = BookmarkService(dio);
  final LikeService _likeService = LikeService(dio);

  bool isBookmarked = false;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    final bookmarked = await _bookmarkService.isBookmarked(widget.poemPublicId);
    final liked = await _likeService.isLiked(widget.poemPublicId);

    setState(() {
      isBookmarked = bookmarked;
      isLiked = liked;
    });
  }

  Future<void> _toggleBookmark() async {
    try {
      final newStatus = await _bookmarkService.toggleBookmark(widget.poemPublicId);
      setState(() => isBookmarked = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus ? 'Bookmarked!' : 'Bookmark removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleLike() async {
    try {
      final newStatus = await _likeService.toggleLike(widget.poemPublicId);
      setState(() => isLiked = newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newStatus ? 'Liked!' : 'Like removed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
            color: isLiked ? Colors.red : null,
            onPressed: _toggleLike,
          ),
        ],
      ),
      body: PoemContent(),
    );
  }
}
```

---

## Testing with cURL

```bash
# Get JWT token first (login)
TOKEN="your_jwt_token_here"

# Toggle bookmark
curl -X POST http://localhost:8080/api/poems/abc123/bookmark \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Toggle like
curl -X POST http://localhost:8080/api/poems/abc123/like \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"

# Check status
curl -X GET http://localhost:8080/api/poems/abc123/status \
  -H "Authorization: Bearer $TOKEN"

# Get bookmarks
curl -X GET "http://localhost:8080/api/users/me/bookmarks?page=0&size=20" \
  -H "Authorization: Bearer $TOKEN"

# Get likes
curl -X GET "http://localhost:8080/api/users/me/likes?page=0&size=20" \
  -H "Authorization: Bearer $TOKEN"
```

---

## Summary of Changes Needed in Flutter App

1. **Change endpoint URLs** from `/api/bookmarks` to `/api/poems/{poemPublicId}/bookmark`
2. **Change endpoint URLs** from `/api/likes` to `/api/poems/{poemPublicId}/like`
3. **Remove DELETE methods** - use POST toggle instead
4. **Update BookmarkService.dart** with correct endpoints
5. **Update LikeService.dart** with correct endpoints
6. **Test the changes** with real backend

---

## Common Errors to Avoid

### ❌ Error 1: Wrong URL
```dart
// WRONG
await dio.post('$baseUrl/api/bookmarks', data: {'poemId': poemId});

// CORRECT
await dio.post('$baseUrl/api/poems/$poemPublicId/bookmark');
```

### ❌ Error 2: Sending body when not needed
```dart
// WRONG
await dio.post('$baseUrl/api/poems/$poemPublicId/bookmark',
  data: {'poemId': poemPublicId}  // ← Not needed!
);

// CORRECT
await dio.post('$baseUrl/api/poems/$poemPublicId/bookmark');
```

### ❌ Error 3: Using DELETE instead of POST toggle
```dart
// WRONG
await dio.delete('$baseUrl/api/bookmarks/$poemId');

// CORRECT
await dio.post('$baseUrl/api/poems/$poemPublicId/bookmark');
// The same endpoint adds AND removes!
```

---

## Questions?

If you encounter any issues:

1. Check that your JWT token is valid
2. Verify the `poemPublicId` exists in the database
3. Check the backend logs for detailed error messages
4. Ensure you're using the correct base URL (http://localhost:8080 for development)

The backend is ready and working. Just update the Flutter app to use the correct endpoints!
