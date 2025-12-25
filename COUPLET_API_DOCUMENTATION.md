# Couplet Engagement API - Flutter Integration Guide

## Table of Contents
1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Base URLs & Headers](#base-urls--headers)
4. [Data Models](#data-models)
5. [API Endpoints](#api-endpoints)
6. [Error Handling](#error-handling)
7. [Deep Linking](#deep-linking)
8. [Usage Examples](#usage-examples)

---

## Overview

The Couplet Engagement API enables users to interact with individual couplets (she'r) within poems (Ghazals). Users can:
- Like and bookmark individual couplets
- Share couplets with rich context
- View their liked/bookmarked couplet collections
- Discover trending and popular couplets

---

## Authentication

All endpoints (except public share link) require JWT authentication.

**Header:**
```
Authorization: Bearer <your_jwt_token>
```

---

## Base URLs & Headers

### Base URL
```
https://poetry.app/api
```

### Common Headers
```http
Content-Type: application/json
Authorization: Bearer <jwt_token>
Accept: application/json
```

---

## Data Models

### CoupletDto
Basic couplet representation

```json
{
  "publicId": "uuid-string",
  "coupletNumber": 1,
  "coupletType": "MATLA",
  "coupletTypeName": "Matla",
  "likeCount": 150,
  "bookmarkCount": 45,
  "shareCount": 30,
  "verses": [
    {
      "publicId": "verse-uuid",
      "verseNumber": 1,
      "coupletNumber": 1,
      "verseType": "MATLA",
      "verseText": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
      "romanizedText": "muhabbat mein nahin hai farq jeene aur marne ka",
      "translation": "In love there is no difference between living and dying"
    },
    {
      "publicId": "verse-uuid-2",
      "verseNumber": 2,
      "coupletNumber": 1,
      "verseType": "MATLA",
      "verseText": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
      "romanizedText": "usi ko dekh kar jeete hain jis kafir pe dam nikle",
      "translation": "We live by seeing the one by whose unfaithfulness we die"
    }
  ],
  "createdAt": "2024-01-15T10:30:00Z"
}
```

### CoupletDetailResponse
Full couplet with poem and poet context

```json
{
  "publicId": "couplet-uuid",
  "coupletNumber": 3,
  "coupletType": "REGULAR",
  "coupletTypeName": "Regular",
  "verses": [...],
  "poemPublicId": "poem-uuid",
  "poemTitle": "Mujh Se Pehli Si Muhabbat",
  "totalCoupletsInPoem": 7,
  "poetryType": "GHAZAL",
  "poetPublicId": "poet-uuid",
  "poetName": "Faiz Ahmed Faiz",
  "poetProfileImageUrl": "https://cdn.poetry.app/poets/faiz.jpg",
  "likeCount": 250,
  "bookmarkCount": 120,
  "shareCount": 80,
  "isLikedByCurrentUser": true,
  "isBookmarkedByCurrentUser": false,
  "createdAt": "2024-01-15T10:30:00Z",
  "updatedAt": "2024-01-20T14:45:00Z"
}
```

### CoupletShareLinkResponse
Share link with rich metadata

```json
{
  "shareUrl": "https://poetry.app/poems/poem-uuid/couplets/3?ref=abc123de",
  "deepLink": "poetryapp://poem/poem-uuid?couplet=3&highlight=true",
  "shareToken": "abc123de",
  "coupletPublicId": "couplet-uuid",
  "coupletNumber": 3,
  "coupletTypeBadge": "Matla",
  "poemContext": "Couplet 3 of 7",
  "poetName": "Faiz Ahmed Faiz",
  "poemPublicId": "poem-uuid",
  "poemTitle": "Mujh Se Pehli Si Muhabbat",
  "verseTexts": [
    "محبت میں نہیں ہے فرق جینے اور مرنے کا",
    "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے"
  ],
  "ogTitle": "Faiz Ahmed Faiz - Mujh Se Pehli Si Muhabbat (Couplet 3)",
  "ogDescription": "محبت میں نہیں ہے فرق...",
  "ogImage": "https://cdn.poetry.app/poems/thumb.jpg",
  "ogUrl": "https://poetry.app/poems/poem-uuid/couplets/3",
  "shareText": "محبت میں نہیں ہے فرق جینے اور مرنے کا\nاسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے\n\n- Faiz Ahmed Faiz (Matla)\nFrom: Mujh Se Pehli Si Muhabbat\n\nhttps://poetry.app/poems/..."
}
```

### CoupletLikeResponse / CoupletBookmarkResponse
User's liked/bookmarked couplet

```json
{
  "coupletPublicId": "couplet-uuid",
  "coupletNumber": 2,
  "coupletType": "REGULAR",
  "coupletTypeName": "Regular",
  "verses": [...],
  "poemPublicId": "poem-uuid",
  "poemTitle": "Poem Title",
  "poemExcerpt": "First 100 characters of poem...",
  "poetryType": "GHAZAL",
  "totalCoupletsInPoem": 8,
  "poetPublicId": "poet-uuid",
  "poetName": "Poet Name",
  "poetProfileImageUrl": "https://...",
  "likeCount": 180,
  "shareCount": 45,
  "bookmarkCount": 90,
  "isLikedByCurrentUser": true,
  "isBookmarkedByCurrentUser": false,
  "likedAt": "2024-01-15T10:30:00Z"  // or "bookmarkedAt" for bookmarks
}
```

### CoupletAnalyticsResponse
Analytics data for trending/popular couplets

```json
{
  "coupletPublicId": "couplet-uuid",
  "coupletNumber": 1,
  "coupletType": "MATLA",
  "coupletTypeName": "Matla",
  "verseTexts": ["verse 1 text", "verse 2 text"],
  "poemPublicId": "poem-uuid",
  "poemTitle": "Poem Title",
  "totalCoupletsInPoem": 6,
  "poetPublicId": "poet-uuid",
  "poetName": "Faiz Ahmed Faiz",
  "poetProfileImageUrl": "https://...",
  "likeCount": 500,
  "shareCount": 200,
  "bookmarkCount": 300,
  "popularityScore": 1150.0,
  "rank": 1
}
```

### ApiResponse Wrapper
All responses are wrapped in this format

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* CoupletDto or other response object */ }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description",
  "data": null
}
```

---

## API Endpoints

### 1. Get Couplets for a Poem

Retrieve all couplets for a specific poem.

**Endpoint:** `GET /api/poems/{poemPublicId}/couplets`

**Path Parameters:**
- `poemPublicId` (string, required) - The poem's public ID

**Response:** `ApiResponse<List<CoupletDto>>`

**Example Request:**
```http
GET /api/poems/abc-123-def/couplets
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Couplets retrieved successfully",
  "data": [
    {
      "publicId": "couplet-1-uuid",
      "coupletNumber": 1,
      "coupletType": "MATLA",
      "verses": [...],
      "likeCount": 150
    },
    {
      "publicId": "couplet-2-uuid",
      "coupletNumber": 2,
      "coupletType": "REGULAR",
      "verses": [...],
      "likeCount": 120
    }
  ]
}
```

**Flutter Implementation:**
```dart
Future<List<CoupletDto>> getCoupletsByPoem(String poemPublicId) async {
  final response = await dio.get(
    '/api/poems/$poemPublicId/couplets',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.data['success']) {
    return (response.data['data'] as List)
        .map((json) => CoupletDto.fromJson(json))
        .toList();
  }
  throw Exception(response.data['message']);
}
```

---

### 2. Get Single Couplet

Get detailed information about a specific couplet.

**Endpoint:** `GET /api/couplets/{coupletPublicId}`

**Path Parameters:**
- `coupletPublicId` (string, required) - The couplet's public ID

**Response:** `ApiResponse<CoupletDetailResponse>`

**Example Request:**
```http
GET /api/couplets/couplet-uuid
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Couplet retrieved successfully",
  "data": {
    "publicId": "couplet-uuid",
    "coupletNumber": 3,
    "verses": [...],
    "poemTitle": "Mujh Se Pehli Si Muhabbat",
    "poetName": "Faiz Ahmed Faiz",
    "isLikedByCurrentUser": true,
    "isBookmarkedByCurrentUser": false
  }
}
```

**Flutter Implementation:**
```dart
Future<CoupletDetailResponse> getCouplet(String coupletPublicId) async {
  final response = await dio.get(
    '/api/couplets/$coupletPublicId',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.data['success']) {
    return CoupletDetailResponse.fromJson(response.data['data']);
  }
  throw Exception(response.data['message']);
}
```

---

### 3. Toggle Like on Couplet

Like or unlike a couplet (toggle operation).

**Endpoint:** `POST /api/couplets/{coupletPublicId}/like`

**Path Parameters:**
- `coupletPublicId` (string, required) - The couplet's public ID

**Response:** `ApiResponse<CoupletDetailResponse>`

**Example Request:**
```http
POST /api/couplets/couplet-uuid/like
Authorization: Bearer <token>
Content-Type: application/json
```

**Example Response:**
```json
{
  "success": true,
  "message": "Couplet liked successfully",
  "data": {
    "publicId": "couplet-uuid",
    "likeCount": 151,
    "isLikedByCurrentUser": true,
    ...
  }
}
```

**Flutter Implementation:**
```dart
Future<CoupletDetailResponse> toggleLike(String coupletPublicId) async {
  final response = await dio.post(
    '/api/couplets/$coupletPublicId/like',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.data['success']) {
    return CoupletDetailResponse.fromJson(response.data['data']);
  }
  throw Exception(response.data['message']);
}

// Usage in UI
void _handleLikePressed() async {
  setState(() => _isLoading = true);
  try {
    final updatedCouplet = await toggleLike(widget.coupletId);
    setState(() {
      _isLiked = updatedCouplet.isLikedByCurrentUser;
      _likeCount = updatedCouplet.likeCount;
    });
    showSnackBar(updatedCouplet.isLikedByCurrentUser
        ? 'Couplet liked'
        : 'Couplet unliked');
  } catch (e) {
    showSnackBar('Error: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

---

### 4. Toggle Bookmark on Couplet

Bookmark or unbookmark a couplet (toggle operation).

**Endpoint:** `POST /api/couplets/{coupletPublicId}/bookmark`

**Path Parameters:**
- `coupletPublicId` (string, required) - The couplet's public ID

**Response:** `ApiResponse<CoupletDetailResponse>`

**Example Request:**
```http
POST /api/couplets/couplet-uuid/bookmark
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Couplet bookmarked successfully",
  "data": {
    "publicId": "couplet-uuid",
    "bookmarkCount": 46,
    "isBookmarkedByCurrentUser": true,
    ...
  }
}
```

**Flutter Implementation:**
```dart
Future<CoupletDetailResponse> toggleBookmark(String coupletPublicId) async {
  final response = await dio.post(
    '/api/couplets/$coupletPublicId/bookmark',
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.data['success']) {
    return CoupletDetailResponse.fromJson(response.data['data']);
  }
  throw Exception(response.data['message']);
}
```

---

### 5. Create Share Link for Couplet

Generate a trackable share link with rich metadata.

**Endpoint:** `POST /api/couplets/{coupletPublicId}/share`

**Path Parameters:**
- `coupletPublicId` (string, required) - The couplet's public ID

**Request Body:**
```json
{
  "shareType": "WHATSAPP",
  "platform": "MOBILE"
}
```

**ShareType Options:**
- `LINK` - Generic link
- `WHATSAPP` - WhatsApp share
- `FACEBOOK` - Facebook share
- `TWITTER` - Twitter share
- `TELEGRAM` - Telegram share
- `EMAIL` - Email share
- `INSTAGRAM` - Instagram share
- `COPY` - Copy to clipboard
- `DEEP_LINK` - Mobile app deep link
- `OTHER` - Other platform

**Platform Options:** `MOBILE`, `WEB`, `TABLET`

**Response:** `ApiResponse<CoupletShareLinkResponse>`

**Example Request:**
```http
POST /api/couplets/couplet-uuid/share
Authorization: Bearer <token>
Content-Type: application/json

{
  "shareType": "WHATSAPP",
  "platform": "MOBILE"
}
```

**Example Response:**
```json
{
  "success": true,
  "message": "Share link created successfully",
  "data": {
    "shareUrl": "https://poetry.app/poems/poem-uuid/couplets/3?ref=abc123de",
    "deepLink": "poetryapp://poem/poem-uuid?couplet=3&highlight=true",
    "shareToken": "abc123de",
    "coupletTypeBadge": "Matla",
    "poemContext": "Couplet 3 of 7",
    "poetName": "Faiz Ahmed Faiz",
    "shareText": "Complete formatted text ready for sharing..."
  }
}
```

**Flutter Implementation:**
```dart
Future<CoupletShareLinkResponse> createShareLink(
  String coupletPublicId,
  String shareType,
) async {
  final response = await dio.post(
    '/api/couplets/$coupletPublicId/share',
    data: {
      'shareType': shareType,
      'platform': 'MOBILE',
    },
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.data['success']) {
    return CoupletShareLinkResponse.fromJson(response.data['data']);
  }
  throw Exception(response.data['message']);
}

// Usage with share_plus package
void _shareCouplet(String coupletId) async {
  try {
    final shareData = await createShareLink(coupletId, 'WHATSAPP');

    await Share.share(
      shareData.shareText,
      subject: shareData.ogTitle,
    );
  } catch (e) {
    showSnackBar('Error sharing: $e');
  }
}
```

---

### 6. Get Public Share Link

Get public share link without authentication (for non-logged-in users).

**Endpoint:** `GET /api/couplets/{coupletPublicId}/share/public`

**Path Parameters:**
- `coupletPublicId` (string, required) - The couplet's public ID

**Authentication:** Not required

**Response:** `ApiResponse<CoupletShareLinkResponse>`

**Example Request:**
```http
GET /api/couplets/couplet-uuid/share/public
```

---

### 7. Get User's Liked Couplets

Retrieve paginated list of couplets liked by the current user.

**Endpoint:** `GET /api/users/me/couplets/liked`

**Query Parameters:**
- `page` (int, optional, default: 0) - Page number (0-indexed)
- `size` (int, optional, default: 20) - Page size
- `sortBy` (string, optional, default: "createdAt") - Sort field
- `sortDir` (string, optional, default: "desc") - Sort direction (asc/desc)

**Response:** `ApiResponse<Page<CoupletLikeResponse>>`

**Example Request:**
```http
GET /api/users/me/couplets/liked?page=0&size=20&sortBy=createdAt&sortDir=desc
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Liked couplets retrieved successfully",
  "data": {
    "content": [
      {
        "coupletPublicId": "couplet-1-uuid",
        "coupletNumber": 2,
        "verses": [...],
        "poemTitle": "Poem Title",
        "poetName": "Poet Name",
        "isLikedByCurrentUser": true,
        "likedAt": "2024-01-15T10:30:00Z"
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

**Flutter Implementation:**
```dart
Future<Page<CoupletLikeResponse>> getUserLikedCouplets({
  int page = 0,
  int size = 20,
}) async {
  final response = await dio.get(
    '/api/users/me/couplets/liked',
    queryParameters: {'page': page, 'size': size},
    options: Options(headers: {'Authorization': 'Bearer $token'}),
  );

  if (response.data['success']) {
    return Page<CoupletLikeResponse>.fromJson(
      response.data['data'],
      (json) => CoupletLikeResponse.fromJson(json),
    );
  }
  throw Exception(response.data['message']);
}

// Usage with ListView
class LikedCoupletsScreen extends StatefulWidget {
  @override
  _LikedCoupletsScreenState createState() => _LikedCoupletsScreenState();
}

class _LikedCoupletsScreenState extends State<LikedCoupletsScreen> {
  final ScrollController _scrollController = ScrollController();
  List<CoupletLikeResponse> _couplets = [];
  int _currentPage = 0;
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore) return;

    setState(() => _isLoading = true);
    try {
      final page = await getUserLikedCouplets(page: _currentPage);
      setState(() {
        _couplets.addAll(page.content);
        _currentPage++;
        _hasMore = !page.last;
      });
    } catch (e) {
      showSnackBar('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _couplets.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _couplets.length) {
          return Center(child: CircularProgressIndicator());
        }
        return CoupletCard(couplet: _couplets[index]);
      },
    );
  }
}
```

---

### 8. Get User's Bookmarked Couplets

Retrieve paginated list of couplets bookmarked by the current user.

**Endpoint:** `GET /api/users/me/couplets/bookmarked`

**Query Parameters:**
- `page` (int, optional, default: 0) - Page number
- `size` (int, optional, default: 20) - Page size
- `sortBy` (string, optional, default: "createdAt") - Sort field
- `sortDir` (string, optional, default: "desc") - Sort direction

**Response:** `ApiResponse<Page<CoupletBookmarkResponse>>`

**Example Request:**
```http
GET /api/users/me/couplets/bookmarked?page=0&size=20
Authorization: Bearer <token>
```

**Response format is same as liked couplets, but with `bookmarkedAt` instead of `likedAt`**

---

### 9. Get Most Liked Couplets

Get most liked couplets globally or by a specific poet.

**Endpoint:** `GET /api/analytics/couplets/most-liked`

**Query Parameters:**
- `poetId` (string, optional) - Filter by poet's public ID
- `page` (int, optional, default: 0) - Page number
- `size` (int, optional, default: 20) - Page size

**Response:** `ApiResponse<Page<CoupletAnalyticsResponse>>`

**Example Request:**
```http
GET /api/analytics/couplets/most-liked?page=0&size=10
Authorization: Bearer <token>

# Filter by poet
GET /api/analytics/couplets/most-liked?poetId=faiz-uuid&page=0&size=10
```

**Example Response:**
```json
{
  "success": true,
  "message": "Most liked couplets retrieved",
  "data": {
    "content": [
      {
        "coupletPublicId": "couplet-uuid",
        "coupletNumber": 1,
        "verseTexts": ["verse 1", "verse 2"],
        "poemTitle": "Famous Poem",
        "poetName": "Faiz Ahmed Faiz",
        "likeCount": 5000,
        "shareCount": 2000,
        "popularityScore": 11500.0,
        "rank": 1
      }
    ],
    "totalElements": 100
  }
}
```

---

### 10. Get Most Shared Couplets

Get most shared couplets globally or by a specific poet.

**Endpoint:** `GET /api/analytics/couplets/most-shared`

**Query Parameters:**
- `poetId` (string, optional) - Filter by poet's public ID
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 20)

**Response:** `ApiResponse<Page<CoupletAnalyticsResponse>>`

**Example Request:**
```http
GET /api/analytics/couplets/most-shared?page=0&size=10
Authorization: Bearer <token>
```

---

### 11. Get Trending Couplets

Get trending couplets based on recent engagement.

**Endpoint:** `GET /api/analytics/couplets/trending`

**Query Parameters:**
- `days` (int, optional, default: 7) - Time window in days
- `page` (int, optional, default: 0)
- `size` (int, optional, default: 20)

**Response:** `ApiResponse<Page<CoupletAnalyticsResponse>>`

**Example Request:**
```http
GET /api/analytics/couplets/trending?days=7&page=0&size=20
Authorization: Bearer <token>
```

**Example Response:**
```json
{
  "success": true,
  "message": "Trending couplets retrieved",
  "data": {
    "content": [
      {
        "coupletPublicId": "trending-couplet-uuid",
        "verseTexts": ["verse 1", "verse 2"],
        "poetName": "Poet Name",
        "likeCount": 450,
        "shareCount": 200,
        "popularityScore": 1150.0
      }
    ]
  }
}
```

---

## Error Handling

### HTTP Status Codes

- `200 OK` - Request successful
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Missing or invalid authentication
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

### Error Response Format

```json
{
  "success": false,
  "message": "Couplet not found: invalid-uuid",
  "data": null
}
```

### Flutter Error Handling

```dart
Future<CoupletDetailResponse> getCouplet(String id) async {
  try {
    final response = await dio.get('/api/couplets/$id');

    if (response.data['success']) {
      return CoupletDetailResponse.fromJson(response.data['data']);
    }
    throw ApiException(response.data['message']);
  } on DioException catch (e) {
    if (e.response?.statusCode == 404) {
      throw CoupletNotFoundException();
    } else if (e.response?.statusCode == 401) {
      throw UnauthorizedException();
    }
    throw NetworkException(e.message);
  }
}
```

---

## Deep Linking

### URL Scheme
```
poetryapp://poem/{poemPublicId}?couplet={coupletNumber}&highlight=true
```

### Implementation in Flutter

**1. Add uni_links package:**
```yaml
dependencies:
  uni_links: ^0.5.1
```

**2. Configure AndroidManifest.xml:**
```xml
<intent-filter>
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.DEFAULT" />
    <category android:name="android.intent.BROWSABLE" />
    <data android:scheme="poetryapp" android:host="poem" />
</intent-filter>
```

**3. Configure Info.plist (iOS):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>poetryapp</string>
        </array>
    </dict>
</array>
```

**4. Handle Deep Links:**
```dart
import 'package:uni_links/uni_links.dart';

class DeepLinkHandler {
  StreamSubscription? _sub;

  void initDeepLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle app opened from terminated state
    getInitialUri().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'poetryapp' && uri.host == 'poem') {
      final poemId = uri.pathSegments.first;
      final coupletNumber = int.tryParse(uri.queryParameters['couplet'] ?? '');
      final shouldHighlight = uri.queryParameters['highlight'] == 'true';

      // Navigate to poem screen with couplet highlighted
      Navigator.pushNamed(
        context,
        '/poem',
        arguments: PoemScreenArgs(
          poemId: poemId,
          scrollToCouplet: coupletNumber,
          highlightCouplet: shouldHighlight,
        ),
      );
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
```

---

## Usage Examples

### Complete Couplet Card Widget

```dart
class CoupletCard extends StatefulWidget {
  final CoupletDetailResponse couplet;

  const CoupletCard({required this.couplet});

  @override
  _CoupletCardState createState() => _CoupletCardState();
}

class _CoupletCardState extends State<CoupletCard> {
  late bool _isLiked;
  late bool _isBookmarked;
  late int _likeCount;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.couplet.isLikedByCurrentUser ?? false;
    _isBookmarked = widget.couplet.isBookmarkedByCurrentUser ?? false;
    _likeCount = widget.couplet.likeCount;
  }

  Future<void> _toggleLike() async {
    try {
      final updated = await CoupletApi.toggleLike(widget.couplet.publicId);
      setState(() {
        _isLiked = updated.isLikedByCurrentUser ?? false;
        _likeCount = updated.likeCount;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _toggleBookmark() async {
    try {
      final updated = await CoupletApi.toggleBookmark(widget.couplet.publicId);
      setState(() {
        _isBookmarked = updated.isBookmarkedByCurrentUser ?? false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _share() async {
    try {
      final shareData = await CoupletApi.createShareLink(
        widget.couplet.publicId,
        'WHATSAPP',
      );
      await Share.share(shareData.shareText);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Couplet type badge
            if (widget.couplet.coupletTypeName.isNotEmpty)
              Chip(
                label: Text(widget.couplet.coupletTypeName),
                backgroundColor: Colors.purple.shade100,
              ),

            SizedBox(height: 8),

            // Verses
            ...widget.couplet.verses.map((verse) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                verse.verseText,
                style: TextStyle(fontSize: 18, height: 1.8),
                textAlign: TextAlign.right,
              ),
            )),

            SizedBox(height: 12),

            // Poet attribution
            Text(
              '- ${widget.couplet.poetName}',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade700,
              ),
            ),

            SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red : null,
                      ),
                      onPressed: _toggleLike,
                    ),
                    Text('$_likeCount'),
                    SizedBox(width: 16),
                    IconButton(
                      icon: Icon(
                        _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                        color: _isBookmarked ? Colors.blue : null,
                      ),
                      onPressed: _toggleBookmark,
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.share),
                  onPressed: _share,
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

### API Service Class

```dart
class CoupletApi {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://poetry.app/api',
  ));

  static void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static Future<List<CoupletDto>> getCoupletsByPoem(String poemId) async {
    final response = await _dio.get('/poems/$poemId/couplets');
    if (response.data['success']) {
      return (response.data['data'] as List)
          .map((json) => CoupletDto.fromJson(json))
          .toList();
    }
    throw ApiException(response.data['message']);
  }

  static Future<CoupletDetailResponse> getCouplet(String coupletId) async {
    final response = await _dio.get('/couplets/$coupletId');
    if (response.data['success']) {
      return CoupletDetailResponse.fromJson(response.data['data']);
    }
    throw ApiException(response.data['message']);
  }

  static Future<CoupletDetailResponse> toggleLike(String coupletId) async {
    final response = await _dio.post('/couplets/$coupletId/like');
    if (response.data['success']) {
      return CoupletDetailResponse.fromJson(response.data['data']);
    }
    throw ApiException(response.data['message']);
  }

  static Future<CoupletDetailResponse> toggleBookmark(String coupletId) async {
    final response = await _dio.post('/couplets/$coupletId/bookmark');
    if (response.data['success']) {
      return CoupletDetailResponse.fromJson(response.data['data']);
    }
    throw ApiException(response.data['message']);
  }

  static Future<CoupletShareLinkResponse> createShareLink(
    String coupletId,
    String shareType,
  ) async {
    final response = await _dio.post(
      '/couplets/$coupletId/share',
      data: {'shareType': shareType, 'platform': 'MOBILE'},
    );
    if (response.data['success']) {
      return CoupletShareLinkResponse.fromJson(response.data['data']);
    }
    throw ApiException(response.data['message']);
  }

  static Future<Page<CoupletLikeResponse>> getUserLikedCouplets({
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/users/me/couplets/liked',
      queryParameters: {'page': page, 'size': size},
    );
    if (response.data['success']) {
      return Page<CoupletLikeResponse>.fromJson(
        response.data['data'],
        (json) => CoupletLikeResponse.fromJson(json),
      );
    }
    throw ApiException(response.data['message']);
  }

  static Future<Page<CoupletAnalyticsResponse>> getTrendingCouplets({
    int days = 7,
    int page = 0,
    int size = 20,
  }) async {
    final response = await _dio.get(
      '/analytics/couplets/trending',
      queryParameters: {'days': days, 'page': page, 'size': size},
    );
    if (response.data['success']) {
      return Page<CoupletAnalyticsResponse>.fromJson(
        response.data['data'],
        (json) => CoupletAnalyticsResponse.fromJson(json),
      );
    }
    throw ApiException(response.data['message']);
  }
}
```

---

## Best Practices

### 1. Optimistic Updates
```dart
void _toggleLike() async {
  // Optimistic update
  setState(() {
    _isLiked = !_isLiked;
    _likeCount += _isLiked ? 1 : -1;
  });

  try {
    final updated = await CoupletApi.toggleLike(widget.coupletId);
    // Sync with server response
    setState(() {
      _isLiked = updated.isLikedByCurrentUser ?? false;
      _likeCount = updated.likeCount;
    });
  } catch (e) {
    // Revert on error
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });
    showError(e);
  }
}
```

### 2. Caching
```dart
class CoupletCache {
  static final Map<String, CoupletDetailResponse> _cache = {};

  static CoupletDetailResponse? get(String id) => _cache[id];

  static void set(String id, CoupletDetailResponse couplet) {
    _cache[id] = couplet;
  }

  static void invalidate(String id) {
    _cache.remove(id);
  }
}
```

### 3. Pagination
Use infinite scroll pattern as shown in the examples above.

### 4. Error Retry
```dart
Future<T> _retry<T>(Future<T> Function() fn, {int maxAttempts = 3}) async {
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (e) {
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: attempt));
    }
  }
  throw Exception('Max retries exceeded');
}
```

---

## Support

For API issues or questions, contact:
- Backend Team: backend@poetry.app
- Documentation: https://docs.poetry.app

---

**Last Updated:** 2024-01-20
**API Version:** 1.0.0
