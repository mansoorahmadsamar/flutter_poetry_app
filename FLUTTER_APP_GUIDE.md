# Poetry App - Flutter Development Guide
**Beautiful Design • Discoverable Content • Elegant Experience**

> A comprehensive guide to building a stunning poetry discovery and reading experience

**Version:** 2.0.0
**Last Updated:** February 6, 2026
**Target:** Flutter Mobile App (iOS & Android)

---

## 📱 App Vision & Design Philosophy

### Core Principles

**1. Content First** 🎨
- Poetry is the hero - let it breathe
- Beautiful typography with RTL support for Urdu/Arabic script
- Generous white space and elegant layouts
- High contrast for readability

**2. Discoverable & Delightful** ✨
- Intuitive navigation and content discovery
- Smart recommendations based on user taste
- Seamless search across poems, poets, and verses
- Contextual suggestions and related content

**3. Emotional Connection** ❤️
- Smooth animations and transitions
- Haptic feedback for interactions
- Beautiful imagery and poet portraits
- Personal collections and bookmarks

**4. Performance & Accessibility** ⚡
- Fast loading with progressive rendering
- Offline reading support
- Multi-language support (Urdu, English, Hindi, Persian)
- Accessibility for screen readers

---

## 🎨 Design System

### Color Palette

```dart
// lib/theme/app_colors.dart
class AppColors {
  // Primary Colors - Rich, elegant tones
  static const primary = Color(0xFF2C3E50);        // Deep blue-gray
  static const primaryLight = Color(0xFF34495E);
  static const primaryDark = Color(0xFF1A252F);

  // Accent Colors - Warm, inviting
  static const accent = Color(0xFFE74C3C);         // Persian red
  static const accentLight = Color(0xFFC0392B);
  static const gold = Color(0xFFD4AF37);           // Golden highlights

  // Backgrounds
  static const background = Color(0xFFFAFAFA);     // Off-white
  static const surface = Color(0xFFFFFFFF);        // Pure white
  static const surfaceDark = Color(0xFF2C2C2C);    // Dark mode

  // Text Colors
  static const textPrimary = Color(0xFF2C3E50);
  static const textSecondary = Color(0xFF7F8C8D);
  static const textUrdu = Color(0xFF1A1A1A);       // High contrast for Urdu

  // Status Colors
  static const success = Color(0xFF27AE60);
  static const error = Color(0xFFE74C3C);
  static const warning = Color(0xFFF39C12);
  static const info = Color(0xFF3498DB);
}
```

### Typography

```dart
// lib/theme/app_text_styles.dart
class AppTextStyles {
  // Urdu/Arabic Typography - Noto Nastaliq Urdu
  static const urduDisplay = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 2.0,  // Generous line height for readability
    letterSpacing: 0.5,
  );

  static const urduHeadline = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.8,
  );

  static const urduBody = TextStyle(
    fontFamily: 'NotoNastaliqUrdu',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 2.2,  // Extra height for couplets
  );

  // English Typography - Crimson Text + Inter
  static const englishDisplay = TextStyle(
    fontFamily: 'CrimsonText',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.5,
  );

  static const englishHeadline = TextStyle(
    fontFamily: 'Inter',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );

  static const englishBody = TextStyle(
    fontFamily: 'Inter',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
  );
}
```

### Spacing & Layout

```dart
// lib/theme/app_spacing.dart
class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // Content margins
  static const contentPadding = EdgeInsets.symmetric(
    horizontal: 20.0,
    vertical: 16.0,
  );

  // Card padding
  static const cardPadding = EdgeInsets.all(16.0);

  // Section spacing
  static const sectionSpacing = 24.0;
}
```

---

## 🏗️ App Architecture

### Folder Structure

```
lib/
├── main.dart
├── config/
│   ├── environment.dart        # API base URLs
│   ├── routes.dart            # Navigation routes
│   └── firebase_config.dart   # Firebase setup
├── theme/
│   ├── app_theme.dart         # Main theme
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   └── app_spacing.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart    # HTTP client
│   │   └── api_response.dart  # Response wrapper
│   ├── models/              # Data models
│   ├── services/            # Business logic
│   └── utils/               # Helpers
├── features/
│   ├── auth/
│   │   ├── screens/
│   │   ├── widgets/
│   │   └── auth_service.dart
│   ├── home/
│   │   ├── screens/
│   │   │   └── home_screen.dart
│   │   └── widgets/
│   │       ├── featured_poets_carousel.dart
│   │       ├── trending_poems_grid.dart
│   │       └── category_chips.dart
│   ├── discover/
│   │   ├── screens/
│   │   │   ├── explore_screen.dart
│   │   │   └── search_screen.dart
│   │   └── widgets/
│   ├── poets/
│   │   ├── screens/
│   │   │   ├── poets_list_screen.dart
│   │   │   └── poet_profile_screen.dart
│   │   └── widgets/
│   ├── poems/
│   │   ├── screens/
│   │   │   ├── poem_reader_screen.dart
│   │   │   └── poems_list_screen.dart
│   │   └── widgets/
│   ├── library/
│   │   ├── screens/
│   │   │   ├── library_screen.dart
│   │   │   └── bookmarks_screen.dart
│   │   └── widgets/
│   └── profile/
│       ├── screens/
│       └── widgets/
└── widgets/                # Shared widgets
    ├── loading_shimmer.dart
    ├── error_state.dart
    └── empty_state.dart
```

---

## 📱 Key Screens & Features

### 1. Home Screen - Discover & Delight

**Purpose:** Curated content discovery, personalized recommendations

**Layout:**
```dart
// lib/features/home/screens/home_screen.dart
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Elegant App Bar with gradient
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text('سخن', style: AppTextStyles.urduDisplay),
              background: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),

          // Daily Featured Poem Card
          SliverToBoxAdapter(
            child: FeaturedPoemCard(),
          ),

          // Trending Poets Carousel
          SliverToBoxAdapter(
            child: PoetsCarousel(title: 'Trending Poets'),
          ),

          // Category Discovery Chips
          SliverToBoxAdapter(
            child: CategoryChipsSection(),
          ),

          // Recent Poems Grid
          SliverPadding(
            padding: AppSpacing.contentPadding,
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => PoemCard(poem: poems[index]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

**API Endpoints:**
- `GET /api/poems/featured` - Featured/daily poem
- `GET /api/poets?page=0&size=10&sortBy=viewCount` - Trending poets
- `GET /api/categories` - Categories for discovery
- `GET /api/poems?page=0&size=20` - Recent poems

**Design Elements:**
- Hero card for featured poem with elegant shadow
- Horizontal scrolling carousel for poets with circular avatars
- Colorful category chips with icon badges
- Masonry grid layout for poems
- Smooth page transitions

---

### 2. Search & Discovery - Smart Exploration

**Purpose:** Multi-faceted search, verse-level discovery, intelligent suggestions

**Layout:**
```dart
// lib/features/discover/screens/search_screen.dart
class SearchScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
        onSearch: (query) => _performSearch(query),
      ),
      body: Column(
        children: [
          // Search Type Tabs
          TabBar(
            tabs: [
              Tab(text: 'Poems'),
              Tab(text: 'Verses'),
              Tab(text: 'Poets'),
            ],
          ),

          // Filters Row (Language, Poetry Type, Era)
          FiltersRow(),

          // Results List with highlighting
          Expanded(
            child: SearchResults(
              results: searchResults,
              onTap: (item) => _navigateToDetail(item),
            ),
          ),
        ],
      ),
    );
  }
}
```

**API Endpoints:**
- `GET /api/poems/search?query={query}&lang=ur&page=0` - Poem search
- `GET /api/poems/verses/search?query={query}&lang=ur` - Verse search
- `GET /api/poets/search?query={query}` - Poet search
- `GET /api/search?query={query}&type=ALL` - Unified search

**Features:**
- Real-time search with debouncing (300ms)
- Search history with quick filters
- Highlighted search terms in results
- Voice search support
- Recent searches persistence
- Language-aware search (Urdu, Roman, English)

**UX Enhancements:**
- Smooth transitions between tabs
- Loading shimmer for results
- Empty state with search suggestions
- Quick filter chips for refinement

---

### 3. Poem Reader - Immersive Reading Experience

**Purpose:** Distraction-free reading, verse-by-verse presentation, engagement

**Layout:**
```dart
// lib/features/poems/screens/poem_reader_screen.dart
class PoemReaderScreen extends StatelessWidget {
  final String poemId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Transparent app bar with poet info
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: PoemHeader(
              poet: poem.poet,
              poemTitle: poem.title,
              backgroundImage: poet.profileImage,
            ),
          ),

          // Poem content with elegant typography
          SliverPadding(
            padding: EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final verse = poem.verses[index];
                  return CoupletCard(
                    verse: verse,
                    onLike: () => _likeCouplet(verse),
                    onBookmark: () => _bookmarkCouplet(verse),
                    onShare: () => _shareCouplet(verse),
                  );
                },
                childCount: poem.verses.length,
              ),
            ),
          ),

          // Related poems section
          SliverToBoxAdapter(
            child: RelatedPoemsSection(poetId: poem.poetId),
          ),
        ],
      ),

      // Floating action buttons for engagement
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            onPressed: _bookmarkPoem,
            child: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
          ),
          SizedBox(height: 8),
          FloatingActionButton.small(
            onPressed: _likePoem,
            child: Icon(isLiked ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
    );
  }
}
```

**API Endpoints:**
- `GET /api/poems/{publicId}` - Get full poem with verses
- `POST /api/poems/{publicId}/bookmark?lang=ur` - Toggle bookmark
- `POST /api/couplets/{coupletId}/like` - Like specific couplet
- `POST /api/couplets/{coupletId}/bookmark?lang=ur` - Bookmark couplet
- `POST /api/couplets/{coupletId}/share` - Track couplet share
- `GET /api/poems/poet/{poetId}?page=0&size=5` - Related poems

**Design Features:**
- **Typography:** Extra large font for Urdu (18-22sp), generous line height (2.0-2.2)
- **RTL Support:** Proper right-to-left layout for Arabic script
- **Verse Spacing:** Clear separation between couplets
- **Engagement:** Smooth animations for like/bookmark
- **Haptic Feedback:** Gentle vibration on interactions
- **Deep Links:** Share individual couplets with public URLs

**Reading Modes:**
- Day mode (cream background, dark text)
- Night mode (dark background, light text)
- Adjustable font size (14-28sp)
- Reading progress indicator

---

### 4. Poet Profile - Rich Biographies

**Purpose:** Explore poet's life, works, and legacy

**Layout:**
```dart
// lib/features/poets/screens/poet_profile_screen.dart
class PoetProfileScreen extends StatelessWidget {
  final String poetId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero image with gradient overlay
          SliverAppBar(
            expandedHeight: 300,
            flexibleSpace: PoetHeroImage(
              imageUrl: poet.profileImageUrl,
              name: poet.urduName,
            ),
          ),

          // Poet info card
          SliverToBoxAdapter(
            child: PoetInfoCard(
              poet: poet,
              stats: PoetStats(
                poemsCount: poet.poemCount,
                followersCount: poet.followersCount,
                era: poet.era,
              ),
            ),
          ),

          // Tabs: Works, Biography, Gallery, Books
          SliverPersistentHeader(
            pinned: true,
            delegate: TabBarDelegate(
              tabs: ['Works', 'Bio', 'Gallery', 'Books'],
            ),
          ),

          // Tab content
          SliverFillRemaining(
            child: TabBarView(
              children: [
                PoemsTab(poetId: poetId),
                BiographyTab(poet: poet),
                GalleryTab(poetId: poetId),
                BooksTab(poetId: poetId),
              ],
            ),
          ),
        ],
      ),

      // Follow button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _toggleFollow,
        icon: Icon(isFollowing ? Icons.check : Icons.add),
        label: Text(isFollowing ? 'Following' : 'Follow'),
      ),
    );
  }
}
```

**API Endpoints:**
- `GET /api/poets/{publicId}/profile` - Complete poet profile
- `GET /api/poems/poet/{poetId}?page=0&size=20` - Poet's poems
- `GET /api/poets/{publicId}/gallery` - Image gallery
- `GET /api/poets/{publicId}/books` - Books by poet
- `POST /api/poet-follows/{poetId}` - Follow poet
- `DELETE /api/poet-follows/{poetId}` - Unfollow poet
- `GET /api/poet-follows/status/{poetId}` - Check follow status

**Design Features:**
- Large hero image with parallax effect
- Beautiful gradient overlays
- Stats cards (poems, followers, era)
- Tabbed navigation for content sections
- Image gallery with lightbox view
- Book covers with download tracking

---

### 5. Library - Personal Collections

**Purpose:** User's saved content, reading history, personalized space

**Layout:**
```dart
// lib/features/library/screens/library_screen.dart
class LibraryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text('My Library'),
            floating: true,
          ),

          // Quick stats cards
          SliverToBoxAdapter(
            child: StatsRow(
              bookmarksCount: 45,
              likesCount: 128,
              followingCount: 12,
            ),
          ),

          // Unified bookmarks feed (poems, couplets, images)
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Recent Bookmarks',
              action: 'View All',
              onTap: () => _navigateToBookmarks(),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final bookmark = recentBookmarks[index];
                return UnifiedBookmarkCard(bookmark: bookmark);
              },
              childCount: recentBookmarks.length,
            ),
          ),

          // Following poets
          SliverToBoxAdapter(
            child: FollowingPoetsSection(),
          ),

          // Generated poetry images
          SliverToBoxAdapter(
            child: MyPoetryImagesSection(),
          ),
        ],
      ),
    );
  }
}
```

**API Endpoints:**
- `GET /api/bookmarks/recent?page=0&size=20` - Recent bookmarks (all types)
- `GET /api/bookmarks/poems?page=0&size=20` - Poem bookmarks only
- `GET /api/bookmarks/couplets?page=0&size=20` - Couplet bookmarks only
- `GET /api/bookmarks/images?page=0&size=20` - Image bookmarks only
- `GET /api/bookmarks/stats` - Bookmark statistics
- `GET /api/poet-follows?page=0&size=20` - Following poets
- `GET /api/users/me/image-collections` - Saved poetry images

**Features:**
- Unified bookmark feed (poems + couplets + images)
- Filter by content type
- Search within bookmarks
- Sort by date, language, popularity
- Delete bookmarks with undo
- Export bookmarks

---

### 6. Image Poetry Creator - Creative Expression

**Purpose:** Generate beautiful poetry images from couplets

**Layout:**
```dart
// lib/features/image_poetry/screens/image_creator_screen.dart
class ImageCreatorScreen extends StatefulWidget {
  final String coupletId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Poetry Image')),
      body: Column(
        children: [
          // Preview area
          Expanded(
            child: ImagePreviewCard(
              couplet: couplet,
              template: selectedTemplate,
              customizations: customizations,
            ),
          ),

          // Template selection
          TemplateCarousel(
            templates: templates,
            onSelect: (template) => _selectTemplate(template),
          ),

          // Customization panel
          CustomizationPanel(
            onColorChange: (color) => _updateColor(color),
            onFontChange: (font) => _updateFont(font),
            onLayoutChange: (layout) => _updateLayout(layout),
          ),

          // Action buttons
          ActionButtonsRow(
            onSave: _saveImage,
            onShare: _shareImage,
            onDownload: _downloadImage,
          ),
        ],
      ),
    );
  }
}
```

**API Endpoints:**
- `GET /api/poetry-images/templates?page=0&size=50` - Available templates
- `GET /api/poetry-images/templates/popular` - Popular templates
- `POST /api/poetry-images/generate` - Generate image
- `POST /api/poetry-images/{imageId}/bookmark?lang=ur` - Bookmark image
- `GET /api/users/me/image-bookmarks?lang=ur` - Get bookmarked images
- `POST /api/poetry-images/upload-background` - Upload custom background

**Features:**
- 50+ beautiful templates
- Custom background upload
- Font size and color customization
- Preview before generation
- Save to collection
- Share to social media
- Download high-res image

---

## 🎯 API Integration Guide

### Environment Configuration

```dart
// lib/config/environment.dart
class Environment {
  static const String _localIp = '192.168.10.11'; // Your machine's IP

  static String get baseUrl {
    switch (const String.fromEnvironment('ENV', defaultValue: 'local')) {
      case 'prod':
        return 'https://134.199.243.167/api';
      case 'dev':
        return 'https://dev-api.poetry.com/api';
      default:
        // Local development
        return Platform.isAndroid
            ? 'http://10.0.2.2:8081/api'        // Android emulator
            : Platform.isIOS
                ? 'http://localhost:8081/api'    // iOS simulator
                : 'http://$_localIp:8081/api';   // Physical device
    }
  }
}
```

### API Client Setup

```dart
// lib/core/api/api_client.dart
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl,
        connectTimeout: Duration(seconds: 10),
        receiveTimeout: Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(AuthInterceptor());
    _dio.interceptors.add(LoggingInterceptor());
    _dio.interceptors.add(ErrorInterceptor());
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(Map<String, dynamic>)? fromJson,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return ApiResponse.fromJson(response.data, fromJson);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // POST, PUT, DELETE methods...
}
```

### Authentication Flow

```dart
// lib/features/auth/auth_service.dart
class AuthService {
  final ApiClient _api;
  final FirebaseAuth _firebaseAuth;
  final FlutterSecureStorage _storage;

  Future<User> signInWithGoogle() async {
    // 1. Sign in with Firebase
    final googleUser = await GoogleSignIn().signIn();
    final googleAuth = await googleUser?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    // 2. Get Firebase ID token
    final firebaseToken = await userCredential.user?.getIdToken();

    // 3. Send to backend for verification
    final response = await _api.post<JwtResponse>(
      '/auth/firebase/verify',
      data: {
        'firebaseToken': firebaseToken,
        'email': userCredential.user?.email,
        'deviceType': Platform.isAndroid ? 'android' : 'ios',
      },
      fromJson: (json) => JwtResponse.fromJson(json),
    );

    // 4. Store JWT tokens securely
    await _storage.write(key: 'access_token', value: response.data.accessToken);
    await _storage.write(key: 'refresh_token', value: response.data.refreshToken);

    return response.data.toUser();
  }

  Future<void> refreshToken() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    final response = await _api.post<JwtResponse>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
      fromJson: (json) => JwtResponse.fromJson(json),
    );

    await _storage.write(key: 'access_token', value: response.data.accessToken);
    await _storage.write(key: 'refresh_token', value: response.data.refreshToken);
  }
}
```

---

## 🚀 Performance Optimization

### 1. Image Loading & Caching

```dart
// Use cached_network_image for all remote images
CachedNetworkImage(
  imageUrl: poet.profileImageUrl,
  placeholder: (context, url) => ShimmerPlaceholder(),
  errorWidget: (context, url, error) => DefaultAvatar(),
  memCacheWidth: 400,  // Resize for memory efficiency
  fadeInDuration: Duration(milliseconds: 300),
)
```

### 2. Pagination & Infinite Scroll

```dart
// lib/widgets/infinite_scroll_list.dart
class InfiniteScrollList<T> extends StatefulWidget {
  final Future<List<T>> Function(int page) fetchData;
  final Widget Function(T item) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
          _loadMoreData();
        }
        return false;
      },
      child: ListView.builder(
        itemCount: items.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == items.length) {
            return LoadingIndicator();
          }
          return itemBuilder(items[index]);
        },
      ),
    );
  }
}
```

### 3. State Management (Riverpod)

```dart
// lib/features/poems/providers/poem_providers.dart
final poemsProvider = FutureProvider.family<PoemDetail, String>((ref, poemId) async {
  final api = ref.read(apiClientProvider);
  return api.get<PoemDetail>('/poems/$poemId', fromJson: PoemDetail.fromJson);
});

final featuredPoemsProvider = FutureProvider<List<PoemSummary>>((ref) async {
  final api = ref.read(apiClientProvider);
  return api.get<List<PoemSummary>>('/poems/featured', /* ... */);
});
```

### 4. Offline Support

```dart
// Cache important data with Hive
final bookmarksBox = await Hive.openBox<Bookmark>('bookmarks');

// Save bookmarks offline
await bookmarksBox.put(bookmark.id, bookmark);

// Sync when online
if (await connectivity.isConnected) {
  await syncBookmarks();
}
```

---

## 🎨 UI Components Library

### Poem Card Component

```dart
class PoemCard extends StatelessWidget {
  final PoemSummary poem;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poet avatar and name
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(poem.poetProfileImageUrl),
                    radius: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    poem.poetName,
                    style: AppTextStyles.urduBody.copyWith(fontSize: 14),
                  ),
                ],
              ),
              SizedBox(height: 12),

              // Poem title
              Text(
                poem.title,
                style: AppTextStyles.urduHeadline,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 8),

              // Excerpt
              Text(
                poem.excerpt,
                style: AppTextStyles.urduBody.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
              SizedBox(height: 12),

              // Stats row
              Row(
                children: [
                  Icon(Icons.visibility, size: 16, color: AppColors.textSecondary),
                  SizedBox(width: 4),
                  Text('${poem.viewCount}', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 16),
                  Icon(Icons.favorite, size: 16, color: AppColors.accent),
                  SizedBox(width: 4),
                  Text('${poem.likeCount}', style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### Couplet Card (for Poem Reader)

```dart
class CoupletCard extends StatelessWidget {
  final Verse verse;
  final VoidCallback onLike;
  final VoidCallback onBookmark;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Verse text (RTL)
          Text(
            verse.verseText,
            style: AppTextStyles.urduBody.copyWith(fontSize: 20),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
          ),

          if (verse.translation != null) ...[
            SizedBox(height: 12),
            Text(
              verse.translation!,
              style: AppTextStyles.englishBody.copyWith(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 16),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border),
                onPressed: onLike,
                tooltip: 'Like',
              ),
              IconButton(
                icon: Icon(Icons.bookmark_border),
                onPressed: onBookmark,
                tooltip: 'Bookmark',
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: onShare,
                tooltip: 'Share',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 📊 Analytics & Tracking

### User Engagement Tracking

```dart
// lib/core/services/analytics_service.dart
class AnalyticsService {
  final ApiClient _api;

  Future<void> trackPoemView(String poemId, {int? durationSeconds}) async {
    await _api.post('/profile/engagement', data: {
      'activityType': 'VIEW',
      'targetType': 'POEM',
      'targetId': poemId,
      'durationSeconds': durationSeconds,
      'deviceType': Platform.isAndroid ? 'android' : 'ios',
    });
  }

  Future<void> trackSearch(String query, String type) async {
    await _api.post('/profile/engagement', data: {
      'activityType': 'SEARCH',
      'targetType': type,
      'metadata': jsonEncode({'query': query}),
    });
  }

  Future<void> trackCoupletShare(String coupletId) async {
    await _api.post('/couplets/$coupletId/share', data: {
      'platform': 'whatsapp', // or 'facebook', 'twitter'
    });
  }
}
```

---

## 🌍 Internationalization (i18n)

### Language Support

```dart
// lib/l10n/app_localizations.dart
class AppLocalizations {
  static const supportedLocales = [
    Locale('ur'),  // Urdu
    Locale('en'),  // English
    Locale('hi'),  // Hindi
    Locale('fa'),  // Persian
  ];

  // Translations
  String get home => _localized({
    'ur': 'گھر',
    'en': 'Home',
    'hi': 'होम',
    'fa': 'خانه',
  });

  String get search => _localized({
    'ur': 'تلاش',
    'en': 'Search',
    'hi': 'खोज',
    'fa': 'جستجو',
  });

  String get poets => _localized({
    'ur': 'شعراء',
    'en': 'Poets',
    'hi': 'कवि',
    'fa': 'شاعران',
  });
}
```

---

## 🔐 Security Best Practices

1. **Token Storage:** Use `flutter_secure_storage` for JWT tokens
2. **API Keys:** Never commit Firebase config or API keys to Git
3. **Certificate Pinning:** Implement for production API calls
4. **Input Validation:** Sanitize all user inputs before API calls
5. **Deep Link Validation:** Verify deep link parameters

---

## 🎬 Animations & Transitions

### Page Transitions

```dart
// Elegant slide transition
PageRouteBuilder(
  pageBuilder: (context, animation, secondaryAnimation) => PoemReaderScreen(),
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeInOut;

    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
    var offsetAnimation = animation.drive(tween);

    return SlideTransition(position: offsetAnimation, child: child);
  },
);
```

### Hero Animations

```dart
// From poem card to poem reader
Hero(
  tag: 'poem-${poem.publicId}',
  child: PoemCard(poem: poem),
)
```

---

## 📦 Essential Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^2.4.0

  # API & Networking
  dio: ^5.4.0
  retrofit: ^4.0.0

  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.15.0
  google_sign_in: ^6.1.5

  # Local Storage
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  flutter_secure_storage: ^9.0.0

  # UI Components
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  flutter_svg: ^2.0.9

  # Internationalization
  intl: ^0.18.1
  flutter_localizations:
    sdk: flutter

  # Utils
  share_plus: ^7.2.1
  url_launcher: ^6.2.2
  connectivity_plus: ^5.0.2
```

---

## 🎯 Testing Strategy

### Widget Tests

```dart
// test/features/poems/poem_card_test.dart
testWidgets('PoemCard displays poem information correctly', (tester) async {
  final poem = PoemSummary(
    publicId: 'test-poem',
    title: 'Test Poem',
    poetName: 'Test Poet',
    // ...
  );

  await tester.pumpWidget(
    MaterialApp(home: PoemCard(poem: poem)),
  );

  expect(find.text('Test Poem'), findsOneWidget);
  expect(find.text('Test Poet'), findsOneWidget);
});
```

### Integration Tests

```dart
// integration_test/app_test.dart
testWidgets('User can search and view poems', (tester) async {
  app.main();
  await tester.pumpAndSettle();

  // Navigate to search
  await tester.tap(find.byIcon(Icons.search));
  await tester.pumpAndSettle();

  // Enter search query
  await tester.enterText(find.byType(TextField), 'محبت');
  await tester.pumpAndSettle();

  // Tap on first result
  await tester.tap(find.byType(PoemCard).first);
  await tester.pumpAndSettle();

  // Verify poem reader opened
  expect(find.byType(PoemReaderScreen), findsOneWidget);
});
```

---

## 🚀 Deployment

### Build Commands

```bash
# Android Release
flutter build apk --release --dart-define=ENV=prod

# iOS Release
flutter build ios --release --dart-define=ENV=prod

# App Bundle (for Play Store)
flutter build appbundle --release --dart-define=ENV=prod
```

### Environment Variables

```bash
# Development
flutter run --dart-define=ENV=dev

# Production
flutter run --dart-define=ENV=prod
```

---

## 📚 Quick Reference

### Common API Calls

```dart
// Get featured poems
final poems = await api.get<List<PoemSummary>>(
  '/poems/featured',
  queryParameters: {'page': 0, 'size': 10},
  fromJson: (json) => (json as List).map((e) => PoemSummary.fromJson(e)).toList(),
);

// Search poems
final results = await api.get<List<PoemSummary>>(
  '/poems/search',
  queryParameters: {
    'query': 'محبت',
    'lang': 'ur',
    'page': 0,
    'size': 20,
  },
  fromJson: (json) => /* ... */,
);

// Get poet profile
final poet = await api.get<PoetDetail>(
  '/poets/${poetId}/profile',
  fromJson: PoetDetail.fromJson,
);

// Bookmark poem
await api.post('/poems/${poemId}/bookmark', queryParameters: {'lang': 'ur'});

// Get user bookmarks (unified)
final bookmarks = await api.get<List<UnifiedBookmark>>(
  '/bookmarks/recent',
  queryParameters: {'page': 0, 'size': 20},
  fromJson: /* ... */,
);
```

---

## 🎨 Design Resources

### Recommended Fonts

**Urdu/Arabic:**
- Noto Nastaliq Urdu (Primary)
- Jameel Noori Nastaleeq (Alternative)

**English:**
- Inter (UI elements, body text)
- Crimson Text (Headings, poetry titles)

**Installation:**
```yaml
# pubspec.yaml
fonts:
  - family: NotoNastaliqUrdu
    fonts:
      - asset: fonts/NotoNastaliqUrdu-Regular.ttf
      - asset: fonts/NotoNastaliqUrdu-Bold.ttf
        weight: 700

  - family: Inter
    fonts:
      - asset: fonts/Inter-Regular.ttf
      - asset: fonts/Inter-Bold.ttf
        weight: 700
```

### Color Inspiration

- **Persian Poetry:** Rich reds, deep blues, gold accents
- **Mughal Architecture:** Ivory, terracotta, jade green
- **Modern Minimal:** Generous white space, single accent color

---

## 💡 Pro Tips

1. **Performance:** Always use `const` constructors where possible
2. **RTL Support:** Test all screens with RTL text direction
3. **Accessibility:** Add semantic labels for screen readers
4. **Error Handling:** Show user-friendly error messages
5. **Loading States:** Use skeleton screens instead of spinners
6. **Empty States:** Provide helpful suggestions when no content
7. **Offline Mode:** Cache critical content for offline reading
8. **Deep Linking:** Support sharing individual poems/couplets
9. **Analytics:** Track user engagement for personalization
10. **A/B Testing:** Test different layouts and features

---

## 📞 Support & Resources

- **API Documentation:** `FLUTTER_API_DOCUMENTATION.md`
- **Backend API:** Port 8081 (local), Port 443 (production)
- **Firebase Console:** [Your Firebase Project]
- **Design Files:** [Figma/Adobe XD link]

---

**Built with ❤️ for Poetry Lovers**

*Last Updated: February 6, 2026*
