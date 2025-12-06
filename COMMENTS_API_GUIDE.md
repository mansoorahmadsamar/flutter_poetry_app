# Comments API Guide

**Date:** December 6, 2025
**Status:** ✅ APIs Available - Ready for Implementation

---

## Overview

The backend has **fully implemented** threaded comments functionality. Users can:
- Comment on poems
- Reply to comments (threaded/nested replies)
- Edit and delete their own comments
- View paginated comments with nested replies
- Sort comments (newest, oldest, top)

---

## Available Endpoints

### 1. Create Comment or Reply

**POST** `/api/poems/{poemPublicId}/comments`

**Authentication:** Required

**Request Body:**
```json
{
  "commentText": "Beautiful ghazal! The metaphors are stunning.",
  "parentCommentPublicId": null
}
```

For replies:
```json
{
  "commentText": "I agree! Especially the first couplet.",
  "parentCommentPublicId": "comment-xyz789"
}
```

**Validation:**
- `commentText`: Required, 1-5000 characters
- `parentCommentPublicId`: Optional, must be valid comment ID

**Response (201 Created):**
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

---

### 2. Get Comments for a Poem

**GET** `/api/poems/{poemPublicId}/comments`

**Authentication:** Optional (works for anonymous users)

**Query Parameters:**
- `page` (int, default: 0) - Page number
- `size` (int, default: 10) - Page size
- `sortBy` (string, default: "createdAt") - Sort field
- `sortDir` (string, default: "desc") - Sort direction

**Example:**
```http
GET /api/poems/poem-abc123/comments?page=0&size=10&sortBy=createdAt&sortDir=desc
```

**Response (200 OK):**
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
    "totalPages": 3,
    "totalElements": 25,
    "last": false,
    "first": true,
    "size": 10,
    "number": 0
  }
}
```

---

### 3. Update Comment

**PUT** `/api/poems/{poemPublicId}/comments/{commentPublicId}`

**Authentication:** Required (only comment owner can edit)

**Request Body:**
```json
{
  "commentText": "Updated comment text..."
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Comment updated successfully",
  "data": {
    "publicId": "comment-abc123",
    "commentText": "Updated comment text...",
    ...
  }
}
```

---

### 4. Delete Comment

**DELETE** `/api/poems/{poemPublicId}/comments/{commentPublicId}`

**Authentication:** Required (only comment owner can delete)

**Response (200 OK):**
```json
{
  "success": true,
  "message": "Comment deleted successfully",
  "data": null
}
```

**Note:** Comments with replies are soft-deleted (marked as deleted but structure preserved). Comments without replies are hard-deleted (completely removed).

---

### 5. Get Replies for a Comment

**GET** `/api/poems/{poemPublicId}/comments/{commentPublicId}/replies`

**Authentication:** Optional

**Query Parameters:**
- `page` (int, default: 0)
- `size` (int, default: 5)
- `sortBy` (string, default: "createdAt")
- `sortDir` (string, default: "asc")

**Response:** Same structure as get comments

---

## Comment Model Fields

### CommentResponse

| Field | Type | Description |
|-------|------|-------------|
| `publicId` | String | Comment's unique ID |
| `commentText` | String | Comment content (1-5000 chars) |
| `userPublicId` | String | Author's user ID |
| `username` | String | Author's username |
| `userProfileImageUrl` | String? | Author's profile image |
| `poemPublicId` | String | Poem's public ID |
| `poemTitle` | String | Poem's title |
| `parentCommentPublicId` | String? | Parent comment ID (null for top-level) |
| `parentCommentUsername` | String? | Parent comment author |
| `replies` | List<CommentResponse> | Nested replies |
| `replyCount` | int | Number of replies |
| `isDeleted` | bool | Is comment deleted |
| `isOwnComment` | bool | Is current user the author |
| `createdAt` | DateTime | When comment was created |
| `updatedAt` | DateTime | When comment was last updated |

---

## Flutter Implementation Guide

### 1. Create Models

**`lib/features/engagement/models/comment_model.dart`**

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class CommentModel with _$CommentModel {
  const factory CommentModel({
    required String publicId,
    required String commentText,
    required String userPublicId,
    required String username,
    String? userProfileImageUrl,
    required String poemPublicId,
    required String poemTitle,
    String? parentCommentPublicId,
    String? parentCommentUsername,
    @Default([]) List<CommentModel> replies,
    @Default(0) int replyCount,
    @Default(false) bool isDeleted,
    @Default(false) bool isOwnComment,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);
}
```

### 2. Create Service

**`lib/features/engagement/services/comment_service.dart`**

```dart
import 'package:dio/dio.dart';
import '../models/comment_model.dart';
import '../../../core/network/dto/api_response.dart';

class CommentService {
  final Dio _dio;

  CommentService(this._dio);

  /// Get comments for a poem
  Future<PaginatedResponse<CommentModel>> getComments({
    required String poemPublicId,
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String sortDir = 'desc',
  }) async {
    final response = await _dio.get(
      '/api/poems/$poemPublicId/comments',
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDir': sortDir,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return PaginatedResponse<CommentModel>.fromJson(
      apiResponse.data!,
      (json) => CommentModel.fromJson(json as Map<String, dynamic>),
    );
  }

  /// Create a comment or reply
  Future<CommentModel> createComment({
    required String poemPublicId,
    required String commentText,
    String? parentCommentPublicId,
  }) async {
    final response = await _dio.post(
      '/api/poems/$poemPublicId/comments',
      data: {
        'commentText': commentText,
        if (parentCommentPublicId != null)
          'parentCommentPublicId': parentCommentPublicId,
      },
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return CommentModel.fromJson(apiResponse.data!);
  }

  /// Update a comment
  Future<CommentModel> updateComment({
    required String poemPublicId,
    required String commentPublicId,
    required String commentText,
  }) async {
    final response = await _dio.put(
      '/api/poems/$poemPublicId/comments/$commentPublicId',
      data: {'commentText': commentText},
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(
      response.data,
      (json) => json as Map<String, dynamic>,
    );

    if (!apiResponse.success || apiResponse.data == null) {
      throw Exception(apiResponse.message);
    }

    return CommentModel.fromJson(apiResponse.data!);
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String poemPublicId,
    required String commentPublicId,
  }) async {
    final response = await _dio.delete(
      '/api/poems/$poemPublicId/comments/$commentPublicId',
    );

    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );

    if (!apiResponse.success) {
      throw Exception(apiResponse.message);
    }
  }
}
```

### 3. Create Providers

**`lib/features/engagement/providers/comment_providers.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/comment_service.dart';
import '../models/comment_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/dto/api_response.dart';

// Service Provider
final commentServiceProvider = Provider<CommentService>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CommentService(dioClient.dio);
});

// Comments List Provider
class CommentsParams {
  final String poemPublicId;
  final int page;
  final String sortBy;
  final String sortDir;

  CommentsParams({
    required this.poemPublicId,
    this.page = 0,
    this.sortBy = 'createdAt',
    this.sortDir = 'desc',
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CommentsParams &&
          poemPublicId == other.poemPublicId &&
          page == other.page &&
          sortBy == other.sortBy &&
          sortDir == other.sortDir;

  @override
  int get hashCode =>
      poemPublicId.hashCode ^ page.hashCode ^ sortBy.hashCode ^ sortDir.hashCode;
}

final commentsProvider = FutureProvider.autoDispose
    .family<PaginatedResponse<CommentModel>, CommentsParams>(
  (ref, params) async {
    final service = ref.watch(commentServiceProvider);
    return service.getComments(
      poemPublicId: params.poemPublicId,
      page: params.page,
      sortBy: params.sortBy,
      sortDir: params.sortDir,
    );
  },
);

// Comment Actions Provider
final commentActionProvider =
    StateNotifierProvider<CommentActionNotifier, AsyncValue<void>>(
  (ref) => CommentActionNotifier(ref),
);

class CommentActionNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  CommentActionNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<CommentModel> createComment({
    required String poemPublicId,
    required String commentText,
    String? parentCommentPublicId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(commentServiceProvider);
      final comment = await service.createComment(
        poemPublicId: poemPublicId,
        commentText: commentText,
        parentCommentPublicId: parentCommentPublicId,
      );

      state = const AsyncValue.data(null);

      // Invalidate comments list
      ref.invalidate(commentsProvider);

      return comment;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }

  Future<void> deleteComment({
    required String poemPublicId,
    required String commentPublicId,
  }) async {
    state = const AsyncValue.loading();

    try {
      final service = ref.read(commentServiceProvider);
      await service.deleteComment(
        poemPublicId: poemPublicId,
        commentPublicId: commentPublicId,
      );

      state = const AsyncValue.data(null);

      // Invalidate comments list
      ref.invalidate(commentsProvider);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
```

### 4. UI Implementation Example

**Comment Button in Poem Detail:**

```dart
_buildActionButton(
  context,
  icon: Icons.comment_outlined,
  label: 'Comments',
  count: poem.commentCount,
  onPressed: () {
    // Navigate to comments screen
    context.push('/main/poems/${poem.publicId}/comments');
  },
)
```

---

## Next Steps

### Phase 1: Basic Comments
1. ✅ APIs are available
2. ⏳ Create `CommentModel` with Freezed
3. ⏳ Create `CommentService`
4. ⏳ Create `comment_providers.dart`
5. ⏳ Add comment count to poem detail
6. ⏳ Create comments screen with list

### Phase 2: Comment Input
1. ⏳ Create comment input widget
2. ⏳ Implement post comment functionality
3. ⏳ Add optimistic updates
4. ⏳ Handle validation errors

### Phase 3: Threaded Replies
1. ⏳ Implement reply UI
2. ⏳ Show nested replies
3. ⏳ Collapse/expand reply threads
4. ⏳ Add "Reply" button to comments

### Phase 4: Edit/Delete
1. ⏳ Show edit/delete for own comments
2. ⏳ Implement edit dialog
3. ⏳ Implement delete confirmation
4. ⏳ Handle soft-deleted comments display

---

## Summary

✅ **Comments API:** Fully implemented and ready
✅ **Features:** Create, read, update, delete, threaded replies
✅ **Authentication:** Handled automatically via JWT
✅ **Pagination:** Supported with configurable page size
✅ **Sorting:** Newest, oldest, or custom sort options

The comments system is ready for implementation! All backend endpoints are working and tested.
