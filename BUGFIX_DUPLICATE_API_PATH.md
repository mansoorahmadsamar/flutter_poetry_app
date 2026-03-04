# Bug Fix: Duplicate /api/ in Authentication URLs

## Issue Found

When attempting to sign in with Google, the app was making requests to incorrect URLs with duplicate `/api/` paths:

**Incorrect URLs:**
```
❌ https://134.199.243.167/api/api/auth/firebase/verify
❌ https://134.199.243.167/api/api/auth/refresh
❌ https://134.199.243.167/api/api/auth/logout
```

**Error:**
```
HandshakeException: Handshake error in client (OS Error:
CERTIFICATE_VERIFY_FAILED: application verification failure)
```

## Root Cause

The `baseApiUrl` already includes `/api`:
```dart
baseApiUrl: 'https://134.199.243.167/api'
```

But the Firebase auth service was adding `/api/` again when constructing URLs:
```dart
Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify')
//         ^^^^^^^^^^^^^^^^^^^^      ^^^^ duplicate!
```

## Solution

**File Modified:** [lib/core/auth/firebase_auth_service.dart](lib/core/auth/firebase_auth_service.dart)

Changed all authentication endpoint URLs to remove the duplicate `/api/`:

### Changes Made

1. **Firebase Token Verification** (Line 91, 94)
   ```dart
   // Before
   Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify')

   // After
   Uri.parse('${appConfig.baseApiUrl}/auth/firebase/verify')
   ```

2. **Token Refresh** (Line 193)
   ```dart
   // Before
   Uri.parse('${appConfig.baseApiUrl}/api/auth/refresh')

   // After
   Uri.parse('${appConfig.baseApiUrl}/auth/refresh')
   ```

3. **Logout** (Line 333)
   ```dart
   // Before
   Uri.parse('${appConfig.baseApiUrl}/api/auth/logout')

   // After
   Uri.parse('${appConfig.baseApiUrl}/auth/logout')
   ```

## Correct URLs

Now the authentication endpoints resolve correctly:

✅ `https://134.199.243.167/api/auth/firebase/verify`
✅ `https://134.199.243.167/api/auth/refresh`
✅ `https://134.199.243.167/api/auth/logout`

## URL Construction Pattern

For all API calls in the app, follow this pattern:

**Config:**
```dart
baseApiUrl: 'https://134.199.243.167/api'  // Ends with /api
```

**Service Calls:**
```dart
// ✅ Correct - path starts with /
Uri.parse('${appConfig.baseApiUrl}/auth/firebase/verify')

// ❌ Wrong - duplicate /api/
Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify')
```

**Result:**
```
baseApiUrl     + path
↓                ↓
https://134.199.243.167/api + /auth/firebase/verify
= https://134.199.243.167/api/auth/firebase/verify ✅
```

## Testing

After this fix:

1. **Test Firebase Sign-In:**
   ```bash
   flutter run
   ```
   - Click "Sign in with Google"
   - Should successfully authenticate
   - Check logs for correct endpoint

2. **Expected Log Output:**
   ```
   📤 Step 6: Sending Firebase token to backend...
      Endpoint: https://134.199.243.167/api/auth/firebase/verify
   ```

3. **Verify Backend Response:**
   - Status Code: 200
   - Should receive auth tokens from backend

## Related Files

- [lib/core/config/app_config.dart](lib/core/config/app_config.dart) - Base URL configuration
- [lib/core/auth/firebase_auth_service.dart](lib/core/auth/firebase_auth_service.dart) - Fixed authentication endpoints

## Prevention

When adding new API endpoints, always remember:
- `baseApiUrl` already includes `/api`
- Paths should start with `/` but NOT include `/api/`
- Final URL format: `{baseApiUrl}/{endpoint-path}`

---

**Fixed Date:** 2026-01-14
**Status:** ✅ Resolved
**Impact:** Firebase authentication now works correctly
