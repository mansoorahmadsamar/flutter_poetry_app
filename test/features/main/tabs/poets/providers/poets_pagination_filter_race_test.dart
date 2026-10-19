import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poets_pagination_provider.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/services/poet_service.dart';

/// A page of poets whose ids say which list and page they came from.
PaginatedResponse<PoetModel> _page(String list, int page, {int total = 40}) =>
    PaginatedResponse<PoetModel>(
      content: [
        for (var i = 0; i < 10; i++)
          PoetModel(
            publicId: '$list-$page-$i',
            name: '$list $page $i',
            shortBio: '-',
            birthYear: 1800,
          ),
      ],
      totalElements: total,
      totalPages: total ~/ 10,
      last: page >= total ~/ 10 - 1,
      first: page == 0,
      size: 10,
      number: page,
    );

/// Answers "all" and "featured" pages only when the test completes the
/// matching [Completer], so responses can arrive in any order.
class _HeldPoetService extends PoetService {
  _HeldPoetService(Ref ref) : super(Dio(), ref);

  final pending = <String, Completer<PaginatedResponse<PoetModel>>>{};

  Future<PaginatedResponse<PoetModel>> _hold(String list, int page) =>
      (pending['$list/$page'] = Completer()).future;

  /// Answers the held request for [list] page [page] with its page.
  void answer(String list, int page) =>
      pending.remove('$list/$page')!.complete(_page(list, page));

  @override
  Future<PaginatedResponse<PoetModel>> getAllPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
    String sortBy = 'viewCount',
    String sortDir = 'desc',
  }) =>
      _hold('all', page);

  @override
  Future<PaginatedResponse<PoetModel>> getFeaturedPoets({
    int page = 0,
    int size = 10,
    String lang = 'ur',
  }) =>
      _hold('featured', page);
}

/// Every poet id must come from [list].
Matcher _onlyFrom(String list) => everyElement(predicate<PoetModel>(
    (p) => p.publicId.startsWith('$list-'), 'a poet from "$list"'));

void main() {
  late ProviderContainer container;
  late _HeldPoetService service;
  late PoetsPaginationNotifier notifier;

  PoetsPaginationState state() => container.read(poetsPaginationProvider);

  setUp(() async {
    container = ProviderContainer(overrides: [
      selectedLanguageProvider.overrideWithValue('ur'),
      poetServiceProvider
          .overrideWith((ref) => service = _HeldPoetService(ref)),
    ]);
    notifier = container.read(poetsPaginationProvider.notifier);
    service.answer('all', 0);
    await pumpEventQueue();
  });

  tearDown(() => container.dispose());

  test(
      'regression: a page of the old filter that lands after setFilter is '
      'dropped', () async {
    final staleMore = notifier.loadMore(); // "all" page 1, held
    await pumpEventQueue();

    final switched = notifier.setFilter(PoetsFilterType.featured);
    await pumpEventQueue();
    service.answer('featured', 0);
    await switched;

    service.answer('all', 1); // arrives late
    await staleMore;

    expect(state().poets, hasLength(10));
    expect(state().poets, _onlyFrom('featured'));
    expect(state().currentPage, 0);
    expect(state().isLoadingMore, isFalse);
    expect(state().hasMore, isTrue);

    // Paging continues on the new filter.
    final more = notifier.loadMore();
    await pumpEventQueue();
    service.answer('featured', 1);
    await more;
    expect(state().poets, hasLength(20));
    expect(state().poets, _onlyFrom('featured'));
    expect(state().currentPage, 1);
  });

  test(
      'regression: switching filter while the first page is loading loads '
      'the new filter', () async {
    final toFeatured = notifier.setFilter(PoetsFilterType.featured);
    await pumpEventQueue();
    final backToAll = notifier.setFilter(PoetsFilterType.all);
    await pumpEventQueue();

    expect(service.pending.keys, containsAll(['featured/0', 'all/0']),
        reason: 'the second switch must not be ignored');

    service.answer('all', 0);
    await backToAll;
    service.answer('featured', 0); // the abandoned filter answers last
    await toFeatured;

    expect(notifier.currentFilter, PoetsFilterType.all);
    expect(state().poets, _onlyFrom('all'));
    expect(state().isLoading, isFalse);
  });

  test('a refresh of the old filter that lands after setFilter is dropped',
      () async {
    final staleRefresh = notifier.refresh(); // "all" page 0, held
    await pumpEventQueue();

    final switched = notifier.setFilter(PoetsFilterType.featured);
    await pumpEventQueue();
    service.answer('featured', 0);
    await switched;

    service.answer('all', 0);
    await staleRefresh;

    expect(state().poets, _onlyFrom('featured'));
    expect(state().isRefreshing, isFalse);
  });

  test('a refresh that supersedes a first load clears the loading state',
      () async {
    // The first featured load never answers (its request is replaced below).
    unawaited(notifier.setFilter(PoetsFilterType.featured));
    await pumpEventQueue();
    final refreshed = notifier.refresh(); // also featured page 0
    await pumpEventQueue();
    service.answer('featured', 0);
    await refreshed;

    expect(state().isLoading, isFalse);
    expect(state().isRefreshing, isFalse);
    expect(state().poets, _onlyFrom('featured'));
  });
}
