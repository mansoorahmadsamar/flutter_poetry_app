import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/features/auth/widgets/sign_in_prompt_sheet.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_book_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_image_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_video_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/services/poet_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poet_books_tab.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poet_gallery_tab.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/widgets/poet_videos_tab.dart';

import '../../../../../helpers/fake_auth_notifier.dart';

/// Records which authenticated poet endpoints were requested. Like
/// production, it answers 401 when called without a session; signed in, it
/// returns empty lists so the tab renders its empty state.
class _RecordingPoetService extends PoetService {
  _RecordingPoetService(Ref ref, {required this.signedIn}) : super(Dio(), ref);

  final bool signedIn;
  final List<String> calls = [];

  void _record(String call) {
    calls.add(call);
    if (!signedIn) {
      final request = RequestOptions(path: '/api/poets/p1/$call');
      throw DioException(
        requestOptions: request,
        response: Response(requestOptions: request, statusCode: 401),
        type: DioExceptionType.badResponse,
      );
    }
  }

  @override
  Future<List<PoetImageModel>> getPoetGallery(
      {required String publicId, String lang = 'ur'}) async {
    _record('gallery');
    return const [];
  }

  @override
  Future<List<PoetBookModel>> getPoetBooks(
      {required String publicId, String lang = 'ur'}) async {
    _record('books');
    return const [];
  }

  @override
  Future<List<PoetVideoModel>> getPoetVideos(
      {required String publicId, String? videoType}) async {
    _record('videos');
    return const [];
  }
}

class _Case {
  const _Case(this.name, this.build, this.call, this.emptyText);
  final String name;
  final Widget Function() build;
  final String call;
  final String emptyText;
}

final _cases = [
  _Case('Gallery', () => const PoetGalleryTab(publicId: 'p1'), 'gallery',
      'No images available'),
  _Case('Books', () => const PoetBooksTab(publicId: 'p1'), 'books',
      'No books available'),
  _Case('Videos', () => const PoetVideosTab(publicId: 'p1'), 'videos',
      'No videos available'),
];

/// Pumps [tab]; returns a getter for the service, which stays `null` when
/// the tab never builds it.
Future<_RecordingPoetService? Function()> _pump(
  WidgetTester tester,
  Widget tab, {
  required bool signedIn,
  String lang = 'en',
}) async {
  _RecordingPoetService? service;
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authOverride(signedIn
            ? FakeAuthNotifier.signedIn()
            : FakeAuthNotifier.guest()),
        selectedLanguageProvider.overrideWithValue(lang),
        poetServiceProvider.overrideWith(
            (ref) => service = _RecordingPoetService(ref, signedIn: signedIn)),
      ],
      child: MaterialApp(home: Scaffold(body: tab)),
    ),
  );
  await tester.pump();
  await tester.pump();
  return () => service;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  for (final c in _cases) {
    group('Poet ${c.name} tab', () {
      for (final lang in ['ur', 'en']) {
        testWidgets(
            'regression: a guest sees a sign-in prompt, no API call ($lang)',
            (tester) async {
          final service = await _pump(tester, c.build(),
              signedIn: false, lang: lang);

          expect(tester.takeException(), isNull);
          expect(find.text('Sign in'), findsOneWidget);
          expect(find.text(c.name), findsOneWidget);
          expect(find.textContaining('Error'), findsNothing);
          expect(find.textContaining('401'), findsNothing);
          // The service was never even built, let alone called.
          expect(service()?.calls ?? const <String>[], isEmpty);
        });
      }

      testWidgets('a guest tapping Sign in opens the sign-in sheet',
          (tester) async {
        await _pump(tester, c.build(), signedIn: false);
        await tester.tap(find.text('Sign in'));
        await tester.pumpAndSettle();
        expect(find.byType(SignInPromptSheet), findsOneWidget);
      });

      testWidgets('a signed-in user loads the tab from the API',
          (tester) async {
        final service = await _pump(tester, c.build(), signedIn: true);
        expect(service()!.calls, [c.call]);
        expect(find.text(c.emptyText), findsOneWidget);
        expect(find.text('Sign in'), findsNothing);
      });
    });
  }
}
