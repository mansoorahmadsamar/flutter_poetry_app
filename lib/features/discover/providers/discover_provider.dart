import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logger/logger.dart';

import '../../../core/providers/language_provider.dart';
import '../../../features/search/providers/global_search_provider.dart';
import '../../../features/search/services/search_history_service.dart';
import '../models/discover_bundle_model.dart';
import '../services/discover_service.dart';

part 'discover_provider.freezed.dart';

/// Status for the discover screen
enum DiscoverStatus {
  initial,
  loading,
  loaded,
  error,
}

/// State for the discover screen
@freezed
class DiscoverState with _$DiscoverState {
  const factory DiscoverState({
    @Default(DiscoverStatus.initial) DiscoverStatus status,
    DiscoverBundle? bundle,
    @Default([]) List<String> recentSearches,
    String? errorMessage,
  }) = _DiscoverState;
}

/// Provider for discover state
final discoverProvider =
    StateNotifierProvider<DiscoverNotifier, DiscoverState>((ref) {
  final discoverService = ref.watch(discoverServiceProvider);
  final historyService = ref.watch(searchHistoryServiceProvider);
  final languageCode = ref.watch(selectedLanguageProvider);

  return DiscoverNotifier(
    discoverService: discoverService,
    historyService: historyService,
    languageCode: languageCode,
  );
});

/// Notifier for managing discover state
class DiscoverNotifier extends StateNotifier<DiscoverState> {
  final DiscoverService _discoverService;
  final SearchHistoryService _historyService;
  final String _languageCode;
  final _logger = Logger();

  DiscoverNotifier({
    required DiscoverService discoverService,
    required SearchHistoryService historyService,
    required String languageCode,
  })  : _discoverService = discoverService,
        _historyService = historyService,
        _languageCode = languageCode,
        super(const DiscoverState()) {
    _loadInitialData();
  }

  /// Load initial discover data
  Future<void> _loadInitialData() async {
    state = state.copyWith(status: DiscoverStatus.loading);

    try {
      final results = await Future.wait([
        _historyService.getHistory(),
        _discoverService.getDiscoverBundle(lang: _languageCode),
      ]);

      final recentSearches = results[0] as List<String>;
      final bundle = results[1] as DiscoverBundle;

      if (!mounted) return;
      state = state.copyWith(
        status: DiscoverStatus.loaded,
        bundle: bundle,
        recentSearches: recentSearches,
        errorMessage: null,
      );

      _logger.i('Discover data loaded successfully');
    } catch (e) {
      _logger.e('Error loading discover data: $e');
      if (!mounted) return;
      state = state.copyWith(
        status: DiscoverStatus.error,
        errorMessage: 'Failed to load content. Please try again.',
      );
    }
  }

  /// Refresh discover data
  Future<void> refresh() async {
    state = state.copyWith(status: DiscoverStatus.loading);

    try {
      final results = await Future.wait([
        _historyService.getHistory(),
        _discoverService.getDiscoverBundle(
          lang: _languageCode,
          forceRefresh: true,
        ),
      ]);

      final recentSearches = results[0] as List<String>;
      final bundle = results[1] as DiscoverBundle;

      if (!mounted) return;
      state = state.copyWith(
        status: DiscoverStatus.loaded,
        bundle: bundle,
        recentSearches: recentSearches,
        errorMessage: null,
      );

      _logger.i('Discover data refreshed successfully');
    } catch (e) {
      _logger.e('Error refreshing discover data: $e');
      if (!mounted) return;
      state = state.copyWith(
        status: DiscoverStatus.error,
        errorMessage: 'Failed to refresh. Please try again.',
      );
    }
  }

  /// Refresh only recent searches (after returning from search)
  Future<void> refreshRecentSearches() async {
    try {
      final recentSearches = await _historyService.getHistory();
      if (!mounted) return;
      state = state.copyWith(recentSearches: recentSearches);
    } catch (e) {
      _logger.e('Error refreshing recent searches: $e');
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _historyService.clearAll();
      if (!mounted) return;
      state = state.copyWith(recentSearches: []);
      _logger.i('Recent searches cleared');
    } catch (e) {
      _logger.e('Error clearing recent searches: $e');
    }
  }

  /// Remove a single search from history
  Future<void> removeRecentSearch(String query) async {
    try {
      await _historyService.removeSearch(query);
      if (!mounted) return;
      final updatedSearches =
          state.recentSearches.where((s) => s != query).toList();
      state = state.copyWith(recentSearches: updatedSearches);
    } catch (e) {
      _logger.e('Error removing search from history: $e');
    }
  }
}
