# Flutter Poetry App - Setup Summary

## Overview
This document summarizes the foundational setup completed for the Poetry App. The architecture follows modern Flutter best practices with a focus on maintainability, scalability, and offline-first functionality.

## Architecture

### Structure
- **Feature-first architecture**: Organized by features (feed, poems, authors, collections, account, auth)
- **Clean separation**: UI, State, Domain, and Data layers
- **Shared components**: Reusable UI components and utilities

### Folder Structure
```
lib/
├── core/
│   ├── config/           # Environment configuration
│   ├── constants/        # App-wide constants
│   ├── design_system/    # Colors, typography, spacing, theme
│   ├── error/           # Error handling
│   ├── l10n/            # Localization files
│   ├── network/         # HTTP client, interceptors, DTOs
│   ├── router/          # Navigation & deep links
│   ├── storage/         # Secure storage & preferences
│   └── utils/           # Utility functions
├── features/
│   ├── feed/
│   ├── poems/
│   ├── authors/
│   ├── collections/
│   ├── account/
│   └── auth/
│       ├── data/
│       │   ├── models/      # Data transfer objects
│       │   └── repositories/ # Data sources
│       ├── domain/
│       │   └── models/      # Business entities
│       └── presentation/
│           ├── providers/   # Riverpod providers
│           ├── screens/     # UI screens
│           └── widgets/     # Feature widgets
└── shared/
    ├── widgets/         # Reusable components
    ├── models/          # Shared models
    └── extensions/      # Dart extensions
```

## Configuration

### Environment Configuration ([app_config.dart](lib/core/config/app_config.dart))
Three environments configured:
- **Dev**: Local development (http://localhost:8080)
- **Stage**: Staging environment
- **Prod**: Production environment

Each environment has:
- Distinct API base URLs
- Configurable timeouts
- Cache TTL settings
- Feature flags (logging, analytics)

### Constants ([app_constants.dart](lib/core/constants/app_constants.dart))
Centralized constants for:
- API headers
- Storage keys
- Pagination defaults
- Cache keys
- Deep link schemes
- Animation durations
- Retry configuration

## Design System

### Colors ([app_colors.dart](lib/core/design_system/app_colors.dart))
- Primary, secondary, and accent colors
- Light and dark theme variants
- Semantic colors (success, error, warning, info)
- Special colors for poetry content (Urdu text accent, verse backgrounds)

### Typography ([app_typography.dart](lib/core/design_system/app_typography.dart))
- **English**: Roboto font family
- **Urdu**: Noto Nasakh Arabic (proper ligature support)
- Increased line heights for Urdu (1.8-2.2x for poetry)
- Complete Material Design 3 text styles
- Special styles for poetry verses and poet names

### Spacing ([app_spacing.dart](lib/core/design_system/app_spacing.dart))
Consistent spacing scale based on 4px unit:
- xs (4px) to xxxl (64px)
- Standard padding and margins
- Icon sizes
- Border radius values
- Elevation levels

### Theme ([app_theme.dart](lib/core/design_system/app_theme.dart))
- Material Design 3 themes
- Light and dark mode support
- Consistent component styling
- RTL-ready layouts

## State Management

### Riverpod Setup
- **flutter_riverpod**: ^2.6.1
- Provider-based architecture
- Type-safe state management
- Easy testing and dependency injection

### Key Providers
- `secureStorageProvider`: Secure token storage
- `preferencesServiceProvider`: App preferences
- `dioClientProvider`: HTTP client

## Networking Layer

### HTTP Client ([dio_client.dart](lib/core/network/dio_client.dart))
- **Dio** for HTTP requests
- Configured timeouts (30s)
- Base URL from environment config
- Interceptor support

### Interceptors
1. **AuthInterceptor** ([auth_interceptor.dart](lib/core/network/interceptors/auth_interceptor.dart))
   - Automatically adds Bearer token to requests
   - Reads from secure storage
   - Handles token expiration

2. **LoggingInterceptor** ([logging_interceptor.dart](lib/core/network/interceptors/logging_interceptor.dart))
   - Pretty-printed request/response logs
   - Only enabled in development
   - Color-coded output

### API Response Structure ([api_response.dart](lib/core/network/dto/api_response.dart))
- Generic `ApiResponse<T>` wrapper
- `PaginatedResponse<T>` for lists
- Matches backend API structure

## Storage

### Secure Storage ([secure_storage.dart](lib/core/storage/secure_storage.dart))
Uses `flutter_secure_storage` for sensitive data:
- Access tokens
- Refresh tokens
- User ID and email
- Platform-specific encryption (Android: EncryptedSharedPreferences)

### Shared Preferences ([preferences_service.dart](lib/core/storage/preferences_service.dart))
For non-sensitive app settings:
- Language preference
- Theme mode
- Onboarding status

## Error Handling ([app_error.dart](lib/core/error/app_error.dart))

Standardized error types:
- **NetworkError**: Offline, timeout, server errors
- **AuthError**: Unauthorized, forbidden, token expired
- **ValidationError**: Field validation errors
- **CacheError**: Cache read/write errors
- **GenericError**: Fallback errors

All errors have:
- Technical message (for logging)
- User-friendly message (for UI)
- Stack trace support

## Dependencies

### Core Dependencies
```yaml
# State Management
flutter_riverpod: ^2.6.1

# Networking
dio: ^5.7.0
retrofit: ^4.4.1
pretty_dio_logger: ^1.4.0

# Storage
flutter_secure_storage: ^9.2.2
shared_preferences: ^2.3.3
hive: ^2.2.3
hive_flutter: ^1.1.0

# Navigation
go_router: ^14.6.2

# UI
google_fonts: ^6.2.1
cached_network_image: ^3.4.1
shimmer: ^3.0.0

# Utilities
equatable: ^2.0.7
logger: ^2.5.0
connectivity_plus: ^6.0.5
```

### Dev Dependencies
```yaml
build_runner: ^2.4.13
freezed: ^2.5.7
json_serializable: ^6.8.0
riverpod_generator: ^2.6.2
retrofit_generator: ^9.1.4
```

## What's Already Built

### ✅ Completed
1. **Project structure**: Feature-first folders created
2. **Dependencies**: All packages installed and configured
3. **Environment config**: Dev/Stage/Prod environments
4. **Design system**: Colors, typography, spacing, themes
5. **Networking**: HTTP client with interceptors
6. **Storage**: Secure storage and preferences
7. **Error handling**: Standardized error types
8. **Main app**: Initialized with Riverpod

### 📝 Ready to Build Next
1. **Routing**: go_router setup with deep links
2. **Localization**: Urdu (RTL) and English (LTR) support
3. **Auth feature**: OAuth2 flow with Google
4. **API services**: Retrofit services for each endpoint
5. **Domain models**: Poet, Poem, Category, etc.
6. **Feed feature**: Home feed with card types
7. **Offline caching**: Hive for local storage
8. **Reusable widgets**: Cards, buttons, loaders, etc.

## API Integration Notes

Based on [API_DOCUMENTATION.md](API_DOCUMENTATION.md):

### Authentication Flow
1. User clicks "Login with Google"
2. Open `/oauth2/authorization/google` in browser/WebView
3. Google redirects back with tokens in URL
4. Extract `access_token` and `refresh_token`
5. Save tokens to secure storage
6. Use `AuthInterceptor` for authenticated requests
7. Handle 401 by refreshing token via `/api/auth/refresh`

### Public Endpoints (No Auth Required)
- `GET /api/categories`
- `GET /api/poets`
- `GET /api/poets/search`

### Protected Endpoints (Auth Required)
- `GET /api/profile`
- `GET /api/profile/interests`
- `POST /api/profile/engagement/track`

## Running the App

### Install Dependencies
```bash
flutter pub get
```

### Run on Device/Emulator
```bash
flutter run
```

### Generate Code (when needed)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Next Steps

1. **Set up routing**: Implement go_router for navigation and deep links
2. **Add localization**: Create Urdu and English translation files
3. **Build auth feature**: Implement OAuth2 flow
4. **Create API services**: Use Retrofit to define API endpoints
5. **Build domain models**: Define Poet, Poem, Category entities
6. **Implement features**: Start with feed, then poems, authors, etc.
7. **Add offline support**: Implement caching strategy with Hive
8. **Create reusable widgets**: Build card components, loaders, empty states

## Code Generation

Some files have `.g.dart` imports that need generation:
- [api_response.dart](lib/core/network/dto/api_response.dart)

Run code generation when you add models with `@JsonSerializable`:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Notes for Development

### Best Practices
- Use the design system constants (don't hardcode values)
- Always check API response `success` field
- Handle errors with user-friendly messages
- Test both RTL and LTR layouts
- Keep access token expiry short (1 hour)
- Implement offline-first where possible

### Architecture Guidelines
- Keep business logic in repositories
- UI should only consume providers
- No direct API calls from widgets
- Use dependency injection via Riverpod
- Separate DTOs (data) from domain models

### Testing Strategy
- Unit tests for repositories and utilities
- Widget tests for core components
- Integration tests for critical flows (login, poem reading)
- Golden tests for Urdu typography

## Resources

- [API Documentation](API_DOCUMENTATION.md)
- [Flutter Riverpod Docs](https://riverpod.dev/)
- [Dio Documentation](https://pub.dev/packages/dio)
- [Google Fonts](https://fonts.google.com/)

---

**Setup completed on**: 2025-11-12
**Flutter version**: 3.9.2
**Dart SDK**: ^3.9.2
