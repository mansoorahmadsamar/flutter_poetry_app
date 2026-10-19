import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/feed/providers/feed_provider.dart';
import 'package:flutter_poetry_app/features/feed/screens/feed_screen.dart';

/// Holds a fixed empty, loaded feed so the screen never calls the API.
class _FakeFeedNotifier extends StateNotifier<FeedState>
    implements FeedNotifier {
  _FakeFeedNotifier() : super(const FeedState(isInitial: false));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('the feed app-bar bell has a "Notifications" label',
      (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue('ur'),
        feedProvider.overrideWith((ref) => _FakeFeedNotifier()),
      ],
      child: const MaterialApp(home: FeedScreen()),
    ));
    await tester.pump();

    expect(find.byTooltip('Notifications'), findsOneWidget);
    expect(
      tester.getSemantics(find.byTooltip('Notifications')),
      isSemantics(
        tooltip: 'Notifications',
        isButton: true,
        hasTapAction: true,
      ),
    );
    handle.dispose();
  });
}
