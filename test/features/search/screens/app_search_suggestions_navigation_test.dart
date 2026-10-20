import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';

import '../helpers/search_test_harness.dart';

/// T-070: autocomplete poet/poem rows used to run a text search for their
/// label although the row already knew the publicId. They now open the
/// poet/poem; tag rows open the hashtag page; categories still search.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  // Shaped like the backend's PoetSuggestion / PoemSuggestion DTOs, with ids
  // and Urdu names taken from the real search fixture.
  final real = realUrduSearchResponse();
  final realPoet = real.poets.first;
  final realPoem = real.poems.first;

  final poet = AutocompletePoet(
    publicId: realPoet.publicId,
    name: realPoet.name,
  );
  final poem = AutocompletePoem(
    publicId: realPoem.publicId,
    title: realPoem.title ?? realPoem.poetryType,
    poetName: realPoem.poetName,
    poetPublicId: realPoem.poetPublicId,
    poetryType: realPoem.poetryType,
  );
  const poetWithoutId = AutocompletePoet(publicId: '-', name: 'jigar');
  const tagWithoutSlug = AutocompleteTag(
    publicId: 'tag-no-slug',
    name: 'بے نام',
    slug: '',
    tagType: 'GENERAL',
  );

  AutocompleteResponse suggestions() => AutocompleteResponse(
        poets: [poet, poetWithoutId],
        poems: [poem],
        tags: const [urduTag, tagWithoutSlug],
        categories: const [urduCategory],
      );

  GlobalSearchState suggestingState({AutocompleteResponse? results}) =>
      GlobalSearchState(
        mode: SearchMode.autocompleting,
        currentQuery: 'دل',
        autocompleteResults: results ?? suggestions(),
      );

  Finder byKey(String key) => find.byKey(ValueKey(key));

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    expect(finder, findsOneWidget);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('regression: poet suggestion opens /main/poets/:publicId',
      (tester) async {
    final app = await pumpSearchScreen(tester, state: suggestingState());

    await tapAndSettle(tester, byKey('suggestion-poet-${poet.publicId}'));

    expect(currentPath(app.router), '/main/poets/${poet.publicId}');
    expect(app.notifier.searches, isEmpty, reason: 'no text search');
  });

  testWidgets('regression: poem suggestion opens /main/poems/:publicId',
      (tester) async {
    final app = await pumpSearchScreen(tester, state: suggestingState());

    await tapAndSettle(tester, byKey('suggestion-poem-${poem.publicId}'));

    expect(currentPath(app.router), '/main/poems/${poem.publicId}');
    expect(app.notifier.searches, isEmpty);
  });

  testWidgets('tag suggestion opens /hashtags/:slug (Urdu slug)',
      (tester) async {
    final app = await pumpSearchScreen(tester, state: suggestingState());

    await tapAndSettle(tester, byKey('suggestion-tag-${urduTag.publicId}'));

    expect(currentPath(app.router), '/hashtags/${urduTag.slug}');
    expect(find.text('hashtag:${urduTag.slug}'), findsOneWidget);
  });

  testWidgets('category suggestion searches for its name', (tester) async {
    final app = await pumpSearchScreen(tester, state: suggestingState());

    await tapAndSettle(
      tester,
      byKey('suggestion-category-${urduCategory.publicId}'),
    );

    expect(app.notifier.searches.single.query, urduCategory.name);
    expect(currentPath(app.router), '/search');
  });

  testWidgets('a poet row with a "-" id falls back to a text search',
      (tester) async {
    final app = await pumpSearchScreen(tester, state: suggestingState());

    await tapAndSettle(tester, byKey('suggestion-poet-${poetWithoutId.publicId}'));

    expect(app.notifier.searches.single.query, poetWithoutId.name);
    expect(currentPath(app.router), '/search');
  });

  testWidgets('a tag row with an empty slug falls back to a text search',
      (tester) async {
    final app = await pumpSearchScreen(tester, state: suggestingState());

    await tapAndSettle(tester, byKey('suggestion-tag-${tagWithoutSlug.publicId}'));

    expect(app.notifier.searches.single.query, tagWithoutSlug.name);
  });

  testWidgets(
      'no suggestions: "search for" row runs the search',
      (tester) async {
    final app = await pumpSearchScreen(
      tester,
      state: suggestingState(results: const AutocompleteResponse()),
    );

    await tapAndSettle(tester, find.text('تلاش کریں: "دل"'));

    expect(app.notifier.searches.single.query, 'دل'); // the typed query
    expect(currentPath(app.router), '/search');
  });

  testWidgets('English suggestions render LTR and still open the poet',
      (tester) async {
    const romanPoet = AutocompletePoet(publicId: 'poet-roman', name: 'Jigar');
    final app = await pumpSearchScreen(
      tester,
      state: suggestingState(
        results: const AutocompleteResponse(poets: [romanPoet]),
      ),
      languageCode: 'en',
    );
    final row = byKey('suggestion-poet-${romanPoet.publicId}');
    expect(Directionality.of(tester.element(row)), TextDirection.ltr);

    await tapAndSettle(tester, row);

    expect(currentPath(app.router), '/main/poets/poet-roman');
  });
}
