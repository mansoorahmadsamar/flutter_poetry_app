import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_event.dart';
import 'package:flutter_poetry_app/features/feed/models/feed_response.dart';
import 'package:flutter_poetry_app/features/feed/providers/feed_provider.dart';
import 'package:flutter_poetry_app/features/feed/services/feed_service.dart';

/// Pumps a feed card with the providers it reads overridden, so no auth,
/// storage or network is touched. [appLang] is the app's UI language.
Future<void> pumpFeedCard(
  WidgetTester tester,
  Widget card, {
  String appLang = 'en',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(appLang),
        reactionTypesProvider
            .overrideWith((ref) async => const <ReactionType>[]),
      ],
      child: MaterialApp(
        home: Scaffold(body: SingleChildScrollView(child: card)),
      ),
    ),
  );
  await tester.pump();
}

/// Like [pumpFeedCard], but inside a [GoRouter] whose poet, poem and hashtag
/// routes show `poet:<id>` / `poem:<id>` / `hashtag:<slug>`, so tap tests can
/// assert where a tap went (the poem's `?couplet=` is in
/// `router.state.uri.queryParameters`). Returns the router; its location
/// starts at `/`.
Future<GoRouter> pumpFeedCardInRouter(
  WidgetTester tester,
  Widget card, {
  String appLang = 'en',
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, __) => Scaffold(body: SingleChildScrollView(child: card)),
      ),
      GoRoute(
        path: '/main/poets/:publicId',
        builder: (_, state) => Text('poet:${state.pathParameters['publicId']}'),
      ),
      GoRoute(
        path: '/main/poems/:publicId',
        builder: (_, state) => Text('poem:${state.pathParameters['publicId']}'),
      ),
      GoRoute(
        path: '/hashtags/:slug',
        builder: (_, state) => Text('hashtag:${state.pathParameters['slug']}'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        selectedLanguageProvider.overrideWithValue(appLang),
        reactionTypesProvider
            .overrideWith((ref) async => const <ReactionType>[]),
        // Card taps record an engagement event on the feed notifier; give it
        // a service that never loads or sends anything.
        feedProvider.overrideWith((ref) => FeedNotifier(
              feedService: IdleFeedService(),
              lang: appLang,
              ref: ref,
            )),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pump();
  return router;
}

/// A [FeedService] whose feed never arrives and whose events go nowhere.
class IdleFeedService implements FeedService {
  @override
  Future<FeedResponse> getFeed({
    String lang = 'ur',
    String? cursor,
    int limit = 20,
    bool refresh = false,
  }) =>
      Completer<FeedResponse>().future;

  @override
  Future<void> sendEvents(List<FeedEvent> events) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}
