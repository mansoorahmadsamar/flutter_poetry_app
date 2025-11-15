# Authentication Architecture - Poetry Backend

## Overview

The Poetry Backend supports **TWO COMPLETELY DIFFERENT** authentication flows:

1. **Web Apps** - Browser-based OAuth redirect flow
2. **Mobile Apps (Android/iOS)** - Native Google Sign-In with backend verification

**Important:** These are separate mechanisms. Don't mix them!

---

## 🌐 Web Application Authentication

### How It Works

```
Browser → Backend OAuth URL → Google → Callback to Backend → Redirect to Web App with Tokens
```

### Flow Diagram

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Browser   │────────>│   Backend    │────────>│   Google    │
│   Web App   │         │    Server    │         │    OAuth    │
└─────────────┘         └──────────────┘         └─────────────┘
      │                        │                         │
      │  1. Navigate to        │                         │
      │  /oauth2/authorization/google                    │
      │─────────────────────>│                         │
      │                        │  2. Redirect to Google │
      │                        │───────────────────────>│
      │                        │                         │
      │  3. Google Login Page  │                         │
      │<────────────────────────────────────────────────│
      │                        │                         │
      │  4. User Authenticates │                         │
      │───────────────────────────────────────────────>│
      │                        │                         │
      │                        │  5. Auth Code          │
      │                        │<───────────────────────│
      │                        │                         │
      │                        │  6. Get User Info      │
      │                        │───────────────────────>│
      │                        │                         │
      │  7. Redirect to web app                         │
      │     with JWT tokens    │                         │
      │<───────────────────────│                         │
```

### Implementation

**Endpoint:** `GET /oauth2/authorization/google`

**Google Cloud Console Setup:**
- Client Type: **Web application**
- Authorized redirect URIs: `http://localhost:8080/login/oauth2/code/google`

**Backend Configuration (`application.yaml`):**
```yaml
spring:
  security:
    oauth2:
      client:
        registration:
          google:
            client-id: "YOUR_WEB_CLIENT_ID"
            client-secret: "YOUR_CLIENT_SECRET"
            redirect-uri: http://localhost:8080/login/oauth2/code/google

app:
  oauth2:
    webRedirectUri: http://localhost:3000/auth/callback
```

**Web App Code Example (React/Next.js):**

```typescript
// pages/login.tsx
export default function LoginPage() {
  const handleGoogleLogin = () => {
    // Redirect to backend OAuth endpoint
    window.location.href = 'http://localhost:8080/oauth2/authorization/google';
  };

  return <button onClick={handleGoogleLogin}>Sign in with Google</button>;
}

// pages/auth/callback.tsx
export default function AuthCallback() {
  const router = useRouter();

  useEffect(() => {
    const { access_token, refresh_token } = router.query;

    if (access_token && refresh_token) {
      // Store tokens (use httpOnly cookies in production!)
      localStorage.setItem('access_token', access_token as string);
      localStorage.setItem('refresh_token', refresh_token as string);

      router.push('/dashboard');
    }
  }, [router.query]);

  return <div>Authenticating...</div>;
}
```

---

## 📱 Mobile Application Authentication (Android & iOS)

### How It Works

```
Mobile App → Native Google Sign-In → Get ID Token → Send to Backend → Receive JWT Tokens
```

### Flow Diagram

```
┌─────────────┐                          ┌──────────────┐
│   Mobile    │                          │   Backend    │
│     App     │                          │    Server    │
└─────────────┘                          └──────────────┘
      │                                         │
      │  1. Trigger Google Sign-In (Native)    │
      │    Using Google Play Services           │
      │                                         │
      │  2. Google Account Picker               │
      │     (Native Android UI)                 │
      │                                         │
      │  3. Get ID Token from Google            │
      │                                         │
      │  4. POST /api/auth/google/android      │
      │     { "idToken": "..." }                │
      │────────────────────────────────────────>│
      │                                         │
      │                                         │  5. Verify ID Token
      │                                         │     with Google
      │                                         │
      │  6. Return JWT Tokens                  │
      │<────────────────────────────────────────│
      │     { "accessToken": "...",             │
      │       "refreshToken": "..." }           │
```

### Why Different from Web?

- ✅ **Works on Android Emulator** - No localhost/IP issues
- ✅ **Better UX** - Uses native Google account picker
- ✅ **More Secure** - Tokens never exposed in URLs
- ✅ **No Redirects** - Direct API call to backend
- ❌ **Google blocks private IPs** - Can't use redirect-based OAuth on mobile

### Implementation

**Endpoint:** `POST /api/auth/google/android`

**Request Body:**
```json
{
  "idToken": "eyJhbGciOiJSUzI1NiIsImtpZCI6...",
  "deviceType": "android"
}
```

**Response:**
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

**Google Cloud Console Setup:**
- Create NEW OAuth Client ID
- Client Type: **Android** (NOT Web application!)
- Package name: Your app's package name (e.g., `com.techhikes.poetry`)
- SHA-1 certificate fingerprint: Get from debug keystore

**Get SHA-1 Fingerprint:**
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android | grep SHA1
```

**Backend Configuration (`application.yaml`):**
```yaml
app:
  google:
    android-client-id: "YOUR_ANDROID_CLIENT_ID.apps.googleusercontent.com"
```

**Android/Flutter Code:**

See `FLUTTER_ANDROID_AUTH_GUIDE.md` for complete implementation.

**Quick Example:**
```dart
// Use google_sign_in package
final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

Future<void> signIn() async {
  final account = await _googleSignIn.signIn();
  final auth = await account!.authentication;
  final idToken = auth.idToken;

  // Send to backend
  final response = await http.post(
    Uri.parse('http://10.0.2.2:8080/api/auth/google/android'),
    body: jsonEncode({'idToken': idToken}),
  );

  final tokens = jsonDecode(response.body)['data'];
  // Store tokens securely
}
```

---

## iOS Authentication

**Same as Android!** Use the native approach:

1. Use `google-sign-in` iOS SDK
2. Get ID token
3. Send to `POST /api/auth/google/android` (yes, same endpoint!)
4. Receive JWT tokens

**Google Cloud Console Setup:**
- Create OAuth Client ID
- Client Type: **iOS**
- Bundle ID: Your app's bundle ID

---

## Comparison Table

| Feature | Web | Mobile (Android/iOS) |
|---------|-----|---------------------|
| **Flow Type** | Redirect-based OAuth | Native SDK + API call |
| **Endpoint** | `GET /oauth2/authorization/google` | `POST /api/auth/google/android` |
| **Google Client Type** | Web application | Android / iOS |
| **Works on Emulator?** | Yes (localhost) | Yes (`10.0.2.2`) |
| **Redirect URIs Needed?** | Yes | No |
| **Google Account Picker** | Browser-based | Native OS picker |
| **Token Delivery** | URL query params | API response body |
| **Code Complexity** | Simple redirect | Requires SDK setup |

---

## Common Questions

### Q: Can I use the web OAuth flow for mobile apps?
**A:** No. Google blocks redirects to private IPs (like `10.0.2.2`), so it won't work on emulators. Use the native approach.

### Q: Can mobile apps use `http://localhost:8080`?
**A:** No. On Android emulator, `localhost` refers to the emulator itself, not your host machine. Use `10.0.2.2:8080`.

### Q: Do I need both Web and Android client IDs?
**A:** Only if you have both web and mobile apps. If you're building only a mobile app, you only need the Android/iOS client ID.

### Q: What about iOS?
**A:** iOS uses the same backend endpoint (`POST /api/auth/google/android`). Just create an iOS OAuth client in Google Cloud Console and use the iOS Google Sign-In SDK.

### Q: Why are there two different flows?
**A:**
- **Web**: Browsers support redirects reliably, and `localhost` works fine
- **Mobile**: Native Google Sign-In provides better UX and avoids redirect limitations

---

## Security Notes

1. **Never hardcode client secrets** in mobile apps (they're decompilable)
2. **Web apps**: Use httpOnly cookies for tokens in production, not localStorage
3. **Mobile apps**: Use secure storage (Keychain/Keystore)
4. **Always use HTTPS** in production
5. **Validate tokens** on every backend request

---

## Quick Start Checklist

### For Web App:
- [ ] Create Web OAuth client in Google Cloud Console
- [ ] Add `http://localhost:8080/login/oauth2/code/google` to redirect URIs
- [ ] Configure `webRedirectUri` in application.yaml
- [ ] Redirect users to `/oauth2/authorization/google`
- [ ] Handle callback at your web app's callback URL

### For Mobile App:
- [ ] Create Android/iOS OAuth client in Google Cloud Console
- [ ] Get SHA-1 fingerprint (Android) or Bundle ID (iOS)
- [ ] Configure `android-client-id` in application.yaml
- [ ] Add `google_sign_in` dependency to Flutter/native app
- [ ] Implement native Google Sign-In
- [ ] Send ID token to `POST /api/auth/google/android`
- [ ] Store returned JWT tokens securely

---

For detailed implementation guides, see:
- `API_DOCUMENTATION.md` - Complete API reference
- `FLUTTER_ANDROID_AUTH_GUIDE.md` - Flutter/Android implementation
