import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/features/engagement/models/reaction_models.dart';
import 'package:flutter_poetry_app/features/engagement/providers/reaction_providers.dart';

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
