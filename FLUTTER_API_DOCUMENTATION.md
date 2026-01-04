# Poetry Backend API - Flutter Mobile App Documentation

**Version:** 1.0.0
**Last Updated:** December 31, 2025
**Base URL (Production):** `https://api.poetry.com`
**Base URL (Development):** `https://dev-api.poetry.com`
**Base URL (Local):** `http://localhost:8080`

---

## Recent Updates (December 2025 - January 2026)

### Bookmark System Enhancement (Phase 1, 2 & 3) ⭐ NEW

**What's New:**
- ✅ **Phase 1 & 2**: Language-aware bookmarks for poems, couplets, and images
- ✅ **Phase 3**: Unified Bookmark API - Single interface for all bookmark types

#### Phase 1 & 2: Language Context Preservation

**Key Features:**
1. **Language-Aware Bookmarks**: All bookmark endpoints (poems, couplets, images) now accept a `lang` query parameter
2. **Multi-Language Bookmark Display**: Bookmarks preserve the language context in which they were created
3. **Image Poetry Bookmarks**: New bookmark system for generated poetry images (separate from collections)
4. **Cross-Language Filtering**: Filter bookmarks by language or view all in mixed languages

**Endpoints Added (Phase 1 & 2):**
- `POST /api/poetry-images/{imageId}/bookmark?lang=ur` - Bookmark generated image
- `GET /api/users/me/image-bookmarks?lang=ur` - Get bookmarked images with language filter
- `GET /api/poetry-images/{imageId}/is-bookmarked` - Check bookmark status
- `POST /api/poems/{publicId}/bookmark?lang=ur` - Updated with language parameter
- `POST /api/couplets/{coupletPublicId}/bookmark?lang=ur` - Updated with language parameter

#### Phase 3: Unified Bookmark API ⭐ NEW

**What is it?**
A single, consolidated API that provides access to all bookmark types (poems, couplets, images) through unified endpoints. No more switching between different endpoints for different content types!

**Key Features:**
1. **Unified Response Format**: All bookmarks return the same structure with type-specific fields
2. **Mixed Content Streams**: Get recent bookmarks across all types in a single call
3. **Type Filtering**: Filter by specific content type (poems-only, couplets-only, images-only)
4. **Cross-Content Search**: Search across all bookmarked content in one query
5. **Aggregated Statistics**: Get comprehensive stats across all bookmark types

**New Unified Endpoints (Phase 3):**
- `GET /api/bookmarks/recent` - Recent bookmarks across all types (mixed feed)
- `GET /api/bookmarks/poems` - Poem bookmarks only (filtered view)
- `GET /api/bookmarks/couplets` - Couplet bookmarks only (filtered view)
- `GET /api/bookmarks/images` - Image bookmarks only (filtered view)
- `GET /api/bookmarks/search?query=محبت` - Search across all bookmarks
- `GET /api/bookmarks/stats` - Comprehensive bookmark statistics

**Why Use Unified API?**
- **Simpler App Architecture**: One controller for all bookmark screens
- **Better UX**: Show users all their bookmarks in one feed
- **Efficient**: Fewer API calls, better performance
- **Flexible**: Easy to add new content types in the future

**Migration Notes for Flutter Developers:**
- All existing bookmark calls will continue to work (backward compatible)
- To support multi-language bookmarks, pass the current app language when calling bookmark endpoints
- Use Phase 3 unified endpoints for new bookmark screens (recommended)
- Legacy endpoints (`/api/users/me/couplets/bookmarked`, etc.) still work but unified API is preferred

---

## Table of Contents

### 1. Overview & Getting Started
- [1.1 Introduction](#11-introduction)
- [1.2 Architecture Overview](#12-architecture-overview)
- [1.3 Authentication Flow](#13-authentication-flow)
- [1.4 Response Format](#14-response-format)
- [1.5 Environment Configuration](#15-environment-configuration)
- [1.6 Error Handling](#16-error-handling)

### 2. Authentication & Authorization
- [2.1 Overview](#21-overview-authentication)
- [2.2 Firebase Authentication](#22-firebase-authentication)
- [2.3 Admin Login](#23-admin-login)
- [2.4 Token Refresh](#24-token-refresh)
- [2.5 Logout](#25-logout)
- [2.6 Get Current User](#26-get-current-user)

### 3. User Profile Management
- [3.1 Overview](#31-overview-user-profile)
- [3.2 Get User Profile](#32-get-user-profile)
- [3.3 Update User Profile](#33-update-user-profile)
- [3.4 Delete User Profile](#34-delete-user-profile)
- [3.5 User Interests](#35-user-interests)
  - [3.5.1 Get User Interests](#351-get-user-interests)
  - [3.5.2 Add Interest](#352-add-interest)
  - [3.5.3 Remove Interest](#353-remove-interest)
  - [3.5.4 Update Interests](#354-update-interests)
- [3.6 User Engagement](#36-user-engagement)
  - [3.6.1 Track Activity](#361-track-activity)
  - [3.6.2 Get User Statistics](#362-get-user-statistics)
  - [3.6.3 Get Reading Analytics](#363-get-reading-analytics)
  - [3.6.4 Get Recommendations](#364-get-recommendations)

### 4. Poet Discovery & Browse
- [4.1 Overview](#41-overview-poets)
- [4.2 Browse Poets](#42-browse-poets)
  - [4.2.1 Get All Poets](#421-get-all-poets)
  - [4.2.2 Get Featured Poets](#422-get-featured-poets)
  - [4.2.3 Get Trending Poets](#423-get-trending-poets)
  - [4.2.4 Get Poets by Gender](#424-get-poets-by-gender)
  - [4.2.5 Get Poets by Era](#425-get-poets-by-era)
  - [4.2.6 Get Poets by Tag](#426-get-poets-by-tag)
  - [4.2.7 Search Poets](#427-search-poets)
- [4.3 Poet Rankings](#43-poet-rankings)
  - [4.3.1 Top Poets by Poem Count](#431-top-poets-by-poem-count)
  - [4.3.2 Most Viewed Poets](#432-most-viewed-poets)
- [4.4 Poet Profile](#44-poet-profile)
  - [4.4.1 Get Complete Profile](#441-get-complete-profile)
  - [4.4.2 Get Poet Gallery](#442-get-poet-gallery)
  - [4.4.3 Get Poet Books](#443-get-poet-books)
  - [4.4.4 Get Poet Videos](#444-get-poet-videos)
  - [4.4.5 Get Poet Facts](#445-get-poet-facts)
- [4.5 Use Cases & Workflows](#45-use-cases-workflows)

### 5. Poem Discovery & Content
- [5.1 Overview](#51-overview-poems)
- [5.2 Browse Poems](#52-browse-poems)
  - [5.2.1 Get All Poems](#521-get-all-poems)
  - [5.2.2 Get Poems by Poet](#522-get-poems-by-poet)
  - [5.2.3 Get Poems by Category](#523-get-poems-by-category)
  - [5.2.4 Get Poems by Language](#524-get-poems-by-language)
- [5.3 Search](#53-search)
  - [5.3.1 Search Poems](#531-search-poems)
  - [5.3.2 Search Verses](#532-search-verses)
- [5.4 Poem Details](#54-poem-details)
  - [5.4.1 Get Poem by ID](#541-get-poem-by-id)
  - [5.4.2 Get Poem Content](#542-get-poem-content)
- [5.5 Engagement](#55-engagement)
  - [5.5.1 Like Poem](#551-like-poem)
  - [5.5.2 Bookmark Poem](#552-bookmark-poem)
  - [5.5.3 Get Like/Bookmark Status](#553-get-likebookmark-status)
- [5.6 User Collections](#56-user-collections)
  - [5.6.1 Get Bookmarked Poems](#561-get-bookmarked-poems)
- [5.7 Use Cases & Workflows](#57-use-cases-workflows)

### 6. Couplet Engagement System
- [6.1 Overview](#61-overview-couplets)
- [6.2 Couplet Retrieval](#62-couplet-retrieval)
  - [6.2.1 Get Couplets by Poem](#621-get-couplets-by-poem)
  - [6.2.2 Get Couplet Detail](#622-get-couplet-detail)
- [6.3 Engagement Actions](#63-engagement-actions)
  - [6.3.1 Like Couplet](#631-like-couplet)
  - [6.3.2 Bookmark Couplet](#632-bookmark-couplet)
  - [6.3.3 Share Couplet](#633-share-couplet)
  - [6.3.4 Get Public Share Link](#634-get-public-share-link)
- [6.4 User Collections](#64-user-collections)
  - [6.4.1 Get Liked Couplets](#641-get-liked-couplets)
  - [6.4.2 Get Bookmarked Couplets](#642-get-bookmarked-couplets)
- [6.5 Analytics & Discovery](#65-analytics-discovery)
  - [6.5.1 Most Liked Couplets](#651-most-liked-couplets)
  - [6.5.2 Most Shared Couplets](#652-most-shared-couplets)
  - [6.5.3 Trending Couplets](#653-trending-couplets)
- [6.6 Use Cases & Workflows](#66-use-cases-workflows)

### 7. Image Poetry Generation
- [7.1 Overview](#71-overview-image-poetry)
- [7.2 Template Management](#72-template-management)
  - [7.2.1 Get Templates](#721-get-templates)
  - [7.2.2 Get Template by ID](#722-get-template-by-id)
  - [7.2.3 Get Popular Templates](#723-get-popular-templates)
  - [7.2.4 Get Template Statistics](#724-get-template-statistics)
- [7.3 Image Generation](#73-image-generation)
  - [7.3.1 Generate Image for Couplet](#731-generate-image-for-couplet)
  - [7.3.2 Upload Custom Background](#732-upload-custom-background)
  - [7.3.3 Get Couplet Images](#733-get-couplet-images)
- [7.4 Upload Custom Background](#74-upload-custom-background)
- [7.5 User Collections & Bookmarks](#75-user-collections-bookmarks)
  - [7.5.1 Save Image to Collection](#751-save-image-to-collection)
  - [7.5.2 Get Saved Images](#752-get-saved-images)
  - [7.5.3 Toggle Favorite](#753-toggle-favorite)
  - [7.5.4 Remove from Collection](#754-remove-from-collection)
  - [7.5.5 Get Collection Names](#755-get-collection-names)
  - [7.5.6 Get Collection Statistics](#756-get-collection-statistics)
  - [7.5.7 Toggle Image Bookmark (NEW)](#757-toggle-image-bookmark-new)
  - [7.5.8 Get Bookmarked Images (NEW)](#758-get-bookmarked-images-new)
  - [7.5.9 Check Image Bookmark Status (NEW)](#759-check-image-bookmark-status-new)

### 8. Book Management
- [8.1 Overview](#81-overview-books)
- [8.2 Book Search & Discovery](#82-book-search-discovery)
  - [8.2.1 Global Book Search](#821-global-book-search)
  - [8.2.2 Get Book Statistics](#822-get-book-statistics)
  - [8.2.3 Search Books by Poet](#823-search-books-by-poet)
  - [8.2.4 Download Book](#824-download-book)
- [8.3 Use Cases & Workflows](#83-use-cases-workflows)

### 8.5 Unified Bookmark API (Phase 3) ⭐ NEW
- [8.5.1 Overview - Unified Bookmarks](#851-overview-unified-bookmarks)
- [8.5.2 Get Recent Bookmarks](#852-get-recent-bookmarks)
- [8.5.3 Get Poem Bookmarks](#853-get-poem-bookmarks)
- [8.5.4 Get Couplet Bookmarks](#854-get-couplet-bookmarks)
- [8.5.5 Get Image Bookmarks](#855-get-image-bookmarks)
- [8.5.6 Search Bookmarks](#856-search-bookmarks)
- [8.5.7 Get Bookmark Statistics](#857-get-bookmark-statistics)
- [8.5.8 Response Format](#858-response-format)
- [8.5.9 Use Cases & Examples](#859-use-cases-examples)

### 9. Comments System
- [9.1 Overview](#91-overview-comments)
- [9.2 Comment Operations](#92-comment-operations)
  - [9.2.1 Create Comment](#921-create-comment)
  - [9.2.2 Get Comments](#922-get-comments)
  - [9.2.3 Delete Comment](#923-delete-comment)
  - [9.2.4 Get Comment Count](#924-get-comment-count)
- [9.3 Use Cases & Workflows](#93-use-cases-workflows)

### 10. Global Search
- [10.1 Overview](#101-overview-search)
- [10.2 Unified Search](#102-unified-search)
- [10.3 Quick Search](#103-quick-search)
- [10.4 Couplet Search](#104-couplet-search)
- [10.5 Autocomplete](#105-autocomplete)
- [10.6 Recommendations](#106-recommendations)
- [10.7 Search Analytics](#107-search-analytics)
  - [10.7.1 Related Searches](#1071-related-searches)
  - [10.7.2 Trending Searches](#1072-trending-searches)
- [10.8 Use Cases & Workflows](#108-use-cases-workflows)

### 11. Categories, Tags & Metadata
- [11.1 Categories](#111-categories)
  - [11.1.1 Get All Categories](#1111-get-all-categories)
  - [11.1.2 Get Root Categories](#1112-get-root-categories)
  - [11.1.3 Get Category by ID](#1113-get-category-by-id)
  - [11.1.4 Get Category by Slug](#1114-get-category-by-slug)
  - [11.1.5 Get Category Children](#1115-get-category-children)
- [11.2 Tags](#112-tags)
  - [11.2.1 Get All Tags](#1121-get-all-tags)
  - [11.2.2 Get Tags by Type](#1122-get-tags-by-type)
  - [11.2.3 Get Tag by Slug](#1123-get-tag-by-slug)
  - [11.2.4 Get Tag by Public ID](#1124-get-tag-by-public-id)
- [11.3 Geography](#113-geography)
  - [11.3.1 Get Countries](#1131-get-countries)
  - [11.3.2 Get Cities](#1132-get-cities)
  - [11.3.3 Get Cities by Country](#1133-get-cities-by-country)
- [11.4 Languages](#114-languages)
  - [11.4.1 Get All Languages](#1141-get-all-languages)
  - [11.4.2 Get Language by Code](#1142-get-language-by-code)
  - [11.4.3 Get Active Languages](#1143-get-active-languages)

### 12. System & Health
- [12.1 Health Check](#121-health-check)
- [12.2 Detailed Health Check](#122-detailed-health-check)
- [12.3 Readiness Check](#123-readiness-check)
- [12.4 Liveness Check](#124-liveness-check)

### 13. Reference
- [13.1 Enum Values](#131-enum-values)
- [13.2 HTTP Status Codes](#132-http-status-codes)
- [13.3 Pagination Format](#133-pagination-format)
- [13.4 Error Response Format](#134-error-response-format)

### 14. Best Practices & Guidelines
- [14.1 Authentication Best Practices](#141-authentication-best-practices)
- [14.2 Pagination Best Practices](#142-pagination-best-practices)
- [14.3 Search Best Practices](#143-search-best-practices)
- [14.4 Image Handling](#144-image-handling)
- [14.5 Multi-Language Support](#145-multi-language-support)
- [14.6 Error Handling](#146-error-handling)
- [14.7 Performance Optimization](#147-performance-optimization)

### 15. Complete Workflows
- [15.1 User Onboarding Flow](#151-user-onboarding-flow)
- [15.2 Content Discovery Flow](#152-content-discovery-flow)
- [15.3 Image Poetry Creation Flow](#153-image-poetry-creation-flow)
- [15.4 Sharing & Social Flow](#154-sharing-social-flow)

### Appendix
- [A. Flutter Code Examples](#appendix-a-flutter-code-examples)
- [B. API Endpoints Summary](#appendix-b-api-endpoints-summary)
- [C. Changelog](#appendix-c-changelog)

---

## 1. Overview & Getting Started

### 1.1 Introduction

Welcome to the Poetry Backend API documentation for Flutter mobile applications. This API provides comprehensive access to a rich collection of Urdu, Persian, and Hindi poetry, along with poet biographies, image generation capabilities, and social engagement features.

**Key Features:**
- 📚 **Extensive Poetry Collection**: Browse thousands of poems across multiple languages and genres
- 👤 **Poet Profiles**: Comprehensive biographies, images, books, and videos
- 🔍 **Advanced Search**: Full-text search with Elasticsearch across poems, verses, poets, and categories
- 🎨 **Image Poetry Generation**: Create beautiful poetry images with customizable templates
- 💝 **Couplet-Level Engagement**: Like, bookmark, and share individual couplets
- 📖 **Book Management**: Search and download poetry books with tracking
- 💬 **Comments & Social**: Threaded comments on poems
- 🌍 **Multi-Language**: Urdu, English, Hindi, Arabic, Persian, Punjabi support
- 🔐 **Secure Authentication**: Firebase Auth + JWT tokens

**API Statistics:**
- **110+ Endpoints** across 15 major categories
- **Multi-language support** for UI and content
- **Real-time analytics** and recommendations
- **CloudFront CDN** for fast global delivery

---

### 1.2 Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                        │
│  ┌────────────┐  ┌────────────┐  ┌─────────────────────┐   │
│  │   Auth     │  │   Home     │  │   Poet Profile      │   │
│  │  Service   │  │  Discovery │  │   Poem Reader       │   │
│  └──────┬─────┘  └──────┬─────┘  └──────────┬──────────┘   │
│         │               │                     │              │
└─────────┼───────────────┼─────────────────────┼──────────────┘
          │               │                     │
          ▼               ▼                     ▼
    ┌─────────────────────────────────────────────────┐
    │         Spring Boot REST API (Port 8080)        │
    │                                                  │
    │  ┌──────────────┐  ┌──────────────────────┐   │
    │  │ Auth Filter  │  │  JWT Validation      │   │
    │  └──────────────┘  └──────────────────────┘   │
    │                                                  │
    │  ┌────────────────────────────────────────┐   │
    │  │         Controllers Layer               │   │
    │  │  - PoetController                       │   │
    │  │  - PoemController                       │   │
    │  │  - CoupletController (NEW)              │   │
    │  │  - ImagePoetryController (NEW)          │   │
    │  │  - BookController (NEW)                 │   │
    │  │  - CommentController (NEW)              │   │
    │  └────────────────────────────────────────┘   │
    │                                                  │
    │  ┌────────────────────────────────────────┐   │
    │  │         Service Layer                   │   │
    │  │  - Business Logic                       │   │
    │  │  - Data Transformation                  │   │
    │  │  - Caching (Redis - future)             │   │
    │  └────────────────────────────────────────┘   │
    │                                                  │
    │  ┌────────────────────────────────────────┐   │
    │  │         Repository Layer                │   │
    │  │  - JPA Repositories                     │   │
    │  │  - Custom Queries (JPQL/Native SQL)     │   │
    │  └────────────────────────────────────────┘   │
    └───────────┬──────────────┬──────────┬──────────┘
                │              │          │
                ▼              ▼          ▼
    ┌──────────────┐  ┌───────────────┐  ┌──────────────┐
    │  PostgreSQL  │  │ Elasticsearch │  │  AWS S3 +    │
    │   Database   │  │  Search Index │  │  CloudFront  │
    │              │  │               │  │  (Images)    │
    └──────────────┘  └───────────────┘  └──────────────┘
```

**Technology Stack:**
- **Backend**: Java 21 + Spring Boot 3.5.5
- **Database**: PostgreSQL 15+ with JSONB support
- **Search**: Elasticsearch (with PostgreSQL fallback)
- **Storage**: AWS S3 + CloudFront CDN
- **Authentication**: Firebase Auth + JWT
- **API Style**: RESTful with standardized responses

---

### 1.3 Authentication Flow

All endpoints (except `/api/auth/**` and `/api/health/**`) require authentication.

**Firebase Authentication Flow:**

```
┌──────────────┐
│ Flutter App  │
└──────┬───────┘
       │
       │ 1. User signs in with Firebase
       │    (Google, Email, Phone, etc.)
       ▼
┌──────────────────┐
│  Firebase Auth   │
│  Returns ID Token│
└──────┬───────────┘
       │
       │ 2. Send Firebase ID Token to backend
       │    POST /api/auth/firebase/verify
       ▼
┌─────────────────────────────────────────┐
│  Backend Verifies Token with Firebase  │
│  Creates/Updates User in Database      │
│  Generates JWT Access + Refresh Tokens │
└──────────┬──────────────────────────────┘
           │
           │ 3. Returns JWT tokens
           ▼
     ┌─────────────────┐
     │ Flutter App     │
     │ Stores Tokens   │
     │ in Secure Store │
     └─────────┬───────┘
               │
               │ 4. Include in all API calls
               │    Authorization: Bearer <access_token>
               ▼
        ┌──────────────────┐
        │  API Endpoints   │
        │  JWT Validation  │
        └──────────────────┘
```

**Token Lifecycle:**
- **Access Token**: Valid for 24 hours
- **Refresh Token**: Valid for 30 days
- When access token expires, use refresh token to get new access token

---

### 1.4 Response Format

All API responses follow a standardized format:

**Success Response:**
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "message": "Error description here",
  "data": null
}
```

**Paginated Response:**
```json
{
  "success": true,
  "message": "Data retrieved successfully",
  "data": {
    "content": [...],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20
    },
    "totalElements": 150,
    "totalPages": 8,
    "last": false,
    "first": true
  }
}
```

---

### 1.5 Environment Configuration

**Base URLs by Environment:**

| Environment | Base URL | Description |
|------------|----------|-------------|
| **Local Development** | `http://localhost:8080` | Your local machine |
| **Android Emulator** | `http://10.0.2.2:8080` | Special IP for Android emulator |
| **iOS Simulator** | `http://localhost:8080` | iOS simulator uses localhost |
| **Development Server** | `https://dev-api.poetry.com` | Development environment |
| **Production** | `https://api.poetry.com` | Live production API |

**Flutter Environment Setup:**

```dart
// lib/config/environment.dart
class Environment {
  static const String dev = 'development';
  static const String prod = 'production';
  
  static String get baseUrl {
    switch (const String.fromEnvironment('ENV', defaultValue: dev)) {
      case prod:
        return 'https://api.poetry.com';
      case dev:
        return 'https://dev-api.poetry.com';
      default:
        // For local development
        return Platform.isAndroid 
            ? 'http://10.0.2.2:8080'
            : 'http://localhost:8080';
    }
  }
}
```

---

### 1.6 Error Handling

**Common Error Scenarios:**

| Status Code | Scenario | Recommended Action |
|------------|----------|-------------------|
| **401 Unauthorized** | Token expired or invalid | Refresh token or re-authenticate |
| **403 Forbidden** | Insufficient permissions | Show appropriate message |
| **404 Not Found** | Resource doesn't exist | Handle gracefully in UI |
| **400 Bad Request** | Invalid input data | Show validation errors |
| **500 Server Error** | Backend issue | Retry with exponential backoff |

**Flutter Error Handling Example:**

```dart
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  
  ApiException(this.statusCode, this.message);
  
  @override
  String toString() => message;
}

Future<T> handleApiCall<T>(Future<Response> apiCall) async {
  try {
    final response = await apiCall;
    
    if (response.statusCode == 401) {
      // Token expired - try to refresh
      await refreshToken();
      // Retry the original call
      return handleApiCall(apiCall);
    }
    
    if (response.statusCode >= 400) {
      final error = jsonDecode(response.body);
      throw ApiException(
        response.statusCode,
        error['message'] ?? 'Unknown error'
      );
    }
    
    final data = jsonDecode(response.body);
    return data['data'] as T;
    
  } on SocketException {
    throw ApiException(null, 'No internet connection');
  } on TimeoutException {
    throw ApiException(null, 'Request timed out');
  }
}
```

---

---

### Test Data Available - Poem Migration Completed
**Date:** November 25, 2025

The backend now has comprehensive test data ready for Flutter UI development and testing:

**📊 Available Test Data:**
- **374 Poems** with real Urdu poetry content from famous poets
- **50 Poets** processed (can be expanded to all 1,993 poets later)
- **1,792 Verses** automatically parsed from Ghazals for verse-level search
- **1,110 Poem-Tag associations** (average 3 tags per poem)

**📝 Poetry Type Distribution:**
```
GHAZAL       224 poems (60%)  - Couplet-based poetry with verse parsing
NAZAM         74 poems (20%)  - Continuous poetry
VERSE         48 poems (13%)  - Standalone verses
RUBAI         11 poems (3%)   - Quatrains
AZAD_NAZAM     5 poems (1%)   - Free verse
QATTA          4 poems (1%)   - Fragment poetry
MARSIYA        4 poems (1%)   - Elegy
HAMD           3 poems (1%)   - Praise poetry
NAAT           1 poem  (<1%)  - Prophet's praise
```

**✨ Real Urdu Poetry Content From:**
- Mirza Ghalib (ہزاروں خواہشیں ایسی، دل کی ویرانی کا کیا مذکور ہے)
- Allama Iqbal (لب پہ آتی ہے دعا، شکوہ)
- Faiz Ahmed Faiz (مجھ سے پہلی سی محبت، بول کہ لب آزاد ہیں)
- Mir Taqi Mir, Momin Khan Momin, Josh Malihabadi

**🏷️ Tag Distribution:**
```
romantic-poet     283 poems
classical-poet    280 poems
ghazal-master     228 poems
patriotic-poet     79 poems
progressive-poet   79 poems
nazm-writer        79 poems
nature-poet        48 poems
sufi-mystic        15 poems
```

**✅ Ready to Test:**
1. Poem browsing and listing endpoints
2. Poem search with Elasticsearch (or PostgreSQL fallback)
3. Verse-level search for Ghazals
4. Filtering by poet, category, poetry type, tags
5. Multilingual content (Urdu poetry in Arabic script)
6. Pagination across all endpoints

**🚀 Next Steps for Flutter Team:**
- Start building UI with real data
- Test search functionality with real Urdu queries (e.g., محبت، دل، عشق)
- Test verse-level search for Ghazals (returns specific couplets)
- Test pagination and filtering
- Verify tag-based discovery

**📖 Reference:**
- See `DATA_MIGRATION_GUIDE.md` for migration details
- To expand data: Change `.limit(50)` in `PoemDataMigration.java` and re-run

---

## Base URLs by Environment

Configure these base URLs in your Flutter app based on the environment:

| Environment    | Base URL                                    | Usage                         |
|----------------|---------------------------------------------|-------------------------------|
| **Local**      | `http://localhost:8080/api`                 | Development on local machine  |
| **Development**| `https://dev-api.yourpoetryapp.com/api`     | Testing/staging server        |
| **Production** | `https://api.yourpoetryapp.com/api`         | Live production server        |

**Important Notes:**
- Replace `yourpoetryapp.com` with your actual domain
- For Android emulator testing: Use `http://10.0.2.2:8080/api` (Android maps this to host machine's localhost)
- For iOS simulator testing: Use `http://localhost:8080/api`
- For physical device testing on same network: Use `http://YOUR_MACHINE_IP:8080/api` (e.g., `http://192.168.1.100:8080/api`)

### Flutter Configuration Example

```dart
class ApiConfig {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'local',
  );

  static String get baseUrl {
    switch (environment) {
      case 'prod':
        return 'https://api.yourpoetryapp.com/api';
      case 'dev':
        return 'https://dev-api.yourpoetryapp.com/api';
      case 'local':
      default:
        return 'http://localhost:8080/api';
    }
  }
}
```

**Run with environment:**
```bash
# Local
flutter run

# Development
flutter run --dart-define=ENV=dev

# Production
flutter run --dart-define=ENV=prod
```

### Backend Server Ports

The Spring Boot backend runs on different ports based on configuration:

- **Default Port:** `8080`
- Configure in `application.properties`:
  ```properties
  server.port=8080
  ```

**Backend URLs by Environment:**
- Local: Backend runs on your machine at port 8080
- Dev: Backend deployed to development server (configure your dev server URL)
- Prod: Backend deployed to production server (configure your prod server URL)

---

## Response Format

All endpoints return responses in the following format:
```json
{
  "success": true,
  "message": "Operation message",
  "data": { ... }
}
```

## Authentication

**IMPORTANT:** All endpoints require JWT authentication except `/api/auth/**` and `/api/health/**`.

Include the access token in the Authorization header for all protected endpoints:

```
Authorization: Bearer <access_token>
```

### Common Authentication Issues & Solutions

#### Issue 1: Getting 302 Redirect Instead of 401/403
**Symptom:** API returns redirect to OAuth2 login page instead of JSON error response
**Cause:** Old backend code with misconfigured security filters
**Solution:** Ensure backend is running the latest code (restart required after Nov 20, 2025 fixes)

#### Issue 2: 404 "User not found" on `/api/auth/me`
**Symptom:** Valid JWT token but `/api/auth/me` returns 404
**Possible Causes:**
- JWT token contains email that doesn't exist in database (token from different environment)
- User was deleted from database but token is still valid
- Token was issued before user record was created
**Solution:**
- Check backend logs for detailed error message
- Verify user exists in database with the email in JWT token
- Generate fresh token by logging in again

#### Issue 3: Redirect Loop on Protected Endpoints
**Symptom:** App gets stuck in redirect loop when calling `/api/poets` or other protected endpoints
**Cause:** Fixed in backend update (Nov 20, 2025)
**Solution:** Ensure backend server is restarted with latest code

#### Expected Error Response Format
When authentication fails, the backend returns:
```json
{
  "success": false,
  "message": "User not authenticated",
  "data": null
}
```
**Status Codes:**
- `401 Unauthorized`: No token or invalid token
- `403 Forbidden`: Valid token but insufficient permissions
- `404 Not Found`: Token valid but user record not found

---

## 1. Authentication Endpoints

Base Path: `/api/auth`

### 1.1 Firebase Login/Register

**Endpoint:** `POST /api/auth/firebase/verify`

**Authentication Required:** No

**Description:** Authenticate user with Firebase ID token. Creates new user if doesn't exist.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "firebaseToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjE5ZjE3...",
  "email": "user@example.com",
  "deviceType": "android",
  "deviceId": "unique-device-id"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Firebase authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
    "type": "Bearer",
    "publicId": "usr_abc123def456",
    "username": "user123",
    "email": "user@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg"
  }
}
```

**Error Response (401):**
```json
{
  "success": false,
  "message": "Invalid Firebase token",
  "data": null
}
```

---

### 1.2 Admin Login

**Endpoint:** `POST /api/auth/admin/login`

**Authentication Required:** No

**Description:** Authenticate admin user with email and password. Returns JWT tokens in the same format as Firebase authentication, allowing admin users to access all APIs.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "admin@system.com",
  "password": "12345678"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Admin authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "550e8400-e29b-41d4-a716-446655440000",
    "type": "Bearer",
    "publicId": "usr_abc123def456",
    "username": "admin",
    "email": "admin@system.com",
    "fullName": "System Admin",
    "profileImageUrl": null
  }
}
```

**Error Response (401 - Invalid Credentials):**
```json
{
  "success": false,
  "message": "Invalid credentials",
  "data": null
}
```

**Error Response (403 - Account Inactive):**
```json
{
  "success": false,
  "message": "Account is not active",
  "data": null
}
```

**Notes:**
- Only users with password authentication enabled can use this endpoint
- Firebase users cannot use this endpoint (they don't have passwords)
- Default admin user: `admin@system.com` / `12345678`
- Admin users can access all API endpoints after authentication
- Same token format as Firebase authentication for consistency

---

### 1.3 Get Current User

**Endpoint:** `GET /api/auth/me`

**Authentication Required:** Yes

**Description:** Get currently authenticated user information

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "fullName": "John Doe",
    "username": "john_doe",
    "profileImageUrl": "https://example.com/profile.jpg",
    "provider": "firebase",
    "isActive": true
  }
}
```

---

### 1.4 Refresh Token

**Endpoint:** `POST /api/auth/refresh`

**Authentication Required:** No

**Description:** Refresh access token using refresh token

**Request Body:**
```json
{
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Token refreshed successfully!",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "660e8400-e29b-41d4-a716-446655440111",
    "type": "Bearer",
    "publicId": "usr_abc123def456",
    "username": "john_doe",
    "email": "user@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg"
  }
}
```

---

### 1.5 Logout

**Endpoint:** `POST /api/auth/logout`

**Authentication Required:** No

**Description:** Logout user and invalidate refresh token

**Request Body:**
```json
{
  "refreshToken": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Logged out successfully!",
  "data": null
}
```

---

## 2. User Profile Endpoints

Base Path: `/api/profile`

All endpoints require authentication.

### 2.1 Get Current User Profile

**Endpoint:** `GET /api/profile`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg",
    "dateOfBirth": "1990-01-15",
    "gender": "male",
    "location": "Karachi",
    "country": "Pakistan",
    "bio": "Poetry enthusiast",
    "preferredLanguage": "ur",
    "readingLevel": "INTERMEDIATE",
    "onboardingCompleted": true,
    "profileVisibility": "PUBLIC",
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-15T14:30:00"
  }
}
```

---

### 2.2 Update Profile

**Endpoint:** `PUT /api/profile`

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "fullName": "John Smith",
  "username": "john_smith",
  "dateOfBirth": "1990-01-15",
  "gender": "male",
  "location": "Karachi",
  "country": "Pakistan",
  "bio": "Passionate about Urdu poetry",
  "preferredLanguage": "ur",
  "readingLevel": "ADVANCED",
  "profileVisibility": "PUBLIC"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_smith",
    "fullName": "John Smith",
    "profileImageUrl": "https://example.com/profile.jpg",
    "dateOfBirth": "1990-01-15",
    "gender": "male",
    "location": "Karachi",
    "country": "Pakistan",
    "bio": "Passionate about Urdu poetry",
    "preferredLanguage": "ur",
    "readingLevel": "ADVANCED",
    "onboardingCompleted": true,
    "profileVisibility": "PUBLIC"
  }
}
```

---

### 2.3 Complete Onboarding

**Endpoint:** `POST /api/profile/complete-onboarding`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Onboarding completed successfully",
  "data": {
    "onboardingCompleted": true
  }
}
```

---

### 2.4 Get User Interests

**Endpoint:** `GET /api/profile/interests`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User interests retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "int_xyz789",
      "interestType": "POET",
      "interestId": 5,
      "interestName": "Mirza Ghalib",
      "strength": 0.8,
      "explicitPreference": true,
      "engagementScore": 12.5,
      "createdAt": "2024-01-01T10:00:00"
    },
    {
      "id": 2,
      "publicId": "int_xyz790",
      "interestType": "CATEGORY",
      "interestId": 3,
      "interestName": "Ghazal",
      "strength": 0.7,
      "explicitPreference": true,
      "engagementScore": 8.3,
      "createdAt": "2024-01-02T11:00:00"
    }
  ]
}
```

---

### 2.5 Get User Interests by Type

**Endpoint:** `GET /api/profile/interests/{interestType}`

**Path Parameters:**
- `interestType`: CATEGORY, POET, TAG, LANGUAGE, CONTENT_TYPE

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/profile/interests/POET`

**Success Response (200):**
```json
{
  "success": true,
  "message": "User interests retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "int_xyz789",
      "interestType": "POET",
      "interestId": 5,
      "interestName": "Mirza Ghalib",
      "strength": 0.8,
      "explicitPreference": true,
      "engagementScore": 12.5
    }
  "activityType": "VIEW",
  "targetType": "POEM",
  "targetId": 123,
  "durationSeconds": 45,
  "sessionId": "session_abc123",
  "deviceType": "android",
  "metadata": "{\"scrollDepth\": 100}"
}
```

**Activity Types:** VIEW, LIKE, UNLIKE, BOOKMARK, UNBOOKMARK, SHARE, SEARCH, FOLLOW_POET, UNFOLLOW_POET, COLLECT, COMMENT, DOWNLOAD

**Target Types:** POEM, POET, CATEGORY, TAG, COLLECTION, USER

**Success Response (200):**
```json
{
  "success": true,
  "message": "Engagement tracked successfully",
  "data": {
    "id": 456,
    "publicId": "eng_abc123",
    "activityType": "VIEW",
    "targetType": "POEM",
    "targetId": 123,
    "durationSeconds": 45,
    "interactionStrength": 1.0,
    "activityTimestamp": "2024-01-15T14:30:00",
    "sessionId": "session_abc123",
    "deviceType": "android"
  }
}
```

---

### 2.9 Get Recent Engagement

**Endpoint:** `GET /api/profile/engagement/recent?days=30`

**Query Parameters:**
- `days` (optional): Number of days to look back (default: 30)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Recent activities retrieved successfully",
  "data": [
    {
      "id": 456,
      "publicId": "eng_abc123",
      "activityType": "VIEW",
      "targetType": "POEM",
      "targetId": 123,
      "durationSeconds": 45,
      "activityTimestamp": "2024-01-15T14:30:00"
    }
  ]
}
```

---

### 2.10 Get Top Engaged Content

**Endpoint:** `GET /api/profile/engagement/top/{targetType}?days=30`

**Path Parameters:**
- `targetType`: POEM, POET, CATEGORY, TAG, COLLECTION, USER

**Query Parameters:**
- `days` (optional): Number of days to look back (default: 30)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/profile/engagement/top/POEM?days=30`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Top engaged content retrieved successfully",
  "data": [
    [123, 15],
    [456, 12],
    [789, 8]
  ]
}
```
Note: Data is array of [targetId, engagementCount]

---

## 3. User Endpoints

Base Path: `/api/user`

### 3.1 Get Current User (Alternative)

**Endpoint:** `GET /api/user/me`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_doe",
    "fullName": "John Doe",
    "profileImageUrl": "https://example.com/profile.jpg"
  }
}
```

---

### 3.2 Get User Bookmarks

**Endpoint:** `GET /api/user/bookmarks?page=0&size=10`

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "id": 1,
        "publicId": "bkm_abc123",
        "poem": {
          "id": 123,
          "publicId": "poem_xyz789",
          "title": "Shikwa",
          "content": "کیوں زیاں کار بندوں میں...",
          "poet": {
            "name": "Allama Iqbal"
          }
        },
        "createdAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 25,
    "totalPages": 3,
    "last": false
  }
}
```

---

### 3.3 Update User Profile

**Endpoint:** `PUT /api/user/profile`

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "fullName": "John Updated",
  "username": "john_updated"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "publicId": "usr_abc123def456",
    "email": "user@example.com",
    "username": "john_updated",
    "fullName": "John Updated"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Username is already taken!",
  "data": null
}
```

---

## 4. Poem Endpoints

Base Path: `/api/poems`

### 4.1 Get All Poems

**Endpoint:** `GET /api/poems?page=0&size=10&sortBy=createdAt&sortDir=desc`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `sortBy` (optional): Sort field (default: createdAt)
- `sortDir` (optional): Sort direction - asc/desc (default: desc)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "شکوہ",
        "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا\nکچھ تو ہے جس کی پردہ داری ہے ضروری",
        "poetPublicId": "poet_abc123",
        "poetName": "علامہ اقبال",
        "poetProfileImageUrl": "https://example.com/iqbal.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "نظم",
        "poetryType": "NAZM",
        "poetryTypeUrduName": "نظم",
        "poetryTypeEnglishName": "Nazm",
        "yearWritten": 1909,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "pageNumber": 0,
      "pageSize": 10,
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalElements": 374,
    "totalPages": 38,
    "last": false,
    "size": 10,
    "number": 0,
    "numberOfElements": 10,
    "first": true,
    "empty": false
  }
}
```

---

### 4.2 Get Poem by ID

**Endpoint:** `GET /api/poems/{publicId}`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poem

**Example:** `GET /api/poems/poem_xyz789`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem retrieved successfully",
  "data": {
    "publicId": "poem_xyz789",
    "createdAt": "2024-01-15T14:30:00",
    "updatedAt": "2024-01-15T14:30:00",
    "poetPublicId": "poet_abc123",
    "poetName": "علامہ اقبال",
    "categoryPublicId": "cat_def456",
    "categoryName": "نظم",
    "poetryType": "GHAZAL",
    "poetryTypeUrduName": "غزل",
    "poetryTypeEnglishName": "Ghazal",
    "requiresStructuredParsing": true,
    "contentType": "TEXT",
    "imageUrl": null,
    "thumbnailUrl": null,
    "yearWritten": 1850,
    "source": "دیوانِ غالب",
    "license": "Public Domain",
    "uploadedByUsername": "admin",
    "isPublic": true,
    "isFeatured": true,
    "viewCount": 1524,
    "likeCount": 456,
    "tags": [
      {
        "publicId": "tag_001",
        "urduName": "عشق",
        "englishName": "Love"
      }
    ],
    "contents": [
      {
        "publicId": "content_001",
        "languageCode": "ur",
        "languageName": "Urdu",
        "languageNativeName": "اردو",
        "script": "ARABIC",
        "scriptUrduName": "عربی",
        "scriptEnglishName": "Arabic",
        "scriptDirection": "rtl",
        "title": "دل ہی تو ہے",
        "fullText": "دل ہی تو ہے نہ سنگ و خشت\nدرد سے بھر نہ آئے کیوں...",
        "isOriginal": true,
        "translatedBy": null,
        "notes": null,
        "verses": [
          {
            "publicId": "verse_001",
            "verseNumber": 1,
            "coupletNumber": 1,
            "verseType": "MATLA",
            "verseText": "دل ہی تو ہے نہ سنگ و خشت",
            "romanizedText": "Dil hi to hai na sang-o-khisht",
            "translation": "It's only a heart, not stone and brick"
          },
          {
            "publicId": "verse_002",
            "verseNumber": 2,
            "coupletNumber": 1,
            "verseType": "MATLA",
            "verseText": "درد سے بھر نہ آئے کیوں",
            "romanizedText": "Dard se bhar na aaye kyon",
            "translation": "Why shouldn't it fill with pain"
          }
        ],
        "totalVerses": 14,
        "totalCouplets": 7
      }
    ]
  }
}
```

**Note:** View count is automatically incremented when fetching a poem.

---

### 4.3 Search Poems (Enhanced with Elasticsearch)

**Endpoint:** `GET /api/poems/search?query=محبت&lang=ur&script=ARABIC&page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Description:**
Enhanced search with Elasticsearch and PostgreSQL fallback. Searches across poem titles, content, and poet names with multilingual support.

**Query Parameters:**
- `query` (required): Search query (supports fuzzy matching for typos)
- `lang` (optional): Language code - `ur`, `en`, `hi` (default: `ur`)
- `script` (optional): Script filter - `ARABIC`, `ROMAN`, `DEVANAGARI`, `LATIN`
- `poetId` (optional): Filter by poet publicId
- `categoryId` (optional): Filter by category publicId
- `poetryType` (optional): Filter by poetry type - `GHAZAL`, `NAZM`, `RUBAI`, etc.
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Examples:**
```
GET /api/poems/search?query=محبت
GET /api/poems/search?query=dil&lang=ur&script=ROMAN
GET /api/poems/search?query=love&poetId=ghalib-123
GET /api/poems/search?query=ghazal&poetryType=GHAZAL&lang=ur
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "محبت کی باتیں",
        "excerpt": "محبت میں دل کی دھڑکن سنائی دے\nہر لمحہ تیری یاد ستائی دے",
        "poetPublicId": "poet_faiz123",
        "poetName": "فیض احمد فیض",
        "poetProfileImageUrl": "https://example.com/faiz.jpg",
        "categoryPublicId": "cat_ghazal",
        "categoryName": "غزل",
        "poetryType": "GHAZAL",
        "poetryTypeUrduName": "غزل",
        "poetryTypeEnglishName": "Ghazal",
        "yearWritten": 1965,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": false,
        "viewCount": 856,
        "likeCount": 127,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2025-11-15T09:20:00",
        "updatedAt": "2025-11-25T16:45:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10,
      "offset": 0
    },
    "totalElements": 45,
    "totalPages": 5,
    "last": false,
    "size": 10,
    "number": 0,
    "first": true,
    "empty": false
  }
}
```

**Notes:**
- Uses Elasticsearch for fast, relevant search with BM25 scoring
- Falls back to PostgreSQL LIKE queries if Elasticsearch is unavailable
- Supports fuzzy matching with AUTO fuzziness for typo tolerance
- Searches across multilingual content simultaneously
- Returns PoemSummaryResponse objects (lightweight poem data)

---

### 4.3.1 Search Verses (Verse-Level Search)

**Endpoint:** `GET /api/poems/verses/search?query=دل&lang=ur&page=0&size=20`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Description:**
Search for specific verses within poems (critical for Ghazal poetry). Returns individual verses with poem and poet context.

**Query Parameters:**
- `query` (required): Search query
- `lang` (optional): Language code - `ur`, `en`, `hi` (default: `ur`)
- `verseType` (optional): Filter by verse type - `MATLA`, `MAQTA`, `REGULAR`
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 20)

**Examples:**
```
GET /api/poems/verses/search?query=دل
GET /api/poems/verses/search?query=mohabbat&verseType=MATLA
GET /api/poems/verses/search?query=love&lang=en
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 23 verses matching 'دل'",
  "data": {
    "content": [
      {
        "verse": {
          "publicId": "verse_123",
          "verseNumber": 1,
          "coupletNumber": 1,
          "verseType": "MATLA",
          "verseText": "دل ہی تو ہے نہ سنگ و خشت",
          "romanizedText": "Dil hi to hai na sang-o-khisht",
          "translation": "It's only a heart, not stone and brick"
        },
        "poemPublicId": "poem_001",
        "poemTitle": "دل ہی تو ہے",
        "poetryType": "GHAZAL",
        "poetPublicId": "ghalib_001",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://example.com/ghalib.jpg",
        "score": 8.5,
        "highlightedText": "<em>دل</em> ہی تو ہے نہ سنگ و خشت",
        "coupletNumber": 1,
        "verseNumber": 1,
        "positionInCouplet": 1
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 20,
      "offset": 0
    },
    "totalElements": 23,
    "totalPages": 2,
    "last": false,
    "size": 20,
    "number": 0,
    "first": true,
    "empty": false
  }
}
```

**Notes:**
- Returns verses with full poem and poet context
- Ideal for finding specific couplets or verses in Ghazals
- Uses Elasticsearch for precise verse-level matching with relevance scoring
- Falls back to PostgreSQL verse search if needed
- Includes highlighted text showing matched terms
- Returns VerseSearchResult objects with complete context

---

### 4.4 Get Featured Poems

**Endpoint:** `GET /api/poems/featured?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Featured poems retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "شکوہ",
        "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا\nکچھ تو ہے جس کی پردہ داری ہے ضروری",
        "poetPublicId": "poet_abc123",
        "poetName": "علامہ اقبال",
        "poetProfileImageUrl": "https://example.com/iqbal.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "نظم",
        "poetryType": "NAZM",
        "poetryTypeUrduName": "نظم",
        "poetryTypeEnglishName": "Nazm",
        "yearWritten": 1909,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 25,
    "totalPages": 3,
    "last": false
  }
}
```

---

### 4.5 Get Poems by Poet

**Endpoint:** `GET /api/poems/poet/{poetPublicId}?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `poetPublicId`: Public ID of the poet

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poems/poet/poet_abc123?page=0&size=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems by poet retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "شکوہ",
        "excerpt": "کیوں زیاں کار بندوں میں شامل ہے نام میرا",
        "poetPublicId": "poet_abc123",
        "poetName": "علامہ اقبال",
        "poetProfileImageUrl": "https://example.com/iqbal.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "نظم",
        "poetryType": "NAZM",
        "poetryTypeUrduName": "نظم",
        "poetryTypeEnglishName": "Nazm",
        "yearWritten": 1909,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "isLikedByCurrentUser": false,
        "isBookmarkedByCurrentUser": false,
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 89,
    "totalPages": 9,
    "last": false
  }
}
```

---

### 4.6 Get Poems by Category

**Endpoint:** `GET /api/poems/category/{categoryPublicId}?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `categoryPublicId`: Public ID of the category

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poems/category/cat_def456?page=0&size=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems by category retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poem_xyz789",
        "title": "دل کی باتیں",
        "excerpt": "دل کی باتیں دل ہی جانے\nپیار کی باتیں پیار جانے",
        "poetPublicId": "poet_ghalib",
        "poetName": "مرزا غالب",
        "poetProfileImageUrl": "https://example.com/ghalib.jpg",
        "categoryPublicId": "cat_def456",
        "categoryName": "غزل",
        "poetryType": "GHAZAL",
        "poetryTypeUrduName": "غزل",
        "poetryTypeEnglishName": "Ghazal",
        "yearWritten": 1850,
        "contentType": "TEXT",
        "thumbnailUrl": null,
        "isPublic": true,
        "isFeatured": false,
        "viewCount": 2341,
        "likeCount": 589,
        "isLikedByCurrentUser": true,
        "isBookmarkedByCurrentUser": true,
        "createdAt": "2024-01-10T12:00:00",
        "updatedAt": "2024-01-20T18:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 224,
    "totalPages": 23,
    "last": false
  }
}
```

---

### 4.7 Get Poems by Language

**Endpoint:** `GET /api/poems/language/{language}?page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `language`: Language code (e.g., ur, en, ar)

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poems/language/ur?page=0&size=10`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poems by language retrieved successfully",
  "data": {
    "content": [
      {
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "Shikwa",
        "language": "ur"
      }
    ]
  }
}
```

---

### 4.8 Toggle Bookmark

**Endpoint:** `POST /api/poems/{publicId}/bookmark?lang=ur`

**Description:** Bookmark or unbookmark a poem (toggles). The language parameter preserves the language context in which the user bookmarked the content.

**Path Parameters:**
- `publicId`: Public ID of the poem

**Query Parameters:**
- `lang` (optional, default: "ur"): Language code when bookmarking (ur, en, hi, etc.). This is stored with the bookmark so the content can be displayed in the bookmarked language later.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem bookmarked successfully",
  "data": {
    "bookmarked": true
  }
}
```

OR

```json
{
  "success": true,
  "message": "Bookmark removed successfully",
  "data": {
    "bookmarked": false
  }
}
```

---

### 4.9 Toggle Like

**Endpoint:** `POST /api/poems/{publicId}/like`

**Description:** Like or unlike a poem (toggles)

**Path Parameters:**
- `publicId`: Public ID of the poem

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem liked successfully",
  "data": {
    "liked": true
  }
}
```

OR

```json
{
  "success": true,
  "message": "Like removed successfully",
  "data": {
    "liked": false
  }
}
```

---

### 4.10 Get Poem Status

**Endpoint:** `GET /api/poems/{publicId}/status`

**Description:** Get bookmark and like status for a poem

**Path Parameters:**
- `publicId`: Public ID of the poem

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem status retrieved successfully",
  "data": {
    "bookmarked": true,
    "liked": false
  }
}
```

---

### 4.11 Upload Poem

**Endpoint:** `POST /api/poems/add-poem`

**Description:** Upload a new poem with automatic Ghazal parsing (requires authentication)

**⚠️ BREAKING CHANGES (Updated November 2025):**
- `language` → `languageCode` (string)
- `script` → Script enum value (ARABIC/ROMAN/DEVANAGARI/LATIN)
- `form` → `poetryType` enum (GHAZAL/NAZAM/VERSE/NASAR/AFSANA/etc.)
- `categoryId` is now optional
- Ghazals are automatically parsed into verses

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "New Poem Title",
  "poetId": "poet_abc123",
  "categoryId": "cat_def456",
  "content": "یہ ایک نئی نظم ہے...",
  "poetryType": "GHAZAL",
  "contentType": "TEXT",
  "imageUrl": null,
  "thumbnailUrl": null,
  "languageCode": "ur",
  "script": "ARABIC",
  "yearWritten": 2024,
  "source": "Original",
  "license": "public_domain",
  "isPublic": true,
  "tagIds": ["tag_123", "tag_456"]
}
```

**Poetry Types:**
- `GHAZAL` - Couplet-based poetry (automatically parsed into MATLA/MAQTA/REGULAR verses)
- `NAZAM` - Continuous poetry (stored as-is, no parsing)
- `AZAD_NAZAM` - Free verse (no parsing)
- `VERSE` - Single verse or couplet (no parsing)
- `NASAR` - Prose (no parsing)
- `AFSANA` - Story/Fiction (no parsing)
- `QATTA`, `RUBAI`, `MASNAVI`, `QASIDA`, `MARSIYA`, `HAMD`, `NAAT`, `MANQABAT`, `DOHA`, `FREE_VERSE`

**Script Values:**
- `ARABIC` - Arabic script (RTL) - عربی
- `ROMAN` - Roman/Latin script (LTR)
- `DEVANAGARI` - Devanagari script (LTR) - देवनागरी
- `LATIN` - Latin script (LTR)

**Success Response (201):**
```json
{
  "success": true,
  "message": "Poem uploaded successfully",
  "data": {
    "publicId": "poem_new123",
    "createdAt": "2025-11-26T10:30:00",
    "updatedAt": "2025-11-26T10:30:00",
    "poetPublicId": "poet_abc123",
    "poetName": "مرزا غالب",
    "categoryPublicId": "cat_def456",
    "categoryName": "غزل",
    "poetryType": "GHAZAL",
    "poetryTypeUrduName": "غزل",
    "poetryTypeEnglishName": "Ghazal",
    "requiresStructuredParsing": true,
    "contentType": "TEXT",
    "imageUrl": null,
    "thumbnailUrl": null,
    "yearWritten": 2024,
    "source": "Original",
    "license": "public_domain",
    "uploadedByUsername": "admin",
    "isPublic": true,
    "isFeatured": false,
    "viewCount": 0,
    "likeCount": 0,
    "tags": [
      {
        "publicId": "tag_123",
        "urduName": "عشق",
        "englishName": "Love"
      }
    ],
    "contents": [
      {
        "publicId": "content_new001",
        "languageCode": "ur",
        "languageName": "Urdu",
        "languageNativeName": "اردو",
        "script": "ARABIC",
        "scriptUrduName": "عربی",
        "scriptEnglishName": "Arabic",
        "scriptDirection": "rtl",
        "title": "New Poem Title",
        "fullText": "یہ ایک نئی نظم ہے...",
        "isOriginal": true,
        "translatedBy": null,
        "notes": null,
        "verses": [
          {
            "publicId": "verse_new001",
            "verseNumber": 1,
            "coupletNumber": 1,
            "verseType": "MATLA",
            "verseText": "یہ ایک نئی نظم ہے",
            "romanizedText": null,
            "translation": null
          }
        ],
        "totalVerses": 8,
        "totalCouplets": 4
      }
    ]
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Poet not found",
  "data": null
}
```

**Note:** For Ghazals, the backend automatically:
- Parses content into individual verses
- Creates couplets (2 verses each)
- Identifies first couplet as MATLA (opening)
- Identifies last couplet as MAQTA (closing with poet's name)
- Tags all other couplets as REGULAR

---

## 4.12 Poem Content Architecture (November 2025 Update)

### Multilingual Poem System

**Overview:**
The poem system now supports **multilingual content** and **automatic Ghazal parsing** for verse-level search.

**Key Features:**
1. **Multilingual Support**: Same poem can exist in multiple languages and scripts
   - Example: Urdu (Arabic script), Roman Urdu, English translation, Hindi translation
2. **Verse-Level Granularity**: Ghazals are parsed into individual verses for precise search
   - Searching "dil" returns specific verses, not just full poems
3. **Schema-Based Parsing**: Only Ghazals are parsed initially (other types stored as-is)

**Database Structure:**

```
poems                 (Metadata only)
  ├── id, publicId
  ├── poet_id
  ├── poetry_type (GHAZAL, NAZAM, etc.)
  ├── category_id (optional)
  └── view_count, like_count, etc.

poem_contents         (Multilingual text storage)
  ├── id, publicId
  ├── poem_id (FK → poems)
  ├── language_id (FK → languages)
  ├── script (ARABIC, ROMAN, DEVANAGARI, LATIN)
  ├── title (translated title)
  ├── full_text (complete poem)
  ├── is_original (boolean)
  └── translated_by, notes

poem_verses           (Parsed verses for Ghazals)
  ├── id, publicId
  ├── content_id (FK → poem_contents)
  ├── verse_number (1, 2, 3...)
  ├── couplet_number (1, 2, 3...)
  ├── verse_type (MATLA, MAQTA, REGULAR)
  └── verse_text (individual verse)
```

**Unique Constraints:**
- `poem_contents`: (poem_id, language_id, script) - One entry per language+script combination
- Full text always preserved even after parsing

**Example Data Flow:**
```
Upload Ghazal:
  Title: "Har Ek Baat Pe"
  Content: "ہر ایک بات پہ کہتے ہو تم کہ تو کیا ہے\n..."
  Poetry Type: GHAZAL
  Language: ur, Script: ARABIC

Backend Processing:
  1. Creates Poem record (metadata only)
  2. Creates PoemContent record (Urdu Arabic)
  3. Parses 6 couplets = 12 verses:
     - Verses 1-2: MATLA (opening couplet)
     - Verses 3-10: REGULAR (middle couplets)
     - Verses 11-12: MAQTA (closing with "Ghalib")
```

---

## 4.13 Breaking Changes Summary (November 2025)

### Removed Endpoints:
- ❌ `GET /api/poems/language/{language}` - Removed (language filtering handled differently)

### Modified Endpoints:

**POST /api/poems/add-poem:**
| Old Field | New Field | Type | Notes |
|-----------|-----------|------|-------|
| `language` | `languageCode` | String | Same values: "ur", "en", "hi" |
| `script` | `script` | Enum | Now: "ARABIC", "ROMAN", "DEVANAGARI", "LATIN" |
| `form` | `poetryType` | Enum | Now: "GHAZAL", "NAZAM", "VERSE", etc. |
| `categoryId` | `categoryId` | String | Now optional (can be null) |

**GET /api/poems/search:**
- ❌ Removed `language` query parameter
- Now searches across all poem content (all languages/scripts)
- Will be replaced with Elasticsearch for verse-level search

**Future Enhancements (Coming Soon):**
- Enhanced DTOs with multilingual content
- Verse-level search using Elasticsearch + BM25
- Translation management endpoints
- Script transliteration support

---

## 5. Enhanced Poet Endpoints

Base Path: `/api/poets`

**IMPORTANT:** All poet endpoints support multi-language responses. Use the `lang` query parameter to get poet information in your preferred language (ur, en, or hi). Default is Urdu (ur).

### Multi-Language Support

All poet data (names, biographies, locations) are stored in 3 languages:
- **ur** (Urdu) - اردو
- **en** (English)
- **hi** (Hindi) - हिंदी

Example: `GET /api/poets?lang=en` will return poet names and bios in English.

---

## 5.1 Browse & Discovery Endpoints

### 5.1.1 Get All Poets

**Endpoint:** `GET /api/poets?page=0&size=10&lang=ur&sortBy=viewCount&sortDir=desc`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)
- `sortBy` (optional): Sort field (default: viewCount)
  - Valid values: `viewCount`, `poemCount`, `followerCount`, `birthYear`, `deathYear`, `createdAt`, `updatedAt`
  - **Note:** Cannot sort by `name` directly as names are stored in multiple languages
- `sortDir` (optional): Sort direction - asc/desc (default: desc)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_abc123",
        "name": "علامہ اقبال",
        "shortBio": "شاعر مشرق، فلسفی اور مفکر",
        "birthYear": 1877,
        "deathYear": 1938,
        "profileImageUrl": "https://example.com/iqbal.jpg",
        "gender": "MALE",
        "era": "MODERN",
        "poemCount": 234,
        "viewCount": 15234,
        "isFeatured": true,
        "isTrending": false,
        "topTags": ["فلسفہ", "قومی شاعری", "مذہبی"]
      },
      {
        "publicId": "poet_def456",
        "name": "پروین شاکر",
        "shortBio": "معاصر اردو کی مشہور خاتون شاعرہ",
        "birthYear": 1952,
        "deathYear": 1994,
        "profileImageUrl": "https://example.com/parveen.jpg",
        "gender": "FEMALE",
        "era": "CONTEMPORARY",
        "poemCount": 156,
        "viewCount": 8932,
        "isFeatured": true,
        "isTrending": true,
        "topTags": ["رومانوی", "جدید غزل", "عصری"]
      }
    ],
    "totalElements": 234,
    "totalPages": 24,
    "last": false
  }
}
```

---

### 5.1.2 Get Featured Poets

**Endpoint:** `GET /api/poets/featured?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets marked as featured (prominent poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Featured poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East, philosopher and thinker",
        "birthYear": 1877,
        "deathYear": 1938,
        "profileImageUrl": "https://example.com/iqbal.jpg",
        "gender": "MALE",
        "era": "MODERN",
        "poemCount": 234,
        "viewCount": 15234,
        "isFeatured": true,
        "topTags": ["Philosophy", "National Poetry", "Religious"]
      }
    ],
    "totalElements": 25,
    "totalPages": 3
  }
}
```

---

### 5.1.3 Get Trending Poets

**Endpoint:** `GET /api/poets/trending?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets currently trending or popular

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Trending poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_xyz789",
        "name": "Ahmad Faraz",
        "shortBio": "Contemporary romantic poet",
        "birthYear": 1931,
        "deathYear": 2008,
        "profileImageUrl": "https://example.com/faraz.jpg",
        "gender": "MALE",
        "era": "CONTEMPORARY",
        "poemCount": 189,
        "viewCount": 12456,
        "isTrending": true,
        "topTags": ["Romantic", "Ghazal", "Modern"]
      }
    ],
    "totalElements": 15,
    "totalPages": 2
  }
}
```

---

### 5.1.4 Get Poets by Gender

**Endpoint:** `GET /api/poets/gender/{gender}?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Filter poets by gender (for example, women poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `gender`: MALE, FEMALE, OTHER

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/gender/FEMALE?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_def456",
        "name": "Parveen Shakir",
        "shortBio": "Famous contemporary Urdu poetess",
        "birthYear": 1952,
        "deathYear": 1994,
        "gender": "FEMALE",
        "era": "CONTEMPORARY",
        "poemCount": 156,
        "viewCount": 8932,
        "topTags": ["Romantic", "Modern Ghazal", "Contemporary"]
      },
      {
        "publicId": "poet_ghi789",
        "name": "Ada Jafri",
        "shortBio": "Leading Urdu poetess of modern era",
        "birthYear": 1924,
        "deathYear": 2015,
        "gender": "FEMALE",
        "era": "MODERN",
        "poemCount": 98,
        "viewCount": 5432,
        "topTags": ["Progressive", "Feminist", "Social"]
      }
    ],
    "totalElements": 42,
    "totalPages": 5
  }
}
```

---

### 5.1.5 Get Poets by Era

**Endpoint:** `GET /api/poets/era/{era}?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Filter poets by historical era

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `era`: CLASSICAL, MODERN, CONTEMPORARY, EMERGING

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/era/CLASSICAL?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "One of the most influential Urdu poets",
        "birthYear": 1797,
        "deathYear": 1869,
        "era": "CLASSICAL",
        "gender": "MALE",
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      }
    ],
    "totalElements": 67,
    "totalPages": 7
  }
}
```

**Era Values:**
- `CLASSICAL` - Classical era poets (pre-1900)
- `MODERN` - Modern era poets (1900-1980)
- `CONTEMPORARY` - Contemporary poets (1980-present)
- `EMERGING` - Emerging new poets

---

### 5.1.6 Get Poets by Tag

**Endpoint:** `GET /api/poets/tags/{tagSlug}?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Filter poets by tag/category (e.g., ghazal-masters, romantic-poets, sufi-poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `tagSlug`: Slug of the tag (e.g., "ghazal-masters", "women-poets", "sufi-poets")

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/tags/ghazal-masters?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "Master of Ghazal poetry",
        "birthYear": 1797,
        "deathYear": 1869,
        "era": "CLASSICAL",
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      },
      {
        "publicId": "poet_mir",
        "name": "Mir Taqi Mir",
        "shortBio": "God of Urdu Ghazal",
        "birthYear": 1723,
        "deathYear": 1810,
        "era": "CLASSICAL",
        "poemCount": 245,
        "viewCount": 18923,
        "topTags": ["Ghazal", "Classical", "Love Poetry"]
      }
    ],
    "totalElements": 15,
    "totalPages": 2
  }
}
```

---

### 5.1.7 Search Poets (Enhanced with Elasticsearch)

**Endpoint:** `GET /api/poets/search?query=iqbal&lang=ur&page=0&size=10`

**Authentication Required:** Yes

**Description:**
Enhanced search with Elasticsearch and PostgreSQL fallback. Searches across poet names, biographies, and details in multiple languages and scripts.

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `query` (required): Search query (supports fuzzy matching)
- `lang` (optional): Language code - `ur`, `en`, `hi` (default: `ur`)
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Examples:**
```
GET /api/poets/search?query=غالب
GET /api/poets/search?query=mirza&lang=en
GET /api/poets/search?query=ghalib&lang=ur
GET /api/poets/search?query=iqbal&page=0&size=20
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East, philosopher and thinker",
        "birthYear": 1877,
        "deathYear": 1938,
        "era": "MODERN",
        "gender": "MALE",
        "poemCount": 234,
        "viewCount": 15234,
        "topTags": ["Philosophy", "Nationalism", "Ghazal"]
      }
    ],
    "totalElements": 1,
    "totalPages": 1
  }
}
```

**Notes:**
- Uses Elasticsearch for fast, relevant search with BM25 scoring
- Searches across poet names, biographies, and short bios
- Falls back to PostgreSQL if Elasticsearch is unavailable
- Supports fuzzy matching for typo tolerance
- Multi-field search with boosted name field (highest relevance)

---

## 5.2 Top & Ranking Endpoints

### 5.2.1 Get Top Poets by Poem Count

**Endpoint:** `GET /api/poets/top/by-poems?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets ranked by number of poems (most prolific poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Top poets by poem count retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "One of the most influential Urdu poets",
        "birthYear": 1797,
        "deathYear": 1869,
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      },
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East",
        "birthYear": 1877,
        "deathYear": 1938,
        "poemCount": 234,
        "viewCount": 15234,
        "topTags": ["Philosophy", "National", "Religious"]
      }
    ],
    "totalElements": 234,
    "totalPages": 24
  }
}
```

---

### 5.2.2 Get Top Poets by Views

**Endpoint:** `GET /api/poets/top/by-views?page=0&size=10&lang=ur`

**Authentication Required:** Yes

**Description:** Get poets ranked by view count (most popular poets)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Top poets by views retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "poet_ghalib",
        "name": "Mirza Ghalib",
        "shortBio": "One of the most influential Urdu poets",
        "birthYear": 1797,
        "deathYear": 1869,
        "poemCount": 312,
        "viewCount": 23456,
        "topTags": ["Ghazal", "Classical", "Philosophy"]
      },
      {
        "publicId": "poet_abc123",
        "name": "Allama Iqbal",
        "shortBio": "Poet of the East",
        "birthYear": 1877,
        "deathYear": 1938,
        "poemCount": 234,
        "viewCount": 15234,
        "topTags": ["Philosophy", "National", "Religious"]
      }
    ],
    "totalElements": 234,
    "totalPages": 24
  }
}
```

---

## 5.3 Poet Profile Endpoints

### 5.3.1 Get Complete Poet Profile

**Endpoint:** `GET /api/poets/{publicId}/profile?lang=ur`

**Authentication Required:** Yes

**Description:** Get complete poet profile with all information including gallery, books, videos, and facts. **View count is automatically incremented.**

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/poet_abc123/profile?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet profile retrieved successfully",
  "data": {
    "publicId": "poet_abc123",
    "name": "Allama Iqbal",
    "biography": "Muhammad Iqbal was a poet, philosopher, and politician. Born in Sialkot, British India (now in Pakistan), he is widely regarded as having inspired the Pakistan Movement. He is considered one of the most important figures in Urdu and Persian literature...",
    "shortBio": "Poet of the East, philosopher and thinker",
    "gender": "MALE",
    "era": "MODERN",
    "birthYear": 1877,
    "deathYear": 1938,
    "birthDate": "1877-11-09",
    "deathDate": "1938-04-21",
    "birthPlace": "Sialkot",
    "country": "Pakistan",
    "primaryLanguageCode": "ur",
    "primaryLanguageName": "Urdu",
    "isFeatured": true,
    "isTrending": false,
    "isVerified": true,
    "viewCount": 15235,
    "followerCount": 4532,
    "poemCount": 234,
    "gallery": [
      {
        "publicId": "img_123",
        "imageUrl": "https://example.com/iqbal-portrait.jpg",
        "thumbnailUrl": "https://example.com/iqbal-portrait-thumb.jpg",
        "caption": "Portrait of Allama Iqbal",
        "altText": "Allama Iqbal portrait",
        "displayOrder": 1,
        "isProfileImage": true,
        "imageType": "PROFILE"
      },
      {
        "publicId": "img_124",
        "imageUrl": "https://example.com/iqbal-young.jpg",
        "thumbnailUrl": "https://example.com/iqbal-young-thumb.jpg",
        "caption": "Young Iqbal in Cambridge",
        "altText": "Young Allama Iqbal",
        "displayOrder": 2,
        "isProfileImage": false,
        "imageType": "HISTORICAL"
      }
    ],
    "books": [
      {
        "publicId": "book_123",
        "languageCode": "ur",
        "languageName": "Urdu",
        "title": "Bang-e-Dara",
        "subtitle": "The Call of the Marching Bell",
        "description": "A collection of patriotic poetry",
        "yearPublished": 1924,
        "publisher": "Taj Company",
        "isbn": "978-1234567890",
        "isbn13": "978-1234567890123",
        "pageCount": 234,
        "coverImageUrl": "https://example.com/bang-e-dara.jpg",
        "isAvailable": true,
        "bookType": "POETRY_COLLECTION"
      },
      {
        "publicId": "book_124",
        "languageCode": "fa",
        "languageName": "Persian",
        "title": "Asrar-e-Khudi",
        "subtitle": "The Secrets of the Self",
        "description": "Philosophical poetry in Persian",
        "yearPublished": 1915,
        "publisher": "Dar al-Kutub",
        "isbn": "978-9876543210",
        "pageCount": 189,
        "coverImageUrl": "https://example.com/asrar.jpg",
        "isAvailable": true,
        "bookType": "POETRY_COLLECTION"
      }
    ],
    "videos": [
      {
        "publicId": "vid_123",
        "title": "Shikwa - Recitation by Mehdi Hassan",
        "description": "Beautiful rendition of Iqbal's Shikwa",
        "videoUrl": "https://youtube.com/watch?v=xyz",
        "thumbnailUrl": "https://img.youtube.com/vi/xyz/0.jpg",
        "duration": 1240,
        "yearRecorded": 1982,
        "videoType": "RECITATION"
      },
      {
        "publicId": "vid_124",
        "title": "Documentary: Life of Allama Iqbal",
        "description": "Complete biography documentary",
        "videoUrl": "https://youtube.com/watch?v=abc",
        "thumbnailUrl": "https://img.youtube.com/vi/abc/0.jpg",
        "duration": 3600,
        "yearRecorded": 2015,
        "videoType": "DOCUMENTARY"
      }
    ],
    "facts": [
      "Studied at Government College Lahore, Cambridge, and Munich",
      "Knighted by King George V in 1922",
      "Delivered the famous Allahabad Address in 1930",
      "Wrote poetry in both Urdu and Persian",
      "Considered the spiritual father of Pakistan"
    ],
    "tags": [
      {
        "publicId": "tag_123",
        "name": "National Poetry",
        "slug": "national-poetry",
        "color": "#FF5733",
        "tagType": "POEM_GENRE",
        "description": "Poetry with national and patriotic themes"
      },
      {
        "publicId": "tag_124",
        "name": "Philosophy",
        "slug": "philosophy",
        "color": "#33C4FF",
        "tagType": "POEM_GENRE",
        "description": "Philosophical and intellectual poetry"
      },
      {
        "publicId": "tag_125",
        "name": "Modern Era",
        "slug": "modern-era",
        "color": "#85FF33",
        "tagType": "ERA",
        "description": "Poets of the modern era"
      }
    ],
    "createdAt": "2024-01-01T10:00:00",
    "updatedAt": "2024-01-15T14:30:00"
  }
}
```

---

### 5.3.2 Get Poet Gallery

**Endpoint:** `GET /api/poets/{publicId}/gallery`

**Authentication Required:** Yes

**Description:** Get all images in poet's gallery

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Example:** `GET /api/poets/poet_abc123/gallery`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet gallery retrieved successfully",
  "data": [
    {
      "publicId": "img_123",
      "imageUrl": "https://example.com/iqbal-portrait.jpg",
      "thumbnailUrl": "https://example.com/iqbal-portrait-thumb.jpg",
      "caption": "Portrait of Allama Iqbal",
      "altText": "Allama Iqbal portrait",
      "displayOrder": 1,
      "isProfileImage": true,
      "imageType": "PROFILE"
    },
    {
      "publicId": "img_124",
      "imageUrl": "https://example.com/iqbal-young.jpg",
      "thumbnailUrl": "https://example.com/iqbal-young-thumb.jpg",
      "caption": "Young Iqbal in Cambridge",
      "altText": "Young Allama Iqbal",
      "displayOrder": 2,
      "isProfileImage": false,
      "imageType": "HISTORICAL"
    }
  ]
}
```

**Image Types:**
- `PROFILE` - Profile/main image
- `PORTRAIT` - Portrait photograph
- `HISTORICAL` - Historical photograph
- `EVENT` - Event or occasion photo
- `OTHER` - Other type

---

### 5.3.3 Get Poet Books

**Endpoint:** `GET /api/poets/{publicId}/books?lang=ur`

**Authentication Required:** Yes

**Description:** Get all books/publications by the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `lang` (optional): Filter by book language (ur/en/fa/ar/hi)

**Example:** `GET /api/poets/poet_abc123/books?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet books retrieved successfully",
  "data": [
    {
      "publicId": "book_123",
      "languageCode": "ur",
      "languageName": "Urdu",
      "title": "Bang-e-Dara",
      "subtitle": "The Call of the Marching Bell",
      "description": "A collection of patriotic poetry written during the independence movement",
      "yearPublished": 1924,
      "publisher": "Taj Company",
      "isbn": "978-1234567890",
      "isbn13": "978-1234567890123",
      "pageCount": 234,
      "coverImageUrl": "https://example.com/bang-e-dara.jpg",
      "isAvailable": true,
      "bookType": "POETRY_COLLECTION"
    },
    {
      "publicId": "book_125",
      "languageCode": "ur",
      "languageName": "Urdu",
      "title": "Bal-e-Jibril",
      "subtitle": "Gabriel's Wing",
      "description": "One of the most celebrated collections",
      "yearPublished": 1935,
      "publisher": "Shaikh Ghulam Ali",
      "isbn": "978-1234567891",
      "pageCount": 189,
      "coverImageUrl": "https://example.com/bal-e-jibril.jpg",
      "isAvailable": true,
      "bookType": "POETRY_COLLECTION"
    }
  ]
}
```

**Book Types:**
- `POETRY_COLLECTION` - Collection of poems
- `ANTHOLOGY` - Anthology or compiled works
- `BIOGRAPHY` - Biographical book
- `CRITICISM` - Literary criticism
- `OTHER` - Other type

**Note:** Books are stored in their original language only (not translated)

---

### 5.3.4 Get Poet Videos

**Endpoint:** `GET /api/poets/{publicId}/videos?type=RECITATION`

**Authentication Required:** Yes

**Description:** Get videos related to the poet (mushairas, recitations, documentaries)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `type` (optional): Filter by video type (MUSHAIRA, INTERVIEW, DOCUMENTARY, RECITATION, BIOGRAPHY, OTHER)

**Example:** `GET /api/poets/poet_abc123/videos?type=DOCUMENTARY`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet videos retrieved successfully",
  "data": [
    {
      "publicId": "vid_123",
      "title": "Documentary: Life of Allama Iqbal",
      "description": "Complete biography documentary covering his life, philosophy, and contribution to Urdu literature",
      "videoUrl": "https://youtube.com/watch?v=abc123",
      "thumbnailUrl": "https://img.youtube.com/vi/abc123/maxresdefault.jpg",
      "duration": 3600,
      "yearRecorded": 2015,
      "videoType": "DOCUMENTARY"
    },
    {
      "publicId": "vid_124",
      "title": "Iqbal: The Visionary",
      "description": "Documentary on Iqbal's political vision",
      "videoUrl": "https://youtube.com/watch?v=def456",
      "thumbnailUrl": "https://img.youtube.com/vi/def456/maxresdefault.jpg",
      "duration": 2700,
      "yearRecorded": 2018,
      "videoType": "DOCUMENTARY"
    }
  ]
}
```

**Video Types:**
- `MUSHAIRA` - Poetry gathering/mushaira
- `INTERVIEW` - Interview about the poet
- `DOCUMENTARY` - Documentary film
- `RECITATION` - Poetry recitation
- `BIOGRAPHY` - Biographical video
- `OTHER` - Other type

**Note:** Duration is in seconds

---

### 5.3.5 Get Poet Facts

**Endpoint:** `GET /api/poets/{publicId}/facts?lang=ur`

**Authentication Required:** Yes

**Description:** Get interesting facts about the poet in specified language

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: ur)

**Example:** `GET /api/poets/poet_abc123/facts?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet facts retrieved successfully",
  "data": [
    "Studied at Government College Lahore, Cambridge, and Munich",
    "Knighted by King George V in 1922",
    "Delivered the famous Allahabad Address in 1930",
    "Wrote poetry in both Urdu and Persian",
    "Considered the spiritual father of Pakistan",
    "His poetry inspired the Pakistan Movement",
    "Specialized in philosophy and Islamic revival"
  ]
}
```

**Note:** Facts are stored and returned in all 3 languages (ur, en, hi)

---

## 5.4 Admin CRUD Endpoints

**IMPORTANT:** These endpoints are for admin use only. In production, add proper role-based access control.

### 5.4.1 Create Poet

**Endpoint:** `POST /api/poets`

**Authentication Required:** Yes (Admin only)

**Description:** Create a new poet with initial translation

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "gender": "MALE",
  "era": "MODERN",
  "birthYear": 1877,
  "deathYear": 1938,
  "birthDate": "1877-11-09",
  "deathDate": "1938-04-21",
  "birthPlaceId": "city_sialkot",
  "countryId": "country_pakistan",
  "primaryLanguageCode": "ur",
  "isFeatured": true,
  "isTrending": false,
  "languageCode": "ur",
  "name": "علامہ اقبال",
  "biography": "علامہ محمد اقبال ایک شاعر، فلسفی اور سیاست دان تھے...",
  "shortBio": "شاعر مشرق، فلسفی اور مفکر"
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Poet created successfully",
  "data": {
    "id": 123,
    "publicId": "poet_abc123",
    "gender": "MALE",
    "era": "MODERN",
    "birthYear": 1877,
    "deathYear": 1938,
    "isFeatured": true,
    "viewCount": 0,
    "followerCount": 0,
    "poemCount": 0,
    "createdAt": "2024-01-15T14:30:00"
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Error creating poet: Birth place not found",
  "data": null
}
```

---

### 5.4.2 Update Poet

**Endpoint:** `PUT /api/poets/{publicId}`

**Authentication Required:** Yes (Admin only)

**Description:** Update poet's basic information (NOT translations)

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body (all fields optional):**
```json
{
  "gender": "MALE",
  "era": "MODERN",
  "birthYear": 1877,
  "deathYear": 1938,
  "birthDate": "1877-11-09",
  "deathDate": "1938-04-21",
  "birthPlaceId": "city_sialkot",
  "countryId": "country_pakistan",
  "primaryLanguageCode": "ur",
  "isFeatured": true,
  "isTrending": false,
  "isVerified": true
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poet updated successfully",
  "data": {
    "id": 123,
    "publicId": "poet_abc123",
    "gender": "MALE",
    "era": "MODERN",
    "birthYear": 1877,
    "deathYear": 1938,
    "isFeatured": true,
    "isTrending": false,
    "isVerified": true,
    "updatedAt": "2024-01-15T14:30:00"
  }
}
```

---

### 5.4.3 Add Poet Translation

**Endpoint:** `POST /api/poets/{publicId}/details`

**Authentication Required:** Yes (Admin only)

**Description:** Add or update poet's name and biography in another language

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "languageCode": "en",
  "name": "Allama Iqbal",
  "biography": "Muhammad Iqbal was a poet, philosopher, and politician...",
  "shortBio": "Poet of the East, philosopher and thinker"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Translation added successfully",
  "data": null
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Error adding translation: Language not found",
  "data": null
}
```

---

### 5.4.4 Add Poet Image

**Endpoint:** `POST /api/poets/{publicId}/images`

**Authentication Required:** Yes (Admin only)

**Description:** Add image to poet's gallery

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "imageUrl": "https://example.com/iqbal-portrait.jpg",
  "thumbnailUrl": "https://example.com/iqbal-portrait-thumb.jpg",
  "caption": "Portrait of Allama Iqbal",
  "altText": "Allama Iqbal portrait",
  "displayOrder": 1,
  "isProfileImage": true,
  "imageType": "PROFILE"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image added successfully",
  "data": null
}
```

**Note:** If `isProfileImage` is true, any existing profile image will be automatically unset.

---

### 5.4.5 Add Poet Book

**Endpoint:** `POST /api/poets/{publicId}/books`

**Authentication Required:** Yes (Admin only)

**Description:** Add book/publication to poet's bibliography

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "languageCode": "ur",
  "title": "Bang-e-Dara",
  "subtitle": "The Call of the Marching Bell",
  "description": "A collection of patriotic poetry",
  "yearPublished": 1924,
  "publisher": "Taj Company",
  "isbn": "978-1234567890",
  "isbn13": "978-1234567890123",
  "pageCount": 234,
  "coverImageUrl": "https://example.com/bang-e-dara.jpg",
  "displayOrder": 1,
  "isAvailable": true,
  "bookType": "POETRY_COLLECTION"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Book added successfully",
  "data": null
}
```

---

### 5.4.6 Add Poet Video

**Endpoint:** `POST /api/poets/{publicId}/videos`

**Authentication Required:** Yes (Admin only)

**Description:** Add video (mushaira, documentary, etc.) to poet's media

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "title": "Documentary: Life of Allama Iqbal",
  "description": "Complete biography documentary",
  "videoUrl": "https://youtube.com/watch?v=abc123",
  "thumbnailUrl": "https://img.youtube.com/vi/abc123/maxresdefault.jpg",
  "duration": 3600,
  "yearRecorded": 2015,
  "videoType": "DOCUMENTARY",
  "displayOrder": 1
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Video added successfully",
  "data": null
}
```

**Note:** Duration is in seconds

---

### 5.4.7 Add Poet Fact

**Endpoint:** `POST /api/poets/{publicId}/facts`

**Authentication Required:** Yes (Admin only)

**Description:** Add interesting fact about poet in all 3 languages at once

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Path Parameters:**
- `publicId`: Public ID of the poet

**Request Body:**
```json
{
  "factsByLanguage": {
    "ur": "انہوں نے کیمبرج، لاہور اور میونخ میں تعلیم حاصل کی",
    "en": "Studied at Government College Lahore, Cambridge, and Munich",
    "hi": "लाहौर, कैम्ब्रिज और म्यूनिख में शिक्षा प्राप्त की"
  },
  "displayOrder": 1
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Fact added successfully",
  "data": null
}
```

**Note:** Must provide fact in all 3 languages. They are linked internally by a factGroupId.

---

### 5.4.8 Add Tag to Poet

**Endpoint:** `POST /api/poets/{publicId}/tags/{tagId}`

**Authentication Required:** Yes (Admin only)

**Description:** Associate a tag with the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `tagId`: Public ID of the tag

**Example:** `POST /api/poets/poet_abc123/tags/tag_ghazal123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tag added successfully",
  "data": null
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Error adding tag: Tag not found",
  "data": null
}
```

---

### 5.4.9 Delete Poet Image

**Endpoint:** `DELETE /api/poets/{publicId}/images/{imageId}`

**Authentication Required:** Yes (Admin only)

**Description:** Remove image from poet's gallery

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `imageId`: Public ID of the image

**Example:** `DELETE /api/poets/poet_abc123/images/img_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image deleted successfully",
  "data": null
}
```

---

### 5.4.10 Delete Poet Video

**Endpoint:** `DELETE /api/poets/{publicId}/videos/{videoId}`

**Authentication Required:** Yes (Admin only)

**Description:** Remove video from poet's media

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `videoId`: Public ID of the video

**Example:** `DELETE /api/poets/poet_abc123/videos/vid_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Video deleted successfully",
  "data": null
}
```

---

### 5.4.11 Delete Poet Book

**Endpoint:** `DELETE /api/poets/{publicId}/books/{bookId}`

**Authentication Required:** Yes (Admin only)

**Description:** Remove book from poet's bibliography

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `bookId`: Public ID of the book

**Example:** `DELETE /api/poets/poet_abc123/books/book_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Book deleted successfully",
  "data": null
}
```

---

### 5.4.12 Remove Tag from Poet

**Endpoint:** `DELETE /api/poets/{publicId}/tags/{tagId}`

**Authentication Required:** Yes (Admin only)

**Description:** Dissociate a tag from the poet

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the poet
- `tagId`: Public ID of the tag

**Example:** `DELETE /api/poets/poet_abc123/tags/tag_ghazal123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tag removed successfully",
  "data": null
}
```

---

## 5.5 Enum Values for Poet Endpoints

### Gender
- `MALE` - Male poet
- `FEMALE` - Female poet
- `OTHER` - Other/Non-binary

### Era
- `CLASSICAL` - Classical era (pre-1900)
- `MODERN` - Modern era (1900-1980)
- `CONTEMPORARY` - Contemporary (1980-present)
- `EMERGING` - Emerging/new poets

### VideoType
- `MUSHAIRA` - Poetry gathering
- `INTERVIEW` - Interview
- `DOCUMENTARY` - Documentary film
- `RECITATION` - Poetry recitation
- `BIOGRAPHY` - Biographical video
- `OTHER` - Other type

### BookType
- `POETRY_COLLECTION` - Collection of poems
- `ANTHOLOGY` - Anthology/compiled works
- `BIOGRAPHY` - Biographical book
- `CRITICISM` - Literary criticism
- `OTHER` - Other type

### ImageType
- `PROFILE` - Profile/main image
- `PORTRAIT` - Portrait photograph
- `HISTORICAL` - Historical photograph
- `EVENT` - Event/occasion photo
- `OTHER` - Other type

### TagType
- `POET_CATEGORY` - Poet categorization (e.g., "women-poets", "emerging-poets")
- `POEM_GENRE` - Poetry genre (e.g., "ghazal", "nazm")
- `GENERAL` - General tag
- `LANGUAGE` - Language-based tag
- `ERA` - Era-based tag

---

## 5.6 Notes for Poet Endpoints

1. **Multi-Language Support:**
   - All text fields (name, biography, shortBio) are stored separately for ur/en/hi
   - Use `?lang=ur` or `?lang=en` or `?lang=hi` to get data in specific language
   - Default language is Urdu (ur)
   - Geographic data (cities, countries) also have translations

2. **View Count Tracking:**
   - View count is automatically incremented when fetching poet profile
   - Use top/by-views endpoint to get most popular poets

3. **Profile Image:**
   - Only one image can be marked as profile image
   - When adding a new profile image, old one is automatically unset
   - Use gallery endpoint to get all images

4. **Books vs Translations:**
   - Books are stored in their ORIGINAL language only
   - Use `?lang=ur` parameter to filter books by language
   - No translation of book content

5. **Facts in Multiple Languages:**
   - Facts must be provided in all 3 languages when adding
   - They are internally linked by factGroupId
   - Use `?lang=ur` to get facts in specific language

6. **Tags for Categorization:**
   - Use tags to categorize poets (e.g., "ghazal-masters", "women-poets", "sufi-poets")
   - Filter poets by tag using `/api/poets/tags/{tagSlug}`
   - Tags have types (POET_CATEGORY, POEM_GENRE, etc.)

7. **Pagination:**
   - All list endpoints support pagination
   - Use standard `page` and `size` parameters
   - Default: page=0, size=10

8. **Sorting:**
   - Most endpoints support sorting via `sortBy` and `sortDir`
   - Common sort fields: name, birthYear, poemCount, viewCount
   - Sort direction: asc or desc

---

---

## 5.7 Global Search Endpoint (NEW)

### 5.7.1 Unified Search

**Endpoint:** `GET /api/search?q=محبت&type=all&lang=ur&page=0&size=10`

**Authentication Required:** Yes

**Description:**
Unified search across ALL content types: poems, verses, poets, and categories simultaneously.
This is the primary search endpoint for the application - provides comprehensive search results in a single request.

**Base Path:** `/api/search`

**Request Headers:**

---

## 6. Couplet Engagement System

### 6.1 Overview {#61-overview-couplets}

The Couplet Engagement System allows users to interact with individual couplets (verses) from Ghazals and other poetry. This fine-grained engagement enables users to like, bookmark, and share specific couplets rather than entire poems.

**Key Features:**
- ✅ **Couplet-Level Engagement**: Like, bookmark individual couplets
- 🔗 **Deep Linking**: Share specific couplets with shareable URLs
- 📊 **Analytics**: Track most liked, most shared, trending couplets
- 📱 **User Collections**: Personal collections of liked/bookmarked couplets
- 🎯 **Discovery**: Find popular couplets by poet or globally

**What is a Couplet?**
In Ghazal poetry, each two-line verse (sher) is called a couplet. The system automatically parses Ghazals into couplets for fine-grained interaction.

**Base Path:** `/api/couplets`, `/api/poems/{poemPublicId}/couplets`

**Authentication:** Required for all endpoints

---

### 6.2 Couplet Retrieval

#### 6.2.1 Get Couplets by Poem {#621-get-couplets-by-poem}

**Endpoint:** `GET /api/poems/{poemPublicId}/couplets?lang=ur`

**Authentication Required:** Yes

**Description:**
Get all couplets for a specific poem in the requested language. For Ghazals, this returns all verses parsed as couplets. For other poetry types, returns verses grouped by stanza.

**Path Parameters:**
- `poemPublicId` (required): Public ID of the poem

**Query Parameters:**
- `lang` (optional): Language code - `ur`, `en`, `hi` (defaults to poem's original language)

**Example:** `GET /api/poems/poem_xyz789/couplets?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplets retrieved successfully",
  "data": [
    {
      "publicId": "couplet_abc123",
      "coupletNumber": 1,
      "verses": [
        {
          "publicId": "verse_111",
          "verseText": "دل کی ویرانی کا کیا مذکور ہے",
          "verseNumber": 1,
          "verseType": "MATLA"
        },
        {
          "publicId": "verse_112",
          "verseText": "یہ نگر سو مرتبہ لوٹا گیا",
          "verseNumber": 2,
          "verseType": "MATLA"
        }
      ],
      "poemPublicId": "poem_xyz789",
      "contentPublicId": "content_ur_123",
      "likeCount": 45,
      "bookmarkCount": 23,
      "shareCount": 12,
      "createdAt": "2024-12-01T10:00:00"
    },
    {
      "publicId": "couplet_abc124",
      "coupletNumber": 2,
      "verses": [
        {
          "publicId": "verse_113",
          "verseText": "کوئی ویرانہ سا ویرانہ بنا کے",
          "verseNumber": 3,
          "verseType": null
        },
        {
          "publicId": "verse_114",
          "verseText": "دل کا صحرا بھی گلستاں بنا دیتے ہیں",
          "verseNumber": 4,
          "verseType": null
        }
      ],
      "likeCount": 67,
      "bookmarkCount": 34,
      "shareCount": 18
    }
  ]
}
```

**Flutter Usage:**
```dart
Future<List<Couplet>> getCoupletsByPoem(String poemId, String lang) async {
  final response = await dio.get(
    '/api/poems/$poemId/couplets',
    queryParameters: {'lang': lang},
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  
  final apiResponse = ApiResponse<List<dynamic>>.fromJson(response.data);
  return apiResponse.data!.map((json) => Couplet.fromJson(json)).toList();
}
```

---

#### 6.2.2 Get Couplet Detail {#622-get-couplet-detail}

**Endpoint:** `GET /api/couplets/{coupletPublicId}`

**Authentication Required:** Yes

**Description:**
Get detailed information about a specific couplet, including the user's like/bookmark status, poem context, and poet information.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Example:** `GET /api/couplets/couplet_abc123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet retrieved successfully",
  "data": {
    "couplet": {
      "publicId": "couplet_abc123",
      "coupletNumber": 1,
      "verses": [
        {
          "publicId": "verse_111",
          "verseText": "دل کی ویرانی کا کیا مذکور ہے",
          "verseNumber": 1,
          "verseType": "MATLA"
        },
        {
          "publicId": "verse_112",
          "verseText": "یہ نگر سو مرتبہ لوٹا گیا",
          "verseNumber": 2,
          "verseType": "MATLA"
        }
      ],
      "likeCount": 45,
      "bookmarkCount": 23,
      "shareCount": 12
    },
    "poem": {
      "publicId": "poem_xyz789",
      "title": "دل کی ویرانی",
      "poetryType": "GHAZAL"
    },
    "poet": {
      "publicId": "poet_ghalib123",
      "name": "Mirza Ghalib",
      "profileImageUrl": "https://cdn.example.com/ghalib.jpg"
    },
    "userStatus": {
      "isLiked": true,
      "isBookmarked": false
    }
  }
}
```

**Use Case:** Detail page when user taps on a shared couplet link

---

### 6.3 Engagement Actions

#### 6.3.1 Like Couplet {#631-like-couplet}

**Endpoint:** `POST /api/couplets/{coupletPublicId}/like`

**Authentication Required:** Yes

**Description:**
Toggle like status on a couplet. If already liked, it will unlike. Returns updated couplet details with new like count.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Example:** `POST /api/couplets/couplet_abc123/like`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet liked successfully",
  "data": {
    "couplet": {
      "publicId": "couplet_abc123",
      "coupletNumber": 1,
      "verses": [...],
      "likeCount": 46,
      "bookmarkCount": 23,
      "shareCount": 12
    },
    "userStatus": {
      "isLiked": true,
      "isBookmarked": false
    }
  }
}
```

**Flutter Usage:**
```dart
Future<CoupletDetail> toggleLikeCouplet(String coupletId) async {
  final response = await dio.post(
    '/api/couplets/$coupletId/like',
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  
  final apiResponse = ApiResponse<Map<String, dynamic>>.fromJson(response.data);
  return CoupletDetail.fromJson(apiResponse.data!);
}

// UI Example
IconButton(
  icon: Icon(
    couplet.userStatus.isLiked ? Icons.favorite : Icons.favorite_border,
    color: couplet.userStatus.isLiked ? Colors.red : Colors.grey,
  ),
  onPressed: () async {
    final updated = await toggleLikeCouplet(couplet.publicId);
    setState(() {
      couplet = updated;
    });
  },
)
```

**Note:** Creates engagement activity record for personalization

---

#### 6.3.2 Bookmark Couplet {#632-bookmark-couplet}

**Endpoint:** `POST /api/couplets/{coupletPublicId}/bookmark?lang=ur`

**Authentication Required:** Yes

**Description:**
Toggle bookmark status on a couplet for later reference. Bookmarked couplets appear in user's collection. The language parameter preserves the language context in which the user bookmarked the content.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Query Parameters:**
- `lang` (optional, default: "ur"): Language code when bookmarking (ur, en, hi, etc.). This is stored with the bookmark so the content can be displayed in the bookmarked language later.

**Example:** `POST /api/couplets/couplet_abc123/bookmark?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet bookmarked successfully",
  "data": {
    "couplet": {
      "publicId": "couplet_abc123",
      "verses": [...],
      "likeCount": 46,
      "bookmarkCount": 24,
      "shareCount": 12
    },
    "userStatus": {
      "isLiked": true,
      "isBookmarked": true
    }
  }
}
```

---

#### 6.3.3 Share Couplet {#633-share-couplet}

**Endpoint:** `POST /api/couplets/{coupletPublicId}/share`

**Authentication Required:** Yes

**Description:**
Generate shareable link for a couplet with Open Graph metadata for social media sharing. Tracks share action for analytics.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Request Body:**
```json
{
  "shareType": "WHATSAPP"
}
```

**Share Types:**
- `WHATSAPP` - WhatsApp sharing
- `FACEBOOK` - Facebook sharing
- `TWITTER` - Twitter/X sharing
- `INSTAGRAM` - Instagram sharing (image required)
- `COPY_LINK` - Generic link copy
- `SMS` - SMS sharing
- `EMAIL` - Email sharing

**Success Response (200):**
```json
{
  "success": true,
  "message": "Share link created successfully",
  "data": {
    "shareUrl": "https://poetry.com/c/abc123-short",
    "deepLink": "poetry://couplet/couplet_abc123",
    "shareToken": "abc123xyz",
    "coupletPublicId": "couplet_abc123",
    "coupletNumber": 1,
    "coupletTypeBadge": "Matla (Opening Couplet)",
    "poemContext": "From 'دل کی ویرانی' by Mirza Ghalib",
    "poetName": "Mirza Ghalib",
    "poemPublicId": "poem_xyz789",
    "poemTitle": "دل کی ویرانی",
    "verseTexts": [
      "دل کی ویرانی کا کیا مذکور ہے",
      "یہ نگر سو مرتبہ لوٹا گیا"
    ],
    "ogTitle": "Mirza Ghalib - دل کی ویرانی",
    "ogDescription": "دل کی ویرانی کا کیا مذکور ہے\nیہ نگر سو مرتبہ لوٹا گیا",
    "ogImage": "https://cdn.poetry.com/couplets/abc123.jpg",
    "ogUrl": "https://poetry.com/c/abc123-short",
    "shareText": "دل کی ویرانی کا کیا مذکور ہے\nیہ نگر سو مرتبہ لوٹا گیا\n\n— Mirza Ghalib\nhttps://poetry.com/c/abc123-short"
  }
}
```

**Flutter Share Example:**
```dart
Future<void> shareCouplet(String coupletId, ShareType type) async {
  // Create share link
  final response = await dio.post(
    '/api/couplets/$coupletId/share',
    data: {'shareType': type.name},
    options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
  );
  
  final shareData = ShareLinkResponse.fromJson(response.data['data']);
  
  // Use Flutter Share package
  await Share.share(
    shareData.shareText,
    subject: shareData.ogTitle,
  );
  
  // Or use platform-specific sharing
  switch (type) {
    case ShareType.WHATSAPP:
      await launchUrl(Uri.parse('whatsapp://send?text=${Uri.encodeComponent(shareData.shareText)}'));
      break;
    case ShareType.COPY_LINK:
      await Clipboard.setData(ClipboardData(text: shareData.shareUrl));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Link copied to clipboard')),
      );
      break;
  }
}
```

**Use Case:** Share button in couplet card or detail view

---

#### 6.3.4 Get Public Share Link {#634-get-public-share-link}

**Endpoint:** `GET /api/couplets/{coupletPublicId}/share/public`

**Authentication Required:** No (Public endpoint)

**Description:**
Generate public share link without authentication. Used for generating share links in web views or when user is not logged in.

**Path Parameters:**
- `coupletPublicId` (required): Public ID of the couplet

**Example:** `GET /api/couplets/couplet_abc123/share/public`

**Success Response (200):**
Same as authenticated share endpoint

---

### 6.4 User Collections

#### 6.4.1 Get Liked Couplets {#641-get-liked-couplets}

**Endpoint:** `GET /api/users/me/couplets/liked?page=0&size=20&sortBy=createdAt&sortDir=desc`

**Authentication Required:** Yes

**Description:**
Get user's liked couplets with pagination and sorting. Returns couplets with full context (poem, poet).

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size
- `sortBy` (optional, default: `createdAt`): Sort field - `createdAt`, `likeCount`, `coupletNumber`
- `sortDir` (optional, default: `desc`): Sort direction - `asc`, `desc`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Liked couplets retrieved successfully",
  "data": {
    "content": [
      {
        "couplet": {
          "publicId": "couplet_abc123",
          "coupletNumber": 1,
          "verses": [
            {
              "verseText": "دل کی ویرانی کا کیا مذکور ہے",
              "verseNumber": 1
            },
            {
              "verseText": "یہ نگر سو مرتبہ لوٹا گیا",
              "verseNumber": 2
            }
          ],
          "likeCount": 46,
          "bookmarkCount": 24
        },
        "poem": {
          "publicId": "poem_xyz789",
          "title": "دل کی ویرانی",
          "poetryType": "GHAZAL"
        },
        "poet": {
          "publicId": "poet_ghalib123",
          "name": "Mirza Ghalib"
        },
        "likedAt": "2024-12-15T14:30:00",
        "isBookmarked": true
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

**Flutter Widget Example:**
```dart
class LikedCoupletsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liked Couplets')),
      body: FutureBuilder<Page<CoupletLike>>(
        future: apiService.getUserLikedCouplets(page: 0),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          
          final couplets = snapshot.data!.content;
          return ListView.builder(
            itemCount: couplets.length,
            itemBuilder: (context, index) {
              final item = couplets[index];
              return CoupletCard(
                couplet: item.couplet,
                poet: item.poet,
                poem: item.poem,
                isLiked: true,
                isBookmarked: item.isBookmarked,
              );
            },
          );
        },
      ),
    );
  }
}
```

---

#### 6.4.2 Get Bookmarked Couplets {#642-get-bookmarked-couplets}

**Endpoint:** `GET /api/users/me/couplets/bookmarked?page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get user's bookmarked couplets. Similar to liked couplets but for bookmarks.

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size  
- `sortBy` (optional, default: `createdAt`): Sort field
- `sortDir` (optional, default: `desc`): Sort direction

**Success Response (200):**
Same structure as liked couplets

---

### 6.5 Analytics & Discovery

#### 6.5.1 Most Liked Couplets {#651-most-liked-couplets}

**Endpoint:** `GET /api/analytics/couplets/most-liked?poetId={optional}&page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get most liked couplets globally or filtered by poet. Useful for discovery and "Popular Couplets" sections.

**Query Parameters:**
- `poetId` (optional): Filter by poet's public ID
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Example:** 
- Global: `GET /api/analytics/couplets/most-liked`
- By Poet: `GET /api/analytics/couplets/most-liked?poetId=poet_ghalib123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Most liked couplets retrieved",
  "data": {
    "content": [
      {
        "couplet": {
          "publicId": "couplet_xyz999",
          "coupletNumber": 5,
          "verses": [
            {
              "verseText": "ہزاروں خواہشیں ایسی کہ ہر خواہش پہ دم نکلے",
              "verseNumber": 9
            },
            {
              "verseText": "بہت نکلے مرے ارمان لیکن پھر بھی کم نکلے",
              "verseNumber": 10
            }
          ],
          "likeCount": 1234,
          "bookmarkCount": 567,
          "shareCount": 234
        },
        "poem": {
          "publicId": "poem_abc123",
          "title": "نقش فریادی"
        },
        "poet": {
          "publicId": "poet_ghalib123",
          "name": "Mirza Ghalib"
        },
        "ranking": 1
      }
    ],
    "totalElements": 100,
    "totalPages": 5
  }
}
```

**Use Case:** "Most Loved Couplets" section on home page

---

#### 6.5.2 Most Shared Couplets {#652-most-shared-couplets}

**Endpoint:** `GET /api/analytics/couplets/most-shared?poetId={optional}&page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get most shared couplets globally or by poet. Indicates viral/popular couplets.

**Query Parameters:**
Same as most liked couplets

**Success Response (200):**
Same structure as most liked couplets, sorted by `shareCount`

---

#### 6.5.3 Trending Couplets {#653-trending-couplets}

**Endpoint:** `GET /api/analytics/couplets/trending?days=7&page=0&size=20`

**Authentication Required:** Yes

**Description:**
Get couplets that are trending based on recent engagement (likes + shares + bookmarks) in the specified time window.

**Query Parameters:**
- `days` (optional, default: 7): Number of days for trend calculation (7, 14, 30)
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size

**Example:** `GET /api/analytics/couplets/trending?days=7`

**Success Response (200):**
Same structure as most liked couplets, with additional `trendScore` field

**Use Case:** "Trending This Week" section

---

### 6.6 Use Cases & Workflows {#66-use-cases-workflows}

**1. Display Poem with Couplets:**
```
GET /api/poems/{poemId}/couplets?lang=ur
→ Display each couplet with like/bookmark buttons
→ User can engage with individual couplets
```

**2. Like a Couplet:**
```
User taps ❤️ button
→ POST /api/couplets/{coupletId}/like
→ Update UI with new like count and status
→ Show animation feedback
```

**3. Share Couplet to WhatsApp:**
```
User taps Share → WhatsApp
→ POST /api/couplets/{coupletId}/share (shareType: WHATSAPP)
→ Get shareText and shareUrl
→ Open WhatsApp with pre-filled text
```

**4. View User's Favorite Couplets:**
```
Navigate to "My Favorites" tab
→ GET /api/users/me/couplets/liked
→ Display paginated list with infinite scroll
→ Show poem/poet context for each couplet
```

**5. Discover Popular Couplets:**
```
Home screen "Most Loved" section
→ GET /api/analytics/couplets/most-liked?size=10
→ Display top 10 most liked couplets
→ User can tap to view poem context
```

**Complete Example - Couplet Card Widget:**
```dart
class CoupletCard extends StatefulWidget {
  final Couplet couplet;
  final Poet poet;
  final Poem poem;
  
  @override
  _CoupletCardState createState() => _CoupletCardState();
}

class _CoupletCardState extends State<CoupletCard> {
  late bool isLiked;
  late bool isBookmarked;
  late int likeCount;
  
  @override
  void initState() {
    super.initState();
    isLiked = widget.couplet.userStatus?.isLiked ?? false;
    isBookmarked = widget.couplet.userStatus?.isBookmarked ?? false;
    likeCount = widget.couplet.likeCount;
  }
  
  Future<void> _toggleLike() async {
    final updated = await apiService.toggleLikeCouplet(widget.couplet.publicId);
    setState(() {
      isLiked = updated.userStatus.isLiked;
      likeCount = updated.couplet.likeCount;
    });
  }
  
  Future<void> _shareCouplet() async {
    final shareData = await apiService.shareCouplet(
      widget.couplet.publicId, 
      ShareType.WHATSAPP
    );
    
    await Share.share(shareData.shareText);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Couplet verses (RTL for Urdu)
            ...widget.couplet.verses.map((verse) => 
              Text(
                verse.verseText,
                textDirection: TextDirection.rtl,
                style: TextStyle(fontSize: 18, fontFamily: 'NotoNastaliq'),
              ),
            ),
            
            SizedBox(height: 12),
            
            // Poet and poem context
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(widget.poet.profileImageUrl),
                  radius: 12,
                ),
                SizedBox(width: 8),
                Text(
                  '${widget.poet.name} - ${widget.poem.title}',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            // Action buttons
            Row(
              children: [
                // Like button
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$likeCount'),
                
                SizedBox(width: 16),
                
                // Bookmark button
                IconButton(
                  icon: Icon(
                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isBookmarked ? Colors.blue : Colors.grey,
                  ),
                  onPressed: () async {
                    final updated = await apiService.toggleBookmarkCouplet(
                      widget.couplet.publicId
                    );
                    setState(() {
                      isBookmarked = updated.userStatus.isBookmarked;
                    });
                  },
                ),
                
                SizedBox(width: 16),
                
                // Share button
                IconButton(
                  icon: Icon(Icons.share, color: Colors.grey),
                  onPressed: _shareCouplet,
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

**Notes:**
- Couplets are automatically created for Ghazals during poem creation/update
- Each couplet has its own engagement counters (likes, bookmarks, shares)
- Sharing creates deep links that work in web and mobile app
- Analytics endpoints are useful for discovery features
- All engagement actions create activity records for personalization

---


## 7. Image Poetry Generation

### 7.1 Overview

Create beautiful poetry images from couplets using pre-designed templates or custom backgrounds.

**Base Path:** `/api/image-templates`, `/api/couplets/{coupletId}/generate-image`

---

### 7.2 Browse Templates

**Endpoint:** `GET /api/image-templates?page=0&size=20`

Get available templates for image generation.

**Success Response:**
```json
{
  "success": true,
  "data": {
    "content": [{
      "publicId": "tmpl_abc123",
      "name": "Floral Elegance",
      "thumbnailUrl": "https://cdn.poetry.com/templates/thumbs/floral-001.jpg",
      "isPremium": false
    }]
  }
}
```

---

### 7.3 Generate Image

**Endpoint:** `POST /api/couplets/{coupletId}/generate-image`

Generate poetry image with template or custom background.

**Request (Template):**
```json
{
  "generationType": "SYSTEM",
  "templateId": "tmpl_abc123",
  "languageCode": "ur"
}
```

**Request (Custom):**
```json
{
  "generationType": "CUSTOM",
  "customBackgroundUrl": "https://s3.../user-bg.jpg",
  "languageCode": "ur"
}
```

**Success Response:**
```json
{
  "success": true,
  "data": {
    "publicId": "img_xyz789",
    "imageUrl": "https://cdn.poetry.com/generated/img_xyz789.jpg",
    "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_xyz789.jpg"
  }
}
```

---

### 7.4 Upload Custom Background

**Endpoint:** `POST /api/users/me/upload-background`

Upload custom image (multipart/form-data, max 5MB).

---

### 7.5 User Collections & Bookmarks

This section covers both traditional collections (save/favorite) and the new bookmark system for generated poetry images.

---

#### 7.5.1 Save Image to Collection

**Endpoint:** `POST /api/poetry-images/{imageId}/save`

**Authentication Required:** Yes

**Description:** Save a generated poetry image to user's collection with optional collection name and favorite flag.

**Path Parameters:**
- `imageId` (required): Public ID of the generated image

**Request Body:**
```json
{
  "collectionName": "My Favorites",
  "isFavorite": true
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image saved to collection"
}
```

---

#### 7.5.2 Get Saved Images

**Endpoint:** `GET /api/users/me/saved-images?page=0&size=20&collectionName=My%20Favorites&favoritesOnly=true`

**Authentication Required:** Yes

**Description:** Retrieve user's saved images with optional filtering by collection name or favorites.

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size
- `collectionName` (optional): Filter by specific collection name
- `favoritesOnly` (optional): If true, only return favorite images

**Success Response (200):**
```json
{
  "success": true,
  "message": "Saved images retrieved",
  "data": {
    "content": [{
      "publicId": "img_xyz789",
      "imageUrl": "https://cdn.poetry.com/generated/img_xyz789.jpg",
      "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_xyz789.jpg",
      "createdAt": "2024-01-15T10:30:00Z"
    }],
    "totalElements": 45,
    "totalPages": 3
  }
}
```

---

#### 7.5.3 Toggle Favorite

**Endpoint:** `POST /api/poetry-images/{imageId}/toggle-favorite`

**Authentication Required:** Yes

**Description:** Toggle favorite status on a saved image.

**Path Parameters:**
- `imageId` (required): Public ID of the generated image

**Success Response (200):**
```json
{
  "success": true,
  "message": "Favorite toggled",
  "data": true
}
```

---

#### 7.5.4 Remove from Collection

**Endpoint:** `DELETE /api/users/me/saved-images/{imageId}`

**Authentication Required:** Yes

**Description:** Remove a saved image from user's collection.

**Path Parameters:**
- `imageId` (required): Public ID of the generated image

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image removed from collection"
}
```

---

#### 7.5.5 Get Collection Names

**Endpoint:** `GET /api/users/me/collection-names`

**Authentication Required:** Yes

**Description:** Get list of all collection names created by the user.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Collection names retrieved",
  "data": [
    "My Favorites",
    "Ghalib Special",
    "Love Poetry"
  ]
}
```

---

#### 7.5.6 Get Collection Statistics

**Endpoint:** `GET /api/users/me/collection-stats`

**Authentication Required:** Yes

**Description:** Get statistics about user's image collections.

**Success Response (200):**
```json
{
  "success": true,
  "message": "Stats retrieved",
  "data": {
    "totalImages": 45,
    "favoriteCount": 12,
    "collectionCount": 3,
    "collectionNames": [
      "My Favorites",
      "Ghalib Special",
      "Love Poetry"
    ]
  }
}
```

---

#### 7.5.7 Toggle Image Bookmark (NEW)

**Endpoint:** `POST /api/poetry-images/{imageId}/bookmark?lang=ur`

**Authentication Required:** Yes

**Description:**
Bookmark or unbookmark a generated poetry image (toggles). Similar to poem and couplet bookmarks, this preserves the language context in which the user bookmarked the image. This is separate from the collection/favorite system and is used for quick access to bookmarked images.

**Path Parameters:**
- `imageId` (required): Public ID of the generated poetry image

**Query Parameters:**
- `lang` (optional, default: "ur"): Language code when bookmarking (ur, en, hi, etc.). This is stored with the bookmark so the image can be displayed with the correct language context later.

**Example:** `POST /api/poetry-images/img_xyz789/bookmark?lang=ur`

**Success Response (200) - Bookmarked:**
```json
{
  "success": true,
  "message": "Image bookmarked successfully",
  "data": true
}
```

**Success Response (200) - Unbookmarked:**
```json
{
  "success": true,
  "message": "Bookmark removed successfully",
  "data": false
}
```

**Note:** Creates engagement activity record for personalization and analytics.

---

#### 7.5.8 Get Bookmarked Images (NEW)

**Endpoint:** `GET /api/users/me/image-bookmarks?page=0&size=20&lang=ur`

**Authentication Required:** Yes

**Description:**
Retrieve user's bookmarked images with optional language filtering. Bookmarks are returned in their original bookmarked language to preserve context.

**Query Parameters:**
- `page` (optional, default: 0): Page number
- `size` (optional, default: 20): Page size
- `lang` (optional): Filter bookmarks by language code. If omitted, returns all bookmarked images regardless of language.

**Example:** `GET /api/users/me/image-bookmarks?page=0&size=20&lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmarked images retrieved successfully",
  "data": {
    "content": [{
      "publicId": "img_xyz789",
      "imageUrl": "https://cdn.poetry.com/generated/img_xyz789.jpg",
      "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_xyz789.jpg",
      "bookmarkedAt": "2024-01-15T10:30:00Z",
      "languageCode": "ur"
    }],
    "totalElements": 25,
    "totalPages": 2
  }
}
```

**Usage Notes:**
- Mixed language bookmarks: If a user has bookmarked images in multiple languages (Urdu, English, Hindi), omitting the `lang` parameter returns all bookmarks, each displaying in its original bookmarked language.
- Language filtering: Use `lang=ur` to see only Urdu bookmarks, `lang=en` for English, etc.
- This is separate from the collection system - an image can be both bookmarked AND saved to a collection.

---

#### 7.5.9 Check Image Bookmark Status (NEW)

**Endpoint:** `GET /api/poetry-images/{imageId}/is-bookmarked`

**Authentication Required:** Optional (returns false if not authenticated)

**Description:**
Check if a specific image is bookmarked by the current user. Useful for displaying bookmark button state in the UI.

**Path Parameters:**
- `imageId` (required): Public ID of the generated poetry image

**Example:** `GET /api/poetry-images/img_xyz789/is-bookmarked`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmark status",
  "data": true
}
```

**Note:** If user is not authenticated, returns `false` instead of 401 error.

---

## 8. Book Management

### 8.1 Search Books

**Endpoint:** `GET /api/books/search?query=diwan&page=0&size=20`

Search poetry books across all poets.

**Success Response:**
```json
{
  "success": true,
  "data": {
    "content": [{
      "publicId": "book_abc123",
      "title": "Diwan-e-Ghalib",
      "poet": {"name": "Mirza Ghalib"},
      "downloadCount": 1234,
      "hasPdf": true,
      "hasEpub": false
    }]
  }
}
```

---

### 8.2 Download Book

**Endpoint:** `GET /api/poets/{poetId}/books/{bookId}/download?fileType=PDF`

Download book file (tracks download count).

**File Types:** `PDF`, `EPUB`, `EXTERNAL`

Returns CloudFront URL or redirects to external link.

---

## 8.5 Unified Bookmark API (Phase 3) ⭐ NEW

### 8.5.1 Overview - Unified Bookmarks

The Unified Bookmark API provides a single, consolidated interface for accessing bookmarks across all content types (poems, couplets, generated images). Instead of calling separate endpoints for each type, you can now fetch all bookmarks in one call.

**Key Benefits:**
- **Single Interface**: One API for all bookmark types
- **Mixed Content Feed**: See all bookmarked content together, sorted by recency
- **Type Filtering**: Easily filter by specific content type when needed
- **Cross-Content Search**: Search across all bookmarks with one query
- **Comprehensive Stats**: Get aggregated statistics across all bookmark types

**Base Path:** `/api/bookmarks`

**All Endpoints Require Authentication**

---

### 8.5.2 Get Recent Bookmarks

**Endpoint:** `GET /api/bookmarks/recent?page=0&size=20&lang=ur`

**Description:**
Get recent bookmarks across ALL content types (poems, couplets, images) in a single mixed feed, sorted by most recently bookmarked.

**Query Parameters:**
- `page` (optional, default: 0) - Page number
- `size` (optional, default: 20) - Page size
- `lang` (optional) - Filter by language code (ur, en, hi). If omitted, returns bookmarks in all languages.

**Authentication:** Required (Bearer token)

**Example:** `GET /api/bookmarks/recent?page=0&size=20`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Recent bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "COUPLET",
        "bookmarkId": "bkmk_abc123",
        "contentId": "couplet_xyz789",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T14:30:00Z",
        "notes": null,
        "coupletFirstVerse": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
        "coupletSecondVerse": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
        "parentPoemTitle": "دیوان غالب",
        "parentPoemId": "poem_abc123",
        "poetName": "Mirza Ghalib",
        "poetId": "poet_ghalib",
        "likeCount": 145,
        "bookmarkCount": 89,
        "shareCount": 34
      },
      {
        "type": "POEM",
        "bookmarkId": "bkmk_def456",
        "contentId": "poem_pqr567",
        "languageCode": "en",
        "bookmarkedAt": "2026-01-01T12:15:00Z",
        "notes": null,
        "poemTitle": "Shikwa",
        "poetName": "Allama Iqbal",
        "poetId": "poet_iqbal",
        "likeCount": 892,
        "bookmarkCount": null,
        "shareCount": 234
      },
      {
        "type": "IMAGE",
        "bookmarkId": "bkmk_ghi789",
        "contentId": "img_uvw890",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T10:00:00Z",
        "notes": null,
        "imageUrl": "https://cdn.poetry.com/generated/img_uvw890.jpg",
        "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_uvw890.jpg",
        "templateName": "Floral Elegance",
        "bookmarkCount": 23
      }
    ],
    "totalElements": 45,
    "totalPages": 3,
    "number": 0,
    "size": 20
  }
}
```

**Use Case:**
Display a unified bookmark screen showing all types of bookmarked content in chronological order.

---

### 8.5.3 Get Poem Bookmarks

**Endpoint:** `GET /api/bookmarks/poems?page=0&size=20&lang=ur`

**Description:**
Get ONLY poem bookmarks (filtered view). Useful for dedicated poem bookmark screens.

**Query Parameters:**
- `page` (optional, default: 0) - Page number
- `size` (optional, default: 20) - Page size
- `lang` (optional) - Filter by language code

**Authentication:** Required

**Example:** `GET /api/bookmarks/poems?lang=ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Poem bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "POEM",
        "bookmarkId": "bkmk_def456",
        "contentId": "poem_pqr567",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T12:15:00Z",
        "poemTitle": "شکوہ",
        "poetName": "Allama Iqbal",
        "poetId": "poet_iqbal",
        "likeCount": 892,
        "bookmarkCount": null,
        "shareCount": 234
      }
    ],
    "totalElements": 15,
    "totalPages": 1
  }
}
```

---

### 8.5.4 Get Couplet Bookmarks

**Endpoint:** `GET /api/bookmarks/couplets?page=0&size=20&lang=ur`

**Description:**
Get ONLY couplet bookmarks (filtered view). Useful for dedicated couplet bookmark screens.

**Query Parameters:**
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `lang` (optional) - Filter by language code

**Authentication:** Required

**Success Response (200):**
```json
{
  "success": true,
  "message": "Couplet bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "COUPLET",
        "bookmarkId": "bkmk_abc123",
        "contentId": "couplet_xyz789",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T14:30:00Z",
        "coupletFirstVerse": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
        "coupletSecondVerse": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
        "parentPoemTitle": "دیوان غالب",
        "parentPoemId": "poem_abc123",
        "poetName": "Mirza Ghalib",
        "poetId": "poet_ghalib",
        "likeCount": 145,
        "bookmarkCount": 89,
        "shareCount": 34
      }
    ],
    "totalElements": 20,
    "totalPages": 1
  }
}
```

---

### 8.5.5 Get Image Bookmarks

**Endpoint:** `GET /api/bookmarks/images?page=0&size=20&lang=ur`

**Description:**
Get ONLY generated poetry image bookmarks (filtered view).

**Query Parameters:**
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `lang` (optional) - Filter by language code

**Authentication:** Required

**Success Response (200):**
```json
{
  "success": true,
  "message": "Image bookmarks retrieved successfully",
  "data": {
    "content": [
      {
        "type": "IMAGE",
        "bookmarkId": "bkmk_ghi789",
        "contentId": "img_uvw890",
        "languageCode": "ur",
        "bookmarkedAt": "2026-01-01T10:00:00Z",
        "imageUrl": "https://cdn.poetry.com/generated/img_uvw890.jpg",
        "thumbnailUrl": "https://cdn.poetry.com/generated/thumbs/img_uvw890.jpg",
        "templateName": "Floral Elegance",
        "bookmarkCount": 23
      }
    ],
    "totalElements": 10,
    "totalPages": 1
  }
}
```

---

### 8.5.6 Search Bookmarks

**Endpoint:** `GET /api/bookmarks/search?query=محبت&page=0&size=20&lang=ur`

**Description:**
Search across ALL bookmarked content (poems, couplets, images) with a single query. Searches in:
- Poem titles and poet names
- Couplet verse text and parent poem titles
- Image template names and notes

**Query Parameters:**
- `query` (required) - Search term (minimum 2 characters)
- `page` (optional, default: 0)
- `size` (optional, default: 20)
- `lang` (optional) - Filter results by language code

**Authentication:** Required

**Example:** `GET /api/bookmarks/search?query=دل&page=0`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Found 8 bookmarks matching 'دل'",
  "data": {
    "content": [
      {
        "type": "COUPLET",
        "coupletFirstVerse": "دل کو تو آرام ہے فریاد کا موقع ہے",
        "coupletSecondVerse": "یہ دونوں باتیں تھیں اب کچھ کہنے کو باقی ہے",
        "parentPoemTitle": "دیوان غالب",
        "poetName": "Mirza Ghalib",
        "bookmarkedAt": "2026-01-01T14:30:00Z"
      },
      {
        "type": "POEM",
        "poemTitle": "دل کی ویرانی کا کیا مذکور ہے",
        "poetName": "Mir Taqi Mir",
        "bookmarkedAt": "2026-01-01T12:00:00Z"
      }
    ],
    "totalElements": 8,
    "totalPages": 1
  }
}
```

**Error Response (400) - Query too short:**
```json
{
  "success": false,
  "message": "Search query must be at least 2 characters"
}
```

---

### 8.5.7 Get Bookmark Statistics

**Endpoint:** `GET /api/bookmarks/stats`

**Description:**
Get comprehensive statistics about user's bookmarks across all types.

**Authentication:** Required

**Example:** `GET /api/bookmarks/stats`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bookmark statistics retrieved successfully",
  "data": {
    "totalBookmarks": 45,
    "poemBookmarks": 15,
    "coupletBookmarks": 20,
    "imageBookmarks": 10,
    "bookmarksByLanguage": {
      "ur": 30,
      "en": 12,
      "hi": 3
    },
    "topPoets": [
      {
        "poetId": "poet_ghalib",
        "poetName": "Mirza Ghalib",
        "bookmarkCount": 18
      },
      {
        "poetId": "poet_iqbal",
        "poetName": "Allama Iqbal",
        "bookmarkCount": 12
      },
      {
        "poetId": "poet_faiz",
        "poetName": "Faiz Ahmed Faiz",
        "bookmarkCount": 8
      }
    ],
    "recentBookmarks": 7
  }
}
```

**Response Fields:**
- `totalBookmarks` - Total count across all types
- `poemBookmarks` - Count of poem bookmarks
- `coupletBookmarks` - Count of couplet bookmarks
- `imageBookmarks` - Count of image bookmarks
- `bookmarksByLanguage` - Breakdown by language code
- `topPoets` - Top 5 poets by bookmark count (poems + couplets combined)
- `recentBookmarks` - Bookmarks added in last 7 days

---

### 8.5.8 Response Format

**Unified Bookmark Response Structure:**

All endpoints return bookmarks with the following structure:

```json
{
  "type": "POEM | COUPLET | IMAGE",
  "bookmarkId": "string",
  "contentId": "string",
  "languageCode": "string",
  "bookmarkedAt": "ISO 8601 timestamp",
  "notes": "string (optional)",

  // Type-specific fields (only present for relevant type)

  // POEM fields:
  "poemTitle": "string",
  "poetName": "string",
  "poetId": "string",

  // COUPLET fields:
  "coupletFirstVerse": "string",
  "coupletSecondVerse": "string",
  "parentPoemTitle": "string",
  "parentPoemId": "string",
  "poetName": "string",
  "poetId": "string",

  // IMAGE fields:
  "imageUrl": "string",
  "thumbnailUrl": "string",
  "templateName": "string",

  // Common engagement metrics
  "likeCount": integer,
  "bookmarkCount": integer (nullable),
  "shareCount": integer
}
```

**Type-Specific Rendering:**

Use the `type` field to determine how to render each bookmark:

```dart
switch (bookmark.type) {
  case 'POEM':
    return PoemBookmarkCard(
      title: bookmark.poemTitle,
      poet: bookmark.poetName,
      // ...
    );
  case 'COUPLET':
    return CoupletBookmarkCard(
      verse1: bookmark.coupletFirstVerse,
      verse2: bookmark.coupletSecondVerse,
      // ...
    );
  case 'IMAGE':
    return ImageBookmarkCard(
      imageUrl: bookmark.imageUrl,
      thumbnail: bookmark.thumbnailUrl,
      // ...
    );
}
```

---

### 8.5.9 Use Cases & Examples

#### Use Case 1: Unified Bookmark Screen

Show all bookmarks in one feed (Instagram/Twitter style):

```dart
// Fetch mixed feed
final response = await http.get(
  '/api/bookmarks/recent?page=0&size=20'
);

// Render different card types based on bookmark.type
ListView.builder(
  itemBuilder: (context, index) {
    final bookmark = bookmarks[index];
    switch (bookmark.type) {
      case 'POEM':
        return PoemBookmarkCard(bookmark);
      case 'COUPLET':
        return CoupletBookmarkCard(bookmark);
      case 'IMAGE':
        return ImageBookmarkCard(bookmark);
    }
  }
)
```

#### Use Case 2: Dedicated Bookmark Tabs

Create tabbed interface with dedicated screens per type:

```
Bookmarks Screen
├── Tab 1: All (mixed feed) → /api/bookmarks/recent
├── Tab 2: Poems → /api/bookmarks/poems
├── Tab 3: Couplets → /api/bookmarks/couplets
└── Tab 4: Images → /api/bookmarks/images
```

#### Use Case 3: Language-Specific Bookmark Screen

Show only Urdu bookmarks:

```dart
final response = await http.get(
  '/api/bookmarks/recent?lang=ur'
);
```

Show only English bookmarks:

```dart
final response = await http.get(
  '/api/bookmarks/recent?lang=en'
);
```

#### Use Case 4: Search Across All Bookmarks

Implement global bookmark search:

```dart
final response = await http.get(
  '/api/bookmarks/search?query=${searchQuery}'
);

// Results include poems, couplets, and images that match
// Highlight matching terms in UI
```

#### Use Case 5: Bookmark Dashboard with Stats

Show user their bookmark statistics:

```dart
final stats = await http.get('/api/bookmarks/stats');

// Display:
// - Total bookmark count
// - Breakdown by type (pie chart)
// - Breakdown by language (bar chart)
// - Top poets (list)
// - Recent activity (last 7 days)
```

---

**Comparison: Legacy vs Unified API**

| Feature | Legacy Approach | Unified API (Phase 3) |
|---------|----------------|----------------------|
| Get all bookmarks | 3 API calls | 1 API call |
| Search bookmarks | 3 separate searches | 1 unified search |
| Mixed content feed | Manual merging | Built-in |
| Statistics | Calculate client-side | Server-provided |
| Code complexity | High (multiple endpoints) | Low (single interface) |

---

## 9. Comments

### 9.1 Create Comment

**Endpoint:** `POST /api/poems/{poemId}/comments`

```json
{
  "commentText": "Beautiful ghazal!",
  "parentCommentPublicId": null
}
```

---

### 9.2 Get Comments

**Endpoint:** `GET /api/poems/{poemId}/comments?page=0&size=10`

Returns threaded comments with replies.

---

### 9.3 Delete Comment

**Endpoint:** `DELETE /api/poems/{poemId}/comments/{commentId}`

Soft delete (shows as "[deleted]").

---

### 9.4 Get Comment Count

**Endpoint:** `GET /api/poems/{poemId}/comments/count`

---

## 10. Global Search

### 10.1 Unified Search

**Endpoint:** `GET /api/search?q=محبت&type=all&lang=ur&page=0`

Search across poems, verses, poets, categories.

**Types:** `all`, `poems`, `verses`, `poets`, `categories`

---

### 10.2 Quick Search

**Endpoint:** `GET /api/search/quick?q=دل&lang=ur`

Simplified search (all types, default pagination).

---

### 10.4 Couplet Search

**Endpoint:** `GET /api/search/couplets`

**Description:** Search specifically for couplets (شعر/اشعار) with advanced filtering and sorting options. Supports multilingual search across Urdu (Arabic/Roman), English, and Hindi.

**Query Parameters:**
- `q` (required) - Search query text
- `poet` (optional) - Filter by poet public ID
- `sort` (optional, default: `relevance`) - Sort order
  - `relevance` - Best match based on BM25 scoring
  - `likes` - Most liked couplets
  - `shares` - Most shared couplets
  - `bookmarks` - Most bookmarked couplets
  - `trending` - Highest engagement score
- `lang` (optional, default: `ur`) - Language code (ur, en, hi)
- `page` (optional, default: `0`) - Page number (zero-indexed)
- `size` (optional, default: `10`) - Results per page

**Example Request:**
```http
GET /api/search/couplets?q=محبت&poet=mirza-ghalib&sort=likes&lang=ur&page=0&size=10
```

**Response Format:**
```json
{
  "success": true,
  "message": "Couplets retrieved successfully",
  "data": {
    "content": [
      {
        "publicId": "abc123",
        "coupletNumber": 3,
        "coupletType": "MISRA",
        "verses": [
          {
            "verseText": "محبت میں نہیں ہے فرق جینے اور مرنے کا",
            "verseNumber": 1,
            "languageCode": "ur"
          },
          {
            "verseText": "اسی کو دیکھ کر جیتے ہیں جس کافر پہ دم نکلے",
            "verseNumber": 2,
            "languageCode": "ur"
          }
        ],
        "poem": {
          "publicId": "poem123",
          "title": "غزل نمبر ۱",
          "poetName": "مرزا غالب"
        },
        "poet": {
          "publicId": "mirza-ghalib",
          "name": "مرزا غالب",
          "profileImageUrl": "https://cdn.example.com/poets/ghalib.jpg"
        },
        "likeCount": 245,
        "shareCount": 89,
        "bookmarkCount": 156,
        "engagementScore": 623.5,
        "isLiked": false,
        "isBookmarked": true
      }
    ],
    "totalElements": 45,
    "totalPages": 5,
    "pageNumber": 0,
    "pageSize": 10,
    "last": false,
    "first": true
  }
}
```

**Engagement Score Calculation:**
`engagementScore = (likes × 1.0) + (shares × 2.0) + (bookmarks × 1.5)`

**Search Features:**
- **Multilingual:** Automatically detects script (Arabic, Roman, Devanagari)
- **Fuzzy Matching:** Handles typos and variations (AUTO fuzziness)
- **Field Boosting:** Verse text gets higher relevance boost
- **Hybrid Fallback:** Automatically falls back to PostgreSQL if Elasticsearch unavailable

**Use Cases:**
1. **Trending Couplets:** `?sort=trending&size=20`
2. **Poet's Popular Couplets:** `?poet=faiz-ahmed-faiz&sort=likes`
3. **Search by Theme:** `?q=عشق&sort=relevance`
4. **Most Bookmarked:** `?sort=bookmarks&page=0`

---

### 10.5 Autocomplete

**Endpoint:** `GET /api/search/autocomplete`

**Description:** Real-time search suggestions across multiple content types (poets, poems, tags, categories). Designed for instant search-as-you-type experiences with minimal latency (<200ms).

**Query Parameters:**
- `q` (required) - Search query (minimum 2 characters)
- `lang` (optional, default: `ur`) - Language code

**Example Request:**
```http
GET /api/search/autocomplete?q=غا&lang=ur
```

**Response Format:**
```json
{
  "success": true,
  "message": "Autocomplete suggestions retrieved",
  "data": {
    "poets": [
      {
        "publicId": "mirza-ghalib",
        "name": "مرزا غالب",
        "profileImageUrl": "https://cdn.example.com/poets/ghalib.jpg",
        "era": "CLASSICAL",
        "score": 9.5
      },
      {
        "publicId": "ghalib-lakhnavi",
        "name": "غالب لکھنوی",
        "profileImageUrl": "https://cdn.example.com/poets/lakhnavi.jpg",
        "era": "MODERN",
        "score": 7.2
      }
    ],
    "poems": [
      {
        "publicId": "poem456",
        "title": "غزل نمبر ۵",
        "poetName": "مرزا غالب",
        "poemType": "GHAZAL",
        "score": 8.3
      },
      {
        "publicId": "poem789",
        "title": "دیوان غالب",
        "poetName": "مرزا غالب",
        "poemType": "GHAZAL",
        "score": 7.8
      }
    ],
    "tags": [
      {
        "publicId": "tag123",
        "name": "غزل",
        "slug": "ghazal",
        "tagType": "POEM_GENRE",
        "score": 9.0
      }
    ],
    "categories": [
      {
        "publicId": "cat456",
        "name": "غزلیات",
        "slug": "ghazliyat",
        "poemCount": 1250,
        "score": 8.5
      }
    ],
    "totalCount": 8
  }
}
```

**Result Limits:**
- Poets: 3 results
- Poems: 5 results
- Tags: 3 results
- Categories: 3 results
- **Total:** Maximum 14 suggestions per query

**Technical Features:**
- **Edge N-gram Tokenizer:** min_gram: 2, max_gram: 15
- **Prefix Matching:** Optimized for partial word matching
- **Relevance Scoring:** Higher scores for exact prefix matches
- **Caching:** Redis cache (TTL: 5 minutes)

**Flutter Implementation Example:**
```dart
// Debounce search input (300-500ms)
Timer? _debounce;

void onSearchChanged(String query) {
  if (_debounce?.isActive ?? false) _debounce!.cancel();

  _debounce = Timer(const Duration(milliseconds: 300), () {
    if (query.length >= 2) {
      _searchService.getAutocompleteSuggestions(query);
    }
  });
}
```

**UI Rendering:**
- Display results grouped by type (Poets, Poems, Tags, Categories)
- Show avatar/icon for each type
- Highlight matching text
- Handle navigation to appropriate detail screen on tap

---

### 10.6 Recommendations

**Endpoint:** `GET /api/search/recommendations`

**Description:** Intelligent content recommendations using multiple strategies: personalized based on user behavior, similar content using More Like This, trending content, and hybrid approaches.

**Query Parameters:**
- `type` (optional, default: `hybrid`) - Recommendation type
  - `personalized` - Based on user's bookmarks and likes
  - `similar` - Similar to currently viewing content
  - `trending` - Popular content in timeframe
  - `hybrid` - Combined strategies (40% personalized + 60% trending)
- `contentType` (required for `similar` type) - POEM or COUPLET
- `contentId` (required for `similar` type) - Public ID of content
- `timeframe` (optional for `trending`, default: `week`) - day, week, month
- `limit` (optional, default: `10`) - Number of recommendations

**Header:**
- `X-User-Id` (optional) - User ID for personalized recommendations

**Example Requests:**

**1. Personalized Recommendations:**
```http
GET /api/search/recommendations?type=personalized&limit=10
Header: X-User-Id: 12345
```

**2. Similar Content:**
```http
GET /api/search/recommendations?type=similar&contentType=POEM&contentId=poem-xyz&limit=10
```

**3. Trending Content:**
```http
GET /api/search/recommendations?type=trending&contentType=COUPLET&timeframe=week&limit=20
```

**4. Hybrid (Default):**
```http
GET /api/search/recommendations?type=hybrid&limit=10
Header: X-User-Id: 12345
```

**Response Format:**
```json
{
  "success": true,
  "message": "Recommendations retrieved",
  "data": {
    "type": "PERSONALIZED",
    "items": [
      {
        "contentType": "POEM",
        "publicId": "poem-abc",
        "title": "شکوہ",
        "poetName": "علامہ اقبال",
        "likeCount": 1250,
        "shareCount": 340,
        "bookmarkCount": 890,
        "score": 87.5,
        "reason": "Based on your bookmarks of Allama Iqbal's works"
      },
      {
        "contentType": "COUPLET",
        "publicId": "couplet-def",
        "title": "Couplet from دیوان غالب",
        "poetName": "مرزا غالب",
        "likeCount": 2100,
        "shareCount": 560,
        "bookmarkCount": 1340,
        "score": 92.3,
        "reason": "Similar to poems you've liked"
      }
    ],
    "totalCount": 10,
    "algorithm": "personalized_mlm"
  }
}
```

**Recommendation Strategies:**

**1. Personalized (personalized):**
- Analyzes user's bookmarks, likes, and reading history
- Uses Elasticsearch More Like This query
- Finds content similar to user's preferences
- **Reason:** "Based on your bookmarks", "Similar to poems you've liked"

**2. Similar Content (similar):**
- Uses More Like This query on specific content
- Parameters: `minTermFreq: 1`, `maxQueryTerms: 12`
- Matches: title, full text, poet, tags
- **Reason:** "Similar to what you're reading"

**3. Trending (trending):**
- High engagement in specified timeframe
- Sorts by: `likeCount`, `viewCount`, `engagementScore`
- Timeframes: day (24h), week (7d), month (30d)
- **Reason:** "Trending this week", "Most popular today"

**4. Hybrid (hybrid):**
- 40% personalized + 30% trending + 30% more trending
- Removes duplicates by publicId
- Falls back to trending for anonymous users
- **Reason:** "Curated for you", "Popular in your interests"

**Use Cases:**

**For Home Feed:**
```http
GET /api/search/recommendations?type=hybrid&limit=20
Header: X-User-Id: 12345
```

**For Poem Detail Screen (Similar Poems):**
```http
GET /api/search/recommendations?type=similar&contentType=POEM&contentId=current-poem-id&limit=5
```

**For Discover Tab:**
```http
GET /api/search/recommendations?type=trending&timeframe=week&limit=30
```

**For Personalized Section:**
```http
GET /api/search/recommendations?type=personalized&limit=15
Header: X-User-Id: 12345
```

**Flutter Implementation:**
```dart
// Home feed with mixed recommendations
Future<List<RecommendedItem>> loadHomeFeed() async {
  final response = await dio.get(
    '/api/search/recommendations',
    queryParameters: {'type': 'hybrid', 'limit': 20},
    options: Options(headers: {'X-User-Id': userId}),
  );
  return parseRecommendations(response.data);
}

// Similar poems carousel
Future<List<RecommendedItem>> loadSimilarPoems(String poemId) async {
  final response = await dio.get(
    '/api/search/recommendations',
    queryParameters: {
      'type': 'similar',
      'contentType': 'POEM',
      'contentId': poemId,
      'limit': 5
    },
  );
  return parseRecommendations(response.data);
}
```

---

### 10.7 Search Analytics

Analytics endpoints for tracking search behavior and providing "People also searched" features.

#### 10.7.1 Related Searches

**Endpoint:** `GET /api/search/related`

**Description:** Returns related search queries based on session co-occurrence analysis. Shows what other users searched for in the same session (30-day window).

**Query Parameters:**
- `q` (required) - Original search query
- `limit` (optional, default: `5`) - Number of related searches

**Example Request:**
```http
GET /api/search/related?q=غالب&limit=5
```

**Response Format:**
```json
{
  "success": true,
  "message": "Related searches retrieved",
  "data": {
    "query": "غالب",
    "relatedSearches": [
      {
        "query": "مرزا غالب",
        "normalizedQuery": "مرزا غالب",
        "count": 234,
        "score": 95.5
      },
      {
        "query": "دیوان غالب",
        "normalizedQuery": "دیوان غالب",
        "count": 189,
        "score": 87.3
      },
      {
        "query": "غالب کی شاعری",
        "normalizedQuery": "غالب کی شاعری",
        "count": 156,
        "score": 78.5
      },
      {
        "query": "غزلیات غالب",
        "normalizedQuery": "غزلیات غالب",
        "count": 142,
        "score": 73.2
      },
      {
        "query": "میر تقی میر",
        "normalizedQuery": "میر تقی میر",
        "count": 98,
        "score": 62.8
      }
    ],
    "totalCount": 5,
    "timeWindow": "last 30 days"
  }
}
```

**Algorithm:**
1. Find all sessions containing the original query
2. Aggregate other queries from those sessions
3. Rank by co-occurrence frequency
4. Exclude the original query

**Score Calculation:**
`score = min(100, count × 10)` - Normalized to 0-100 range

**Use Cases:**

**People Also Searched UI:**
```dart
// Display as horizontal chip list below search results
Widget buildRelatedSearches(String query) {
  return FutureBuilder<RelatedSearchesResponse>(
    future: searchService.getRelatedSearches(query),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('People also searched:', style: TextStyle(fontSize: 14)),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: snapshot.data!.relatedSearches.map((search) {
              return ActionChip(
                label: Text(search.query),
                onPressed: () => performSearch(search.query),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
}
```

**Zero Results Suggestion:**
```http
GET /api/search?q=غالیب  # User typo - no results
GET /api/search/related?q=غالیب  # Suggests "غالب" (correct spelling)
```

---

#### 10.7.2 Trending Searches

**Endpoint:** `GET /api/search/trending`

**Description:** Returns most popular search queries within a specified timeframe, ranked by search frequency.

**Query Parameters:**
- `timeframe` (optional, default: `week`) - Time window
  - `day` - Last 24 hours
  - `week` - Last 7 days
  - `month` - Last 30 days
- `limit` (optional, default: `10`) - Number of trending searches

**Example Request:**
```http
GET /api/search/trending?timeframe=week&limit=10
```

**Response Format:**
```json
{
  "success": true,
  "message": "Trending searches retrieved",
  "data": {
    "searches": [
      {
        "query": "فیض احمد فیض",
        "normalizedQuery": "فیض احمد فیض",
        "count": 1245,
        "score": 100.0
      },
      {
        "query": "محبت",
        "normalizedQuery": "محبت",
        "count": 987,
        "score": 79.3
      },
      {
        "query": "غالب",
        "normalizedQuery": "غالب",
        "count": 892,
        "score": 71.6
      },
      {
        "query": "اقبال",
        "normalizedQuery": "اقبال",
        "count": 756,
        "score": 60.7
      },
      {
        "query": "غزل",
        "normalizedQuery": "غزل",
        "count": 634,
        "score": 50.9
      }
    ],
    "totalCount": 10,
    "timeframe": "week",
    "period": "last 7 days"
  }
}
```

**Score Calculation:**
`score = min(100, count × 5)` - Normalized to 0-100 range

**Use Cases:**

**1. Trending Searches Widget (Home Screen):**
```dart
Widget buildTrendingSearches() {
  return FutureBuilder<TrendingSearchesResponse>(
    future: searchService.getTrendingSearches('week'),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return CircularProgressIndicator();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trending This Week 🔥', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          ...snapshot.data!.searches.asMap().entries.map((entry) {
            int index = entry.key;
            var search = entry.value;
            return ListTile(
              leading: CircleAvatar(child: Text('${index + 1}')),
              title: Text(search.query),
              subtitle: Text('${search.count} searches'),
              trailing: Icon(Icons.trending_up),
              onTap: () => performSearch(search.query),
            );
          }).toList(),
        ],
      );
    },
  );
}
```

**2. Discovery Tab (Daily/Weekly/Monthly Tabs):**
```dart
TabBarView(
  children: [
    TrendingSearchList(timeframe: 'day'),
    TrendingSearchList(timeframe: 'week'),
    TrendingSearchList(timeframe: 'month'),
  ],
);
```

**3. Search Suggestions (Empty State):**
```http
# When search box is empty, show trending searches
GET /api/search/trending?timeframe=day&limit=5
```

**Implementation Notes:**
- All search queries are logged asynchronously (non-blocking)
- Session tracking uses client-generated session IDs
- Related searches use Elasticsearch terms aggregations
- Trending searches cached for 1 hour (Redis)

---

### 10.8 Use Cases & Workflows

### 11.1 Categories

**Get All:** `GET /api/categories`

**Get Root:** `GET /api/categories/root`

**By ID:** `GET /api/categories/{publicId}`

**By Slug:** `GET /api/categories/slug/{slug}`

**Get Children:** `GET /api/categories/{publicId}/children`

---

### 11.2 Tags

**Get All:** `GET /api/tags`

**By Type:** `GET /api/tags/type/{type}` (ERA, POET_CATEGORY, POEM_GENRE, etc.)

**By Slug:** `GET /api/tags/slug/{slug}`

**By ID:** `GET /api/tags/{publicId}`

---

### 11.3 Geography

**Countries:** `GET /api/geography/countries?lang=en`

**Cities:** `GET /api/geography/cities?lang=en&countryCode=PK`

**Cities by Country:** `GET /api/geography/countries/{countryCode}/cities?lang=en`

---

### 11.4 Languages

**Get All:** `GET /api/languages`

**By Code:** `GET /api/languages/{code}`

**Active Languages:** `GET /api/languages/active`

Supported: Urdu (ur), English (en), Hindi (hi), Arabic (ar), Persian (fa), Punjabi (pa)

---

## 12. System & Health

**Health Check:** `GET /api/health` (No auth required)

**Detailed:** `GET /api/health/detailed`

**Readiness:** `GET /api/health/ready`

**Liveness:** `GET /api/health/live`

---

## 13. Reference

### 13.1 Enum Values

**PoetryType:** GHAZAL, NAZM, RUBAI, QASIDA, MARSIYA, HAMD, NAAT, MANQABAT, SALAM, QITA, MUSADDAS, MASNAVI

**Gender:** MALE, FEMALE, OTHER

**Era:** CLASSICAL, MODERN, CONTEMPORARY, EMERGING

**ReadingLevel:** BEGINNER, INTERMEDIATE, ADVANCED

**InterestType:** CATEGORY, POET, TAG, LANGUAGE, CONTENT_TYPE

**ActivityType:** VIEW, LIKE, UNLIKE, BOOKMARK, UNBOOKMARK, SHARE, SEARCH, FOLLOW_POET, UNFOLLOW_POET, COLLECT, COMMENT, DOWNLOAD

**TargetType:** POEM, POET, CATEGORY, TAG, COLLECTION, USER, BOOK

**ShareType:** WHATSAPP, FACEBOOK, TWITTER, INSTAGRAM, COPY_LINK, SMS, EMAIL

**TagType:** ERA, POET_CATEGORY, POEM_GENRE, GENERAL, LANGUAGE, TEMPLATE_STYLE, TEMPLATE_CATEGORY

---

### 13.2 HTTP Status Codes

- **200 OK** - Success
- **201 Created** - Resource created
- **400 Bad Request** - Invalid input
- **401 Unauthorized** - Auth required/failed
- **403 Forbidden** - Not authorized
- **404 Not Found** - Resource not found
- **500 Internal Server Error** - Server error

---

### 13.3 Pagination Format

All paginated responses include:
```json
{
  "content": [...],
  "pageable": {"pageNumber": 0, "pageSize": 20},
  "totalElements": 150,
  "totalPages": 8,
  "last": false,
  "first": true
}
```

---

### 13.4 Error Response Format

```json
{
  "success": false,
  "message": "Error description",
  "data": null
}
```

---

## 14. Best Practices & Guidelines

### 14.1 Authentication

- Store tokens in secure storage (flutter_secure_storage)
- Refresh token when access token expires (401 response)
- Include Authorization header in ALL authenticated endpoints
- Handle token expiry gracefully with automatic retry

### 14.2 Pagination

- Use `page=0` for first page (zero-indexed)
- Default `size=20` for most lists
- Check `last` field to know if more pages exist
- Implement infinite scroll for better UX

### 14.3 Search

- Minimum query length: 2 characters
- Debounce search input (300-500ms)
- Use Elasticsearch endpoints for better performance
- Falls back to PostgreSQL automatically if ES unavailable

### 14.4 Image Handling

- All image URLs are CloudFront CDN URLs (permanent)
- Cache images locally using cached_network_image package
- Handle null image URLs gracefully with placeholders
- Compress images before upload (max 5MB for backgrounds)

### 14.5 Multi-Language Support

- Default language: Urdu (ur)
- Use `?lang=ur|en|hi` parameter consistently
- Handle RTL text for Urdu/Arabic (TextDirection.rtl)
- Use NotoNastaliqUrdu font for Urdu poetry

**Bookmark Language Context Preservation:**
- When users bookmark content (poems, couplets, or images), the `lang` parameter is stored with the bookmark
- This allows displaying bookmarks in their original language context regardless of current app language
- Example: If a user bookmarks a poem in Urdu (`lang=ur`) and another in English (`lang=en`), their bookmark screen will show mixed languages - each bookmark in its original language
- When fetching bookmarks, you can optionally filter by language:
  - `/api/users/me/bookmarks?lang=ur` - Only Urdu bookmarks
  - `/api/users/me/image-bookmarks?lang=en` - Only English image bookmarks
  - `/api/users/me/bookmarks` - All bookmarks (mixed languages)
- This feature enables a more natural user experience where content is preserved as the user first encountered it

### 14.6 Error Handling

```dart
try {
  final response = await apiCall();
  return response;
} on DioError catch (e) {
  if (e.response?.statusCode == 401) {
    await refreshToken();
    return apiCall(); // Retry
  }
  throw ApiException(e.response?.data['message'] ?? 'Unknown error');
} on SocketException {
  throw NetworkException('No internet connection');
}
```

### 14.7 Performance Optimization

- Use pagination for all lists
- Implement caching for frequently accessed data
- Lazy load images
- Use const constructors where possible
- Minimize API calls (batch requests when possible)

---

## 15. Complete Workflows

### 15.1 User Onboarding Flow

```
1. Firebase Auth (Google/Email/Phone)
   → POST /api/auth/firebase/verify
   → Store access + refresh tokens
   
2. Update Profile
   → PUT /api/profile/update (name, city, preferences)
   
3. Select Interests
   → POST /api/profile/interests (favorite poets, categories)
   
4. Start Exploring
   → GET /api/search/quick?q=محبت
```

---

### 15.2 Content Discovery Flow

```
Home Screen:
  → GET /api/poets/featured (Featured Poets)
  → GET /api/analytics/couplets/trending (Trending Couplets)
  → GET /api/profile/recommendations (Personalized)

Browse Poets:
  → GET /api/poets?page=0
  → Tap poet → GET /api/poets/{id}?lang=ur
  → View poems → GET /api/poems?poetId={id}

Read Poem:
  → GET /api/poems/{id}?lang=ur
  → GET /api/poems/{id}/couplets?lang=ur
  → Like couplet → POST /api/couplets/{id}/like
  → Generate image → POST /api/couplets/{id}/generate-image
```

---

### 15.3 Image Poetry Creation Flow

```
1. Select Couplet from poem

2. Choose Template
   → GET /api/image-templates
   → OR upload custom → POST /api/users/me/upload-background

3. Generate
   → POST /api/couplets/{id}/generate-image

4. Save, Bookmark & Share
   → POST /api/poetry-images/{id}/save (Save to collection)
   → POST /api/poetry-images/{id}/bookmark?lang=ur (Quick bookmark)
   → Share.share(imageUrl)

5. View Later
   → GET /api/users/me/saved-images (Collections)
   → GET /api/users/me/image-bookmarks?lang=ur (Bookmarks in specific language)
   → GET /api/users/me/image-bookmarks (All bookmarks, mixed languages)
```

---

### 15.4 Sharing & Social Flow

```
Share Couplet:
  → POST /api/couplets/{id}/share (shareType: WHATSAPP)
  → Get shareUrl + shareText
  → Share via platform

Comment on Poem:
  → POST /api/poems/{id}/comments
  → GET /api/poems/{id}/comments (view all)

View User Activity:
  → GET /api/users/me/couplets/liked (Liked couplets)
  → GET /api/users/me/couplets/bookmarked (Bookmarked couplets)
  → GET /api/users/me/saved-images (Saved image collections)
  → GET /api/users/me/image-bookmarks (Bookmarked images)
  → GET /api/users/me/image-bookmarks?lang=ur (Urdu bookmarked images)

Bookmark Content in Different Languages:
  → Reading Urdu poem → POST /api/poems/{id}/bookmark?lang=ur
  → Reading English translation → POST /api/poems/{id}/bookmark?lang=en
  → Viewing Hindi couplet → POST /api/couplets/{id}/bookmark?lang=hi
  → Generated Urdu image → POST /api/poetry-images/{id}/bookmark?lang=ur
  → All bookmarks preserved in their original language context
```

---

## Appendix A: Flutter Code Examples

### API Service Setup

```dart
class ApiService {
  final Dio dio;
  String? accessToken;
  String? refreshToken;
  
  ApiService() : dio = Dio(BaseOptions(
    baseUrl: Environment.baseUrl,
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _refreshToken();
          return handler.resolve(await _retry(error.requestOptions));
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<Response> _retry(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }
  
  Future<void> _refreshToken() async {
    final response = await dio.post('/api/auth/refresh', 
      data: {'refreshToken': refreshToken}
    );
    accessToken = response.data['data']['accessToken'];
    await _saveTokens();
  }
}
```

---

### Model Classes

```dart
class Poet {
  final String publicId;
  final String name;
  final String? profileImageUrl;
  final String? birthYear;
  final int poemCount;
  
  Poet.fromJson(Map<String, dynamic> json) 
    : publicId = json['publicId'],
      name = json['name'],
      profileImageUrl = json['profileImageUrl'],
      birthYear = json['birthYear']?.toString(),
      poemCount = json['poemCount'] ?? 0;
}

class Couplet {
  final String publicId;
  final int coupletNumber;
  final List<Verse> verses;
  final int likeCount;
  final int bookmarkCount;
  final CoupletUserStatus? userStatus;
  
  Couplet.fromJson(Map<String, dynamic> json)
    : publicId = json['publicId'],
      coupletNumber = json['coupletNumber'],
      verses = (json['verses'] as List)
          .map((v) => Verse.fromJson(v))
          .toList(),
      likeCount = json['likeCount'] ?? 0,
      bookmarkCount = json['bookmarkCount'] ?? 0,
      userStatus = json['userStatus'] != null 
          ? CoupletUserStatus.fromJson(json['userStatus'])
          : null;
}
```

---

## Appendix B: API Endpoints Summary

**Total Endpoints:** 110+

**By Category:**
- Authentication: 5
- User Profile: 10
- Poets: 12
- Poems: 13
- Couplets: 13
- Image Poetry: 11
- Books: 4
- Comments: 4
- Search: 4
- Categories: 5
- Tags: 4
- Geography: 3
- Languages: 3
- Health: 4
- Analytics: 15+

**Public Endpoints (No Auth):** 8
- Authentication endpoints (4)
- Health checks (4)

**Protected Endpoints:** 100+

---

## Appendix C: Changelog

### December 2025
- Added Couplet Engagement System (13 endpoints)
- Added Image Poetry Generation (11 endpoints)
- Added Book Management with download tracking
- Added Comments System (4 endpoints)
- Enhanced search with unified multi-type search
- Added comprehensive documentation with Flutter examples

### November 2025
- Added Image Template Management
- Enhanced Poet endpoints with multi-language support
- Added Tag-based poet filtering
- Improved pagination across all endpoints

### October 2025
- Initial API release
- Basic authentication with Firebase
- Poet and Poem CRUD operations
- User profile management

---

## Support & Feedback

For issues or questions:
- GitHub: https://github.com/your-repo/issues
- Email: support@poetry.com

**Documentation Version:** 1.0.0
**Last Updated:** December 28, 2025

---
