import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/creator_poem_model.dart';
import 'creator_providers.dart';

/// Sort options exposed in the My Poems tab "Newest ▾" picker.
enum CreatorPoemsSort { date, likes, views }

extension CreatorPoemsSortX on CreatorPoemsSort {
  String get apiKey {
    switch (this) {
      case CreatorPoemsSort.date:
        return 'date';
      case CreatorPoemsSort.likes:
        return 'likes';
      case CreatorPoemsSort.views:
        return 'views';
    }
  }

  String get englishLabel {
    switch (this) {
      case CreatorPoemsSort.date:
        return 'Newest';
      case CreatorPoemsSort.likes:
        return 'Most liked';
      case CreatorPoemsSort.views:
        return 'Most read';
    }
  }
}

class CreatorPoemsState {
  const CreatorPoemsState({
    this.poems = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.sort = CreatorPoemsSort.date,
    this.totalElements = 0,
  });

  final List<CreatorPoem> poems;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final CreatorPoemsSort sort;
  final int totalElements;

  bool get isEmpty => poems.isEmpty && !isLoading;

  CreatorPoemsState copyWith({
    List<CreatorPoem>? poems,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    Object? error = _sentinel,
    CreatorPoemsSort? sort,
    int? totalElements,
  }) {
    return CreatorPoemsState(
      poems: poems ?? this.poems,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: identical(error, _sentinel) ? this.error : error as String?,
      sort: sort ?? this.sort,
      totalElements: totalElements ?? this.totalElements,
    );
  }
}

const _sentinel = Object();

class CreatorPoemsNotifier extends StateNotifier<CreatorPoemsState> {
  CreatorPoemsNotifier(this._ref) : super(const CreatorPoemsState()) {
    loadInitial();
  }

  final Ref _ref;
  static const int _pageSize = 20;

  Future<void> loadInitial() async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      poems: [],
      page: 0,
      hasMore: true,
    );
    try {
      final svc = _ref.read(creatorServiceProvider);
      final res =
          await svc.getMyPoems(page: 0, size: _pageSize, sortBy: state.sort.apiKey);
      state = state.copyWith(
        poems: res.content,
        page: 0,
        hasMore: !res.last,
        isLoading: false,
        totalElements: res.totalElements,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final next = state.page + 1;
      final svc = _ref.read(creatorServiceProvider);
      final res = await svc.getMyPoems(
        page: next,
        size: _pageSize,
        sortBy: state.sort.apiKey,
      );
      state = state.copyWith(
        poems: [...state.poems, ...res.content],
        page: next,
        hasMore: !res.last,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> setSort(CreatorPoemsSort sort) async {
    if (sort == state.sort) return;
    state = state.copyWith(sort: sort);
    await loadInitial();
  }

  /// Optimistically prepend a freshly composed poem.
  void prepend(CreatorPoem poem) {
    state = state.copyWith(
      poems: [poem, ...state.poems],
      totalElements: state.totalElements + 1,
    );
  }

  /// Replace a poem by publicId (after edit).
  void replace(CreatorPoem poem) {
    state = state.copyWith(
      poems: state.poems.map((p) => p.publicId == poem.publicId ? poem : p).toList(),
    );
  }

  void remove(String publicId) {
    state = state.copyWith(
      poems: state.poems.where((p) => p.publicId != publicId).toList(),
      totalElements: (state.totalElements - 1).clamp(0, 1 << 31),
    );
  }
}

final creatorPoemsProvider =
    StateNotifierProvider.autoDispose<CreatorPoemsNotifier, CreatorPoemsState>(
  (ref) => CreatorPoemsNotifier(ref),
);
