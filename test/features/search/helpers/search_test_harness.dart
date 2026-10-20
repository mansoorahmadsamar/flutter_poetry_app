import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_poetry_app/core/providers/language_provider.dart';
import 'package:flutter_poetry_app/core/routing/app_router.dart';
import 'package:flutter_poetry_app/features/discover/models/discover_bundle_model.dart';
import 'package:flutter_poetry_app/features/discover/services/discover_service.dart';
import 'package:flutter_poetry_app/features/search/models/global_search_state.dart';
import 'package:flutter_poetry_app/features/search/models/search_models.dart';
import 'package:flutter_poetry_app/features/search/models/search_origin.dart';
import 'package:flutter_poetry_app/features/search/providers/global_search_provider.dart';
import 'package:flutter_poetry_app/features/search/screens/app_search_screen.dart';
import 'package:flutter_poetry_app/features/search/services/search_history_service.dart';
import 'package:flutter_poetry_app/features/search/services/search_service.dart';

/// Reads `test/fixtures/search/<name>`.
Map<String, dynamic> searchFixture(String name) =>
    jsonDecode(File('test/fixtures/search/$name').readAsStringSync())
        as Map<String, dynamic>;

/// The real production response for `q=دل lang=ur`, with image URLs removed
/// (CachedNetworkImage would reach for the network and platform channels).
UnifiedSearchResponse realUrduSearchResponse() {
  final data =
      searchFixture('unified_search_dil_ur.json')['data'] as Map<String, dynamic>;
  final response = UnifiedSearchResponse.fromJson(data);
  return response.copyWith(
    poets: [for (final p in response.poets) p.copyWith(profileImageUrl: null)],
    poems: [
      for (final p in response.poems) p.copyWith(poetProfileImageUrl: null),
    ],
  );
}

/// The real production response for the Roman query `q=jigar` (4 poems,
/// 5 verse hits, 0 couplets), with image URLs removed. Its verses carry the
/// poem id and `"-"` for the poet fields (the backend before T-073).
UnifiedSearchResponse realRomanJigarResponse() {
  final data = searchFixture('unified_search_jigar.json')['data']
      as Map<String, dynamic>;
  final response = UnifiedSearchResponse.fromJson(data);
  return response.copyWith(
    poets: [for (final p in response.poets) p.copyWith(profileImageUrl: null)],
    poems: [
      for (final p in response.poems) p.copyWith(poetProfileImageUrl: null),
    ],
    verses: [
      for (final v in response.verses) v.copyWith(poetProfileImageUrl: null),
    ],
  );
}

/// The couplet contract variants (see the fixture's `_comment`), each given a
/// distinct id so their cards can be found by key.
({
  CoupletSearchResult withPoem,
  CoupletSearchResult legacyNested,
  CoupletSearchResult withoutPoem,
}) coupletVariants() {
  final v = searchFixture('couplet_result_variants.json');
  CoupletSearchResult parse(String key, String suffix) {
    final c = CoupletSearchResult.fromJson(v[key] as Map<String, dynamic>);
    return c.copyWith(publicId: '${c.publicId}-$suffix');
  }

  return (
    withPoem: parse('withNewFields', 'with-poem'),
    legacyNested: parse('legacyNestedPoem', 'legacy'),
    withoutPoem: parse('withoutNewFields', 'without-poem'),
  );
}

/// Category and tag results shaped like the backend DTOs
/// (`CategorySuggestion`, `TagSuggestion`). Production returned none for the
/// captured queries, so these are synthetic.
const urduCategory = AutocompleteCategory(
  publicId: 'cat-ghazal',
  name: 'غزل',
  poemCount: 12,
);
const urduTag = AutocompleteTag(
  publicId: 'tag-mohabbat',
  name: 'محبت',
  slug: 'محبت',
  tagType: 'THEME',
);
const romanTag = AutocompleteTag(
  publicId: 'tag-ishq',
  name: 'ishq',
  slug: 'ishq',
  tagType: 'THEME',
);
const placeholderSlugTag = AutocompleteTag(
  publicId: 'tag-no-slug',
  name: 'بے نام',
  slug: '-',
  tagType: 'GENERAL',
);

/// [results] as the last page of every type, so filtered tabs show no
/// (endlessly animating) load-more spinner.
UnifiedSearchResponse lastPage(UnifiedSearchResponse results) =>
    results.copyWith(
      hasMorePoets: false,
      hasMorePoems: false,
      hasMoreVerses: false,
      hasMoreCouplets: false,
      hasMoreTags: false,
      hasMoreCategories: false,
    );

/// Search screen state showing [results] in [segment].
GlobalSearchState resultsState(
  UnifiedSearchResponse results, {
  DiscoverSegment segment = DiscoverSegment.all,
  String query = 'دل',
  RelatedSearchesResponse? related,
}) =>
    GlobalSearchState(
      mode: SearchMode.results,
      currentQuery: query,
      activeSegment: segment,
      unifiedResults: results,
      relatedSearches: related,
    );

/// A [GlobalSearchNotifier] with a fixed state that records searches instead
/// of calling the API.
class FakeGlobalSearchNotifier extends GlobalSearchNotifier {
  FakeGlobalSearchNotifier(GlobalSearchState initial)
      : super(
          _IdleSearchService(),
          _IdleHistoryService(),
          _IdleDiscoverService(),
          'ur',
        ) {
    state = initial;
  }

  final searches =
      <({String? query, DiscoverSegment? segment, SearchOrigin? origin})>[];

  /// Tabs switched to, in order. Switching never searches here; the real
  /// reuse-or-fetch rule is covered by `global_search_tab_switch_test.dart`.
  final segmentSwitches = <DiscoverSegment>[];

  @override
  void setActiveSegment(DiscoverSegment segment) {
    segmentSwitches.add(segment);
    state = state.copyWith(activeSegment: segment);
  }

  @override
  Future<void> executeSearch({
    String? query,
    DiscoverSegment? segment,
    SearchOrigin? origin,
  }) async {
    searches.add((query: query, segment: segment, origin: origin));
  }

  /// Pagination is not under test; a real call would hit the API.
  @override
  Future<void> loadMore() async {}

  @override
  void onQueryChanged(String query) {
    state = state.copyWith(currentQuery: query.trim());
  }

  /// Puts the screen into autocomplete mode with [suggestions].
  void showSuggestions(String query, AutocompleteResponse suggestions) {
    state = state.copyWith(
      mode: SearchMode.autocompleting,
      currentQuery: query,
      autocompleteResults: suggestions,
      isLoadingAutocomplete: false,
    );
  }
}

// The notifier's constructor loads history and the discover bundle; these
// never complete, so nothing overwrites the test's state and nothing is
// fetched.
class _IdleHistoryService implements SearchHistoryService {
  @override
  Future<List<String>> getHistory() => Completer<List<String>>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _IdleDiscoverService implements DiscoverService {
  @override
  Future<DiscoverBundle> getDiscoverBundle({
    required String lang,
    bool forceRefresh = false,
  }) =>
      Completer<DiscoverBundle>().future;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _IdleSearchService implements SearchService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// Stand-in for a destination screen: shows which route and id it got.
class DestinationStub extends StatelessWidget {
  const DestinationStub(this.kind, this.id, {super.key});

  final String kind;
  final String id;

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Text('$kind:$id', textDirection: TextDirection.ltr));
}

/// The app's search route plus the real detail routes (same paths and the
/// same [AppRoutes] names as `app_router.dart`), with stub screens.
GoRouter buildSearchTestRouter() => GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) => const AppSearchScreen(),
        ),
        GoRoute(
          path: AppRoutes.main,
          builder: (context, state) => const Text('main'),
          routes: [
            GoRoute(
              path: 'poets/:publicId',
              name: AppRoutes.poetDetailName,
              builder: (context, state) =>
                  DestinationStub('poet', state.pathParameters['publicId']!),
            ),
            GoRoute(
              path: 'poems/:publicId',
              name: AppRoutes.poemDetailName,
              builder: (context, state) =>
                  DestinationStub('poem', state.pathParameters['publicId']!),
            ),
          ],
        ),
        GoRoute(
          path: '/hashtags/:slug',
          name: AppRoutes.hashtagDetailName,
          builder: (context, state) =>
              DestinationStub('hashtag', state.pathParameters['slug']!),
        ),
      ],
    );

/// The location of the top-most route (including pushed ones),
/// percent-decoded.
String currentPath(GoRouter router) =>
    Uri.decodeComponent(router.state.uri.path);

/// Pumps [AppSearchScreen] at `/search` with [state], in [languageCode], on a
/// tall surface so every result is built without scrolling.
Future<({GoRouter router, FakeGlobalSearchNotifier notifier})>
    pumpSearchScreen(
  WidgetTester tester, {
  required GlobalSearchState state,
  String languageCode = 'ur',
}) async {
  tester.view.physicalSize = const Size(900, 4000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final notifier = FakeGlobalSearchNotifier(state);
  final router = buildSearchTestRouter();
  addTearDown(router.dispose);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        globalSearchProvider.overrideWith((ref) => notifier),
        selectedLanguageProvider.overrideWithValue(languageCode),
      ],
      child: MaterialApp.router(routerConfig: router),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, notifier: notifier);
}
