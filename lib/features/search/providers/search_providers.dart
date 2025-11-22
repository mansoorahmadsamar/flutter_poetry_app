import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/models/poet_model.dart';
import 'package:flutter_poetry_app/features/main/tabs/poets/providers/poet_providers.dart';
import 'package:flutter_poetry_app/core/network/dto/api_response.dart';
import 'package:flutter_poetry_app/features/search/models/search_state.dart';

final _logger = Logger();

/// Search query state provider
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Search filters state provider
final searchFiltersProvider =
    StateNotifierProvider<SearchFiltersNotifier, SearchFilters>(
  (ref) => SearchFiltersNotifier(),
);

/// Search filters notifier
class SearchFiltersNotifier extends StateNotifier<SearchFilters> {
  SearchFiltersNotifier() : super(const SearchFilters());

  void toggleEra(String era) {
    final eras = List<String>.from(state.selectedEras);
    if (eras.contains(era)) {
      eras.remove(era);
    } else {
      eras.add(era);
    }
    state = state.copyWith(selectedEras: eras);
    _logger.i('🔍 Era filters updated: $eras');
  }

  void toggleGender(String gender) {
    final genders = List<String>.from(state.selectedGenders);
    if (genders.contains(gender)) {
      genders.remove(gender);
    } else {
      genders.add(gender);
    }
    state = state.copyWith(selectedGenders: genders);
    _logger.i('🔍 Gender filters updated: $genders');
  }

  void setOnlyFeatured(bool value) {
    state = state.copyWith(onlyFeatured: value);
    _logger.i('🔍 Featured filter: $value');
  }

  void setOnlyTrending(bool value) {
    state = state.copyWith(onlyTrending: value);
    _logger.i('🔍 Trending filter: $value');
  }

  void reset() {
    state = const SearchFilters();
    _logger.i('🔍 Filters reset');
  }
}

/// Search history provider
final searchHistoryProvider =
    StateNotifierProvider<SearchHistoryNotifier, List<String>>(
  (ref) => SearchHistoryNotifier(),
);

/// Search history notifier with SharedPreferences persistence
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 10;

  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      state = history;
      _logger.i('📚 Loaded ${history.length} search history items');
    } catch (e) {
      _logger.e('❌ Error loading search history: $e');
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    try {
      final history = List<String>.from(state);

      // Remove if already exists (to move it to top)
      history.remove(query);

      // Add to beginning
      history.insert(0, query);

      // Keep only last N items
      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      state = history;

      // Persist to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, history);

      _logger.i('✅ Added search to history: $query');
    } catch (e) {
      _logger.e('❌ Error saving search history: $e');
    }
  }

  Future<void> removeSearch(String query) async {
    try {
      final history = List<String>.from(state);
      history.remove(query);
      state = history;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, history);

      _logger.i('🗑️ Removed from search history: $query');
    } catch (e) {
      _logger.e('❌ Error removing search history: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      state = [];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);
      _logger.i('🧹 Cleared all search history');
    } catch (e) {
      _logger.e('❌ Error clearing search history: $e');
    }
  }
}

/// Suggested/Featured poets provider for search screen
final suggestedPoetsProvider = FutureProvider.autoDispose<
    PaginatedResponse<PoetModel>>((ref) async {
  final service = ref.watch(poetServiceProvider);
  final lang = ref.watch(selectedLanguageProvider);

  try {
    final result = await service.getFeaturedPoets(
      lang: lang,
      page: 0,
      size: 8,
    );
    _logger.i('✅ Loaded ${result.content.length} suggested poets');
    return result;
  } catch (e) {
    _logger.e('❌ Error loading suggested poets: $e');
    rethrow;
  }
});
