# User Engagement Features API Documentation

**Version:** 1.0
**Date:** December 6, 2025
**For:** Flutter Development Team

This document provides complete API specifications for the newly implemented user engagement features in the Poetry Backend.

---

## Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Comments System](#comments-system)
4. [Share Functionality](#share-functionality)
5. [Poet Follow System](#poet-follow-system)
6. [Enhanced Bookmarks & Likes](#enhanced-bookmarks--likes)
7. [Engagement Tracking](#engagement-tracking)
8. [Error Handling](#error-handling)
9. [Data Models](#data-models)

---

## Overview

### New Features Implemented

1. **Threaded Comments** - Users can comment on poems and reply to comments
2. **Share Functionality** - Generate share links with deep linking support
3. **Poet Follow/Favorite** - Users can follow their favorite poets
4. **Enhanced Bookmarks/Likes** - Searchable and filterable bookmarks
5. **Comprehensive Engagement Tracking** - Track all user interactions for personalization

### Base URL

```
Development: http://localhost:8080
Production: https://api.yourpoetryapp.com
```

### Response Format

All endpoints return responses in the following format:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { /* Response data */ },
  "timestamp": "2025-12-06T10:30:00"
}
```

Error responses:

```json
{
  "success": false,
  "message": "Error description",
  "data": null,
  "timestamp": "2025-12-06T10:30:00"
}
```

---

## Authentication

All protected endpoints require JWT authentication.

### Headers Required

```http
Authorization: Bearer YOUR_JWT_TOKEN
Content-Type: application/json
```

### Getting User Context

The backend automatically extracts user information from the JWT token. You don't need to send user IDs in request bodies for protected endpoints.

---

## Comments System

### 1. Create Comment or Reply

**Endpoint:** `POST /api/poems/{poemPublicId}/comments`

**Description:** Create a new comment on a poem or reply to an existing comment.

**Authentication:** Required

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem

**Request Body:**

```json
{
  "commentText": "Beautiful ghazal! The metaphors are stunning.",
  "parentCommentPublicId": null
}
```

For replies, include the parent comment's public ID:

```json
{
  "commentText": "I agree! Especially the first couplet.",
  "parentCommentPublicId": "comment-xyz789"
}
```

**Validation:**
- `commentText`: Required, 1-5000 characters
- `parentCommentPublicId`: Optional, must be a valid comment ID

**Success Response (201 Created):**

```json
{
  "success": true,
  "message": "Comment posted successfully",
  "data": {
    "publicId": "comment-abc123",
    "commentText": "Beautiful ghazal! The metaphors are stunning.",
    "userPublicId": "user-456",
    "username": "poetry_lover",
    "userProfileImageUrl": "https://cdn.example.com/profiles/user-456.jpg",
    "poemPublicId": "poem-abc123",
    "poemTitle": "Dil ki duniya mein",
    "parentCommentPublicId": null,
    "parentCommentUsername": null,
    "replies": [],
    "replyCount": 0,
    "isDeleted": false,
    "isOwnComment": true,
    "createdAt": "2025-12-06T10:30:00",
    "updatedAt": "2025-12-06T10:30:00"
  }
}
```

**Flutter Implementation Notes:**
- Show loading indicator while posting
- Optimistically add comment to UI before server response
- Handle validation errors (empty text, too long)
- Support @ mentions in future (use regex to detect @username)

---

### 2. Get Comments for a Poem

**Endpoint:** `GET /api/poems/{poemPublicId}/comments`

**Description:** Retrieve paginated comments with nested replies (threaded view).

**Authentication:** Optional (works for anonymous users, but `isOwnComment` will be false)

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem

**Query Parameters:**
- `page` (int, default: 0) - Page number
- `size` (int, default: 10) - Page size
- `sortBy` (string, default: "createdAt") - Sort field
- `sortDir` (string, default: "desc") - Sort direction (asc|desc)

**Example Request:**

```http
GET /api/poems/poem-abc123/comments?page=0&size=10&sortBy=createdAt&sortDir=desc
```

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Retrieved 25 comments",
  "data": {
    "content": [
      {
        "publicId": "comment-001",
        "commentText": "Beautiful poem!",
        "userPublicId": "user-123",
        "username": "sara_k",
        "userProfileImageUrl": "https://cdn.example.com/profiles/user-123.jpg",
        "poemPublicId": "poem-abc123",
        "poemTitle": "Dil ki duniya mein",
        "parentCommentPublicId": null,
        "parentCommentUsername": null,
        "replies": [
          {
            "publicId": "comment-002",
            "commentText": "I agree!",
            "userPublicId": "user-456",
            "username": "ahmad_m",
            "userProfileImageUrl": null,
            "poemPublicId": "poem-abc123",
            "poemTitle": "Dil ki duniya mein",
            "parentCommentPublicId": "comment-001",
            "parentCommentUsername": "sara_k",
            "replies": [],
            "replyCount": 0,
            "isDeleted": false,
            "isOwnComment": false,
            "createdAt": "2025-12-06T10:35:00",
            "updatedAt": "2025-12-06T10:35:00"
          }
        ],
        "replyCount": 1,
        "isDeleted": false,
        "isOwnComment": false,
        "createdAt": "2025-12-06T10:30:00",
        "updatedAt": "2025-12-06T10:30:00"
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
    "totalElements": 25,
    "last": false,
    "first": true,
    "size": 10,
    "number": 0,
    "numberOfElements": 10,
    "empty": false
  }
}
```

**Flutter Implementation Notes:**
- Use `ListView.builder` with pagination
- Implement "Load More" button or infinite scroll
- Render replies in a nested structure (indented or threaded UI)
- Show "View N replies" button to expand/collapse replies
- Cache comments locally to reduce API calls

---

### 3. Delete Comment

**Endpoint:** `DELETE /api/poems/{poemPublicId}/comments/{commentPublicId}`

**Description:** Soft delete a comment. Only the comment owner can delete. Deleted comments show as "[deleted]" but maintain thread structure.

**Authentication:** Required

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem
- `commentPublicId` (string) - The public ID of the comment

**Example Request:**

```http
DELETE /api/poems/poem-abc123/comments/comment-xyz789
```

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Comment deleted successfully",
  "data": {
    "deleted": true
  }
}
```

**Error Response (400 Bad Request):**

```json
{
  "success": false,
  "message": "You can only delete your own comments"
}
```

**Flutter Implementation Notes:**
- Show confirmation dialog before deleting
- Update UI to show "[deleted]" instead of removing the comment
- Disable delete button for comments that aren't owned by current user

---

### 4. Get Comment Count

**Endpoint:** `GET /api/poems/{poemPublicId}/comments/count`

**Description:** Get total comment count for a poem.

**Authentication:** Not required

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Comment count retrieved successfully",
  "data": {
    "count": 42
  }
}
```

**Flutter Implementation Notes:**
- Display count on poem detail page
- Update count after posting/deleting comments
- Show "No comments yet" when count is 0

---

## Share Functionality

### 1. Create Share and Generate Link

**Endpoint:** `POST /api/poems/{poemPublicId}/share`

**Description:** Track a share action and generate share link with tracking token and deep link.

**Authentication:** Required

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem

**Request Body:**

```json
{
  "shareType": "WHATSAPP",
  "platform": "MOBILE"
}
```

**Share Types (enum):**
- `LINK` - Generic share link
- `DEEP_LINK` - Mobile app deep link
- `FACEBOOK` - Share to Facebook
- `WHATSAPP` - Share to WhatsApp
- `TWITTER` - Share to Twitter/X
- `TELEGRAM` - Share to Telegram
- `EMAIL` - Share via Email
- `INSTAGRAM` - Share to Instagram
- `COPY` - Copy to clipboard
- `OTHER` - Other share method

**Platform Values:**
- `MOBILE` - Mobile device
- `WEB` - Web browser
- `TABLET` - Tablet device

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Share link generated successfully",
  "data": {
    "shareUrl": "https://poetry.app/poems/poem-abc123?ref=a1b2c3d4",
    "deepLink": "poetryapp://poem/poem-abc123",
    "shareToken": "a1b2c3d4",
    "poemPublicId": "poem-abc123",
    "ogTitle": "Dil ki duniya mein - Mirza Ghalib",
    "ogDescription": "محبت میں نہیں ہے فرق جینے اور مرنے کا\nاسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے...",
    "ogImage": "https://cdn.example.com/poems/poem-abc123-thumb.jpg",
    "ogUrl": "https://poetry.app/poems/poem-abc123?ref=a1b2c3d4",
    "shareText": "Dil ki duniya mein - Mirza Ghalib\n\nhttps://poetry.app/poems/poem-abc123?ref=a1b2c3d4"
  }
}
```

**Flutter Implementation Notes:**

```dart
// Example: Share to WhatsApp
void shareToWhatsApp(String poemId) async {
  final response = await apiClient.post(
    '/api/poems/$poemId/share',
    body: {
      'shareType': 'WHATSAPP',
      'platform': 'MOBILE',
    },
  );

  final shareData = response['data'];

  // Use share_plus package
  await Share.share(
    shareData['shareText'],
    subject: shareData['ogTitle'],
  );

  // Or use URL launcher for WhatsApp
  final whatsappUrl = 'whatsapp://send?text=${Uri.encodeComponent(shareData['shareText'])}';
  await launchUrl(Uri.parse(whatsappUrl));
}

// Example: Deep link for internal navigation
void shareWithDeepLink(String poemId) async {
  final response = await apiClient.post('/api/poems/$poemId/share', ...);
  final deepLink = response['data']['deepLink'];

  // Use this for SMS, Email, or copying to clipboard
  await Clipboard.setData(ClipboardData(text: deepLink));
  showSnackbar('Link copied! Share it anywhere.');
}
```

**Share Dialog Implementation:**

```dart
void showShareDialog(BuildContext context, String poemId) {
  showModalBottomSheet(
    context: context,
    builder: (context) => ShareBottomSheet(
      options: [
        ShareOption('WhatsApp', ShareType.WHATSAPP, Icons.whatsapp),
        ShareOption('Facebook', ShareType.FACEBOOK, Icons.facebook),
        ShareOption('Twitter', ShareType.TWITTER, Icons.twitter),
        ShareOption('Copy Link', ShareType.COPY, Icons.copy),
        ShareOption('More...', ShareType.OTHER, Icons.share),
      ],
      onShare: (type) async {
        await sharePoem(poemId, type);
      },
    ),
  );
}
```

---

### 2. Get Public Share Link

**Endpoint:** `GET /api/poems/{poemPublicId}/share-link`

**Description:** Get share link without tracking (for anonymous users or quick sharing).

**Authentication:** Not required

**Success Response (200 OK):**

Same structure as create share endpoint, but with generic `shareToken: "public"`.

**Flutter Implementation Notes:**
- Use this for "Quick Share" button that doesn't require login
- Fallback when user is not authenticated

---

## Poet Follow System

### 1. Toggle Follow/Unfollow

**Endpoint:** `POST /api/poets/{poetPublicId}/follow`

**Description:** Follow or unfollow a poet (toggle).

**Authentication:** Required

**Path Parameters:**
- `poetPublicId` (string) - The public ID of the poet

**Success Response (200 OK):**

When following:
```json
{
  "success": true,
  "message": "Poet followed successfully",
  "data": {
    "following": true
  }
}
```

When unfollowing:
```json
{
  "success": true,
  "message": "Poet unfollowed successfully",
  "data": {
    "following": false
  }
}
```

**Flutter Implementation Notes:**

```dart
class PoetFollowButton extends StatefulWidget {
  final String poetId;
  final bool initialFollowing;

  @override
  _PoetFollowButtonState createState() => _PoetFollowButtonState();
}

class _PoetFollowButtonState extends State<PoetFollowButton> {
  late bool isFollowing;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    isFollowing = widget.initialFollowing;
  }

  Future<void> toggleFollow() async {
    setState(() => isLoading = true);

    try {
      final response = await apiClient.post('/api/poets/${widget.poetId}/follow');
      setState(() {
        isFollowing = response['data']['following'];
      });

      showSnackbar(isFollowing
          ? 'You are now following this poet'
          : 'Unfollowed');
    } catch (e) {
      showError('Failed to update follow status');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : toggleFollow,
      icon: Icon(isFollowing ? Icons.favorite : Icons.favorite_border),
      label: Text(isFollowing ? 'Following' : 'Follow'),
      style: ElevatedButton.styleFrom(
        backgroundColor: isFollowing ? Colors.red : Colors.grey,
      ),
    );
  }
}
```

---

### 2. Check Follow Status

**Endpoint:** `GET /api/poets/{poetPublicId}/is-following`

**Description:** Check if current user is following a poet.

**Authentication:** Required

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Follow status retrieved successfully",
  "data": {
    "following": true
  }
}
```

**Flutter Implementation Notes:**
- Call this when loading poet detail page
- Use to set initial state of follow button

---

### 3. Get Follower Count

**Endpoint:** `GET /api/poets/{poetPublicId}/follower-count`

**Description:** Get total follower count for a poet.

**Authentication:** Not required

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Follower count retrieved successfully",
  "data": {
    "count": 1523
  }
}
```

**Flutter Implementation Notes:**
- Display count on poet profile page
- Format large numbers (1.5K, 10K, etc.)
- Update count after follow/unfollow

---

### 4. Get Followed Poets (User's Following List)

**Endpoint:** `GET /api/users/me/following`

**Description:** Get list of poets that current user is following (searchable).

**Authentication:** Required

**Query Parameters:**
- `query` (string, optional) - Search query for poet name
- `page` (int, default: 0) - Page number
- `size` (int, default: 20) - Page size

**Example Request:**

```http
GET /api/users/me/following?query=ghalib&page=0&size=20
```

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Followed poets retrieved successfully",
  "data": {
    "content": [
      {
        "poetPublicId": "poet-ghalib-001",
        "poetName": "Mirza Ghalib",
        "poetNameUrdu": "مرزا غالب",
        "poetNameEnglish": "Mirza Ghalib",
        "poetNameHindi": "मिर्ज़ा ग़ालिब",
        "profileImageUrl": "https://cdn.example.com/poets/ghalib.jpg",
        "bio": "One of the most influential Urdu poets...",
        "birthDate": "1797-12-27",
        "deathDate": "1869-02-15",
        "birthPlace": "agra",
        "poemCount": 245,
        "followerCount": 15234,
        "followedAt": "2025-11-15T08:20:00",
        "isFollowing": true
      }
    ],
    "totalElements": 12,
    "totalPages": 1,
    "size": 20,
    "number": 0
  }
}
```

**Flutter Implementation Notes:**
- Create a "Following" tab in user profile
- Implement search bar for filtering followed poets
- Show empty state when user isn't following anyone
- Allow quick unfollow from this list

---

## Enhanced Bookmarks & Likes

### 1. Toggle Bookmark

**Endpoint:** `POST /api/poems/{poemPublicId}/bookmark`

**Description:** Add or remove a bookmark for a poem. This endpoint acts as a toggle - if the poem is already bookmarked, it will remove the bookmark; if not, it will add one.

**Authentication:** Required

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem

**Request Body:** None required

**Example Request:**

```http
POST /api/poems/abc123/bookmark
Authorization: Bearer YOUR_JWT_TOKEN
```

**Success Response (200 OK):**

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

**When removing bookmark:**

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

**Flutter Implementation:**

```dart
Future<bool> toggleBookmark(String poemPublicId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/poems/$poemPublicId/bookmark'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['bookmarked'] as bool;
  }
  throw Exception('Failed to toggle bookmark');
}
```

---

### 2. Toggle Like

**Endpoint:** `POST /api/poems/{poemPublicId}/like`

**Description:** Add or remove a like for a poem. This endpoint acts as a toggle - if the poem is already liked, it will remove the like; if not, it will add one.

**Authentication:** Required

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem

**Request Body:** None required

**Example Request:**

```http
POST /api/poems/abc123/like
Authorization: Bearer YOUR_JWT_TOKEN
```

**Success Response (200 OK):**

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

**When removing like:**

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

**Flutter Implementation:**

```dart
Future<bool> toggleLike(String poemPublicId) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/poems/$poemPublicId/like'),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['liked'] as bool;
  }
  throw Exception('Failed to toggle like');
}
```

---

### 3. Check Bookmark/Like Status

**Endpoint:** `GET /api/poems/{poemPublicId}/status`

**Description:** Check if the current user has bookmarked or liked a specific poem.

**Authentication:** Required

**Path Parameters:**
- `poemPublicId` (string) - The public ID of the poem

**Example Request:**

```http
GET /api/poems/abc123/status
Authorization: Bearer YOUR_JWT_TOKEN
```

**Success Response (200 OK):**

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

### 4. Get User's Bookmarks (Enhanced)

**Endpoint:** `GET /api/users/me/bookmarks`

**Description:** Get user's bookmarked poems with search and filter capabilities.

**Authentication:** Required

**Query Parameters:**
- `query` (string, optional) - Search query for poem title or poet name
- `poetryType` (string, optional) - Filter by poetry type (GHAZAL, NAZAM, etc.)
- `poetId` (string, optional) - Filter by poet public ID
- `page` (int, default: 0) - Page number
- `size` (int, default: 20) - Page size
- `sortBy` (string, default: "createdAt") - Sort field
- `sortDir` (string, default: "desc") - Sort direction

**Example Requests:**

```http
# All bookmarks
GET /api/users/me/bookmarks?page=0&size=20

# Search bookmarks
GET /api/users/me/bookmarks?query=mohabbat&page=0&size=20

# Filter by poetry type
GET /api/users/me/bookmarks?poetryType=GHAZAL&page=0&size=20

# Filter by poet
GET /api/users/me/bookmarks?poetId=ghalib-001&page=0&size=20

# Combined filters
GET /api/users/me/bookmarks?query=dil&poetryType=GHAZAL&poetId=mir-001&sortBy=createdAt&sortDir=desc
```

**Success Response (200 OK):**

```json
{
  "success": true,
  "message": "Bookmarks retrieved successfully",
  "data": {
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
        "poetryTypeName": "غزل",
        "yearWritten": 1850,
        "contentType": "TEXT",
        "thumbnailUrl": "-",
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 234,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": true,
        "createdAt": "2025-10-15T10:30:00",
        "updatedAt": "2025-12-05T14:20:00"
      }
    ],
    "totalElements": 45,
    "totalPages": 3,
    "size": 20,
    "number": 0
  }
}
```

**Flutter Implementation Notes:**

```dart
// Bookmarks Screen with Search and Filters
class BookmarksScreen extends StatefulWidget {
  @override
  _BookmarksScreenState createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  String searchQuery = '';
  PoetryType? selectedType;
  String? selectedPoetId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookmarks'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search bookmarks...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
                _debounceSearch();
              },
            ),
          ),

          // Filter chips
          if (selectedType != null || selectedPoetId != null)
            Wrap(
              children: [
                if (selectedType != null)
                  FilterChip(
                    label: Text(selectedType!.name),
                    onDeleted: () => setState(() => selectedType = null),
                  ),
                if (selectedPoetId != null)
                  FilterChip(
                    label: Text('By Poet'),
                    onDeleted: () => setState(() => selectedPoetId = null),
                  ),
              ],
            ),

          // Bookmarked poems list
          Expanded(
            child: FutureBuilder<BookmarksResponse>(
              future: fetchBookmarks(
                query: searchQuery,
                poetryType: selectedType,
                poetId: selectedPoetId,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PoemsList(poems: snapshot.data!.poems);
                }
                return LoadingIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

---

### 2. Get User's Likes (Enhanced)

**Endpoint:** `GET /api/users/me/likes`

**Description:** Same functionality as bookmarks endpoint, but for liked poems.

**Parameters:** Same as bookmarks endpoint above.

---

## Engagement Tracking

### Background Tracking

The backend automatically tracks user engagement for personalization. You should send tracking data for certain actions:

### Actions to Track from Flutter

1. **View Duration** - Track time spent on poem detail page
2. **Reading Completion** - Track how much of the poem was read (scroll depth)
3. **Language Changes** - Track when user changes language preference
4. **Filter/Sort Changes** - Track filter and sort preferences
5. **Search Behavior** - Track search queries and clicked results
6. **Navigation Patterns** - Track screen flow

### Engagement Tracking Headers

For actions that support engagement tracking, send these headers:

```http
X-Session-Id: uuid-of-session
X-Device-Type: MOBILE
X-Duration-Seconds: 45
```

**Flutter Implementation:**

```dart
class EngagementTracker {
  static const _sessionDuration = Duration(minutes: 30);
  String? _currentSessionId;
  DateTime? _sessionStartTime;

  String getOrCreateSessionId() {
    if (_currentSessionId == null || _isSessionExpired()) {
      _currentSessionId = Uuid().v4();
      _sessionStartTime = DateTime.now();
    }
    return _currentSessionId!;
  }

  bool _isSessionExpired() {
    if (_sessionStartTime == null) return true;
    return DateTime.now().difference(_sessionStartTime!) > _sessionDuration;
  }

  Map<String, String> getTrackingHeaders() {
    return {
      'X-Session-Id': getOrCreateSessionId(),
      'X-Device-Type': Platform.isIOS ? 'IOS' : 'ANDROID',
    };
  }
}

// Track poem view duration
class PoemDetailPage extends StatefulWidget {
  final String poemId;

  @override
  _PoemDetailPageState createState() => _PoemDetailPageState();
}

class _PoemDetailPageState extends State<PoemDetailPage> {
  DateTime? viewStartTime;

  @override
  void initState() {
    super.initState();
    viewStartTime = DateTime.now();
  }

  @override
  void dispose() {
    _trackViewDuration();
    super.dispose();
  }

  Future<void> _trackViewDuration() async {
    if (viewStartTime != null) {
      final duration = DateTime.now().difference(viewStartTime!);
      final headers = {
        ...EngagementTracker().getTrackingHeaders(),
        'X-Duration-Seconds': duration.inSeconds.toString(),
      };

      // Send to backend (backend handles this automatically for views)
      // You can also send custom tracking events if needed
    }
  }
}
```

---

## Error Handling

### Common Error Responses

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Validation error: Comment text is required"
}
```

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "Authentication required"
}
```

**403 Forbidden:**
```json
{
  "success": false,
  "message": "You can only delete your own comments"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Poem not found: poem-xyz"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "An unexpected error occurred"
}
```

### Flutter Error Handling

```dart
class ApiClient {
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          ...EngagementTracker().getTrackingHeaders(),
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        throw ApiException(
          statusCode: response.statusCode,
          message: data['message'] ?? 'Unknown error',
        );
      }
    } on SocketException {
      throw ApiException(
        statusCode: 0,
        message: 'No internet connection',
      );
    } catch (e) {
      rethrow;
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException({required this.statusCode, required this.message});

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isValidationError => statusCode == 400;
}
```

---

## Data Models

### Dart Model Classes

Here are the Dart model classes you'll need:

```dart
// Comment Model
class Comment {
  final String publicId;
  final String commentText;
  final String userPublicId;
  final String username;
  final String? userProfileImageUrl;
  final String poemPublicId;
  final String poemTitle;
  final String? parentCommentPublicId;
  final String? parentCommentUsername;
  final List<Comment> replies;
  final int replyCount;
  final bool isDeleted;
  final bool isOwnComment;
  final DateTime createdAt;
  final DateTime updatedAt;

  Comment({
    required this.publicId,
    required this.commentText,
    required this.userPublicId,
    required this.username,
    this.userProfileImageUrl,
    required this.poemPublicId,
    required this.poemTitle,
    this.parentCommentPublicId,
    this.parentCommentUsername,
    this.replies = const [],
    this.replyCount = 0,
    this.isDeleted = false,
    this.isOwnComment = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      publicId: json['publicId'],
      commentText: json['commentText'],
      userPublicId: json['userPublicId'],
      username: json['username'],
      userProfileImageUrl: json['userProfileImageUrl'],
      poemPublicId: json['poemPublicId'],
      poemTitle: json['poemTitle'],
      parentCommentPublicId: json['parentCommentPublicId'],
      parentCommentUsername: json['parentCommentUsername'],
      replies: (json['replies'] as List?)
          ?.map((e) => Comment.fromJson(e))
          .toList() ?? [],
      replyCount: json['replyCount'] ?? 0,
      isDeleted: json['isDeleted'] ?? false,
      isOwnComment: json['isOwnComment'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

// Share Link Response Model
class ShareLinkResponse {
  final String shareUrl;
  final String deepLink;
  final String shareToken;
  final String poemPublicId;
  final String ogTitle;
  final String ogDescription;
  final String ogImage;
  final String ogUrl;
  final String shareText;

  ShareLinkResponse({
    required this.shareUrl,
    required this.deepLink,
    required this.shareToken,
    required this.poemPublicId,
    required this.ogTitle,
    required this.ogDescription,
    required this.ogImage,
    required this.ogUrl,
    required this.shareText,
  });

  factory ShareLinkResponse.fromJson(Map<String, dynamic> json) {
    return ShareLinkResponse(
      shareUrl: json['shareUrl'],
      deepLink: json['deepLink'],
      shareToken: json['shareToken'],
      poemPublicId: json['poemPublicId'],
      ogTitle: json['ogTitle'],
      ogDescription: json['ogDescription'],
      ogImage: json['ogImage'],
      ogUrl: json['ogUrl'],
      shareText: json['shareText'],
    );
  }
}

// Followed Poet Model
class FollowedPoet {
  final String poetPublicId;
  final String poetName;
  final String poetNameUrdu;
  final String poetNameEnglish;
  final String poetNameHindi;
  final String profileImageUrl;
  final String bio;
  final DateTime? birthDate;
  final DateTime? deathDate;
  final String? birthPlace;
  final int poemCount;
  final int followerCount;
  final DateTime followedAt;
  final bool isFollowing;

  FollowedPoet({
    required this.poetPublicId,
    required this.poetName,
    required this.poetNameUrdu,
    required this.poetNameEnglish,
    required this.poetNameHindi,
    required this.profileImageUrl,
    required this.bio,
    this.birthDate,
    this.deathDate,
    this.birthPlace,
    this.poemCount = 0,
    this.followerCount = 0,
    required this.followedAt,
    this.isFollowing = true,
  });

  factory FollowedPoet.fromJson(Map<String, dynamic> json) {
    return FollowedPoet(
      poetPublicId: json['poetPublicId'],
      poetName: json['poetName'],
      poetNameUrdu: json['poetNameUrdu'],
      poetNameEnglish: json['poetNameEnglish'],
      poetNameHindi: json['poetNameHindi'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      deathDate: json['deathDate'] != null
          ? DateTime.parse(json['deathDate'])
          : null,
      birthPlace: json['birthPlace'],
      poemCount: json['poemCount'] ?? 0,
      followerCount: json['followerCount'] ?? 0,
      followedAt: DateTime.parse(json['followedAt']),
      isFollowing: json['isFollowing'] ?? true,
    );
  }
}

// Share Type Enum
enum ShareType {
  LINK,
  DEEP_LINK,
  FACEBOOK,
  WHATSAPP,
  TWITTER,
  TELEGRAM,
  EMAIL,
  INSTAGRAM,
  COPY,
  OTHER,
}
```

---

## Deep Linking Setup

### Configure Deep Links in Flutter

**1. Android Configuration (`android/app/src/main/AndroidManifest.xml`):**

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />

    <!-- Deep link scheme -->
    <data android:scheme="poetryapp" android:host="poem" />

    <!-- Universal link -->
    <data android:scheme="https" android:host="poetry.app" />
</intent-filter>
```

**2. iOS Configuration (`ios/Runner/Info.plist`):**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLName</key>
        <string>com.yourapp.poetry</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>poetryapp</string>
        </array>
    </dict>
</array>
```

**3. Handle Deep Links in Flutter:**

```dart
import 'package:uni_links/uni_links.dart';

class DeepLinkHandler {
  StreamSubscription? _linkSubscription;

  void initDeepLinks() {
    // Handle initial deep link (cold start)
    getInitialUri().then((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });

    // Handle deep links while app is running
    _linkSubscription = uriLinkStream.listen((uri) {
      if (uri != null) {
        _handleDeepLink(uri);
      }
    });
  }

  void _handleDeepLink(Uri uri) {
    // poetryapp://poem/poem-abc123
    if (uri.scheme == 'poetryapp' && uri.host == 'poem') {
      final poemId = uri.pathSegments.first;
      navigateToPoemDetail(poemId);
    }

    // https://poetry.app/poems/poem-abc123?ref=a1b2c3d4
    if (uri.host == 'poetry.app' && uri.pathSegments.contains('poems')) {
      final poemId = uri.pathSegments.last;
      final shareToken = uri.queryParameters['ref'];

      // Track share click if share token present
      if (shareToken != null) {
        trackShareClick(shareToken);
      }

      navigateToPoemDetail(poemId);
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
```

---

## Testing Checklist

### Comments
- [ ] Create a comment on a poem
- [ ] Reply to a comment
- [ ] Delete own comment
- [ ] Try to delete someone else's comment (should fail)
- [ ] Load more comments (pagination)
- [ ] Collapse/expand threaded replies
- [ ] Handle empty state (no comments)

### Share
- [ ] Share to WhatsApp
- [ ] Share to other platforms
- [ ] Copy link to clipboard
- [ ] Open shared link in browser
- [ ] Open deep link in app
- [ ] Share without authentication (public link)

### Follow
- [ ] Follow a poet
- [ ] Unfollow a poet
- [ ] View followed poets list
- [ ] Search followed poets
- [ ] Check follower count updates
- [ ] Empty state when not following anyone

### Bookmarks & Likes
- [ ] View all bookmarks
- [ ] Search bookmarks
- [ ] Filter bookmarks by poetry type
- [ ] Filter bookmarks by poet
- [ ] Sort bookmarks
- [ ] Empty state when no bookmarks

### Edge Cases
- [ ] Test with poor network connection
- [ ] Test offline mode
- [ ] Test with expired JWT token
- [ ] Test with very long comment text
- [ ] Test with special characters in comments
- [ ] Test rapid follow/unfollow clicks

---

## Performance Recommendations

### 1. Caching Strategy

```dart
class CacheManager {
  static const commentsCacheDuration = Duration(minutes: 5);
  static const followerCountCacheDuration = Duration(minutes: 10);

  final _cache = <String, CachedData>{};

  Future<T> getOrFetch<T>(
    String key,
    Future<T> Function() fetcher,
    Duration cacheDuration,
  ) async {
    final cached = _cache[key];

    if (cached != null && !cached.isExpired(cacheDuration)) {
      return cached.data as T;
    }

    final data = await fetcher();
    _cache[key] = CachedData(data, DateTime.now());
    return data;
  }
}
```

### 2. Pagination Best Practices

- Load 10-20 items per page
- Implement infinite scroll or "Load More" button
- Show skeleton loaders while loading
- Cache previous pages

### 3. Optimistic Updates

```dart
Future<void> toggleFollowOptimistic(String poetId, bool currentState) async {
  // Update UI immediately
  setState(() {
    isFollowing = !currentState;
    followerCount += isFollowing ? 1 : -1;
  });

  try {
    // Make API call
    await apiClient.post('/api/poets/$poetId/follow');
  } catch (e) {
    // Revert on error
    setState(() {
      isFollowing = currentState;
      followerCount += isFollowing ? 1 : -1;
    });
    showError('Failed to update follow status');
  }
}
```

---

## Support & Questions

For questions or issues with the API:

**Backend Team Contact:**
- Email: backend@poetryapp.com
- Slack: #backend-support

**API Documentation:**
- Swagger UI: http://localhost:8080/swagger-ui.html (Development)
- Postman Collection: [Link to Postman Collection]

**Version History:**
- v1.0 (Dec 6, 2025) - Initial release

---

**Happy Coding! 🚀**
