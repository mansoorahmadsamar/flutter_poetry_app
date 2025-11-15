# Backend Fix Required for Mobile Authentication

## Issue

The Flutter app was getting a **302 redirect error** when calling `/api/auth/google/android`. The backend was redirecting to the OAuth login flow instead of processing the API request.

```
Error: DioException [bad response]: status code of 302
Location: http://localhost:8080/oauth2/authorization/google
```

## Root Cause

The Spring Security configuration had a single security filter chain that applied both:
- OAuth2 login (session-based, requires redirects)
- JWT/API authentication (stateless, no redirects)

When the OAuth2 login was configured globally with `.oauth2Login()`, Spring Security would redirect **all unauthenticated requests** to the OAuth login page, even API requests that should return 401 instead.

## Solution Applied

Updated [`SecurityConfig.java`](/Users/mansoorahmadsamar/Documents/Development/Java/poetry-backend/poetry-backend/src/main/java/com/techhikes/poetry/config/SecurityConfig.java) to use **two separate security filter chains**:

### 1. API Filter Chain (Order 1)
- **Applies to**: `/api/**` endpoints
- **Session Policy**: STATELESS (no sessions, no redirects)
- **Auth Method**: JWT tokens via `AuthTokenFilter`
- **Unauthenticated Response**: 401 Unauthorized (no redirect)
- **Public Endpoints**: `/api/auth/**`, `/api/health/**`, `/api/poems/**`, etc.

### 2. OAuth Filter Chain (Order 2)
- **Applies to**: `/oauth2/**`, `/login/**`, and all other endpoints
- **Session Policy**: IF_REQUIRED (allows sessions for OAuth flow)
- **Auth Method**: OAuth2 login with Google
- **Unauthenticated Response**: Redirect to `/oauth2/authorization/google`

## Testing

After restarting the backend, test the fix:

```bash
# Should return 401 (not 302 redirect)
curl -v -X POST 'http://localhost:8080/api/auth/google/android' \
  -H 'Content-Type: application/json' \
  -d '{"idToken":"test","deviceType":"android"}'

# Expected: HTTP/1.1 401 Unauthorized
# NOT: HTTP/1.1 302 (redirect)
```

With a valid Google ID token, it should return 200 with JWT tokens.

## Action Required

**⚠️ RESTART THE BACKEND** to apply the SecurityConfig changes:

1. Stop the backend in IntelliJ
2. Restart the application
3. Test the `/api/auth/google/android` endpoint
4. Run the Flutter app and try Google Sign-In

## Changes Made

**File**: `/Users/mansoorahmadsamar/Documents/Development/Java/poetry-backend/poetry-backend/src/main/java/com/techhikes/poetry/config/SecurityConfig.java`

**Changes**:
- Split single `filterChain()` method into two:
  - `apiFilterChain()` with `@Order(1)` and `.securityMatcher("/api/**")`
  - `oauth2FilterChain()` with `@Order(2)` for OAuth endpoints
- Added `HttpServletResponse` import
- API chain uses `STATELESS` session policy
- OAuth chain uses `IF_REQUIRED` session policy

## Related Documentation

- [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) - Describes the two authentication flows
- [AUTH_ARCHITECTURE.md](./AUTH_ARCHITECTURE.md) - Architecture diagrams
- [FLUTTER_ANDROID_AUTH_GUIDE.md](./FLUTTER_ANDROID_AUTH_GUIDE.md) - Mobile implementation guide
