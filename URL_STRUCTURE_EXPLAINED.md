# URL Structure - Correct Configuration

## Base URL vs Full Endpoint Path

### Current Configuration ✅

**Base URL (in AppConfig):**
```dart
baseApiUrl: 'https://134.199.243.167'
```

**Service Endpoint Paths:**
```dart
// SearchService
_baseEndpoint = '/api/search'

// PoetService
_baseEndpoint = '/api/poets'

// BookmarkService
endpoint = '/api/bookmarks/poems/123'

// Firebase Auth
endpoint = '/api/auth/firebase/verify'
```

**Final URLs:**
```
https://134.199.243.167 + /api/search/couplets
= https://134.199.243.167/api/search/couplets ✅

https://134.199.243.167 + /api/poets
= https://134.199.243.167/api/poets ✅

https://134.199.243.167 + /api/auth/firebase/verify
= https://134.199.243.167/api/auth/firebase/verify ✅
```

## Why This Structure?

### Advantages

1. **Clear Separation**
   - Base URL = Server address
   - Endpoint path = API route

2. **Visible API Prefix**
   - All service code clearly shows `/api/` in the path
   - Easy to identify API calls vs other endpoints

3. **Flexibility**
   - Can easily switch between `/api/`, `/admin/`, `/actuator/`
   - Services control their full path

4. **Matches Backend Structure**
   - Backend documentation shows: `https://134.199.243.167/api/*`
   - Our config matches exactly

### Example Service Code

```dart
class SearchService {
  final Dio _dio;
  static const String _baseEndpoint = '/api/search';

  Future<Response> searchCouplets() async {
    // Dio automatically combines: baseUrl + endpoint
    // Result: https://134.199.243.167/api/search/couplets
    return _dio.get('$_baseEndpoint/couplets');
  }
}
```

## Alternative Structure (NOT Used)

We could have done this, but it's less clean:

```dart
// ❌ Less clear approach
baseApiUrl: 'https://134.199.243.167/api'

// Service paths would be:
_baseEndpoint = '/search'  // No /api/ visible
endpoint = '/auth/firebase/verify'  // Confusing - is this API or not?

// Same final URLs but less readable in code
```

## Backend Endpoint Categories

According to the production guide, the backend has multiple endpoint categories:

### API Endpoints (Public/Authenticated)
```
Base: https://134.199.243.167/api
Examples:
  - /api/poems
  - /api/search/couplets
  - /api/auth/firebase/verify
  - /api/bookmarks
```

### Admin Endpoints
```
Base: https://134.199.243.167/admin
Examples:
  - /admin/users
  - /admin/poets
  - /admin/categories
```

### Actuator Endpoints
```
Base: https://134.199.243.167/actuator
Examples:
  - /actuator/health
  - /actuator/metrics
```

## Configuration Summary

| Config | Value | Purpose |
|--------|-------|---------|
| `baseApiUrl` | `https://134.199.243.167` | Server base address |
| Service paths | `/api/search`, `/api/poets`, etc. | Full API endpoint paths |
| SSL handling | Accept cert for `134.199.243.167` | Handle self-signed certificate |

## How URLs are Constructed

### Dio HTTP Client
```dart
// In DioClient
_dio = Dio(
  BaseOptions(
    baseUrl: 'https://134.199.243.167',  // From appConfig
  ),
);

// In Service
_dio.get('/api/poems')

// Dio combines them:
// baseUrl + path = https://134.199.243.167/api/poems
```

### Firebase Auth (using http package)
```dart
Uri.parse('${appConfig.baseApiUrl}/api/auth/firebase/verify')

// String interpolation:
// 'https://134.199.243.167' + '/api/auth/firebase/verify'
// = 'https://134.199.243.167/api/auth/firebase/verify'
```

## Verification Checklist

✅ Base URL does NOT end with `/api`
✅ Service paths START with `/api/`
✅ Final URLs match backend documentation
✅ SSL certificate handling checks for IP address
✅ All services use consistent path structure

## Testing URLs

```bash
# Health check
curl -k https://134.199.243.167/api/health

# Search
curl -k "https://134.199.243.167/api/search/couplets?q=test"

# Auth
curl -k https://134.199.243.167/api/auth/firebase/verify -X POST

# All should respond (200 or validation error, not 404)
```

---

**Last Updated:** 2026-01-14
**Configuration:** Production Server
**Status:** ✅ Correct Structure Implemented
