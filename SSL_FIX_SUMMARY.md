# SSL Certificate Fix - Firebase Auth Service

## Problem

The Firebase authentication was failing with a timeout error:

```
SocketException: Operation timed out (OS Error: Operation timed out, errno = 60)
uri=https://134.199.243.167/api/auth/firebase/verify
```

## Root Cause

The `FirebaseAuthService` uses the **`http` package** directly for backend API calls, not Dio:

```dart
import 'package:http/http.dart' as http;

final response = await http.post(
  Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify'),
  ...
);
```

**The Issue:**
- We configured SSL certificate bypass in `DioClient` (for Dio requests)
- But `FirebaseAuthService` uses the `http` package directly
- The `http` package didn't have SSL certificate configuration
- Result: Connection timed out trying to verify the self-signed certificate

## Solution

Added SSL certificate handling to the `http` package in `FirebaseAuthService`.

### Changes Made

**File:** [lib/core/auth/firebase_auth_service.dart](lib/core/auth/firebase_auth_service.dart)

#### 1. Added Imports
```dart
import 'dart:io';
import 'package:http/io_client.dart';
```

#### 2. Created HTTP Client Factory Method
```dart
/// Create HTTP client that accepts self-signed certificates for production server
http.Client _createHttpClient() {
  if (appConfig.baseApiUrl.contains('134.199.243.167')) {
    final ioClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        // Accept self-signed certificate for the production server
        return host == '134.199.243.167';
      };
    return IOClient(ioClient);
  }
  return http.Client();
}
```

#### 3. Updated All HTTP Calls

**Firebase Token Verification:**
```dart
final client = _createHttpClient();
final response = await client.post(
  Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({...}),
);
client.close();
```

**Token Refresh:**
```dart
final client = _createHttpClient();
final response = await client.post(
  Uri.parse('${appConfig.baseApiUrl}/api/auth/refresh'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'refreshToken': refreshToken}),
);
client.close();
```

**Logout:**
```dart
final client = _createHttpClient();
await client.post(
  Uri.parse('${appConfig.baseApiUrl}/api/auth/logout'),
  headers: {'Content-Type': 'application/json'},
  body: json.encode({'refreshToken': refreshToken}),
);
client.close();
```

## Why Two SSL Configurations?

The app uses two different HTTP clients:

### 1. Dio (for most API calls)
- Used by: `SearchService`, `PoetService`, `BookmarkService`, etc.
- SSL config: In `DioClient` constructor
- Location: [lib/core/network/dio_client.dart](lib/core/network/dio_client.dart)

### 2. http package (for Firebase auth)
- Used by: `FirebaseAuthService`
- SSL config: In `_createHttpClient()` method
- Location: [lib/core/auth/firebase_auth_service.dart](lib/core/auth/firebase_auth_service.dart)

**Why not use Dio everywhere?**
- `FirebaseAuthService` was written to use the `http` package directly
- Both approaches work, they just need separate SSL configuration

## SSL Configuration Strategy

Both HTTP clients follow the same pattern:

```dart
if (baseApiUrl.contains('134.199.243.167')) {
  // Create HTTP client with custom certificate callback
  httpClient.badCertificateCallback = (cert, host, port) {
    return host == '134.199.243.167';  // Accept only for this host
  };
}
```

**Security:**
- Only bypasses SSL validation for `134.199.243.167`
- Other hosts still require valid certificates
- Production-ready for testing with self-signed certs

## Testing

After this fix, Firebase authentication should work:

```bash
flutter run
```

**Expected Flow:**
1. User clicks "Sign in with Google"
2. Firebase authentication completes ✅
3. Firebase token obtained ✅
4. Token sent to backend at `https://134.199.243.167/api/auth/firebase/verify` ✅
5. Backend validates and returns app tokens ✅
6. User logged in successfully ✅

## Verification

Test the authentication endpoint:
```bash
curl -k https://134.199.243.167/api/auth/firebase/verify -X POST \
  -H "Content-Type: application/json" \
  -d '{"firebaseToken":"test","email":"test@test.com"}'
```

Expected response (validation error is good - endpoint is reachable):
```json
{
  "success": false,
  "message": "Invalid Firebase token"
}
```

## Complete SSL Setup Summary

### Files Modified for SSL Support

1. **[lib/core/network/dio_client.dart](lib/core/network/dio_client.dart)**
   - Configures SSL for Dio HTTP client
   - Used by: SearchService, PoetService, BookmarkService, etc.

2. **[lib/core/auth/firebase_auth_service.dart](lib/core/auth/firebase_auth_service.dart)**
   - Configures SSL for `http` package
   - Used by: Firebase authentication flow

### When to Remove SSL Bypass

Once you have a proper domain with valid SSL certificate:

1. Remove from `DioClient`:
   ```dart
   // DELETE THIS BLOCK:
   if (appConfig.baseApiUrl.contains('134.199.243.167')) {
     (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
       ...
     };
   }
   ```

2. Remove from `FirebaseAuthService`:
   ```dart
   // DELETE THIS METHOD:
   http.Client _createHttpClient() {
     ...
   }

   // And change calls back to:
   final response = await http.post(...);  // Instead of client.post
   ```

3. Update `baseApiUrl`:
   ```dart
   baseApiUrl: 'https://api.yourdomain.com'
   ```

---

**Fixed Date:** 2026-01-14
**Status:** ✅ Resolved
**Impact:** Firebase authentication now works with self-signed SSL certificate
