import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Logger _logger = Logger();

// ============= BOOKMARK SEARCH HISTORY PROVIDER =============

final bookmarkSearchHistoryProvider =
    StateNotifierProvider<BookmarkSearchHistoryNotifier, List<String>>(
  (ref) => BookmarkSearchHistoryNotifier(),
);

class BookmarkSearchHistoryNotifier extends StateNotifier<List<String>> {
  static const String _historyKey = 'bookmark_search_history';
  static const int _maxHistoryItems = 10;

  BookmarkSearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_historyKey) ?? [];
      state = history;
      _logger.i('📚 Loaded ${history.length} bookmark search history items');
    } catch (e) {
      _logger.e('❌ Error loading search history: $e');
    }
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty || query.length < 3) return;

    try {
      final history = List<String>.from(state);
      history.remove(query); // Remove if exists
      history.insert(0, query); // Add to top

      if (history.length > _maxHistoryItems) {
        history.removeRange(_maxHistoryItems, history.length);
      }

      state = history;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_historyKey, history);

      _logger.i('💾 Saved search: "$query"');
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

      _logger.i('🗑️ Removed search: "$query"');
    } catch (e) {
      _logger.e('❌ Error removing search: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      state = [];
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_historyKey);

      _logger.i('🧹 Cleared all bookmark search history');
    } catch (e) {
      _logger.e('❌ Error clearing search history: $e');
    }
  }
}
