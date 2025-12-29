import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/main/main_screen.dart';
import '../../features/main/tabs/poets/screens/poet_detail_screen.dart';
import '../../features/main/tabs/poets/screens/poem_detail_screen.dart';
import '../../features/search/screens/poets_search_screen.dart';
import '../../features/engagement/screens/bookmark_search_screen.dart';
import '../../features/engagement/screens/bookmarked_couplets_screen.dart';
import '../../features/image_poetry/screens/template_selection_screen.dart';
import '../../features/image_poetry/screens/image_generation_screen.dart';
import '../../features/image_poetry/screens/generated_image_gallery_screen.dart';
import '../../features/image_poetry/screens/saved_images_screen.dart';
import '../../features/image_poetry/screens/image_detail_screen.dart';
import '../../features/image_poetry/editor/screens/poetry_editor_screen.dart';
import '../auth/auth_provider.dart';

/// App routes
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
}

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

      // If still loading, stay on splash
      if (isLoading && currentLocation != AppRoutes.splash) {
        return AppRoutes.splash;
      }

      // If on splash and not loading
      if (currentLocation == AppRoutes.splash && !isLoading) {
        return isAuthenticated ? AppRoutes.main : AppRoutes.login;
      }

      // If not authenticated and trying to access main, redirect to login
      if (!isAuthenticated && currentLocation == AppRoutes.main) {
        return AppRoutes.login;
      }

      // If authenticated and trying to access login, redirect to main
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
            builder: (context, state) => PoetDetailScreen(
              publicId: state.pathParameters['publicId']!,
            ),
          ),
          GoRoute(
            path: 'poems/:publicId',
            builder: (context, state) => PoemDetailScreen(
              publicId: state.pathParameters['publicId']!,
            ),
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
        builder: (context, state) => ImageDetailScreen(
          imageId: state.pathParameters['imageId']!,
        ),
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
    ],
  );
});
