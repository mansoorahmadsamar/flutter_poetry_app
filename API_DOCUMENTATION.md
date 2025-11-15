# Poetry Backend API Documentation

## Base URL

**Development:**
- Web Browser: `http://localhost:8080`
- Android Emulator: `http://10.0.2.2:8080`
- Real Device (same network): `http://YOUR_LOCAL_IP:8080`

**Production:** `https://your-api-domain.com`

---

## Authentication System

### Overview

The Poetry Backend supports **TWO DIFFERENT authentication mechanisms**:

| Platform | Method | Endpoint |
|----------|--------|----------|
| **Web Apps** | OAuth redirect flow | `GET /oauth2/authorization/google` |
| **Mobile Apps** | Native Google Sign-In + API call | `POST /api/auth/google/android` |

**📖 For detailed flow diagrams and architecture:** See [`AUTH_ARCHITECTURE.md`](./AUTH_ARCHITECTURE.md)

### Quick Summary

**Web Apps:**
1. Redirect user to `/oauth2/authorization/google`
2. Google handles authentication
3. Backend redirects to your web app with tokens in URL

**Mobile Apps (Android/iOS):**
1. Use native Google Sign-In SDK (e.g., `google_sign_in` in Flutter)
2. Get ID token from Google
3. POST ID token to `/api/auth/google/android`
4. Backend returns JWT tokens

**Why two different approaches?** Mobile apps can't reliably use redirect-based OAuth (Google blocks private IPs). Native sign-in provides better UX and works on emulators.

### Using Access Tokens

Once authenticated (via either method), all protected endpoints require:

```
Authorization: Bearer <access-token>
```

### Token Lifecycle

1. **Authentication** → Receive access token + refresh token
2. **API Calls** → Include access token in `Authorization` header
3. **Token Expires** → Use refresh token to get new tokens (`POST /api/auth/refresh`)
4. **Logout** → Revoke refresh tokens (`POST /api/auth/logout`)

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

### 1A. Web App Authentication - Google Login
**Endpoint:** `GET /oauth2/authorization/google`

**Description:** Initiates Google OAuth2 flow for **WEB applications only**. For mobile apps, use endpoint 1B below.

**Platform:** Web browsers only

**Authentication:** Not required

**How it works:**
1. Navigate to this URL in browser
2. Backend redirects to Google's authentication page
3. User authenticates with Google
4. Google redirects back to backend
5. Backend creates/updates user in database
6. Backend generates JWT tokens
7. Backend redirects to web app with tokens in URL

**Redirect URL (after authentication):**
```
http://localhost:3000/auth/callback?access_token={jwt}&refresh_token={jwt}
```

**Query Parameters:**
| Parameter | Type | Description |
|-----------|------|-------------|
| `access_token` | String (JWT) | Access token (expires in 1 hour) |
| `refresh_token` | String (JWT) | Refresh token (expires in 7 days) |

**Configuration:**
```yaml
app:
  oauth2:
    webRedirectUri: http://localhost:3000/auth/callback
```

**Example (React/Next.js):**
```javascript
// Redirect to OAuth
window.location.href = 'http://localhost:8080/oauth2/authorization/google';

// Handle callback
const { access_token, refresh_token } = router.query;
// Store tokens and navigate to dashboard
```

---

### 1B. Mobile App Authentication - Google Sign-In (Android/iOS)
**Endpoint:** `POST /api/auth/google/android`

**Description:** Authenticates mobile users via native Google Sign-In. Works for both Android and iOS.

**Platform:** Mobile apps (Android/iOS)

**Authentication:** Not required

**Request Body:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6...",
  "deviceType": "android"
}
```

**Request Body Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `idToken` | String | Yes | ID token from Google Sign-In SDK |
| `deviceType` | String | No | "android" or "ios" |

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Authentication successful",
  "data": {
    "accessToken": "eyJhbGciOiJIUzUxMiJ9...",
    "refreshToken": "eyJhbGciOiJIUzUxMiJ9...",
    "type": "Bearer",
    "publicId": "user_abc123",
    "username": "johndoe",
    "email": "john@example.com",
    "fullName": "John Doe",
    "profileImageUrl": "https://..."
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Invalid Google ID token",
  "data": null
}
```

**How it works:**
1. Use native Google Sign-In SDK in your app
2. Get ID token from Google
3. Send ID token to this endpoint
4. Backend verifies token with Google
5. Backend creates/updates user
6. Backend returns JWT tokens
7. Store tokens securely in app

**Example (Flutter):**
```dart
// 1. Sign in with Google
final account = await GoogleSignIn().signIn();
final auth = await account!.authentication;

// 2. Send ID token to backend
final response = await http.post(
  Uri.parse('http://10.0.2.2:8080/api/auth/google/android'),
  body: jsonEncode({'idToken': auth.idToken}),
);

// 3. Store tokens
final tokens = jsonDecode(response.body)['data'];
await storage.write(key: 'access_token', value: tokens['accessToken']);
```

**Configuration Required:**
1. Create Android/iOS OAuth client in Google Cloud Console
2. Get SHA-1 fingerprint (Android) or Bundle ID (iOS)
3. Configure in `application.yaml`:
```yaml
app:
  google:
    android-client-id: "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com"
```

**📖 For complete implementation guide:** See [`FLUTTER_ANDROID_AUTH_GUIDE.md`](./FLUTTER_ANDROID_AUTH_GUIDE.md)

---

### Why Two Different Endpoints?

| Aspect | Web (1A) | Mobile (1B) |
|--------|----------|-------------|
| **Method** | Browser redirect | API call |
| **Token delivery** | URL parameters | JSON response |
| **Works on emulator?** | Yes | Yes |
| **Google client type** | Web application | Android/iOS |
| **User experience** | Browser-based | Native picker |

---

**User Data Collected from Google (both methods):**
- Email address (required)
- Full name
- Google ID
- Profile image URL

**User Creation/Update Logic (both methods):**
- If user doesn't exist: Creates new user account
- If user exists: Updates profile image if changed
- Username auto-generated from email
- Provider set to "google"

---

#### Overview
The backend intelligently supports both **web and mobile apps** with a single OAuth configuration. It automatically detects the platform and redirects accordingly.

#### How Platform Detection Works

The backend uses a **session-based approach** to preserve the platform parameter through the OAuth flow:

1. **Platform Parameter Capture**
   - When you initiate OAuth with `?platform=mobile` or `?platform=web`
   - Backend stores the platform in the session via `OAuth2PlatformCaptureFilter`

2. **OAuth Flow**
   - User authenticates with Google
   - Google redirects back to backend
   - Backend retrieves platform from session

3. **Platform-Based Redirect**
   - If `platform=mobile` → redirects to `poetry://app/auth/callback`
   - If `platform=web` → redirects to `http://localhost:3000/auth/callback`
   - If no platform specified → defaults to web redirect

**Usage:**
```bash
# Force mobile redirect
GET /oauth2/authorization/google?platform=mobile

# Force web redirect
GET /oauth2/authorization/google?platform=web

# Default (web redirect)
GET /oauth2/authorization/google
```

#### Backend Configuration

**application.yaml:**
```yaml
app:
  oauth2:
    # Multiple redirect URIs separated by comma
    authorizedRedirectUris: poetry://app/auth/callback,http://localhost:3000/auth/callback
```

**Environment Variable (Optional):**
```bash
export AUTHORIZED_REDIRECT_URIS="poetry://app/auth/callback,http://localhost:3000/auth/callback,https://yourdomain.com/auth/callback"
```

#### Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│          User Clicks "Sign in with Google"                   │
└────────────────────────┬─────────────────────────────────────┘
                         │
                         ▼
           ┌─────────────────────────────┐
           │   Platform Detection         │
           │   1. Check ?platform param   │
           │   2. Check User-Agent        │
           │   3. Default to web          │
           └─────────────┬───────────────┘
                         │
           ┌─────────────┴──────────────┐
           │                            │
           ▼                            ▼
     ┌──────────┐               ┌──────────────┐
     │  Mobile  │               │     Web      │
     └────┬─────┘               └──────┬───────┘
          │                            │
          ▼                            ▼
poetry://app/auth/callback    http://localhost:3000/auth/callback
?access_token=xxx             ?access_token=xxx
&refresh_token=yyy            &refresh_token=yyy
```

#### Mobile App Integration (Flutter Example)

**Important: Android Emulator Setup**

When testing on Android emulator, you MUST use `10.0.2.2` instead of `localhost` to reach your backend:
- ✅ Use: `http://10.0.2.2:8080/oauth2/authorization/google?platform=mobile`
- ❌ Don't use: `http://localhost:8080/oauth2/authorization/google?platform=mobile`
- Reason: `localhost` on emulator refers to the emulator itself, not your host machine
- Add `http://10.0.2.2:8080/login/oauth2/code/google` to Google Cloud Console redirect URIs

For real Android devices on the same network:
- Use your computer's local IP (e.g., `http://192.168.1.100:8080`)
- Find your IP: `ipconfig` (Windows) or `ifconfig` (Mac/Linux)

**1. Configure Deep Links**

**Android (AndroidManifest.xml):**
```xml
<activity android:name=".MainActivity">
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data android:scheme="poetry" android:host="app" />
    </intent-filter>
</activity>
```

**iOS (Info.plist):**
```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>poetry</string>
        </array>
    </dict>
</array>
```

**2. Flutter Code Implementation**

```dart
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final storage = FlutterSecureStorage();

  // Backend URL configuration
  // For Android Emulator: Use 10.0.2.2
  // For Real Device: Use your computer's local IP (e.g., 192.168.1.100)
  // For Production: Use your actual domain
  static const String backendUrl = 'http://10.0.2.2:8080'; // Android Emulator
  // static const String backendUrl = 'http://192.168.1.100:8080'; // Real Device
  // static const String backendUrl = 'https://api.yourdomain.com'; // Production

  // Initialize deep link listener
  void initDeepLinkListener() {
    uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.scheme == 'poetry') {
        _handleAuthCallback(uri);
      }
    });
  }

  // Start OAuth flow
  Future<void> signInWithGoogle() async {
    final authUrl = '$backendUrl/oauth2/authorization/google?platform=mobile';

    if (await canLaunch(authUrl)) {
      await launch(authUrl, forceSafariVC: false, forceWebView: false);
    }
  }

  // Handle auth callback
  void _handleAuthCallback(Uri uri) {
    final accessToken = uri.queryParameters['access_token'];
    final refreshToken = uri.queryParameters['refresh_token'];

    if (accessToken != null && refreshToken != null) {
      // Store tokens securely
      storage.write(key: 'access_token', value: accessToken);
      storage.write(key: 'refresh_token', value: refreshToken);

      // Navigate to main screen
      navigatorKey.currentState?.pushReplacementNamed('/home');
    }
  }
}
```

**3. Test Deep Link Manually**

```bash
# Android
adb shell am start -W -a android.intent.action.VIEW \
  -d "poetry://app/auth/callback?access_token=test&refresh_token=test"

# iOS Simulator
xcrun simctl openurl booted \
  "poetry://app/auth/callback?access_token=test&refresh_token=test"
```

#### Web App Integration (React/Next.js Example)

**1. Create Auth Callback Page**

```typescript
// pages/auth/callback.tsx (Next.js)
import { useEffect } from 'react';
import { useRouter } from 'next/router';

export default function AuthCallback() {
  const router = useRouter();

  useEffect(() => {
    const { access_token, refresh_token } = router.query;

    if (access_token && refresh_token) {
      // Store tokens (use httpOnly cookies in production)
      localStorage.setItem('access_token', access_token as string);
      localStorage.setItem('refresh_token', refresh_token as string);

      // Redirect to home
      router.push('/');
    } else {
      // Handle error
      router.push('/login?error=auth_failed');
    }
  }, [router.query]);

  return <div>Authenticating...</div>;
}
```

**2. Initiate OAuth**

```typescript
// components/GoogleLoginButton.tsx
export function GoogleLoginButton() {
  const handleLogin = () => {
    window.location.href = 'http://localhost:8080/oauth2/authorization/google?platform=web';
  };

  return (
    <button onClick={handleLogin}>
      Sign in with Google
    </button>
  );
}
```

#### Google Cloud Console Configuration

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Navigate to: **APIs & Services** > **Credentials**
4. Click on your OAuth 2.0 Client ID
5. Add **Authorized redirect URIs**:
   ```
   http://localhost:8080/login/oauth2/code/google
   http://10.0.2.2:8080/login/oauth2/code/google
   https://your-production-domain.com/login/oauth2/code/google
   ```

**Important for Android Emulator:**
- `localhost:8080` works for web browsers running on the same machine as the backend
- `10.0.2.2:8080` is required for Android emulators - this special IP routes to the host machine
- When testing on Android emulator, use: `http://10.0.2.2:8080/oauth2/authorization/google?platform=mobile`

**Note:** You don't need to add `poetry://` or `http://localhost:3000/auth/callback` to Google's redirect URIs. Those are your app's callback URLs after the backend processes the OAuth response.

#### Troubleshooting

**Issue: Backend still redirects to localhost**
- Check `app.oauth2.authorizedRedirectUris` in application.yaml
- Restart backend after configuration changes
- Verify logs show correct redirect URI

**Issue: Mobile app doesn't receive deep link**
- Verify deep link configuration in AndroidManifest.xml / Info.plist
- Test deep link manually using adb/xcrun commands
- Check that app is in foreground when redirect happens
- Ensure scheme is `poetry://` not `https://`

**Issue: Tokens not being stored**
- Check Flutter logs for deep link reception
- Verify token extraction from query parameters
- Use Flutter Secure Storage for secure token storage

**Issue: "Invalid redirect URI" error**
- Ensure Google Cloud Console has correct backend redirect URIs
- Backend redirect URIs must match exactly (including protocol and port)
- Mobile deep link URIs don't need to be in Google Console

#### Security Best Practices

1. **Token Storage**
   - Mobile: Use Flutter Secure Storage or iOS Keychain/Android Keystore
   - Web: Use httpOnly cookies in production (not localStorage)

2. **HTTPS in Production**
   - Always use HTTPS for backend in production
   - Update redirect URIs to use `https://`

3. **Token Validation**
   - Validate tokens on every request
   - Implement token refresh logic for expired tokens

4. **Deep Link Validation**
   - Validate deep link origin in mobile app
   - Only process links from trusted domains

#### Testing OAuth Flow

**Mobile App Test:**
```bash
# 1. Start backend
./mvnw spring-boot:run

# 2. Run Flutter app
flutter run

# 3. Tap "Sign in with Google"
# 4. Select Google account
# 5. Backend should redirect to: poetry://app/auth/callback?...
# 6. App intercepts deep link and stores tokens
# 7. App navigates to home screen
```

**Web App Test:**
```bash
# 1. Start backend
./mvnw spring-boot:run

# 2. Start Next.js app
npm run dev

# 3. Click "Sign in with Google"
# 4. Select Google account
# 5. Backend redirects to: http://localhost:3000/auth/callback?...
# 6. Page extracts and stores tokens
# 7. Redirects to home page
```

#### Production Configuration

**Backend (application.yaml):**
```yaml
app:
  oauth2:
    authorizedRedirectUris: poetry://app/auth/callback,https://yourdomain.com/auth/callback
```

**Environment Variable:**
```bash
export AUTHORIZED_REDIRECT_URIS="poetry://app/auth/callback,https://yourdomain.com/auth/callback"
```

**Google Cloud Console:**
- Add production backend URL to authorized redirect URIs
- Example: `https://api.yourdomain.com/login/oauth2/code/google`

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

## Poems API

### 1. Upload Poem
**Endpoint:** `POST /api/poems/upload`
**Description:** Upload a new poem/content to the platform
**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <your-access-token>
Content-Type: application/json
```

**Request Body:**
```json
{
  "title": "محبت کی راہیں",
  "poetId": "poet_1234567890abcdef",
  "categoryId": "cat_2345678901bcdefg",
  "contentText": "دل کی دھڑکن میں بسا ہے پیار تیرا\nآنکھوں میں سجا ہے خمار تیرا",
  "tags": ["محبت", "رومانس", "غزل"],
  "form": "Ghazal",
  "yearWritten": 2024,
  "source": "Original Composition",
  "language": "ur",
  "script": "arabic",
  "license": "public_domain",
  "isPublic": true
}
```

**Request Body Fields:**
| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `title` | String | Yes | Poem title (max 500 characters) |
| `poetId` | String | Yes | Public ID of the poet |
| `categoryId` | String | Yes | Public ID of the category |
| `contentText` | String | Yes | Full text of the poem |
| `tags` | Array<String> | Yes | Tags for the poem (min 1 tag) |
| `form` | String | No | Poetic form (e.g., "Ghazal", "Nazm") |
| `yearWritten` | Integer | No | Year the poem was written |
| `source` | String | No | Source/origin of the poem |
| `language` | String | No | Language code (default: "ur") |
| `script` | String | No | Script type (default: "arabic") |
| `license` | String | No | License type (default: "public_domain") |
| `isPublic` | Boolean | No | Public visibility (default: true) |

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "Content uploaded successfully",
  "data": {
    "id": 1,
    "publicId": "poem_1234567890abcdef",
    "title": "محبت کی راہیں",
    "content": "دل کی دھڑکن میں بسا ہے پیار تیرا\nآنکھوں میں سجا ہے خمار تیرا",
    "poet": {
      "id": 1,
      "publicId": "poet_1234567890abcdef",
      "name": "Mirza Ghalib"
    },
    "category": {
      "id": 2,
      "publicId": "cat_2345678901bcdefg",
      "name": "Ghazal"
    },
    "tags": [
      {
        "id": 1,
        "name": "محبت",
        "slug": "محبت"
      },
      {
        "id": 2,
        "name": "رومانس",
        "slug": "رومانس"
      }
    ],
    "uploadedBy": {
      "id": 1,
      "publicId": "user_1234567890abcdef",
      "username": "johndoe"
    },
    "form": "Ghazal",
    "yearWritten": 2024,
    "source": "Original Composition",
    "language": "ur",
    "script": "arabic",
    "license": "public_domain",
    "isPublic": true,
    "viewCount": 0,
    "likeCount": 0,
    "isFeatured": false,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

**Error Responses:**

**400 Bad Request:**
```json
{
  "success": false,
  "message": "Poet not found with ID: poet_invalid123",
  "data": null
}
```
*Causes:*
- Invalid poet ID
- Invalid category ID
- Missing required fields
- Validation errors (e.g., title too long, no tags provided)

**401 Unauthorized:**
```json
{
  "success": false,
  "message": "User not authenticated",
  "data": null
}
```

**Important Notes:**
1. **Tag Management**: Tags are automatically created if they don't exist
2. **User Association**: The poem is automatically associated with the authenticated user
3. **Validation**: All required fields must be provided and meet validation criteria
4. **Visibility**: Use `isPublic: false` for draft poems

---

### 2. Get All Poems
**Endpoint:** `GET /api/poems`
**Description:** Retrieve all public poems with pagination and sorting
**Authentication:** Not required

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Page number (0-indexed) |
| `size` | Integer | 10 | Number of items per page |
| `sortBy` | String | createdAt | Field to sort by (createdAt, viewCount, likeCount, title) |
| `sortDir` | String | desc | Sort direction (asc or desc) |

**Example:** `GET /api/poems?page=0&size=10&sortBy=viewCount&sortDir=desc`

**Response:**
```json
{
  "success": true,
  "message": "Poems retrieved successfully",
  "data": {
    "content": [
      {
        "id": 1,
        "publicId": "poem_1234567890abcdef",
        "title": "محبت کی راہیں",
        "content": "دل کی دھڑکن میں بسا ہے پیار تیرا...",
        "poet": {
          "id": 1,
          "publicId": "poet_1234567890abcdef",
          "name": "Mirza Ghalib"
        },
        "category": {
          "id": 2,
          "publicId": "cat_2345678901bcdefg",
          "name": "Ghazal"
        },
        "viewCount": 1523,
        "likeCount": 245,
        "language": "ur",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "totalElements": 150,
    "totalPages": 15,
    "number": 0,
    "size": 10,
    "first": true,
    "last": false
  }
}
```

---

### 3. Get Poem by ID
**Endpoint:** `GET /api/poems/{publicId}`
**Description:** Retrieve a specific poem by its public ID. Automatically increments view count.
**Authentication:** Not required

**Response:**
```json
{
  "success": true,
  "message": "Poem retrieved successfully",
  "data": {
    "id": 1,
    "publicId": "poem_1234567890abcdef",
    "title": "محبت کی راہیں",
    "content": "دل کی دھڑکن میں بسا ہے پیار تیرا\nآنکھوں میں سجا ہے خمار تیرا",
    "poet": {
      "id": 1,
      "publicId": "poet_1234567890abcdef",
      "name": "Mirza Ghalib",
      "birthYear": 1797,
      "deathYear": 1869
    },
    "category": {
      "id": 2,
      "publicId": "cat_2345678901bcdefg",
      "name": "Ghazal",
      "slug": "ghazal"
    },
    "tags": [
      {
        "id": 1,
        "name": "محبت",
        "slug": "محبت"
      }
    ],
    "uploadedBy": {
      "id": 1,
      "publicId": "user_1234567890abcdef",
      "username": "johndoe"
    },
    "form": "Ghazal",
    "yearWritten": 2024,
    "source": "Original Composition",
    "language": "ur",
    "script": "arabic",
    "license": "public_domain",
    "viewCount": 1524,
    "likeCount": 245,
    "isFeatured": false,
    "isPublic": true,
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-15T10:30:00Z"
  }
}
```

**404 Not Found:**
```json
{
  "success": false,
  "message": "Poem not found",
  "data": null
}
```

---

### 4. Search Poems
**Endpoint:** `GET /api/poems/search`
**Description:** Search poems by title or content
**Authentication:** Not required

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | String | Yes | Search term |
| `language` | String | No | Filter by language code |
| `page` | Integer | No | Page number (default: 0) |
| `size` | Integer | No | Items per page (default: 10) |

**Example:** `GET /api/poems/search?query=محبت&language=ur&page=0&size=10`

**Response:** Same structure as Get All Poems

---

### 5. Get Featured Poems
**Endpoint:** `GET /api/poems/featured`
**Description:** Retrieve featured poems
**Authentication:** Not required

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Page number |
| `size` | Integer | 10 | Items per page |

**Example:** `GET /api/poems/featured?page=0&size=10`

**Response:** Same structure as Get All Poems

---

### 6. Get Poems by Poet
**Endpoint:** `GET /api/poems/poet/{poetPublicId}`
**Description:** Retrieve all poems by a specific poet
**Authentication:** Not required

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Page number |
| `size` | Integer | 10 | Items per page |

**Example:** `GET /api/poems/poet/poet_1234567890abcdef?page=0&size=10`

**Response:** Same structure as Get All Poems

**404 Not Found:**
```json
{
  "success": false,
  "message": "Poet not found",
  "data": null
}
```

---

### 7. Get Poems by Category
**Endpoint:** `GET /api/poems/category/{categoryPublicId}`
**Description:** Retrieve all poems in a specific category
**Authentication:** Not required

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Page number |
| `size` | Integer | 10 | Items per page |

**Example:** `GET /api/poems/category/cat_2345678901bcdefg?page=0&size=10`

**Response:** Same structure as Get All Poems

---

### 8. Get Poems by Language
**Endpoint:** `GET /api/poems/language/{language}`
**Description:** Retrieve all poems in a specific language
**Authentication:** Not required

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `page` | Integer | 0 | Page number |
| `size` | Integer | 10 | Items per page |

**Example:** `GET /api/poems/language/ur?page=0&size=10`

**Response:** Same structure as Get All Poems

---

### 9. Toggle Bookmark
**Endpoint:** `POST /api/poems/{publicId}/bookmark`
**Description:** Bookmark or unbookmark a poem
**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <your-access-token>
```

**Response:**
```json
{
  "success": true,
  "message": "Poem bookmarked successfully",
  "data": {
    "bookmarked": true
  }
}
```

**Response when removing bookmark:**
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

### 10. Toggle Like
**Endpoint:** `POST /api/poems/{publicId}/like`
**Description:** Like or unlike a poem. Automatically updates the poem's like count.
**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <your-access-token>
```

**Response:**
```json
{
  "success": true,
  "message": "Poem liked successfully",
  "data": {
    "liked": true
  }
}
```

**Response when removing like:**
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

### 11. Get Poem Status
**Endpoint:** `GET /api/poems/{publicId}/status`
**Description:** Check if the current user has bookmarked or liked a poem
**Authentication:** Required

**Request Headers:**
```
Authorization: Bearer <your-access-token>
```

**Response:**
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

---

## Complete CURL Commands for Testing

This section provides ready-to-use CURL commands for testing all API endpoints. Replace placeholders with actual values.

### Setup Variables (Optional - for easier testing)
```bash
# Set these variables for easier testing
export BASE_URL="http://localhost:8080"
export JWT_TOKEN="your_jwt_token_here"
export POET_ID="poet_public_id_here"
export CATEGORY_ID="category_public_id_here"
export POEM_ID="poem_public_id_here"
```

### Authentication Endpoints

#### 1. Initiate Google Login (Browser)
```bash
# Open in browser - for web app
open "http://localhost:8080/oauth2/authorization/google?platform=web"

# Open in browser - for mobile app
open "http://localhost:8080/oauth2/authorization/google?platform=mobile"
```

#### 2. Get Current User
```bash
curl -X GET http://localhost:8080/api/auth/me \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 3. Refresh Token
```bash
curl -X POST http://localhost:8080/api/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "your_refresh_token_here"
  }'
```

#### 4. Logout
```bash
curl -X POST http://localhost:8080/api/auth/logout \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "your_refresh_token_here"
  }'
```

---

### Poem Endpoints

#### 1. Upload Poem
```bash
curl -X POST http://localhost:8080/api/poems/upload \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -d '{
    "title": "محبت کی راہیں",
    "poetId": "'"${POET_ID}"'",
    "categoryId": "'"${CATEGORY_ID}"'",
    "contentText": "دل کی دھڑکن میں بسا ہے پیار تیرا\nآنکھوں میں سجا ہے خمار تیرا",
    "tags": ["محبت", "رومانس", "غزل"],
    "form": "Ghazal",
    "yearWritten": 2024,
    "source": "Original Composition",
    "language": "ur",
    "script": "arabic",
    "license": "public_domain",
    "isPublic": true
  }'
```

#### 2. Get All Poems
```bash
# Basic - get first page
curl -X GET "http://localhost:8080/api/poems?page=0&size=10"

# With sorting by view count
curl -X GET "http://localhost:8080/api/poems?page=0&size=10&sortBy=viewCount&sortDir=desc"

# With sorting by likes
curl -X GET "http://localhost:8080/api/poems?page=0&size=10&sortBy=likeCount&sortDir=desc"

# Get second page
curl -X GET "http://localhost:8080/api/poems?page=1&size=10&sortBy=createdAt&sortDir=desc"
```

#### 3. Get Poem by ID
```bash
curl -X GET "http://localhost:8080/api/poems/${POEM_ID}"
```

#### 4. Search Poems
```bash
# Basic search
curl -X GET "http://localhost:8080/api/poems/search?query=محبت&page=0&size=10"

# Search with language filter
curl -X GET "http://localhost:8080/api/poems/search?query=love&language=ur&page=0&size=10"

# URL encoded search (for special characters)
curl -X GET "http://localhost:8080/api/poems/search?query=%D9%85%D8%AD%D8%A8%D8%AA&language=ur"
```

#### 5. Get Featured Poems
```bash
curl -X GET "http://localhost:8080/api/poems/featured?page=0&size=10"
```

#### 6. Get Poems by Poet
```bash
curl -X GET "http://localhost:8080/api/poems/poet/${POET_ID}?page=0&size=10"
```

#### 7. Get Poems by Category
```bash
curl -X GET "http://localhost:8080/api/poems/category/${CATEGORY_ID}?page=0&size=10"
```

#### 8. Get Poems by Language
```bash
# Urdu poems
curl -X GET "http://localhost:8080/api/poems/language/ur?page=0&size=10"

# English poems
curl -X GET "http://localhost:8080/api/poems/language/en?page=0&size=10"
```

#### 9. Toggle Bookmark
```bash
# Add/remove bookmark
curl -X POST "http://localhost:8080/api/poems/${POEM_ID}/bookmark" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 10. Toggle Like
```bash
# Add/remove like
curl -X POST "http://localhost:8080/api/poems/${POEM_ID}/like" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 11. Get Poem Status
```bash
# Check if bookmarked/liked
curl -X GET "http://localhost:8080/api/poems/${POEM_ID}/status" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

---

### Category Endpoints

#### 1. Get All Categories
```bash
curl -X GET "http://localhost:8080/api/categories"
```

#### 2. Get Root Categories Only
```bash
curl -X GET "http://localhost:8080/api/categories/root"
```

#### 3. Get Category by ID
```bash
curl -X GET "http://localhost:8080/api/categories/${CATEGORY_ID}"
```

#### 4. Get Category by Slug
```bash
# Example: Get "Ghazal" category
curl -X GET "http://localhost:8080/api/categories/slug/ghazal"
```

#### 5. Get Category Children
```bash
curl -X GET "http://localhost:8080/api/categories/${CATEGORY_ID}/children"
```

---

### Poet Endpoints

#### 1. Get All Poets
```bash
# Basic - get first page
curl -X GET "http://localhost:8080/api/poets?page=0&size=10"

# With sorting
curl -X GET "http://localhost:8080/api/poets?page=0&size=10&sortBy=name&sortDir=asc"

# Filter by language
curl -X GET "http://localhost:8080/api/poets?page=0&size=10&language=ur"
```

#### 2. Get Poet by ID
```bash
curl -X GET "http://localhost:8080/api/poets/${POET_ID}"
```

#### 3. Search Poets
```bash
# Search by name
curl -X GET "http://localhost:8080/api/poets/search?query=Ghalib&page=0&size=10"

# Search with language filter
curl -X GET "http://localhost:8080/api/poets/search?query=Iqbal&language=ur&page=0&size=10"
```

---

### Profile Endpoints

#### 1. Get Current User Profile
```bash
curl -X GET "http://localhost:8080/api/profile" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 2. Update Profile
```bash
curl -X PUT "http://localhost:8080/api/profile" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "profilePicture": "https://example.com/new-profile.jpg"
  }'
```

#### 3. Complete Onboarding
```bash
curl -X POST "http://localhost:8080/api/profile/complete-onboarding" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

---

### User Interests Endpoints

#### 1. Get User Interests
```bash
curl -X GET "http://localhost:8080/api/profile/interests" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 2. Get User Interests by Type
```bash
# Get category interests
curl -X GET "http://localhost:8080/api/profile/interests/CATEGORY" \
  -H "Authorization: Bearer ${JWT_TOKEN}"

# Get poet interests
curl -X GET "http://localhost:8080/api/profile/interests/POET" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 3. Add User Interest
```bash
curl -X POST "http://localhost:8080/api/profile/interests" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "interestType": "CATEGORY",
    "interestId": 2,
    "interestName": "Ghazal",
    "strength": 0.8,
    "explicitPreference": true
  }'
```

#### 4. Remove User Interest
```bash
# Remove category interest
curl -X DELETE "http://localhost:8080/api/profile/interests/CATEGORY/2" \
  -H "Authorization: Bearer ${JWT_TOKEN}"

# Remove poet interest
curl -X DELETE "http://localhost:8080/api/profile/interests/POET/1" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

---

### Engagement Tracking Endpoints

#### 1. Track Engagement
```bash
curl -X POST "http://localhost:8080/api/profile/engagement/track" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "activityType": "VIEW",
    "targetType": "POEM",
    "targetId": 123,
    "durationSeconds": 45,
    "sessionId": "session_abc123",
    "deviceType": "mobile",
    "metadata": "{\"source\": \"recommendation\"}"
  }'
```

#### 2. Get Recent Engagement
```bash
# Last 30 days (default)
curl -X GET "http://localhost:8080/api/profile/engagement/recent" \
  -H "Authorization: Bearer ${JWT_TOKEN}"

# Last 7 days
curl -X GET "http://localhost:8080/api/profile/engagement/recent?days=7" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

#### 3. Get Top Engaged Content
```bash
# Top engaged poems
curl -X GET "http://localhost:8080/api/profile/engagement/top/POEM?days=30" \
  -H "Authorization: Bearer ${JWT_TOKEN}"

# Top engaged poets
curl -X GET "http://localhost:8080/api/profile/engagement/top/POET?days=30" \
  -H "Authorization: Bearer ${JWT_TOKEN}"
```

---

## Testing Workflow Example

Here's a complete workflow to test the poem upload functionality:

### Step 1: Authenticate and Get Token
```bash
# 1. Open browser and authenticate
open "http://localhost:8080/oauth2/authorization/google?platform=web"

# 2. Extract access_token from callback URL
# URL will be: http://localhost:3000/auth/callback?access_token=xxx&refresh_token=yyy

# 3. Set the token
export JWT_TOKEN="your_extracted_access_token"
```

### Step 2: Get Available Poets and Categories
```bash
# Get poets
curl -X GET "http://localhost:8080/api/poets?page=0&size=5" | jq '.data.content[] | {publicId, name}'

# Get categories
curl -X GET "http://localhost:8080/api/categories" | jq '.data[] | {publicId, name}'

# Set the IDs
export POET_ID="poet_abc123"
export CATEGORY_ID="cat_xyz789"
```

### Step 3: Upload a Poem
```bash
curl -X POST "http://localhost:8080/api/poems/upload" \
  -H "Authorization: Bearer ${JWT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Poem",
    "poetId": "'"${POET_ID}"'",
    "categoryId": "'"${CATEGORY_ID}"'",
    "contentText": "This is a test poem content.",
    "tags": ["test", "demo"],
    "language": "en",
    "isPublic": true
  }' | jq '.'

# Save the returned poem ID
export POEM_ID="returned_poem_public_id"
```

### Step 4: Interact with the Poem
```bash
# View the poem
curl -X GET "http://localhost:8080/api/poems/${POEM_ID}" | jq '.'

# Like the poem
curl -X POST "http://localhost:8080/api/poems/${POEM_ID}/like" \
  -H "Authorization: Bearer ${JWT_TOKEN}" | jq '.'

# Bookmark the poem
curl -X POST "http://localhost:8080/api/poems/${POEM_ID}/bookmark" \
  -H "Authorization: Bearer ${JWT_TOKEN}" | jq '.'

# Check status
curl -X GET "http://localhost:8080/api/poems/${POEM_ID}/status" \
  -H "Authorization: Bearer ${JWT_TOKEN}" | jq '.'
```

### Step 5: Verify the Upload
```bash
# Search for your poem
curl -X GET "http://localhost:8080/api/poems/search?query=Test%20Poem" | jq '.'

# Get all poems (should include yours)
curl -X GET "http://localhost:8080/api/poems?page=0&size=10&sortBy=createdAt&sortDir=desc" | jq '.data.content[0]'
```

---

## Postman Collection

You can also import these as a Postman collection. Create a new collection with these environment variables:

**Environment Variables:**
```json
{
  "base_url": "http://localhost:8080",
  "jwt_token": "your_jwt_token",
  "poet_id": "poet_public_id",
  "category_id": "category_public_id",
  "poem_id": "poem_public_id"
}
```

Then use `{{base_url}}`, `{{jwt_token}}`, etc. in your requests.

---

## Quick Reference

### Common Status Codes
- `200 OK` - Successful GET/PUT/DELETE request
- `201 Created` - Successful POST request (resource created)
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Missing or invalid authentication token
- `403 Forbidden` - Authenticated but not authorized
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server-side error

### Authentication Header Format
```
Authorization: Bearer eyJhbGciOiJIUzUxMiJ9.eyJzdWIiOiJ1c2Vy...
```

### Common Query Parameters
- `page` - Page number (0-indexed)
- `size` - Items per page
- `sortBy` - Field to sort by
- `sortDir` - Sort direction (asc/desc)
- `query` - Search term
- `language` - Language filter code

---

## Troubleshooting Common Issues

### Issue: 401 Unauthorized
**Solution:**
1. Check if JWT token is valid and not expired
2. Use `/api/auth/refresh` to get new token
3. Ensure `Authorization: Bearer TOKEN` header is included

### Issue: 404 Not Found for Poem Upload
**Solution:**
1. Verify `poetId` exists: `curl http://localhost:8080/api/poets/{poetId}`
2. Verify `categoryId` exists: `curl http://localhost:8080/api/categories/{categoryId}`
3. Check request body has all required fields

### Issue: Empty Response from API
**Solution:**
1. Check if backend is running: `curl http://localhost:8080/actuator/health`
2. Verify correct port (default: 8080)
3. Check backend logs for errors

### Issue: CORS Error (Browser)
**Solution:**
Backend already has CORS enabled with `@CrossOrigin(origins = "*")`. If still getting errors:
1. Check browser console for specific error
2. Verify request includes correct headers
3. Try using Postman/CURL to isolate browser-specific issues

### Issue: Mobile OAuth "Site Cannot Be Reached"
**Problem:** After Google authentication, browser tries to navigate to `http://localhost:8080/login/oauth2/code/google` which fails on mobile devices or Android emulators.

**Root Cause:**
- On Android emulator: `localhost` refers to the emulator device itself, NOT your host machine
- The backend is running on your host machine at `localhost:8080`, but the emulator can't reach it
- Google redirects to `http://localhost:8080/login/oauth2/code/google`, which the emulator interprets as its own localhost

**Solution for Android Emulator:**

1. **Update Google Cloud Console:**
   - Add this redirect URI: `http://10.0.2.2:8080/login/oauth2/code/google`
   - `10.0.2.2` is the special IP that Android emulator uses to reach the host machine

2. **Update Your OAuth Initiation URL in Android App:**
   ```
   http://10.0.2.2:8080/oauth2/authorization/google?platform=mobile
   ```
   - Replace `localhost:8080` with `10.0.2.2:8080`
   - Keep the `?platform=mobile` parameter - this tells backend to redirect to `poetry://app/auth/callback`

3. **Expected Flow:**
   - Android app opens: `http://10.0.2.2:8080/oauth2/authorization/google?platform=mobile`
   - Backend redirects to Google for authentication
   - User authenticates with Google
   - Google redirects back to: `http://10.0.2.2:8080/login/oauth2/code/google?code=...`
   - Backend processes authentication and redirects to: `poetry://app/auth/callback?access_token=...&refresh_token=...`
   - Android app intercepts the deep link via intent filter

4. **Verify Your Android Intent Filter:**
   ```xml
   <intent-filter>
       <action android:name="android.intent.action.VIEW" />
       <category android:name="android.intent.category.DEFAULT" />
       <category android:name="android.intent.category.BROWSABLE" />
       <data android:scheme="poetry" android:host="app" />
   </intent-filter>
   ```

**Alternative Solutions:**

1. **For Real Android Device (not emulator):**
   - Find your computer's local IP address (e.g., `192.168.1.100`)
   - Use `http://192.168.1.100:8080/oauth2/authorization/google?platform=mobile`
   - Add `http://192.168.1.100:8080/login/oauth2/code/google` to Google Cloud Console
   - Ensure device and computer are on the same network

2. **For Production:**
   - Use your actual domain: `https://api.yourdomain.com`
   - Update redirect URIs accordingly
   - Use HTTPS instead of HTTP

**Debugging Steps:**

1. **Check backend logs** - Look for these log messages:
   ```
   === STEP 1: Initial OAuth Request ===
   Platform parameter: mobile
   ✓ Stored platform 'mobile' in session

   === STEP 2: OAuth Callback from Google ===
   Platform from session: mobile

   === STEP 3: OAuth2AuthenticationSuccessHandler ===
   Platform from session: mobile

   === STEP 4: Determining Redirect URI ===
   Configured redirectUris: poetry://app/auth/callback,http://localhost:3000/auth/callback
   ✓ Platform is 'mobile' - selecting mobile URI
   ✓ Selected redirect URI: poetry://app/auth/callback

   === STEP 5: Final Redirect ===
   >>> REDIRECTING NOW TO: poetry://app/auth/callback?access_token=...
   ```

2. **If platform is null or 'web'**:
   - Verify you're calling: `http://YOUR_IP:8080/oauth2/authorization/google?platform=mobile`
   - Use your computer's IP address (not localhost)
   - Example: `http://192.168.1.100:8080/oauth2/authorization/google?platform=mobile`

3. **If Session IDs don't match**:
   - Check that session persistence is enabled
   - Verify `SessionCreationPolicy.IF_REQUIRED` in SecurityConfig
   - Check for session cookie issues

4. **If mobile URI not found**:
   - Verify application.yaml has: `authorizedRedirectUris: poetry://app/auth/callback,http://localhost:3000/auth/callback`
   - Restart backend after config changes

---

## Production Deployment Notes

Before deploying to production:

1. **Update Configuration:**
   ```yaml
   app:
     oauth2:
       authorizedRedirectUris: poetry://app/auth/callback,https://yourdomain.com/auth/callback
   ```

2. **Update Google Cloud Console:**
   - Add production redirect URI: `https://api.yourdomain.com/login/oauth2/code/google`

3. **Enable HTTPS:**
   - All endpoints should use HTTPS in production
   - Update frontend to use HTTPS URLs

4. **Security:**
   - Change JWT secret in production
   - Use environment variables for sensitive data
   - Enable rate limiting
   - Implement request validation

5. **Database:**
   - Update database connection for production
   - Enable connection pooling
   - Set up backups

6. **Monitoring:**
   - Enable actuator endpoints: `/actuator/health`, `/actuator/metrics`
   - Set up logging
   - Configure alerts

---

**Last Updated:** 2025-11-13
**API Version:** 1.0