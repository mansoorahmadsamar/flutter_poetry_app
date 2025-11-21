import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/poet_model.dart';
import '../services/poet_service.dart';
import 'poet_providers.dart';

part 'poets_pagination_provider.freezed.dart';

/// Pagination state for poets list
@freezed
class PoetsPaginationState with _$PoetsPaginationState {
  const factory PoetsPaginationState({
    @Default([]) List<PoetModel> poets,
    @Default(0) int currentPage,
    @Default(true) bool hasMore,
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default(false) bool isRefreshing,
    String? error,
    @Default(10) int pageSize,
  }) = _PoetsPaginationState;
}

/// Filter type for poets list
enum PoetsFilterType {
  all,
  trending,
  featured,
  topByViews,
  classical,
  modern,
  women,
}

/// Notifier for managing paginated poets
class PoetsPaginationNotifier extends StateNotifier<PoetsPaginationState> {
  final PoetService _poetService;
  final String _language;
  PoetsFilterType _currentFilter = PoetsFilterType.all;

  PoetsPaginationNotifier(this._poetService, this._language)
      : super(const PoetsPaginationState()) {
    loadInitial();
  }

  PoetsFilterType get currentFilter => _currentFilter;

  /// Load initial page of poets
  Future<void> loadInitial() async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      poets: [],
      currentPage: 0,
      hasMore: true,
    );

    try {
      final result = await _fetchPoets(0);
      state = state.copyWith(
        isLoading: false,
        poets: result.content,
        currentPage: 0,
        hasMore: !result.last,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load more poets (next page)
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true, error: null);

    try {
      final nextPage = state.currentPage + 1;
      final result = await _fetchPoets(nextPage);

      state = state.copyWith(
        isLoadingMore: false,
        poets: [...state.poets, ...result.content],
        currentPage: nextPage,
        hasMore: !result.last,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  /// Refresh the list (pull-to-refresh)
  Future<void> refresh() async {
    if (state.isRefreshing) return;

    state = state.copyWith(isRefreshing: true, error: null);

    try {
      final result = await _fetchPoets(0);
      state = state.copyWith(
        isRefreshing: false,
        poets: result.content,
        currentPage: 0,
        hasMore: !result.last,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      );
    }
  }

  /// Change filter and reload
  Future<void> setFilter(PoetsFilterType filter) async {
    if (_currentFilter == filter) return;

    _currentFilter = filter;
    await loadInitial();
  }

  /// Fetch poets based on current filter
  Future<dynamic> _fetchPoets(int page) async {
    switch (_currentFilter) {
      case PoetsFilterType.all:
        return _poetService.getAllPoets(
          page: page,
          size: state.pageSize,
          lang: _language,
        );
      case PoetsFilterType.trending:
        return _poetService.getTrendingPoets(
          page: page,
          size: state.pageSize,
          lang: _language,
        );
      case PoetsFilterType.featured:
        return _poetService.getFeaturedPoets(
          page: page,
          size: state.pageSize,
          lang: _language,
        );
      case PoetsFilterType.topByViews:
        return _poetService.getTopPoetsByViews(
          page: page,
          size: state.pageSize,
          lang: _language,
        );
      case PoetsFilterType.classical:
        return _poetService.getPoetsByEra(
          era: 'CLASSICAL',
          page: page,
          size: state.pageSize,
          lang: _language,
        );
      case PoetsFilterType.modern:
        return _poetService.getPoetsByEra(
          era: 'MODERN',
          page: page,
          size: state.pageSize,
          lang: _language,
        );
      case PoetsFilterType.women:
        return _poetService.getPoetsByGender(
          gender: 'FEMALE',
          page: page,
          size: state.pageSize,
          lang: _language,
        );
    }
  }
}

/// Provider for paginated poets
final poetsPaginationProvider =
    StateNotifierProvider<PoetsPaginationNotifier, PoetsPaginationState>((ref) {
  final poetService = ref.watch(poetServiceProvider);
  final language = ref.watch(selectedLanguageProvider);
  return PoetsPaginationNotifier(poetService, language);
});
