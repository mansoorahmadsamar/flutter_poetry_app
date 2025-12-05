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
- Multi-language support (Urdu, English, Hindi)
- Poets & Poetry browsing with language preferences
- Search functionality with filters
- Poem reading with proper RTL/LTR text rendering

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

## Features

### ✅ Implemented Features

#### Authentication
- ✅ OAuth2 with Google
- ✅ JWT token management
- ✅ Automatic token refresh
- ✅ Secure token storage

#### Multi-Language Support
- ✅ Language selection (Urdu, English, Hindi)
- ✅ Dynamic content loading based on user preference
- ✅ Localized poetry type names (e.g., "غزل" for Ghazal in Urdu)
- ✅ Automatic RTL/LTR text direction handling
- ✅ Script-aware rendering (Arabic, Roman, Devanagari)

#### Poets & Poetry
- ✅ Browse poets with pagination
- ✅ Filter poets by era, gender, featured, trending
- ✅ View poet profiles with biography, stats, and media
- ✅ Browse poems by poet with poetry type filters
- ✅ Read poem details with proper formatting
- ✅ View counts and engagement metrics
- ✅ Poem cards with excerpts and metadata

#### Search
- ✅ Search poets by name
- ✅ Filter search results by era and gender
- ✅ Recent searches history
- ✅ Suggested poets
- ✅ Real-time search with debouncing

#### User Interface
- ✅ Dark/Light theme support
- ✅ Proper Urdu typography with Jameel Noori font
- ✅ Responsive grid layouts
- ✅ Pull-to-refresh
- ✅ Infinite scroll pagination
- ✅ Bottom navigation

### 🚧 Planned Features

#### Content
- Save favorite poems
- Create custom collections
- Share poems on social media
- Bookmark poems for offline reading

#### Personalization
- User interests (categories, poets)
- Personalized feed based on reading history
- Engagement tracking and recommendations

#### Offline Support
- Cache feed and poems
- Read offline
- Sync when online

#### Advanced Features
- Audio recitations
- Poem explanations and commentary
- Poetry competitions and events
- Community discussions

## API Integration

Base URL (Dev): `http://10.0.2.2:8080` (Android Emulator)
Base URL (Prod): `https://api.poetry-app.com` (To be configured)

### Language Support
All API endpoints support the `lang` query parameter:
- `ur` - Urdu (Arabic script)
- `en` - English / Roman Urdu (Roman script)
- `hi` - Hindi (Devanagari script)

Example:
```
GET /api/poets?lang=ur
GET /api/poems/poet/{id}?lang=en
```

The API automatically returns content in the requested language with fallback to original content.

See [API_DOCUMENTATION.md](API_DOCUMENTATION.md) for full API reference.

## Design System

### Colors
- Primary: #2E5077 (Deep Blue)
- Secondary: #D4A574 (Golden Brown)
- Error: Red tones for errors
- Success: Green tones for success states

### Typography
- **English**: Roboto (Sans-serif)
- **Urdu**: Jameel Noori Nastaleeq (Proper Nastaliq calligraphy)
- **Arabic Script**: Noto Nasakh Arabic with ligatures

### Spacing
4px base unit with consistent scale (xs, sm, md, lg, xl)

### Themes
- Light theme with clean backgrounds
- Dark theme with proper contrast
- Automatic theme switching based on system preference

## Architecture

### State Management
- **Riverpod** for dependency injection and state management
- **Freezed** for immutable models and unions
- **StateNotifier** for complex state logic

### Project Structure
```
lib/
├── core/
│   ├── providers/        # Language, theme providers
│   ├── network/         # HTTP client, interceptors
│   └── design_system/   # Colors, typography, spacing
├── features/
│   ├── auth/           # Google OAuth authentication
│   ├── main/           # Main app with tabs
│   │   └── tabs/
│   │       ├── poets/  # Poets browsing and details
│   │       └── search/ # Search functionality
│   └── onboarding/    # Initial app setup
└── shared/            # Reusable widgets
```

## Development

### Adding New Features
1. Create feature folder under `lib/features/`
2. Add models with Freezed annotations
3. Create providers for state management
4. Build UI components
5. Run code generation: `flutter pub run build_runner build`

### Testing
```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Next Steps

### Short Term
1. ✅ ~~Language support~~
2. ✅ ~~Poets browsing~~
3. ✅ ~~Search functionality~~
4. Favorites and bookmarks
5. User profile and preferences

### Long Term
1. Offline caching with Hive/SQLite
2. Audio recitations
3. Social features (sharing, comments)
4. Poetry competitions
5. Push notifications

## Resources

- [Setup Summary](SETUP_SUMMARY.md)
- [API Documentation](API_DOCUMENTATION.md)
- [Flutter Riverpod](https://riverpod.dev/)
