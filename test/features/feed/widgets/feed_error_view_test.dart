import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/network/request_failure.dart';
import 'package:flutter_poetry_app/features/feed/widgets/feed_error_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_config.dart';

void main() {
  setUpAll(setUpTestConfig);

  Future<void> pump(
    WidgetTester tester,
    RequestFailureKind kind, {
    TextDirection direction = TextDirection.ltr,
    VoidCallback? onRetry,
  }) {
    return tester.pumpWidget(MaterialApp(
      home: Directionality(
        textDirection: direction,
        child: Scaffold(
          body: FeedErrorView(kind: kind, onRetry: onRetry ?? () {}, isDark: false),
        ),
      ),
    ));
  }

  testWidgets('offline says offline, not "session expired"', (tester) async {
    await pump(tester, RequestFailureKind.offline);
    expect(find.text("You're offline"), findsOneWidget);
    expect(find.text('Check your internet connection and try again.'), findsOneWidget);
    expect(find.textContaining('session'), findsNothing);
  });

  testWidgets('an expired session says so, not "check your connection"', (tester) async {
    await pump(tester, RequestFailureKind.sessionExpired);
    expect(find.text('Your session has expired'), findsOneWidget);
    expect(find.textContaining('connection'), findsNothing);
  });

  testWidgets('a server failure does not blame the connection', (tester) async {
    await pump(tester, RequestFailureKind.server);
    expect(find.text('Could not load feed'), findsOneWidget);
    expect(find.textContaining('connection'), findsNothing);
  });

  testWidgets('each kind has distinct copy', (tester) async {
    final messages = RequestFailureKind.values.map((k) => feedErrorCopy(k).message).toSet();
    expect(messages, hasLength(RequestFailureKind.values.length));
  });

  testWidgets('renders in an RTL (Urdu) layout without overflow and retry works',
      (tester) async {
    var retried = 0;
    await pump(tester, RequestFailureKind.offline,
        direction: TextDirection.rtl, onRetry: () => retried++);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Retry'));
    expect(retried, 1);
  });
}
