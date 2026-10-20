import 'package:flutter/material.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/routing/app_router.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/creator/providers/creator_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poem_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poem_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'fake_hashtag_service.dart';

/// The app's real poem route (`/main/poems/:publicId`, from
/// `appRoutesProvider`), so tests cover how the route reads its parameters.
GoRoute realPoemRoute() {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  final main = container
      .read(appRoutesProvider)
      .whereType<GoRoute>()
      .firstWhere((r) => r.path == AppRoutes.main);
  return main.routes
      .whereType<GoRoute>()
      .firstWhere((r) => r.name == AppRoutes.poemDetailName);
}

/// Pumps `PoemDetailScreen` at [location] (e.g. `/main/poems/p?couplet=3`)
/// through [realPoemRoute], with [poem] as the loaded poem and nothing else
/// fetched (no more-from-poet poems, no owned poet, no reaction types). Other
/// hashtag pages show `hashtag:<slug>`.
///
/// [settle] false pumps a bounded number of frames instead of
/// `pumpAndSettle`, for a screen that may animate forever (a spinner).
Future<GoRouter> pumpPoemDetail(
  WidgetTester tester,
  String location, {
  required PoemModel poem,
  String lang = 'ur',
  bool settle = true,
}) async {
  final router = GoRouter(
    initialLocation: location,
    routes: [
      GoRoute(
        path: AppRoutes.main,
        builder: (_, __) => const SizedBox(),
        routes: [realPoemRoute()],
      ),
      GoRoute(
        path: '/hashtags/:slug',
        builder: (_, state) => Text('hashtag:${state.pathParameters['slug']}'),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      selectedLanguageProvider.overrideWithValue(lang),
      poemDetailProvider.overrideWith((ref, id) async => poem),
      poetPoemsProvider
          .overrideWith((ref, params) async => emptyHashtagPage<PoemModel>()),
      ownedPoetProvider.overrideWith((ref) async => null),
      reactionTypesProvider.overrideWith((ref) async => const <ReactionType>[]),
    ],
    child: MaterialApp.router(routerConfig: router),
  ));
  if (settle) {
    await tester.pumpAndSettle();
  } else {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }
  return router;
}
