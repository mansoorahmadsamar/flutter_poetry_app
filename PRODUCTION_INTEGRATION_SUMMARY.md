# Production Backend Integration Summary

## Changes Made

### 1. Updated Production Configuration
**File:** [lib/core/config/app_config.dart](lib/core/config/app_config.dart#L75-L88)

### 2. Added SSL Certificate Handling
**File:** [lib/core/network/dio_client.dart](lib/core/network/dio_client.dart#L29-L40)

### 3. Fixed Authentication Endpoint URLs
**File:** [lib/core/auth/firebase_auth_service.dart](lib/core/auth/firebase_auth_service.dart)
- Removed duplicate `/api/` from authentication endpoints
- Changed `/api/auth/*` to `/auth/*` (base URL already includes `/api`)

Updated the production environment configuration to point to the deployed backend:

```dart
factory AppConfig.prod() {
  return const AppConfig._(
    environment: AppEnvironment.prod,
    appName: 'Poetry',
    baseApiUrl: 'https://134.199.243.167/api',  // Updated to production server
    apiTimeout: 30000,
    feedTTL: 900, // 15 minutes
    poemTTL: 7200, // 2 hours
    enableLogging: false,
    enableAnalytics: true,
    googleOAuthRedirectUri: 'https://134.199.243.167/auth/callback',
    googleWebClientId: '461228119902-ofi032jvtvsqrenp0349rs06rahfpkru.apps.googleusercontent.com',
  );
}
```

**Key Changes:**
- `baseApiUrl`: Changed from `'https://api.poetry.app'` to `'https://134.199.243.167'`
- `googleOAuthRedirectUri`: Updated to match production server
- `googleWebClientId`: Added the Web Client ID for Firebase authentication
- Service paths include `/api/` prefix (e.g., `/api/poems`, `/api/search`)

**SSL Certificate Handling:**
```dart
// In DioClient constructor
if (appConfig.baseApiUrl.contains('134.199.243.167')) {
  (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (X509Certificate cert, String host, int port) {
      // Accept self-signed certificate for the production server
      return host == '134.199.243.167';
    };
    return client;
  };
}
```
This allows the app to connect to the production server which uses a self-signed SSL certificate.

## Configuration Details

### Environment Behavior
All environments now use the production server:
- **Debug Mode** → Development config with logging enabled → `https://134.199.243.167`
- **Release Mode** → Production config → `https://134.199.243.167`
- **Profile Mode** → Staging config → `https://stage-api.poetry.app` (not configured)

### API Endpoints
All API requests will now go through:
- **Base URL:** `https://134.199.243.167`
- **Service paths:** `/api/poems`, `/api/search`, `/api/auth`, etc.
- **Example:** `https://134.199.243.167` + `/api/poems` = `https://134.199.243.167/api/poems`

## Testing the Integration

### 1. Test in Debug Mode (Development - with logging)
```bash
flutter run
```
This will use the production server with logging enabled for debugging.

### 2. Test in Release Mode (Production - optimized)
```bash
# Android
flutter run --release

# iOS
flutter run --release
```
This will use the production server with logging disabled for performance.

### 3. Verify API Connectivity

Test these key endpoints once the app is running in release mode:

#### Health Check
```bash
curl https://134.199.243.167/api/health
```

#### Get Poems (Public)
```bash
curl https://134.199.243.167/api/poems?page=0&size=5
```

#### Search Couplets
```bash
curl "https://134.199.243.167/api/search/couplets?q=محبت&lang=ur&page=0&size=10"
```

### 4. Test User Authentication

The app uses Firebase Authentication. When testing:

1. **Login/Signup** should work with Firebase
2. **Authorization Header** will automatically include: `Bearer <firebase-id-token>`
3. **Bookmarks, Likes** and other authenticated features should work

## Network Architecture

```
Flutter App (Release Build)
    ↓
AppConfig.prod() → baseApiUrl: 'https://134.199.243.167/api'
    ↓
DioClient (with Auth & Logging Interceptors)
    ↓
Service Layer (SearchService, BookmarkService, etc.)
    ↓
Production Backend API (134.199.243.167)
```

## Important Notes

### SSL/TLS Considerations
The production server uses HTTPS with a self-signed SSL certificate at IP address 134.199.243.167.

**Current Configuration:**
- ✅ The app is configured to accept the self-signed certificate for `134.199.243.167`
- ✅ SSL validation is bypassed only for this specific host
- ⚠️ This is acceptable for development/testing but not recommended for final production

**For Future Production:**
1. Obtain a proper domain name (e.g., `api.poetry.app`)
2. Install a valid SSL certificate (Let's Encrypt or commercial CA)
3. Remove the `badCertificateCallback` code from DioClient
4. Update `baseApiUrl` to use the domain name

### Firebase Configuration
Make sure Firebase is properly configured for the production environment:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

### API Authentication Flow
1. User authenticates via Firebase (Google Sign-In)
2. Firebase returns an ID token
3. `AuthInterceptor` automatically adds the token to all API requests
4. Backend validates the Firebase token

## What Works Out of the Box

All existing features should work with the production backend:

✅ **Search & Discovery**
- Couplet search with filters
- Autocomplete suggestions
- Trending searches
- Poet discovery

✅ **User Engagement**
- Bookmarks (couplets & poets)
- Likes
- User profile

✅ **Content Browsing**
- Browse poems by poet
- View poet profiles
- Category filtering
- Language preferences

## Troubleshooting

### Issue: Network Error / Connection Refused
**Solution:** Verify the backend is running:
```bash
curl https://134.199.243.167/api/health
```

### Issue: 401 Unauthorized
**Solution:**
1. Check Firebase authentication is working
2. Verify the Firebase ID token is being sent
3. Check backend logs for authentication errors

### Issue: SSL Certificate Error
**Solution:**
1. Verify the production server has a valid SSL certificate
2. Check nginx SSL configuration on the production server

### Issue: CORS Error (Web Platform)
**Solution:**
Backend CORS should be configured to allow requests. Check nginx CORS headers.

## Next Steps

1. **Build & Test Release Version**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

2. **Test All Features**
   - Authentication (Login/Signup)
   - Search & Discovery
   - Bookmarks
   - Likes
   - User Profile

3. **Monitor Production**
   - Check backend logs: `docker logs -f poetry-backend`
   - Monitor API health: `https://134.199.243.167/actuator/health`

4. **Update for Production Domain (Future)**
   When you have a domain name:
   ```dart
   baseApiUrl: 'https://api.yourdomain.com'
   ```

## Reference Documentation

- **Production Backend Guide:** [PRODUCTION_USAGE_GUIDE.md](PRODUCTION_USAGE_GUIDE.md)
- **API Documentation:** `FLUTTER_API_DOCUMENTATION.md`
- **Search API:** `TEMPLATE_SEARCH_API_GUIDE.md`
- **Couplet API:** `COUPLET_API_DOCUMENTATION.md`

---

**Integration Date:** 2026-01-14
**Production Server:** 134.199.243.167
**Status:** ✅ Ready for Testing
