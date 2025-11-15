import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/main/main_screen.dart';
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
      ),
    ],
  );
});
