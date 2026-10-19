import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/constants/app_constants.dart';
import 'package:flutter_poetry_app/features/auth/login_screen.dart';
import 'package:flutter_poetry_app/features/auth/widgets/session_expired_notice.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../helpers/auth_harness.dart';
import '../../helpers/fake_dio_adapter.dart';

/// A phone-sized screen (Pixel 7 Pro logical size) — the login layout is
/// designed for phones, not the 800x600 test default.
void _phoneScreen(WidgetTester tester) {
  tester.view.physicalSize = const Size(412, 892) * 3;
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _pumpLogin(
  WidgetTester tester,
  AuthHarness h, {
  TextDirection direction = TextDirection.ltr,
}) async {
  final router = GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/main', builder: (_, __) => const Text('main screen')),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(UncontrolledProviderScope(
    container: h.container,
    child: MaterialApp.router(
      routerConfig: router,
      builder: (context, child) =>
          Directionality(textDirection: direction, child: child!),
    ),
  ));
  // The login screen animates forever (calligraphy shimmer): pump a bounded time.
  await tester.pump(const Duration(milliseconds: 1500));
}

void main() {
  late AuthHarness h;

  Future<void> expiredAtStartup(WidgetTester tester) async {
    await tester.runAsync(() async {
      h = await AuthHarness.create(
        accessToken: expiredAccessToken,
        refreshToken: validRefreshToken,
      );
      h.adapter.on('POST', AppConstants.authRefreshPath, (_) => const FakeReply(401));
      await h.restored();
    });
    expect(h.auth.sessionExpired, isTrue);
  }

  tearDown(() => h.dispose());

  testWidgets('after an expired session the login screen explains it', (tester) async {
    _phoneScreen(tester);
    await expiredAtStartup(tester);
    await _pumpLogin(tester, h);

    expect(find.text(SessionExpiredNotice.title), findsOneWidget);
    expect(find.text(SessionExpiredNotice.message), findsOneWidget);
    expect(find.text('Continue as guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a normal visit to login shows no expiry notice', (tester) async {
    _phoneScreen(tester);
    await tester.runAsync(() async {
      h = await AuthHarness.create();
      await h.restored();
    });
    await _pumpLogin(tester, h);

    expect(find.byType(SessionExpiredNotice), findsNothing);
  });

  testWidgets('"Continue as guest" clears the notice and opens the app as a guest',
      (tester) async {
    _phoneScreen(tester);
    await expiredAtStartup(tester);
    await _pumpLogin(tester, h);

    await tester.tap(find.byKey(const Key('continue-as-guest')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('main screen'), findsOneWidget);
    expect(h.auth.sessionExpired, isFalse);
    expect(h.auth.isGuest, isTrue);
  });

  testWidgets('the notice lays out right-to-left without overflow', (tester) async {
    _phoneScreen(tester);
    await expiredAtStartup(tester);
    await _pumpLogin(tester, h, direction: TextDirection.rtl);

    expect(find.byType(SessionExpiredNotice), findsOneWidget);
    expect(tester.takeException(), isNull);
    final notice = tester.getRect(find.byKey(const Key('session-expired-notice')));
    final icon = tester.getRect(find.byIcon(Icons.lock_clock_outlined));
    // RTL: the icon sits on the right edge of the notice.
    expect(icon.center.dx, greaterThan(notice.center.dx));
  });
}
