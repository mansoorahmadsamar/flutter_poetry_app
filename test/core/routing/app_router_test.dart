import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/core/routing/app_router.dart';
import 'package:flutter_poetry_app/features/auth/login_screen.dart';
import 'package:flutter_poetry_app/features/auth/widgets/session_expired_notice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/auth_harness.dart';
import '../../helpers/fake_dio_adapter.dart';

const _feed = '/api/feed';
const _refresh = AppConstants.authRefreshPath;

/// The real redirect and navigation with light screens: the real login
/// screen, placeholders for the rest.
final _testRoutes = <RouteBase>[
  GoRoute(path: '/', builder: (_, __) => const Text('splash')),
  GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
  GoRoute(
    path: '/main',
    builder: (_, __) => const Text('main screen'),
    routes: [
      GoRoute(
        path: 'poems/:publicId',
        builder: (_, state) => Text('poem ${state.pathParameters['publicId']}'),
      ),
      GoRoute(path: 'creator', builder: (_, __) => const Text('creator')),
    ],
  ),
];

String _location(GoRouter router) =>
    router.routerDelegate.currentConfiguration.uri.toString();

AuthHarness? _harness;
AuthHarness get h => _harness!;
set h(AuthHarness value) => _harness = value;

void main() {
  tearDown(() {
    _harness?.dispose();
    _harness = null;
  });

  group('appRedirect', () {
    const restoring = (isAuthenticated: false, isRestoringSession: true);
    const guest = (isAuthenticated: false, isRestoringSession: false);
    const signedIn = (isAuthenticated: true, isRestoringSession: false);

    test('holds every route on splash while the session is restored', () {
      expect(appRedirect(restoring, '/'), isNull);
      expect(appRedirect(restoring, '/main'), '/');
    });

    test('splash forwards to main or login once restored', () {
      expect(appRedirect(signedIn, '/'), '/main');
      expect(appRedirect(guest, '/'), '/login');
    });

    test('guests browse open routes but not account-only ones', () {
      expect(appRedirect(guest, '/main/poems/abc'), isNull);
      expect(appRedirect(guest, '/main/creator/compose'), '/login');
      expect(appRedirect(guest, '/main/become-poet'), '/login');
      expect(appRedirect(guest, '/bookmarks/search'), '/login');
    });

    test('signed-in users are sent from login to main', () {
      expect(appRedirect(signedIn, '/login'), '/main');
      expect(appRedirect(signedIn, '/main/creator'), isNull);
    });
  });

  group('routerProvider is built once', () {
    test('regression: a token refresh does not build a new GoRouter (T-043)', () async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      await h.restored();
      final before = h.container.read(routerProvider);

      h.adapter.on('POST', _refresh, (_) => FakeReply(200, refreshSuccessBody()));
      expect(await h.notifier.refreshAccessToken(), isTrue);
      expect(h.auth.accessToken, refreshedAccessToken);

      expect(identical(h.container.read(routerProvider), before), isTrue);
    });

    test('signing out does not build a new GoRouter either', () async {
      h = await AuthHarness.create(
        accessToken: validAccessToken,
        refreshToken: validRefreshToken,
      );
      await h.restored();
      final before = h.container.read(routerProvider);
      await h.notifier.logout();
      expect(identical(h.container.read(routerProvider), before), isTrue);
    });
  });

  group('navigation through the real router', () {
    void phoneScreen(WidgetTester tester) {
      tester.view.physicalSize = const Size(412, 892) * 3;
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
    }

    Future<GoRouter> pumpApp(WidgetTester tester) async {
      final router = h.container.read(routerProvider);
      await tester.pumpWidget(UncontrolledProviderScope(
        container: h.container,
        child: MaterialApp.router(routerConfig: router),
      ));
      await tester.pump();
      return router;
    }

    Future<void> settle(WidgetTester tester) async {
      // Let the fake network and sign-out run, then let routing catch up.
      // The login screen animates forever, so pump a bounded time.
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1500));
    }

    Future<void> signedIn(WidgetTester tester) async {
      await tester.runAsync(() async {
        h = await AuthHarness.create(
          accessToken: validAccessToken,
          refreshToken: validRefreshToken,
          overrides: [appRoutesProvider.overrideWithValue(_testRoutes)],
        );
        await h.restored();
      });
    }

    testWidgets('a token refresh keeps the user on the page they were reading',
        (tester) async {
      await signedIn(tester);
      final router = await pumpApp(tester);
      router.go('/main/poems/abc');
      await tester.pumpAndSettle();
      expect(find.text('poem abc'), findsOneWidget);

      h.adapter
        ..on('GET', _feed, (o) => o.headers['Authorization'] ==
                '${AppConstants.bearerPrefix} $refreshedAccessToken'
            ? const FakeReply(200, {'success': true})
            : const FakeReply(401))
        ..on('POST', _refresh, (_) => FakeReply(200, refreshSuccessBody()));
      await tester.runAsync(() => h.dio.get(_feed));
      await tester.pumpAndSettle();

      expect(h.refreshCalls, 1);
      expect(_location(router), '/main/poems/abc');
      expect(find.text('poem abc'), findsOneWidget);
    });

    testWidgets('regression: 401 + refused refresh ends on the login screen with the notice',
        (tester) async {
      phoneScreen(tester);
      await signedIn(tester);
      final router = await pumpApp(tester);
      router.go('/main/poems/abc');
      await tester.pump();

      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply(401));
      await tester.runAsync(() async {
        await h.dio.get(_feed).then((_) {}, onError: (_) {});
        await h.authWhere((s) => s.sessionExpired);
      });
      await settle(tester);

      expect(_location(router), '/login');
      expect(find.text(SessionExpiredNotice.title), findsOneWidget);
      expect(await tester.runAsync(h.storage.getAccessToken), isNull);

      // Guest mode is one tap away, and the notice goes with it.
      await tester.tap(find.byKey(const Key('continue-as-guest')));
      await settle(tester);
      expect(_location(router), '/main');
      expect(h.auth.isGuest, isTrue);
      expect(h.auth.sessionExpired, isFalse);
    });

    testWidgets('an expired session at app start opens the login screen with the notice',
        (tester) async {
      phoneScreen(tester);
      await tester.runAsync(() async {
        h = await AuthHarness.create(
          accessToken: expiredAccessToken,
          refreshToken: expiredRefreshToken,
          overrides: [appRoutesProvider.overrideWithValue(_testRoutes)],
        );
        await h.restored();
      });
      final router = await pumpApp(tester);
      await settle(tester);

      expect(_location(router), '/login');
      expect(find.text(SessionExpiredNotice.title), findsOneWidget);
    });

    testWidgets('a lost connection does not sign out or leave the page', (tester) async {
      await signedIn(tester);
      final router = await pumpApp(tester);
      router.go('/main/poems/abc');
      await tester.pump();

      h.adapter
        ..on('GET', _feed, (_) => const FakeReply(401))
        ..on('POST', _refresh, (_) => const FakeReply.offline());
      await tester.runAsync(() => h.dio.get(_feed).then((_) {}, onError: (_) {}));
      await tester.pump();

      expect(_location(router), '/main/poems/abc');
      expect(h.auth.isAuthenticated, isTrue);
    });

    testWidgets('logout from anywhere goes to login without the expiry notice',
        (tester) async {
      phoneScreen(tester);
      await signedIn(tester);
      final router = await pumpApp(tester);
      router.go('/main/poems/abc');
      await tester.pump();

      await tester.runAsync(h.notifier.logout);
      await settle(tester);

      expect(_location(router), '/login');
      expect(find.byType(SessionExpiredNotice), findsNothing);
    });

    testWidgets('a guest opening an account-only route is sent to login', (tester) async {
      phoneScreen(tester);
      await tester.runAsync(() async {
        h = await AuthHarness.create(
          overrides: [appRoutesProvider.overrideWithValue(_testRoutes)],
        );
        await h.restored();
      });
      final router = await pumpApp(tester);
      await settle(tester);
      router.go('/main/creator');
      await settle(tester);
      expect(_location(router), '/login');
    });
  });
}
