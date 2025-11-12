# Flutter Poetry App
The largest poetry app in the world, inshaAllah

## Project Status

✅ **Foundation Setup Complete**

The app foundation has been fully set up with:
- Feature-first architecture with Riverpod
- Environment configuration (dev/stage/prod)
- Complete design system (colors, typography, spacing, themes)
- HTTP client with authentication interceptors
- Secure storage for tokens
- Error handling framework

See [SETUP_SUMMARY.md](SETUP_SUMMARY.md) for detailed documentation.

## Quick Start

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
flutter run
```

### Generate Code (when adding models)
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Project Structure

```
lib/
├── core/                 # Core functionality
│   ├── config/          # Environment configuration
│   ├── constants/       # App constants
│   ├── design_system/   # Colors, typography, spacing, themes
│   ├── error/          # Error handling
│   ├── network/        # HTTP client & interceptors
│   └── storage/        # Secure storage & preferences
├── features/           # Feature modules
│   ├── auth/          # Authentication
│   ├── feed/          # Home feed
│   ├── poems/         # Poem reading
│   ├── authors/       # Poet profiles
│   ├── collections/   # Poetry collections
│   └── account/       # User account
└── shared/            # Shared components
```

## Features (Planned)

### Authentication
- OAuth2 with Google
- JWT token management
- Automatic token refresh

### Content
- Browse poetry by categories
- Search poems and poets
- Read poems with proper Urdu typography
- Save favorite poems

### Personalization
- User interests (categories, poets)
- Personalized feed
- Engagement tracking

### Offline Support
- Cache feed and poems
- Read offline
- Sync when online

### Localization
- Urdu (RTL)
- English (LTR)

## API Integration

Base URL (Dev): `http://localhost:8080`

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for full API reference.

## Design System

### Colors
- Primary: #2E5077
- Secondary: #D4A574
- Special Urdu text colors

### Typography
- **English**: Roboto
- **Urdu**: Noto Nasakh Arabic with proper ligatures

### Spacing
4px base unit with consistent scale

## Next Steps

1. Routing & Deep Links
2. Localization (Urdu + English)
3. Authentication (OAuth2)
4. API Services (Retrofit)
5. Domain Models
6. Feed Feature
7. Poem Reader
8. Offline Caching

## Resources

- [Setup Summary](SETUP_SUMMARY.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Flutter Riverpod](https://riverpod.dev/)
