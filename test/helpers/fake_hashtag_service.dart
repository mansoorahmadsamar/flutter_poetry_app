import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/hashtags/models/hashtag_model.dart';
import 'package:flutter_poetry_app/features/hashtags/screens/hashtag_detail_screen.dart';
import 'package:flutter_poetry_app/features/hashtags/services/hashtag_service.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/couplet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_dio_adapter.dart';

PaginatedResponse<T> emptyHashtagPage<T>() => PaginatedResponse<T>(
      content: const [],
      totalElements: 0,
      totalPages: 0,
      last: true,
      first: true,
      size: 10,
      number: 0,
    );

/// Serves fixed metadata and empty tabs, and records which tab endpoints were
/// asked for. Never touches the network.
class FakeHashtagService extends HashtagService {
  FakeHashtagService(this.meta) : super(Dio());

  final HashtagDto meta;

  /// `couplets`, `poems`, `images`, `poets` — one entry per tab request.
  final List<String> tabRequests = [];

  @override
  Future<HashtagDto> getHashtagMeta(String slug) async => meta;

  @override
  Future<PaginatedResponse<CoupletDetailResponse>> getCoupletsByHashtag(
      String slug,
      {String lang = 'ur',
      int page = 0,
      int size = 10}) async {
    tabRequests.add('couplets');
    return emptyHashtagPage();
  }

  @override
  Future<PaginatedResponse<PoemModel>> getPoemsByHashtag(String slug,
      {String lang = 'ur', int page = 0, int size = 10}) async {
    tabRequests.add('poems');
    return emptyHashtagPage();
  }

  @override
  Future<PaginatedResponse<Map<String, dynamic>>> getImagesByHashtag(
      String slug,
      {int page = 0,
      int size = 20}) async {
    tabRequests.add('images');
    return emptyHashtagPage();
  }

  @override
  Future<PaginatedResponse<PoetModel>> getPoetsByHashtag(String slug,
      {String lang = 'ur', int page = 0, int size = 20}) async {
    tabRequests.add('poets');
    return emptyHashtagPage();
  }
}

/// A real [HashtagService] over a [FakeDioAdapter]: `/api/hashtags/<slug>`
/// answers [meta] (the `data` of the envelope) and
/// `/api/hashtags/<slug>/couplets` answers [couplets] (a whole envelope, e.g.
/// a fixture). Other tab endpoints answer 404.
HashtagService hashtagServiceOverAdapter({
  required String slug,
  required Map<String, dynamic> meta,
  required Map<String, dynamic> couplets,
}) {
  final adapter = FakeDioAdapter()
    ..on('GET', '/api/hashtags/$slug',
        (_) => FakeReply(200, {'success': true, 'message': 'ok', 'data': meta}))
    ..on('GET', '/api/hashtags/$slug/couplets', (_) => FakeReply(200, couplets));
  return HashtagService(
      Dio(BaseOptions(baseUrl: 'http://fake'))..httpClientAdapter = adapter);
}

/// Pumps [HashtagDetailScreen] for [slug] inside a [GoRouter] whose poem route
/// shows `poem:<id>`, so tap tests can assert where a tap went.
Future<GoRouter> pumpHashtagScreen(
  WidgetTester tester, {
  required String slug,
  required HashtagService service,
  String lang = 'en',
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => HashtagDetailScreen(slug: slug),
      ),
      GoRoute(
        path: '/main/poems/:publicId',
        builder: (_, state) => Text('poem:${state.pathParameters['publicId']}'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(lang),
        hashtagServiceProvider.overrideWithValue(service),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  // Let the metadata future and the visible tab's first load complete. A
  // real Dio (see [hashtagServiceOverAdapter]) finishes outside fake time.
  // Wait (bounded) until no spinner is left rather than for a fixed number of
  // turns, so a slower machine cannot make this flaky.
  for (var i = 0; i < 50; i++) {
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    await tester.pump(const Duration(milliseconds: 50));
    if (find.byType(CircularProgressIndicator).evaluate().isEmpty) break;
  }
  return router;
}
