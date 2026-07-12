import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/main/main_screen.dart';
import '../../features/main/tabs/poets/screens/poet_detail_screen.dart';
import '../../features/main/tabs/poets/screens/poem_detail_screen.dart';
import '../../features/main/tabs/creator/screens/become_poet_intro_screen.dart';
import '../../features/main/tabs/creator/screens/new_poet_form_screen.dart';
import '../../features/main/tabs/creator/screens/claim_poet_search_screen.dart';
import '../../features/main/tabs/creator/screens/claim_poet_submit_screen.dart';
import '../../features/main/tabs/creator/screens/creator_dashboard_screen.dart';
import '../../features/main/tabs/creator/screens/compose_poem_screen.dart';
import '../../features/main/tabs/creator/screens/edit_poem_screen.dart';
import '../../features/main/tabs/creator/screens/edit_profile_screen.dart';
import '../../features/main/tabs/creator/screens/manage_translations_screen.dart';
import '../../features/main/tabs/creator/screens/manage_facts_screen.dart';
import '../../features/main/tabs/creator/screens/upload_book_screen.dart';
import '../../features/main/tabs/creator/screens/creator_image_detail_screen.dart';
import '../../features/main/tabs/creator/models/creator_image_model.dart';
import '../../features/search/screens/poets_search_screen.dart';
import '../../features/search/screens/app_search_screen.dart';
import '../../features/search/screens/category_results_screen.dart';
import '../../features/engagement/screens/bookmark_search_screen.dart';
import '../../features/engagement/screens/bookmarked_couplets_screen.dart';
import '../../features/image_poetry/screens/template_selection_screen.dart';
import '../../features/image_poetry/screens/image_generation_screen.dart';
import '../../features/image_poetry/screens/generated_image_gallery_screen.dart';
import '../../features/image_poetry/screens/saved_images_screen.dart';
import '../../features/image_poetry/screens/image_detail_screen.dart';
import '../../features/image_poetry/editor/screens/poetry_editor_screen.dart';
import '../../features/hashtags/screens/hashtag_detail_screen.dart';
import '../auth/auth_provider.dart';

/// App routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
}

/// Routes that REQUIRE an authenticated user. A guest who navigates to any
/// of these (or a nested route under them) is bounced to /login. Everything
/// else in the app is reachable as a guest — read-only browse, search, poet
/// and poem detail, image generation entry, etc.
///
/// Keep this list tight: account-tied surfaces only. Per-action gating for
/// individual writes (bookmark, like, follow) happens via SignInPromptSheet,
/// not at the route level.
const _authRequiredPrefixes = <String>[
  '/main/become-poet',
  '/main/creator',
  '/bookmarks',
];

bool _requiresAuth(String location) =>
    _authRequiredPrefixes.any(location.startsWith);

/// Router provider
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final currentLocation = state.matchedLocation;

      // While the stored session is being resolved, stay on splash so the
      // app doesn't briefly flash the login screen before authed routes load.
      if (isLoading && currentLocation != AppRoutes.splash) {
        return AppRoutes.splash;
      }

      // Once auth has settled, splash routes forward: authenticated users go
      // straight to /main; everyone else lands on the login screen first.
      // The login screen offers Sign in with Apple, Sign in with Google, and
      // an explicit "Continue without signing in" affordance — so guests opt
      // into browsing deliberately rather than skipping login automatically.
      if (currentLocation == AppRoutes.splash && !isLoading) {
        return isAuthenticated ? AppRoutes.main : AppRoutes.login;
      }

      // Guests who chose to browse can reach open surfaces freely; only
      // account-only surfaces bounce them back to /login. Reading poetry is
      // never gated — required for App Store Guideline 5.1.1(v).
      if (!isAuthenticated && _requiresAuth(currentLocation)) {
        return AppRoutes.login;
      }

      // Already-authed users land back on /main if they re-open /login.
      if (isAuthenticated && currentLocation == AppRoutes.login) {
        return AppRoutes.main;
      }

      // No redirect needed
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.main,
        builder: (context, state) => const MainScreen(),
        routes: [
          GoRoute(
            path: 'poets-search',
            builder: (context, state) => const PoetsSearchScreen(),
          ),
          GoRoute(
            path: 'poets/:publicId',
            name: 'poet-detail',
            builder: (context, state) => PoetDetailScreen(
              publicId: state.pathParameters['publicId']!,
            ),
          ),
          GoRoute(
            path: 'poems/:publicId',
            name: 'poem-detail',
            builder: (context, state) => PoemDetailScreen(
              publicId: state.pathParameters['publicId']!,
            ),
          ),
          // ── Poet Mode (creator onboarding + dashboard) ──
          GoRoute(
            path: 'become-poet',
            name: 'become-poet',
            builder: (context, state) => const BecomePoetIntroScreen(),
            routes: [
              GoRoute(
                path: 'new',
                name: 'become-poet-new',
                builder: (context, state) => const NewPoetFormScreen(),
              ),
              GoRoute(
                path: 'claim',
                name: 'become-poet-claim',
                builder: (context, state) => const ClaimPoetSearchScreen(),
                routes: [
                  GoRoute(
                    path: ':publicId',
                    name: 'become-poet-claim-submit',
                    builder: (context, state) => ClaimPoetSubmitScreen(
                      publicId: state.pathParameters['publicId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: 'creator',
            name: 'creator-dashboard',
            builder: (context, state) => const CreatorDashboardScreen(),
            routes: [
              GoRoute(
                path: 'compose',
                name: 'creator-compose',
                builder: (context, state) => const ComposePoemScreen(),
              ),
              GoRoute(
                path: 'poems/:publicId/edit',
                name: 'creator-poem-edit',
                builder: (context, state) => EditPoemScreen(
                  publicId: state.pathParameters['publicId']!,
                ),
              ),
              GoRoute(
                path: 'profile/edit',
                name: 'creator-profile-edit',
                builder: (context, state) => const EditProfileScreen(),
              ),
              GoRoute(
                path: 'translations/:lang',
                name: 'creator-translations',
                builder: (context, state) => ManageTranslationsScreen(
                  initialLang: state.pathParameters['lang'] ?? 'en',
                ),
              ),
              GoRoute(
                path: 'books/new',
                name: 'creator-book-new',
                builder: (context, state) => const UploadBookScreen(),
              ),
              GoRoute(
                path: 'facts',
                name: 'creator-facts',
                builder: (context, state) => const ManageFactsScreen(),
              ),
              GoRoute(
                path: 'images/:id',
                name: 'creator-image-detail',
                builder: (context, state) {
                  // The gallery passes the already-loaded CreatorImage as
                  // `extra` to avoid an extra fetch on push. Deep-link
                  // callers without the object aren't supported yet
                  // (would need an image-by-id fetch endpoint).
                  final image = state.extra as CreatorImage?;
                  if (image == null) {
                    return const Scaffold(
                      body: Center(child: Text('Image not available')),
                    );
                  }
                  return CreatorImageDetailScreen(image: image);
                },
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/bookmarks/search',
        name: 'bookmark-search',
        builder: (context, state) => const BookmarkSearchScreen(),
      ),
      GoRoute(
        path: '/bookmarks/couplets',
        name: 'bookmarked-couplets',
        builder: (context, state) => const BookmarkedCoupletsScreen(),
      ),
      // Image poetry routes
      GoRoute(
        path: '/image-poetry/templates',
        name: 'template-selection',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final coupletId = extra?['coupletId'] as String? ?? '';
          return TemplateSelectionScreen(coupletId: coupletId);
        },
      ),
      GoRoute(
        path: '/image-poetry/generate/:coupletId',
        name: 'image-generation',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ImageGenerationScreen(
            coupletId: state.pathParameters['coupletId']!,
            templateId: extra?['templateId'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/image-poetry/couplet/:coupletId/gallery',
        name: 'couplet-image-gallery',
        builder: (context, state) => GeneratedImageGalleryScreen(
          coupletId: state.pathParameters['coupletId']!,
        ),
      ),
      GoRoute(
        path: '/image-poetry/saved',
        name: 'saved-images',
        builder: (context, state) => const SavedImagesScreen(),
      ),
      GoRoute(
        path: '/image-poetry/image/:imageId',
        name: 'image-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ImageDetailScreen(
            imageId: state.pathParameters['imageId']!,
            imageUrl: extra?['imageUrl'] as String?,
          );
        },
      ),
      // Generic image poetry detail route (for bookmark navigation)
      GoRoute(
        path: '/image-poetry/:contentId',
        name: 'image-poetry-detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ImageDetailScreen(
            imageId: state.pathParameters['contentId']!,
            imageUrl: extra?['imageUrl'] as String?,
          );
        },
      ),
      // Poetry Editor (NEW - Canvas-based editor)
      GoRoute(
        path: '/poetry-editor',
        name: 'poetry-editor',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PoetryEditorScreen(
            coupletId: extra?['coupletId'] as String?,
            initialVerses: extra?['verses'] as List<String>?,
          );
        },
      ),
      // Hashtag routes
      GoRoute(
        path: '/hashtags/:slug',
        name: 'hashtag-detail',
        builder: (context, state) => HashtagDetailScreen(
          slug: state.pathParameters['slug']!,
        ),
      ),
      // Global Search routes
      GoRoute(
        path: '/search',
        name: 'global-search',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return AppSearchScreen(
            initialQuery: extra?['query'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/search/results/:category',
        name: 'category-results',
        builder: (context, state) {
          final category = state.pathParameters['category']!;
          final extra = state.extra as Map<String, dynamic>?;
          return CategoryResultsScreen(
            query: extra?['query'] as String? ?? '',
            sortBy: extra?['sortBy'] as String? ?? 'relevance',
            category: category,
            poetId: extra?['poetId'] as String?,
          );
        },
      ),
    ],
  );
});
