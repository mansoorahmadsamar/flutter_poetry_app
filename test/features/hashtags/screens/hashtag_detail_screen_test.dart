import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/core/design_system/app_colors.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/hashtags/screens/hashtag_detail_screen.dart';
import 'package:flutter_poetry_app/features/hashtags/services/hashtag_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';

PaginatedResponse<T> _emptyPage<T>() => PaginatedResponse<T>(
      content: const [],
      totalElements: 0,
      totalPages: 0,
      last: true,
      first: true,
      size: 10,
      number: 0,
    );

/// Serves fixed metadata and empty tabs; never touches the network.
class _FakeHashtagService extends HashtagService {
  _FakeHashtagService(this.meta) : super(Dio());

  final HashtagDto meta;

  @override
  Future<HashtagDto> getHashtagMeta(String slug) async => meta;

  @override
  Future<PaginatedResponse<CoupletDetailResponse>> getCoupletsByHashtag(
          String slug,
          {String lang = 'ur',
          int page = 0,
          int size = 10}) async =>
      _emptyPage();

  @override
  Future<PaginatedResponse<PoemModel>> getPoemsByHashtag(String slug,
          {String lang = 'ur', int page = 0, int size = 10}) async =>
      _emptyPage();

  @override
  Future<PaginatedResponse<Map<String, dynamic>>> getImagesByHashtag(
          String slug,
          {int page = 0,
          int size = 20}) async =>
      _emptyPage();

  @override
  Future<PaginatedResponse<PoetModel>> getPoetsByHashtag(String slug,
          {String lang = 'ur', int page = 0, int size = 20}) async =>
      _emptyPage();
}

Future<void> _pump(WidgetTester tester, HashtagDto meta,
    {String lang = 'en'}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(lang),
        hashtagServiceProvider.overrideWithValue(_FakeHashtagService(meta)),
      ],
      child: MaterialApp(home: HashtagDetailScreen(slug: meta.slug)),
    ),
  );
  // Let the metadata future and the tabs' first loads complete.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

Color? _tabLabelColour(WidgetTester tester) =>
    tester.widget<TabBar>(find.byType(TabBar)).labelColor;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  group('HashtagDetailScreen colour', () {
    testWidgets('regression: "-" colour does not throw and uses the primary',
        (tester) async {
      await _pump(tester, const HashtagDto(slug: 'ishq', name: 'ishq', color: '-'));
      expect(tester.takeException(), isNull);
      expect(find.text('#ishq'), findsOneWidget);
      expect(_tabLabelColour(tester), AppColors.primary);
    });

    testWidgets('a valid colour tints the tabs', (tester) async {
      await _pump(tester, const HashtagDto(slug: 'dil', color: '#1A2B3C'));
      expect(_tabLabelColour(tester), const Color(0xFF1A2B3C));
    });

    testWidgets('Urdu: "-" colour renders the RTL screen', (tester) async {
      const name = 'محبت';
      await _pump(
        tester,
        const HashtagDto(slug: 'mohabbat', name: name, color: '-'),
        lang: 'ur',
      );
      expect(tester.takeException(), isNull);
      expect(find.text('#$name'), findsOneWidget);
      expect(Directionality.of(tester.element(find.text('#$name'))),
          TextDirection.rtl);
      expect(_tabLabelColour(tester), AppColors.primary);
    });
  });
}
