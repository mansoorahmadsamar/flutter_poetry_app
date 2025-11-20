# Poetry App - API Documentation for Flutter Team

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

### 1.2 Get Current User

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

### 1.3 Refresh Token

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

### 1.4 Logout

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
  ]
}
```

---

### 2.6 Add User Interest

**Endpoint:** `POST /api/profile/interests`

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "interestType": "POET",
  "interestId": 5,
  "interestName": "Mirza Ghalib",
  "strength": 0.8,
  "explicitPreference": true
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Interest added successfully",
  "data": {
    "id": 1,
    "publicId": "int_xyz789",
    "interestType": "POET",
    "interestId": 5,
    "interestName": "Mirza Ghalib",
    "strength": 0.8,
    "explicitPreference": true,
    "engagementScore": 0.0
  }
}
```

---

### 2.7 Remove User Interest

**Endpoint:** `DELETE /api/profile/interests/{interestType}/{interestId}`

**Path Parameters:**
- `interestType`: CATEGORY, POET, TAG, LANGUAGE, CONTENT_TYPE
- `interestId`: ID of the interest item

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `DELETE /api/profile/interests/POET/5`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Interest removed successfully",
  "data": null
}
```

---

### 2.8 Track Engagement

**Endpoint:** `POST /api/profile/engagement/track`

**Description:** Track user engagement activities (views, likes, bookmarks, etc.)

**Request Headers:**
```
Authorization: Bearer <access_token>
Content-Type: application/json
```

**Request Body:**
```json
{
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
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "Shikwa",
        "content": "کیوں زیاں کار بندوں میں...",
        "contentType": "TEXT",
        "imageUrl": null,
        "thumbnailUrl": null,
        "language": "ur",
        "script": "arabic",
        "form": "nazm",
        "yearWritten": 1909,
        "source": "Bang-e-Dara",
        "license": "public_domain",
        "isPublic": true,
        "isFeatured": true,
        "viewCount": 1523,
        "likeCount": 456,
        "poet": {
          "id": 5,
          "publicId": "poet_abc123",
          "name": "Allama Iqbal",
          "birthYear": 1877,
          "deathYear": 1938,
          "nationality": "British India",
          "language": "ur",
          "imageUrl": "https://example.com/iqbal.jpg"
        },
        "category": {
          "id": 3,
          "publicId": "cat_def456",
          "name": "Nazm",
          "slug": "nazm",
          "description": "Free verse poetry"
        },
        "createdAt": "2024-01-15T14:30:00",
        "updatedAt": "2024-01-15T14:30:00"
      }
    ],
    "pageable": {
      "pageNumber": 0,
      "pageSize": 10
    },
    "totalElements": 1523,
    "totalPages": 153,
    "last": false
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
    "id": 123,
    "publicId": "poem_xyz789",
    "title": "Shikwa",
    "content": "کیوں زیاں کار بندوں میں...",
    "contentType": "TEXT",
    "language": "ur",
    "script": "arabic",
    "form": "nazm",
    "yearWritten": 1909,
    "viewCount": 1524,
    "likeCount": 456,
    "poet": {
      "id": 5,
      "publicId": "poet_abc123",
      "name": "Allama Iqbal"
    },
    "category": {
      "id": 3,
      "publicId": "cat_def456",
      "name": "Nazm"
    }
  }
}
```

**Note:** View count is automatically incremented when fetching a poem.

---

### 4.3 Search Poems

**Endpoint:** `GET /api/poems/search?query=محبت&language=ur&page=0&size=10`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `query` (required): Search query
- `language` (optional): Filter by language
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Search results retrieved successfully",
  "data": {
    "content": [
      {
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "محبت کی راہیں",
        "content": "محبت کی راہیں...",
        "poet": {
          "name": "Mirza Ghalib"
        }
      }
    ],
    "totalElements": 45,
    "totalPages": 5
  }
}
```

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
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "Shikwa",
        "isFeatured": true,
        "poet": {
          "name": "Allama Iqbal"
        }
      }
    ]
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
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "Shikwa",
        "poet": {
          "publicId": "poet_abc123",
          "name": "Allama Iqbal"
        }
      }
    ]
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
        "id": 123,
        "publicId": "poem_xyz789",
        "title": "Shikwa",
        "category": {
          "publicId": "cat_def456",
          "name": "Nazm"
        }
      }
    ]
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

**Endpoint:** `POST /api/poems/{publicId}/bookmark`

**Description:** Bookmark or unbookmark a poem (toggles)

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

**Description:** Upload a new poem (requires authentication)

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
  "contentType": "TEXT",
  "imageUrl": null,
  "thumbnailUrl": null,
  "language": "ur",
  "script": "arabic",
  "form": "ghazal",
  "yearWritten": 2024,
  "source": "Original",
  "license": "public_domain",
  "isPublic": true,
  "tagIds": ["tag_123", "tag_456"]
}
```

**Success Response (201):**
```json
{
  "success": true,
  "message": "Poem uploaded successfully",
  "data": {
    "id": 789,
    "publicId": "poem_new123",
    "title": "New Poem Title",
    "content": "یہ ایک نئی نظم ہے...",
    "contentType": "TEXT",
    "language": "ur",
    "isPublic": true,
    "createdAt": "2024-01-15T14:30:00"
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

**Endpoint:** `GET /api/poets?page=0&size=10&lang=ur&sortBy=name&sortDir=asc`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)
- `lang` (optional): Language code - ur/en/hi (default: ur)
- `sortBy` (optional): Sort field (default: name)
- `sortDir` (optional): Sort direction - asc/desc (default: asc)

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

### 5.1.7 Search Poets

**Endpoint:** `GET /api/poets/search?query=iqbal&lang=ur&page=0&size=10`

**Authentication Required:** Yes

**Description:** Search poets by name in specified language

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Query Parameters:**
- `query` (required): Search query
- `lang` (optional): Language code - ur/en/hi (default: ur)
- `page` (optional): Page number (default: 0)
- `size` (optional): Items per page (default: 10)

**Example:** `GET /api/poets/search?query=Iqbal&lang=en`

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
        "poemCount": 234,
        "viewCount": 15234
      }
    ],
    "totalElements": 1,
    "totalPages": 1
  }
}
```

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

## 6. Category Endpoints

Base Path: `/api/categories`

### 6.1 Get All Categories

**Endpoint:** `GET /api/categories`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "cat_abc123",
      "name": "Ghazal",
      "slug": "ghazal",
      "description": "A form of amatory poem or ode",
      "createdAt": "2024-01-01T10:00:00"
    },
    {
      "id": 2,
      "publicId": "cat_def456",
      "name": "Nazm",
      "slug": "nazm",
      "description": "Free verse poetry",
      "createdAt": "2024-01-01T10:00:00"
    }
  ]
}
```

---

### 6.2 Get Root Categories

**Endpoint:** `GET /api/categories/root`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Description:** Get only top-level categories (no parent)

**Success Response (200):**
```json
{
  "success": true,
  "message": "Root categories retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "cat_abc123",
      "name": "Ghazal",
      "slug": "ghazal",
      "description": "A form of amatory poem or ode"
    }
  ]
}
```

---

### 6.3 Get Category by ID

**Endpoint:** `GET /api/categories/{publicId}`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `publicId`: Public ID of the category

**Example:** `GET /api/categories/cat_abc123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Category retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "cat_abc123",
    "name": "Ghazal",
    "slug": "ghazal",
    "description": "A form of amatory poem or ode"
  }
}
```

---

### 6.4 Get Category by Slug

**Endpoint:** `GET /api/categories/slug/{slug}`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Path Parameters:**
- `slug`: Slug of the category

**Example:** `GET /api/categories/slug/ghazal`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Category retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "cat_abc123",
    "name": "Ghazal",
    "slug": "ghazal",
    "description": "A form of amatory poem or ode"
  }
}
```

---

### 6.5 Get Category Children

**Endpoint:** `GET /api/categories/{publicId}/children`

**Authentication Required:** Yes

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Description:** Get subcategories of a category

**Path Parameters:**
- `publicId`: Public ID of the parent category

**Example:** `GET /api/categories/cat_abc123/children`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Child categories retrieved successfully",
  "data": [
    {
      "id": 10,
      "publicId": "cat_child123",
      "name": "Classical Ghazal",
      "slug": "classical-ghazal",
      "description": "Traditional form of ghazal"
    }
  ]
}
```

---

## 7. Tag Endpoints

Base Path: `/api/tags`

**Authentication Required:** Yes

Tags are used to categorize and filter poets. All tag endpoints require authentication.

### 7.1 Get All Tags

**Endpoint:** `GET /api/tags`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tags retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "tag_123",
      "name": "Ghazal Masters",
      "slug": "ghazal-masters",
      "description": "Poets who mastered the art of ghazal",
      "tagType": "POET_CATEGORY",
      "color": "#FF5733",
      "createdAt": "2024-01-01T10:00:00"
    },
    {
      "id": 2,
      "publicId": "tag_124",
      "name": "Women Poets",
      "slug": "women-poets",
      "description": "Female poets of Urdu literature",
      "tagType": "POET_CATEGORY",
      "color": "#C70039",
      "createdAt": "2024-01-01T10:00:00"
    },
    {
      "id": 3,
      "publicId": "tag_125",
      "name": "Sufi Poetry",
      "slug": "sufi-poetry",
      "description": "Mystical and spiritual poetry",
      "tagType": "POEM_GENRE",
      "color": "#900C3F",
      "createdAt": "2024-01-01T10:00:00"
    }
  ]
}
```

**Tag Types:**
- `ERA` - Era-based tags (classical, modern, contemporary)
- `POET_CATEGORY` - Poet categorization (women-poets, emerging-poets, etc.)
- `POEM_GENRE` - Poetry genre (ghazal, nazm, marsiya, etc.)
- `GENERAL` - General purpose tags
- `LANGUAGE` - Language-based tags

---

### 7.2 Get Tags by Type

**Endpoint:** `GET /api/tags/type/{type}`

**Path Parameters:**
- `type`: Tag type (ERA, POET_CATEGORY, POEM_GENRE, GENERAL, LANGUAGE)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/tags/type/POET_CATEGORY`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tags retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "tag_123",
      "name": "Ghazal Masters",
      "slug": "ghazal-masters",
      "description": "Poets who mastered the art of ghazal",
      "tagType": "POET_CATEGORY",
      "color": "#FF5733"
    },
    {
      "id": 2,
      "publicId": "tag_124",
      "name": "Women Poets",
      "slug": "women-poets",
      "description": "Female poets of Urdu literature",
      "tagType": "POET_CATEGORY",
      "color": "#C70039"
    }
  ]
}
```

---

### 7.3 Get Tag by Slug

**Endpoint:** `GET /api/tags/slug/{slug}`

**Path Parameters:**
- `slug`: Tag slug (e.g., "ghazal-masters", "women-poets")

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/tags/slug/ghazal-masters`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tag retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "tag_123",
    "name": "Ghazal Masters",
    "slug": "ghazal-masters",
    "description": "Poets who mastered the art of ghazal",
    "tagType": "POET_CATEGORY",
    "color": "#FF5733",
    "createdAt": "2024-01-01T10:00:00"
  }
}
```

---

### 7.4 Get Tag by Public ID

**Endpoint:** `GET /api/tags/{publicId}`

**Path Parameters:**
- `publicId`: Tag public ID

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/tags/tag_123`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Tag retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "tag_123",
    "name": "Ghazal Masters",
    "slug": "ghazal-masters",
    "description": "Poets who mastered the art of ghazal",
    "tagType": "POET_CATEGORY",
    "color": "#FF5733",
    "createdAt": "2024-01-01T10:00:00"
  }
}
```

---

## 8. Geography Endpoints (Countries & Cities)

Base Path: `/api/geography`

**Authentication Required:** Yes

Geography endpoints provide access to countries and cities with multi-language support. Use these for user profile forms, poet filtering, and location selection.

### 8.1 Get All Countries

**Endpoint:** `GET /api/geography/countries?lang=en`

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: en)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Countries retrieved successfully",
  "data": [
    {
      "publicId": "country_pk",
      "code": "PK",
      "name": "Pakistan"
    },
    {
      "publicId": "country_in",
      "code": "IN",
      "name": "India"
    },
    {
      "publicId": "country_af",
      "code": "AF",
      "name": "Afghanistan"
    }
  ]
}
```

**Example with Urdu:**
`GET /api/geography/countries?lang=ur`

```json
{
  "success": true,
  "message": "Countries retrieved successfully",
  "data": [
    {
      "publicId": "country_pk",
      "code": "PK",
      "name": "پاکستان"
    },
    {
      "publicId": "country_in",
      "code": "IN",
      "name": "بھارت"
    },
    {
      "publicId": "country_af",
      "code": "AF",
      "name": "افغانستان"
    }
  ]
}
```

---

### 8.2 Get All Cities

**Endpoint:** `GET /api/geography/cities?lang=en&countryCode=PK`

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: en)
- `countryCode` (optional): Filter by country code (PK, IN, AF)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Cities retrieved successfully",
  "data": [
    {
      "publicId": "city_karachi",
      "name": "Karachi",
      "countryCode": "PK",
      "countryName": "Pakistan",
      "latitude": 24.8607,
      "longitude": 67.0011
    },
    {
      "publicId": "city_lahore",
      "name": "Lahore",
      "countryCode": "PK",
      "countryName": "Pakistan",
      "latitude": 31.5497,
      "longitude": 74.3436
    },
    {
      "publicId": "city_islamabad",
      "name": "Islamabad",
      "countryCode": "PK",
      "countryName": "Pakistan",
      "latitude": 33.6844,
      "longitude": 73.0479
    }
  ]
}
```

**Example with Urdu:**
`GET /api/geography/cities?lang=ur&countryCode=PK`

```json
{
  "success": true,
  "message": "Cities retrieved successfully",
  "data": [
    {
      "publicId": "city_karachi",
      "name": "کراچی",
      "countryCode": "PK",
      "countryName": "پاکستان",
      "latitude": 24.8607,
      "longitude": 67.0011
    },
    {
      "publicId": "city_lahore",
      "name": "لاہور",
      "countryCode": "PK",
      "countryName": "پاکستان",
      "latitude": 31.5497,
      "longitude": 74.3436
    }
  ]
}
```

---

### 8.3 Get Cities by Country

**Endpoint:** `GET /api/geography/countries/{countryCode}/cities?lang=en`

**Path Parameters:**
- `countryCode`: Country code (PK, IN, AF)

**Query Parameters:**
- `lang` (optional): Language code - ur/en/hi (default: en)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/geography/countries/PK/cities?lang=en`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Cities retrieved successfully",
  "data": [
    {
      "publicId": "city_karachi",
      "name": "Karachi",
      "latitude": 24.8607,
      "longitude": 67.0011
    },
    {
      "publicId": "city_lahore",
      "name": "Lahore",
      "latitude": 31.5497,
      "longitude": 74.3436
    },
    {
      "publicId": "city_islamabad",
      "name": "Islamabad",
      "latitude": 33.6844,
      "longitude": 73.0479
    }
  ]
}
```

---

## 9. Language Endpoints

Base Path: `/api/languages`

**Authentication Required:** Yes

Language endpoints provide access to supported languages for the app. Use these for language selection in user preferences.

### 9.1 Get All Languages

**Endpoint:** `GET /api/languages`

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Languages retrieved successfully",
  "data": [
    {
      "code": "ur",
      "name": "Urdu",
      "nativeName": "اردو",
      "direction": "RTL",
      "isActive": true
    },
    {
      "code": "en",
      "name": "English",
      "nativeName": "English",
      "direction": "LTR",
      "isActive": true
    },
    {
      "code": "hi",
      "name": "Hindi",
      "nativeName": "हिंदी",
      "direction": "LTR",
      "isActive": true
    },
    {
      "code": "ar",
      "name": "Arabic",
      "nativeName": "العربية",
      "direction": "RTL",
      "isActive": false
    },
    {
      "code": "fa",
      "name": "Persian",
      "nativeName": "فارسی",
      "direction": "RTL",
      "isActive": false
    }
  ]
}
```

**Direction Values:**
- `LTR` - Left to Right (English, Hindi)
- `RTL` - Right to Left (Urdu, Arabic, Persian)

---

### 9.2 Get Language by Code

**Endpoint:** `GET /api/languages/{code}`

**Path Parameters:**
- `code`: Language code (ur, en, hi, ar, fa)

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Example:** `GET /api/languages/ur`

**Success Response (200):**
```json
{
  "success": true,
  "message": "Language retrieved successfully",
  "data": {
    "code": "ur",
    "name": "Urdu",
    "nativeName": "اردو",
    "direction": "RTL",
    "isActive": true
  }
}
```

---

### 9.3 Get Active Languages

**Endpoint:** `GET /api/languages/active`

**Description:** Get only languages that are currently active/supported in the app

**Request Headers:**
```
Authorization: Bearer <access_token>
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Active languages retrieved successfully",
  "data": [
    {
      "code": "ur",
      "name": "Urdu",
      "nativeName": "اردو",
      "direction": "RTL"
    },
    {
      "code": "en",
      "name": "English",
      "nativeName": "English",
      "direction": "LTR"
    },
    {
      "code": "hi",
      "name": "Hindi",
      "nativeName": "हिंदी",
      "direction": "LTR"
    }
  ]
}
```

**Note:** Currently active languages are Urdu (ur), English (en), and Hindi (hi).

---

## 10. Health Check Endpoints

Base Path: `/api/health`

### 10.1 Basic Health Check

**Endpoint:** `GET /api/health`

**Authentication Required:** No

**Success Response (200):**
```json
{
  "success": true,
  "message": "Health check successful",
  "data": {
    "status": "UP",
    "timestamp": "2024-01-15T14:30:00",
    "service": "Poetry Backend API",
    "version": "1.0.0"
  }
}
```

---

### 10.2 Detailed Health Check

**Endpoint:** `GET /api/health/detailed`

**Authentication Required:** No

**Success Response (200):**
```json
{
  "success": true,
  "message": "Detailed health check completed",
  "data": {
    "status": "UP",
    "timestamp": "2024-01-15T14:30:00",
    "service": "Poetry Backend API",
    "version": "1.0.0",
    "database": {
      "status": "UP",
      "message": "Database connection is healthy"
    },
    "statistics": {
      "totalUsers": 1234,
      "totalPoems": 5678,
      "totalPoets": 1000
    }
  }
}
```

**Note:** Statistics now show 1000 poets after the migration.

---

### 10.3 Readiness Check

**Endpoint:** `GET /api/health/ready`

**Authentication Required:** No

**Success Response (200):**
```json
{
  "success": true,
  "message": "Readiness check completed",
  "data": {
    "status": "READY",
    "timestamp": "2024-01-15T14:30:00"
  }
}
```

---

### 10.4 Liveness Check

**Endpoint:** `GET /api/health/live`

**Authentication Required:** No

**Success Response (200):**
```json
{
  "success": true,
  "message": "Liveness check successful",
  "data": {
    "status": "ALIVE",
    "timestamp": "2024-01-15T14:30:00",
    "uptime": 1705328400000
  }
}
```

---

## Common HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required or failed
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error
- `503 Service Unavailable` - Service temporarily unavailable

---

## Pagination Response Format

All paginated endpoints return data in this format:

```json
{
  "content": [...],
  "pageable": {
    "pageNumber": 0,
    "pageSize": 10,
    "sort": {
      "sorted": true,
      "unsorted": false
    }
  },
  "totalElements": 100,
  "totalPages": 10,
  "last": false,
  "first": true,
  "size": 10,
  "number": 0,
  "numberOfElements": 10
}
```

---

## Error Response Format

Error responses follow this format:

```json
{
  "success": false,
  "message": "Error description here",
  "data": null
}
```

---

## Enum Values Reference

### ReadingLevel
- `BEGINNER`
- `INTERMEDIATE`
- `ADVANCED`

### ProfileVisibility
- `PUBLIC`
- `PRIVATE`
- `FRIENDS_ONLY`

### ContentType (Poem)
- `TEXT`
- `IMAGE`
- `MIXED`

### InterestType
- `CATEGORY`
- `POET`
- `TAG`
- `LANGUAGE`
- `CONTENT_TYPE`

### ActivityType
- `VIEW`
- `LIKE`
- `UNLIKE`
- `BOOKMARK`
- `UNBOOKMARK`
- `SHARE`
- `SEARCH`
- `FOLLOW_POET`
- `UNFOLLOW_POET`
- `COLLECT`
- `COMMENT`
- `DOWNLOAD`

### TargetType
- `POEM`
- `POET`
- `CATEGORY`
- `TAG`
- `COLLECTION`
- `USER`

---

## API Endpoints Summary

### Public Endpoints (No Authentication Required)

**Authentication Endpoints:**
- `POST /api/auth/firebase/verify` - Login/Register with Firebase
- `POST /api/auth/refresh` - Refresh access token
- `POST /api/auth/logout` - Logout user

**Health Check Endpoints:**
- `GET /api/health` - Basic health check
- `GET /api/health/detailed` - Detailed health check
- `GET /api/health/ready` - Readiness check
- `GET /api/health/live` - Liveness check

**Total Public Endpoints: 7**

### Protected Endpoints (Authentication Required)

**Authentication:**
- `GET /api/auth/me` - Get current user

**User Profile (10 endpoints):**
- Profile management
- User interests (CRUD)
- Engagement tracking
- Analytics

**User (3 endpoints):**
- Get user info
- Get bookmarks
- Update profile

**Poems (11 endpoints):**
- Browse all poems
- Search poems
- Get by poet/category/language
- Upload poem
- Like/bookmark/status

**Poets (28 endpoints):**
- Browse/Discovery (7): all, featured, trending, by gender, by era, by tag, search
- Top/Ranking (2): by poem count, by views
- Profile (5): complete profile, gallery, books, videos, facts
- Admin CRUD (14): create, update, add translation, add image/book/video/fact/tag, delete image/video/book/tag

**Categories (5 endpoints):**
- Browse all categories
- Get category details
- Get subcategories

**Tags (4 endpoints):**
- Get all tags
- Get tags by type
- Get tag by slug
- Get tag by public ID

**Geography (3 endpoints):**
- Get all countries (with multi-language support)
- Get all cities (with multi-language support)
- Get cities by country

**Languages (3 endpoints):**
- Get all languages
- Get language by code
- Get active languages

**Total Protected Endpoints: 71**

**Total API Endpoints: 78**

---

## Notes for Flutter Team

1. **Authentication Flow:**
   - **CRITICAL:** User must login before accessing any content
   - Use Firebase to authenticate users on the client side
   - Send Firebase ID token to `/api/auth/firebase/verify`
   - Store `accessToken` and `refreshToken` locally
   - Include `accessToken` in Authorization header for ALL endpoints (except `/api/auth/**` and `/api/health/**`)
   - Refresh token when it expires using `/api/auth/refresh`
   - All content browsing (poems, poets, categories) requires authentication

2. **Pagination:**
   - Most list endpoints support pagination
   - Use `page` (0-indexed) and `size` parameters
   - Check `last` field to know if more pages exist
   - Use `totalElements` and `totalPages` for UI pagination controls

3. **Search:**
   - Search is available for poems and poets
   - Can filter by language
   - Results are paginated

4. **Engagement Tracking:**
   - Track user interactions for personalization
   - Send engagement events for: views, likes, bookmarks, searches
   - Include session ID for better analytics

5. **User Interests:**
   - Allow users to select favorite poets, categories
   - Use for personalized recommendations
   - Track both explicit preferences and implicit engagement

6. **Error Handling:**
   - Always check `success` field in response
   - Display `message` field to users for errors
   - Handle 401 errors by refreshing token or re-authenticating

7. **Image URLs:**
   - All image URLs are absolute paths
   - Handle null image URLs gracefully
   - Consider caching images locally

8. **Languages:**
   - Default language is Urdu (ur)
   - Support Arabic script for Urdu content
   - Handle RTL text rendering properly

9. **Public IDs:**
   - Use `publicId` (not `id`) for API requests
   - Public IDs are string-based and more secure

10. **Real-time Features:**
    - View counts are updated automatically
    - Like/bookmark toggles return current state
    - Use status endpoint to get current state before displaying UI

11. **Environment Configuration:**
    - Always use environment-based base URLs (see top of document)
    - For local testing: Make sure backend is running on `http://localhost:8080`
    - For Android emulator local testing: Use `http://10.0.2.2:8080/api` instead of localhost
    - For iOS simulator local testing: Use `http://localhost:8080/api`
    - Never hardcode production URLs - use build configurations
    - Test with dev environment before deploying to production

12. **Testing Checklist:**
    - Test authentication flow in all environments
    - Verify token refresh works correctly
    - Test with expired tokens (should auto-refresh or prompt re-login)
    - Test offline scenarios and network error handling
    - Verify all protected endpoints return 401 when token is missing/invalid