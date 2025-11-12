# Poetry Backend API Documentation

## Base URL
```
http://localhost:8080
```

---

## Authentication System

### Overview
The Poetry Backend uses **OAuth2.0 with Google** as the authentication provider and **JWT (JSON Web Tokens)** for maintaining user sessions. The system implements a dual-token approach with access tokens and refresh tokens for enhanced security.

### Authentication Flow Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Client    │────────>│   Backend    │────────>│   Google    │
│     App     │         │    Server    │         │    OAuth    │
└─────────────┘         └──────────────┘         └─────────────┘
      │                        │                         │
      │  1. Initiate Login    │                         │
      │─────────────────────>│                         │
      │                        │  2. Redirect to Google │
      │                        │───────────────────────>│
      │                        │                         │
      │  3. Google Auth Page   │                         │
      │<────────────────────────────────────────────────│
      │                        │                         │
      │  4. User Authenticates │                         │
      │───────────────────────────────────────────────>│
      │                        │                         │
      │                        │  5. Auth Code          │
      │                        │<───────────────────────│
      │                        │                         │
      │                        │  6. Exchange for Token │
      │                        │───────────────────────>│
      │                        │                         │
      │                        │  7. User Info          │
      │                        │<───────────────────────│
      │                        │                         │
      │  8. Redirect + Tokens  │                         │
      │<───────────────────────│                         │
      │                        │                         │
```

### How Authentication Works

1. **Initial Authentication**:
   - Client initiates OAuth flow by navigating to `/oauth2/authorization/google`
   - User is redirected to Google's authentication page
   - User authenticates with Google credentials
   - Google redirects back to backend with authorization code
   - Backend exchanges code for user information from Google
   - Backend creates or updates user in database
   - Backend generates JWT tokens (access + refresh)
   - Backend redirects to configured callback URL with tokens in query parameters

2. **Using Access Tokens**:
   - Client extracts tokens from callback URL
   - Client stores tokens securely
   - Client includes access token in `Authorization` header for protected API calls
   - Format: `Authorization: Bearer <access-token>`

3. **Token Refresh**:
   - When access token expires (401 response), use refresh token
   - Call `/api/auth/refresh` endpoint with refresh token
   - Backend validates refresh token and issues new access + refresh tokens
   - Old refresh token is automatically revoked
   - Update stored tokens with new ones

4. **Logout**:
   - Call `/api/auth/logout` endpoint with refresh token
   - Backend revokes all refresh tokens for the user
   - Client clears stored tokens locally

### Token Management

#### Access Token
- **Type**: JWT (JSON Web Token)
- **Purpose**: Authenticate API requests
- **Expiration**: Configurable (default: 1 hour via `app.jwt.expiration`)
- **Storage**: Must be stored securely on client side
- **Usage**: Include in `Authorization` header as `Bearer <token>`
- **Content**: Contains user email in the subject claim

#### Refresh Token
- **Type**: JWT (JSON Web Token)
- **Purpose**: Obtain new access tokens without re-authentication
- **Expiration**: 7 days
- **Storage**: Must be stored securely on client side
- **Usage**: Send to `/api/auth/refresh` endpoint when access token expires
- **Revocation**: Automatically revoked when used or when user logs out
- **Security**: Only one refresh token is valid per user at a time

### Important Security Notes

1. **Token Storage**: Tokens should be stored securely on the client side (not in plain text or local storage)
2. **Token Rotation**: Each refresh generates a new refresh token and revokes the old one
3. **Automatic Revocation**: All refresh tokens are revoked on logout
4. **Access Token Lifespan**: Access tokens cannot be revoked before expiration - keep expiration time short
5. **HTTPS Required**: Always use HTTPS in production to prevent token interception

---

## Authentication Endpoints

### 1. Initiate Google Login
**Endpoint:** `GET /oauth2/authorization/google`

**Description:** Initiates the Google OAuth2 authentication flow. This is not a standard REST API endpoint - it's a browser redirect that starts the OAuth flow.

**Authentication:** Not required

**Method:** Browser-based redirect

**How it works:**
1. Client navigates to this URL (via browser, WebView, or external browser)
2. Backend redirects user to Google's authentication page
3. User completes authentication with Google
4. Google redirects back to backend with authorization code
5. Backend exchanges code for user information from Google
6. Backend creates or updates user in database with Google profile data
7. Backend generates JWT tokens (access token + refresh token)
8. Backend redirects to configured callback URL with tokens as query parameters

**Redirect URL (after successful authentication):**
```
{configured_redirect_uri}?access_token={jwt_access_token}&refresh_token={jwt_refresh_token}
```

**Example Redirect:**
```
http://localhost:3000/auth/callback?access_token=eyJhbGciOiJIUzUxMiJ9...&refresh_token=eyJhbGciOiJIUzUxMiJ9...
```

**Callback URL Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `access_token` | String (JWT) | JWT access token for API authentication (expires in 1 hour) |
| `refresh_token` | String (JWT) | JWT refresh token for obtaining new access tokens (expires in 7 days) |

**Configuration:**
- Default redirect URI: `http://localhost:3000/auth/callback`
- Can be configured via: `app.oauth2.authorizedRedirectUri` property in backend
- For mobile apps, configure a custom URL scheme or deep link

**User Data Collected from Google:**
- Email address (required)
- Full name
- Google ID
- Profile image URL

**User Creation/Update Logic:**
- If user with email doesn't exist: Creates new user account
- If user exists: Updates profile image if changed
- Username is auto-generated from email (prefix before @)
- Provider field set to "google"

### 2. Get Current User
**Endpoint:** `GET /api/auth/me`

**Description:** Retrieve the authenticated user's basic information

**Authentication:** Required (Bearer token)

**Request Headers:**
```
Authorization: Bearer <your-access-token>
Content-Type: application/json
```

**Request Body:** None

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "email": "user@example.com",
    "fullName": "John Doe",
    "username": "johndoe",
    "profileImageUrl": "https://lh3.googleusercontent.com/a/xxx",
    "provider": "google",
    "isActive": true
  }
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `id` | Integer | Internal user ID |
| `email` | String | User's email address |
| `fullName` | String | User's full name from Google |
| `username` | String | Unique username (generated from email) |
| `profileImageUrl` | String | Google profile picture URL |
| `provider` | String | Authentication provider (always "google") |
| `isActive` | Boolean | Whether the user account is active |

**Error Responses:**

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "User not authenticated",
  "data": null
}
```
*Cause:* Missing, invalid, or expired access token

**404 Not Found:**
```json
{
  "success": false,
  "message": "User not found",
  "data": null
}
```
*Cause:* User exists in JWT but not in database (rare edge case)

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Error retrieving user information",
  "data": null
}
```
*Cause:* Server-side error

### 3. Refresh Access Token
**Endpoint:** `POST /api/auth/refresh`

**Description:** Obtain new access and refresh tokens using an existing valid refresh token

**Authentication:** Not required (uses refresh token in request body)

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

**Request Body Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `refreshToken` | String (JWT) | Yes | Valid refresh token obtained from login or previous refresh |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Token refreshed successfully!",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "type": "Bearer",
    "publicId": "user_1234567890abcdef",
    "username": "johndoe",
    "email": "user@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://lh3.googleusercontent.com/a/xxx"
  }
}
```

**Response Fields:**
| Field | Type | Description |
|-------|------|-------------|
| `accessToken` | String (JWT) | New access token (expires in 1 hour) |
| `refreshToken` | String (JWT) | New refresh token (expires in 7 days) |
| `type` | String | Token type (always "Bearer") |
| `publicId` | String | User's public identifier |
| `username` | String | User's username |
| `email` | String | User's email address |
| `fullName` | String | User's full name |
| `profileImageUrl` | String | User's profile image URL |

**Error Responses:**

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Refresh Token is required!",
  "data": null
}
```
*Cause:* Missing or empty `refreshToken` in request body

**500 Internal Server Error:**
```json
{
  "success": false,
  "message": "Refresh token is not in database!",
  "data": null
}
```
*Cause:* Invalid, expired, or revoked refresh token

**Important Notes:**
1. **Token Rotation**: The old refresh token is **automatically revoked** when used
2. **Update Both Tokens**: Always update both access and refresh tokens in client storage
3. **Single Use**: Each refresh token can only be used once
4. **Expiration**: Refresh tokens expire after 7 days of issuance
5. **One Token Per User**: Only one refresh token is valid per user at a time
6. **Failed Refresh**: If refresh fails, user must re-authenticate via Google login

### 4. Logout
**Endpoint:** `POST /api/auth/logout`

**Description:** Logout the user and revoke all refresh tokens associated with the user's account

**Authentication:** Not required (uses refresh token in request body)

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzUxMiJ9..."
}
```

**Request Body Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `refreshToken` | String (JWT) | No | User's refresh token (optional but recommended) |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Logged out successfully!",
  "data": null
}
```

**Important Notes:**
1. **Token Revocation**: All refresh tokens for the user are revoked on the backend
2. **Access Tokens**: Existing access tokens remain valid until expiration (cannot be revoked server-side)
3. **Client Cleanup**: Client must clear stored tokens locally regardless of API response
4. **Optional Refresh Token**: If refresh token is not provided or invalid, the endpoint still returns success
5. **Graceful Handling**: Always succeeds (200 OK) even if token is invalid or missing

**Client-Side Logout Flow:**
1. Call `/api/auth/logout` with refresh token (if available)
2. Clear stored access token from client storage
3. Clear stored refresh token from client storage
4. Redirect user to login screen
5. Clear any cached user data or session information

**Security Consideration:**
- Since access tokens cannot be revoked server-side, they remain valid until expiration
- Keep access token expiration time short (default: 1 hour) to minimize security risk
- Logged-out users with valid access tokens can still make API calls until token expires

---

## Protected Endpoints

All endpoints below require authentication. Include the access token in the `Authorization` header for every request:

**Required Headers for Protected Endpoints:**
```
Authorization: Bearer <your-access-token>
Content-Type: application/json
```

**Example Request:**
```
GET /api/profile HTTP/1.1
Host: localhost:8080
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2VyQGV4YW1wbGUuY29tIiwiaWF0IjoxNzA5NTU...
Content-Type: application/json
```

### Authentication Errors

All protected endpoints may return the following authentication-related errors:

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "User not authenticated",
  "data": null
}
```
**Causes:**
- Missing `Authorization` header
- Invalid JWT token format
- Expired access token
- Token signature verification failed

**Recommended Action:**
1. Attempt to refresh token using `/api/auth/refresh` endpoint
2. If refresh succeeds: Retry the original request with new access token
3. If refresh fails: Clear stored tokens and redirect user to login

**403 Forbidden:**
```json
{
  "success": false,
  "message": "Access denied",
  "data": null
}
```
**Cause:** User is authenticated but lacks permission to access the resource

**Recommended Action:** Show appropriate error message to user

### Token Refresh Strategy

When a protected endpoint returns 401:
1. **Immediate Action**: Call `/api/auth/refresh` with stored refresh token
2. **Success**: Update stored tokens and retry the failed request
3. **Failure**: Clear all tokens and require user to login again
4. **Best Practice**: Implement automatic retry logic for 401 responses

---

## Categories API

### 1. Get All Categories
**Endpoint:** `GET /api/categories`
**Description:** Retrieve all categories including parent and child categories
**Authentication:** Not required

**Response:**
```json
{
  "success": true,
  "message": "Categories retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "cat_1234567890abcdef",
      "name": "Classical Poetry",
      "slug": "classical-poetry",
      "description": "Traditional forms of Urdu poetry with established patterns and structures",
      "parent": null,
      "children": [
        {
          "id": 2,
          "publicId": "cat_2345678901bcdefg",
          "name": "Ghazal",
          "slug": "ghazal",
          "description": "Traditional form of amorous poetry",
          "parent": {
            "id": 1,
            "name": "Classical Poetry"
          },
          "children": []
        }
      ],
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### 2. Get Root Categories Only
**Endpoint:** `GET /api/categories/root`
**Description:** Retrieve only parent categories (no subcategories)
**Authentication:** Not required

**Response:**
```json
{
  "success": true,
  "message": "Root categories retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "cat_1234567890abcdef",
      "name": "Classical Poetry",
      "slug": "classical-poetry",
      "description": "Traditional forms of Urdu poetry with established patterns and structures",
      "parent": null,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    {
      "id": 5,
      "publicId": "cat_5678901234abcdef",
      "name": "Modern Poetry",
      "slug": "modern-poetry",
      "description": "Contemporary Urdu poetry breaking traditional boundaries",
      "parent": null,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### 3. Get Category by ID
**Endpoint:** `GET /api/categories/{publicId}`
**Description:** Retrieve a specific category by its public ID
**Authentication:** Not required

**Response:**
```json
{
  "success": true,
  "message": "Category retrieved successfully",
  "data": {
    "id": 2,
    "publicId": "cat_2345678901bcdefg",
    "name": "Ghazal",
    "slug": "ghazal",
    "description": "Traditional form of amorous poetry",
    "parent": {
      "id": 1,
      "publicId": "cat_1234567890abcdef",
      "name": "Classical Poetry"
    },
    "children": [],
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### 4. Get Category by Slug
**Endpoint:** `GET /api/categories/slug/{slug}`
**Description:** Retrieve a specific category by its slug
**Authentication:** Not required

**Example:** `GET /api/categories/slug/ghazal`

**Response:** Same as Get Category by ID

### 5. Get Category Children
**Endpoint:** `GET /api/categories/{publicId}/children`
**Description:** Retrieve all child categories of a specific category
**Authentication:** Not required

**Response:**
```json
{
  "success": true,
  "message": "Child categories retrieved successfully",
  "data": [
    {
      "id": 2,
      "publicId": "cat_2345678901bcdefg",
      "name": "Ghazal",
      "slug": "ghazal",
      "description": "Traditional form of amorous poetry",
      "parent": {
        "id": 1,
        "name": "Classical Poetry"
      },
      "children": [],
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

---

## Poets API

### 1. Get All Poets (Paginated)
**Endpoint:** `GET /api/poets`
**Description:** Retrieve all poets with pagination and filtering options
**Authentication:** Not required

**Query Parameters:**
- `page` (default: 0) - Page number
- `size` (default: 10) - Number of items per page
- `sortBy` (default: "name") - Field to sort by
- `sortDir` (default: "asc") - Sort direction (asc/desc)
- `language` (optional) - Filter by language code

**Example:** `GET /api/poets?page=0&size=5&sortBy=name&sortDir=asc&language=ur`

**Response:**
```json
{
  "success": true,
  "message": "Poets retrieved successfully",
  "data": {
    "content": [
      {
        "id": 1,
        "publicId": "poet_1234567890abcdef",
        "name": "Mirza Ghalib",
        "birthYear": 1797,
        "deathYear": 1869,
        "biography": "Mirza Asadullah Baig Khan, known as Ghalib, is considered one of the greatest Urdu poets...",
        "nationality": "Indian",
        "language": "ur",
        "imageUrl": null,
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-15T10:30:00Z"
      },
      {
        "id": 2,
        "publicId": "poet_2345678901bcdefg",
        "name": "Allama Iqbal",
        "birthYear": 1877,
        "deathYear": 1938,
        "biography": "Muhammad Iqbal was a philosopher, poet, and politician...",
        "nationality": "Pakistani",
        "language": "ur",
        "imageUrl": null,
        "createdAt": "2024-01-15T10:30:00Z",
        "updatedAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pageable": {
      "sort": {
        "sorted": true,
        "unsorted": false,
        "empty": false
      },
      "pageNumber": 0,
      "pageSize": 5,
      "offset": 0,
      "paged": true,
      "unpaged": false
    },
    "totalElements": 24,
    "totalPages": 5,
    "last": false,
    "first": true,
    "numberOfElements": 5,
    "size": 5,
    "number": 0,
    "sort": {
      "sorted": true,
      "unsorted": false,
      "empty": false
    },
    "empty": false
  }
}
```

### 2. Get Poet by ID
**Endpoint:** `GET /api/poets/{publicId}`
**Description:** Retrieve a specific poet by their public ID
**Authentication:** Not required

**Response:**
```json
{
  "success": true,
  "message": "Poet retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "poet_1234567890abcdef",
    "name": "Mirza Ghalib",
    "birthYear": 1797,
    "deathYear": 1869,
    "biography": "Mirza Asadullah Baig Khan, known as Ghalib, is considered one of the greatest Urdu poets. His ghazals are renowned for their depth, complexity, and philosophical insights.",
    "nationality": "Indian",
    "language": "ur",
    "imageUrl": null,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### 3. Search Poets
**Endpoint:** `GET /api/poets/search`
**Description:** Search poets by name or other criteria
**Authentication:** Not required

**Query Parameters:**
- `query` (required) - Search term
- `language` (optional) - Filter by language
- `page` (default: 0) - Page number
- `size` (default: 10) - Number of items per page

**Example:** `GET /api/poets/search?query=Ghalib&language=ur&page=0&size=10`

**Response:** Same structure as Get All Poets (paginated)

---

## Profile API

### 1. Get Current User Profile
**Endpoint:** `GET /api/profile`
**Description:** Get the current authenticated user's profile
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "User profile retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "user_1234567890abcdef",
    "email": "user@example.com",
    "name": "John Doe",
    "profilePicture": "https://example.com/profile.jpg",
    "provider": "GOOGLE",
    "providerId": "google_123456789",
    "onboardingCompleted": true,
    "emailVerified": true,
    "accountNonExpired": true,
    "accountNonLocked": true,
    "credentialsNonExpired": true,
    "enabled": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### 2. Update Profile
**Endpoint:** `PUT /api/profile`
**Description:** Update the current user's profile information
**Authentication:** Required

**Request Body:**
```json
{
  "name": "Updated Name",
  "profilePicture": "https://example.com/new-profile.jpg"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Profile updated successfully",
  "data": {
    "id": 1,
    "publicId": "user_1234567890abcdef",
    "email": "user@example.com",
    "name": "Updated Name",
    "profilePicture": "https://example.com/new-profile.jpg",
    "provider": "GOOGLE",
    "providerId": "google_123456789",
    "onboardingCompleted": true,
    "emailVerified": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T11:45:00Z"
  }
}
```

### 3. Complete Onboarding
**Endpoint:** `POST /api/profile/complete-onboarding`
**Description:** Mark the user's onboarding as completed
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "Onboarding completed successfully",
  "data": {
    "id": 1,
    "publicId": "user_1234567890abcdef",
    "email": "user@example.com",
    "name": "John Doe",
    "onboardingCompleted": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T11:45:00Z"
  }
}
```

---

## User Interests API

### 1. Get User Interests
**Endpoint:** `GET /api/profile/interests`
**Description:** Get all interests for the current user
**Authentication:** Required

**Response:**
```json
{
  "success": true,
  "message": "User interests retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "interest_1234567890abcdef",
      "interestType": "CATEGORY",
      "interestId": 2,
      "interestName": "Ghazal",
      "strength": 0.8,
      "explicitPreference": true,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    },
    {
      "id": 2,
      "publicId": "interest_2345678901bcdefg",
      "interestType": "POET",
      "interestId": 1,
      "interestName": "Mirza Ghalib",
      "strength": 0.9,
      "explicitPreference": true,
      "createdAt": "2024-01-15T10:30:00Z",
      "updatedAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### 2. Get User Interests by Type
**Endpoint:** `GET /api/profile/interests/{interestType}`
**Description:** Get user interests filtered by type (CATEGORY or POET)
**Authentication:** Required

**Example:** `GET /api/profile/interests/CATEGORY`

**Response:** Same structure as Get User Interests, but filtered by type

### 3. Add User Interest
**Endpoint:** `POST /api/profile/interests`
**Description:** Add a new interest for the current user
**Authentication:** Required

**Request Body:**
```json
{
  "interestType": "CATEGORY",
  "interestId": 2,
  "interestName": "Ghazal",
  "strength": 0.8,
  "explicitPreference": true
}
```

**Response:**
```json
{
  "success": true,
  "message": "Interest added successfully",
  "data": {
    "id": 1,
    "publicId": "interest_1234567890abcdef",
    "interestType": "CATEGORY",
    "interestId": 2,
    "interestName": "Ghazal",
    "strength": 0.8,
    "explicitPreference": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

### 4. Remove User Interest
**Endpoint:** `DELETE /api/profile/interests/{interestType}/{interestId}`
**Description:** Remove a specific interest from the current user
**Authentication:** Required

**Example:** `DELETE /api/profile/interests/CATEGORY/2`

**Response:**
```json
{
  "success": true,
  "message": "Interest removed successfully",
  "data": null
}
```

---

## Engagement Tracking API

### 1. Track Engagement
**Endpoint:** `POST /api/profile/engagement/track`
**Description:** Track user engagement activity
**Authentication:** Required

**Request Body:**
```json
{
  "activityType": "VIEW",
  "targetType": "POEM",
  "targetId": 123,
  "durationSeconds": 45,
  "sessionId": "session_abc123",
  "deviceType": "mobile",
  "metadata": "{\"source\": \"recommendation\"}"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Engagement tracked successfully",
  "data": {
    "id": 1,
    "publicId": "engagement_1234567890abcdef",
    "activityType": "VIEW",
    "targetType": "POEM",
    "targetId": 123,
    "durationSeconds": 45,
    "sessionId": "session_abc123",
    "deviceType": "mobile",
    "metadata": "{\"source\": \"recommendation\"}",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### 2. Get Recent Engagement
**Endpoint:** `GET /api/profile/engagement/recent`
**Description:** Get user's recent engagement activities
**Authentication:** Required

**Query Parameters:**
- `days` (default: 30) - Number of days to look back

**Example:** `GET /api/profile/engagement/recent?days=7`

**Response:**
```json
{
  "success": true,
  "message": "Recent activities retrieved successfully",
  "data": [
    {
      "id": 1,
      "publicId": "engagement_1234567890abcdef",
      "activityType": "VIEW",
      "targetType": "POEM",
      "targetId": 123,
      "durationSeconds": 45,
      "sessionId": "session_abc123",
      "deviceType": "mobile",
      "metadata": "{\"source\": \"recommendation\"}",
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### 3. Get Top Engaged Content
**Endpoint:** `GET /api/profile/engagement/top/{targetType}`
**Description:** Get user's most engaged content by type
**Authentication:** Required

**Query Parameters:**
- `days` (default: 30) - Number of days to look back

**Example:** `GET /api/profile/engagement/top/POEM?days=30`

**Response:**
```json
{
  "success": true,
  "message": "Top engaged content retrieved successfully",
  "data": [
    [123, 450], // [targetId, totalEngagementSeconds]
    [124, 380],
    [125, 290]
  ]
}
```

---

## Error Responses

All endpoints may return error responses with the following structure:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Invalid request parameters",
  "data": null,
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/categories"
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "Authentication required",
  "data": null,
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/profile"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Resource not found",
  "data": null,
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/categories/invalid-id"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Internal server error",
  "data": null,
  "timestamp": "2024-01-15T10:30:00Z",
  "path": "/api/categories"
}
```

---

## Data Models

### InterestType Enum
- `CATEGORY` - Interest in a poetry category
- `POET` - Interest in a specific poet

### ActivityType Enum
- `VIEW` - Viewing content
- `LIKE` - Liking content
- `SHARE` - Sharing content
- `BOOKMARK` - Bookmarking content

### TargetType Enum
- `POEM` - Poetry content
- `POET` - Poet profile
- `CATEGORY` - Poetry category

### AuthProvider Enum
- `GOOGLE` - Google OAuth provider
- `LOCAL` - Local email/password authentication

---

## Notes for Frontend Development

### Authentication & Security
1. **Token Storage**: Store JWT tokens securely (use secure storage mechanisms, not localStorage or plain text)
2. **Token Inclusion**: Include access token in `Authorization: Bearer <token>` header for all authenticated requests
3. **Token Refresh**: Implement automatic token refresh on 401 responses to improve user experience
4. **Logout Cleanup**: Always clear stored tokens on logout, even if API call fails
5. **HTTPS Only**: Use HTTPS in production to prevent token interception

### API Best Practices
6. **Error Handling**: Always check the `success` field in responses and handle errors appropriately
7. **401 Handling**: On 401 responses, attempt token refresh before redirecting to login
8. **Public IDs**: Use `publicId` fields for all API calls instead of internal `id` fields
9. **Pagination**: Use the pagination metadata (`totalPages`, `totalElements`) to implement proper pagination UI
10. **Search**: Implement debounced search to avoid excessive API calls

### Performance & UX
11. **Caching**: Consider caching categories and poets data as they don't change frequently
12. **Loading States**: Show appropriate loading indicators during API calls
13. **Offline Support**: Consider implementing offline caching for better user experience
14. **Rate Limiting**: Be mindful of API rate limits and implement appropriate retry logic
15. **Interest Management**: Strength values range from 0.0 to 1.0, where 1.0 indicates highest interest

### OAuth Flow for Mobile
16. **WebView vs Browser**: Choose between in-app WebView or external browser for OAuth flow
17. **Deep Links**: Configure deep links/custom URL schemes to handle OAuth callback
18. **Callback Handling**: Extract `access_token` and `refresh_token` from callback URL query parameters
19. **Redirect URI**: Configure backend's `app.oauth2.authorizedRedirectUri` to match your mobile app's callback URL

## Data Population

The backend automatically populates initial data on startup:
- **58 Categories** including main categories and subcategories for Urdu poetry
- **24 Famous Urdu Poets** from classical to contemporary era
- Categories are hierarchical with parent-child relationships
- Poets include biographical information and time periods